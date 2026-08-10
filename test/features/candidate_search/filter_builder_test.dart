import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/candidate_search/domain/search_filters.dart';
import 'package:headhunter_app/src/features/candidate_search/presentation/applied_filter_chips.dart';
import 'package:headhunter_app/src/features/candidate_search/presentation/level_floor_field.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';

/// The filter builder's two load-bearing rules, and the chips above it.
///
/// The whole builder is not pumped here on purpose: it is thirty-four controls
/// over eight dictionaries, and a test that mounts all of it asserts mostly
/// that Flutter lays out a `ListView`. What is worth pinning is the behaviour a
/// reader cannot see by looking — the level floor binding a **rank** where
/// everything else in this app binds an id, and BR-12 refusing an unjustified
/// restriction *before* the request rather than after it.
void main() {
  DictionaryItem level(
    String id,
    String code,
    String label, {
    required int rank,
    required int sortOrder,
  }) => DictionaryItem(
    id: id,
    code: code,
    label: label,
    sortOrder: sortOrder,
    isActive: true,
    rank: rank,
  );

  /// A scale whose `rank` and `sortOrder` deliberately disagree.
  ///
  /// They agree in the seed data today, which is exactly why they must not here
  /// — a field reading `sortOrder` would pass every test written against a
  /// realistic fixture, and then break the day an administrator inserts a level
  /// between two others (§10.3). `sortOrder` is a display order and moves;
  /// `rank` is what "or better" compares.
  ///
  /// The ids share no substring with the labels or the ranks either, so no test
  /// here can pass because the wrong one leaked through.
  final skillLevels = [
    level('a7f2-1100', 'basic', 'Boshlangʻich', rank: 10, sortOrder: 3),
    level('b3e8-2200', 'intermediate', 'Oʻrta', rank: 20, sortOrder: 2),
    level('c9d4-3300', 'advanced', 'Yuqori', rank: 30, sortOrder: 1),
    level('d1c6-4400', 'expert', 'Ekspert', rank: 40, sortOrder: 0),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Map<String, List<DictionaryItem>> catalogue = const {},
    Set<String> failing = const {},
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // Mirrors main.dart: an error is terminal, not a slow load. Without
        // this the failure test below would observe a spinner instead.
        retry: (retryCount, error) => null,
        overrides: [
          for (final entry in catalogue.entries)
            dictionaryProvider(entry.key).overrideWith((ref) => entry.value),
          for (final type in failing)
            dictionaryProvider(
              type,
            ).overrideWith((ref) => throw Exception('no network')),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('§7.4: a level floor binds a rank, not an id', () {
    testWidgets('choosing a level calls back with its rank', (tester) async {
      final received = <int?>[];

      await pump(
        tester,
        LevelFloorField(
          label: 'Minimum level',
          type: DictionaryType.skillLevel,
          value: null,
          onChanged: received.add,
        ),
        catalogue: {DictionaryType.skillLevel: skillLevels},
      );

      await tester.tap(find.text('Yuqori'));
      await tester.pumpAndSettle();

      // 30, not 'c9d4-3300'. "Advanced or better" is a comparison, and an id
      // cannot express one — this is the single place in the app where a
      // dictionary choice does not store the id.
      expect(received, [30]);
    });

    testWidgets('the whole ladder is on screen, weakest first', (tester) async {
      await pump(
        tester,
        LevelFloorField(
          label: 'Minimum level',
          type: DictionaryType.skillLevel,
          value: null,
          onChanged: (_) {},
        ),
        catalogue: {DictionaryType.skillLevel: skillLevels},
      );

      final labels = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();

      // A floor is only legible if you can see what is above the line.
      expect(
        labels.indexOf('Boshlangʻich'),
        lessThan(labels.indexOf('Ekspert')),
      );
    });

    testWidgets('an unranked item is never offered', (tester) async {
      // Binding null as a floor reads as "any level" and silently drops the
      // filter, so an item with no rank is not a choice at all.
      await pump(
        tester,
        LevelFloorField(
          label: 'Minimum level',
          type: DictionaryType.skillLevel,
          value: null,
          onChanged: (_) {},
        ),
        catalogue: {
          DictionaryType.skillLevel: [
            ...skillLevels,
            const DictionaryItem(
              id: 'e2b0-5500',
              code: 'unranked',
              label: 'Darajasiz',
              sortOrder: 4,
              isActive: true,
            ),
          ],
        },
      );

      expect(find.text('Darajasiz'), findsNothing);
      expect(find.text('Ekspert'), findsOneWidget);
    });

    testWidgets('tapping the chosen level clears the floor', (tester) async {
      final received = <int?>[];

      await pump(
        tester,
        LevelFloorField(
          label: 'Minimum level',
          type: DictionaryType.skillLevel,
          value: 30,
          onChanged: received.add,
        ),
        catalogue: {DictionaryType.skillLevel: skillLevels},
      );

      await tester.tap(find.text('Yuqori'));
      await tester.pumpAndSettle();

      // A filter you cannot undo where you set it is the one people reset the
      // whole form to escape.
      expect(received, [null]);
    });

    testWidgets('a scale that will not load degrades to "any"', (tester) async {
      // Not an error screen: a filter that cannot offer a floor still filters.
      // hasError is matched before loading, so this can never be an ellipsis
      // that resolves at no point.
      await pump(
        tester,
        LevelFloorField(
          label: 'Minimum level',
          type: DictionaryType.skillLevel,
          value: null,
          onChanged: (_) {},
        ),
        failing: {DictionaryType.skillLevel},
      );

      expect(find.text('Any level'), findsOneWidget);
      expect(find.text('…'), findsNothing);
    });
  });

  group('the applied-filter chips', () {
    testWidgets('nothing filtered says so rather than showing nothing', (
      tester,
    ) async {
      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(),
          onChanged: (_) {},
        ),
      );

      expect(
        find.text('No filters — every searchable candidate'),
        findsOneWidget,
      );
    });

    testWidgets('a group with several values says how many', (tester) async {
      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(
            skillIds: ['s1', 's2', 's3'],
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.text('Skills (3)'), findsOneWidget);
    });

    testWidgets('a group with one value does not count it', (tester) async {
      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(skillIds: ['s1']),
          onChanged: (_) {},
        ),
      );

      // "Skills (1)" is a count nobody needed.
      expect(find.text('Skills'), findsOneWidget);
    });

    testWidgets('a filter whose value needs no dictionary carries it', (
      tester,
    ) async {
      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(experienceYearsMin: 5),
          onChanged: (_) {},
        ),
      );

      expect(find.text('Experience: 5'), findsOneWidget);
    });

    testWidgets('removing a chip removes its dependents too', (tester) async {
      CandidateSearchFilters? received;

      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(
            occupationIds: ['occ-1'],
            occupationExperienceYearsMin: 3,
          ),
          onChanged: (next) => received = next,
        ),
      );

      // The chip for the occupation, not the one for the years.
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(HhRemovableChip, 'Occupations'),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pumpAndSettle();

      // Removing the occupation must not leave a set the server refuses with
      // `search.occupation_required` — a chip that appears to do nothing while
      // an error arrives about a filter the employer did not touch.
      expect(received?.occupationIds, isEmpty);
      expect(received?.occupationExperienceYearsMin, isNull);
    });

    testWidgets('clear all empties the set', (tester) async {
      CandidateSearchFilters? received;

      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(
            skillIds: ['s1'],
            regionId: 'r1',
            experienceYearsMin: 2,
          ),
          onChanged: (next) => received = next,
        ),
      );

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(received?.isEmpty, isTrue);
    });

    testWidgets('BR-12: a restriction is always visible as a chip', (
      tester,
    ) async {
      // This is what makes persisting a restricted search safe: the employer
      // can never be running one without seeing it.
      await pump(
        tester,
        AppliedFilterChips(
          filters: const CandidateSearchFilters(
            ageMin: 21,
            genderId: 'gender-1',
            restrictionJustificationId: 'just-1',
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.text('Age from: 21'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Restrictions'), findsOneWidget);
    });
  });
}
