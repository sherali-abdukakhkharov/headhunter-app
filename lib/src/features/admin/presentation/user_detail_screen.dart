import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/role_label.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_user.dart';
import 'package:jobbridge_app/src/features/admin/domain/audit_entry.dart';
import 'package:jobbridge_app/src/features/admin/presentation/account_status_badge.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_decision_sheet.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// The instant §10.4's restriction ends, from a calendar day picked on a phone.
///
/// ## Why this is not a date string
///
/// The route takes an ISO timestamp and the server parses it with
/// `new Date(...)`. A bare `2026-09-01` is read as **UTC** midnight, which is
/// 05:00 in Tashkent — so a restriction an administrator ended on the 1st
/// would in fact run five hours into it. Sending the offset removes the
/// question.
///
/// ## Why the offset comes from a response
///
/// [platformOffset] must be read from a timestamp the **server** sent, exactly
/// as §8.3's interview scheduling reads one: a `+05:00` written into Dart
/// would be a second source of truth for the platform zone, wrong the day
/// Uzbekistan reintroduces daylight saving and wrong in the direction that
/// moves every deadline by an hour.
///
/// ## What the day means
///
/// Midnight at the **start** of it, which is the server's own example and what
/// BR-10's guard does with it (`restricted_until <= now()`). So "until the
/// 1st" means the account is free on the 1st, and the sheet's caption says so
/// rather than leaving an administrator to guess which end of the day it is.
String restrictionEndsAt(String day, Duration platformOffset) {
  final sign = platformOffset.isNegative ? '-' : '+';
  final abs = platformOffset.abs();
  final hours = abs.inHours.toString().padLeft(2, '0');
  final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');

  return '${day}T00:00:00$sign$hours:$minutes';
}

