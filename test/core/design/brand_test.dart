import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// The transformed bounds of the mark inside one of the Android vector
/// drawables.
typedef _MarkBox = ({double left, double top, double width, double height});

/// Reads a launcher vector and works out where the mark actually lands.
///
/// The path data in those files is byte-identical to the design document and
/// the placement lives entirely in two nested `<group>` transforms, so the only
/// thing that can be wrong is the arithmetic — and nothing else in this repo
/// would catch it. `flutter analyze` does not read Android XML, `flutter test`
/// does not build it, and an off-centre icon looks plausible until it is beside
/// another app's on a home screen.
///
/// The ink's extremes are known from the design's crop, `viewBox="4.5 6.2 23
/// 19.8"`: x from 4.5 to 27.5, y from 6.2 to 26. So the transformed box follows
/// from the scale and the outer translate without parsing a single curve.
_MarkBox _markBox(String path) {
  final xml = File(path).readAsStringSync();

  double attr(String name) {
    final match = RegExp('$name="([-0-9.]+)"').firstMatch(xml);
    expect(match, isNotNull, reason: '$name missing from $path');
    return double.parse(match!.group(1)!);
  }

  // The outer group's scale and translate; the inner group only re-applies the
  // design's crop origin, which the ink extremes below already account for.
  final scale = attr('android:scaleX');
  expect(
    attr('android:scaleY'),
    scale,
    reason: 'a non-uniform scale would stretch the mark, which is misuse',
  );

  return (
    left: attr('android:translateX'),
    top: attr('android:translateY'),
    width: scale * 23,
    height: scale * 19.8,
  );
}

