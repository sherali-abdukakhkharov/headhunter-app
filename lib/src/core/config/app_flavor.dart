/// The three build targets §12.1 requires: development, testing, production.
///
/// A flavor is chosen at **build** time via `--dart-define=FLAVOR=...` and
/// carries the API base URL, the app id suffix and the display name. Nothing is
/// read from disk at runtime and nothing is switchable in the UI - a build
/// knows which environment it belongs to and cannot be pointed at another.
///
/// ## Why the app id differs per flavor
///
/// The suffix lets development, testing and production install **side by side**
/// on one device. Without it, a tester installing the production build silently
/// replaces the one they were testing, and its data goes with it. The suffix is
/// applied by Gradle (see `android/app/build.gradle.kts`), not here;
/// [appIdSuffix] exists so the two halves are stated in one place and can be
/// asserted by a test.
enum AppFlavor {
  /// Local development against a backend on this machine.
  development(
    apiBaseUrl: 'http://10.0.2.2:3001',
    appIdSuffix: '.dev',
    displayName: 'HeadHunter Dev',
  ),

  /// The shared environment used for UAT (§13).
  ///
  /// **This is §12.1's "testing" flavor, renamed.** The Android Gradle Plugin
  /// rejects any product flavor whose name starts with `test` - it collides
  /// with the `test` and `androidTest` source sets - so `testing` is not a
  /// legal name on that side. Rather than carry one name in Dart and another in
  /// Gradle, which is a trap every time someone pairs `--flavor` with
  /// `--dart-define=FLAVOR=`, both say `staging`.
  ///
  /// The host is a placeholder until the environment exists; a build for it
  /// passes `--dart-define=API_BASE_URL=...` explicitly, which always wins.
  staging(
    apiBaseUrl: 'https://api.staging.headhunter.uz',
    appIdSuffix: '.staging',
    displayName: 'HeadHunter Staging',
  ),

  /// The store build. No suffix, and the display name carries no environment
  /// marker.
  production(
    apiBaseUrl: 'https://api.headhunter.uz',
    appIdSuffix: '',
    displayName: 'HeadHunter',
  );

  const AppFlavor({
    required this.apiBaseUrl,
    required this.appIdSuffix,
    required this.displayName,
  });

  /// Default API base URL for this flavor. An explicit
  /// `--dart-define=API_BASE_URL` overrides it - see `AppConfig.apiBaseUrl`.
  final String apiBaseUrl;

  /// Suffix Gradle appends to `com.headhunter.app` for this flavor.
  final String appIdSuffix;

  /// Launcher name and in-app title. Deliberately **not** localized: §2.4
  /// forbids translating proper names, and a user reporting a bug should be
  /// able to name their build whatever language they read the app in.
  final String displayName;

  /// The flavor this binary was built as.
  ///
  /// Defaults to [development] so `flutter run` with no arguments does the
  /// obvious thing. That default is safe in exactly one direction: forgetting
  /// the flag can only ever produce a *less* privileged build pointed at a
  /// local backend, never a development build wearing production's identity.
  static const AppFlavor current = _parsed;

  static const String _name = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'development',
  );

  // Written as a const conditional rather than a lookup so the whole chain
  // folds at compile time and the unused flavors are tree-shaken.
  static const AppFlavor _parsed = _name == 'production'
      ? production
      : _name == 'staging'
      ? staging
      : development;

  /// Whether this is the store build. Gate anything that must never ship -
  /// debug menus, seeded data, verbose logging - on this rather than on
  /// `kDebugMode`, because a *profile* build of production is still production.
  bool get isProduction => this == production;

  /// Whether development-only surfaces (the design gallery, the role switcher)
  /// may be reachable.
  ///
  /// Deliberately not `kDebugMode`: a release build of the development flavor
  /// is exactly what gets handed to the client for a look, and the switcher has
  /// to work there.
  bool get allowsDevelopmentTools => !isProduction;
}
