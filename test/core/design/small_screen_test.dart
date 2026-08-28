/// M11's small-screen and large-font pass, as a test rather than as a walk.
///
/// ## Why a test and not a device session
///
/// "Re-check every component at large system font scale as screens land" is a
/// task nobody finishes: it has to be redone for every screen that lands after
/// it, and doing it by hand means it is done once and then decays. An overflow
/// is also exactly the kind of defect assertions miss — nothing throws, no
/// `expect` fails, and the yellow-and-black stripes only exist on a screen
/// somebody is looking at.
///
/// So this pumps the design gallery — which is the catalogue, every component
/// in one tree — on the smallest surface the product supports, at the largest
/// text scale Android offers, and fails on the overflow Flutter reports.
///
/// ## The two numbers
///
/// **320 × 568** is the floor the design names, and the working checklist's
/// nav-label entry is measured at it. **2.0** is Android's largest font
/// scale; §12.5 asks the app to survive it rather than to look identical.
///
/// ## What this does not catch
///
/// A screen assembled from components that each fit can still overflow, and a
/// component only reachable behind a provider is not in the gallery. This is
/// the component-level pass; the screen-level one needs the screens, and their
/// own tests are where it belongs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/design_gallery/presentation/design_gallery_screen.dart';

/// Runs [body] and returns every layout overflow Flutter reported.
///
/// `FlutterError.onError` rather than `tester.takeException()`: an overflow is
/// reported as an error but does not throw, so the pump completes and the test
/// passes with the stripes painted. Collecting them is the only way to see one
/// without looking at a picture.
Future<List<String>> overflowsDuring(Future<void> Function() body) async {
  final overflows = <String>[];
  final previous = FlutterError.onError;

  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed')) {
      overflows.add(text.split('\n').first);
      return;
    }
    previous?.call(details);
  };

  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }

  return overflows;
}

void main() {
  /// The floor the design names, and Android's largest accessibility scale.
  const smallest = Size(320, 568);
  const largestText = 2.0;

  Future<List<String>> pumpGallery(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required Locale locale,
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    return overflowsDuring(() async {
      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          child: MaterialApp(
            theme: HhTheme.light,
            locale: locale,
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              minScaleFactor: textScale,
              maxScaleFactor: textScale,
              child: child!,
            ),
            home: const DesignGalleryScreen(),
          ),
        ),
      );

      // `pump`, not `pumpAndSettle`: the gallery holds indeterminate
      // progress indicators, which never settle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  }

  testWidgets('the catalogue fits the smallest screen', (tester) async {
    final overflows = await pumpGallery(
      tester,
      size: smallest,
      textScale: 1,
      locale: const Locale('en'),
    );

    expect(overflows, isEmpty, reason: overflows.join('\n'));
  });

  testWidgets('the catalogue survives the largest font scale', (tester) async {
    final overflows = await pumpGallery(
      tester,
      size: smallest,
      textScale: largestText,
      locale: const Locale('en'),
    );

    expect(overflows, isEmpty, reason: overflows.join('\n'));
  });

  testWidgets('and survives it in Russian, which is the longest', (
    tester,
  ) async {
    // The variant that finds these. `HhMetaChip` shipped without an ellipsis
    // because everything using it was one word in English and three in
    // Russian — English fitted, so nothing was ever red.
    final overflows = await pumpGallery(
      tester,
      size: smallest,
      textScale: largestText,
      locale: const Locale('ru'),
    );

    expect(overflows, isEmpty, reason: overflows.join('\n'));
  });
}