/// One account, and §10.4's four actions on it (UAT-14).
///
/// ## The offered actions come from the status the account is in
///
/// Not from the three values the route accepts — see
/// [UserStatusChange.availableFor]. A button that answers 409 every time it is
/// pressed is worse than an absent one, and there is a second reason here that
/// the vacancy transition table did not have: `admin.status_unchanged` covers
/// *two* unrelated situations on the server. "Already in that state" is the
/// ordinary race between two administrators and the work is done; "awaiting
/// deletion" is BR-14's state, which no administrator action may overwrite and
/// which no retry will ever resolve. The client keeps them apart by never
/// offering an action on a `deletion_requested` account, which leaves the 409
/// meaning exactly one thing by the time it can be reached.
///
/// ## Self-targeting is the server's refusal to make, not this screen's
///
/// `admin.cannot_target_self` is a 403, and the client **cannot** pre-empt it:
/// nothing in the session carries the signed-in account's user id — the token
/// response is roles and tokens, by design. So the sheet renders the server's
/// own sentence beside the button that failed, which is what it does with
/// every other refusal. Adding an id to the session to grey out one button on
/// one screen would be a wider change than the problem.
///
/// ## The history is two lists and no audit log
///
/// `AdminUserDetailDto` carries BR-08's status trail and the complaints filed
/// about the person, and **no audit entries** — those are a different endpoint
/// (`GET /admin/audit`) and a separate fetch. The screen is built around the
/// two lists it is actually given.
class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(adminUserProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUserTitle)),
      body: switch (detail) {
        // 404 first and separately: `user.not_found` means the account is gone
        // since the search that found it. Retrying fails the same way, so
        // there is no retry.
        AsyncValue(hasError: true, error: final ApiException e)
            when e.statusCode == 404 =>
          ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhNotice(
                title: l10n.adminUserGoneTitle,
                message: l10n.adminUserGoneBody,
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
              title: failureTitle(error, l10n),
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(adminUserProvider(userId)),
            ),
          ],
        ),
        AsyncData(:final value) => _Detail(detail: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.detail});

  final AdminUserDetail detail;

  AdminUser get user => detail.user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        HhCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user.name ?? l10n.adminUserNoName,
                style: HhTypography.subtitle,
              ),
              const SizedBox(height: HhSpace.sm),
              Text(
                user.phone ?? l10n.adminUserNoPhone,
                style: HhTypography.body,
              ),
              const SizedBox(height: HhSpace.md),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: accountStatusBadge(user.status.wire, l10n),
              ),

              // Only where it says something. A restriction with no end date
              // is a different fact from one that expires, and it is the fact
              // an administrator most needs before deciding whether to act.
              if (user.status == UserAccountStatus.restricted) ...[
                const SizedBox(height: HhSpace.sm),
                Text(
                  switch (user.restrictedUntil) {
                    final until? => l10n.adminUserRestrictedUntil(
                      wallClockDay(until.wallClock),
                    ),
                    _ => l10n.adminUserRestrictedIndefinitely,
                  },
                  style: HhTypography.caption,
                ),
              ],

              const SizedBox(height: HhSpace.md),
              Wrap(
                spacing: HhSpace.sm,
                runSpacing: HhSpace.xs,
                children: [
                  for (final role in user.roles) roleChip(role, l10n),
                ],
              ),

              // Captions rather than chips, for the reason `roleChip`
              // records: a label with a date in it is long enough to overflow
              // an `HhMetaChip`, which does not shrink its text.
              const SizedBox(height: HhSpace.sm),
              Text(
                l10n.adminUserRegistered(
                  wallClockDay(user.createdAt.wallClock),
                ),
                style: HhTypography.caption,
              ),
              Text(
                // "Never" is worth a line of its own: it is what tells an
                // abandoned registration from an account somebody uses.
                switch (user.lastLoginAt) {
                  final at? => l10n.adminUserLastLogin(
                    wallClockDay(at.wallClock),
                  ),
                  _ => l10n.adminUserNeverSignedIn,
                },
                style: HhTypography.caption,
              ),
            ],
          ),
        ),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminUserActions, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        _Actions(detail: detail),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminUserHistory, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),

        // §10.4's audit log, asked its two questions about this account. They
        // sit here rather than beside the actions because they are reading
        // rather than doing, and because the status trail below is the same
        // question answered by a different table: BR-08 records what the
        // account's status became, the audit log records everything an
        // administrator did — a warning changes no status and appears only
        // there.
        HhButton.text(
          label: l10n.adminUserAuditAbout,
          onPressed: () => GoRouter.of(context).go(
            Routes.adminAuditForTarget(
              AuditTargetType.user.wire,
              user.userId,
            ),
          ),
        ),
        // Offered only where it can answer: an audit row is only ever written
        // by an administrator, so "what has this candidate done" is a query
        // guaranteed to come back empty and to read as a bug.
        if (user.roles.contains(AppRole.admin))
          HhButton.text(
            label: l10n.adminUserAuditBy,
            onPressed: () => GoRouter.of(
              context,
            ).go(Routes.adminAuditByActor(user.userId)),
          ),
        // §10.5, and offered on the same rule: BR-15 creates a wallet at first
        // *employer* registration, so this link on a candidate would lead to a
        // 404 that reads as a fault rather than as "there is nothing here".
        if (user.roles.contains(AppRole.employer))
          HhButton.text(
            label: l10n.adminWalletTitle,
            onPressed: () => GoRouter.of(
              context,
            ).go(Routes.adminWalletFor(user.userId)),
          ),
        const SizedBox(height: HhSpace.sm),

        if (detail.statusHistory.isEmpty)
          Text(
            l10n.adminUserHistoryEmpty,
            style: HhTypography.body.copyWith(color: HhColors.inkMuted),
          )
        else
          for (final entry in detail.statusHistory) ...[
            _HistoryRow(entry: entry),
            const SizedBox(height: HhSpace.sm),
          ],

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminUserComplaints, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        if (detail.complaints.isEmpty)
          Text(
            l10n.adminUserComplaintsEmpty,
            style: HhTypography.body.copyWith(color: HhColors.inkMuted),
          )
        else
          for (final complaint in detail.complaints) ...[
            _ComplaintRow(complaint: complaint),
            const SizedBox(height: HhSpace.sm),
          ],
      ],
    );
  }
}

