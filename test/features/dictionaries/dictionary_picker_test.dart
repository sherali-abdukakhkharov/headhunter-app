import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_picker.dart';

/// Widget tests for the pickers (§3.3, BR-13, §5.1, §10.3).
///
/// Both bugs these pickers have had were found by running the app, not by the
/// suite — see MEMORY.md. So these pin *behaviour a reader can see on screen*:
/// what the sheet offers, what the field displays, and what the callback
/// receives. Nothing here asserts on an internal.
///
/// **Only [dictionaryProvider] is overridden.** Everything else in the graph —
/// the selectable filter, the parent cascade, label resolution — runs its real
/// implementation on top of the fake catalogue, because those three are the
/// rules under test and faking them would test the fake.
void main() {
  // Ids are deliberately opaque and share no substring with their labels, so a
  // test that passes because a label leaked into a callback cannot exist.
  const developer = 'f1a0-9c33';
  const teacher = '0b47-21de';
  const retired = 'c8e2-77aa';
  const merged = '4d16-b005';

  const tashkentCity = '7f30-1188';
  const tashkentRegion = 'a920-63c4';
  const chilanzar = 'e5b1-402f';
  const yunusabad = '2c74-9ab8';

  DictionaryItem item(
    String id,
    String code,
    String label, {
    int sortOrder = 0,
    bool isActive = true,
    String? parentId,
    String? mergedIntoId,
    int? rank,
  }) => DictionaryItem(
    id: id,
    code: code,
    label: label,
    sortOrder: sortOrder,
    isActive: isActive,
    parentId: parentId,
    mergedIntoId: mergedIntoId,
    rank: rank,
  );

  // One retired and one merged item, because §10.3 treats them the same way on
  // the way in (not offered) and the same way on the way out (still resolved).
  final occupations = [
    item(developer, 'developer', 'Dasturchi'),
    item(teacher, 'teacher', "O'qituvchi", sortOrder: 1),
    item(retired, 'telegraphist', 'Telegrafchi', sortOrder: 2, isActive: false),
    item(merged, 'coder', 'Koder', sortOrder: 3, mergedIntoId: developer),
  ];

  // A single type holding both levels of the hierarchy, told apart only by
  // parentId — which is exactly the shape §5.1 describes and the shape that
  // makes an unscoped region picker offer districts.
  final regions = [
    item(tashkentCity, 'tashkent_city', 'Toshkent shahri'),
    item(tashkentRegion, 'tashkent_region', 'Toshkent viloyati', sortOrder: 1),
    item(chilanzar, 'chilanzar', 'Chilonzor', parentId: tashkentCity),
    item(yunusabad, 'yunusabad', 'Yunusobod', parentId: tashkentCity),
  ];

  /// Pumps [child] over a fake catalogue.
  ///
  /// Takes the data rather than a list of overrides because `Override` is not
  /// exported by `flutter_riverpod` — and the call sites read better for it.
  /// [failing] makes a type throw, for the error-state rule.
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Map<String, List<DictionaryItem>> catalogue = const {},
    Set<String> failing = const {},
    // Keyed on (type, idKey). With a single id, labelKey is the id itself.
    Map<(String, String), Map<String, DictionaryItem>> resolves = const {},
    Set<(String, String)> resolveFails = const {},
  }) async {
    // A phone-shaped surface. The pickers are 52px rows in a sheet sized as a
    // fraction of the viewport, and 800x600 is not a shape this app ever runs
    // at.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // Mirrors main.dart. Without it a thrown provider sits in AsyncLoading
        // that merely carries the error, and the error test below would pass
        // by observing a spinner — the exact confusion the app-wide setting
        // exists to prevent.
        retry: (retryCount, error) => null,
        overrides: [
          for (final entry in catalogue.entries)
            dictionaryProvider(entry.key).overrideWith((ref) => entry.value),
          for (final type in failing)
            dictionaryProvider(
              type,
            ).overrideWith((ref) => throw Exception('no network')),
          for (final entry in resolves.entries)
            resolvedLabelsProvider(
              entry.key.$1,
              entry.key.$2,
            ).overrideWith((ref) => entry.value),
          for (final key in resolveFails)
            resolvedLabelsProvider(
              key.$1,
              key.$2,
            ).overrideWith((ref) => throw Exception('lookup failed')),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
  }

  /// Dismisses a modal sheet by tapping the scrim above it.
  ///
  /// The sheet opens at 0.75 of the viewport, so the top quarter is barrier.
  Future<void> dismissSheet(WidgetTester tester) async {
    await tester.tapAt(const Offset(180, 20));
    await tester.pumpAndSettle();
  }

  group('BR-13: the picker displays a label and binds an id', () {
    testWidgets('choosing an option calls back with the id, never the label', (
      tester,
    ) async {
      final received = <String?>[];

      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: null,
          onChanged: received.add,
        ),
        catalogue: {'occupation': occupations},
      );

      await openSheet(tester);
      await tester.tap(find.text('Dasturchi'));
      await tester.pumpAndSettle();

      expect(received, [developer]);
      // Stated separately from the equality above: this is the assertion BR-13
      // is actually about, and it should fail loudly rather than as a diff.
      expect(received.single, isNot('Dasturchi'));
    });

    testWidgets('the field renders the label for the id it holds', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: teacher,
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
      );

      expect(find.text("O'qituvchi"), findsOneWidget);
      expect(find.text(teacher), findsNothing);
    });

    testWidgets('multi-select chips show labels and the callback carries ids', (
      tester,
    ) async {
      List<String>? received;

      await pump(
        tester,
        HhDictionaryMultiPicker(
          label: 'Kasblar',
          type: 'occupation',
          values: const [developer],
          onChanged: (ids) => received = ids,
        ),
        catalogue: {'occupation': occupations},
      );

      expect(find.text('Dasturchi'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("O'qituvchi"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(received, unorderedEquals([developer, teacher]));
    });
  });

  group('§10.3: retired and merged items', () {
    testWidgets('neither is offered in the sheet', (tester) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: null,
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
      );

      await openSheet(tester);

      expect(find.text('Dasturchi'), findsOneWidget);
      expect(find.text('Telegrafchi'), findsNothing);
      // Offering both sides of a merge lets someone pick the id that is about
      // to stop existing.
      expect(find.text('Koder'), findsNothing);
    });

    testWidgets('a retired id already on a profile still reads as words', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: retired,
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
      );

      expect(find.text('Telegrafchi'), findsOneWidget);
      expect(find.text('Unavailable value'), findsNothing);
    });

    testWidgets('an id nothing can resolve reads as the unknown-value string', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: 'not-a-real-id',
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
        // The server does not know it either, so the lookup succeeds and comes
        // back empty.
        resolves: const {('occupation', 'not-a-real-id'): {}},
      );

      // Never the raw id: a UUID on screen is not a label in any language.
      expect(find.text('not-a-real-id'), findsNothing);
      expect(find.text('Unavailable value'), findsOneWidget);
    });

    // Found by this test: both pickers used to fall through to the loading arm
    // on a resolution *failure*, and with Riverpod's retry disabled app-wide
    // that ellipsis is terminal — the field never says what it holds. The
    // leveled editor already guarded against it; the pickers did not.
    testWidgets('a failed lookup says unavailable, not an endless ellipsis', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: 'not-a-real-id',
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
        resolveFails: const {('occupation', 'not-a-real-id')},
      );

      expect(find.text('…'), findsNothing);
      expect(find.text('Unavailable value'), findsOneWidget);
    });

    testWidgets('a multi-select chip survives a failed lookup too', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryMultiPicker(
          label: 'Kasblar',
          type: 'occupation',
          values: const ['not-a-real-id'],
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
        resolveFails: const {('occupation', 'not-a-real-id')},
      );

      expect(find.text('…'), findsNothing);
      expect(find.text('Unavailable value'), findsOneWidget);
    });
  });

  group('§5.1: one type, two levels of hierarchy', () {
    testWidgets('a parent-scoped picker offers regions but not districts', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Viloyat',
          type: 'region',
          value: null,
          parentScoped: true,
          onChanged: (_) {},
        ),
        catalogue: {'region': regions},
      );

      await openSheet(tester);

      expect(find.text('Toshkent shahri'), findsOneWidget);
      // The whole reason parentScoped exists. Without it these are offered
      // alongside the regions, each one a valid-looking option binding a real
      // id — which is why it is invisible until someone looks.
      expect(find.text('Chilonzor'), findsNothing);
      expect(find.text('Yunusobod'), findsNothing);
    });

    testWidgets("a child picker offers only the chosen parent's children", (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Tuman',
          type: 'region',
          value: null,
          parentId: tashkentCity,
          requiresParentLabel: 'Choose a region first',
          onChanged: (_) {},
        ),
        catalogue: {'region': regions},
      );

      await openSheet(tester);

      expect(find.text('Chilonzor'), findsOneWidget);
      expect(find.text('Yunusobod'), findsOneWidget);
      expect(find.text('Toshkent shahri'), findsNothing);
    });

    testWidgets('with no parent chosen the field is disabled and says why', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Tuman',
          type: 'region',
          value: null,
          requiresParentLabel: 'Choose a region first',
          onChanged: (_) {},
        ),
        catalogue: {'region': regions},
      );

      expect(find.text('Choose a region first'), findsOneWidget);

      // Inert by construction rather than merely styled as disabled: the
      // blocked branch renders no text field at all, so there is nothing to
      // tap and the sheet cannot open. With no parent it would otherwise list
      // every district in the country.
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('search', () {
    testWidgets('filters on the label and still returns an id', (tester) async {
      final received = <String?>[];

      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: null,
          onChanged: received.add,
        ),
        catalogue: {'occupation': occupations},
      );

      await openSheet(tester);
      await tester.enterText(find.byType(TextField).last, 'qit');
      await tester.pumpAndSettle();

      expect(find.text('Dasturchi'), findsNothing);
      expect(find.text("O'qituvchi"), findsOneWidget);

      await tester.tap(find.text("O'qituvchi"));
      await tester.pumpAndSettle();

      expect(received, [teacher]);
    });

    testWidgets('a search matching nothing shows the empty state', (
      tester,
    ) async {
      await pump(
        tester,
        HhDictionaryPicker(
          label: 'Kasb',
          type: 'occupation',
          value: null,
          onChanged: (_) {},
        ),
        catalogue: {'occupation': occupations},
      );

      await openSheet(tester);
      await tester.enterText(find.byType(TextField).last, 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches that search.'), findsOneWidget);
    });
  });

  // The trap recorded in CLAUDE.md: a UI that matches AsyncLoading before
  // checking hasError shows an endless spinner instead of the failure.
  testWidgets('a dictionary that fails shows the error state, not a spinner', (
    tester,
  ) async {
    await pump(
      tester,
      HhDictionaryPicker(
        label: 'Kasb',
        type: 'occupation',
        value: null,
        onChanged: (_) {},
      ),
      failing: const {'occupation'},
    );

    await openSheet(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('backing out of the sheet changes nothing', (tester) async {
    final received = <String?>[];

    await pump(
      tester,
      HhDictionaryPicker(
        label: 'Kasb',
        type: 'occupation',
        value: developer,
        onChanged: received.add,
      ),
      catalogue: {'occupation': occupations},
    );

    await openSheet(tester);
    await dismissSheet(tester);

    expect(received, isEmpty);
    expect(find.text('Dasturchi'), findsOneWidget);
  });

  group('labelKey', () {
    // Not a widget test, but it belongs with the pickers: it is the reason a
    // picker does not leak a provider on every rebuild.
    test('sorts, so the same set in any order is one provider', () {
      expect(labelKey(['b', 'a']), labelKey(['a', 'b']));
    });

    test('an empty set resolves to the empty key', () {
      expect(labelKey(const []), '');
    });
  });
}
