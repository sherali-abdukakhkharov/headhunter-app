import 'package:flutter/widgets.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// The five semantic tones.
///
/// The tone answers **"whose turn is it, and did it end well?"** — not "what
/// kind of thing is this". Design round 1 gave the rule that generates every
/// state in the product:
///
/// | Tone | Meaning |
/// |---|---|
/// | [info] | In motion. Progressing normally, nobody needs to do anything. |
/// | [warning] | Waiting on a person. The word says who — you or a reviewer. |
/// | [success] | Resolved well. Not reserved for verification. |
/// | [error] | Resolved badly, for the person reading it. |
/// | [neutral] | Out of motion. Nobody's turn, no outcome. |
enum HhTone { success, warning, error, info, neutral }

/// A status badge: **icon + word**, never colour alone.
///
/// One component behind vacancy, application and verification state. Use a
/// named constructor — they *are* the vocabulary, and inventing a badge inline
/// is how the vocabulary stops being learnable.
///
/// ## The glyph rule
///
/// Within one object type **no glyph ever repeats**, so tone never has to carry
/// the distinction alone. Across object types **the same glyph always means the
/// same thing**:
///
/// - **shield** — an identity was checked
/// - **check-circle** — a person was accepted
/// - **clock** — a reviewer holds it
/// - **pencil** — you can still edit it
/// - **lock** — the object is finished and read-only
/// - **eye** — visible / has been seen
/// - **x-circle** — negative outcome, reason always attached
///
/// That is why *hired* and *verified* can share green: one is a check-circle on
/// a person, the other a shield on an organisation.
///
/// Labels are always passed in, never hardcoded — they come from the
/// localization layer, and the same state reads in four interface variants.
class HhBadge extends StatelessWidget {
  const HhBadge({
    required this.label,
    required this.tone,
    required this.iconPath,
    super.key,
  });

  // --- Vacancy · Vakansiya (6 states) --------------------------------------

  /// Draft — yours, still editable.
  ///
  /// **Employer-list only.** A draft is never visible to a candidate, so this
  /// badge must not appear on any candidate-facing surface.
  const HhBadge.vacancyDraft({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.edit;

  /// Under moderation — a moderator holds it.
  const HhBadge.vacancyModeration({required this.label, super.key})
    : tone = HhTone.warning,
      iconPath = HhIconPath.clock;

  /// Active — live and visible.
  ///
  /// Success-toned: green is **not** reserved for verification; the glyph
  /// disambiguates. **Employer-list only** — for a candidate a live vacancy is
  /// the default, and badging it adds noise to every card.
  const HhBadge.vacancyActive({required this.label, super.key})
    : tone = HhTone.success,
      iconPath = HhIconPath.eye;

  /// Paused — *the employer* stopped it, and can restart it.
  const HhBadge.vacancyPaused({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.pause;

  /// Closed — finished, read-only.
  const HhBadge.vacancyClosed({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.lock;

  /// Rejected by moderation. A reason is always shown alongside.
  const HhBadge.vacancyRejected({required this.label, super.key})
    : tone = HhTone.error,
      iconPath = HhIconPath.xCircle;

  // --- Application · Ariza (9 states) --------------------------------------

  /// Submitted — sent, not yet opened.
  const HhBadge.applicationSubmitted({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.send;

  /// Viewed by the employer.
  const HhBadge.applicationViewed({required this.label, super.key})
    : tone = HhTone.info,
      iconPath = HhIconPath.eye;

  /// Shortlisted.
  const HhBadge.applicationShortlisted({required this.label, super.key})
    : tone = HhTone.info,
      iconPath = HhIconPath.bookmark;

  /// Interview scheduled. The date lives in the card body, not the badge.
  const HhBadge.applicationInterview({required this.label, super.key})
    : tone = HhTone.info,
      iconPath = HhIconPath.people;

  /// Offer extended — **warning, because it waits on the candidate.**
  ///
  /// Changed from success in design round 1: success ("resolved well") told the
  /// candidate the matter was settled when the response deadline was in fact
  /// theirs to meet.
  const HhBadge.applicationOffer({required this.label, super.key})
    : tone = HhTone.warning,
      iconPath = HhIconPath.document;

  /// Hired — a **person** was accepted.
  const HhBadge.applicationHired({required this.label, super.key})
    : tone = HhTone.success,
      iconPath = HhIconPath.checkCircle;

  /// Rejected.
  const HhBadge.applicationRejected({required this.label, super.key})
    : tone = HhTone.error,
      iconPath = HhIconPath.xCircle;

  /// Withdrawn — **the candidate** stopped it.
  const HhBadge.applicationWithdrawn({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.arrowLeft;

  /// The vacancy closed underneath the application. Same lock as a closed
  /// vacancy, because it is the same fact.
  const HhBadge.applicationVacancyClosed({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.lock;

  // --- Verification · Tasdiqlash (5 states) --------------------------------

  /// Not submitted.
  const HhBadge.verificationNotSubmitted({required this.label, super.key})
    : tone = HhTone.neutral,
      iconPath = HhIconPath.upload;

  /// Under review — same clock as vacancy moderation, because it is the same
  /// fact: a reviewer holds it.
  const HhBadge.verificationUnderReview({required this.label, super.key})
    : tone = HhTone.warning,
      iconPath = HhIconPath.clock;

  /// Verified — an **organisation** was checked.
  const HhBadge.verificationVerified({required this.label, super.key})
    : tone = HhTone.success,
      iconPath = HhIconPath.shieldCheck;

  /// Verification rejected.
  const HhBadge.verificationRejected({required this.label, super.key})
    : tone = HhTone.error,
      iconPath = HhIconPath.xCircle;

  /// Changes required — same pencil as draft, because it is the same fact:
  /// yours to edit.
  const HhBadge.verificationChangesRequired({required this.label, super.key})
    : tone = HhTone.warning,
      iconPath = HhIconPath.edit;

  final String label;
  final HhTone tone;
  final String iconPath;

  /// Background / foreground pair for a tone.
  static (Color bg, Color fg) colorsFor(HhTone tone) => switch (tone) {
    HhTone.success => (HhColors.successBg, HhColors.successFg),
    HhTone.warning => (HhColors.warningBg, HhColors.warningFg),
    HhTone.error => (HhColors.errorBg, HhColors.errorFg),
    HhTone.info => (HhColors.infoBg, HhColors.infoFg),
    HhTone.neutral => (HhColors.neutralBg, HhColors.neutralFg),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = colorsFor(tone);

    return Semantics(
      label: label,
      child: Container(
        // Geometry fixed by the design: 6/10/6/8 padding, radius 7, gap 5,
        // icon 13 at stroke 2.2, label 600/12.
        padding: const EdgeInsets.only(left: 8, right: 10, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              // Keeps the glyph on the first line's optical centre when the
              // label wraps.
              padding: const EdgeInsets.only(top: 1),
              child: HhIcon(iconPath, size: 13, color: fg, strokeWidth: 2.2),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: HhTypography.badge.copyWith(fontSize: 12, color: fg),
                // Wraps to two lines rather than truncating: icon and word
                // never separate, and a clipped status word is unreadable.
                maxLines: 2,
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
///
/// Same shield as [HhBadge.verificationVerified] — an identity was checked.
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
      Flexible(
        child: Text(
          label,
          style: HhTypography.meta.copyWith(
            color: HhColors.successFg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

/// Match-percentage pill on a candidate card. Success-toned because a high
/// match is good news; the number carries the meaning, so no glyph is needed.
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
