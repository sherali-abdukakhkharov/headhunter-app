import 'package:jobbridge_app/l10n/generated/app_l10n.dart';

/// The two reasons the **server** writes, rather than a moderator.
///
/// Kept as the wire values rather than restated, because these are what a
/// status transition actually carries — `vacancy-status.ts` on the backend
/// declares both as exported constants for the same reason.
abstract final class SystemModerationReason {
  /// BR-12: a live vacancy whose age or gender restriction was edited has not
  /// been reviewed as it now reads, so it leaves discovery until it is.
  static const restrictionChanged = 'restriction_changed_requires_review';

  /// BR-04: no moderator existed to approve it.
  static const autoApproved = 'auto_approved_no_moderator';
}

/// A moderation reason as a person should read it.
///
/// ## §2.4's verbatim rule has exactly two exceptions, and they are these
///
/// A rejection reason is an administrator's own words, in whatever language
/// they wrote them, and §2.4 forbids translating it — so almost everything that
/// arrives here is returned untouched.
///
/// But the server also writes a reason itself when nobody decided anything: a
/// restriction was edited, or BR-04 published a vacancy because no moderator
/// existed. Those are **machine codes**, and rendering them verbatim put
/// `restriction_changed_requires_review` on an employer's own vacancy card and
/// in the moderation queue (MT-012). Verbatim is a rule about *human* text; a
/// code was never human text.
///
/// Anything unrecognised falls through unchanged, which keeps the rule intact
/// for the case it exists for — and means a third system reason added
/// server-side degrades to today's behaviour rather than to a blank.
String moderationReasonText(String reason, AppL10n l10n) => switch (reason) {
  SystemModerationReason.restrictionChanged =>
    l10n.vacancyReasonRestrictionChanged,
  SystemModerationReason.autoApproved => l10n.vacancyReasonAutoApproved,
  _ => reason,
};
