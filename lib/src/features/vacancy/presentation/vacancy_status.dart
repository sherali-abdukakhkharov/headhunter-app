import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// The badge for one of §6.4's six vacancy statuses.
///
/// One function rather than a `switch` per call site: the design system's
/// named constructors *are* the vocabulary, and a seventh status added
/// server-side should surface in one place. An unrecognised status falls back
/// to draft rather than throwing — the same rule as an unknown field kind, for
/// the same reason.
Widget vacancyBadge(String status, AppL10n l10n) => switch (status) {
  'under_moderation' => HhBadge.vacancyModeration(
    label: l10n.vacancyStatusModeration,
  ),
  'active' => HhBadge.vacancyActive(label: l10n.vacancyStatusActive),
  'paused' => HhBadge.vacancyPaused(label: l10n.vacancyStatusPaused),
  'closed' => HhBadge.vacancyClosed(label: l10n.vacancyStatusClosed),
  'rejected' => HhBadge.vacancyRejected(label: l10n.vacancyStatusRejected),
  _ => HhBadge.vacancyDraft(label: l10n.vacancyStatusDraft),
};

/// The label for an employer transition (§6.4).
String transitionLabel(String status, AppL10n l10n) => switch (status) {
  'active' => l10n.vacancyResume,
  'paused' => l10n.vacancyPause,
  _ => l10n.vacancyClose,
};
