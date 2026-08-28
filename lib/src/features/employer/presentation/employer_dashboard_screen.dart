import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/applications/data/employer_applications_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/application_stage.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/saved_candidates_screen.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_controller.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:jobbridge_app/src/features/employer/presentation/verification_card.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notifications_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_list_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_status.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_tile.dart';

/// §6.2's employer dashboard (E-07, E-08).
///
/// ## Pending actions come before metrics
///
/// The design says why, and it is the one rule that shapes the whole screen: "a
/// recruiter opens this app to act, not to read numbers." So the three counts
/// live in the header where they can be glanced at, and the body opens with
/// **what needs doing** — a rejected vacancy, applicants nobody has looked at,
/// verification that has not been submitted.
///
/// The header is **inverted** for the same reason the launch screen inverts the
/// mark: "the two apps are instantly distinguishable when a user switches
/// roles" (§2.3 makes that switch a runtime one, so a candidate and an employer
/// see the same shell with different contents).
///
/// ## Where the numbers come from, and what it costs
///
/// There is **no employer dashboard endpoint**, so every figure here is
/// assembled from the per-resource routes that already exist:
///
/// - **Active vacancies, open positions** — `GET /vacancies/mine`, one request
/// - **New applications** — `GET /vacancies/{id}/applications/counts`, **once
///   per vacancy**
/// - **Hiring progress** — the same counts, plus `/invitations/counts/{id}`,
///   again per vacancy
/// - **Candidates to review** — `GET /candidate-search/saved`, one request
/// - **Wallet** — `GET /wallet`, one request
///
/// That is **two requests per active vacancy** — fine for the handful an
/// employer runs at once, and wrong in principle. A summary endpoint is
/// recorded as a backend ask in TODO.md; when it lands this screen loses the
/// fan-out and nothing else about it changes.
///
/// ## Two of §6.2's seven widgets are absent, on purpose
///
/// **Interviews** has no route an employer may call: `GET /interviews/mine`
/// carries `@RequireRole('candidate')`, so the design's third header metric
/// ("5 Suhbat") cannot be built at all yet — not a client gap, a contract gap.
/// It is a backend ask, and until then the header shows the three counts that
/// *are* answerable rather than a placeholder where a number should be.
///
/// **Top up** is M13 and blocked on merchant credentials, so the wallet widget
/// is `WalletTile` — balance and its som value, tappable through to the
/// ledger — and the action arrives with the rest of §6.7.
class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final vacancies = ref.watch(myVacanciesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref
          ..invalidate(myVacanciesProvider)
          ..invalidate(savedCandidatesProvider),
        child: switch (vacancies) {
          // Error before any loading arm: retry is off app-wide, so a failure
          // here is terminal and a spinner over it would be permanent.
          AsyncValue(hasError: true, :final error?) => ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhErrorState(
                title: failureTitle(error, l10n),
                message: error is ApiException
                    ? error.message
                    : l10n.stateErrorBody,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(myVacanciesProvider),
              ),
            ],
          ),
          AsyncData(:final value) => _Body(vacancies: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// Everything below the loading and error arms, so the widgets underneath can
/// take the vacancy list as a plain value.
class _Body extends ConsumerWidget {
  const _Body({required this.vacancies});

  final List<Vacancy> vacancies;

  /// BR-06's own flag rather than a status comparison: `isOpenForApplications`
  /// is computed server-side from the status *and* the deadline, so a vacancy
  /// that is `active` with yesterday's deadline is correctly not open.
  List<Vacancy> get _active =>
      vacancies.where((v) => v.isOpenForApplications).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = _active;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(active: active),

        Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // §9.2, and the same reasoning as the candidate's home: five
              // tabs, all spoken for, and a badge nobody can see is not a
              // badge.
              const NotificationsEntryRow(),
              const SizedBox(height: HhSpace.sectionGap),

              _Attention(vacancies: vacancies, active: active),

              if (active.isNotEmpty) ...[
                const SizedBox(height: HhSpace.sectionGap),
                _HiringProgress(active: active),
              ],

              const SizedBox(height: HhSpace.sectionGap),
              Text(
                AppL10n.of(context).dashboardWallet,
                style: HhTypography.subtitle,
              ),
              const SizedBox(height: HhSpace.md),
              const WalletTile(),

              const SizedBox(height: HhSpace.sectionGap),
              const _QuickActions(),
            ],
          ),
        ),
      ],
    );
  }
}

