import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/account/data/account_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_sync.g.dart';

/// The half of §3.2 that lives on the account: "the choice follows the user to
/// every signed-in device rather than staying on the install that changed it".
///
/// ## Why it is not on `LocaleController`
///
/// Pushing the choice needs a repository, and `core/l10n` importing a feature's
/// data layer is the wrong direction — the controller is read by the `x-lang`
/// interceptor and by `MaterialApp.locale`, which is as low as anything in this
/// app goes. So the controller keeps the local half, this keeps the server
/// half, and a screen calls [select] rather than either one directly.
///
/// ## Who wins at sign-in
///
/// A choice made on this device wins and travels to the account: it is the more
/// recent statement of intent, and §3.2 lets somebody pick a language *before*
/// registering — overwriting that with the account's value would undo the last
/// thing they did.
///
/// A device that has never been asked takes the account's value instead. The
/// alternative is pushing a guess made from the phone's system language over a
/// choice the user made deliberately somewhere else.
///
/// [LocaleController.hasLocalChoice] is what tells the two apart, and it can
/// only do so because the stored key is written by `select` alone.
///
/// ## A failed push costs the sync, never the choice
///
/// The local write happens first and is not rolled back. The language the user
/// just picked is on screen either way; what a failure costs is the other
/// device seeing it, which is worth a caught exception rather than a snackbar
/// about a request nobody asked to make.
class LocaleSync {
  const LocaleSync(this._ref);

  final Ref _ref;

  /// Applies a language choice, and pushes it when there is an account to push
  /// to.
  Future<void> select(AppLocale locale) async {
    await _ref.read(localeControllerProvider.notifier).select(locale);

    await _push(locale);
  }

  /// Reconciles the device and the account, once, at sign-in.
  Future<void> reconcile() async {
    final controller = _ref.read(localeControllerProvider.notifier);

    if (await controller.hasLocalChoice()) {
      await _push(_ref.read(activeLocaleProvider));

      return;
    }

    try {
      final adopted = AppLocale.fromTag(
        await _ref.read(accountRepositoryProvider).accountLocale(),
      );
      if (adopted != null) await controller.select(adopted);
    } on ApiException catch (e) {
      // The app is usable in whatever language it is already showing, so this
      // is not worth a screen. Logged rather than swallowed, because "my
      // language did not follow me" is otherwise unexplainable.
      debugPrint('Could not read the account language: ${e.message}');
    }
  }

  Future<void> _push(AppLocale locale) async {
    // Nothing to push to, and nothing wrong: §3.2's whole point is that the
    // language is selectable before an account exists.
    if (_ref.read(sessionControllerProvider) is! SessionActive) return;

    try {
      await _ref.read(accountRepositoryProvider).updateLocale(locale.tag);
    } on ApiException catch (e) {
      debugPrint('Could not store the account language: ${e.message}');
    }
  }
}

@riverpod
LocaleSync localeSync(Ref ref) => LocaleSync(ref);
