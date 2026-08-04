/// Compile-time application configuration.
///
/// Values come from `--dart-define`, so a build carries its own target
/// environment and nothing is read from disk at runtime.
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
/// ```
abstract final class AppConfig {
  /// Base URL of the headhunter-backend API.
  ///
  /// Defaults to `10.0.2.2`, which is how the Android emulator reaches the
  /// host machine's loopback interface. `localhost` inside the emulator refers
  /// to the emulator itself, so it will never find a server on your PC.
  ///
  /// On a physical device, pass your machine's LAN IP instead:
  /// `--dart-define=API_BASE_URL=http://192.168.1.42:3000`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// Request timeout for a single API call.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Whether verbose network logging is enabled. Off in release builds.
  static bool get isNetworkLoggingEnabled => !const bool.fromEnvironment(
    'dart.vm.product',
  );
}