/// §10.4's four actions, or the one sentence that says why there are none.
class _Actions extends ConsumerWidget {
  const _Actions({required this.detail});

  final AdminUserDetail detail;

  AdminUser get user => detail.user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final available = UserStatusChange.availableFor(user.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A warning is offered on every account, `deletion_requested`
        // included: it changes no status, so BR-14's request is untouched by
        // it, and the audit row is a record worth having about an account on
        // its way out.
        HhButton.secondary(
          label: l10n.adminWarnUser,
          onPressed: () => _warn(context, ref),
        ),

        if (available.isEmpty) ...[
          const SizedBox(height: HhSpace.md),
          // Rendered rather than hidden, the same rule the complaint review's
          // remedy section follows: an administrator who cannot find the
          // buttons assumes they missed them.
          HhNotice(
            title: l10n.adminUserNoActionsTitle,
            message: l10n.adminUserNoActionsBody,
            iconPath: HhIconPath.infoCircle,
          ),
        ],

        for (final change in available) ...[
          const SizedBox(height: HhSpace.sm),
          // Blocking is destructive and looks it; restricting and lifting do
          // not. Nothing here is the screen's primary action — an
          // administrator arrives to read an account, and acting on it is the
          // exception.
          if (change == UserStatusChange.blocked)
            HhButton.destructive(
              label: l10n.adminUserBlock,
              onPressed: () => _change(context, ref, change),
            )
          else
            HhButton.secondary(
              label: _labelFor(change, l10n),
              onPressed: () => _change(context, ref, change),
            ),
        ],
      ],
    );
  }

  /// Lifting reads differently depending on what is being lifted: "unblock" is
  /// meaningless to somebody looking at a restricted account, and "lift the
  /// restriction" is wrong on a blocked one. Same transition, two sentences.
  String _labelFor(UserStatusChange change, AppL10n l10n) => switch (change) {
    UserStatusChange.restricted => l10n.adminUserRestrict,
    UserStatusChange.blocked => l10n.adminUserBlock,
    UserStatusChange.active => user.status == UserAccountStatus.blocked
        ? l10n.adminUserUnblock
        : l10n.adminUserLiftRestriction,
  };

  /// §10.4's restrict, block and unblock, with their mandatory reason.
  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    UserStatusChange change,
  ) async {
    final l10n = AppL10n.of(context);

    final result = await showAdminDecisionSheet(
      context,
      title: switch (change) {
        UserStatusChange.restricted => l10n.adminUserRestrictTitle,
        UserStatusChange.blocked => l10n.adminUserBlockTitle,
        UserStatusChange.active => user.status == UserAccountStatus.blocked
            ? l10n.adminUserUnblockTitle
            : l10n.adminUserLiftRestrictionTitle,
      },
      subject: user.name ?? user.phone ?? l10n.adminUserNoName,
      body: switch (change) {
        UserStatusChange.restricted => l10n.adminUserRestrictBody,
        UserStatusChange.blocked => l10n.adminUserBlockBody,
        UserStatusChange.active => l10n.adminUserLiftBody,
      },
      confirmLabel: _labelFor(change, l10n),
      needsReason: true,
      // BR-10 requires the app to *explain* a restriction rather than fail
      // mysteriously, and §4.2 shows this text to the person verbatim. So the
      // label promises the right audience: not the employer, the account.
      reasonLabel: l10n.adminUserStatusReasonLabel,
      reasonHint: l10n.adminUserStatusReasonHint,
      // Only a restriction takes a date, and only a restriction is offered
      // one. Lifting has no end and blocking has no end by design — BR-10's
      // guard only ever expires a restriction.
      date: change == UserStatusChange.restricted
          ? _restrictionDate(l10n)
          : null,
      send: (input) => ref
          .read(adminRepositoryProvider)
          .setUserStatus(
            user.userId,
            change,
            input.reason ?? '',
            restrictedUntil: input.until,
          ),
    );

    if (result == AdminDecisionOutcome.dismissed) return;

    // Patched on a 409 as well as on success, and that is not optimism:
    // `admin.status_unchanged` means the account was already in the status
    // that was asked for, so both answers leave it there.
    ref.read(userSearchProvider.notifier).applyStatus(
      user.userId,
      change.result,
    );
    // The status, the history row and §10.1's sanction counters all moved.
    ref
      ..invalidate(adminUserProvider(user.userId))
      ..invalidate(adminDashboardProvider);

    if (result == AdminDecisionOutcome.sent && context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
  }

  /// §10.4's optional end date.
  ///
  /// The offset is taken from this account's own `createdAt` rather than
  /// written into Dart, the same way §8.3's scheduling takes one — and unlike
  /// §8.3 it can never be missing here, because a user row without a
  /// registration timestamp is not a shape the server can send.
  AdminDecisionDate _restrictionDate(AppL10n l10n) {
    final offset = user.createdAt.offset;

    return AdminDecisionDate(
      label: l10n.adminUserRestrictUntilLabel,
      caption: l10n.adminUserRestrictUntilCaption,
      toWire: (day) => restrictionEndsAt(day, offset),
    );
  }

  /// §10.4's mild remedy — the same sheet §10.2 reaches it from.
  Future<void> _warn(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);

    final result = await showAdminDecisionSheet(
      context,
      title: l10n.adminWarnUserTitle,
      subject: user.name ?? user.phone ?? l10n.adminUserNoName,
      body: l10n.adminWarnUserBody,
      confirmLabel: l10n.adminWarnUser,
      needsReason: true,
      reasonLabel: l10n.adminWarnReasonLabel,
      reasonHint: l10n.adminWarnReasonHint,
      send: (input) => ref
          .read(adminRepositoryProvider)
          .warnUser(user.userId, input.reason ?? ''),
    );

    if (result != AdminDecisionOutcome.sent) return;

    // Nothing on this screen changes — a warning alters no status, which is
    // the point of it — and it writes no BR-08 row, so the history does not
    // move either. The audit log is the whole record, and it is not on this
    // screen. The toast is the confirmation.
    if (context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
  }
}

