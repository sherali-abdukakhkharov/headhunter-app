import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/dictionary_draft.dart';
import 'package:jobbridge_app/src/features/admin/presentation/dictionary_type_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

import 'admin_fake.dart';

/// §10.3's dictionary administration — MT-004, the last placeholder in the
/// release shell.
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin();

  ApiException? activeFailure;
  ApiException? mergeFailure;
  ApiException? createFailure;

  /// Whether the activation answers 409 `dictionary.state_unchanged`.
  bool stateUnchanged = false;

  final created = <({String type, Map<String, dynamic> body})>[];
  final activations = <({String itemId, bool isActive})>[];
  final merges = <({String itemId, String survivorId})>[];

  @override
  Future<String> createDictionaryItem(
    String typeCode,
    NewDictionaryItem item,
  ) async {
    created.add((type: typeCode, body: item.toJson()));
    if (createFailure case final error?) throw error;
    return 'new-id';
  }

  @override
  Future<void> setDictionaryItemActive(
    String itemId, {
    required bool isActive,
  }) async {
    activations.add((itemId: itemId, isActive: isActive));
    if (stateUnchanged) {
      throw const AdminDecisionConflict('It is already in that state.');
    }
    if (activeFailure case final error?) throw error;
  }

  @override
  Future<void> mergeDictionaryItems(String itemId, String survivorId) async {
    merges.add((itemId: itemId, survivorId: survivorId));
    if (mergeFailure case final error?) throw error;
  }
}

DictionaryItem _item({
  String id = 'itm-1',
  String code = 'welder',
  String label = 'Payvandchi',
  bool isActive = true,
  String? mergedIntoId,
}) => DictionaryItem(
  id: id,
  code: code,
  label: label,
  sortOrder: 1,
  isActive: isActive,
  mergedIntoId: mergedIntoId,
);

