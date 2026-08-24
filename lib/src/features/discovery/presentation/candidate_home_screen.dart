import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/applications/data/application_repository.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_feed_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notifications_screen.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_repository.dart';

/// §5.5's candidate home: what to do now, and the work worth looking at.
///
/// ## What this screen is, given that the Vacancies tab exists
///
/// §5.5 covers home *and* discovery, and the discovery half — three feeds and
/// nine filters — is the Vacancies tab. Repeating it here would be two screens
/// showing one list. So Home is the candidate's equivalent of §6.2's employer
/// dashboard: **what is waiting on them**, whether their profile is in a state
/// that can be found at all, and a short look at the work the server
/// recommends. Everything on it leads somewhere.
///
/// ## Four requests, and each section fails on its own
///
/// There is no candidate dashboard endpoint, so this composes four the app
/// already has: the profile, the recommended feed, the applications list and
/// the received invitations. That is a deliberate trade — the alternative is a
/// server change for a screen every other part of which is already built — and
/// it comes with one rule: **a section that fails renders nothing rather than
/// an error box**. One unreachable endpoint must not make a candidate's home
/// screen look broken, and every section has a tab of its own to reach the
/// same data from.
///
/// The exception is the profile prompt, which is *absent* rather than empty
/// when it cannot be read: a prompt that cannot say how complete a profile is
/// has nothing to prompt about.
///
/// ## The order is the candidate's urgency, not the section list's
///
/// An unanswered invitation is somebody waiting for a reply, so it comes
/// first. An incomplete profile is why the rest of the app is quiet, so it
/// comes before the work. Recommended vacancies are the reason to open the app
/// on a day when nothing is waiting, so they fill the rest of it.
class CandidateHomeScreen extends ConsumerWidget {
  const CandidateHomeScreen({super.key});

  /// How many recommended vacancies Home shows before handing over to the
  /// Vacancies tab. Three fills a phone screen under the sections above it;
  /// more would make Home a second feed with a worse filter story.
  static const recommendedPreview = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(candidateProfileProvider)
              ..invalidate(vacancyFeedProvider(Feed.recommended))
              ..invalidate(myApplicationsProvider)
              ..invalidate(receivedInvitationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              Text(l10n.candidateHomeTitle, style: HhTypography.title),
              const SizedBox(height: HhSpace.md),

              // §9.2's way in, and the only place its badge can be seen: the
              // shell is capped at five destinations and all five are spoken
              // for. It sits above the counts because an unread notification
              // is the newest thing waiting.
              const NotificationsEntryRow(),
              const SizedBox(height: HhSpace.md),

              const _WaitingOnYou(),
              const _ProfilePrompt(),

              const SizedBox(height: HhSpace.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.candidateHomeRecommended,
                      style: HhTypography.subtitle,
                    ),
                  ),
                  HhButton.text(
                    label: l10n.candidateHomeSeeAll,
                    onPressed: () => GoRouter.of(context).go(
                      Routes.candidateVacanciesWith(Feed.recommended.wire),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HhSpace.sm),
              const _Recommended(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The two counts that mean somebody is waiting on the candidate.
class _WaitingOnYou extends ConsumerWidget {
  const _WaitingOnYou();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    // `.value` rather than a switch: a failed list is simply not counted, and
    // the row it would have produced is absent. See the screen doc.
    final invitations = ref.watch(receivedInvitationsProvider).value;
    final applications = ref.watch(myApplicationsProvider).value;

    // §8.2's `sent` and nothing else. `details_requested` is the candidate
    // waiting on the *employer*, so counting it here would ask somebody to
    // answer a question they already asked.
    final awaiting =
        invitations
            ?.where((i) => i.status == InvitationStatus.sent)
            .length ??
        0;
    final live =
        applications?.where((a) => a.canWithdraw).length ?? 0;

    if (awaiting == 0 && live == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.md),
      child: HhCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            if (awaiting > 0)
              _CountRow(
                icon: HhIconPath.send,
                label: l10n.candidateHomeInvitations(awaiting),
                // Both counts lead to the same tab, which holds applications
                // and invitations behind a segment. The segment is that
                // screen's own state and is not deep-linked, so this promises
                // the tab rather than the list — an honest chevron.
                onTap: () =>
                    GoRouter.of(context).go(Routes.candidateApplications),
              ),
            if (awaiting > 0 && live > 0)
              const Divider(height: 1, color: HhColors.borderFaint),
            if (live > 0)
              _CountRow(
                icon: HhIconPath.document,
                label: l10n.candidateHomeApplications(live),
                onTap: () =>
                    GoRouter.of(context).go(Routes.candidateApplications),
              ),
          ],
        ),
      ),
    );
  }
}

