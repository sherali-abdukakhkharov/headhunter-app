// The Google Play store assets, rendered from the real brand widgets.
//
//   flutter test test/store_assets_test.dart --dart-define=STORE_ASSETS_OUT=docs/store
//
// Without the define this file is one skipped test, which is what keeps it
// committable: it writes plain PNGs through `toImage` and never calls
// `matchesGoldenFile`, so there is no platform-specific golden for a Linux
// runner to disagree with (MEMORY.md, 2026-08-20). The assets it produces are
// committed under docs/store/ and are what gets uploaded to the Console — so
// when the brand changes, re-run this rather than editing a PNG.
//
// Two compositions, both on the design's navy:
//
// - **icon-512.png** — the mark at 56 % of the tile, the figure the design
//   states for square masks. Play applies its own rounded-square mask, not a
//   circle, so the adaptive icon's 48 % (chosen for the circle case) would be
//   needlessly small here. Full-bleed, no transparency, no rounded corners of
//   our own — Play adds those.
// - **feature-graphic-1024x500.png** — the horizontal lockup, centred, with
//   room on every side because Play crops the graphic differently per surface.
//   The name is the only text: it is a logotype and is not translated, so one
//   graphic serves all four interface variants.
@TestOn('vm')
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

const _outDir = String.fromEnvironment('STORE_ASSETS_OUT');

void main() {
  if (_outDir.isEmpty) {
    test(
      'store assets',
      () {},
      skip: 'Pass --dart-define=STORE_ASSETS_OUT=<dir> to render the Play '
          'Store assets into <dir>.',
    );
    return;
  }

  setUpAll(() async {
    // Without the real face every glyph is an Ahem box and the wordmark is a
    // row of rectangles. Same recipe as the visual harness in MEMORY.md.
    final bytes = await File('assets/fonts/GolosText-Variable.ttf')
        .readAsBytes();
    final loader = FontLoader(HhTypography.family)
      ..addFont(
        Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    await loader.load();
    Directory(_outDir).createSync(recursive: true);
  });

  testWidgets('icon 512 x 512', (tester) async {
    const side = 512.0;
    await _render(
      tester,
      const Size(side, side),
      'icon-512.png',
      const ColoredBox(
        color: HhColors.brand900,
        child: Center(
          child: HhBrandMark(
            width: side * HhBrandLaunchPlate.markFraction,
            ground: HhBrandGround.navy,
          ),
        ),
      ),
    );
  });

  testWidgets('feature graphic 1024 x 500', (tester) async {
    await _render(
      tester,
      const Size(1024, 500),
      'feature-graphic-1024x500.png',
      const ColoredBox(
        color: HhColors.brand900,
        child: Center(
          child: HhBrandLockup(ground: HhBrandGround.navy, fontSize: 112),
        ),
      ),
    );
  });
}

/// Draws [child] at exactly [size] device pixels and writes it as [fileName].
Future<void> _render(
  WidgetTester tester,
  Size size,
  String fileName,
  Widget child,
) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final key = GlobalKey();

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(key: key, child: SizedBox.expand(child: child)),
    ),
  );

  // The mark is an SVG, and flutter_svg parses it asynchronously: the first
  // frame after pumpWidget is drawn before the picture exists. Real time has
  // to pass, which only runAsync allows.
  await tester.runAsync(() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);

    expect(image.width, size.width.toInt());
    expect(image.height, size.height.toInt());

    File('$_outDir/$fileName').writeAsBytesSync(png!.buffer.asUint8List());
  });
}
