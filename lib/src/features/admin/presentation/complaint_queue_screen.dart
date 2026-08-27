import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint.dart';
import 'package:jobbridge_app/src/features/admin/domain/queue_wait.dart';

/// §10.2's third queue: everything reported, in one list.
///
/// ## One list, four kinds, and no filter
///
/// The server made `complaints` a single generic table precisely so §10.2 is
/// one queue rather than four, and the client keeps that: a moderator works a
/// queue, and the oldest open complaint is the oldest open complaint whatever
/// it is about.
///
/// There is a `targetType` filter on the route and no control for it, which is
/// a decision rather than an omission. Four kinds plus "all" is five segments,
/// and `HhSegmented` was already ruled out at five for the vacancy status
/// filters — at 360pt each would be about 70pt, which fits no label in any of
/// the four interface variants. A filter is worth adding when a moderator has
/// enough complaints for the kinds to be separate jobs, and it wants a control
/// the design system does not have yet. Until then the kind is on every row.
///
/// ## The row does not name the target, and it cannot
///
/// `GET /admin/complaints` returns complaints, not what they are about —
/// resolving the target is a per-kind query that the detail route does one at a
/// time. So the row carries the kind, the wait, and the reporter's own words,
/// which between them are enough to decide what to open first. Naming the
/// target in the list would cost four extra queries a page for a sentence that
/// is one tap away.
class ComplaintQueueScreen extends ConsumerWidget {
  const ComplaintQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final queue = ref.watch(complaintQueueProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HhSpace.gutter,
                HhSpace.gutter,
                HhSpace.gutter,
                HhSpace.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.adminComplaintsTitle,
                  style: HhTypography.title,
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(complaintQueueProvider),
                // Error first: with retry disabled app-wide a failing provider
                // is a terminal state, and matching the loading arm first would
                // spin forever over it.
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
                        onRetry: () => ref.invalidate(complaintQueueProvider),
                      ),
                    ],
                  ),
                  AsyncData(:final value) => _Queue(page: value),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Queue extends ConsumerWidget {
  const _Queue({required this.page});

  final AdminQueuePage<Complaint> page;

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
              title: l10n.adminComplaintsEmpty,
              message: l10n.adminComplaintsEmptyBody,
            ),
          )
        else ...[
          Text(l10n.adminVerificationFifo, style: HhTypography.caption),
          const SizedBox(height: HhSpace.lg),
          for (final item in page.items) ...[
            _ComplaintRow(complaint: item),
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

  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(complaintQueueProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// One complaint: what kind of thing it is about, how long it has waited, and
/// what the reporter said.
class _ComplaintRow extends StatelessWidget {
  const _ComplaintRow({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () =>
          GoRouter.of(context).go(Routes.adminComplaintFor(complaint.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: HhSpace.sm,
              runSpacing: HhSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ComplaintKindChip(kind: complaint.targetType),
                Text(
                  l10n.adminWaitingDays(daysWaiting(complaint.createdAt)),
                  style: HhTypography.caption,
                ),
              ],
            ),
          ),

          const SizedBox(height: HhSpace.xs),
          // What it is about (MT-017). Without this the whole card is a kind, a
          // date and an accusation, so two reports about different vacancies
          // are the same card twice and triage means opening each one.
          //
          // A name where the server resolved one, and a short reference where
          // it could not — a complaint outlives its target, so "deleted" is an
          // ordinary row rather than an error.
          Text(
            complaint.targetSummary ?? complaint.targetReference,
            style: HhTypography.body.copyWith(
              fontSize: 14.5,
              color: complaint.targetSummary == null
                  ? HhColors.inkSubtle
                  : HhColors.brand900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: HhSpace.md),
          Row(
            children: [
              Expanded(
                // The reporter's own words (§2.4), clipped in the list and
                // whole on the review. Clipped rather than summarised: an
                // accusation shortened by the client is an accusation the
                // client wrote.
                child: Text(
                  complaint.reason,
                  style: HhTypography.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: HhSpace.sm),
              const HhIcon(
                HhIconPath.chevronRight,
                size: 18,
                color: HhColors.inkSubtle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// What a complaint is about, as a meta chip.
///
/// **Not an `HhBadge`, on purpose.** A badge is the design system's status
/// vocabulary — icon plus word for the *state* of a thing — and every complaint
/// in this queue has the same state, `open`. The target kind is a
/// classification, so drawing it as a badge would spend the vocabulary that
/// makes `HhBadge` learnable on something that is not a status. A meta chip is
/// what this system uses for a neutral fact, and the icon still carries the
/// distinction without colour.
///
/// `user` and `profile` share the person glyph deliberately: the server
/// resolves both to the same row, so telling them apart on screen would be a
/// distinction with nothing behind it.
class ComplaintKindChip extends StatelessWidget {
  const ComplaintKindChip({required this.kind, super.key});

  final ComplaintTarget kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    final (label, icon) = switch (kind) {
      ComplaintTarget.vacancy => (
        l10n.adminComplaintKindVacancy,
        HhIconPath.briefcase,
      ),
      ComplaintTarget.user => (l10n.adminComplaintKindUser, HhIconPath.person),
      ComplaintTarget.profile => (
        l10n.adminComplaintKindProfile,
        HhIconPath.person,
      ),
      ComplaintTarget.message => (
        l10n.adminComplaintKindMessage,
        HhIconPath.chat,
      ),
      // A kind this build does not know. Says so rather than guessing, and the
      // review offers no action on it.
      ComplaintTarget.unknown => (
        l10n.adminComplaintKindUnknown,
        HhIconPath.helpCircle,
      ),
    };

    return HhMetaChip(label: label, iconPath: icon);
  }
}
