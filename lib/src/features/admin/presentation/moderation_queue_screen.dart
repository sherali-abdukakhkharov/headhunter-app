import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/domain/queue_wait.dart';

/// §10.2's vacancy moderation queue — the administrator's half of BR-04.
///
/// ## BR-04 is the mirror of BR-03
///
/// A submitted vacancy reaches no candidate until a moderator passes it, and
/// for a **BR-12 restricted** vacancy this queue is the only route to
/// publication there is. So between this and the verification queue beside it,
/// the two gates that stop the product working end to end are both answerable
/// from a phone, which is what §10 asks for.
///
/// ## Unlike verification, the row is not the review
///
/// The verification queue sends the whole submission in its list response, so
/// its card *is* the review. This one sends a title, an employer and the BR-12
/// restriction — and approving a job posting on its title is not reviewing it.
/// §10.2 asks for the details, the requirements and the contact information by
/// name, so the row opens the review and the decision is taken there, with the
/// description on screen.
///
/// What the row *does* carry is the one thing that decides how urgently it
/// needs opening: whether there is an age or gender restriction to judge.
class ModerationQueueList extends ConsumerWidget {
  const ModerationQueueList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final queue = ref.watch(moderationQueueProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(moderationQueueProvider),
      child: switch (queue) {
        AsyncValue(hasError: true, :final error?) => ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            HhErrorState(
              title: failureTitle(error, l10n),
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(moderationQueueProvider),
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

  final AdminQueuePage<ModerationQueueItem> page;

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
              title: l10n.adminModerationEmpty,
              message: l10n.adminModerationEmptyBody,
            ),
          )
        else ...[
          Text(l10n.adminVerificationFifo, style: HhTypography.caption),
          const SizedBox(height: HhSpace.lg),
          for (final item in page.items) ...[
            _VacancyRow(item: item),
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
      await ref.read(moderationQueueProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// One vacancy in the queue: what it is, whose it is, how long it has waited,
/// and whether it carries a BR-12 restriction.
class _VacancyRow extends StatelessWidget {
  const _VacancyRow({required this.item});

  final ModerationQueueItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () => GoRouter.of(context).go(
        Routes.adminVacancyReviewFor(item.vacancyId),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A `Wrap`, because a badge is icon plus word and the waiting time is
          // a date: neither may be truncated, so a `Row` is the wrong widget.
          // `double.infinity` because a Wrap inside a stretch Column still
          // shrink-wraps.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: HhSpace.sm,
              runSpacing: HhSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Warning-toned, and it is not an accusation: the tone means
                // "waiting on a person", and a restriction is precisely the
                // thing §10.2 will not let a machine wave through.
                if (item.isRestricted)
                  HhBadge(
                    label: l10n.adminRestrictionFlag,
                    tone: HhTone.warning,
                    iconPath: HhIconPath.alertTriangle,
                  ),
                Text(
                  l10n.adminWaitingDays(daysWaiting(item.submittedAt)),
                  style: HhTypography.caption,
                ),
              ],
            ),
          ),

          const SizedBox(height: HhSpace.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // The employer's own words (§2.4). Null is a real state —
                      // a vacancy can be submitted before it has a title only
                      // if the schema does not require one, and saying so beats
                      // an empty row that reads as broken.
                      item.title ?? l10n.vacancyUntitled,
                      style: HhTypography.subtitle,
                    ),
                    if (item.employerName case final name?)
                      Text(name, style: HhTypography.caption),
                  ],
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