/// §5.5's "profile completion prompt where relevant".
///
/// *Where relevant* is doing work: a complete profile gets nothing, because a
/// bar at 100% on every visit is a permanent reminder of a finished job.
class _ProfilePrompt extends ConsumerWidget {
  const _ProfilePrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final profile = ref.watch(candidateProfileProvider).value;

    if (profile == null || profile.isComplete) return const SizedBox.shrink();

    return HhCard(
      onTap: () => GoRouter.of(context).go(Routes.candidateProfile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            profile.isStarted
                ? l10n.candidateHomeProfileIncomplete
                : l10n.candidateHomeProfileEmpty,
            style: HhTypography.subtitle,
          ),
          const SizedBox(height: HhSpace.sm),
          Text(
            // Not searchable is the consequence worth naming: it is the answer
            // to "why is nobody inviting me", and §5.4 makes it a threshold
            // rather than a preference.
            profile.isSearchable
                ? l10n.candidateHomeProfileBody
                : l10n.candidateHomeProfileHidden,
            style: HhTypography.body.copyWith(color: HhColors.inkMuted),
          ),
          const SizedBox(height: HhSpace.md),
          // The same ring the profile screen draws, so the two cannot report
          // one profile as two different numbers.
          HhCompletenessRing(
            percent: profile.completenessPercent,
            title: l10n.profileCompleteness,
          ),
        ],
      ),
    );
  }
}

/// A short look at the work the server recommends (§5.5).
class _Recommended extends ConsumerWidget {
  const _Recommended();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final feed = ref.watch(vacancyFeedProvider(Feed.recommended));

    return switch (feed) {
      // A failure renders the empty state rather than an error box: the
      // Vacancies tab reports the same failure properly, with a retry, and
      // Home's job is not to be a second error screen.
      AsyncValue(hasError: true) || AsyncData(value: []) => HhEmptyState(
        title: l10n.candidateHomeNoRecommendations,
        message: l10n.candidateHomeNoRecommendationsBody,
        actionLabel: l10n.candidateHomeBrowseAll,
        onAction: () => GoRouter.of(context).go(
          Routes.candidateVacanciesWith(Feed.recent.wire),
        ),
      ),
      AsyncData(:final value) => Column(
        children: [
          for (final card
              in value.take(CandidateHomeScreen.recommendedPreview))
            // The same card the feed draws, with the same actions. A second
            // card type here would drift from it, and the first thing to
            // drift would be what Apply does.
            VacancyFeedCard(card: card, feed: Feed.recommended),
        ],
      ),
      _ => const Padding(
        padding: EdgeInsets.symmetric(vertical: HhSpace.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// One count, and the way to what it counts.
class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: [
            HhIcon(icon, size: 20, color: HhColors.inkMuted),
            const SizedBox(width: HhSpace.md),
            Expanded(child: Text(label, style: HhTypography.body)),
            const HhIcon(
              HhIconPath.chevronRight,
              size: 18,
              color: HhColors.inkSubtle,
            ),
          ],
        ),
      ),
    ),
  );
}
