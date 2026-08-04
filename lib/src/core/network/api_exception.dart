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
      DioExceptionType.badResponse => _messageForStatus(status),
      DioExceptionType.unknown => 'An unexpected network error occurred.',
    };

    return ApiException(message, statusCode: status, cause: e);
  }

  /// Message safe to render directly in the UI.
  final String message;

  /// HTTP status code, when the failure came from a server response.
  final int? statusCode;

  /// The underlying error, kept for logging - never shown to users.
  final Object? cause;

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
  String toString() =>
      'ApiException(${statusCode ?? 'no status'}): $message';
}
