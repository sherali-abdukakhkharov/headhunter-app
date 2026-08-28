/// The empty-state drawings, and the one property that is not decoration.
///
/// A list that has never had anything in it is fixed by **acting**; a list four
/// filters just emptied is fixed by **undoing**. One drawing for both would
/// tell somebody who has just set four filters to go and wait for employers to
/// publish, which is why the brief asked for three and why the wrong one is a
/// content bug rather than a cosmetic one.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

Future<void> pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(theme: HhTheme.light, home: Scaffold(body: child)),
  );
  await tester.pumpAndSettle();
}

/// The drawing an [HhEmptyState] actually rendered.
HhSpotArt renderedArt(WidgetTester tester) =>
    tester.widget<HhSpotIllustration>(find.byType(HhSpotIllustration)).art;

void main() {
  testWidgets('an empty state draws the neutral art by default', (
    tester,
  ) async {
    await pump(
      tester,
      const HhEmptyState(title: 'Nothing here', message: 'It is empty.'),
    );

    // Neutral rather than one of the other two, because guessing wrong tells
    // the reader to do the opposite of what would help.
    expect(renderedArt(tester), HhSpotArt.neutral);
  });

  testWidgets('the reserved box is filled, never left as a placeholder', (
    tester,
  ) async {
    await pump(
      tester,
      const HhEmptyState(title: 'Nothing here', message: 'It is empty.'),
    );

    // The box was a plain sand rectangle until 2026-08-28. It is 110 × 80 and
    // the drawing has to occupy it, or every empty state in the product has a
    // hole where the design put an illustration.
    final size = tester.getSize(find.byType(HhSpotIllustration));
    expect(size, const Size(110, 80));
  });

  testWidgets('a caller can say which of the three this is', (tester) async {
    await pump(
      tester,
      const HhEmptyState(
        title: 'Nothing matches',
        message: 'Try widening the filters.',
        art: HhSpotArt.filter,
      ),
    );

    expect(renderedArt(tester), HhSpotArt.filter);
  });

  testWidgets('an explicit illustration wins over the art', (tester) async {
    await pump(
      tester,
      const HhEmptyState(
        title: 'Nothing here',
        message: 'It is empty.',
        art: HhSpotArt.first,
        illustration: SizedBox.shrink(),
      ),
    );

    // The gallery and anything showing a picture of its own still can.
    expect(find.byType(HhSpotIllustration), findsNothing);
  });

  testWidgets('the drawings are decorative, and say so to TalkBack', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pump(
      tester,
      const HhEmptyState(title: 'Nothing here', message: 'It is empty.'),
    );

    // Every state that shows one of these also states the same thing in words
    // directly beneath it. A described image would say it twice.
    //
    // Asserted on the `ExcludeSemantics` rather than on the absence of a
    // `Semantics` node: `SvgPicture` builds one of its own, so "no Semantics
    // anywhere below" is a claim about flutter_svg's internals and would go
    // red on an upgrade that changed nothing here.
    expect(
      find.descendant(
        of: find.byType(HhSpotIllustration),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );

    expect(find.text('Nothing here'), findsOneWidget);
    handle.dispose();
  });

  group('the drawings themselves', () {
    test('every one is two colours, and both carry something', () {
      for (final art in HhSpotArt.values) {
        // The brief is navy **and** turquoise. A drawing with an empty accent
        // is a one-colour drawing wearing the type of a two-colour one, and
        // the accent is the half that carries the meaning.
        expect(art.navy.trim(), isNotEmpty, reason: '${art.name} navy');
        expect(art.accent.trim(), isNotEmpty, reason: '${art.name} accent');
      }
    });

    test('every path stays inside the 110 x 80 viewBox', () {
      // Nothing clips it, so a path that runs past the box is simply drawn
      // outside the reserved space and overlaps the title beneath it — which
      // renders fine, passes every other assertion, and looks broken.
      // **Absolute `M` and `L` only.** Every other command is relative to a pen
      // position this would have to track, and a checker that guesses at that
      // is a checker that fails on correct paths — the first version of this
      // test read the numbers out of the `h30l14 14v42` following an `M` and
      // called the drawing broken.
      //
      // The anchor points alone are enough to catch the mistake worth
      // catching: a drawing placed outside the box rather than one whose curve
      // strays a pixel over it.
      final anchors = RegExp(
        r'[ML]\s*(-?\d+(?:\.\d+)?)[,\s]+(-?\d+(?:\.\d+)?)',
      );

      for (final art in HhSpotArt.values) {
        for (final path in [art.navy, art.accent]) {
          final points = anchors.allMatches(path).toList();
          expect(points, isNotEmpty, reason: '${art.name}: no anchor point');

          for (final point in points) {
            expect(
              double.parse(point.group(1)!),
              inInclusiveRange(0, 110),
              reason: '${art.name}: x outside the box at "${point.group(0)}"',
            );
            expect(
              double.parse(point.group(2)!),
              inInclusiveRange(0, 80),
              reason: '${art.name}: y outside the box at "${point.group(0)}"',
            );
          }
        }
      }
    });
  });
}
