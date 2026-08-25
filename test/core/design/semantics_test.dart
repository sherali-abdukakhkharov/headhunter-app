/// MT-015: what a screen reader is told about the shared components.
///
/// Two defects, and both were invisible to every existing test because they are
/// invisible on screen:
///
/// - **`Semantics(label: X, child: … Text(X) …)` announces X twice.** The
///   node's own name and the child's merge into `"X\nX"`, so TalkBack said
///   *"Home, Home"*, *"Save, Save"*, *"Verified employer, Verified employer"*.
///   Three of the design system's most-used components did it.
/// - **An icon-only button with no name is announced as nothing at all.**
///   Android's hierarchy dump marks it `NAF=true`. Every picker chevron in the
///   product was in that state, which is the one control on a picker a
///   screen-reader user has to find.
///
/// Semantics are fully testable headlessly, so these need no device — which is
/// the point of writing them here rather than filing them for a QA pass.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HhTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('one control, one name', () {
    testWidgets('a button is announced once and is still tappable', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, HhButton(label: 'Save', onPressed: () {}));

      expect(
        tester.getSemantics(find.byType(HhButton)),
        isSemantics(label: 'Save', isButton: true, hasTapAction: true),
      );

      handle.dispose();
    });

    testWidgets('a disabled button says so rather than going silent', (
      tester,
    ) async {
      // Excluding the subtree drops the child's state as well as its name, so
      // the node has to carry it. A button announced without "disabled" is one
      // a screen-reader user taps and then wonders about.
      final handle = tester.ensureSemantics();
      // No onPressed at all, which is what a disabled button is.
      await pump(tester, const HhButton(label: 'Save'));

      expect(
        tester.getSemantics(find.byType(HhButton)),
        isSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );

      handle.dispose();
    });

    testWidgets('a badge is announced once', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const HhBadge.verificationVerified(label: 'Verified employer'),
      );

      expect(
        tester.getSemantics(find.byType(HhBadge)),
        isSemantics(label: 'Verified employer'),
      );

      handle.dispose();
    });

    testWidgets('a nav destination is announced once, with its position', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: HhTheme.light,
          home: Scaffold(
            bottomNavigationBar: HhBottomNav(
              items: const [
                HhNavItem(iconPath: HhIconPath.home, label: 'Home'),
                HhNavItem(iconPath: HhIconPath.briefcase, label: 'Vacancies'),
                HhNavItem(iconPath: HhIconPath.people, label: 'Candidates'),
              ],
              currentIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Home')),
        isSemantics(
          label: 'Home',
          // "Tab 1 of 3", from `MaterialLocalizations`. A destination
          // announced without its position leaves somebody unable to tell how
          // far along the bar they are.
          value: 'Tab 1 of 3',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );

      expect(
        tester.getSemantics(find.text('Vacancies')),
        isSemantics(
          label: 'Vacancies',
          value: 'Tab 2 of 3',
          isSelected: false,
        ),
      );

      handle.dispose();
    });

    testWidgets('no shared component announces its own name twice', (
      tester,
    ) async {
      // The shape of the bug rather than the three instances of it: a label
      // that contains its own text twice, joined by the newline Flutter uses
      // when it merges a node with its children.
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Column(
          children: [
            HhButton(label: 'Save', onPressed: () {}),
            HhButton.secondary(label: 'Search', onPressed: () {}),
            HhButton.text(label: 'Skip', onPressed: () {}),
            const HhBadge.verificationVerified(label: 'Verified employer'),
            const HhMetaChip(label: 'Tashkent'),
          ],
        ),
      );

      for (final name in [
        'Save',
        'Search',
        'Skip',
        'Verified employer',
        'Tashkent',
      ]) {
        expect(
          find.bySemanticsLabel('$name\n$name'),
          findsNothing,
          reason: '"$name" is announced twice',
        );
        expect(find.bySemanticsLabel(name), findsOneWidget);
      }

      handle.dispose();
    });
  });

  group('every interactive element is named', () {
    testWidgets("a picker's chevron says what it opens", (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        HhTextField(
          label: 'Industry',
          readOnly: true,
          trailingIconPath: HhIconPath.chevronDown,
          onTrailingTap: () {},
          trailingSemanticLabel: 'Choose Industry',
        ),
      );

      // Named after the field, not "Choose": a profile form carries six
      // pickers, and six controls all called "Choose" are six controls nobody
      // can tell apart.
      expect(find.bySemanticsLabel('Choose Industry'), findsOneWidget);

      handle.dispose();
    });

    test('a tappable trailing icon without a name is a build error', () {
      // The structural half of the fix. Naming the six existing chevrons
      // fixes today; the assert is what stops the seventh.
      expect(
        () => HhTextField(
          label: 'Industry',
          trailingIconPath: HhIconPath.chevronDown,
          onTrailingTap: () {},
        ),
        throwsAssertionError,
      );
    });

    test('an untappable trailing icon needs no name', () {
      // Decoration, not a control — a unit chip or a status glyph. Requiring a
      // name there would push callers into inventing ones, and a screen reader
      // reading out decoration is its own kind of noise.
      expect(
        () => const HhTextField(
          label: 'Salary',
          trailingIconPath: HhIconPath.calendar,
        ),
        returnsNormally,
      );
    });
  });
}
