import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// Step indicator for a multi-step flow: "Step 4 / 9" with the section name and
/// a progress bar.
///
/// Candidate onboarding is nine steps, so telling the user where they are is
/// not optional: an unbounded form is the commonest reason people abandon one.
class HhStepIndicator extends StatelessWidget {
  const HhStepIndicator({
    required this.step,
    required this.total,
    required this.stepLabel,
    required this.sectionName,
    super.key,
  });

  /// 1-based current step.
  final int step;
  final int total;

  /// Localized "Step 4 / 9" text. Built by the caller because pluralisation and
  /// word order differ across the four interface variants.
  final String stepLabel;

  /// Name of the current section, shown on the right.
  final String sectionName;

  @override
  Widget build(BuildContext context) {
    final progress = (step / total).clamp(0.0, 1.0);

    return Semantics(
      label: '$stepLabel, $sectionName',
      value: '${(progress * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepLabel,
                style: HhTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: HhColors.brand900,
                ),
              ),
              Flexible(
                child: Text(
                  sectionName,
                  style: HhTypography.caption,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: HhSpace.sm),
          ClipRRect(
            borderRadius: HhRadius.pillAll,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: HhColors.borderSubtle,
              color: HhColors.brand600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Completeness ring: percentage inside, caption beside it.
///
/// The caption should name what is *missing*, not restate the number — the
/// number is already in the ring, and "CV and language level remaining" is what
/// actually moves someone to finish.
class HhCompletenessRing extends StatelessWidget {
  const HhCompletenessRing({
    required this.percent,
    required this.title,
    super.key,
    this.subtitle,
    this.diameter = 56,
    this.surfaceColor = HhColors.white,
  });

  /// 0-100.
  final int percent;
  final String title;
  final String? subtitle;
  final double diameter;

  /// Colour of the ring's inner disc — set this to the surface the ring sits on
  /// so the hole reads as transparent.
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) => Semantics(
    label: title,
    value: '$percent%',
    child: Row(
      children: [
        SizedBox(
          width: diameter,
          height: diameter,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: (percent / 100).clamp(0.0, 1.0),
              surfaceColor: surfaceColor,
            ),
            child: Center(
              child: Text(
                '$percent%',
                style: HhTypography.badge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HhColors.brand900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: HhTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HhColors.brand900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: HhTypography.caption),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.surfaceColor});

  final double fraction;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final centre = rect.center;
    final radius = size.shortestSide / 2;

    canvas
      ..drawCircle(
        centre,
        radius,
        Paint()..color = HhColors.borderSubtle,
      )
      // Sweep from 12 o'clock clockwise, matching the design's conic gradient.
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        true,
        Paint()..color = HhColors.brand600,
      )
      // Punch the hole with the surface colour rather than a blend mode, so the
      // ring composites correctly inside any parent.
      ..drawCircle(
        centre,
        radius * 0.75,
        Paint()..color = surfaceColor,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.surfaceColor != surfaceColor;
}

/// Horizontal hiring-stage timeline: completed, current, and upcoming stages
/// with their labels underneath.
///
/// The current stage is drawn larger with a halo so it is findable at a glance
/// without relying on colour alone.
class HhStageTimeline extends StatelessWidget {
  const HhStageTimeline({
    required this.stages,
    required this.currentIndex,
    super.key,
  });

  /// Localized stage names, in order.
  final List<String> stages;

  /// 0-based index of the active stage.
  final int currentIndex;

  @override
  Widget build(BuildContext context) => Semantics(
    label: stages.isEmpty
        ? null
        : stages[currentIndex.clamp(0, stages.length - 1)],
    child: Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < stages.length; i++) ...[
              _dot(i),
              if (i != stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < currentIndex
                        ? (i == currentIndex - 1
                              ? HhColors.brand600
                              : HhColors.success)
                        : HhColors.borderSubtle,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final (i, name) in stages.indexed)
              Flexible(
                child: Text(
                  name,
                  style: HhTypography.meta.copyWith(
                    fontSize: 10.5,
                    color: i == currentIndex
                        ? HhColors.brand600
                        : HhColors.inkSubtle,
                    fontWeight: i == currentIndex
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  textAlign: i == 0
                      ? TextAlign.start
                      : (i == stages.length - 1
                            ? TextAlign.end
                            : TextAlign.center),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _dot(int i) {
    if (i == currentIndex) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: HhColors.brand600,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: HhColors.brand200, spreadRadius: 3),
          ],
        ),
      );
    }

    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: i < currentIndex ? HhColors.success : HhColors.borderSubtle,
        shape: BoxShape.circle,
      ),
    );
  }
}
