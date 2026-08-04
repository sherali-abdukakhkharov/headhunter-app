import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:headhunter_app/src/features/auth/data/auth_repository.dart';
import 'package:headhunter_app/src/features/auth/domain/auth_session.dart';

/// Captures the request and replies with a canned response, so nothing leaves
/// the process. Same pattern as `test/features/health/`.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  ({AuthRepository repo, _StubAdapter adapter}) build({
    int statusCode = 200,
    String body = '{}',
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3001'));
    final adapter = _StubAdapter(statusCode: statusCode, body: body);
    dio.httpClientAdapter = adapter;
    return (repo: AuthRepository(dio), adapter: adapter);
  }

  const successBody = '''
{
  "accessToken": "access-1",
  "refreshToken": "refresh-1",
  "expiresInSeconds": 900,
  "roles": ["candidate"],
  "activeRole": "candidate",
  "isNewUser": true
}
''';

  group('signInWithTelegram', () {
    test('parses the session the backend returns', () async {
      final h = build(body: successBody);

      final session = await h.repo.signInWithTelegram('id-token');

      expect(session.accessToken, 'access-1');
      expect(session.refreshToken, 'refresh-1');
      expect(session.expiresInSeconds, 900);
      expect(session.grantedRoles, {AppRole.candidate});
      expect(session.active, AppRole.candidate);
      expect(session.isNewUser, isTrue);
    });

    test('posts the id token to /auth/telegram', () async {
      final h = build(body: successBody);
      await h.repo.signInWithTelegram('id-token');

      expect(h.adapter.captured?.path, '/auth/telegram');
      expect(h.adapter.captured?.method, 'POST');
      expect(
        (h.adapter.captured?.data as Map?)?['idToken'],
        'id-token',
      );
    });

    test('is flagged skipAuth, so a 401 is not read as expiry', () async {
      // No session exists yet. Without the flag the auth interceptor treats a
      // 401 as an expired access token, tries to refresh, fails, clears the
      // token store and reports an auth failure - turning "Telegram rejected
      // your token" into a spurious sign-out.
      final h = build(body: successBody);
      await h.repo.signInWithTelegram('id-token');

      expect(
        h.adapter.captured?.extra[AuthInterceptor.skipAuthFlag],
        isTrue,
      );
    });

    test('surfaces a refusal as ApiException, not a DioException', () async {
      // The BR-01 path: the backend refuses a login carrying no
      // Telegram-verified phone number. Its message is already localized via
      // x-lang, so the screen renders it directly.
      final h = build(statusCode: 422, body: '{"message":"Phone required"}');

      await expectLater(
        h.repo.signInWithTelegram('id-token'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422),
        ),
      );
    });

    test('an empty body is an ApiException, not a null dereference', () async {
      final h = build(body: '');

      await expectLater(
        h.repo.signInWithTelegram('id-token'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AuthSession', () {
    test('drops a role this client version does not know', () {
      // Forward compatibility: the server may grant a role before the app ships
      // support for it. That must not crash deserialization, and it must not
      // become a role we then try to build a shell for.
      final session = AuthSession.fromJson({
        'accessToken': 'a',
        'refreshToken': 'r',
        'expiresInSeconds': 900,
        'roles': ['candidate', 'moderator'],
        'activeRole': 'candidate',
        'isNewUser': false,
      });

      expect(session.grantedRoles, {AppRole.candidate});
    });

    test('tolerates a null activeRole', () {
      // Sent when the account holds several roles and has chosen none; the
      // client then routes into role selection.
      final session = AuthSession.fromJson({
        'accessToken': 'a',
        'refreshToken': 'r',
        'expiresInSeconds': 900,
        'roles': <String>[],
        'activeRole': null,
        'isNewUser': true,
      });

      expect(session.active, isNull);
      expect(session.grantedRoles, isEmpty);
    });

    test('never puts token material in toString', () {
      // These strings reach log lines and crash reports. As with TokenPair.
      final session = AuthSession.fromJson({
        'accessToken': 'super-secret-access',
        'refreshToken': 'super-secret-refresh',
        'expiresInSeconds': 900,
        'roles': ['candidate'],
        'activeRole': 'candidate',
        'isNewUser': false,
      });

      expect(session.toString(), isNot(contains('super-secret')));
      expect(session.toString(), contains('redacted'));
    });
  });
}
