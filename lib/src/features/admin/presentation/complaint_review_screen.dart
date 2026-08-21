import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_action.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_detail.dart';
import 'package:jobbridge_app/src/features/admin/presentation/account_status_badge.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_decision_sheet.dart';
import 'package:jobbridge_app/src/features/admin/presentation/complaint_queue_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_status.dart';

/// One complaint, read before §10.2's decision — and the way in to the route
/// nothing could reach.
///
/// ## The remedy comes before the outcome, and that ordering is the design
///
/// A complaint review is **two requests**, because the server models it as two
/// things: `POST /admin/complaints/:id/review` records what was decided, and
/// the remedy — pausing the vacancy, warning the person — is its own route with
/// its own audit row. They are not one transaction and the client cannot make
/// them one.
///
/// So the screen does not hide that behind a single "uphold" button. Hiding it
/// would mean a failed second request leaves a complaint marked `actioned` with
/// nothing done, or a vacancy paused with the complaint still open, and nothing
/// on screen to say which. Instead the remedy is offered first, with the
/// outcome below it, and the outcome section says what `actioned` claims:
/// something was done. An `actioned` complaint with no action taken is a true
/// statement about the record and a false one about the world, and the audit
/// log is the only record a complaint review has.
///
/// ## §10.2's pause-or-remove finally has an entry point
///
/// `PUT /admin/vacancies/:vacancyId/status` has existed since the admin module
/// was built and **nothing in the app could reach a published vacancy** — the
/// moderation queue only holds `under_moderation`, and there is no admin
/// vacancy list. A complaint about a live vacancy is the honest way in: it is
/// the case §10.2 describes ("a complaint upheld, a policy breach"), and it
/// arrives with the reason the route makes mandatory already written down by
/// somebody else.
///
/// The two actions offered depend on where the vacancy is, from the transition
/// table — see [VacancyAdminStatus.availableFor]. A closed vacancy offers
/// neither, because `closed` is terminal (BR-11).
///
/// ## Gone is a normal answer, twice over
///
/// A 404 on the complaint is the usual 404. But a complaint whose **target** is
/// gone is a different and expected thing: the server keeps complaints past the
/// life of what they were about, deliberately, so the record of a decision
/// survives the decision. That gets a notice and no remedy, and the outcome is
/// still recordable — dismissing a complaint about a deleted vacancy is exactly
/// what should happen to it.
class ComplaintReviewScreen extends ConsumerWidget {
  const ComplaintReviewScreen({required this.complaintId, super.key});

  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(complaintDetailProvider(complaintId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminComplaintTitle)),
      body: switch (detail) {
        // 404 first and separately: `complaint.not_found` means a colleague
        // reviewed it, or it never existed. Either way retrying fails the same
        // way, so there is no retry.
        AsyncValue(hasError: true, error: final ApiException e)
            when e.statusCode == 404 =>
          ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhNotice(
                title: l10n.adminComplaintGoneTitle,
                message: l10n.adminComplaintGoneBody,
                iconPath: HhIconPath.infoCircle,
              ),
              const SizedBox(height: HhSpace.lg),
              HhButton.secondary(
                label: l10n.commonBack,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        AsyncValue(hasError: true, :final error?) => ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(complaintDetailProvider(complaintId)),
            ),
          ],
        ),
        AsyncData(:final value) => _Review(detail: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Review extends ConsumerWidget {
  const _Review({required this.detail});

  final ComplaintDetail detail;

  Complaint get complaint => detail.complaint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        ComplaintKindChip(kind: complaint.targetType),

        const SizedBox(height: HhSpace.lg),
        Text(l10n.adminComplaintReported, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        // The accusation, whole and verbatim (§2.4). The list clipped it; this
        // is the screen where the decision gets taken, so nothing is clipped.
        HhCard(child: Text(complaint.reason, style: HhTypography.body)),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminComplaintTarget, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        _Target(detail: detail),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminComplaintRemedy, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        _Remedy(detail: detail),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminComplaintOutcome, style: HhTypography.label),
        const SizedBox(height: HhSpace.xs),
        Text(
          l10n.adminComplaintOutcomeBody,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),
        HhButton(
          label: l10n.adminComplaintUphold,
          onPressed: () => _resolve(context, ref, ComplaintOutcome.actioned),
        ),
        const SizedBox(height: HhSpace.sm),
        HhButton.secondary(
          label: l10n.adminComplaintDismiss,
          onPressed: () => _resolve(context, ref, ComplaintOutcome.dismissed),
        ),
      ],
    );
  }

  /// Records §10.2's outcome and leaves.
  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    ComplaintOutcome outcome,
  ) async {
    final l10n = AppL10n.of(context);
    final navigator = Navigator.of(context);
    final upheld = outcome == ComplaintOutcome.actioned;

    final result = await showAdminDecisionSheet(
      context,
      title: upheld
          ? l10n.adminComplaintUpholdTitle
          : l10n.adminComplaintDismissTitle,
      subject: _subjectOf(detail, l10n),
      body: upheld
          ? l10n.adminComplaintUpholdBody
          : l10n.adminComplaintDismissBody,
      confirmLabel: upheld
          ? l10n.adminComplaintUphold
          : l10n.adminComplaintDismiss,
      // Mandatory on **both** outcomes, unlike the other two queues: the
      // server requires it either way, and a dismissal is the half somebody
      // is more likely to ask about later.
      needsReason: true,
      reasonLabel: l10n.adminResolutionLabel,
      reasonHint: l10n.adminResolutionHint,
      // `needsReason` is true, so the sheet cannot send null here.
      send: (resolution) => ref
          .read(adminRepositoryProvider)
          .reviewComplaint(complaint.id, outcome, resolution ?? ''),
    );

    if (result == AdminDecisionOutcome.dismissed) return;

    // Out of the queue on a 409 as well as on success — reviewed either way —
    // and §10.1's open-complaint counter moved with it.
    ref.read(complaintQueueProvider.notifier).remove(complaint.id);
    ref.invalidate(adminDashboardProvider);

    if (result == AdminDecisionOutcome.sent && context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
    await navigator.maybePop();
  }
}

