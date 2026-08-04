import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// The button variants drawn in the design.
enum HhButtonVariant {
  /// Solid brand fill. One primary action per screen.
  primary,

  /// Tinted fill with a light border. Secondary action alongside a primary.
  secondary,

  /// White with a grey border. Neutral actions like "Add".
  tertiary,

  /// White with a red border and red label. Deletions.
  destructive,

  /// No container at all. Skip links and "I'll fill this in later".
  text,
}

/// A button at the design's single control height.
///
/// **Full-width by default, never fixed-width.** Cyrillic labels run roughly
/// 30% longer than their Latin equivalents, so a width that fits
/// "Davom etish" will clip "Продолжить". Pass `expand: false` only inside a
/// row where the parent already constrains the width.
///
/// Pass [loading] rather than swapping the label yourself: it keeps the
/// button's footprint identical while disabling the tap, so the layout does not
/// jump and a double-submit is impossible.
class HhButton extends StatelessWidget {
  const HhButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = HhButtonVariant.primary,
    this.iconPath,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  });

  const HhButton.secondary({
    required this.label,
    super.key,
    this.onPressed,
    this.iconPath,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  }) : variant = HhButtonVariant.secondary;

  const HhButton.tertiary({
    required this.label,
    super.key,
    this.onPressed,
    this.iconPath,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  }) : variant = HhButtonVariant.tertiary;

  const HhButton.destructive({
    required this.label,
    super.key,
    this.onPressed,
    this.iconPath,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  }) : variant = HhButtonVariant.destructive;

  const HhButton.text({
    required this.label,
    super.key,
    this.onPressed,
    this.iconPath,
    this.expand = false,
  }) : variant = HhButtonVariant.text,
       loading = false,
       compact = false;

  final String label;
  final VoidCallback? onPressed;
  final HhButtonVariant variant;

  /// Optional leading glyph, from [HhIconPath].
  final String? iconPath;

  /// Shows a spinner and blocks input, without changing the button's size.
  final bool loading;

  /// Stretch to the available width. Default true — see the class doc.
  final bool expand;

  /// Use the 44px height. Only for in-card actions, never a primary form
  /// action.
  final bool compact;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final height = compact ? HhSize.controlCompact : HhSize.control;

    if (variant == HhButtonVariant.text) {
      return _TextButtonBody(
        label: label,
        iconPath: iconPath,
        onPressed: onPressed,
        expand: expand,
      );
    }

    final style = _resolveStyle();

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: style.foreground,
              backgroundColor: style.foreground.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 9),
        ] else if (iconPath != null) ...[
          HhIcon(
            iconPath!,
            size: 19,
            color: style.foreground,
            strokeWidth: 1.9,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: HhTypography.bodyStrong.copyWith(color: style.foreground),
            textAlign: TextAlign.center,
            // Deliberately no maxLines/ellipsis: §08.2 says the box grows with
            // the label and never clips it. Truncating a Cyrillic label — ~30%
            // longer than its Latin equivalent — is the failure this prevents.
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: Material(
        color: style.background,
        // `shape` only — Material asserts if both `shape` and `borderRadius`
        // are supplied, so the radius travels inside the shape.
        shape: RoundedRectangleBorder(
          borderRadius: HhRadius.buttonAll,
          side: style.border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: HhRadius.buttonAll,
          focusColor: HhColors.brand600.withValues(alpha: 0.12),
          child: Container(
            // minHeight, not height: the design's §08.2 answer is that the box
            // grows with the label and never clips it, so at large system font
            // scales the control gets taller rather than truncating.
            constraints: BoxConstraints(minHeight: height),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 6,
            ),
            // No `alignment` at all. A Container with an alignment expands to
            // the largest size its constraints allow — which stretched an
            // auto-width button horizontally, and once the fixed height became
            // a minHeight, stretched it to the full viewport vertically too.
            // The Row centres the label on both axes instead.
            child: child,
          ),
        ),
      ),
    );
  }

  _ButtonStyle _resolveStyle() {
    if (!_enabled && !loading) {
      return const _ButtonStyle(
        background: HhColors.fillDisabled,
        foreground: HhColors.inkDisabled,
      );
    }

    return switch (variant) {
      HhButtonVariant.primary => _ButtonStyle(
        // Loading keeps the brand fill but dims it, so the button reads as
        // busy rather than disabled.
        background: loading
            ? HhColors.brand600.withValues(alpha: 0.75)
            : HhColors.brand600,
        foreground: HhColors.white,
      ),
      HhButtonVariant.secondary => const _ButtonStyle(
        background: HhColors.brand50,
        foreground: HhColors.brand600,
        border: BorderSide(color: HhColors.brand200),
      ),
      HhButtonVariant.tertiary => const _ButtonStyle(
        background: HhColors.white,
        foreground: HhColors.ink,
        border: HhBorders.control,
      ),
      HhButtonVariant.destructive => const _ButtonStyle(
        background: HhColors.white,
        foreground: HhColors.error,
        border: BorderSide(color: HhColors.errorBorder, width: 1.5),
      ),
      HhButtonVariant.text => const _ButtonStyle(
        background: HhColors.white,
        foreground: HhColors.brand600,
      ),
    };
  }
}

@immutable
class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final BorderSide? border;
}

class _TextButtonBody extends StatelessWidget {
  const _TextButtonBody({
    required this.label,
    required this.iconPath,
    required this.onPressed,
    required this.expand,
  });

  final String label;
  final String? iconPath;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colour = onPressed == null ? HhColors.inkDisabled : HhColors.brand600;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: HhRadius.buttonAll,
        child: Container(
          // 44 keeps the touch target legal even though there is no fill, and
          // stays a minimum so the label can grow with the text scale.
          constraints: const BoxConstraints(minHeight: HhSize.minTarget),
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: HhSpace.md,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null) ...[
                HhIcon(iconPath!, size: 19, color: colour, strokeWidth: 1.9),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: HhTypography.bodyStrong.copyWith(color: colour),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