void main() {
  const foreground =
      'android/app/src/main/res/drawable/ic_launcher_foreground.xml';
  const legacy = 'android/app/src/main/res/mipmap-anydpi/ic_launcher.xml';

  /// Every rendered mark in the tree, as its SVG source.
  List<String> markSources(WidgetTester tester) => tester
      .widgetList<SvgPicture>(find.byType(SvgPicture))
      // `provideSvg` rather than a field: the string is private, and this is
      // the accessor the loader exposes for exactly this purpose.
      .map((p) => (p.bytesLoader as SvgStringLoader).provideSvg(null))
      .toList();

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HhTheme.light,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pump();
  }

  group('the mark reads in one colour, and never the wrong two', () {
    testWidgets('on navy the right figure is turquoise and the left white', (
      tester,
    ) async {
      await pump(
        tester,
        const HhBrandMark(width: 64, ground: HhBrandGround.navy),
      );

      final svg = markSources(tester).single;

      // Order matters: left group first, right group second. The design fixes
      // which figure is turquoise — "the right one, the employer, reaching
      // toward the candidate. Never swapped, never both."
      expect(svg.indexOf('#ffffff'), lessThan(svg.indexOf('#12b0be')));
      expect(svg.contains('#12b0be'), isTrue);
    });

    testWidgets('on white the mark is mono navy, never turquoise', (
      tester,
    ) async {
      await pump(
        tester,
        // The default ground, stated because it is the case under test: the
        // mark must be mono navy wherever nobody chose otherwise.
        const HhBrandMark(width: 64),
      );

      final svg = markSources(tester).single;

      // The design's board bans turquoise on white, and one of the four misuse
      // specimens is exactly this. Structural separation — two heads and the
      // 1.6-unit gap — is what makes a single colour legal.
      expect(svg.contains('#12b0be'), isFalse);
      expect(svg.contains('#0b2545'), isTrue);
    });

    testWidgets('on the turquoise plate the mark is mono navy', (tester) async {
      await pump(
        tester,
        const HhBrandMark(width: 64, ground: HhBrandGround.turquoise),
      );

      final svg = markSources(tester).single;
      expect(svg.contains('#12b0be'), isFalse);
      expect(svg.contains('#ffffff'), isFalse);
    });

    test('a ground is the only way to colour the mark', () {
      // Not an assertion about behaviour but about the API's shape, which is
      // the point of taking a ground rather than colours: "turquoise on white"
      // and "both figures turquoise" are two of the four documented misuses,
      // and neither is expressible.
      expect(HhBrandGround.values, hasLength(3));
    });
  });

  group('below 20px the pair fuses, so it becomes one figure', () {
    testWidgets('at the floor it is still the pair', (tester) async {
      await pump(tester, const HhBrandMark(width: HhBrandMark.pairFloor));

      // Both bodies present: two figures.
      expect(markSources(tester).single.contains('M27.5 26'), isTrue);
    });

    testWidgets('under the floor only the left figure is drawn', (
      tester,
    ) async {
      await pump(
        tester,
        const HhBrandMark(width: HhBrandMark.pairFloor - 1),
      );

      final svg = markSources(tester).single;
      expect(svg.contains('M4.5 26'), isTrue);
      expect(
        svg.contains('M27.5 26'),
        isFalse,
        reason: 'the right figure must be gone, not shrunk',
      );
      // And the crop narrows with it, or the solo would sit in a pair-width
      // box.
      expect(svg.contains('4.5 6.2 10.7 19.8'), isTrue);
    });

    testWidgets('the solo figure on navy is white, not turquoise', (
      tester,
    ) async {
      await pump(
        tester,
        const HhBrandMark(width: 16, ground: HhBrandGround.navy),
      );

      // Turquoise belongs to the right figure and there is no right figure.
      // Drawing the survivor turquoise would put the employer's colour on the
      // candidate.
      final svg = markSources(tester).single;
      expect(svg.contains('#ffffff'), isTrue);
      expect(svg.contains('#12b0be'), isFalse);
    });

    test('the two crops have different aspects, and the widget says so', () {
      const pair = HhBrandMark(width: 40);
      const solo = HhBrandMark(width: 16);

      expect(pair.isSolo, isFalse);
      expect(solo.isSolo, isTrue);

      // 23 : 19.8 becomes 10.7 : 19.8 — wider-than-tall becomes taller-than-
      // wide. Callers that assume one shape either side of the threshold are
      // the reason this is asserted rather than left to the doc comment.
      expect(pair.height, closeTo(40 * 19.8 / 23, 0.001));
      expect(solo.height, closeTo(16 * 19.8 / 10.7, 0.001));
      expect(pair.height, lessThan(pair.width));
      expect(solo.height, greaterThan(solo.width));
    });

    test('clear space is half the arch height, so it scales with the mark', () {
      expect(
        HhBrandMark.clearSpaceFor(100),
        closeTo(100 * 19.8 / 23 / 2, 0.001),
      );
    });
  });

  group('the lockup is a lockup', () {
    testWidgets('the horizontal mark matches the wordmark cap height', (
      tester,
    ) async {
      await pump(tester, const HhBrandLockup(fontSize: 40));

      // The rule is "the mark's height equals the wordmark's cap height", so
      // the mark's *width* is derived. Setting it independently is what turns a
      // lockup into two things near each other.
      final markHeight = tester.getSize(find.byType(SvgPicture)).height;
      expect(markHeight, closeTo(40 * 18.08 / 23, 0.5));
    });

    testWidgets('the wordmark ignores the text scaler', (tester) async {
      Future<double> widthAt(double scale) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HhTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const Scaffold(
                body: Center(child: HhBrandWordmark(color: Color(0xFF000000))),
              ),
            ),
          ),
        );
        await tester.pump();
        return tester.getSize(find.byType(Text)).width;
      }

      // A logotype is an image of a name, not readable content: if the word
      // grew while the mark did not, the lockup would break rather than become
      // readable. "Nisbat qulflangan" is one of the four misuse specimens.
      expect(await widthAt(2), closeTo(await widthAt(1), 0.01));
    });

    testWidgets('on navy the word stays white while the mark goes turquoise', (
      tester,
    ) async {
      await pump(tester, const HhBrandLockup(ground: HhBrandGround.navy));

      expect(
        tester.widget<Text>(find.byType(Text)).style?.color,
        HhColors.white,
        reason: 'never both turquoise',
      );
      expect(markSources(tester).single.contains('#12b0be'), isTrue);
    });

    testWidgets('the default size stays a pair, not a solo figure', (
      tester,
    ) async {
      // The cap-height derivation puts the mark within a couple of points of
      // the 20pt floor, so the default lockup is the case most at risk of
      // quietly dropping a figure — and a one-figure "lockup" is not one.
      await pump(tester, const HhBrandLockup());

      expect(markSources(tester).single.contains('M27.5 26'), isTrue);
    });

    test('the wordmark is never translated', () {
      // Not `appTitle`: a localizable key could one day come back in Cyrillic,
      // and the mark's construction has no Cyrillic form.
      expect(HhBrandWordmark.text, 'JobBridge');
    });
  });

  group('the launch plate inverts the icon', () {
    testWidgets('turquoise plate, navy mark', (tester) async {
      await pump(
        tester,
        const HhBrandLaunchPlate(screenSize: Size(360, 800)),
      );

      final decoration =
          tester.widget<Container>(find.byType(Container)).decoration
              as BoxDecoration?;
      expect(decoration?.color, HhColors.accent500);

      // The launcher icon is a turquoise arch on navy; this is the reverse, so
      // a stalled launch cannot be mistaken for a stalled home screen.
      expect(markSources(tester).single.contains('#0b2545'), isTrue);
    });

    test('the plate is 44% of the short edge', () {
      const plate = HhBrandLaunchPlate(screenSize: Size(360, 800));

      expect(plate.plateWidth, closeTo(360 * 0.44, 0.001));
    });

    test('a landscape surface does not push the plate past the height', () {
      // 44% of a literal 800pt width is most of a 600pt height, and the group
      // overflowed by 36pt before the short edge became the base. The product
      // is portrait-only, so this should never happen — and a launch screen
      // that overflows when it does is still a defect.
      const wide = HhBrandLaunchPlate(screenSize: Size(800, 600));

      expect(wide.plateWidth, closeTo(600 * 0.44, 0.001));
      expect(wide.plateWidth, lessThan(600 / 2));
    });
  });

  group('the launcher icons are placed by arithmetic nothing else checks', () {
    test('the adaptive foreground is centred on the 108dp layer', () {
      final box = _markBox(foreground);

      expect(box.left + box.width / 2, closeTo(54, 0.01));
      expect(box.top + box.height / 2, closeTo(54, 0.01));
    });

    test('the adaptive mark is 48% wide, not the square masks 56%', () {
      final box = _markBox(foreground);

      expect(box.width / 108, closeTo(0.48, 0.0005));
    });

    test('its diagonal clears the 66% safe zone', () {
      final box = _markBox(foreground);
      final diagonal = math.sqrt(
        box.width * box.width + box.height * box.height,
      );

      // This is the whole reason the adaptive ratio is 48% and not 56%: a
      // circular mask binds on the bounding *diagonal*, which at 23 : 19.8 is
      // 1.320 x width. At 56% that reaches 73.9% and the corners get clipped.
      expect(diagonal / 108, closeTo(0.6334, 0.001));
      expect(
        diagonal / 108,
        lessThan(0.66),
        reason: 'a circular mask would clip the corners of the arch',
      );
    });

    test('the legacy icon is centred and takes the square-mask 56%', () {
      final box = _markBox(legacy);

      expect(box.left + box.width / 2, closeTo(54, 0.01));
      expect(box.top + box.height / 2, closeTo(54, 0.01));
      // Nothing masks an API 24/25 icon to a circle, so the wider ratio applies
      // and the file draws its own plate.
      expect(box.width / 108, closeTo(0.56, 0.0005));
    });

    test('both keep the locked 23 : 19.8 aspect', () {
      for (final path in [foreground, legacy]) {
        final box = _markBox(path);
        expect(
          box.height / box.width,
          closeTo(19.8 / 23, 0.0005),
          reason: 'stretching the mark is misuse — $path',
        );
      }
    });

    test('the mark path data matches the design document exactly', () {
      // The point of carrying the crop as a transform rather than
      // pre-multiplying the coordinates: these strings can be diffed against
      // the design.
      for (final path in [foreground, legacy]) {
        final xml = File(path).readAsStringSync();
        expect(
          xml.contains(
            'M4.5 26C4.5 18.5 5.8 13.2 8.6 13.2C11.5 13.2 13.4 12.4 15.2 '
            '11.8L15.2 17.5C12.5 18.2 10.5 20.5 10.5 26Z',
          ),
          isTrue,
          reason: 'left figure altered in $path',
        );
        expect(
          xml.contains(
            'M27.5 26C27.5 18.5 26.2 13.2 23.4 13.2C20.5 13.2 18.6 12.4 16.8 '
            '11.8L16.8 17.5C19.5 18.2 21.5 20.5 21.5 26Z',
          ),
          isTrue,
          reason: 'right figure altered in $path',
        );
        // The inner group is the design's crop origin. Without it the mark sits
        // 4.5 x scale too far right and the centring assertions above are the
        // only thing that would notice.
        expect(xml.contains('android:translateX="-4.5"'), isTrue);
        expect(xml.contains('android:translateY="-6.2"'), isTrue);
      }
    });

    test('no themed-icon layer, which would close the gap between figures', () {
      // Android 13 tints a single silhouette, collapsing two figures into one
      // shape — the same failure the 20px floor exists to prevent. Absent on
      // purpose, so the launcher falls back to the full-colour icon.
      // Comments stripped first: this file's own comment explains why the
      // element is absent, and naming it there must not read as declaring it.
      // The first version of this test failed on its own documentation.
      final xml = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      ).readAsStringSync().replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

      expect(xml.contains('<monochrome'), isFalse);
      // And the two layers that must be there still are.
      expect(xml.contains('<background'), isTrue);
      expect(xml.contains('<foreground'), isTrue);
    });
  });

  group('the platform launch window matches the Flutter one', () {
    test('the launch background is the brand navy, not the default', () {
      // It was `?android:colorBackground` — white on a light device — handing
      // over to a navy Flutter splash, so every cold start flashed white.
      for (final path in [
        'android/app/src/main/res/drawable/launch_background.xml',
        'android/app/src/main/res/drawable-v21/launch_background.xml',
      ]) {
        expect(
          File(path).readAsStringSync().contains('@color/brand_navy'),
          isTrue,
          reason: path,
        );
      }
    });

    test('Android 12+ gets its own splash background', () {
      // On API 31+ the platform ignores windowBackground and draws the icon on
      // windowSplashScreenBackground instead, so the navy above would not
      // apply.
      expect(
        File('android/app/src/main/res/values-v31/styles.xml')
            .readAsStringSync()
            .contains('android:windowSplashScreenBackground'),
        isTrue,
      );
    });

    test('the brand colours agree with HhColors', () {
      final xml = File(
        'android/app/src/main/res/values/brand.xml',
      ).readAsStringSync();

      String hex(Color c) {
        final rgb = (c.toARGB32() & 0xFFFFFF)
            .toRadixString(16)
            .toUpperCase()
            .padLeft(6, '0');
        return '#FF$rgb';
      }

      // Two copies of a colour, one in Dart and one in XML, is exactly the
      // drift that shows up as a one-frame flash of the wrong navy.
      expect(xml.contains(hex(HhColors.brand900)), isTrue);
      expect(xml.contains(hex(HhColors.accent500)), isTrue);
      expect(xml.contains(hex(HhColors.surfaceMuted)), isTrue);
    });
  });
}