/// One BR-08 status change: what it became, when, and why.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final StatusHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              accountStatusBadge(entry.toStatus.wire, l10n),
              const Spacer(),
              Text(
                wallClockDay(entry.createdAt.wallClock),
                style: HhTypography.caption,
              ),
            ],
          ),

          const SizedBox(height: HhSpace.sm),
          Text(
            // Who, and "the platform" where nobody: BR-10's guard lifting an
            // expired restriction writes a row with no actor, and that is the
            // difference between a decision and a deadline.
            switch (entry.actorRole) {
              final role? => l10n.adminUserHistoryBy(roleLabel(role, l10n)),
              _ => l10n.adminUserHistoryAutomatic,
            },
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),

          if (entry.reason case final reason?) ...[
            const SizedBox(height: HhSpace.sm),
            // The administrator's own words (§2.4), whole.
            Text(reason, style: HhTypography.body),
          ],
        ],
      ),
    );
  }

}

/// One complaint filed about this account.
///
/// It does not open the review. §10.2's queue is where a complaint is decided,
/// and a second route to the decision from a screen that shows only open and
/// closed ones together would invite re-deciding one that is already closed.
/// This list is context for a decision about the *account*.
class _ComplaintRow extends StatelessWidget {
  const _ComplaintRow({required this.complaint});

  final UserComplaint complaint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              HhMetaChip(
                label: complaint.isOpen
                    ? l10n.adminUserComplaintOpen
                    : l10n.adminUserComplaintClosed,
                iconPath: complaint.isOpen
                    ? HhIconPath.alertTriangle
                    : HhIconPath.checkCircle,
              ),
              const Spacer(),
              Text(
                wallClockDay(complaint.createdAt.wallClock),
                style: HhTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: HhSpace.sm),
          // The reporter's own words (§2.4), clipped: this is context, and the
          // review is where an accusation is read on its merits.
          Text(
            complaint.reason,
            style: HhTypography.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
