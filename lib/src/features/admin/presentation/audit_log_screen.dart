import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/audit_entry.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// §10.4's immutable log: "record important administrator actions in an
/// immutable audit log available to authorized administrators".
///
/// ## Two questions, both of them in the location
///
/// The section asks the log two things — what one administrator has done, and
/// what was done to one thing — and both arrive as query parameters rather
/// than as controls on the screen. There is nothing useful to type: every
/// filter this endpoint takes is a uuid, so the log is something you arrive at
/// *from* the account you were reading, and the way back to the whole log is
/// one button.
///
/// ## The names arrive resolved, and the uuid is the fallback
///
/// `actorName` and `targetName` come from the server (2026-08-26). This screen
/// does not resolve either itself and could not affordably: a name per distinct
/// id would mean `GET /admin/users/:id` each — a request that returns a phone
/// number, a status history and a complaint list to obtain a string, and writes
/// a §11.1 access log line every time. Twenty rows would have paid for a page
/// of names with a page of logged reads of other people's contact details, on
/// a screen nobody opened to read contact details.
///
/// **A name replaces the id rather than sitting above it.** Once there is a
/// name, the uuid is not a second fact a reader uses — it is 36 characters
/// nobody can do anything with on a phone, and the *way in* to that account is
/// the tap, which is still there. The id is shown when the name is null, which
/// is a real case: a seeded administrator has no profile to take one from.
///
/// `targetName` is set for a `user` target only. The other four are not
/// accounts; their identity is in `details`, put there by the action.
///
/// **Only a `user` target links.** A vacancy id has no screen that would
/// accept it (the moderation review holds only `under_moderation` ones), and a
/// complaint one would open the review with its decide buttons live — which is
/// how a complaint somebody already closed gets decided a second time. The
/// same reasoning keeps §10.4's complaint list from linking.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({required this.query, super.key});

  final AuditQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final log = ref.watch(auditLogProvider(query));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminAuditTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(auditLogProvider(query)),
        // Error first: with retry disabled app-wide a failing provider is a
        // terminal state, and matching the loading arm first would spin over
        // it forever.
        child: switch (log) {
          AsyncValue(hasError: true, :final error?) => ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhErrorState(
                title: l10n.stateErrorTitle,
                message: error is ApiException
                    ? error.message
                    : l10n.stateErrorBody,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(auditLogProvider(query)),
              ),
            ],
          ),
          AsyncData(:final value) => _Log(query: query, page: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Log extends ConsumerWidget {
  const _Log({required this.query, required this.page});

  final AuditQuery query;
  final AdminQueuePage<AuditEntry> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        if (!query.isEmpty) ...[
          HhNotice(
            title: query.actorUserId != null
                ? l10n.adminAuditFilteredByActor
                : l10n.adminAuditFilteredByTarget,
            message: query.actorUserId ?? query.targetId ?? '',
            iconPath: HhIconPath.filters,
          ),
          const SizedBox(height: HhSpace.sm),
          HhButton.text(
            label: l10n.adminAuditShowAll,
            onPressed: () => GoRouter.of(context).go(Routes.adminAudit),
          ),
          const SizedBox(height: HhSpace.md),
        ],

        if (page.items.isEmpty)
          HhEmptyState(
            title: l10n.adminAuditEmpty,
            message: query.isEmpty
                ? l10n.adminAuditEmptyBody
                : l10n.adminAuditEmptyFilteredBody,
          )
        else ...[
          // Said once, at the top, and it is not decoration: an audit log that
          // could be edited would not be one, and the property belongs to the
          // table rather than to this app having no write path for it.
          Text(l10n.adminAuditNote, style: HhTypography.caption),
          const SizedBox(height: HhSpace.md),
          for (final entry in page.items) ...[
            _EntryCard(entry: entry),
            const SizedBox(height: HhSpace.md),
          ],
        ],

        if (page.isLoadingMore)
          HhLoadingMore(label: l10n.commonLoadingMore)
        else if (page.hasMore)
          HhButton.text(
            label: l10n.commonShowMore,
            onPressed: () => _loadMore(context, ref),
          ),
      ],
    );
  }

  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(auditLogProvider(query).notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// One row: what was done, to what, why, and by whom.
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final pairs = entry.detailPairs;

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(auditActionLabel(entry.action, l10n), style: HhTypography.body),
          const SizedBox(height: HhSpace.xs),
          // Date **and** time: a run of administrator actions on one busy day
          // is the ordinary case, and a log that says only the day cannot be
          // read against anything else that happened.
          Text(
            wallClockStamp(entry.createdAt.wallClock),
            style: HhTypography.caption,
          ),

          const SizedBox(height: HhSpace.sm),
          _Target(entry: entry),

          if (entry.reason case final reason?) ...[
            const SizedBox(height: HhSpace.sm),
            // The administrator's own words (§2.4), whole. This is often the
            // only account of why something was done.
            Text(reason, style: HhTypography.body),
          ],

          if (pairs.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            Text(l10n.adminAuditDetails, style: HhTypography.caption),
            const SizedBox(height: HhSpace.xs),
            // Rendered as text, keys and all, and **never parsed**: the keys
            // differ per action, are enumerated nowhere, and a client that
            // read one by name would be wrong for the next action added.
            for (final (key, value) in pairs)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$key: $value',
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
              ),
          ],

          const SizedBox(height: HhSpace.sm),
          _Actor(actorUserId: entry.actorUserId, actorName: entry.actorName),
        ],
      ),
    );
  }
}

