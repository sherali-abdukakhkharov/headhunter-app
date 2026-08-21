import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_dashboard.dart';

/// §10.1's administrator dashboard, and the way into every other admin surface.
///
/// ## Queues first, and they are a different kind of fact from the metrics
///
/// §10.1 lists its counters as one paragraph, and the screen deliberately does
/// not. Four of them are bounded by a period; five are current state. So the
/// dashboard opens with **what is waiting on a decision right now** and puts
/// the period figures below a heading that says they are period figures.
///
/// The reason is not tidiness. "7 awaiting verification" under a date range
/// reads as "seven employers waited during July" — a sentence that is false and
/// that gets more false as the period ages. Seven are waiting *now*, and an
/// administrator's only question about a queue is whether to open it.
///
/// ## A counter is a way in, or it has no chevron
///
/// All three §10.2 counters navigate: two to their own segment of the
/// moderation tab, and the third to the complaints tab. That was not true when
/// this screen shipped — the complaint counter carried a number and no chevron,
/// because a number that navigates to "this arrives in M10" is worse than one
/// that does not navigate at all. [_QueueRow] takes an **optional** `onTap` and
/// draws the chevron only where there is one, so turning that row on was
/// passing a destination and changing nothing else here. Keep it optional: the
/// same shape is what a fourth counter would need.
///
/// ## The header is not the employer's navy panel
///
/// §6.2's dashboard inverts to navy so "the two apps are instantly
/// distinguishable when a user switches roles" (§2.3 makes that a runtime
/// switch). Reusing it here would defeat exactly that: an account holding both
/// employer and administrator would see the same navy header in both shells,
/// at the one moment the difference matters. The administrator's surface is a
/// work queue on the app's own ground.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final dashboard = ref.watch(adminDashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminDashboardProvider),
          child: switch (dashboard) {
            // Error before any loading arm: retry is off app-wide, so a failure
            // here is terminal and a spinner over it would be permanent.
            AsyncValue(hasError: true, :final error?) => ListView(
              padding: const EdgeInsets.all(HhSpace.gutter),
              children: [
                HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(adminDashboardProvider),
                ),
              ],
            ),
            AsyncData(:final value) => _Body(data: value),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final AdminDashboard data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        Text(l10n.adminDashboardTitle, style: HhTypography.title),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminQueuesTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        _Queues(data: data),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminSanctionsTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        HhCard(
          child: Row(
            children: [
              Expanded(
                child: _Figure(
                  value: data.restrictedUsers,
                  label: l10n.adminRestrictedUsers,
                ),
              ),
              Expanded(
                child: _Figure(
                  value: data.blockedUsers,
                  label: l10n.adminBlockedUsers,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: HhSpace.sectionGap),
        _Period(data: data),
      ],
    );
  }
}

/// The three current-state queues, or one sentence saying there are none.
///
/// The sentence replaces the rows rather than sitting above them, because three
/// zeros in a column is the shape of a screen that failed to load. Nothing is
/// lost by it: every queue has a tab of its own in the nav bar, so an
/// administrator who wants to look at an empty queue can still reach it.
class _Queues extends StatelessWidget {
  const _Queues({required this.data});

  final AdminDashboard data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (!data.hasQueuedWork) {
      return HhCard(
        child: Row(
          children: [
            const HhIcon(
              HhIconPath.checkCircle,
              size: 20,
              color: HhColors.success,
            ),
            const SizedBox(width: HhSpace.md),
            Expanded(
              child: Text(l10n.adminQueuesClear, style: HhTypography.body),
            ),
          ],
        ),
      );
    }

    return HhCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _QueueRow(
            icon: HhIconPath.shieldCheck,
            label: l10n.adminAwaitingVerification,
            count: data.awaitingVerification,
            // Each counter names its queue in the location, so both land on the
            // segment they describe. Screen state would not: the shell keeps
            // the branch, so the second counter tapped would show the first
            // one's list.
            onTap: () => GoRouter.of(context).go(
              Routes.adminQueueWith(Routes.adminQueueVerification),
            ),
          ),
          const Divider(height: 1, color: HhColors.borderFaint),
          _QueueRow(
            icon: HhIconPath.briefcase,
            label: l10n.adminAwaitingModeration,
            count: data.awaitingModeration,
            onTap: () => GoRouter.of(context).go(
              Routes.adminQueueWith(Routes.adminQueueVacancies),
            ),
          ),
          const Divider(height: 1, color: HhColors.borderFaint),
          _QueueRow(
            icon: HhIconPath.alertTriangle,
            label: l10n.adminOpenComplaints,
            count: data.openComplaints,
            // The third and last of §10.2's queues to get a way in. This row
            // has carried a number and no chevron since the dashboard shipped,
            // which was the whole point of making the destination optional.
            onTap: () => GoRouter.of(context).go(Routes.adminComplaints),
          ),
        ],
      ),
    );
  }
}

