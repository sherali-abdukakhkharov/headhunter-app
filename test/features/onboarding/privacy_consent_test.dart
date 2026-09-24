/// §4.1 step 2: the policy the sign-in consent accepts is one tap away.
///
/// Reported from a phone on 2026-09-24: the checkbox read "I accept the Terms
/// of Service and the Privacy Policy" and neither was a link. One of the two
/// documents did not exist at all, so the sentence now names the policy alone
/// and the policy's words open it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/links/link_opener.dart';
import 'package:jobbridge_app/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLinkOpener implements LinkOpener {
  final opened = <Uri>[];
  bool noBrowser = false;

  @override
  Future<void> open(Uri url) async {
    opened.add(url);
    if (noBrowser) throw const NoBrowserException();
  }
}

void main() {
  Future<_FakeLinkOpener> pump(WidgetTester tester, AppLocale variant) async {
    // A returning install: the language is chosen, so the phone step shows.
    SharedPreferences.setMockInitialValues({'locale.tag': variant.tag});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final links = _FakeLinkOpener();
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [linkOpenerProvider.overrideWithValue(links)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: variant.locale,
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return links;
  }

  for (final variant in AppLocale.values) {
    final l10n = lookupAppL10n(variant.locale);

    group(variant.tag, () {
      test('the link words sit verbatim in the sentence', () {
        // How HhInlineLink places the link. A translation that drifts from it
        // draws the sentence without an underline — readable, but the policy
        // is then reachable only through a screen reader's actions menu.
        expect(l10n.authPrivacyAgree, contains(l10n.authPrivacyPolicyLink));
      });

      test('the sentence accepts no document that does not exist', () {
        // There is no terms-of-service text to open. Owner decision,
        // 2026-09-24: the consent names the privacy policy alone.
        for (final word in ['shartlar', 'шартлар', 'Условия', 'Terms']) {
          expect(l10n.authPrivacyAgree, isNot(contains(word)));
        }
      });

      testWidgets('tapping the policy opens it in this language, unticked', (
        tester,
      ) async {
        final links = await pump(tester, variant);

        await tester.tapOnText(
          find.textRange.ofSubstring(l10n.authPrivacyPolicyLink),
        );
        await tester.pump();

        expect(links.opened, [LegalLinks.privacyPolicy(variant)]);
        // Reading the policy is not accepting it: the box stays empty.
        final box = tester.widget<HhCheckboxRow>(find.byType(HhCheckboxRow));
        expect(box.value, isFalse);
      });
    });
  }

  testWidgets('a phone with no browser is told so, not left wondering', (
    tester,
  ) async {
    final links = await pump(tester, AppLocale.en);
    links.noBrowser = true;
    final en = lookupAppL10n(AppLocale.en.locale);

    await tester.tapOnText(
      find.textRange.ofSubstring(en.authPrivacyPolicyLink),
    );
    await tester.pump();

    expect(find.text(en.linkNoBrowser), findsOneWidget);
  });
}
