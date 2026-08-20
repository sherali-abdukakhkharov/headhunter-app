import 'dart:ui' show PlatformDispatcher;

import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

/// The active interface language.
///
/// Ownership follows §3.2: the language is selectable **before** registration,
/// so local storage is the source of truth pre-auth. After sign-in the server
/// value wins on a fresh install, and a local change is pushed to the server.
/// Only the local half exists today - [select] is where the server push lands
/// when the profile endpoint arrives in M1, and the seam is marked below rather
/// than left to be rediscovered.
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

  /// Applies and persists a language choice.
  ///
  /// Writes optimistically so the UI switches immediately; a failed write costs
  /// the preference on next launch, not the current session.
  Future<void> select(AppLocale locale) async {
    state = AsyncData(locale);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_storageKey, locale.tag);

    // M1 seam: once the profile endpoint exists, push the choice to the server
    // here so it restores on the user's other signed-in devices (§3.2).
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
