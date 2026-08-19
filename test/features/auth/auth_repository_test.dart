import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/auth_session.dart';

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

  const challengeBody = '''
{
  "expiresAt": "2026-08-05T12:05:00+05:00",
  "resendAvailableAt": "2026-08-05T12:01:00+05:00",
  "devCode": "666666"
}
''';

  group('sendOtp', () {
    test('posts the wire phone to /auth/otp/send', () async {
      final h = build(body: challengeBody);
      await h.repo.sendOtp('+998901234567');

      expect(h.adapter.captured?.path, '/auth/otp/send');
      expect(h.adapter.captured?.method, 'POST');
      expect((h.adapter.captured?.data as Map?)?['phone'], '+998901234567');
    });

    test('sends no purpose, so the server decides what happened', () async {
      // Registration and login are one flow for a phone-only identity (§4.1).
      // Letting the client name the purpose would be a way to probe which
      // numbers are already registered.
      final h = build(body: challengeBody);
      await h.repo.sendOtp('+998901234567');

      expect((h.adapter.captured?.data as Map?)?.containsKey('purpose'), false);
    });

    test('parses both deadlines and the dev code', () async {
      final h = build(body: challengeBody);
      final challenge = await h.repo.sendOtp('+998901234567');

      expect(challenge.expiresAt.wallClock.hour, 12);
      expect(challenge.devCode, '666666');
    });

    test('is flagged skipAuth, so a 401 is not read as expiry', () async {
      final h = build(body: challengeBody);
      await h.repo.sendOtp('+998901234567');

      expect(h.adapter.captured?.extra[AuthInterceptor.skipAuthFlag], isTrue);
    });

    test('surfaces a 429 as ApiException', () async {
      // Expected traffic, not a bug: this is how §4.2's resend delay and the
      // per-phone rate limit are enforced.
      final h = build(statusCode: 429, body: '{"message":"Too soon"}');

      await expectLater(
        h.repo.sendOtp('+998901234567'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });

    test('an empty body is an ApiException, not a null dereference', () async {
      final h = build(body: '');

      await expectLater(
        h.repo.sendOtp('+998901234567'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('resendOtp', () {
    test('hits the resend route, not send', () async {
      // Separate routes are separate rate-limit subjects on the server.
      final h = build(body: challengeBody);
      await h.repo.resendOtp('+998901234567');

      expect(h.adapter.captured?.path, '/auth/otp/resend');
    });
  });

  group('verifyOtp', () {
    test('posts the phone and code to /auth/otp/verify', () async {
      final h = build(body: successBody);
      await h.repo.verifyOtp(phone: '+998901234567', code: '666666');

      expect(h.adapter.captured?.path, '/auth/otp/verify');
      final data = h.adapter.captured?.data as Map?;
      expect(data?['phone'], '+998901234567');
      expect(data?['code'], '666666');
    });

    test('parses the same session shape the Telegram path returned', () async {
      // Both paths return AuthTokensResponseDto, which is what lets the session
      // model and the role-selection redirect be written once.
      final h = build(body: successBody);
      final session = await h.repo.verifyOtp(
        phone: '+998901234567',
        code: '666666',
      );

      expect(session.accessToken, 'access-1');
      expect(session.grantedRoles, {AppRole.candidate});
      expect(session.isNewUser, isTrue);
    });

    test('is flagged skipAuth, so a 401 is not read as expiry', () async {
      // A 401 here means the code was wrong, expired or already used. Without
      // the flag the interceptor would try to refresh a session that does not
      // exist and report a spurious sign-out instead.
      final h = build(body: successBody);
      await h.repo.verifyOtp(phone: '+998901234567', code: '666666');

      expect(h.adapter.captured?.extra[AuthInterceptor.skipAuthFlag], isTrue);
    });

    test('surfaces a wrong code as ApiException', () async {
      final h = build(statusCode: 401, body: '{"message":"Invalid code"}');

      await expectLater(
        h.repo.verifyOtp(phone: '+998901234567', code: '000000'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('an empty body is an ApiException, not a null dereference', () async {
      final h = build(body: '');

      await expectLater(
        h.repo.verifyOtp(phone: '+998901234567', code: '666666'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('refresh', () {
    test('posts the refresh token and returns the whole session', () async {
      // The whole session, not just the pair: cold-start restore needs the
      // roles and the account status, which is what separates this from the
      // interceptor's own narrower refresh.
      final h = build(body: successBody);
      final session = await h.repo.refresh('refresh-1');

      expect(h.adapter.captured?.path, '/auth/refresh');
      expect(
        (h.adapter.captured?.data as Map?)?['refreshToken'],
        'refresh-1',
      );
      expect(session.grantedRoles, {AppRole.candidate});
    });

    test('is flagged skipAuth: a 401 here is the answer', () async {
      // Without the flag the interceptor would try to refresh a refresh.
      final h = build(body: successBody);
      await h.repo.refresh('refresh-1');

      expect(h.adapter.captured?.extra[AuthInterceptor.skipAuthFlag], isTrue);
    });

    test('surfaces a dead session as a 401 ApiException', () async {
      final h = build(statusCode: 401, body: '{"message":"Session expired"}');

      await expectLater(
        h.repo.refresh('refresh-1'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('logout', () {
    test('posts the refresh token to /auth/logout', () async {
      final h = build(statusCode: 204);
      await h.repo.logout('refresh-1');

      expect(h.adapter.captured?.path, '/auth/logout');
      expect(
        (h.adapter.captured?.data as Map?)?['refreshToken'],
        'refresh-1',
      );
    });

    test('is flagged skipAuth, so an expired access token can still log out',
        () async {
      final h = build(statusCode: 204);
      await h.repo.logout('refresh-1');

      expect(h.adapter.captured?.extra[AuthInterceptor.skipAuthFlag], isTrue);
    });
  });

  group('selectRoles', () {
    test('sends wire values and returns what the server granted', () async {
      // Not an echo of the request: an administrator may already have granted
      // something (§10), and trusting the request would drop it.
      final h = build(body: '{"roles":["candidate","employer"]}');

      final granted = await h.repo.selectRoles({AppRole.candidate});

      expect(h.adapter.captured?.path, '/auth/roles');
      expect((h.adapter.captured?.data as Map?)?['roles'], ['candidate']);
      expect(granted, {AppRole.candidate, AppRole.employer});
    });

    test('is NOT flagged skipAuth - it is an authenticated call', () async {
      // A 401 here really does mean the access token expired, and the
      // interceptor should refresh and replay rather than give up.
      final h = build(body: '{"roles":["candidate"]}');
      await h.repo.selectRoles({AppRole.candidate});

      expect(
        h.adapter.captured?.extra[AuthInterceptor.skipAuthFlag],
        isNot(isTrue),
      );
    });

    test('drops a role this client version does not know', () async {
      final h = build(body: '{"roles":["candidate","moderator"]}');

      expect(await h.repo.selectRoles({AppRole.candidate}), {
        AppRole.candidate,
      });
    });

    test('a body without roles is an ApiException', () async {
      // The stub's default body is `{}` - a 200 carrying nothing usable.
      final h = build();

      await expectLater(
        h.repo.selectRoles({AppRole.candidate}),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // Deprecated 2026-08-05 but kept working; see docs/TELEGRAM_LOGIN.md. These
  // stay so the path cannot rot silently while nothing calls it.
  group('signInWithTelegram (deprecated)', () {
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