void main() {
  Future<_FakeAdmin> pump(
    WidgetTester tester, {
    List<DictionaryItem> items = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin();

    await tester.pumpWidget(
      ProviderScope(
        // Riverpod 3 retries a throwing provider by default and reports
        // `AsyncLoading` while it does. The app disables it in `main.dart`.
        retry: (retryCount, error) => null,
        overrides: [
          adminRepositoryProvider.overrideWithValue(fake),
          dictionaryProvider('occupation').overrideWith((ref) => items),
          // The merge picker offers only what a picker would: active, not
          // merged away. That filtering is `selectableDictionary`'s job and it
          // has its own tests, so here it is served directly.
          selectableDictionaryProvider('occupation').overrideWith(
            (ref) => [for (final i in items) if (i.isSelectable) i],
          ),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const DictionaryTypeScreen(type: 'occupation'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  Future<void> openActions(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// The nth field **inside an open sheet**.
  ///
  /// A modal sheet opens over the screen, whose search box is the first
  /// `TextField` in the tree — so index 0 belongs to the list behind, not to
  /// the sheet in front.
  Finder sheetField(int index) => find.byType(TextField).at(index + 1);

  /// Presses a button inside a sheet, bringing it into view first.
  ///
  /// The create sheet is taller than a phone with five fields on it, so its
  /// confirm button starts below the fold and a bare `tap` misses.
  Future<void> pressInSheet(WidgetTester tester, String label) async {
    final button = find.widgetWithText(HhButton, label);
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Chooses the survivor in the merge picker.
  ///
  /// The picker's *label* is a separate `Text` above the box and taps nothing,
  /// so the field itself is what opens it.
  Future<void> chooseSurvivor(WidgetTester tester, String label) async {
    await tester.tap(sheetField(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  group('the list shows what BR-13 keeps rather than what a picker offers', () {
    testWidgets('a retired item is listed, and marked', (tester) async {
      await pump(
        tester,
        items: [
          _item(),
          _item(id: 'itm-2', code: 'smith', label: 'Temirchi', isActive: false),
        ],
      );

      // Nothing is ever deleted (BR-13), so an administrator's list has to
      // show what a picker deliberately hides — that is the difference between
      // "what is in use" and "what exists".
      expect(find.text('Payvandchi'), findsOneWidget);
      expect(find.text('Temirchi'), findsOneWidget);
      expect(find.text('Not in use'), findsOneWidget);
    });

    testWidgets('a merged item says so instead', (tester) async {
      await pump(
        tester,
        items: [_item(isActive: false, mergedIntoId: 'itm-9')],
      );

      // Two different facts: retired is a decision about a real item, merged
      // is a pointer at the one that replaced it.
      expect(find.text('Merged'), findsOneWidget);
      expect(find.text('Not in use'), findsNothing);
    });

    testWidgets('the search reads codes as well as names', (tester) async {
      await pump(
        tester,
        items: [_item(), _item(id: 'itm-2', code: 'smith', label: 'Temirchi')],
      );

      await tester.enterText(find.byType(TextField).first, 'smith');
      await tester.pump();

      // An administrator hunting a duplicate often has the code, and the label
      // may be in a language they cannot type.
      expect(find.text('Temirchi'), findsOneWidget);
      expect(find.text('Payvandchi'), findsNothing);
    });

    testWidgets('an empty search result does not read as an empty type', (
      tester,
    ) async {
      await pump(tester, items: [_item()]);

      await tester.enterText(find.byType(TextField).first, 'zzz');
      await tester.pump();

      expect(find.text('Nothing matches'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsNothing);
    });
  });

  group('activation is the one thing §3.2 can refuse', () {
    testWidgets('a retired item is put back into use', (tester) async {
      final fake = await pump(tester, items: [_item(isActive: false)]);

      await openActions(tester, 'Payvandchi');
      await tester.tap(find.text('Put into use'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.activations.single, (itemId: 'itm-1', isActive: true));
    });

    testWidgets('and a 422 is a translation, not a fault', (tester) async {
      final fake = await pump(tester, items: [_item(isActive: false)]);
      fake.activeFailure = const ApiException('Unprocessable', statusCode: 422);

      await openActions(tester, 'Payvandchi');
      await tester.tap(find.text('Put into use'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The database refuses to activate an item missing any of the four
      // labels (§3.2). Rendering the server's status line would tell an
      // administrator nothing about what to do.
      expect(
        find.textContaining('all four languages'),
        findsOneWidget,
      );
      expect(find.text('Unprocessable'), findsNothing);
    });

    testWidgets('a 409 means somebody else did it, and the work is done', (
      tester,
    ) async {
      final fake = await pump(tester, items: [_item()]);
      fake.stateUnchanged = true;

      await openActions(tester, 'Payvandchi');
      await tester.tap(find.text('Take out of use'));
      await tester.pumpAndSettle();

      // The sheet closes as it would on success: `dictionary.state_unchanged`
      // is the ordinary race, and the list re-reads either way.
      expect(find.text('Take out of use'), findsNothing);
      expect(fake.activations, hasLength(1));
    });

    testWidgets('a merged item is offered nothing at all', (tester) async {
      await pump(
        tester,
        items: [_item(isActive: false, mergedIntoId: 'itm-9')],
      );

      await openActions(tester, 'Payvandchi');

      // Activating one would put a duplicate back into the pickers it was
      // merged out of.
      expect(find.text('Put into use'), findsNothing);
      expect(find.text('Merge'), findsNothing);
      expect(find.textContaining('nothing left to do'), findsOneWidget);
    });
  });

  group('a merge names which item goes', () {
    testWidgets('the one in the path is the one that loses', (tester) async {
      final fake = await pump(
        tester,
        items: [_item(), _item(id: 'itm-2', code: 'welder2', label: 'Payvand')],
      );

      await openActions(tester, 'Payvandchi');
      await chooseSurvivor(tester, 'Payvand');

      await tester.tap(find.widgetWithText(HhButton, 'Merge'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The direction is the one thing about a merge somebody can get
      // backwards, and it cannot be undone from this app.
      expect(fake.merges.single, (itemId: 'itm-1', survivorId: 'itm-2'));
    });

    testWidgets('and the server refusal is read, not translated', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        items: [_item(), _item(id: 'itm-2', label: 'Payvand')],
      );
      fake.mergeFailure = const ApiException(
        'That item was itself merged away.',
      );

      await openActions(tester, 'Payvandchi');
      await chooseSurvivor(tester, 'Payvand');
      await tester.tap(find.widgetWithText(HhButton, 'Merge'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Three of them — into itself, a type mismatch, a survivor already
      // merged — and the server's own sentence says which.
      expect(find.text('That item was itself merged away.'), findsOneWidget);
    });
  });

  group('creating collects all four labels (§3.2)', () {
    Future<_FakeAdmin> openForm(WidgetTester tester) async {
      final fake = await pump(tester);
      await tester.tap(find.text('Add an item'));
      await tester.pumpAndSettle();
      return fake;
    }

    testWidgets('a partial set is a draft, and says so', (tester) async {
      await openForm(tester);

      await tester.enterText(sheetField(0), 'welder');
      await tester.enterText(sheetField(1), 'Payvandchi');
      await tester.pump();

      // Not an error: §3.2 stops a partial item reaching a picker by refusing
      // to activate it. What would be wrong is letting somebody believe it is
      // finished.
      expect(
        find.textContaining('3 languages still to write'),
        findsOneWidget,
      );
    });

    testWidgets('the write carries every label typed and nothing else', (
      tester,
    ) async {
      final fake = await openForm(tester);

      await tester.enterText(sheetField(0), ' welder ');
      await tester.enterText(sheetField(1), 'Payvandchi');
      await tester.enterText(sheetField(2), 'Пайвандчи');
      await tester.enterText(sheetField(3), 'Сварщик');
      await tester.enterText(sheetField(4), 'Welder');
      await tester.pump();

      await pressInSheet(tester, 'Add');

      final body = fake.created.single;
      expect(body.type, 'occupation');
      expect(body.body['code'], 'welder');
      expect(body.body['labels'], {
        'uz-Latn': 'Payvandchi',
        'uz-Cyrl': 'Пайвандчи',
        'ru': 'Сварщик',
        'en': 'Welder',
      });
      // Never active on create: the client cannot know the four labels are
      // complete until the database accepts or refuses an activation, so it
      // asks separately and reads the answer.
      expect(body.body['isActive'], isFalse);
    });

    testWidgets('a code shorter than the server accepts cannot be sent', (
      tester,
    ) async {
      final fake = await openForm(tester);

      await tester.enterText(sheetField(0), 'w');
      await tester.pump();

      await pressInSheet(tester, 'Add');

      expect(fake.created, isEmpty);
    });

    testWidgets("a taken code is the server's sentence to read", (
      tester,
    ) async {
      final fake = await openForm(tester);
      fake.createFailure = const ApiException('That code is already used.');

      await tester.enterText(sheetField(0), 'welder');
      await tester.pump();
      await pressInSheet(tester, 'Add');

      // `dictionary.code_taken` means the item exists and the answer is to
      // merge rather than to add again.
      expect(find.text('That code is already used.'), findsOneWidget);
    });
  });

  group('the draft model', () {
    test('an empty label is not sent as an empty string', () {
      const draft = NewDictionaryItem(
        code: 'welder',
        labels: {'uz-Latn': 'Payvandchi', 'ru': '   ', 'en': ''},
      );

      // A blank is not a translation. Sending one would create a label the
      // §3.2 constraint counts as present.
      expect(draft.toJson()['labels'], {'uz-Latn': 'Payvandchi'});
      expect(draft.missingLocales, hasLength(3));
      expect(draft.isComplete, isFalse);
    });

    test('all four makes it complete', () {
      const draft = NewDictionaryItem(
        code: 'welder',
        labels: {
          'uz-Latn': 'Payvandchi',
          'uz-Cyrl': 'Пайвандчи',
          'ru': 'Сварщик',
          'en': 'Welder',
        },
      );

      expect(draft.missingLocales, ft.isEmpty);
      expect(draft.isComplete, isTrue);
    });
  });
}
