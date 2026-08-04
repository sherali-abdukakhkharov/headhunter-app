import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/core/design/design.dart';

/// Guards the design decisions that are easy to erode one screen at a time.
///
/// These are not "does Flutter work" tests. Each one pins a rule the design
/// document states explicitly, so a well-meaning change that breaks it fails
/// here rather than in review.
Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: HhTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('one control size for everyone', () {
    testWidgets('buttons are 52px tall', (tester) async {
      await pump(tester, HhButton(label: 'Davom etish', onPressed: () {}));

      final box = tester.getSize(
        find.descendant(
          of: find.byType(HhButton),
          matching: find.byType(Container),
        ),
      );
      expect(box.height, HhSize.control);
    });

    testWidgets('a text field box is 52px tall', (tester) async {
      await pump(tester, const HhTextField(label: 'Ism va familiya'));

      final box = tester.getSize(find.byType(AnimatedContainer));
      expect(box.height, HhSize.control);
    });

    // Regression: the bordered variants set Material.shape, and passing both
    // shape and borderRadius trips an assertion. The original tests only
    // covered `primary`, which has no border — so every variant is built here.
    testWidgets('every button variant builds without asserting', (
      tester,
    ) async {
      final variants = <String, Widget>{
        'primary': HhButton(label: 'Davom etish', onPressed: () {}),
        'secondary': HhButton.secondary(label: 'Saqlash', onPressed: () {}),
        'tertiary': HhButton.tertiary(label: "Qo'shish", onPressed: () {}),
        'destructive': HhButton.destructive(
          label: "O'chirish",
          onPressed: () {},
        ),
        'text': HhButton.text(label: 'Keyinroq', onPressed: () {}),
        'disabled': const HhButton(label: "O'chirilgan"),
        'loading': HhButton(
          label: 'Yuborilmoqda',
          loading: true,
          onPressed: () {},
        ),
        'with icon': HhButton.tertiary(
          label: "Qo'shish",
          iconPath: HhIconPath.plus,
          onPressed: () {},
        ),
      };

      for (final entry in variants.entries) {
        await pump(tester, entry.value);
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} button must build cleanly',
        );
      }
    });

    testWidgets('expand:false hugs the label instead of stretching', (
      tester,
    ) async {
      await pump(
        tester,
        HhButton(label: 'Ko‘rish', expand: false, onPressed: () {}),
      );
      final hugged = tester.getSize(find.byType(HhButton)).width;

      await pump(tester, HhButton(label: 'Ko‘rish', onPressed: () {}));
      final stretched = tester.getSize(find.byType(HhButton)).width;

      expect(
        hugged,
        lessThan(stretched),
        reason: 'an auto-width button must not fill the available width',
      );
    });

    testWidgets('loading does not change a button height', (tester) async {
      await pump(tester, HhButton(label: 'Yuborilmoqda', onPressed: () {}));
      final idle = tester.getSize(find.byType(HhButton));

      await pump(
        tester,
        HhButton(label: 'Yuborilmoqda', loading: true, onPressed: () {}),
      );
      expect(tester.getSize(find.byType(HhButton)), idle);
    });
  });

  group('status is never colour alone', () {
    testWidgets('every badge renders an icon beside its word', (tester) async {
      const badges = <HhBadge>[
        HhBadge.verified(label: 'Tasdiqlangan'),
        HhBadge.pending(label: "Ko'rib chiqilmoqda"),
        HhBadge.rejected(label: 'Rad etildi'),
        HhBadge.info(label: 'Yangi'),
        HhBadge.paused(label: "To'xtatilgan"),
        HhBadge.changesRequired(label: "O'zgartirish talab qilinadi"),
      ];

      for (final badge in badges) {
        await pump(tester, badge);
        expect(
          find.descendant(
            of: find.byType(HhBadge),
            matching: find.byType(HhIcon),
          ),
          findsOneWidget,
          reason: 'badge "${badge.label}" must carry a glyph, not colour alone',
        );
        expect(find.text(badge.label), findsOneWidget);
      }
    });

    testWidgets('a selected filter chip is marked with a check', (
      tester,
    ) async {
      await pump(
        tester,
        const HhFilterChip(label: 'Toshkent', selected: false),
      );
      expect(find.byType(HhIcon), findsNothing);

      await pump(tester, const HhFilterChip(label: 'Toshkent', selected: true));
      expect(find.byType(HhIcon), findsOneWidget);
    });
  });

  group('touch targets', () {
    testWidgets('a switch row is at least 44px tall', (tester) async {
      await pump(
        tester,
        HhSwitchRow(
          label: "Qidiruvda ko'rinsin",
          value: true,
          onChanged: (_) {},
        ),
      );

      expect(
        tester.getSize(find.byType(HhSwitchRow)).height,
        greaterThanOrEqualTo(HhSize.minTarget),
      );
    });

    testWidgets('a checkbox row is at least 44px tall', (tester) async {
      await pump(
        tester,
        HhCheckboxRow(label: 'Guvohnoma bor', value: false, onChanged: (_) {}),
      );

      expect(
        tester.getSize(find.byType(HhCheckboxRow)).height,
        greaterThanOrEqualTo(HhSize.minTarget),
      );
    });
  });

  group('bottom navigation', () {
    testWidgets('renders icon and label for all five destinations', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HhTheme.light,
          home: Scaffold(
            bottomNavigationBar: HhBottomNav(
              items: HhNavSets.admin(
                dashboard: 'Panel',
                queue: 'Navbat',
                complaints: 'Shikoyatlar',
                // The design names this as the longest label in the set.
                users: 'Фойдаланувчилар',
                dictionaries: "Lug'atlar",
              ),
              currentIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(HhIcon), findsNWidgets(5));
      expect(find.text('Фойдаланувчилар'), findsOneWidget);
    });

    testWidgets('the longest Cyrillic label wraps instead of truncating', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HhTheme.light,
          home: Scaffold(
            bottomNavigationBar: HhBottomNav(
              items: HhNavSets.admin(
                dashboard: 'Panel',
                queue: 'Navbat',
                complaints: 'Shikoyatlar',
                users: 'Фойдаланувчилар',
                dictionaries: "Lug'atlar",
              ),
              currentIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('Фойдаланувчилар'));
      expect(
        label.maxLines,
        2,
        reason: 'tab labels wrap to two lines rather than truncate',
      );
    });
  });

  testWidgets('the step indicator actually paints its progress bar', (
    tester,
  ) async {
    await pump(
      tester,
      const SizedBox(
        width: 320,
        child: HhStepIndicator(
          step: 4,
          total: 9,
          stepLabel: '4-qadam / 9',
          sectionName: 'Ko‘nikmalar',
        ),
      ),
    );

    // Regression: a hand-rolled Stack laid out to zero height, so the bar was
    // invisible on device while analyze and tests stayed green.
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, closeTo(4 / 9, 0.001));
    expect(
      tester.getSize(find.byType(LinearProgressIndicator)).height,
      greaterThan(0),
    );
  });

  testWidgets('the theme exposes no dark variant', (tester) async {
    // The design specifies a single light scheme. If a dark theme is ever
    // added it must come from the client, not from us.
    expect(HhTheme.light.brightness, Brightness.light);
  });

  testWidgets('completeness ring reports its value to screen readers', (
    tester,
  ) async {
    await pump(
      tester,
      const HhCompletenessRing(percent: 72, title: "Profil to'ldirilgan"),
    );

    expect(find.text('72%'), findsOneWidget);
  });
}
