import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/core/auth/token_store.dart';
import 'package:headhunter_app/src/core/network/interceptors/auth_interceptor.dart';

/// Serves canned responses without touching a socket.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode) => ResponseBody.fromString(
  '{}',
  statusCode,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenStore tokenStore;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'auth.access_token': 'expired-access',
      'auth.refresh_token': 'refresh-1',
    });
    tokenStore = const TokenStore(FlutterSecureStorage());
  });

  /// Builds a client whose adapter rejects anything but the post-refresh token.
  ({Dio dio, int Function() refreshCount, int Function() authFailures}) build({
    required Future<TokenPair?> Function(String) refresh,
  }) {
    var refreshCount = 0;
    var authFailures = 0;

    Future<ResponseBody> serve(RequestOptions options) async {
      // Yield so concurrent requests genuinely overlap rather than completing
      // one at a time in submission order.
      await Future<void>.delayed(Duration.zero);
      return options.headers['Authorization'] == 'Bearer fresh-access'
          ? _json(200)
          : _json(401);
    }

    final retryClient = Dio()..httpClientAdapter = _FakeAdapter(serve);
    final dio = Dio()..httpClientAdapter = _FakeAdapter(serve);

    dio.interceptors.add(
      AuthInterceptor(
        tokenStore: tokenStore,
        retryClient: retryClient,
        refresh: (token) async {
          refreshCount++;
          return refresh(token);
        },
        onAuthFailure: () async {
          authFailures++;
        },
      ),
    );

    return (
      dio: dio,
      refreshCount: () => refreshCount,
      authFailures: () => authFailures,
    );
  }

  Future<TokenPair?> succeedingRefresh(String _) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const TokenPair(
      accessToken: 'fresh-access',
      refreshToken: 'refresh-2',
    );
  }

  group('AuthInterceptor single-flight refresh', () {
    // The reason this matters is not efficiency. The backend rotates refresh
    // tokens and detects reuse per session family: a second concurrent refresh
    // presents an already-superseded token, which reads as theft and revokes
    // every session in the family. Without single-flight, a user is signed out
    // by their own retry.
    test('concurrent 401s trigger exactly one refresh', () async {
      final h = build(refresh: succeedingRefresh);

      final responses = await Future.wait([
        h.dio.get<dynamic>('/a'),
        h.dio.get<dynamic>('/b'),
        h.dio.get<dynamic>('/c'),
      ]);

      expect(h.refreshCount(), 1, reason: 'one refresh for three 401s');
      expect(responses.map((r) => r.statusCode), everyElement(200));
    });

    test('all concurrent requests are replayed and succeed', () async {
      final h = build(refresh: succeedingRefresh);

      final results = await Future.wait([
        h.dio.get<dynamic>('/a'),
        h.dio.get<dynamic>('/b'),
      ]);

      expect(results, hasLength(2));
      expect(results.every((r) => r.statusCode == 200), isTrue);
      expect(h.authFailures(), 0);
    });

    test('the refreshed pair is persisted', () async {
      final h = build(refresh: succeedingRefresh);
      await h.dio.get<dynamic>('/a');

      expect(await tokenStore.readAccessToken(), 'fresh-access');
      expect(await tokenStore.readRefreshToken(), 'refresh-2');
    });

    test('a later 401 refreshes again - the gate is not sticky', () async {
      final h = build(refresh: succeedingRefresh);

      await h.dio.get<dynamic>('/a');
      expect(h.refreshCount(), 1);

      // Put the store back into an expired state and go again.
      await tokenStore.save(
        const TokenPair(accessToken: 'expired-access', refreshToken: 'r'),
      );
      await h.dio.get<dynamic>('/b');

      expect(h.refreshCount(), 2);
    });
  });

  group('AuthInterceptor failure handling', () {
    test('a refused refresh signs out once and clears tokens', () async {
      final h = build(refresh: (_) async => null);

      await expectLater(
        Future.wait([h.dio.get<dynamic>('/a'), h.dio.get<dynamic>('/b')]),
        throwsA(isA<DioException>()),
      );

      expect(h.refreshCount(), 1);
      expect(await tokenStore.readAccessToken(), isNull);
      expect(await tokenStore.readRefreshToken(), isNull);
    });

    // A refresh that throws is a network failure, not proof the session died.
    // Clearing tokens here would sign users out every time they drive through a
    // tunnel.
    test('a refresh that throws leaves the session intact', () async {
      final h = build(refresh: (_) async => throw const SocketExceptionStub());

      await expectLater(
        h.dio.get<dynamic>('/a'),
        throwsA(isA<DioException>()),
      );

      expect(await tokenStore.readRefreshToken(), 'refresh-1');
      expect(h.authFailures(), 0);
    });

    test('requests flagged skipAuth never trigger a refresh', () async {
      final h = build(refresh: succeedingRefresh);

      await expectLater(
        h.dio.get<dynamic>(
          // The MVP's sign-in endpoint. A 401 here means Telegram's ID token
          // was rejected, not that a session expired - so a refresh would be
          // nonsense, there is no session yet.
          '/auth/telegram',
          options: Options(extra: {AuthInterceptor.skipAuthFlag: true}),
        ),
        throwsA(isA<DioException>()),
      );

      expect(h.refreshCount(), 0);
    });

    test('a replay that 401s again does not loop', () async {
      // Refresh "succeeds" but hands back a token the server still rejects.
      final h = build(
        refresh: (_) async => const TokenPair(
          accessToken: 'still-wrong',
          refreshToken: 'r2',
        ),
      );

      await expectLater(
        h.dio.get<dynamic>('/a'),
        throwsA(isA<DioException>()),
      );

      expect(h.refreshCount(), 1, reason: 'the retry flag stops a second pass');
    });
  });
}

/// Stand-in for a transport failure; the interceptor only cares that it throws.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
