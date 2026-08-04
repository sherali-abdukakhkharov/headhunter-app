import 'dart:ui' show Locale;

/// The four interface variants the specification requires (§3.2), as a closed
/// set.
///
/// This enum - not `AppL10n.supportedLocales` - is the app's source of
/// truth for which locales exist.
///
/// **Why not the generated list.** `gen-l10n` emits
/// `supportedLocales = [Locale('en'), Locale('ru'), Locale('uz')]`: it drops
/// the script codes, even though it generates working `AppL10nUzLatn` and
/// `AppL10nUzCyrl` classes and a `lookupAppL10n` that dispatches on
/// `scriptCode`. Handing the generated list to `MaterialApp` would let
/// `basicLocaleListResolution` collapse a `uz-Cyrl` preference onto plain `uz`,
/// which resolves to Latin - Cyrillic would be unreachable through the UI and
/// nothing would fail loudly. [supportedLocales] below restores the script
/// codes. The delegate accepts them because its `isSupported` matches on
/// `languageCode` alone.
///
/// This is the tooling handing us exactly the collapse ARCHITECTURE.md §4.2
/// warns about, so it is worth stating twice: **never key on
/// `locale.languageCode`.** Use [tag], or the enum value itself.
enum AppLocale {
  /// Uzbek, Latin script. The product's primary language and the base ARB.
  uzLatn(
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
    'uz-Latn',
    "O'zbekcha (Lotin)",
  ),

  /// Uzbek, Cyrillic script. A distinct interface variant, not a rendering of
  /// [uzLatn] - the two never share a cache entry or an ARB file.
  uzCyrl(
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    'uz-Cyrl',
    'Ўзбекча (Кирилл)',
  ),

  ru(Locale('ru'), 'ru', 'Русский'),

  en(Locale('en'), 'en', 'English');

  const AppLocale(this.locale, this.tag, this.nativeName);

  /// The Flutter locale, carrying `scriptCode` where the language needs one.
  final Locale locale;

  /// Canonical BCP-47 tag: lowercase language, title-case script.
  ///
  /// This exact casing is the frozen wire contract with the backend - it is the
  /// `x-lang` header value, it comes back in the response body's `locale`, and
  /// it appears inside dictionary ETags. A casing slip here is a silent
  /// permanent cache miss rather than an error, so it is asserted in tests.
  final String tag;

  /// The language's name in its own language.
  ///
  /// Deliberately not localized: a language picker that renders every option in
  /// the *current* language is unusable to someone who cannot read the current
  /// language, which is the only situation in which the picker matters. §2.4
  /// also forbids translating user-facing proper names.
  final String nativeName;

  /// Locales handed to `MaterialApp.supportedLocales`, in preference order.
  static const List<Locale> supportedLocales = [
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    Locale('ru'),
    Locale('en'),
  ];

  /// The locale used when nothing has been chosen and the device offers no
  /// usable hint.
  static const AppLocale fallback = uzLatn;

  /// Parses a stored or wire tag, tolerating the aliases the backend accepts.
  ///
  /// Returns null for anything unrecognized rather than guessing, so a
  /// corrupted preference falls through to device resolution instead of
  /// silently pinning the wrong script.
  static AppLocale? fromTag(String? tag) {
    if (tag == null || tag.isEmpty) return null;

    // Normalize separator and case: 'uz_latn', 'UZ-LATN' and 'uz-Latn' are the
    // same request. Only the canonical form is ever *emitted*.
    final normalized = tag.replaceAll('_', '-').toLowerCase();

    return switch (normalized) {
      'uz-latn' || 'uz' => uzLatn,
      'uz-cyrl' || 'oz' => uzCyrl,
      'ru' => ru,
      'en' => en,
      _ => null,
    };
  }

  /// Maps a device locale onto the closest supported variant.
  ///
  /// A bare `uz` from the platform carries no script information, so it
  /// resolves to [uzLatn] - an explicit default rather than whatever locale
  /// resolution would have picked.
  static AppLocale fromDeviceLocale(Locale deviceLocale) {
    if (deviceLocale.languageCode == 'uz') {
      return deviceLocale.scriptCode == 'Cyrl' ? uzCyrl : uzLatn;
    }
    return fromTag(deviceLocale.languageCode) ?? fallback;
  }

  /// Resolution order used when a key is missing from this variant: the chain
  /// required by §3.2, `uz-Cyrl -> uz-Latn -> en`.
  ///
  /// Nothing consumes this at runtime - `gen-l10n` resolves missing keys
  /// against the template at build time, and the CI key-set check makes a gap
  /// a build failure rather than a runtime fallback. It is here so the
  /// intended order is stated in code next to the locales it orders, and
  /// asserted by a test.
  List<AppLocale> get fallbackChain => switch (this) {
    uzCyrl => const [uzCyrl, uzLatn, en],
    uzLatn => const [uzLatn, en],
    ru => const [ru, en],
    en => const [en],
  };
}
