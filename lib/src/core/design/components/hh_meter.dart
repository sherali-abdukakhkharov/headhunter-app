import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// One filled stretch of an [HhMeter], and the word that explains it.
@immutable
class HhMeterSegment {
  const HhMeterSegment({
    required this.value,
    required this.color,
    required this.label,
  });

  /// Counted in the same unit as the meter's total — people, not percentages.
  /// The meter does the arithmetic so no two call sites can round differently.
  final int value;

  final Color color;

  /// Shown in the legend beside a swatch of [color]. Include the figure: the
  /// swatch says *which* segment and the label has to say **how many**, because
  /// a bar 8pt tall cannot be read off.
  final String label;
}

/// A segmented progress meter with a legend (§6.2's hiring progress).
///
/// ## Why the legend is not optional
///
/// The design's own rule is that status is never colour alone, and a stacked
/// bar is colour alone by construction: three lengths in three hues and nothing
/// else. So the legend carries a swatch **and** a word **and** the figure, and
/// there is no constructor that omits it.
///
/// ## The remainder is drawn by not drawing it
///
/// Segments fill from the left and whatever is left of [total] stays as track.
/// That is why the widget takes a total rather than fractions: "7 of 20 hired"
/// is the fact, and a caller converting it to 0.35 first is a caller that can
/// disagree with the label printed beside it.
///
/// Segments that overflow the total are **clamped together rather than
/// individually**, so a server that reports more hires than openings — which
/// §6.5 allows, since `worker_count` is a target rather than a cap — renders a
/// full bar in the right proportions instead of one segment eating the other.
class HhMeter extends StatelessWidget {
  const HhMeter({
    required this.total,
    required this.segments,
    super.key,
    this.remainderLabel,
  });

  /// The denominator. Zero or less draws an empty track: a vacancy need not
  /// state a worker count (§6.5), and inventing a denominator would be
  /// inventing a target.
  final int total;

  final List<HhMeterSegment> segments;

  /// Legend entry for the unfilled remainder, where one is worth naming.
  final String? remainderLabel;

  static const _height = 8.0;
  static const _swatch = 8.0;

  int get _filled => segments.fold(0, (sum, s) => sum + s.value);

  /// What is left of [total]. Never negative.
  int get remaining => total <= 0 ? 0 : (total - _filled).clamp(0, total);

  @override
  Widget build(BuildContext context) {
    // One scale for every segment, so an overflow shortens them in proportion
    // rather than letting the first one consume the bar.
    final overflow = total > 0 && _filled > total ? total / _filled : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: HhRadius.pillAll,
          child: SizedBox(
            height: _height,
            child: Stack(
              children: [
                const ColoredBox(
                  color: HhColors.fillDisabled,
                  child: SizedBox(width: double.infinity, height: _height),
                ),
                if (total > 0)
                  Row(
                    children: [
                      for (final segment in segments)
                        Expanded(
                          // Scaled to thousandths so `flex` — an int — keeps
                          // the proportions of small counts. Two hires against
                          // twenty openings is 100 against 800, not 0 or 1.
                          flex: (segment.value * overflow * 1000).round(),
                          child: ColoredBox(color: segment.color),
                        ),
                      // The track showing through *is* the remainder, so it
                      // takes the leftover flex rather than being painted.
                      Expanded(
                        flex: remaining * 1000,
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: HhSpace.sm),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            for (final segment in segments)
              _LegendEntry(color: segment.color, label: segment.label),
            if (remainderLabel case final label?)
              _LegendEntry(color: HhColors.fillDisabled, label: label),
          ],
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: HhMeter._swatch,
        height: HhMeter._swatch,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: HhTypography.meta.copyWith(
          fontSize: 11.5,
          color: HhColors.inkMuted,
        ),
      ),
    ],
  );
}