/// The inverted navy header: who you are, and three numbers.
class _Header extends ConsumerWidget {
  const _Header({required this.active});

  final List<Vacancy> active;

  /// §6.2's "total open positions".
  ///
  /// `worker_count` is a **schema field** (§6.3) stored as a column, so it
  /// arrives inside `fields` keyed by its field code rather than as a property.
  /// A vacancy need not state one, and one that does not contributes nothing
  /// rather than one — inventing a position would inflate the only number on
  /// this screen an employer might quote to somebody.
  int get _openPositions => active.fold(0, (sum, v) {
    final count = v.fields['worker_count'];
    return sum + (count is num ? count.toInt() : 0);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final profile = ref.watch(employerEditorProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + HhSpace.lg,
        left: HhSpace.gutter,
        right: HhSpace.gutter,
        bottom: HhSpace.lg,
      ),
      decoration: const BoxDecoration(color: HhColors.brand900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile case AsyncData(value: final state))
            _Identity(profile: state.profile),

          const SizedBox(height: HhSpace.lg),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '${active.length}',
                  label: l10n.dashboardActiveVacancies,
                ),
              ),
              Expanded(
                child: _Metric(
                  value: '$_openPositions',
                  label: l10n.dashboardOpenPositions,
                ),
              ),
              Expanded(child: _NewApplications(active: active)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Company name and verification state, on navy.
class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final EmployerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // A company profile can be an organisation or an individual, so the name is
    // whichever of the three the employer filled in. "Company" is the last
    // resort rather than an empty line, which would read as a failed load.
    final name = [
      profile?.publicName,
      profile?.legalName,
      profile?.fullName,
    ].firstWhere((n) => n != null && n.trim().isNotEmpty, orElse: () => null);

    return Row(
      children: [
        const HhIcon(
          HhIconPath.building,
          size: 22,
          color: HhColors.brand200,
          strokeWidth: 1.8,
        ),
        const SizedBox(width: HhSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? l10n.navCompany,
                style: HhTypography.subtitle.copyWith(color: HhColors.white),
              ),
              if (profile?.verificationStatus case final status?) ...[
                const SizedBox(height: 4),
                // The same badge the company screen shows, not a bespoke one:
                // BR-03 is the state an employer acts on most and it must read
                // identically wherever it appears.
                verificationBadge(status, l10n),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One header figure. Deliberately not a card: the design draws three numbers
/// on the navy, and boxing them would make the header the loudest thing on a
/// screen whose point is the list below it.
class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: HhTypography.display.copyWith(
          color: HhColors.white,
          fontSize: 26,
        ),
      ),
      Text(
        label,
        style: HhTypography.meta.copyWith(color: HhColors.brand200),
      ),
    ],
  );
}

/// §6.2's "applications not yet reviewed", summed across active vacancies.
///
/// Absent rather than zero while the per-vacancy counts are still arriving: a
/// zero that turns into 34 half a second later is a number that was wrong, and
/// this is the one figure on the screen an employer would act on immediately.
class _NewApplications extends ConsumerWidget {
  const _NewApplications({required this.active});

  final List<Vacancy> active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    var total = 0;

    for (final vacancy in active) {
      final counts = ref.watch(vacancyApplicationCountsProvider(vacancy.id));
      if (counts case AsyncData(:final value)) {
        total += value.byStatus[ApplicationStage.submitted] ?? 0;
      } else {
        // One outstanding request is enough to make the sum a lie.
        return _Metric(value: '—', label: l10n.dashboardNewApplications);
      }
    }

    return _Metric(value: '$total', label: l10n.dashboardNewApplications);
  }
}

/// §6.2's pending work, which the design puts before every metric.
///
/// Rows are ordered by **how stuck the employer is**, not by recency: BR-03
/// first, because nothing else on this screen works without it; then a vacancy
/// a moderator sent back, because it is the only item with a deadline the
/// employer does not control; then applicants nobody has read; then saved
/// candidates, which is a nudge rather than a blockage.
class _Attention extends ConsumerWidget {
  const _Attention({required this.vacancies, required this.active});

