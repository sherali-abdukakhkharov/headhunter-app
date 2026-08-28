import 'package:dio/dio.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';

/// What went wrong, at the level a screen can act on.
///
/// The point of separating this from [ApiException.message] is that a screen
/// sometimes has to *behave* differently rather than merely say something
/// different: an offline failure should keep whatever is already on screen and
/// offer a retry, while a 403 has nothing to retry and the content is gone.
/// Matching on a message string to decide that would break the first time the
/// copy is edited.
enum ApiFailureKind {
  /// The request never reached the server. Almost always the device's own
  /// connection, and the only kind the user can personally fix.
  offline,

  /// The server was reached and did not answer in time.
  timeout,

  /// Cancelled by the app, usually by leaving the screen mid-request.
  cancelled,

  /// TLS validation failed. Common on captive-portal wifi.
  certificate,

  /// The server answered, and the answer was a failure.
  server,

  /// Something else went wrong in the transport.
  unknown;

  /// Whether this is the connection rather than the product.
  ///
  /// **Timeout counts.** From the server's side the two are different events;
  /// from the reader's side they are one situation with one remedy — check the
  /// connection and try again — and a heading that said "something went wrong"
  /// for a timeout would be blaming the app for a train tunnel.
  ///
  /// A certificate failure is deliberately **not** here even though captive
  /// portals cause most of them: "no connection" would be a lie on a network
  /// that is plainly working, and the honest answer is the generic one.
  bool get isConnection =>
      this == ApiFailureKind.offline || this == ApiFailureKind.timeout;
}

/// The heading a failure should carry.
///
/// Every screen in this app rendered `stateErrorTitle` — "Something went
/// wrong" — over every failure, including the ones where nothing had. That is a
/// claim about the system, and for a reader on a bad connection it is both
/// wrong and unhelpful: it points at the app instead of at the thing they can
/// fix. §12.4 asks for the offline state to be explicit, and the cold start
/// already is; this is the same treatment inside the shell.
///
/// The *message* needed nothing: `ApiException` already carries a localized
/// sentence about the connection for these kinds, because the server was never
/// reached and could not send one. Only the heading contradicted it.
String failureTitle(Object? error, AppL10n l10n) =>
    error is ApiException && error.kind.isConnection
    ? l10n.stateOfflineTitle
    : l10n.stateErrorTitle;