/// What was reported, in whatever detail the server could resolve.
class _Target extends StatelessWidget {
  const _Target({required this.detail});

  final ComplaintDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final target = detail.target;

    if (target == null) {
      // Expected, not broken: "a complaint outlives its target on purpose".
      return HhNotice(
        title: l10n.adminComplaintTargetGone,
        message: l10n.adminComplaintTargetGoneBody,
        iconPath: HhIconPath.infoCircle,
      );
    }

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: switch (detail.complaint.targetType) {
          ComplaintTarget.vacancy => [
            Text(
              target.title ?? l10n.vacancyUntitled,
              style: HhTypography.subtitle,
            ),
            const SizedBox(height: HhSpace.sm),
            // The same badge §6.4 draws for an employer, from the same
            // function: a moderator and an employer looking at one vacancy
            // must not be told two different things about its state.
            vacancyBadge(target.status ?? 'draft', l10n),
          ],
          ComplaintTarget.user || ComplaintTarget.profile => [
            Text(
              // Null is not "no name": the join is against
              // `candidate_profiles`, so an employer account resolves to a
              // status and nothing else. Saying which beats an empty line.
              target.fullName ?? l10n.adminComplaintEmployerAccount,
              style: HhTypography.subtitle,
            ),
            const SizedBox(height: HhSpace.sm),
            accountStatusBadge(target.status, l10n),
          ],
          ComplaintTarget.message => [
            // The reported message, verbatim (§2.4) — it is the evidence, and
            // this is the one screen where it is read on its merits.
            Text(target.body ?? '', style: HhTypography.body),
          ],
          ComplaintTarget.unknown => [
            Text(
              l10n.adminComplaintKindUnknownBody,
              style: HhTypography.body.copyWith(color: HhColors.inkMuted),
            ),
          ],
        },
      ),
    );
  }
}

/// What can be done about the target, before the outcome is recorded.
class _Remedy extends ConsumerWidget {
  const _Remedy({required this.detail});

