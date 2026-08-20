import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/network/log_redaction.dart';

/// §12.1: log without sensitive data. dio's `LogInterceptor` prints headers and
/// both bodies verbatim, so this is the thing standing between a developer's
/// logcat and a working set of credentials.
void main() {
  group('redacts', () {
    test('the bearer token on an authenticated request', () {
      const line =
          'authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhIn0.sig';

      final out = redactSensitive(line);

      expect(out, isNot(contains('eyJhbGci')));
      expect(out, 'authorization: Bearer <redacted>');
    });

    test('the token pair in a sign-in response', () {
      const line =
          '{"accessToken":"eyJabc.def.ghi","refreshToken":"afrm7t3b9NZ",'
          '"expiresInSeconds":900}';

      final out = redactSensitive(line);

      expect(out, isNot(contains('eyJabc')));
      expect(out, isNot(contains('afrm7t3b9NZ')));
      // The rest of the body still has to be readable, or the log is useless.
      expect(out, contains('"expiresInSeconds":900'));
    });

    test('the one-time code, sent and echoed back', () {
      expect(
        redactSensitive('{"phone":"+998901234567","code":"666666"}'),
        isNot(contains('666666')),
      );
      expect(
        redactSensitive('{"devCode":"666666"}'),
        '{"devCode":"<redacted>"}',
      );
    });

    // `idToken` is kept in the redaction list although the client no longer
    // sends one: the backend's /auth/telegram still accepts it, and a key that
    // stops being redacted is a leak waiting for the day it comes back.
    test('an OIDC id token', () {
      expect(
        redactSensitive('{"idToken":"eyJraWQiOiIx"}'),
        '{"idToken":"<redacted>"}',
      );
    });
  });

  group('keeps what makes a log worth reading', () {
    test("the backend's error key, which shares the name `code`", () {
      // The single most useful field when a call fails, and not a secret. It is
      // told apart from an OTP by not being a run of digits.
      const line = '{"statusCode":401,"code":"auth.otp_invalid",'
          '"message":"The code is invalid or has expired."}';

      expect(redactSensitive(line), line);
    });

    test('the phone number, masked to its last two digits', () {
      // Enough to tell two test accounts apart; matches how the backend logs
      // them (`maskPhone`).
      expect(
        redactSensitive('{"phone":"+998901234567"}'),
        '{"phone":"***67"}',
      );
    });

    test('an ordinary line, untouched', () {
      const line = '*** Request ***\nuri: http://10.0.2.2:3001/health\n';

      expect(redactSensitive(line), line);
    });
  });

  // dio logs a *request* body by calling toString() on the Dart Map, so the
  // outgoing secrets are unquoted. Rules written against JSON alone pass every
  // test above and still leak every one of these - which is what a real logcat
  // showed before these cases existed.
  group('the unquoted Dart-Map form dio logs for requests', () {
    test('masks the phone on the send call', () {
      expect(redactSensitive('{phone: +998955555555}'), '{phone: ***55}');
    });

    test('redacts the code on the verify call, keeping the rest', () {
      expect(
        redactSensitive('{phone: +998955555555, code: 666666, '
            'platform: android}'),
        '{phone: ***55, code: <redacted>, platform: android}',
      );
    });

    test('redacts a refresh token on the refresh call', () {
      expect(
        redactSensitive('{refreshToken: afrm7t3b9NZ-x8OxYEIHqQ}'),
        '{refreshToken: <redacted>}',
      );
    });
  });

  test('leaves statusCode alone despite ending in "code"', () {
    expect(
      redactSensitive('{"statusCode":401,"message":"nope"}'),
      '{"statusCode":401,"message":"nope"}',
    );
  });

  test('handles several secrets in one line', () {
    const line =
        'headers: authorization: Bearer abc.def\n'
        'body: {"refreshToken":"xyz","phone":"+998901234567"}';

    final out = redactSensitive(line);

    expect(out, isNot(contains('abc.def')));
    expect(out, isNot(contains('xyz')));
    expect(out, isNot(contains('901234567')));
  });
}