/// A network or server failure, already translated into something the UI can
/// show a user.
///
/// Widgets should never see a raw [DioException]; repositories convert at the
/// boundary via [ApiException.fromDioException].
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.cause,
    this.kind = ApiFailureKind.unknown,
  });

  /// Translates a [DioException] into a user-presentable failure.
  factory ApiException.fromDioException(DioException e) {
    final status = e.response?.statusCode;
    final l10n = localizations;

    final kind = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiFailureKind.timeout,
      DioExceptionType.connectionError => ApiFailureKind.offline,
      DioExceptionType.cancel => ApiFailureKind.cancelled,
      DioExceptionType.badCertificate => ApiFailureKind.certificate,
      DioExceptionType.badResponse => ApiFailureKind.server,
      DioExceptionType.unknown => ApiFailureKind.unknown,
    };

    final message = switch (kind) {
      ApiFailureKind.timeout => l10n.apiErrorTimeout,
      // **Never "is the backend running, and is the base URL correct".** That
      // was the copy until 2026-08-25 and it shipped to users, who can act on
      // neither and reasonably concluded they had misconfigured the app
      // (MT-014). What a person can act on is their own connection.
      ApiFailureKind.offline => l10n.apiErrorOffline,
      ApiFailureKind.cancelled => l10n.apiErrorCancelled,
      ApiFailureKind.certificate => l10n.apiErrorCertificate,
      ApiFailureKind.server =>
        _serverMessage(e.response?.data) ?? _messageForStatus(l10n, status),
      ApiFailureKind.unknown => l10n.apiErrorUnexpected,
    };

    return ApiException(message, statusCode: status, cause: e, kind: kind);
  }

  /// How failures are worded, in the active interface variant.
  ///
  /// **A settable static, and deliberately.** An [ApiException] is built inside
  /// a repository, far from any `BuildContext`, in 117 places. Threading a
  /// localizer through all of them would put a translation concern into every
  /// data-layer signature to serve the handful of cases the server cannot word
  /// itself. So the wording is installed once, the way the `x-lang` header is:
  /// `LangInterceptor` takes an `AppLocale Function()` for the same reason.
  ///
  /// [installLocalizations] is called from the app root whenever the variant
  /// changes. Until then this is the fallback variant rather than null, so a
  /// failure during the first frames still has words — and tests get a working
  /// default without a fixture.
  static AppL10n localizations = lookupAppL10n(AppLocale.fallback.locale);

  /// Points the wording at [locale]. Called from `JobBridgeApp` on every build,
  /// which is how a language change reaches errors raised afterwards.
  ///
  /// Errors already constructed keep the words they were built with: a message
  /// is a string by the time anything can render it. That is correct — the
  /// alternative is a screen whose error text changes under the reader without
  /// the request having been retried.
  static void installLocalizations(AppLocale locale) =>
      localizations = lookupAppL10n(locale.locale);

  /// The server's own message, when it sent one.
  ///
  /// **Preferred over [_messageForStatus] whenever it exists**, because the
  /// status alone is usually the wrong thing to say. A 401 from
  /// `/auth/otp/verify` means "that code is wrong" and the generic text for 401
  /// is "your session has expired, please sign in again" — advice that is not
  /// merely unhelpful during a sign-in, it is describing a different event.
  ///
  /// Safe to render directly, and **already in the right language**: the
  /// backend's exception filter answers every failure with
  /// `{statusCode, code, message}` where `message` is translated into the
  /// caller's `x-lang` and is deliberately generic about internals — never a
  /// stack trace, an SQL fragment or a driver message. That is a contract with
  /// a test behind it on the other side, and it is why the fallbacks below are
  /// reached far less often than their number suggests.
  ///
  /// Falls through to the status text for anything not of that shape: a proxy's
  /// HTML error page, a gateway timeout body, or a plain-string response are
  /// all things that reach a mobile client, and none of them should be shown
  /// to a user.
  static String? _serverMessage(Object? data) {
    if (data is! Map) return null;

    final message = data['message'];
    if (message is! String || message.trim().isEmpty) return null;

    return message;
  }

  /// Message safe to render directly in the UI.
  final String message;

  /// HTTP status code, when the failure came from a server response.
  final int? statusCode;

  /// What kind of failure this was, for screens that must behave differently
  /// rather than only say something different.
  final ApiFailureKind kind;

  /// The underlying error, kept for logging - never shown to users.
  final Object? cause;

  /// True when retrying the same request could plausibly succeed.
  ///
  /// Offline, timeout and 5xx are conditions that pass; a 403 or a 422 will
  /// answer identically forever, and offering "try again" there is an
  /// invitation to press a button that cannot work.
  bool get isRetryable => switch (kind) {
    ApiFailureKind.offline ||
    ApiFailureKind.timeout ||
    ApiFailureKind.unknown => true,
    ApiFailureKind.cancelled || ApiFailureKind.certificate => false,
    ApiFailureKind.server => statusCode != null && statusCode! >= 500,
  };

  /// Fallback copy, used only when the server sent no usable message.
  ///
  /// Necessarily vague: at this point all that is known is a number.
  static String _messageForStatus(AppL10n l10n, int? status) =>
      switch (status) {
    400 => l10n.apiErrorBadRequest,
    401 => l10n.sessionExpired,
    403 => l10n.apiErrorForbidden,
    404 => l10n.apiErrorNotFound,
    409 => l10n.apiErrorConflict,
    422 => l10n.apiErrorUnprocessable,
    429 => l10n.apiErrorTooManyRequests,
    _ when status != null && status >= 500 => l10n.apiErrorServer,
    _ => l10n.stateErrorBody,
  };

  @override
  String toString() => 'ApiException(${statusCode ?? 'no status'}): $message';
}
