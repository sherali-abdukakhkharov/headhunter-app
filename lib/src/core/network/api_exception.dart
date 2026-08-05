import 'package:dio/dio.dart';

/// A network or server failure, already translated into something the UI can
/// show a user.
///
/// Widgets should never see a raw [DioException]; repositories convert at the
/// boundary via [ApiException.fromDioException].
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.cause});

  /// Translates a [DioException] into a user-presentable failure.
  factory ApiException.fromDioException(DioException e) {
    final status = e.response?.statusCode;

    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        'The server took too long to respond. Check your connection and '
            'try again.',
      DioExceptionType.connectionError =>
        'Cannot reach the server. Is the backend running, and is the base '
            'URL correct for this device?',
      DioExceptionType.cancel => 'The request was cancelled.',
      DioExceptionType.badCertificate =>
        'The server presented an invalid security certificate.',
      DioExceptionType.badResponse =>
        _serverMessage(e.response?.data) ?? _messageForStatus(status),
      DioExceptionType.unknown => 'An unexpected network error occurred.',
    };

    return ApiException(message, statusCode: status, cause: e);
  }

  /// The server's own message, when it sent one.
  ///
  /// **Preferred over [_messageForStatus] whenever it exists**, because the
  /// status alone is usually the wrong thing to say. A 401 from
  /// `/auth/otp/verify` means "that code is wrong" and the generic text for 401
  /// is "your session has expired, please sign in again" — advice that is not
  /// merely unhelpful during a sign-in, it is describing a different event.
  ///
  /// Safe to render directly. The backend's exception filter answers every
  /// failure with `{statusCode, code, message}` where `message` is translated
  /// into the caller's `x-lang` and is deliberately generic about internals —
  /// never a stack trace, an SQL fragment or a driver message. That is a
  /// contract with a test behind it on the other side.
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

  /// The underlying error, kept for logging - never shown to users.
  final Object? cause;

  /// Fallback copy, used only when the server sent no usable message.
  ///
  /// Necessarily vague: at this point all that is known is a number.
  static String _messageForStatus(int? status) => switch (status) {
    400 => 'The request was invalid.',
    401 => 'Your session has expired. Please sign in again.',
    403 => 'You do not have permission to do that.',
    404 => 'The requested resource was not found.',
    409 => 'That conflicts with existing data.',
    422 => 'Some of the submitted data was not valid.',
    429 => 'Too many requests. Please slow down and try again shortly.',
    _ when status != null && status >= 500 =>
      'The server ran into a problem. Please try again later.',
    _ => 'The request failed.',
  };

  @override
  String toString() => 'ApiException(${statusCode ?? 'no status'}): $message';
}