  final List<Vacancy> vacancies;
  final List<Vacancy> active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final rows = <Widget>[
      ..._profile(context, ref, l10n),
      ..._verification(context, ref, l10n),
      ..._rejected(context, l10n),
      ..._unreviewed(context, ref, l10n),
      ..._saved(context, ref, l10n),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.dashboardAttention, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        if (rows.isEmpty)
          // Not an empty state with an illustration: an empty queue is the
          // *good* outcome here, and drawing it as absence would read as a
          // failure to load.
          HhCard(
            child: Row(
              children: [
                const HhIcon(
                  HhIconPath.checkCircle,
                  size: 20,
                  color: HhColors.success,
                  strokeWidth: 2,
                ),
                const SizedBox(width: HhSpace.md),
                Expanded(
                  child: Text(
                    l10n.dashboardAttentionClear,
                    style: HhTypography.body,
                  ),
                ),
              ],
            ),
          )
        else
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: HhSpace.sm),
              child: row,
            ),
      ],
    );
  }

  /// §6.1's profile, and it outranks even verification.
  ///
  /// An employer with **no profile** used to produce no row at all: the
  /// verification read 404s without one, which fell through to the default arm
  /// — so the dashboard said "Nothing is waiting on you" to an account that
  /// could not publish a vacancy, search a candidate or submit anything. The
  /// audit found the app saying everything was fine and then refusing every
  /// primary action.
  ///
  /// An incomplete profile is the same story with a number on it: BR-03 needs
  /// all of §6.1, so 60% is not "mostly working".
  List<Widget> _profile(BuildContext context, WidgetRef ref, AppL10n l10n) {
    final editor = ref.watch(employerEditorProvider);

    return switch (editor) {
      AsyncData(value: EmployerEditorState(profile: null)) => [
        _AttentionRow(
          iconPath: HhIconPath.building,
          color: HhColors.warningFg,
          title: l10n.dashboardProfileTitle,
          subtitle: l10n.dashboardProfileMissing,
          onTap: () => context.go(Routes.employerCompany),
        ),
      ],
      AsyncData(value: EmployerEditorState(profile: final profile?))
          when !profile.isComplete =>
        [
          _AttentionRow(
            iconPath: HhIconPath.building,
            color: HhColors.warningFg,
            title: l10n.dashboardProfileTitle,
            subtitle: l10n.dashboardProfileIncomplete(
              profile.completenessPercent,
            ),
            onTap: () => context.go(Routes.employerCompany),
          ),
        ],
      // A failure adds no row. The screen already reports it where the header
      // reads the same provider, and a second copy of one error is noise.
      _ => const [],
    };
  }

  /// BR-03: an unverified employer cannot publish, search or unlock, so this
  /// outranks everything else.
  List<Widget> _verification(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
  ) {
    final verification = ref.watch(verificationProvider);

    return switch (verification) {
      AsyncData(:final value) when value.status != 'verified' => [
        _AttentionRow(
          iconPath: HhIconPath.shieldCheck,
          color: HhColors.warningFg,
          title: l10n.dashboardVerificationTitle,
          subtitle: verificationLabel(value.status, l10n),
          onTap: () => context.go(Routes.employerCompany),
        ),
      ],
      _ => const [],
    };
  }

  /// A vacancy a moderator sent back (§6.4). Read off `isSubmittable` plus a
  /// rejected status rather than off the reason text, because a rejection with
  /// no comment is still a rejection.
  List<Widget> _rejected(BuildContext context, AppL10n l10n) => [
    for (final vacancy in vacancies)
      if (vacancy.status == 'rejected')
        _AttentionRow(
          iconPath: HhIconPath.alertTriangle,
          color: HhColors.warningFg,
          title: l10n.dashboardVacancyRejected,
          subtitle: vacancyTitle(vacancy, l10n),
          onTap: () =>
              context.go('${Routes.employerVacancies}/${vacancy.id}'),
        ),
  ];

  /// Applicants at `submitted` — nobody has opened them.
  List<Widget> _unreviewed(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
  ) => [
    for (final vacancy in active)
      if (ref.watch(vacancyApplicationCountsProvider(vacancy.id))
          case AsyncData(:final value))
        if (value.byStatus[ApplicationStage.submitted] case final n?
            when n > 0)
          _AttentionRow(
            iconPath: HhIconPath.people,
            color: HhColors.brand600,
            title: l10n.dashboardUnreviewed(n),
            subtitle: vacancyTitle(vacancy, l10n),
            onTap: () => context.go(
              '${Routes.employerVacancies}/${vacancy.id}/applicants',
            ),
          ),
  ];

  /// §6.2's "candidates to review": shortlisted or recently saved.
  List<Widget> _saved(BuildContext context, WidgetRef ref, AppL10n l10n) {
    final saved = ref.watch(savedCandidatesProvider);

    return switch (saved) {
      AsyncData(:final value) when value.isNotEmpty => [
        _AttentionRow(
          iconPath: HhIconPath.bookmark,
          color: HhColors.brand600,
          title: l10n.dashboardSavedCandidates(value.length),
          subtitle: l10n.searchSaved,
          onTap: () => showSavedCandidates(context),
        ),
      ],
      _ => const [],
    };
  }
}