/// What the row is about — a way in where there is one.
class _Target extends StatelessWidget {
  const _Target({required this.entry});

  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final targetId = entry.targetId;

    final chip = HhMetaChip(
      label: switch (entry.targetType) {
        AuditTargetType.user => l10n.adminAuditTargetUser,
        AuditTargetType.employer => l10n.adminAuditTargetEmployer,
        AuditTargetType.vacancy => l10n.adminAuditTargetVacancy,
        AuditTargetType.complaint => l10n.adminAuditTargetComplaint,
        AuditTargetType.dictionaryItem => l10n.adminAuditTargetDictionaryItem,
        AuditTargetType.unknown => l10n.adminAuditTargetUnknown,
      },
      iconPath: switch (entry.targetType) {
        AuditTargetType.user => HhIconPath.person,
        AuditTargetType.employer => HhIconPath.building,
        AuditTargetType.vacancy => HhIconPath.briefcase,
        AuditTargetType.complaint => HhIconPath.alertTriangle,
        AuditTargetType.dictionaryItem => HhIconPath.dictionary,
        AuditTargetType.unknown => HhIconPath.helpCircle,
      },
    );

    // A user is the one kind this app has a screen for. Everything else keeps
    // its id on the row and leads nowhere, which is honest: an affordance that
    // opened a screen unable to show that object would be worse than none.
    final opens =
        entry.targetType == AuditTargetType.user && targetId != null;

    final row = Row(
      children: [
        chip,
        const SizedBox(width: HhSpace.sm),
        Expanded(
          child: Text(
            // Same rule as the actor: the name where there is one, the id
            // where there is not. A non-user target never has one, and its
            // identity is in `details` rather than here.
            entry.targetName ?? targetId ?? '',
            style: HhTypography.caption.copyWith(
              color: entry.targetName == null
                  ? HhColors.inkSubtle
                  : HhColors.ink,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (opens)
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkSubtle,
          ),
      ],
    );

    if (!opens) return row;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () =>
            GoRouter.of(context).go(Routes.adminUserFor(targetId)),
        child: row,
      ),
    );
  }
}

/// Who did it, and a way into their account.
class _Actor extends StatelessWidget {
  const _Actor({required this.actorUserId, this.actorName});

  final String actorUserId;

  /// Null for an administrator with no name anywhere — a seeded one has no
  /// profile to take one from, and then the uuid is all there is to show.
  final String? actorName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        // Always openable: an audit row is only ever written by an
        // administrator, so this id always names an account this app can show.
        onTap: () =>
            GoRouter.of(context).go(Routes.adminUserFor(actorUserId)),
        child: Row(
          children: [
            const HhIcon(
              HhIconPath.shieldCheck,
              size: 15,
              color: HhColors.inkSubtle,
            ),
            const SizedBox(width: 6),
            Text(l10n.adminAuditActor, style: HhTypography.caption),
            const SizedBox(width: HhSpace.sm),
            Expanded(
              child: Text(
                actorName ?? actorUserId,
                style: HhTypography.caption.copyWith(
                  // The name is a fact about a person and the id is a
                  // fallback, so they do not read at the same weight.
                  color: actorName == null
                      ? HhColors.inkSubtle
                      : HhColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const HhIcon(
              HhIconPath.chevronRight,
              size: 18,
              color: HhColors.inkSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

/// A dotted action code as a sentence, or the code itself.
///
/// **The fallback is the code, not a placeholder.** The set of actions grows
/// on the server — §10.5's wallet adjustment and §10.3's dictionary edits are
/// already in it, and the next feature will add more — so a build that has not
/// heard of one must still render a row somebody can act on. A dotted code is
/// a stable identifier that can be searched for in the backend; "unknown
/// action" is not, and a row that did not appear at all would make the log
/// lie.
String auditActionLabel(String action, AppL10n l10n) => switch (action) {
  'employer.verification_decided' => l10n.adminAuditVerificationDecided,
  'vacancy.moderated' => l10n.adminAuditVacancyModerated,
  'complaint.reviewed' => l10n.adminAuditComplaintReviewed,
  'user.warned' => l10n.adminAuditUserWarned,
  'user.restricted' => l10n.adminAuditUserRestricted,
  'user.blocked' => l10n.adminAuditUserBlocked,
  'user.unblocked' => l10n.adminAuditUserUnblocked,
  'user.restriction_expired' => l10n.adminAuditRestrictionExpired,
  'user.purged' => l10n.adminAuditAccountPurged,
  'wallet.adjusted' => l10n.adminAuditWalletAdjusted,
  'dictionary.item_created' => l10n.adminAuditDictionaryCreated,
  'dictionary.item_updated' => l10n.adminAuditDictionaryUpdated,
  'dictionary.item_deactivated' => l10n.adminAuditDictionaryDeactivated,
  'dictionary.items_merged' => l10n.adminAuditDictionaryMerged,
  _ => action,
};
