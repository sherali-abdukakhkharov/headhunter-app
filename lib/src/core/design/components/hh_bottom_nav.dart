import 'package:flutter/material.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// One bottom-navigation destination.
@immutable
class HhNavItem {
  const HhNavItem({
    required this.iconPath,
    required this.label,
  });

  final String iconPath;

  /// Localized label. Always shown — the design never uses icon-only tabs.
  final String label;
}

/// Bottom navigation, at most five destinations, **icon + label always**.
///
/// The design specifies three configurations — candidate, employer,
/// administrator — supplied as [items] rather than baked in, because the active
/// role decides them at runtime and one account may hold several roles.
///
/// ## Constant height, by design
///
/// The bar **reserves two label lines always**, giving a constant [height] of
/// 70pt across all three roles and all four interface variants. A bar that
/// changed height when the user switched role would read as a layout bug, and
/// it would move the safe-area inset under it.
///
/// Box model above the safe-area inset:
///
/// ```text
/// 8 top + 22 icon + 4 gap + 25 label box + 10 bottom + 1 hairline = 70
/// ```
///
/// The label box is a hard height with `overflow: hidden`, **top-aligned** so a
/// one-line label sits tight under its icon rather than floating. The clamp is
/// deliberate: **no string can ever grow the bar.** Where a label would need a
/// third line, shorten the *string* or give it a soft hyphen — see
/// [hhSoftHyphenate] — never the box.
class HhBottomNav extends StatelessWidget {
  const HhBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  /// Bar height above the safe-area inset. Constant across roles and languages.
  static const height = 70.0;

  static const _paddingTop = 8.0;
  static const _iconSize = 22.0;
  static const _iconLabelGap = 4.0;
  static const _labelBox = 25.0;

  // The box model's 1pt hairline is drawn by the top border, not padding.
  static const _paddingBottom = 10.0;

  final List<HhNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    assert(
      items.length <= 5,
      'The design caps bottom navigation at five destinations; '
      'got ${items.length}.',
    );

    // Reconciling the two rules the design states about this bar:
    //
    // - §6: "no string can ever grow the bar" — a hard 25pt box with overflow
    //   hidden, so the bar totals exactly 70 whatever the labels say.
    // - §3: bottom-nav icons stay fixed, "only labels scale, and the bar grows
    //   with them."
    //
    // Both hold if the clamp applies at the default scale and relaxes above
    // it: at 1x the box is exactly 25 (bar = 70) and a long string is clipped
    // to two lines; above 1x the lines lay out at their true height so the bar
    // grows and nothing is cut. Either way `maxLines: 2` means no string can
    // grow the bar beyond two lines.
    //
    // Not simply `scale(25)`: two lines at 10.5/1.2 is 25.2pt, which the design
    // rounds down to land on 70, and Golos's own line metrics add a little
    // more. Multiplied up, both round-downs start cutting descenders.
    final clampLabelBox = MediaQuery.textScalerOf(context).scale(1) <= 1.0;

    // Container, not DecoratedBox: the box model counts the 1pt hairline as
    // part of the 70, and only a Container border insets its child. A
    // DecoratedBox paints the border without occupying space, measuring 69.
    return Container(
      decoration: const BoxDecoration(
        color: HhColors.white,
        border: Border(top: HhBorders.card),
        boxShadow: HhElevation.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: _paddingTop,
            bottom: _paddingBottom,
            left: 4,
            right: 4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: _NavTab(
                    item: item,
                    selected: i == currentIndex,
                    clampLabelBox: clampLabelBox,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.clampLabelBox,
    required this.onTap,
  });

  final HhNavItem item;
  final bool selected;

  /// Whether to hard-clamp the label box to its reserved height. True at the
  /// default text scale, false above it — see [HhBottomNav.build].
  final bool clampLabelBox;

  final VoidCallback onTap;

  Widget _label() => Text(
    item.label,
    style: HhTypography.navLabel(selected: selected),
    textAlign: TextAlign.center,
    maxLines: 2,
  );

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: item.label,
    child: InkWell(
      onTap: onTap,
      borderRadius: HhRadius.inputAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: HhIcon(
                item.iconPath,
                size: HhBottomNav._iconSize,
                color: selected ? HhColors.brand600 : HhColors.inkSubtle,
                active: selected,
              ),
            ),
            const SizedBox(height: HhBottomNav._iconLabelGap),
            if (clampLabelBox)
              SizedBox(
                height: HhBottomNav._labelBox,
                child: ClipRect(
                  child: Align(
                    // Top-aligned so a one-line label sits tight under its
                    // icon rather than floating in the reserved box.
                    alignment: Alignment.topCenter,
                    child: _label(),
                  ),
                ),
              )
            else
              _label(),
          ],
        ),
      ),
    ),
  );
}

/// Inserts a soft hyphen (`U+00AD`) after [afterPrefix] so a long nav label
/// breaks at a chosen point instead of overflowing its reserved box.
///
/// The design's worked example: `Фойдаланувчилар` needs three lines at 390pt
/// with no break hint, so it ships as `Фойдалан\u00ADувчилар`, which lands in two
/// lines at every supported width. Prefer shortening the string; reach for this
/// when the word genuinely cannot be shortened.
String hhSoftHyphenate(String label, {required String afterPrefix}) {
  if (!label.startsWith(afterPrefix) || label == afterPrefix) return label;
  return '$afterPrefix\u00AD${label.substring(afterPrefix.length)}';
}

/// The three destination sets from the design.
///
/// Labels must come from the localization layer at call time, so these are
/// functions of the already-translated strings rather than constants.
abstract final class HhNavSets {
  static List<HhNavItem> candidate({
    required String home,
    required String vacancies,
    required String applications,
    required String messages,
    required String profile,
  }) => [
    HhNavItem(iconPath: HhIconPath.home, label: home),
    HhNavItem(iconPath: HhIconPath.briefcase, label: vacancies),
    HhNavItem(iconPath: HhIconPath.document, label: applications),
    HhNavItem(iconPath: HhIconPath.chat, label: messages),
    HhNavItem(iconPath: HhIconPath.person, label: profile),
  ];

  static List<HhNavItem> employer({
    required String home,
    required String vacancies,
    required String candidates,
    required String messages,
    required String company,
  }) => [
    HhNavItem(iconPath: HhIconPath.home, label: home),
    HhNavItem(iconPath: HhIconPath.briefcase, label: vacancies),
    HhNavItem(iconPath: HhIconPath.people, label: candidates),
    HhNavItem(iconPath: HhIconPath.chat, label: messages),
    HhNavItem(iconPath: HhIconPath.building, label: company),
  ];

  static List<HhNavItem> admin({
    required String dashboard,
    required String queue,
    required String complaints,
    required String users,
    required String dictionaries,
  }) => [
    HhNavItem(iconPath: HhIconPath.home, label: dashboard),
    HhNavItem(iconPath: HhIconPath.shieldCheck, label: queue),
    HhNavItem(iconPath: HhIconPath.alertTriangle, label: complaints),
    HhNavItem(iconPath: HhIconPath.people, label: users),
    HhNavItem(iconPath: HhIconPath.dictionary, label: dictionaries),
  ];
}