/// One actionable row: a glyph, what happened, which vacancy, and a chevron.
class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.iconPath,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconPath;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HhCard(
    onTap: onTap,
    child: Row(
      children: [
        HhIcon(iconPath, size: 20, color: color, strokeWidth: 2),
        const SizedBox(width: HhSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        const HhIcon(
          HhIconPath.chevronRight,
          size: 18,
          color: HhColors.inkDisabled,
        ),
      ],
    ),
  );
}

/// §6.2's hiring progress, one meter per open vacancy.
class _HiringProgress extends StatelessWidget {
  const _HiringProgress({required this.active});

  final List<Vacancy> active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.dashboardHiring, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        for (final vacancy in active)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: _VacancyMeter(vacancy: vacancy),
          ),
      ],
    );
  }
}

/// Hired and invited against the openings, for one vacancy.
///
/// ## "Invited" counts the invitations still in the air
///
/// The design's three segments add up to the openings — 7 hired, 4 invited, 9
/// remaining of 20 — so they have to be **disjoint**, and a total of
/// invitations ever sent is not: some of those people are in the 7. So this
/// counts the non-terminal ones, which is the same `InvitationStatus.terminal`
/// set the inbox uses to decide whether a candidate may still answer.
class _VacancyMeter extends ConsumerWidget {
  const _VacancyMeter({required this.vacancy});

  final Vacancy vacancy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final counts = ref.watch(vacancyApplicationCountsProvider(vacancy.id));
    final invitations = ref.watch(invitationCountsProvider(vacancy.id));

    // The worker count comes from the counts endpoint rather than from
    // `fields`, because that is the number §6.5 measures hires against and the
    // two must not be read from different places.
    final openings = switch (counts) {
      AsyncData(:final value) => value.workerCount,
      _ => null,
    };
    final hired = switch (counts) {
      AsyncData(:final value) => value.hiredCount,
      _ => 0,
    };
    final inFlight = switch (invitations) {
      AsyncData(:final value) => value.entries
          .where((e) => !InvitationStatus.terminal.contains(e.key))
          .fold(0, (sum, e) => sum + e.value),
      _ => 0,
    };

    return HhCard(
      onTap: () => context.go(
        '${Routes.employerVacancies}/${vacancy.id}/applicants',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  vacancyTitle(vacancy, l10n),
                  style: HhTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: HhSpace.sm),
              Text(
                // A vacancy need not state a worker count, and a denominator
                // nobody set is not a target to measure against.
                openings == null
                    ? '$hired'
                    : l10n.dashboardHiredOf(hired, openings),
                style: HhTypography.bodyStrong.copyWith(
                  color: HhColors.brand600,
                ),
              ),
            ],
          ),
          const SizedBox(height: HhSpace.md),
          HhMeter(
            total: openings ?? 0,
            segments: [
              HhMeterSegment(
                value: hired,
                color: HhColors.success,
                label: l10n.dashboardMeterHired(hired),
              ),
              HhMeterSegment(
                value: inFlight,
                color: HhColors.accent500,
                label: l10n.dashboardMeterInvited(inFlight),
              ),
            ],
            remainderLabel: openings == null
                ? null
                : l10n.dashboardMeterRemaining(
                    (openings - hired - inFlight).clamp(0, openings),
                  ),
          ),
        ],
      ),
    );
  }
}

/// §6.2's two quick actions.
class _QuickActions extends ConsumerStatefulWidget {
  const _QuickActions();

  @override
  ConsumerState<_QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends ConsumerState<_QuickActions> {
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HhButton(
          label: l10n.vacancyNew,
          iconPath: HhIconPath.plus,
          loading: _creating,
          onPressed: _creating ? null : _create,
        ),
        const SizedBox(height: HhSpace.sm),
        HhButton.secondary(
          label: l10n.searchCandidates,
          iconPath: HhIconPath.search,
          onPressed: () => context.go(Routes.employerCandidates),
        ),
      ],
    );
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    // Shared with the vacancy list rather than copied: BR-03's refusal happens
    // at creation, and two wordings of it would drift.
    await createVacancyAndOpen(context, ref);
    if (mounted) setState(() => _creating = false);
  }
}
