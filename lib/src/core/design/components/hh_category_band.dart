import 'package:flutter/widgets.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

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
/// **The band always renders.** When there is no photograph it keeps its full
/// height and fills with the category tint plus the category glyph and name.
/// Omitting it is the one behaviour the design calls out as breaking list
/// rhythm: card geometry must not change between the two cases, so a list with
/// mixed image coverage still scans as one rhythm.
///
/// Photography is supplied as one 3:2 master per category (1620×1080) with the
/// subject inside the middle 60% vertically, so the same file survives both the
/// card crop (4.15:1) and the detail hero crop (2.6:1).
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

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: image ?? _Fallback(category: category, label: categoryLabel),
  );
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.category, required this.label});

  final HhWorkCategory category;
  final String label;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: HhColors.brand50,
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HhIcon(
            category.iconPath,
            size: 20,
            color: HhColors.brand400,
            strokeWidth: 1.9,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: HhTypography.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HhColors.brand400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
