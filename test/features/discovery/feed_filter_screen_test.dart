import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/features/discovery/domain/feed_filters.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/feed_filter_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// §5.5's filter screen, once it carried all nine filters (2026-08-26).
///
/// The three that landed last are the ones worth pinning here, and not because
/// the widgets are hard: for months this screen rendered a notice naming
/// experience, language and an upper pay bound as things it could not do. A
/// control that is present and does nothing is the failure that looks like an
/// answer, so what these assert is the whole round trip — typed on screen,
/// stored in [FeedFilters], sent by `toQuery`.
void main() {
  // Ids share no substring with their labels, so a test that passed because a
  // label leaked into the stored filter set cannot exist.
  const russian = 'a71f-0033';
  const english = '5c02-91be';

  DictionaryItem item(String id, String code, String label, {int order = 0}) =>
      DictionaryItem(
        id: id,
        code: code,
        label: label,
        sortOrder: order,
        isActive: true,
      );

  final languages = [
    item(russian, 'russian', 'Rus tili'),
    item(english, 'english', 'Ingliz tili', order: 1),
  ];

  /// Pumps the filter screen over empty preferences and a fake catalogue.
  ///
  /// What Apply writes is read back with [saved] rather than from a callback,
  /// which this screen does not have.
  Future<void> pump(
    WidgetTester tester, {
    FeedFilters stored = const FeedFilters(),
  }) async {
    // Seeded through storage rather than by overriding the controller: the
    // controller *is* the round trip this screen is part of, and standing in
    // for it would leave `set` — the half that decides what Apply writes —
    // untested.
    SharedPreferences.setMockInitialValues(
      stored.isEmpty
          ? {}
          : {'discovery.filters': jsonEncode(stored.toJson())},
    );

    // A phone-shaped surface: this screen is a scrolling column of 52px
    // controls, and the default 800x600 is not a shape this app ever runs at.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          dictionaryProvider('language').overrideWith((ref) => languages),
          for (final type in const [
            'occupation',
            'region',
            'employment_type',
            'work_format',
            'shift',
          ])
            dictionaryProvider(type).overrideWith((ref) => const []),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const FeedFilterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// What Apply wrote, read back the way the next cold start reads it.
  ///
  /// Storage rather than the controller's state, for two reasons. The screen
  /// pops itself on Apply, which disposes an autoDispose provider, so reading
  /// it afterwards observes a *fresh* one still loading. And persistence is the
  /// half that matters here: §5.5's filters survive between sessions, so "the
  /// notifier held it" is not the claim worth pinning.
  Future<FeedFilters> saved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('discovery.filters');

    return raw == null
        ? const FeedFilters()
        : FeedFilters.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Brings [finder] fully on screen.
  ///
  /// Nine controls at 52px with persistent labels is taller than the 360x800
  /// phone this pumps, and the form is a lazy `ListView` — so everything below
  /// the pay boxes is not merely off screen, it is not built. Both calls are
  /// needed: `scrollUntilVisible` stops as soon as the widget exists, which can
  /// leave it a few pixels past the edge where a tap silently misses.
  ///
  /// The scrollable is named because there is more than one on screen and the
  /// default finder insists on exactly one — it fails with "Bad state: Too many
  /// elements", which reads like a broken finder rather than an ambiguous one.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  /// The text field carrying [label].
  ///
  /// By label rather than by index: every control on this screen is an
  /// `HhTextField`, and `at(4)` would silently move to a different filter the
  /// day one is inserted above it.
  Finder box(String label) => find.byWidgetPredicate(
    (widget) => widget is HhTextField && widget.label == label,
  );

  Future<void> type(WidgetTester tester, String label, String text) async {
    final target = box(label);
    await reveal(tester, target);
    await tester.enterText(target, text);
    await tester.pump();
  }

  Future<void> apply(WidgetTester tester) async {
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
  }

  group('all nine of §5.5 have a control', () {
    testWidgets('the three that used to be missing are on screen', (
      tester,
    ) async {
      await pump(tester);

      // Named individually rather than counted: this screen used to carry a
      // notice listing exactly these three as unavailable, and the notice came
      // down in the same change that added them.
      for (final label in const [
        'Pay up to',
        'Experience required, up to (years)',
        'Language required',
      ]) {
        await reveal(tester, find.text(label));
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('each of the two ceilings says which way it reads', (
      tester,
    ) async {
      await pump(tester);

      // The pay note is the older one; the experience note is its counterpart,
      // and both exist because a filter whose results look wrong cannot be
      // told from a broken one.
      for (final note in const [
        'Vacancies with negotiable pay are still shown.',
        'Vacancies that ask for no experience are still shown.',
      ]) {
        await reveal(tester, find.text(note));
        expect(find.text(note), findsOneWidget);
      }
    });
  });

  group('what is typed is what is stored', () {
    testWidgets('a pay ceiling reaches the query', (tester) async {
      await pump(tester);

      await type(tester, 'Pay up to', '2000000');
      await apply(tester);

      expect((await saved()).salaryTo, 2000000);
      expect((await saved()).toQuery()['salaryTo'], 2000000);
    });

    testWidgets('both pay bounds travel together', (tester) async {
      await pump(tester);

      await type(tester, 'Pay from', '1000000');
      await type(tester, 'Pay up to', '2000000');
      await apply(tester);

      expect((await saved()).salaryFrom, 1000000);
      expect((await saved()).salaryTo, 2000000);
      // One narrowing decision about pay, whatever the badge is counting.
      expect((await saved()).count, 1);
    });

    testWidgets('an experience ceiling reaches the query', (tester) async {
      await pump(tester);

      await type(tester, 'Experience required, up to (years)', '3');
      await apply(tester);

      expect((await saved()).experienceYearsMax, 3);
    });

    testWidgets('a ceiling of zero is a request, not an empty box', (
      tester,
    ) async {
      await pump(tester);

      await type(tester, 'Experience required, up to (years)', '0');
      await apply(tester);

      // "Only vacancies that ask for no experience" is exactly what somebody
      // with none wants, and it is the one value a truthiness check loses.
      expect((await saved()).experienceYearsMax, 0);
      expect((await saved()).toQuery()['experienceYearsMax'], 0);
    });

    testWidgets('letters clear the filter rather than reading as zero', (
      tester,
    ) async {
      await pump(
        tester,
        stored: const FeedFilters(salaryFrom: 500000),
      );

      await type(tester, 'Pay from', 'ko‘p');
      await apply(tester);

      // A floor of 0 passes every vacancy, which is not what somebody who
      // typed a word meant — and neither is keeping the old figure.
      expect((await saved()).salaryFrom, isNull);
      expect((await saved()).toQuery().containsKey('salaryFrom'), isFalse);
    });

    testWidgets('emptying a box unsets its filter', (tester) async {
      await pump(
        tester,
        stored: const FeedFilters(salaryTo: 900000, experienceYearsMax: 5),
      );

      await type(tester, 'Pay up to', '');
      await type(tester, 'Experience required, up to (years)', '');
      await apply(tester);

      expect((await saved()).salaryTo, isNull);
      expect((await saved()).experienceYearsMax, isNull);
      expect((await saved()).isEmpty, isTrue);
    });
  });

  group('the language picker binds ids, not labels (BR-13)', () {
    testWidgets('choosing a language stores its id', (tester) async {
      await pump(tester);

      // Scoped to this picker: all five multi-selects render an Add, and a
      // bare `find.text('Add')` would resolve to the occupation one.
      final languages = find.byWidgetPredicate(
        (widget) =>
            widget is HhDictionaryMultiPicker && widget.type == 'language',
      );
      await reveal(tester, languages);

      await tester.tap(
        find.descendant(of: languages, matching: find.text('Add')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rus tili'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await apply(tester);

      expect((await saved()).languageIds, {russian});
      expect((await saved()).toQuery()['languageIds'], [russian]);
    });

    testWidgets('a stored id renders as its label', (tester) async {
      await pump(tester, stored: const FeedFilters(languageIds: {english}));

      await reveal(tester, find.text('Ingliz tili'));
      expect(find.text('Ingliz tili'), findsOneWidget);
    });
  });

  group('reset', () {
    testWidgets('empties the three boxes as well as the pickers', (
      tester,
    ) async {
      await pump(
        tester,
        stored: const FeedFilters(
          salaryFrom: 100,
          salaryTo: 900,
          experienceYearsMax: 4,
          languageIds: {russian},
        ),
      );

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      await apply(tester);

      // The controllers hold text of their own, so clearing the draft alone
      // would leave the numbers on screen and put them straight back on Apply.
      expect((await saved()).isEmpty, isTrue);
      expect((await saved()).toQuery(), isEmpty);
    });
  });
}