/// One queue: how long it is, and — where there is somewhere to go — a way in.
class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });

  final String icon;
  final String label;
  final int count;

  /// Absent while the queue's screen does not exist. The chevron follows it, so
  /// the affordance cannot promise a destination there is none of.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          HhIcon(icon, size: 20, color: HhColors.inkMuted),
          const SizedBox(width: HhSpace.md),
          Expanded(child: Text(label, style: HhTypography.body)),
          const SizedBox(width: HhSpace.sm),
          Text('$count', style: HhTypography.subtitle),
          if (onTap != null) ...[
            const SizedBox(width: HhSpace.sm),
            const HhIcon(
              HhIconPath.chevronRight,
              size: 18,
              color: HhColors.inkSubtle,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// §10.1's period-bounded figures, and the control that chooses the period.
class _Period extends ConsumerWidget {
  const _Period({required this.data});

  final AdminDashboard data;

  /// The presets offered. Thirty is the server's own default, so the middle
  /// chip is lit on a first load without the client having asked for anything.
  static const _presets = [7, 30, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final period = data.period;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.adminPeriodTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.xs),
        Text(
          // ISO, like every other date in this app: §8.3's display policy is
          // still an open client question and a format invented here would
          // have to be undone in four locales.
          '${DashboardPeriod.formatDate(period.from)} — '
          '${DashboardPeriod.formatDate(period.to)}',
          style: HhTypography.caption,
        ),

        const SizedBox(height: HhSpace.md),
        Wrap(
          spacing: HhSpace.sm,
          runSpacing: HhSpace.sm,
          children: [
            for (final days in _presets)
              HhFilterChip(
                label: l10n.adminPeriodDays(days),
                // Reads the period the **server** echoed rather than a local
                // "chosen" flag, so the chips can never disagree with the
                // figures underneath them.
                selected: period.days == days,
                onTap: () => ref
                    .read(dashboardRangeControllerProvider.notifier)
                    // Counts back from the server's own end date. The device
                    // clock is never consulted: "today" is a fact about
                    // PLATFORM_TIME_ZONE, and an administrator in another zone
                    // would otherwise shift the window by a day at each end.
                    .showLastDays(days, endingOn: period.to),
              ),
          ],
        ),

        const SizedBox(height: HhSpace.md),
        HhCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CountPairRow(label: l10n.adminCandidates, pair: data.candidates),
              const SizedBox(height: HhSpace.md),
              const Divider(height: 1, color: HhColors.borderFaint),
              const SizedBox(height: HhSpace.md),
              _CountPairRow(label: l10n.adminEmployers, pair: data.employers),
            ],
          ),
        ),

        const SizedBox(height: HhSpace.md),
        HhCard(
          child: Row(
            children: [
              Expanded(
                child: _Figure(
                  value: data.activeVacancies,
                  label: l10n.adminVacanciesPublished,
                ),
              ),
              Expanded(
                child: _Figure(
                  value: data.applications,
                  label: l10n.adminApplicationsSubmitted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A §10.1 count pair: everyone, and how many of them arrived in the period.
class _CountPairRow extends StatelessWidget {
  const _CountPairRow({required this.label, required this.pair});

  final String label;
  final CountPair pair;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HhTypography.bodyStrong),
        const SizedBox(height: HhSpace.sm),
        Row(
          children: [
            Expanded(
              child: _Figure(
                value: pair.total,
                label: l10n.adminCountTotal,
              ),
            ),
            Expanded(
              child: _Figure(
                value: pair.newInPeriod,
                label: l10n.adminCountNew,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One number with its word underneath.
///
/// A figure and not an `HhBadge`: a badge answers "whose turn is it, and did it
/// end well?", and a count answers neither. The word is what carries the
/// meaning, so it is never dropped to save a line.
class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$value', style: HhTypography.title),
      Text(label, style: HhTypography.caption),
    ],
  );
}
