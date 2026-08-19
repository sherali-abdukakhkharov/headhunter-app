import 'package:flutter/material.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// A pill filter chip. Selected chips take the brand fill and gain a check
/// glyph — selection is never conveyed by colour alone.
///
/// Bind the chip's identity to a **dictionary ID**, never its label: the same
/// occupation carries four localized labels and one ID, and filtering on text
/// silently returns nothing in the other three interface variants.
class HhFilterChip extends StatelessWidget {
  const HhFilterChip({
    required this.label,
    required this.selected,
    super.key,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: HhRadius.pillAll,
      child: Container(
        constraints: const BoxConstraints(minHeight: HhSize.minTarget),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? HhColors.brand600 : HhColors.white,
          borderRadius: HhRadius.pillAll,
          border: selected
              ? null
              : const Border.fromBorderSide(HhBorders.control),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const HhIcon(
                HhIconPath.check,
                size: 15,
                color: HhColors.white,
                strokeWidth: 2.6,
              ),
              const SizedBox(width: 6),
            ],
            Text(label, style: HhTypography.chipLabel(selected: selected)),
          ],
        ),
      ),
    ),
  );
}

/// An applied-filter chip with a remove affordance, shown above a result list.
///
/// Tinted rather than solid so a row of applied filters does not compete with
/// the primary action.
///
/// **The label shrinks before the chip does.** A chip holds whatever a
/// dictionary or a filter group is called, and the same word is longer in
/// Russian than in English — an unconstrained `Text` in a `Row` overflows its
/// line rather than wrapping, so one long label paints a striped bar across the
/// filter row. Truncating is the only option that keeps the remove control
/// reachable, which is the part of the chip that must never be lost.
class HhRemovableChip extends StatelessWidget {
  const HhRemovableChip({
    required this.label,
    super.key,
    this.onRemove,
  });

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: HhSize.minTarget),
    padding: const EdgeInsets.only(left: 14, right: 6),
    decoration: const BoxDecoration(
      color: HhColors.brand50,
      borderRadius: HhRadius.pillAll,
      border: Border.fromBorderSide(BorderSide(color: HhColors.brand200)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HhTypography.chipLabel(
              selected: true,
            ).copyWith(color: HhColors.brand600),
          ),
        ),
        // A 44px target around a 14px glyph: the chip stays visually compact
        // while the remove control is still legal to tap.
        Semantics(
          button: true,
          label: 'Remove $label',
          child: InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: HhSize.minTarget - 8,
              height: HhSize.minTarget - 8,
              child: Center(
                child: HhIcon(
                  HhIconPath.close,
                  size: 14,
                  color: HhColors.brand600,
                  strokeWidth: 2.6,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// A small neutral metadata chip — location, shift, number of openings.
/// Not interactive.
class HhMetaChip extends StatelessWidget {
  const HhMetaChip({
    required this.label,
    super.key,
    this.iconPath,
    this.dense = false,
  });

  final String label;
  final String? iconPath;

  /// Slightly tighter, for the candidate card where three chips share a row.
  final bool dense;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: dense ? 8 : 9,
      vertical: dense ? 4 : 5,
    ),
    decoration: BoxDecoration(
      color: HhColors.fill,
      borderRadius: BorderRadius.circular(dense ? 5 : 6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconPath != null) ...[
          HhIcon(
            iconPath!,
            size: 13,
            color: HhColors.inkMuted,
            strokeWidth: 2,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: HhTypography.meta.copyWith(fontSize: dense ? 11.5 : 12),
        ),
      ],
    ),
  );
}

/// Two-or-more-way segmented control, e.g. Active / History.
class HhSegmented extends StatelessWidget {
  const HhSegmented({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: const BoxDecoration(
      color: HhColors.fillDisabled,
      borderRadius: HhRadius.buttonAll,
    ),
    child: Row(
      children: [
        for (final (i, label) in labels.indexed)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selectedIndex,
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: HhRadius.inputAll,
                child: AnimatedContainer(
                  duration: HhDuration.fast,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? HhColors.white
                        : Colors.transparent,
                    borderRadius: HhRadius.inputAll,
                    boxShadow: i == selectedIndex
                        ? const [
                            BoxShadow(
                              color: Color(0x1A0B2545),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style:
                        HhTypography.chipLabel(
                          selected: i == selectedIndex,
                        ).copyWith(
                          color: i == selectedIndex
                              ? HhColors.brand900
                              : HhColors.inkMuted,
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
