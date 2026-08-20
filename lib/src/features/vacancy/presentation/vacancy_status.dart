import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';

/// What to call a vacancy on screen.
///
/// The title is a **schema-driven field** (§6.3) and not a column, so it lives
/// in `fields` and may be missing, blank or not a string at all — a draft
/// created and abandoned has none. Every caller has to answer the same question
/// the same way, and there were three copies of this before the employer's
/// sent-invitation list would have made a fourth.
String vacancyTitle(Vacancy vacancy, AppL10n l10n) {
  final title = vacancy.fields['title'];

  return title is String && title.trim().isNotEmpty
      ? title
      : l10n.vacancyUntitled;
}

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