  final ComplaintDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    if (!detail.hasTargetAction) {
      // Rendered rather than hidden. A moderator who cannot find the remedy
      // section assumes they missed it; one who reads "there is nothing to act
      // on" knows the only thing left is the outcome.
      return Text(
        l10n.adminComplaintNoRemedy,
        style: HhTypography.body.copyWith(color: HhColors.inkMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.adminComplaintRemedyBody,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),

        // Pause before remove, and both secondary: the outcome below is the
        // action this screen exists for, and a remedy is a step towards it.
        for (final action in detail.vacancyActions) ...[
          HhButton.secondary(
            label: action == VacancyAdminStatus.paused
                ? l10n.adminPauseVacancy
                : l10n.adminCloseVacancy,
            onPressed: () => _administrate(context, ref, action),
          ),
          const SizedBox(height: HhSpace.sm),
        ],

        if (detail.subjectUserId != null)
          HhButton.secondary(
            label: l10n.adminWarnUser,
            onPressed: () => _warn(context, ref),
          ),
      ],
    );
  }

  /// §10.2's pause-or-remove on a **live** vacancy.
  Future<void> _administrate(
    BuildContext context,
    WidgetRef ref,
    VacancyAdminStatus action,
  ) async {
    final l10n = AppL10n.of(context);
    final vacancyId = detail.vacancyId;
    if (vacancyId == null) return;

    final pausing = action == VacancyAdminStatus.paused;

    final result = await showAdminDecisionSheet(
      context,
      title: pausing
          ? l10n.adminPauseVacancyTitle
          : l10n.adminCloseVacancyTitle,
      subject: detail.target?.title ?? l10n.vacancyUntitled,
      body: pausing ? l10n.adminPauseVacancyBody : l10n.adminCloseVacancyBody,
      confirmLabel: pausing ? l10n.adminPauseVacancy : l10n.adminCloseVacancy,
      // The server's own word: "the employer is owed an explanation". So the
      // default reason label — which says the employer reads it verbatim — is
      // the right one here.
      needsReason: true,
      send: (reason) => ref
          .read(adminRepositoryProvider)
          .administrateVacancy(vacancyId, action, reason ?? ''),
    );

    if (result != AdminDecisionOutcome.sent) return;

    // Stay on the screen: the complaint is still open and still needs an
    // outcome recorded. Reload the detail so the vacancy's badge and the
    // remaining transitions both follow — after a pause, "pause" is gone and
    // only "remove" is left, which is the transition table becoming visible.
    ref.invalidate(complaintDetailProvider(detail.complaint.id));

    if (context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
  }

  /// §10.4's mild remedy, reachable from here because it is what an upheld
  /// complaint about a person most often deserves.
  Future<void> _warn(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final userId = detail.subjectUserId;
    if (userId == null) return;

    final result = await showAdminDecisionSheet(
      context,
      title: l10n.adminWarnUserTitle,
      subject: detail.target?.fullName ?? l10n.adminComplaintEmployerAccount,
      body: l10n.adminWarnUserBody,
      confirmLabel: l10n.adminWarnUser,
      needsReason: true,
      // Addressed to the person, not the employer — M9 delivers it to them.
      reasonLabel: l10n.adminWarnReasonLabel,
      reasonHint: l10n.adminWarnReasonHint,
      send: (reason) =>
          ref.read(adminRepositoryProvider).warnUser(userId, reason ?? ''),
    );

    if (result != AdminDecisionOutcome.sent) return;

    // Nothing on this screen changes — a warning alters no status, which is
    // the point of it — so there is nothing to reload. The toast is the
    // confirmation, and §10.4's audit row is the record.
    if (context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
  }
}

/// What to name on a confirmation sheet for this complaint.
///
/// A complaint has no name of its own, and the sheet names its subject because
/// an administrator working a queue sees sheets that look alike. So it borrows
/// the target's: the vacancy's title, the person's name, or — for a message, or
/// anything gone — the kind, which is the most specific true thing left.
String _subjectOf(ComplaintDetail detail, AppL10n l10n) {
  final target = detail.target;

  return switch (detail.complaint.targetType) {
    ComplaintTarget.vacancy =>
      target?.title ?? l10n.adminComplaintKindVacancy,
    ComplaintTarget.user =>
      target?.fullName ?? l10n.adminComplaintKindUser,
    ComplaintTarget.profile =>
      target?.fullName ?? l10n.adminComplaintKindProfile,
    ComplaintTarget.message => l10n.adminComplaintKindMessage,
    ComplaintTarget.unknown => l10n.adminComplaintKindUnknown,
  };
}
