import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';

/// The word for one of §8.3's four interview statuses.
///
/// Separate from [interviewStatusBadge] for the same reason the application
/// stage's is: a label is needed without a badge — in a sheet's title, in a
/// history row — and two spellings of one status is how a vocabulary stops
/// being one.
String interviewStatusLabel(String status, AppL10n l10n) => switch (status) {
  InterviewStatus.confirmed => l10n.interviewStatusConfirmed,
  InterviewStatus.rescheduleRequested =>
    l10n.interviewStatusRescheduleRequested,
  InterviewStatus.cancelled => l10n.interviewStatusCancelled,
  _ => l10n.interviewStatusScheduled,
};

/// The badge for one of §8.3's four interview statuses.
///
/// An unrecognised status falls back to `scheduled` rather than throwing — the
/// same rule as the application stage and the invitation status. A newer server
/// adding a fifth state should read as "there is an interview" rather than
/// crash the list.
Widget interviewStatusBadge(String status, AppL10n l10n) => switch (status) {
  InterviewStatus.confirmed => HhBadge.interviewConfirmed(
    label: l10n.interviewStatusConfirmed,
  ),
  InterviewStatus.rescheduleRequested =>
    HhBadge.interviewRescheduleRequested(
      label: l10n.interviewStatusRescheduleRequested,
    ),
  InterviewStatus.cancelled => HhBadge.interviewCancelled(
    label: l10n.interviewStatusCancelled,
  ),
  _ => HhBadge.interviewScheduled(label: l10n.interviewStatusScheduled),
};

/// The word for one of §8.3's three interview types.
///
/// Shown even though the type also decides which detail field is present,
/// because "phone" carries no field at all: the number is the candidate's own,
/// already verified on their profile (BR-01), so without this word a phone
/// interview would render as a time and nothing else.
String interviewTypeLabel(String type, AppL10n l10n) => switch (type) {
  InterviewType.inPerson => l10n.interviewTypeInPerson,
  InterviewType.externalLink => l10n.interviewTypeExternalLink,
  InterviewType.phone => l10n.interviewTypePhone,
  // A type this build has never heard of still has a time and a status worth
  // rendering, so it says "interview" rather than guessing which detail to look
  // for.
  _ => l10n.interviewTitle,
};

/// The verb on one of §8.3's two candidate responses.
String interviewResponseLabel(String status, AppL10n l10n) => switch (status) {
  InterviewStatus.rescheduleRequested => l10n.interviewRequestAnother,
  _ => l10n.interviewConfirm,
};
