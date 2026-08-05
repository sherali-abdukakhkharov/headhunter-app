import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';

/// Screens render `ApiException.message` directly, so what this class chooses
/// to say *is* the user-facing copy for every server failure in the app.
void main() {
  DioException badResponse(int status, {Object? body}) {
    final options = RequestOptions(path: '/auth/otp/verify');
    return DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<Object?>(
        requestOptions: options,
        statusCode: status,
        data: body,
      ),
    );
  }

  group('server message', () {
    test('is preferred over the generic text for the status', () {
      // The case that motivated this. A 401 from /auth/otp/verify means "that
      // code is wrong"; the generic 401 copy is "your session has expired,
      // please sign in again", which during a sign-in describes a different
      // event entirely and tells the user to do what they are already doing.
      final e = ApiException.fromDioException(
        badResponse(401, body: const {
          'statusCode': 401,
          'code': 'auth.otp_invalid',
          'message': 'The code is invalid or has expired.',
        }),
      );

      expect(e.message, 'The code is invalid or has expired.');
      expect(e.statusCode, 401);
    });

    test('carries the localization the server already did', () {
      // The backend translates into the caller's x-lang before answering, which
      // is the only reason the app can render these without a lookup table of
      // its own.
      final e = ApiException.fromDioException(
        badResponse(429, body: const {
          'message': 'Kod allaqachon yuborilgan. Biroz kuting.',
        }),
      );

      expect(e.message, 'Kod allaqachon yuborilgan. Biroz kuting.');
    });
  });

  group('fallback to the status', () {
    test('when there is no body at all', () {
      final e = ApiException.fromDioException(badResponse(401));

      expect(e.message, contains('session has expired'));
    });

    test('when the body is not an object', () {
      // A proxy's HTML error page, or a plain-string body. Neither is something
      // to show a user.
      final e = ApiException.fromDioException(
        badResponse(502, body: '<html><body>502 Bad Gateway</body></html>'),
      );

      expect(e.message, isNot(contains('html')));
      expect(e.message, contains('server ran into a problem'));
    });

    test('when message is absent, blank or the wrong type', () {
      for (final body in [
        const <String, Object?>{'statusCode': 403},
        const <String, Object?>{'message': '   '},
        const <String, Object?>{'message': 42},
        const <String, Object?>{'message': null},
      ]) {
        expect(
          ApiException.fromDioException(badResponse(403, body: body)).message,
          contains('permission'),
          reason: 'body $body should fall through to the status text',
        );
      }
    });
  });

  group('non-response failures', () {
    test('a connection error names the likely cause', () {
      final e = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(e.message, contains('Cannot reach the server'));
      expect(e.statusCode, isNull);
    });
  });
}
