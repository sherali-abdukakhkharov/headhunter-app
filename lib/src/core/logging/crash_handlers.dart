import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/logging/app_log.dart';

/// Routes every uncaught error through [AppLog].
///
/// ## What was happening instead
///
/// Two kinds of failure never reached anybody:
///
/// - **A framework error** — an overflow, a bad build, a failed assertion — is
///   printed in debug and, in a release build, handed to a default handler that
///   says nothing. A tester on a release APK saw a red screen or nothing at all
///   and had nothing to report but "it broke".
/// - **An uncaught asynchronous error** — a `Future` nobody awaited, an error
///   thrown off the frame — went to the platform and vanished the same way.
///
/// Both now produce one structured line, which is the difference between a bug
/// report that names an event and one that says the app closed.
///
/// ## `PlatformDispatcher.onError`, not `runZonedGuarded`
///
/// The zone version wraps `runApp` and is the older recipe. It has a real trap:
/// the binding must be initialized *inside* the same zone, so a
/// `WidgetsFlutterBinding.ensureInitialized()` in the wrong place makes every
/// later platform message cross a zone boundary and Flutter complains at
/// runtime. `PlatformDispatcher.instance.onError` needs no zone and catches the
/// same errors.
///
/// ## The previous handler still runs
///
/// Returning without calling it would **swallow the red screen in debug**,
/// which is worse than the silence this replaces: the loudest possible signal
/// during development, deleted to add a log line.
/// ## Installing twice reports twice, so it does not
///
/// Each handler chains onto whatever was there, which is what lets this sit
/// beside another one. Called a second time it would chain onto *itself*, and
/// one error would produce two records — noise in production and a confusing
/// failure in a test, which is how this was found.
bool _installed = false;

/// For tests: allow the handlers to be installed again.
@visibleForTesting
void resetCrashHandlers() => _installed = false;

void installCrashHandlers() {
  if (_installed) return;
  _installed = true;

  final previousFlutterError = FlutterError.onError;

  FlutterError.onError = (details) {
    AppLog.error(
      'app.flutter_error',
      error: details.exception,
      stackTrace: details.stack,
      fields: {
        // The library and the short description, not the whole dump: the sink
        // carries the stack, and a log line long enough to scroll off the
        // buffer is one nobody reads.
        'library': details.library ?? 'unknown',
        if (details.context case final context?)
          'context': context.toDescription(),
      },
    );

    previousFlutterError?.call(details);
  };

  final previousPlatformError = PlatformDispatcher.instance.onError;

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLog.error('app.uncaught_error', error: error, stackTrace: stack);

    // `true` means handled, which stops it reaching the platform's own crash
    // path. Deferring to a previous handler first so installing this twice, or
    // beside something else, does not silently drop one of them.
    return previousPlatformError?.call(error, stack) ?? true;
  };
}
