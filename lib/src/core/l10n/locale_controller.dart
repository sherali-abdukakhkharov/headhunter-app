import 'dart:ui' show PlatformDispatcher;

import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

/// The active interface language.
///
/// Ownership follows §3.2: the language is selectable **before** registration,
/// so local storage is the source of truth pre-auth. After sign-in the
/// account's value wins on a device that has never been asked, and a choice
/// made here wins and travels. **Both halves exist as of 2026-08-28** — this
/// class owns the local one and `LocaleSync` owns the server one, because
/// `core/` must not import a feature's repository.
///
/// Kept alive: this is read by the `x-lang` interceptor on every request and by
/// `MaterialApp.locale`, so it must not be rebuilt when a screen is disposed.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  /// Preferences key. Stores the canonical BCP-47 tag, never an enum index -
  /// reordering the enum must not silently change a user's language.
  static const _storageKey = 'locale.tag';

  @override
  Future<AppLocale> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    final stored = AppLocale.fromTag(prefs.getString(_storageKey));
    if (stored != null) return stored;

    // Nothing chosen yet. Fall back to the device language rather than the
    // product default, so a Russian-speaking user is not shown Uzbek on first
    // launch and left hunting for the picker.
    return AppLocale.fromDeviceLocale(
      PlatformDispatcher.instance.locale,
    );
  }

  /// Whether the user has ever chosen a language on this install.
  ///
  /// The stored key is written by [select] alone, so its absence means "never
  /// chosen" rather than "chose the default". That distinction is what decides
  /// who wins at sign-in: a choice made here is the more recent statement of
  /// intent and travels to the account, and a device that has never been asked
  /// takes the account's answer instead of overwriting it with a guess made
  /// from the phone's system language.
  Future<bool> hasLocalChoice() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);

    return prefs.getString(_storageKey) != null;
  }

  /// Applies and persists a language choice, locally.
  ///
  /// Writes optimistically so the UI switches immediately; a failed write costs
  /// the preference on next launch, not the current session.
  ///
  /// **The server half lives in `LocaleSync`**, not here: pushing it needs a
  /// repository, and `core/` reaching into a feature is the wrong direction.
  /// Call the sync from a screen — it does this and then the push.
  Future<void> select(AppLocale locale) async {
    state = AsyncData(locale);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_storageKey, locale.tag);
  }
}

/// The active locale as a plain value, for callers that cannot await.
///
/// Falls back to [AppLocale.fallback] while preferences are still loading, and
/// on error. The `x-lang` interceptor uses this: a request must always carry a
/// language, and blocking every request on a disk read - to avoid one wrong
/// header during the first frames - is the worse trade.
@Riverpod(keepAlive: true)
AppLocale activeLocale(Ref ref) =>
    ref.watch(localeControllerProvider).value ?? AppLocale.fallback;
