/// §2.1's category band, on the card a candidate actually scrolls past.
///
/// **The band existed in the design system and no screen drew it.**
/// `HhVacancyCard`, which composes it, was only ever used by the gallery; the
/// real feed built a plain card of text. So the fastest signal on a scanned
/// list — the one thing the design says a generic band would be worse than
/// omitting — was on no screen at all.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_card.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_feed_screen.dart';

VacancyCard _card({String? category}) => VacancyCard.fromJson({
  'id': 'vac-1',
  'title': 'Payvandchi kerak',
  'employer': const {'isVerified': false, 'name': 'Uzum Market'},
  'isSaved': false,
  'salaryIsNegotiable': true,
  'hasApplied': false,
  'category': category,
});

Future<void> pump(WidgetTester tester, VacancyCard card) async {
  tester.view.physicalSize = const Size(1080, 2400);
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
        home: Scaffold(
          body: VacancyFeedCard(card: card, feed: Feed.recommended),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a known category draws its band', (tester) async {
    await pump(tester, _card(category: 'seasonal_agricultural'));

    final band = tester.widget<HhCategoryBand>(find.byType(HhCategoryBand));

    expect(band.category, HhWorkCategory.seasonal);
    // The name in §2.1's words, so the band and the specification agree.
    expect(band.categoryLabel, 'Seasonal and agricultural work');
    expect(find.text('Seasonal and agricultural work'), findsOneWidget);
  });

  testWidgets('an unknown category draws no band at all', (tester) async {
    await pump(tester, _card(category: 'promotional_2027'));

    // A band is a claim about what kind of work this is. A wrong one is worse
    // than none, so a category this build does not know draws nothing.
    expect(find.byType(HhCategoryBand), findsNothing);
    expect(find.text('Payvandchi kerak'), findsOneWidget);
  });

  testWidgets('a vacancy with no category draws no band', (tester) async {
    await pump(tester, _card());

    expect(find.byType(HhCategoryBand), findsNothing);
  });

  testWidgets('the band reaches the card edges', (tester) async {
    await pump(tester, _card(category: 'professional'));

    final card = tester.getRect(find.byType(HhCard));
    final band = tester.getRect(find.byType(HhCategoryBand));

    // Full-bleed, so the card does the clipping and the padding sits inside
    // it. A band inset by the card's own padding would read as a panel rather
    // than as the card's header.
    expect(band.left, card.left);
    expect(band.right, card.right);
    expect(band.top, card.top);
  });

  testWidgets('the content is still padded under the band', (tester) async {
    await pump(tester, _card(category: 'professional'));

    final card = tester.getRect(find.byType(HhCard));
    final title = tester.getRect(find.text('Payvandchi kerak'));

    // Moving the padding inside is what makes the band full-bleed, and it is
    // also what would silently un-pad everything else if it were forgotten.
    expect(title.left, greaterThan(card.left));
  });
}
