// The app as the App Store screenshots see it: lib/main.dart, plus the Flutter
// Driver extension and a few commands that put it into a state.
//
// Run by .github/workflows/ios-screenshots.yml through
// `flutter drive --target=test_driver/app.dart`. It is never part of a store
// build: nothing under lib/ imports it, and `flutter build` takes lib/main.dart.
//
// ## Commands rather than taps for sign-in and language
//
// The fields and buttons a script would type into are labelled in four
// languages, and the sign-in screen would put a keyboard and a consent line in
// front of the camera for nothing. Each command below calls exactly what the
// screen it replaces calls. The screens being photographed are reached the way
// a person reaches them; only the way in is shortened.
import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/src/app.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/core/logging/crash_handlers.dart';
import 'package:jobbridge_app/src/core/router/app_router.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_messaging.dart';

/// `LocaleController`'s preferences key. Removed before every sign-in — see
/// [_signIn] for why.
const _localeKey = 'locale.tag';

/// `NotificationPrimer`'s key. Set up front so the explanation sheet, which
/// opens once per install, never covers a shot.
const _primerKey = 'notifications.primer_seen';

Future<void> main() async {
  // As in lib/main.dart, so a failure the store would see is a failure here.
  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      // A simulator in CI is not a device anyone should push to, and
      // registering it would add a row to a demo account's devices. Disabled
      // push is a supported configuration, not a stub: §9.2 has to work
      // without it.
      pushMessagingProvider.overrideWithValue(const DisabledPushMessaging()),
    ],
  );

  // Before anything touches the binding: the extension installs its own.
  enableFlutterDriverExtension(
    handler: (message) => _handle(container, message ?? ''),
  );
  installCrashHandlers();

  final prefs = await container.read(sharedPreferencesProvider.future);
  await prefs.setBool(_primerKey, true);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const JobBridgeApp(),
    ),
  );
}

/// One command per message: a verb and its space-separated arguments.
Future<String> _handle(ProviderContainer container, String message) async {
  final words = message.split(' ');
  final arguments = words.skip(1).toList();

  switch (words.first) {
    case 'signIn':
      return _signIn(container, phone: arguments[0], code: arguments[1]);

    case 'signOut':
      await container.read(sessionControllerProvider.notifier).signOut();
      return 'ok';

    // Local only, as the language picker's first half is. The account keeps
    // its own language: `LocaleSync` pushes a choice to the server only at
    // sign-in and from the account screen, and neither runs here.
    case 'locale':
      final locale = AppLocale.fromTag(arguments.single);
      if (locale == null) throw ArgumentError.value(message, 'locale');
      await container.read(localeControllerProvider.notifier).select(locale);
      return locale.tag;

    case 'go':
      container.read(appRouterProvider).go(arguments.single);
      return 'ok';

    case 'location':
      return container
          .read(appRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .toString();
  }

  throw ArgumentError.value(message, 'message', 'Unknown command');
}

/// Signs in with a seeded account's fixed code (headhunter-backend
/// docs/TEST_ACCOUNTS.md: no SMS is sent for these numbers) and returns the
/// language the account was adopted in.
///
/// **The stored language is removed first.** Signing in runs
/// `LocaleSync.reconcile`, which pushes this device's choice to the account
/// when there is one — so after the first account had been photographed in
/// three languages, the second would have been switched to the last of them
/// on the server. With no local choice, reconcile adopts the account's own
/// language instead, and the demo accounts end the run as they began it.
Future<String> _signIn(
  ProviderContainer container, {
  required String phone,
  required String code,
}) async {
  final prefs = await container.read(sharedPreferencesProvider.future);
  await prefs.remove(_localeKey);
  container.invalidate(localeControllerProvider);

  final wire = UzPhone.parse(phone).wire;
  await container.read(authRepositoryProvider).sendOtp(wire);
  await container
      .read(sessionControllerProvider.notifier)
      .signInWithOtp(phone: wire, code: code);

  // Reconcile runs unawaited from the app's session listener, and it ends by
  // storing the adopted language. A `locale` command sent before that would be
  // overwritten by it, so this answers only once it has landed.
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (prefs.getString(_localeKey) == null &&
      DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  return prefs.getString(_localeKey) ?? 'not adopted';
}
