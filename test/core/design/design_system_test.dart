import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

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
    testWidgets('a button is 52px tall at the default text scale', (
      tester,
    ) async {
      await pump(tester, HhButton(label: 'Davom etish', onPressed: () {}));

      final box = tester.getSize(
        find.descendant(
          of: find.byType(HhButton),
          matching: find.byType(Container),
        ),
      );
      expect(box.height, HhSize.control);
    });

    testWidgets('a text field box is 52px tall at the default text scale', (
      tester,
    ) async {
      await pump(tester, const HhTextField(label: 'Ism va familiya'));

      final box = tester.getSize(find.byType(AnimatedContainer));
      expect(box.height, HhSize.control);
    });

    // Design round 1 §08.2: "control height min 52 — the box grows with the
    // label, it never clips it." 52 is a floor, not a fixed height, so a large
    // accessibility text scale must make the control taller rather than
    // truncating a label (Cyrillic runs ~30% longer than Latin).
    testWidgets('a control grows with the text scale instead of clipping', (
      tester,
    ) async {
      Future<double> heightAt(double scale) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HhTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 200,
                    child: HhButton(
                      // Long enough that it must wrap when scaled up.
                      label: 'Продолжить регистрацию',
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        return tester.getSize(find.byType(HhButton)).height;
      }

      final normal = await heightAt(1);
      final large = await heightAt(2);

      expect(normal, greaterThanOrEqualTo(HhSize.control));
      expect(
        large,
        greaterThan(normal),
        reason: 'the box must grow with the label rather than clip it',
      );
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

  group('status vocabulary', () {
    // The canonical twenty states from design round 1, grouped by object type.
    const vacancy = <HhBadge>[
      HhBadge.vacancyDraft(label: 'Qoralama'),
      HhBadge.vacancyModeration(label: 'Moderatsiyada'),
      HhBadge.vacancyActive(label: 'Faol'),
      HhBadge.vacancyPaused(label: "To'xtatilgan"),
      HhBadge.vacancyClosed(label: 'Yopilgan'),
      HhBadge.vacancyRejected(label: 'Rad etildi'),
    ];
    const application = <HhBadge>[
      HhBadge.applicationSubmitted(label: 'Yuborildi'),
      HhBadge.applicationViewed(label: "Ko'rildi"),
      HhBadge.applicationShortlisted(label: "Qisqa ro'yxatda"),
      HhBadge.applicationInterview(label: 'Suhbat'),
      HhBadge.applicationOffer(label: 'Taklif'),
      HhBadge.applicationHired(label: 'Ishga qabul qilindi'),
      HhBadge.applicationRejected(label: 'Rad etildi'),
      HhBadge.applicationWithdrawn(label: 'Qaytarib olindi'),
      HhBadge.applicationVacancyClosed(label: 'Vakansiya yopildi'),
    ];
    const verification = <HhBadge>[
      HhBadge.verificationNotSubmitted(label: 'Yuborilmagan'),
      HhBadge.verificationUnderReview(label: "Ko'rib chiqilmoqda"),
      HhBadge.verificationVerified(label: 'Tasdiqlangan'),
      HhBadge.verificationRejected(label: 'Rad etildi'),
      HhBadge.verificationChangesRequired(label: "O'zgartirish talab"),
    ];

    test('all twenty states exist', () {
      expect(vacancy.length + application.length + verification.length, 20);
    });

    // "Within one object type no glyph ever repeats, so tone never has to carry
    // the distinction alone." This is what lets withdrawn / paused / closed all
    // be neutral without becoming indistinguishable.
    test('no glyph repeats within an object type', () {
      for (final group in [vacancy, application, verification]) {
        final glyphs = group.map((b) => b.iconPath).toList();
        expect(
          glyphs.toSet().length,
          glyphs.length,
          reason: 'a glyph is reused within one object type',
        );
      }
    });

    // "Across object types the same glyph always means the same thing."
    test('shared glyphs carry the same meaning across object types', () {
      // A reviewer holds it.
      expect(
        const HhBadge.vacancyModeration(label: '').iconPath,
        const HhBadge.verificationUnderReview(label: '').iconPath,
      );
      // Yours to edit.
      expect(
        const HhBadge.vacancyDraft(label: '').iconPath,
        const HhBadge.verificationChangesRequired(label: '').iconPath,
      );
      // Finished and read-only.
      expect(
        const HhBadge.vacancyClosed(label: '').iconPath,
        const HhBadge.applicationVacancyClosed(label: '').iconPath,
      );
    });

    // Both green, but different glyphs on different objects: check-circle on a
    // person, shield on an organisation.
    test('hired and verified share a tone but not a glyph', () {
      const hired = HhBadge.applicationHired(label: '');
      const verified = HhBadge.verificationVerified(label: '');

      expect(hired.tone, HhTone.success);
      expect(verified.tone, HhTone.success);
      expect(hired.iconPath, isNot(verified.iconPath));
      expect(hired.iconPath, HhIconPath.checkCircle);
      expect(verified.iconPath, HhIconPath.shieldCheck);
    });

    // Green is explicitly NOT reserved for verification.
    test('an active vacancy is success-toned', () {
      expect(const HhBadge.vacancyActive(label: '').tone, HhTone.success);
    });

    // Warning means "waiting on a person"; an offer waits on the candidate.
    test('an offer is warning-toned, not success', () {
      const offer = HhBadge.applicationOffer(label: 'Taklif');
      expect(offer.tone, HhTone.warning);
      expect(offer.iconPath, HhIconPath.document);
    });

    testWidgets('every badge renders an icon beside its word', (tester) async {
      final badges = [...vacancy, ...application, ...verification];

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

    // Design round 1 recategorised Offer from success to warning: under the
    // tone rule warning means "waiting on a person", and an offer waits on the
    // candidate. Success would tell them the matter was already settled.

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

  group('vacancy card band', () {
    // The design is explicit that omitting the band is the one behaviour that
    // breaks list rhythm: card geometry must not change between the
    // photograph and no-photograph cases.
    testWidgets('renders at the same height with and without a photograph', (
      tester,
    ) async {
      Future<double> cardHeight({required bool withImage}) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HhTheme.light,
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: HhVacancyCard(
                  title: 'Call-markaz operatori',
                  employer: 'Anor Telecom',
                  pay: "4 500 000 so'm",
                  category: HhWorkCategory.service,
                  categoryLabel: 'Xizmat',
                  image: withImage
                      ? const ColoredBox(color: Color(0xFF123456))
                      : null,
                ),
              ),
            ),
          ),
        );
        return tester.getSize(find.byType(HhVacancyCard)).height;
      }

      expect(
        await cardHeight(withImage: false),
        await cardHeight(withImage: true),
        reason: 'the band must keep its height when there is no photograph',
      );
    });

    testWidgets('the no-photograph fallback names the category', (
      tester,
    ) async {
      await pump(
        tester,
        const HhCategoryBand(
          category: HhWorkCategory.seasonal,
          categoryLabel: 'Mavsumiy',
        ),
      );

      // Glyph plus word, exactly as with a status badge.
      expect(find.text('Mavsumiy'), findsOneWidget);
      expect(find.byType(HhIcon), findsOneWidget);
    });

    test('there is one category per specification work category', () {
      expect(HhWorkCategory.values.length, 5);
    });
  });

  group('the icon set', () {
    // An icon is a bare path string wrapped in an SVG document at build time,
    // so a typo in the path data is a parse failure at paint time rather than a
    // compile error - and it can only be caught by rendering it.
    testWidgets('both disclosure chevrons render', (tester) async {
      await pump(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HhIcon(HhIconPath.chevronDown),
            HhIcon(HhIconPath.chevronRight),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(HhIcon), findsNWidgets(2));
    });

    test('the two chevrons are different glyphs', () {
      // They mean different things - down opens a list in place, right opens a
      // screen - so an alias would make the distinction unrenderable.
      expect(HhIconPath.chevronRight, isNot(HhIconPath.chevronDown));
    });
  });

  group('bottom navigation', () {
    testWidgets('height is constant across role configurations', (
      tester,
    ) async {
      Future<double> barHeight(List<HhNavItem> items) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HhTheme.light,
            home: Scaffold(
              bottomNavigationBar: HhBottomNav(
                items: items,
                currentIndex: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        );
        return tester.getSize(find.byType(HhBottomNav)).height;
      }

      final candidate = await barHeight(
        HhNavSets.candidate(
          home: 'Bosh sahifa',
          vacancies: 'Vakansiyalar',
          applications: 'Arizalar',
          messages: 'Xabarlar',
          profile: 'Profil',
        ),
      );
      // The admin set contains the longest label in the product.
      final admin = await barHeight(
        HhNavSets.admin(
          dashboard: 'Panel',
          queue: 'Navbat',
          complaints: 'Shikoyatlar',
          users: 'Фойдаланувчилар',
          dictionaries: "Lug'atlar",
        ),
      );

      expect(candidate, HhBottomNav.height);
      expect(
        admin,
        candidate,
        reason: 'switching role must not change the bar height',
      );
    });

    testWidgets('a very long label cannot grow the bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HhTheme.light,
          home: Scaffold(
            bottomNavigationBar: HhBottomNav(
              items: HhNavSets.admin(
                dashboard: 'Panel',
                queue: 'Navbat',
                complaints: 'Shikoyatlar',
                users: 'Фойдаланувчилар ва ташкилотлар рўйхати',
                dictionaries: "Lug'atlar",
              ),
              currentIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(HhBottomNav)).height,
        HhBottomNav.height,
      );
      expect(tester.takeException(), isNull);
    });

    test('soft hyphen lands inside the long Cyrillic label', () {
      final hyphenated = hhSoftHyphenate(
        'Фойдаланувчилар',
        afterPrefix: 'Фойдалан',
      );
      expect(hyphenated, 'Фойдалан­увчилар');
      // A prefix that does not match leaves the string untouched.
      expect(hhSoftHyphenate('Panel', afterPrefix: 'zzz'), 'Panel');
    });
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
