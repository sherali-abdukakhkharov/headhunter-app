import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';

/// The word for one of §8.2's four invitation statuses.
///
/// Separate from [invitationStatusBadge] for the same reason `stageLabel` is
/// separate from `stageBadge`: the response buttons and the §7.4 counts need
/// the word without the badge, and two spellings of one status is how a
/// vocabulary stops being one.
String invitationStatusLabel(String status, AppL10n l10n) => switch (status) {
  InvitationStatus.detailsRequested => l10n.invitationDetailsRequested,
  InvitationStatus.accepted => l10n.invitationAccepted,
  InvitationStatus.declined => l10n.invitationDeclined,
  _ => l10n.invitationSent,
};

/// The badge for one of §8.2's four invitation statuses.
///
/// An unrecognised status falls back to `sent` rather than throwing — the same
/// rule as an unknown application stage or schema field kind. `sent` is the
/// right fallback specifically because it is the *pre-answer* state: a status
/// this app has never heard of is one it cannot claim was an answer.
/// [received] is the candidate's side of the same invitation.
///
/// §8.2's `sent` is an **employer-side event verb**, and on the candidate's
/// inbox it reads as though they sent something — at the one moment the card
/// exists to ask them for an answer. Same status, same badge vocabulary, and
/// the word that is true where it is being read. Nothing else differs: an
/// accepted invitation is accepted from both sides.
Widget invitationStatusBadge(
  String status,
  AppL10n l10n, {
  bool received = false,
}) => switch (status) {
  InvitationStatus.detailsRequested => HhBadge.invitationDetailsRequested(
    label: l10n.invitationDetailsRequested,
  ),
  InvitationStatus.accepted => HhBadge.invitationAccepted(
    label: l10n.invitationAccepted,
  ),
  InvitationStatus.declined => HhBadge.invitationDeclined(
    label: l10n.invitationDeclined,
  ),
  _ => HhBadge.invitationSent(
    label: received ? l10n.invitationAwaitingYou : l10n.invitationSent,
  ),
};

/// The button label for one of §8.2's three candidate responses.
///
/// A verb, where [invitationStatusLabel] is a state: "Accept" is an action the
/// candidate takes, "Accepted" is what the invitation then is. Sharing one
/// string for both would put a past participle on a button.
String invitationResponseLabel(String status, AppL10n l10n) => switch (status) {
  InvitationStatus.accepted => l10n.invitationAccept,
  InvitationStatus.declined => l10n.invitationDecline,
  _ => l10n.invitationRequestDetails,
};
