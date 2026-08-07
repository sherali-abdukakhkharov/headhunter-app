import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:headhunter_app/src/features/profile/domain/field_schema.dart';
import 'package:headhunter_app/src/features/profile/presentation/leveled_field_editor.dart';

/// Widget tests for `dictionary_leveled` (§4.4).
///
/// The rule worth defending is the invariant: **every row has a level, by
/// construction.** The server rejects a row without one, so the editor is
/// built to make such a row impossible rather than merely unlikely — and that
/// is only observable by driving the two sheets in sequence.
void main() {
  const dart = 'a71c-3390';
  const flutter = '55e0-c1b2';

  const junior = '9b3f-0d47';
  const senior = 'd204-8ef6';

  DictionaryItem entry(String id, String code, String label, {int? rank}) =>
      DictionaryItem(
        id: id,
        code: code,
        label: label,
        sortOrder: rank ?? 0,
        isActive: true,
        rank: rank,
      );

  final skills = [
    entry(dart, 'dart', 'Dart'),
    entry(flutter, 'flutter', 'Flutter'),
  ];

  // Ranked, because §7.4's "at this level or better" compares rank rather than
  // label or sort order.
  final levels = [
    entry(junior, 'junior', 'Boshlangʻich', rank: 1),
    entry(senior, 'senior', 'Yuqori', rank: 3),
  ];

  const field = SchemaField(
    code: 'skills',
    kind: FieldKind.dictionaryLeveled,
    label: 'Kasbiy koʻnikmalar',
    required: false,
    dictionaryType: 'skill',
    levelDictionaryType: 'skill_level',
  );

  /// Pumps the editor and returns the list every `onChanged` payload lands in.
  ///
  /// Returning the accumulator rather than the latest value is what lets a
  /// test say *nothing was emitted* — which is the assertion the central
  /// invariant needs, and one that a "last value" holder cannot express.
  Future<List<List<Map<String, dynamic>>>> pump(
    WidgetTester tester, {
    List<Map<String, dynamic>> rows = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final changes = <List<Map<String, dynamic>>>[];

    await tester.pumpWidget(
      ProviderScope(
        // Mirrors main.dart, so a failed resolution is terminal rather than a
        // retrying AsyncLoading.
        retry: (retryCount, error) => null,
        overrides: [
          dictionaryProvider('skill').overrideWith((ref) => skills),
          dictionaryProvider('skill_level').overrideWith((ref) => levels),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(
            body: LeveledFieldEditor(
              field: field,
              rows: rows,
              onChanged: changes.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return changes;
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Taps an option **inside the open sheet**.
  ///
  /// Scoped to the sheet's list, because a row already on the field shows the
  /// same label as the option that would change it — an unscoped `find.text`
  /// matches both and cannot say which one it meant.
  Future<void> tapOption(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: find.byType(ListView), matching: find.text(label)),
    );
    await tester.pumpAndSettle();
  }

  /// Dismisses the open sheet by tapping the scrim above it. The sheet opens at
  /// 0.75 of the viewport, so the top quarter is barrier.
  Future<void> dismissSheet(WidgetTester tester) async {
    await tester.tapAt(const Offset(180, 20));
    await tester.pumpAndSettle();
  }

  group('every row has a level, by construction', () {
    testWidgets('backing out of the level picker adds nothing at all', (
      tester,
    ) async {
      final changes = await pump(tester);

      await tapText(tester, 'Add');
      await tapOption(tester, 'Dart');
      // The level sheet is now open. Walking away from it must not leave a
      // half-built row behind: the server refuses one, so the editor never
      // creates one.
      await dismissSheet(tester);

      expect(changes, isEmpty);
    });

    testWidgets('choosing both creates one row carrying both ids', (
      tester,
    ) async {
      final changes = await pump(tester);

      await tapText(tester, 'Add');
      await tapOption(tester, 'Dart');
      await tapOption(tester, 'Yuqori');

      // Ids on both halves, never labels — BR-13 governs the level too.
      expect(changes, [
        [
          {'itemId': dart, 'levelId': senior},
        ],
      ]);
    });

    testWidgets('backing out of the item picker adds nothing either', (
      tester,
    ) async {
      final changes = await pump(tester);

      await tapText(tester, 'Add');
      await dismissSheet(tester);

      expect(changes, isEmpty);
    });
  });

  testWidgets('the level sheet is titled for the level, not for the field', (
    tester,
  ) async {
    await pump(tester);

    await tapText(tester, 'Add');
    // The item sheet is correctly titled for the field, so the label shows
    // twice here: once as the editor's own label, once as the sheet title.
    expect(find.text(field.label), findsNWidgets(2));

    await tapOption(tester, 'Dart');

    // Now the level sheet. Titling this one `field.label` as well reads as the
    // same question asked twice, and the second one is the one nothing on
    // screen explains.
    expect(find.text('Level'), findsOneWidget);
    expect(find.text(field.label), findsOneWidget);
  });

  testWidgets('re-adding an item corrects its level rather than duplicating', (
    tester,
  ) async {
    final changes = await pump(
      tester,
      rows: const [
        {'itemId': dart, 'levelId': junior},
      ],
    );

    await tapText(tester, 'Add');
    await tapOption(tester, 'Dart');
    await tapOption(tester, 'Yuqori');

    // One row, at the corrected level — which is how the server reads it too.
    expect(changes, [
      [
        {'itemId': dart, 'levelId': senior},
      ],
    ]);
  });

  testWidgets('changing a level rewrites that row and leaves the rest', (
    tester,
  ) async {
    final changes = await pump(
      tester,
      rows: const [
        {'itemId': dart, 'levelId': junior},
        {'itemId': flutter, 'levelId': junior},
      ],
    );

    // The per-row button, not the sheet: there is one per row and the first
    // belongs to Dart.
    await tester.tap(find.text('Level').first);
    await tester.pumpAndSettle();
    await tapOption(tester, 'Yuqori');

    expect(changes, [
      [
        {'itemId': dart, 'levelId': senior},
        {'itemId': flutter, 'levelId': junior},
      ],
    ]);
  });

  testWidgets('a row shows its item label and its level label', (
    tester,
  ) async {
    await pump(
      tester,
      rows: const [
        {'itemId': dart, 'levelId': junior},
        {'itemId': flutter, 'levelId': senior},
      ],
    );

    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Boshlangʻich'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Yuqori'), findsOneWidget);

    // Never the ids.
    expect(find.text(dart), findsNothing);
    expect(find.text(junior), findsNothing);
  });

  testWidgets('removing a row drops only that row', (tester) async {
    final changes = await pump(
      tester,
      rows: const [
        {'itemId': dart, 'levelId': junior},
        {'itemId': flutter, 'levelId': senior},
      ],
    );

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    expect(changes, [
      [
        {'itemId': flutter, 'levelId': senior},
      ],
    ]);
  });

  testWidgets('an empty field says so rather than rendering nothing', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Nothing selected yet'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
