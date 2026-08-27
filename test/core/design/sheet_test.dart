import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// The bottom-sheet primitive, and the meta chip's label.
///
/// Both were carried items on the design-system list rather than bugs anybody
/// filed, and both had the same cause: a rule that existed in one component and
/// was never applied to its sibling.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

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

  /// Opens a sheet the way a screen does, and settles the animation.
  Future<void> open(WidgetTester tester, Widget sheet) async {
    await pump(
      tester,
      Builder(
        builder: (context) => HhButton(
          label: 'Open',
          onPressed: () => showHhSheet<void>(context, builder: (_) => sheet),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  group('HhSheet carries the chrome every sheet was copying', () {
    testWidgets('a title and a drag handle, without either being asked for', (
      tester,
    ) async {
      // Three of the twelve hand-rolled sheets had no handle. Nobody chose
      // that; they started from a copy that did not have one.
      await open(tester, const HhSheet(title: 'Notes', child: Text('body')));

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.byType(HhSheet), findsOneWidget);
    });

    testWidgets('it lifts for the keyboard, which two sheets did not', (
      tester,
    ) async {
      // The other omission the component fixes. A sheet with a text field has
      // to rise or the thing being typed into sits behind the keyboard, and
      // two of the twelve hand-rolled ones simply did not.
      await open(tester, const HhSheet(title: 'Notes', child: Text('body')));

      // The deepest bottom inset under the sheet: `SafeArea` contributes a
      // `Padding` of its own, so the first one in the tree is not the sheet's.
      double bottomInset() => tester
          .widgetList<Padding>(
            find.descendant(
              of: find.byType(HhSheet),
              matching: find.byType(Padding),
            ),
          )
          .map((p) => p.padding.resolve(TextDirection.ltr).bottom)
          .reduce((a, b) => a > b ? a : b);

      final before = bottomInset();

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(bottomInset(), greaterThan(before));
    });

    testWidgets('the handle is there at all', (tester) async {
      await open(tester, const HhSheet(child: Text('body')));

      expect(find.byType(HhSheetHandle), findsOneWidget);
    });

    testWidgets('the handle is not something a screen reader stops on', (
      tester,
    ) async {
      // It says "this drags" to a sighted user, and the gesture is not one a
      // screen reader offers — so a focus stop there is a dead end.
      final handle = tester.ensureSemantics();
      await open(tester, const HhSheet(child: Text('body')));

      expect(find.byType(ExcludeSemantics), findsWidgets);

      handle.dispose();
    });

    testWidgets('no title renders no empty line', (tester) async {
      await open(tester, const HhSheet(child: Text('body')));

      // Scoped to the sheet: the screen behind it still has its own text, and
      // a bare `find.byType(Text)` would be counting that too.
      expect(
        find.descendant(of: find.byType(HhSheet), matching: find.byType(Text)),
        findsOneWidget,
      );
    });

    testWidgets('a long body scrolls rather than overflowing', (tester) async {
      await open(
        tester,
        HhSheet(
          title: 'Long',
          child: Column(
            children: [
              for (var i = 0; i < 60; i++) Text('row $i'),
            ],
          ),
        ),
      );

      // No overflow exception, and the scroll view is the thing that made it
      // possible rather than a taller sheet.
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('scrollable: false leaves the child to lay itself out', (
      tester,
    ) async {
      // For a sheet whose child is a list: a `ListView` inside a
      // `SingleChildScrollView` has unbounded height, which either throws or
      // silently builds every row and loses the laziness the list was for.
      await open(
        tester,
        HhSheet(
          title: 'List',
          scrollable: false,
          child: ListView(
            shrinkWrap: true,
            children: const [Text('one'), Text('two')],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('two'), findsOneWidget);
    });
  });

  group('HhMetaChip shrinks its label before it overflows', () {
    testWidgets('a label wider than its box truncates', (tester) async {
      // The defect: an unconstrained `Text` in a `Row` overflows its line
      // rather than wrapping, so one long label painted a striped bar across
      // the card. Everything using this chip was one word until §10.4, and
      // **Russian would have shipped it broken** while English fitted.
      await pump(
        tester,
        const SizedBox(
          width: 120,
          child: HhMetaChip(
            label: 'Подтверждающий документ работодателя',
            iconPath: HhIconPath.document,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a short label is untouched', (tester) async {
      await pump(tester, const HhMetaChip(label: 'Tashkent'));

      expect(find.text('Tashkent'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the icon survives the squeeze', (tester) async {
      // The label shrinks *before the chip does*, which is `HhRemovableChip`'s
      // rule: whatever else is in the row has to stay.
      await pump(
        tester,
        const SizedBox(
          width: 90,
          child: HhMetaChip(
            label: 'Очень длинное название документа',
            iconPath: HhIconPath.document,
          ),
        ),
      );

      expect(find.byType(HhIcon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
