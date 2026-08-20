import 'package:flutter/material.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// A checkbox with its label, as one tappable row.
///
/// The whole row is the target, not just the 22px box — on a phone, hitting a
/// 22px square is a miss waiting to happen.
class HhCheckboxRow extends StatelessWidget {
  const HhCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => _SelectionRow(
    label: label,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    semantics: (checked: value, inMutuallyExclusiveGroup: false),
    control: AnimatedContainer(
      duration: HhDuration.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? HhColors.brand600 : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: value
            ? null
            : Border.all(color: HhColors.controlOutline, width: 1.8),
      ),
      child: value
          ? const Center(
              child: HhIcon(
                HhIconPath.check,
                size: 14,
                color: HhColors.white,
                strokeWidth: 3,
              ),
            )
          : null,
    ),
  );
}

/// A radio option with its label, as one tappable row.
///
/// The selected state is drawn as a thick ring rather than a dot-in-circle,
/// matching the design.
class HhRadioRow<T> extends StatelessWidget {
  const HhRadioRow({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return _SelectionRow(
      label: label,
      onTap: onChanged == null ? null : () => onChanged!(value),
      semantics: (checked: selected, inMutuallyExclusiveGroup: true),
      control: AnimatedContainer(
        duration: HhDuration.fast,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? HhColors.brand600 : HhColors.controlOutline,
            width: selected ? 6.5 : 1.8,
          ),
        ),
      ),
    );
  }
}

/// A labelled switch row — label left, switch right.
///
/// Used for candidate search visibility, notification categories, and any other
/// on/off preference.
class HhSwitchRow extends StatelessWidget {
  const HhSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.description,
  });

  final String label;

  /// Optional second line explaining the consequence of the switch. Worth
  /// filling in for anything privacy-related.
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    label: label,
    child: InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Container(
        constraints: const BoxConstraints(minHeight: HhSize.minTarget),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: HhTypography.body.copyWith(
                      fontSize: 14.5,
                      color: HhColors.brand900,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(description!, style: HhTypography.caption),
                  ],
                ],
              ),
            ),
            const SizedBox(width: HhSpace.md),
            ExcludeSemantics(
              child: AnimatedContainer(
                duration: HhDuration.fast,
                width: 46,
                height: 27,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: value ? HhColors.brand600 : HhColors.controlOutline,
                  borderRadius: HhRadius.pillAll,
                ),
                child: Align(
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 21,
                    height: 21,
                    decoration: const BoxDecoration(
                      color: HhColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shared layout for checkbox and radio rows.
class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.control,
    required this.onTap,
    required this.semantics,
  });

  final String label;
  final Widget control;
  final VoidCallback? onTap;
  final ({bool checked, bool inMutuallyExclusiveGroup}) semantics;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: semantics.checked,
    inMutuallyExclusiveGroup: semantics.inMutuallyExclusiveGroup,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: HhSize.minTarget),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ExcludeSemantics(child: control),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: HhTypography.body.copyWith(
                  fontSize: 14.5,
                  color: HhColors.brand900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
