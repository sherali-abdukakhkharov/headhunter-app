import 'package:flutter/widgets.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// The five semantic tones. One vocabulary, learned once, read everywhere.
enum HhTone { success, warning, error, info, neutral }

/// A status badge: **icon + word**, never colour alone.
///
/// This is the single component behind vacancy status, application stage,
/// employer verification, invitation state and complaint state. Using it
/// everywhere is what lets a user learn the vocabulary once, so prefer a new
/// named constructor here over a bespoke pill inside a feature.
///
/// The icon is not decoration. A user who cannot distinguish the tones still
/// reads the state from the glyph and the label, which is the accessibility
/// requirement the design calls out explicitly.
class HhBadge extends StatelessWidget {
  const HhBadge({
    required this.label,
    required this.tone,
    required this.iconPath,
    super.key,
  });

  /// Verified employer, approved vacancy, accepted offer.
  const HhBadge.verified({required this.label, super.key})
    : tone = HhTone.success,
      iconPath = HhIconPath.checkCircle;

  /// Under moderation, under review, pending verification.
  const HhBadge.pending({required this.label, super.key})
    : tone = HhTone.warning,
      iconPath = HhIconPath.clock;

  /// Rejected vacancy, rejected application, declined invitation.
  const HhBadge.rejected({required this.label, super.key})
    : tone = HhTone.error,
      iconPath = HhIconPath.xCircle;

  /// New application, new invitation, informational state.
  const HhBadge.info({required this.label, super.key})
    : tone = HhTone.info,
      iconPath = HhIconPath.infoCircle;

  /// Paused vacancy, closed conversation, withdrawn application.
  const HhBadge.paused({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.pause;

  /// Changes required — a warning tone with an edit glyph, because the user has
  /// something to *do* rather than something to wait for.
  const HhBadge.changesRequired({required this.label, super.key})
    : tone = HhTone.warning,
      iconPath = HhIconPath.edit;

  final String label;
  final HhTone tone;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      HhTone.success => (HhColors.successBg, HhColors.successFg),
      HhTone.warning => (HhColors.warningBg, HhColors.warningFg),
      HhTone.error => (HhColors.errorBg, HhColors.errorFg),
      HhTone.info => (HhColors.infoBg, HhColors.infoFg),
      HhTone.neutral => (HhColors.neutralBg, HhColors.neutralFg),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.only(left: 9, right: 11, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HhIcon(iconPath, size: 14, color: fg, strokeWidth: 2.2),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: HhTypography.badge.copyWith(color: fg),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A borderless "verified employer" line, as it appears in a vacancy card
/// footer: shield glyph plus words, in success green.
class HhVerifiedMark extends StatelessWidget {
  const HhVerifiedMark({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const HhIcon(
        HhIconPath.shieldCheck,
        size: 14,
        color: HhColors.successFg,
        strokeWidth: 2.2,
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: HhTypography.meta.copyWith(
          color: HhColors.successFg,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

/// Match-percentage pill on a candidate card. Success-toned because a high
/// match is good news; the number carries the meaning, so no icon is needed.
class HhMatchPill extends StatelessWidget {
  const HhMatchPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: HhColors.successBg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: HhTypography.badge.copyWith(
        fontSize: 11.5,
        color: HhColors.successFg,
      ),
    ),
  );
}
