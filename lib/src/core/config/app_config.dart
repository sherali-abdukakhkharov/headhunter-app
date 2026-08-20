import 'package:jobbridge_app/src/core/config/app_flavor.dart';

/// Compile-time application configuration.
///
/// Values come from `--dart-define`, so a build carries its own target
/// environment and nothing is read from disk at runtime.
///
/// ```sh
/// flutter run --dart-define=FLAVOR=development
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.42:3001
/// ```
///
/// **No secrets belong here** (§12.5). `--dart-define` values are compiled into
/// the binary as plain string constants and are recoverable from an APK with
/// `strings`, so this file may hold hostnames and feature switches and nothing
/// else. API keys and signing material stay on the server or in CI secrets.
abstract final class AppConfig {
  /// The build target this binary was compiled for.
  static const AppFlavor flavor = AppFlavor.current;

  /// Base URL of the headhunter-backend API.
  ///
  /// Defaults to [AppFlavor.apiBaseUrl] for the active flavor, so a normal
  /// build needs only `FLAVOR`. An explicit `API_BASE_URL` still wins - that is
  /// how a physical device reaches a backend on the development machine, and
  /// how a testing build is pointed at a review environment.
  ///
  /// The development default is `10.0.2.2:3001`. `10.0.2.2` is how the Android
  /// emulator reaches the host machine's loopback interface; `localhost` inside
  /// the emulator refers to the emulator itself, so it will never find a server
  /// on your PC. Port 3001 matches `HTTP_PORT` in headhunter-backend/.env -
  /// 3000 is already taken on this machine by the `sahih-bot` container.
  ///
  /// On a physical device, pass your machine's LAN IP instead:
  /// `--dart-define=API_BASE_URL=http://192.168.1.42:3001`
  static String get apiBaseUrl =>
      _apiBaseUrlOverride.isEmpty ? flavor.apiBaseUrl : _apiBaseUrlOverride;

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Whether [apiBaseUrl] came from `--dart-define` rather than the flavor.
  /// Surfaced in the debug footer so "which backend am I actually talking to"
  /// is answerable from the device.
  static bool get isApiBaseUrlOverridden => _apiBaseUrlOverride.isNotEmpty;

  /// Request timeout for a single API call.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Whether verbose network logging is enabled.
  ///
  /// Off in release builds *and* off in the production flavor regardless of
  /// build mode: §12.1 requires logging without sensitive data, and a profile
  /// build of production is still production.
  static bool get isNetworkLoggingEnabled =>
      !const bool.fromEnvironment('dart.vm.product') && !flavor.isProduction;
}
