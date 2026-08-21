import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/queue_wait.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_decision_sheet.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';

/// §10.2's employer verification queue — the administrator's half of BR-03.
///
/// ## Why this is the first admin screen built
///
/// BR-03 gates *everything* an employer does: no vacancy may be submitted and
/// no invitation may be sent until their profile is verified. Until this screen
/// existed there was no path through the product to grant that — an employer
/// could register, complete a profile, upload their documents and wait forever,
/// with the only remedy being a hand-written API call.
///
/// ## The list is the review
///
/// Every field §10.2 asks for arrives in the queue response, evidence included,
/// so there is no detail route and no second request. A detail screen would
/// spend a round trip re-fetching what is already in hand and would cost the
/// administrator their place in the queue to read it.
///
/// ## The order is the server's, and nothing here re-sorts
///
/// Oldest first. A queue that is not FIFO is a queue somebody waits in
/// indefinitely, and sorting by name — the obvious "improvement" — would undo
/// that silently. The card says how long its submission has waited, because
/// that is the fact the ordering is *for* and a timestamp does not give it.
///
/// ## A list, not a screen
///
/// §10.2's two queues share one shell tab, and `AdminQueueScreen` owns the
/// scaffold and the segmented control that names them. A `Scaffold` here would
/// put a second one inside the first.
class VerificationQueueList extends ConsumerWidget {
  const VerificationQueueList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final queue = ref.watch(verificationQueueProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(verificationQueueProvider),
      child: switch (queue) {
        AsyncValue(hasError: true, :final error?) => ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(verificationQueueProvider),
            ),
          ],
        ),
        AsyncData(:final value) => _Queue(page: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Queue extends ConsumerWidget {
  const _Queue({required this.page});

  final AdminQueuePage<VerificationQueueItem> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        if (page.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: HhSpace.lg),
            child: HhEmptyState(
              title: l10n.adminVerificationEmpty,
              message: l10n.adminVerificationEmptyBody,
            ),
          )
        else ...[
          Text(l10n.adminVerificationFifo, style: HhTypography.caption),
          const SizedBox(height: HhSpace.lg),
          for (final item in page.items) ...[
            _SubmissionCard(item: item),
            const SizedBox(height: HhSpace.md),
          ],
        ],

        if (page.isLoadingMore)
          HhLoadingMore(label: l10n.commonLoadingMore)
        else if (page.hasMore)
          Padding(
            padding: const EdgeInsets.only(top: HhSpace.sm),
            child: HhButton.text(
              label: l10n.commonShowMore,
              onPressed: () => _loadMore(context, ref),
            ),
          ),
      ],
    );
  }

  /// A failed append leaves the queue on screen and says so, rather than
  /// replacing rows that are still correct with an error page.
  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(verificationQueueProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// One submission: who, since when, what they uploaded, and the three outcomes.
class _SubmissionCard extends ConsumerWidget {
  const _SubmissionCard({required this.item});

  final VerificationQueueItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A `Wrap`, not a `Row`: the type label and the waiting time both
          // grow in Russian, and a badge is icon plus word so truncating one
          // would put its state back on colour alone. `double.infinity` because
          // a Wrap inside a stretch Column still shrink-wraps, which is the
          // trap that left the chat timestamps ragged.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: HhSpace.sm,
              runSpacing: HhSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HhMetaChip(
                  label: item.isCompany
                      ? l10n.adminEmployerCompany
                      : l10n.adminEmployerIndividual,
                  iconPath: item.isCompany
                      ? HhIconPath.building
                      : HhIconPath.person,
                ),
                Text(
                  l10n.adminWaitingDays(daysWaiting(item.submittedAt)),
                  style: HhTypography.caption,
                ),
              ],
            ),
          ),

          const SizedBox(height: HhSpace.md),
          Text(
            // The employer's own words (§2.4), never translated and never
            // reconstructed. Null is a real state and it is said rather than
            // left blank, so a thin card is not read as a broken one.
            item.displayName ?? l10n.adminEmployerUnnamed,
            style: HhTypography.subtitle,
          ),
          if (item.secondaryName case final second?)
            Text(second, style: HhTypography.caption),

          if (item.regionId case final regionId?) ...[
            const SizedBox(height: HhSpace.xs),
            // A bound dictionary id resolved to a label (BR-13). Never the id,
            // and never compared as text.
            DictionaryLabel(
              type: 'region',
              id: regionId,
              style: HhTypography.caption,
            ),
          ],

          const SizedBox(height: HhSpace.lg),
          Text(l10n.adminEvidenceTitle, style: HhTypography.label),
          const SizedBox(height: HhSpace.sm),
          if (item.files.isEmpty)
            Text(l10n.adminEvidenceNone, style: HhTypography.caption)
          else
            for (final file in item.files)
              _EvidenceRow(employerUserId: item.employerUserId, file: file),

          const SizedBox(height: HhSpace.lg),
          // Approval first, then the outcome the employer can act on, then the
          // refusal. Ordered by how good the news is rather than by severity,
          // because the common case in a verification queue is a submission
          // that is fine.
          HhButton(
            label: l10n.adminVerify,
            onPressed: () =>
                _decide(context, ref, VerificationDecision.verified),
          ),
          const SizedBox(height: HhSpace.sm),
          HhButton.secondary(
            label: l10n.adminRequestChanges,
            onPressed: () =>
                _decide(context, ref, VerificationDecision.changesRequired),
          ),
          const SizedBox(height: HhSpace.sm),
          HhButton.text(
            label: l10n.adminReject,
            onPressed: () =>
                _decide(context, ref, VerificationDecision.rejected),
          ),
        ],
      ),
    );
  }

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    VerificationDecision decision,
  ) async {
    final l10n = AppL10n.of(context);
    final subject = item.displayName ?? l10n.adminEmployerUnnamed;

    final outcome = await showAdminDecisionSheet(
      context,
      title: switch (decision) {
        VerificationDecision.verified => l10n.adminVerifyTitle,
        VerificationDecision.changesRequired => l10n.adminRequestChangesTitle,
        VerificationDecision.rejected => l10n.adminRejectTitle,
      },
      subject: subject,
      body: switch (decision) {
        VerificationDecision.verified => l10n.adminVerifyBody,
        VerificationDecision.changesRequired => l10n.adminRequestChangesBody,
        VerificationDecision.rejected => l10n.adminRejectBody,
      },
      confirmLabel: switch (decision) {
        VerificationDecision.verified => l10n.adminVerify,
        VerificationDecision.changesRequired => l10n.adminRequestChanges,
        VerificationDecision.rejected => l10n.adminReject,
      },
      needsReason: decision.needsReason,
      send: (reason) => ref
          .read(adminRepositoryProvider)
          .decideVerification(
            item.employerUserId,
            decision,
            reason: reason,
          ),
    );

    if (outcome == AdminDecisionOutcome.dismissed) return;

    // The row leaves on a 409 as well as on success — the work is done either
    // way — and only the confirmation differs.
    ref.read(verificationQueueProvider.notifier).remove(item.employerUserId);
    ref.invalidate(adminDashboardProvider);

    if (outcome == AdminDecisionOutcome.sent && context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
  }
}

