/// §9.2's permission, asked by the app before it is asked by Android.
///
/// Registration used to open with `requestPermission()`, so the system dialog
/// appeared the instant a code was verified — sometimes before a new user had
/// chosen a role. **Android asks once.** A refusal given to a question nobody
/// explained, worded by the OS in whatever language the *phone* is set to
/// rather than the one just chosen in the app, is a permanent refusal that only
/// a trip to system settings can undo (1.29.0 audit, P1).
///
/// So the sheet comes first, and the platform is asked only if somebody says
/// yes. What is worth pinning is the shape of that: **asked once per install,
/// whatever the answer**, and a decline that costs the banner and nothing else.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_messaging.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notification_primer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMessaging implements PushMessaging {
  bool permitted = true;
  int permissionRequests = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;

    return permitted;
  }

  @override
  Never noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'This suite asks about permission only; ${invocation.memberName} is not '
    'part of that.',
  );
}

void main() {
  final en = lookupAppL10n(const Locale('en'));

  late _FakeMessaging messaging;

  setUp(() {
    messaging = _FakeMessaging();
    SharedPreferences.setMockInitialValues({});
  });

  /// A screen that offers the primer the way `RoleShell` does.
  Future<bool?> pump(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);

    bool? answer;

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [pushMessagingProvider.overrideWithValue(messaging)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    final seen = await ref.read(
                      notificationPrimerProvider.future,
                    );
                    if (seen || !context.mounted) return;

                    answer = await showNotificationPrimer(context, ref);
                  },
                  child: const Text('offer'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('offer'));
    await tester.pumpAndSettle();

    return answer;
  }

  testWidgets('it explains before the platform is asked', (tester) async {
    await pump(tester);

    expect(find.text(en.notificationsPrimerTitle), findsOneWidget);
    // The whole point of the sheet: nothing has been asked of the OS yet.
    expect(messaging.permissionRequests, 0);
  });

  testWidgets('it names the events rather than promising "updates"', (
    tester,
  ) async {
    await pump(tester);

    // §9.2's own events. "Stay up to date" is what an app says when it cannot
    // say what it would send.
    expect(find.text(en.notificationsPrimerBody), findsOneWidget);
  });

  testWidgets('Turn on asks the platform', (tester) async {
    await pump(tester);

    await tester.tap(find.text(en.notificationsPrimerEnable));
    await tester.pumpAndSettle();

    expect(messaging.permissionRequests, 1);
  });

  testWidgets('Not now asks nothing at all', (tester) async {
    await pump(tester);

    await tester.tap(find.text(en.notificationsPrimerLater));
    await tester.pumpAndSettle();

    // Declining here must not spend the one question Android allows. That is
    // the difference between "not now" and "never".
    expect(messaging.permissionRequests, 0);
  });

  testWidgets('a refusal from the platform is an answer, not a failure', (
    tester,
  ) async {
    messaging.permitted = false;

    await pump(tester);
    await tester.tap(find.text(en.notificationsPrimerEnable));
    await tester.pumpAndSettle();

    expect(messaging.permissionRequests, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('it is not offered twice, whatever the answer was', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text(en.notificationsPrimerLater));
    await tester.pumpAndSettle();

    // "Later" meant later. A sheet that returns at every launch is the same
    // interruption this exists to remove.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notifications.primer_seen'), isTrue);
  });

  testWidgets('and an install that has been asked sees nothing', (
    tester,
  ) async {
    await pump(tester, prefs: {'notifications.primer_seen': true});

    expect(find.text(en.notificationsPrimerTitle), findsNothing);
    expect(messaging.permissionRequests, 0);
  });
}
