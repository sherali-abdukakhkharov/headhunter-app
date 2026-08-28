import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/network/log_redaction.dart';

/// One structured log line.
///
/// ## Why a record rather than a sentence
///
/// Everything in this app logged with `debugPrint('some sentence $value')`,
/// which is fine to read and impossible to search: two lines about the same
/// event are worded differently by whoever wrote them, and nothing can be
/// grepped except by guessing the wording. §12.1 asks for logging without
/// sensitive data, and a shape is also what makes the redaction reliable —
/// [fields] go through [redactSensitive] as a unit rather than each call site
/// remembering.
///
/// ## Why still `debugPrint`
///
/// `developer.log` writes only to the VM service, so it is invisible in
/// `flutter run`, `flutter logs` and logcat — exactly where somebody looks when
/// the app misbehaves. The same reason the dio interceptor uses it.
@immutable
class LogRecord {
  const LogRecord({
    required this.event,
    this.level = LogLevel.info,
    this.fields = const {},
    this.error,
    this.stackTrace,
  });

  /// A stable, greppable name. `auth.otp_sent`, not "sent the OTP".
  final String event;

  final LogLevel level;

  /// Structured context. Values are stringified and redacted.
  final Map<String, Object?> fields;

  final Object? error;
  final StackTrace? stackTrace;

  /// The line as it reaches logcat, already redacted.
  ///
  /// The error is included but the stack trace is **not**: a stack is long
  /// enough to bury every other line in the buffer, and it is the sink's job to
  /// carry it somewhere it can be read.
  String format() {
    final buffer = StringBuffer('[${level.name}] $event');

    for (final entry in fields.entries) {
      buffer.write(' ${entry.key}=${entry.value}');
    }

    if (error != null) buffer.write(' error=$error');

    return redactSensitive(buffer.toString());
  }
}

enum LogLevel { debug, info, warn, error }

/// Anywhere a record can go besides the console.
///
/// **Deliberately empty of any service.** A crash reporter sends stack traces
/// and device details off the device, which is a privacy-policy question (§4.2
/// names an approved privacy policy) and not one to answer by adding a package.
/// This is the seam it plugs into: implement [record] and install it in
/// `main.dart`, and nothing else in the app has to change.
///
/// It is also the half that cannot be verified here — a Gradle plugin change is
/// unbuildable in this environment, and a broken one breaks every release.
// ignore: one_member_abstracts
abstract class LogSink {
  // A class rather than a `void Function(LogRecord)`, deliberately: a sink is a
  // *thing* with a lifetime — it opens a connection, batches, flushes on
  // pause — and `addSink` deduplicates by identity, which a closure cannot
  // give. The lint is answered here rather than obeyed.
  void record(LogRecord record);
}

/// The app's logger.
///
/// Static because logging must work before any provider exists — including
/// inside the error handlers, which fire while the tree is being built.
abstract final class AppLog {
  static final List<LogSink> _sinks = [];

  /// Adds a destination. Idempotent per instance.
  static void addSink(LogSink sink) {
    if (!_sinks.contains(sink)) _sinks.add(sink);
  }

  /// For tests: forget every sink.
  @visibleForTesting
  static void clearSinks() => _sinks.clear();

  static void log(LogRecord record) {
    debugPrint('[jobbridge] ${record.format()}');

    for (final sink in _sinks) {
      // A sink that throws must not take the app with it — this runs from the
      // error handlers, so a throw here would be an error while reporting an
      // error, which is the shape of an infinite loop.
      try {
        sink.record(record);
      } on Object catch (e) {
        debugPrint('[jobbridge] [error] log.sink_failed error=$e');
      }
    }
  }

  static void info(String event, {Map<String, Object?> fields = const {}}) =>
      log(LogRecord(event: event, fields: fields));

  static void warn(String event, {Map<String, Object?> fields = const {}}) =>
      log(LogRecord(event: event, level: LogLevel.warn, fields: fields));

  static void error(
    String event, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  }) => log(
    LogRecord(
      event: event,
      level: LogLevel.error,
      fields: fields,
      error: error,
      stackTrace: stackTrace,
    ),
  );
}