/// One evidence file, opened through the platform channel on tap.
///
/// **Nothing is prefetched.** Every download of protected data is logged
/// (§11.1), so reading a file speculatively would write an audit entry nobody
/// asked for — into the log that exists to make reads accountable. The bytes
/// are fetched when an administrator asks for them and not before.
class _EvidenceRow extends ConsumerStatefulWidget {
  const _EvidenceRow({required this.employerUserId, required this.file});

  final String employerUserId;
  final EvidenceFile file;

  @override
  ConsumerState<_EvidenceRow> createState() => _EvidenceRowState();
}

class _EvidenceRowState extends ConsumerState<_EvidenceRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HhSpace.xs),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: _busy ? null : _open,
        borderRadius: HhRadius.inputAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: HhSpace.sm),
          child: Row(
            children: [
              if (_busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              else
                const HhIcon(
                  HhIconPath.document,
                  size: 18,
                  color: HhColors.inkMuted,
                ),
              const SizedBox(width: HhSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.fileName,
                      style: HhTypography.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // The server's own `file_purpose` code. Not mapped to a
                    // Dart label: purposes are dictionary rows an
                    // administrator edits at runtime (§10.3), so a switch here
                    // would go stale the day one is added — and the reader of
                    // this screen is the person who maintains that dictionary.
                    Text(
                      widget.file.purposeCode,
                      style: HhTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _open() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    try {
      await ref.read(attachmentOpenerProvider).open(
        // Followed verbatim. The path is scoped to this employer's submission
        // on the server side, and constructing one here would be the client
        // deciding which files an administrator may read.
        downloadPath: widget.file.path,
        fileId: widget.file.id,
        fileName: widget.file.fileName,
      );
    } on NoViewerException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.fileNoViewer)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
