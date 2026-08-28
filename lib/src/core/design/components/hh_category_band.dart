import 'package:flutter/widgets.dart';

import 'package:jobbridge_app/src/core/design/hh_category_art.dart';
import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// The five work categories of the specification (§2.1).
///
/// Each has its own photographic band; there is deliberately **no generic
/// band**. The band is the fastest signal on a scanned list, and the design's
/// position is that a generic one is worse than none.
enum HhWorkCategory {
  professional(HhIconPath.building),
  service(HhIconPath.people),
  physical(HhIconPath.tool),
  seasonal(HhIconPath.calendar),
  temporary(HhIconPath.clock);

  const HhWorkCategory(this.iconPath);

  /// Glyph shown in the no-image fallback.
  final String iconPath;
}

/// The category band at the top of a vacancy card or detail hero.
///
/// **The band always renders**, and since 2026-08-29 it always has a picture:
/// [HhCategoryArt] draws one scene per category, and [image] overrides it if a
/// photograph is ever supplied. Omitting the band is the one behaviour the
/// design calls out as breaking list rhythm — card geometry must not change
/// between the two cases, so a list with mixed coverage still scans as one
/// rhythm.
///
/// **The name is drawn over the picture**, bottom left, on a scrim. It used to
/// appear only in the tinted fallback, which meant it would have vanished the
/// moment artwork arrived — and the category is the one thing on a vacancy card
/// that nothing else says. The scrim is there so the label survives a
/// photograph as well as it survives a drawing.
///
/// Photography, if it ever comes, is one 3:2 master per category (1620×1080).
/// **The brief's "subject inside the middle 60%" is right for the hero crop
/// (2.6:1) and wrong for the card (4.15:1)**, which from a 3:2 master keeps
/// only 36% — that has to be fixed in the brief before anything is shot.
class HhCategoryBand extends StatelessWidget {
  const HhCategoryBand({
    required this.category,
    required this.categoryLabel,
    super.key,
    this.image,
    this.height = cardHeight,
  });

  /// Card band height, at full card width. Crop ratio 4.15 : 1.
  static const cardHeight = 86.0;

  /// Detail hero height at a 390pt frame. Crop ratio 2.6 : 1.
  static const heroHeight = 150.0;

  final HhWorkCategory category;

  /// Localized category name, shown only in the fallback.
  final String categoryLabel;

  /// The photograph. When null the fallback renders — never an empty box, and
  /// never a collapsed band.
  final Widget? image;

  final double height;

  /// The label's inset from the band's own edges, not the artwork's: the two
  /// crops show different parts of the drawing, and a label positioned inside
  /// the SVG would move with the crop.
  static const _labelInset = 10.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: Stack(
      fit: StackFit.expand,
      children: [
        image ?? HhCategoryArtwork(HhCategoryArt.of(category)),
        Positioned(
          left: _labelInset,
          right: _labelInset,
          bottom: 8,
          // The pill hugs its text; the `right` above only stops a long name
          // running off the band.
          child: Align(
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                // Not fully opaque: the label belongs to the picture rather
                // than sitting on top of it as a separate object.
                color: Color(0xE6FFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                child: Text(
                  categoryLabel,
                  style: HhTypography.caption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HhColors.brand900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
