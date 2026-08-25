import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';

/// Screens render `ApiException.message` directly, so what this class chooses
/// to say *is* the user-facing copy for every server failure in the app.
///
/// The copy is asserted against the ARB rather than against English fragments.
/// That is the whole point of MT-014's fix: these strings used to be hardcoded
/// English in a product with four interface variants, so a Russian-reading user
/// who lost signal was told — in English — to check whether "the backend" was
/// running and whether the "base URL" was correct for their device.
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

  DioException transport(DioExceptionType type) => DioException(
    requestOptions: RequestOptions(path: '/health'),
    type: type,
  );

  // The ARB for one variant, through the same lookup the production code uses.
  // Asserting against this rather than a literal means a copy edit moves the
  // expectation with it, while a *missing* translation still fails.
  AppL10n copyFor(AppLocale locale) => lookupAppL10n(locale.locale);

  // Every case restores this, so one test cannot leave the wording pointed at
  // a variant the next one does not expect.
  final original = ApiException.localizations;
  tearDown(() => ApiException.localizations = original);

  group('server message', () {
    test('is preferred over the generic text for the status', () {
      // The case that motivated this. A 401 from /auth/otp/verify means "that
      // code is wrong"; the generic 401 copy is "your session has expired,
      // please sign in again", which during a sign-in describes a different
      // event entirely and tells the user to do what they are already doing.
      final e = ApiException.fromDioException(
        badResponse(
          401,
          body: const {
            'statusCode': 401,
            'code': 'auth.otp_invalid',
            'message': 'The code is invalid or has expired.',
          },
        ),
      );

      expect(e.message, 'The code is invalid or has expired.');
      expect(e.statusCode, 401);
      expect(e.kind, ApiFailureKind.server);
    });

    test('carries the localization the server already did', () {
      // The backend translates into the caller's x-lang before answering, which
      // is the only reason the app can render these without a lookup table of
      // its own — and why the fallbacks below are reached far less often than
      // their number suggests.
      final e = ApiException.fromDioException(
        badResponse(429, body: const {
          'message': 'Kod allaqachon yuborilgan. Biroz kuting.',
        }),
      );

      expect(e.message, 'Kod allaqachon yuborilgan. Biroz kuting.');
    });
  });

  group('fallback to the status', () {
    // This group is about which status maps to which sentence, not about
    // language, so it reads in English. The variants are covered below.
    setUp(() => ApiException.installLocalizations(AppLocale.en));

    test('when there is no body at all', () {
      final e = ApiException.fromDioException(badResponse(401));

      expect(e.message, copyFor(AppLocale.en).sessionExpired);
    });

    test('when the body is not an object', () {
      // A proxy's HTML error page, or a plain-string body. Neither is something
      // to show a user.
      final e = ApiException.fromDioException(
        badResponse(502, body: '<html><body>502 Bad Gateway</body></html>'),
      );

      expect(e.message, isNot(contains('html')));
      expect(e.message, copyFor(AppLocale.en).apiErrorServer);
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
          copyFor(AppLocale.en).apiErrorForbidden,
          reason: 'body $body should fall through to the status text',
        );
      }
    });
  });

  group('MT-014: a transport failure speaks the user’s language', () {
    test('and never mentions the backend or a base URL', () {
      // The literal words that shipped. Asserted across every variant, because
      // the failure was that one variant's worth of English served all four.
      for (final locale in AppLocale.values) {
        ApiException.installLocalizations(locale);
        final message = ApiException.fromDioException(
          transport(DioExceptionType.connectionError),
        ).message;

        expect(
          message.toLowerCase(),
          isNot(anyOf(contains('backend'), contains('base url'))),
          reason: '$locale still carries developer-facing copy',
        );
      }
    });

    test('in each variant, and the four are four distinct strings', () {
      final seen = <AppLocale, String>{};

      for (final locale in AppLocale.values) {
        ApiException.installLocalizations(locale);
        seen[locale] = ApiException.fromDioException(
          transport(DioExceptionType.connectionError),
        ).message;
      }

      expect(seen[AppLocale.en], copyFor(AppLocale.en).apiErrorOffline);
      expect(seen[AppLocale.ru], copyFor(AppLocale.ru).apiErrorOffline);
      expect(seen[AppLocale.uzLatn], copyFor(AppLocale.uzLatn).apiErrorOffline);
      expect(seen[AppLocale.uzCyrl], copyFor(AppLocale.uzCyrl).apiErrorOffline);

      // The two Uzbek scripts are separate interface variants, never a
      // rendering of one another, so collapsing them here would be the same
      // bug AppLocale exists to prevent.
      expect(seen.values.toSet(), hasLength(AppLocale.values.length));
    });

    test('the default variant is the fallback, not English', () {
      // A failure during the first frames — before JobBridgeApp has built and
      // installed anything — still has to have words, and the words a user of
      // this product is most likely to read are Uzbek Latin.
      ApiException.localizations = lookupAppL10n(AppLocale.fallback.locale);

      expect(
        ApiException.fromDioException(
          transport(DioExceptionType.connectionError),
        ).message,
        copyFor(AppLocale.uzLatn).apiErrorOffline,
      );
    });
  });

  group('the kind, which is what a screen can act on', () {
    test('separates the four transport failures from a server answer', () {
      expect(
        ApiException.fromDioException(
          transport(DioExceptionType.connectionError),
        ).kind,
        ApiFailureKind.offline,
      );
      expect(
        ApiException.fromDioException(
          transport(DioExceptionType.receiveTimeout),
        ).kind,
        ApiFailureKind.timeout,
      );
      expect(
        ApiException.fromDioException(transport(DioExceptionType.cancel)).kind,
        ApiFailureKind.cancelled,
      );
      expect(
        ApiException.fromDioException(
          transport(DioExceptionType.badCertificate),
        ).kind,
        ApiFailureKind.certificate,
      );
      expect(
        ApiException.fromDioException(badResponse(403)).kind,
        ApiFailureKind.server,
      );
      expect(
        ApiException.fromDioException(
          transport(DioExceptionType.connectionError),
        ).statusCode,
        isNull,
      );
    });

    test('a retry is offered only where one could work', () {
      bool retryable(DioException e) =>
          ApiException.fromDioException(e).isRetryable;

      expect(retryable(transport(DioExceptionType.connectionError)), isTrue);
      expect(retryable(transport(DioExceptionType.receiveTimeout)), isTrue);
      expect(retryable(badResponse(503)), isTrue);

      // These answer identically however many times they are asked, so a
      // "try again" button on them is an invitation to press something that
      // cannot work.
      expect(retryable(badResponse(403)), isFalse);
      expect(retryable(badResponse(422)), isFalse);
      expect(retryable(transport(DioExceptionType.cancel)), isFalse);
      expect(retryable(transport(DioExceptionType.badCertificate)), isFalse);
    });
  });
}
