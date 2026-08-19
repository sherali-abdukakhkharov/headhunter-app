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
    displayName: 'JobBridge Dev',
    // Registered with BotFather 2026-08-05 against com.jobbridge.app.dev and
    // this machine's debug signing certificate.
    telegramRedirectUri: 'https://app1562839855-login.tg.dev/tglogin',
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
  /// **The host below does not exist**, and that is deliberate rather than
  /// neglect. There is one real backend today (`hh.qitmir.uz`, on
  /// [production]); pointing staging at it as well would let a staging build
  /// write production data with nothing to signal it. A staging build therefore
  /// fails to reach anything until a second environment exists, or someone
  /// passes `--dart-define=API_BASE_URL=...` deliberately, which always wins.
  staging(
    apiBaseUrl: 'https://api.staging.headhunter.uz',
    appIdSuffix: '.staging',
    displayName: 'JobBridge Staging',
    // Empty: com.jobbridge.app.staging is not registered with BotFather yet,
    // and cannot be until it has its own signing keystore. Empty makes
    // `telegramSignInUnavailableReason` fail loudly at the button instead of
    // sending the user into a login that Telegram will silently refuse.
    telegramRedirectUri: '',
  ),

  /// The store build. No suffix, and the display name carries no environment
  /// marker.
  ///
  /// `hh.qitmir.uz` is the live backend, confirmed 2026-08-05: `GET /health`
  /// answers 200 over HTTPS and `POST /auth/telegram` answers 401 for a bogus
  /// token rather than 404, so that deployment carries the Telegram endpoint.
  production(
    apiBaseUrl: 'https://hh.qitmir.uz',
    appIdSuffix: '',
    displayName: 'JobBridge',
    // Empty until com.jobbridge.app is registered against the **Play App
    // Signing** certificate, whose SHA-256 comes from the Play Console. The
    // current debug-signed production build is not the one that ships, so
    // registering its fingerprint would be registering a throwaway.
    telegramRedirectUri: '',
  );

  const AppFlavor({
    required this.apiBaseUrl,
    required this.appIdSuffix,
    required this.displayName,
    required this.telegramRedirectUri,
  });

  /// Default API base URL for this flavor. An explicit
  /// `--dart-define=API_BASE_URL` overrides it - see `AppConfig.apiBaseUrl`.
  final String apiBaseUrl;

  /// Suffix Gradle appends to `com.jobbridge.app` for this flavor.
  final String appIdSuffix;

  /// Launcher name and in-app title. Deliberately **not** localized: §2.4
  /// forbids translating proper names, and a user reporting a bug should be
  /// able to name their build whatever language they read the app in.
  final String displayName;

  /// OIDC redirect URI for Telegram login, or empty when this flavor's
  /// application id is not registered with BotFather.
  ///
  /// **Per flavor, not per app**, and that is the whole reason this lives here:
  /// Telegram registers a redirect URI against one **application id plus one
  /// signing certificate**, and M0.5 gave the three flavors three different
  /// application ids. A single shared value would work in development and fail
  /// in exactly the environment nobody tested. See docs/TELEGRAM_LOGIN.md §7.
  ///
  /// Must match what is registered in BotFather **byte for byte**, including
  /// the `/tglogin` path - Telegram refuses to redirect anywhere else, and that
  /// refusal is the login's security boundary.
  final String telegramRedirectUri;

  /// Whether Telegram sign-in can work in this build.
  bool get isTelegramSignInAvailable => telegramRedirectUri.isNotEmpty;

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
