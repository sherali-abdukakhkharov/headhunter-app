/// §4.1's two decisions, in two steps rather than one long form.
///
/// Language and authentication are separate choices and the specification
/// sequences them, but onboarding presented both at once: a logo, four
/// full-width radio rows, and only then the field the user came for. At the
/// design's own QA case — 320pt, 200% text — the first viewport held the logo,
/// the languages and the "Sign in" heading, and the phone field was entirely
/// off screen (1.29.0 audit, P1).
///
/// The property that makes the split worth having is **that it is first-run
/// only**. An extra page in front of every sign-in is permanent friction bought
/// for a decision most people make once, so a returning signed-out user must
/// land on the field with the language still one control away.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final en = lookupAppL10n(const Locale('en'));

  Future<void> pump(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    Size size = const Size(1080, 2400),
    double scale = 1,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);

    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('an install that has never chosen a language', () {
    testWidgets('is asked, before it is asked for a phone number', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text(en.settingsLanguage), findsOneWidget);
      for (final option in AppLocale.values) {
        expect(find.text(option.nativeName), findsOneWidget);
      }
      // The whole point of the split: one decision per screen.
      expect(find.text(en.authPhoneLabel), findsNothing);
    });

    testWidgets('and Continue takes it to the phone field', (tester) async {
      await pump(tester);

      await tester.tap(find.text(en.commonNext));
      await tester.pumpAndSettle();

      expect(find.text(en.authPhoneLabel), findsOneWidget);
      expect(find.text(en.authSignInTitle), findsOneWidget);
    });

    testWidgets('Continue stores the preselection, so it is asked once', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text(en.commonNext));
      await tester.pumpAndSettle();

      // Nobody touched a row. Accepting a default you were shown four
      // alternatives to is a choice — and if it stored nothing, this page
      // would come back at the next launch, which is the friction the split
      // was meant to remove.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale.tag'), isNotNull);
    });

    testWidgets('choosing a language applies it immediately', (tester) async {
      await pump(tester);

      await tester.tap(find.text(AppLocale.ru.nativeName));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale.tag'), AppLocale.ru.tag);
    });
  });

  group('an install that has', () {
    testWidgets('lands on the phone field directly', (tester) async {
      await pump(tester, prefs: {'locale.tag': 'en'});

      expect(find.text(en.authPhoneLabel), findsOneWidget);
      // No second language page in front of a returning signed-out user.
      expect(find.text(en.settingsLanguage), findsNothing);
    });

    testWidgets('and keeps the language one control away', (tester) async {
      await pump(tester, prefs: {'locale.tag': 'ru'});

      // Named in its own language, so it is legible to the person most likely
      // to want it — somebody who cannot read the rest of the screen.
      expect(find.text(AppLocale.ru.nativeName), findsOneWidget);

      await tester.tap(find.text(AppLocale.ru.nativeName));
      await tester.pumpAndSettle();

      for (final option in AppLocale.values) {
        expect(find.text(option.nativeName), findsWidgets);
      }
    });

    testWidgets('and changing it there sticks', (tester) async {
      await pump(tester, prefs: {'locale.tag': 'ru'});

      await tester.tap(find.text(AppLocale.ru.nativeName));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocale.uzCyrl.nativeName).last);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale.tag'), AppLocale.uzCyrl.tag);
    });
  });

  testWidgets('the phone field is on the first viewport at 320pt, 2.0x', (
    tester,
  ) async {
    // The audit's own measurement, and the reason for the split. With the
    // language rows above it the field was not merely low — it was off screen
    // entirely, on a page whose scrollability is the only thing that saved it.
    await pump(
      tester,
      prefs: {'locale.tag': 'en'},
      // 960 physical at dpr 3 is 320 logical; 1704 is 568.
      size: const Size(960, 1704),
      scale: 2,
    );

    expect(tester.takeException(), isNull);

    final field = tester.getRect(find.byType(HhTextField).first);
    expect(
      field.top,
      lessThan(568),
      reason: 'the thing the screen is for must be on the screen',
    );
  });
}
