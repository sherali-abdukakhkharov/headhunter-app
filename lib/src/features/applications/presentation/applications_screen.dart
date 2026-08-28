import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/data/application_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_card.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitations_inbox_screen.dart';

/// The word for one of §8.1's eight application stages.
///
/// Separate from [stageBadge] because the employer view needs the label
/// without the badge — in a stage-move button and in §6.5's per-stage counts —
/// and two spellings of the same stage is how a vocabulary stops being one.
String stageLabel(String status, AppL10n l10n) => switch (status) {
  'viewed' => l10n.stageViewed,
  'shortlisted' => l10n.stageShortlisted,
  'interview' => l10n.stageInterview,
  'offer' => l10n.stageOffer,
  'hired' => l10n.stageHired,
  'rejected' => l10n.stageRejected,
  'withdrawn' => l10n.stageWithdrawn,
  _ => l10n.stageSubmitted,
};

/// The badge for one of §8.1's eight application stages.
///
/// One function, because the design system's named constructors *are* the
/// vocabulary. An unrecognised stage falls back to `submitted` rather than
/// throwing — the same rule as an unknown field kind.
Widget stageBadge(String status, AppL10n l10n) => switch (status) {
  'viewed' => HhBadge.applicationViewed(label: l10n.stageViewed),
  'shortlisted' => HhBadge.applicationShortlisted(
    label: l10n.stageShortlisted,
  ),
  'interview' => HhBadge.applicationInterview(label: l10n.stageInterview),
  'offer' => HhBadge.applicationOffer(label: l10n.stageOffer),
  'hired' => HhBadge.applicationHired(label: l10n.stageHired),
  'rejected' => HhBadge.applicationRejected(label: l10n.stageRejected),
  'withdrawn' => HhBadge.applicationWithdrawn(label: l10n.stageWithdrawn),
  _ => HhBadge.applicationSubmitted(label: l10n.stageSubmitted),
};

/// The candidate's applications and invitations — §8.1 and §8.2 (UAT-07).
///
/// ## Why the invitations live behind a segment rather than a tab
///
/// §8.2's invitations are the candidate's other correspondence with employers,
/// and they want a home beside the applications rather than buried under one.
/// A sixth bottom-nav destination is not available: the design caps the bar at
/// five, `HhBottomNav` asserts it, and round 1 fixed the bar at a constant
/// 70pt with two-line labels already tight at 320pt.
///
/// So the two lists share this tab and a segmented control chooses between
/// them. The distinction is real and worth keeping visible: an application is
/// something the candidate started, an invitation is something addressed to
/// them, and only the second one has actions waiting.
class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HhSpace.gutter,
                HhSpace.gutter,
                HhSpace.gutter,
                0,
              ),
              child: HhSegmented(
                labels: [l10n.navApplications, l10n.navInvitations],
                selectedIndex: _segment,
                onChanged: (i) => setState(() => _segment = i),
              ),
            ),
            Expanded(
              child: _segment == 0
                  ? const _Applications()
                  : const InvitationsInboxScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

/// §8.1's own list: what this candidate applied to, and where each one got to.
class _Applications extends ConsumerWidget {
  const _Applications();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final applications = ref.watch(myApplicationsProvider);

    return switch (applications) {
      AsyncValue(hasError: true, :final error?) => Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhErrorState(
          title: l10n.stateErrorTitle,
          message: error is ApiException ? error.message : l10n.stateErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(myApplicationsProvider),
        ),
      ),
      AsyncData(:final value) when value.isEmpty => HhEmptyState(
        title: l10n.stateEmptyTitle,
        message: l10n.applicationsEmpty,
        art: HhSpotArt.first,
      ),
      AsyncData(:final value) => ListView.builder(
        padding: const EdgeInsets.all(HhSpace.gutter),
        itemCount: value.length,
        itemBuilder: (context, index) => _Row(application: value[index]),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Row extends ConsumerStatefulWidget {
  const _Row({required this.application});

  final Application application;

  @override
  ConsumerState<_Row> createState() => _RowState();
}

class _RowState extends ConsumerState<_Row> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final application = widget.application;

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stageBadge(application.status, l10n),

            // Which job this is. The row carried a stage badge and nothing else
            // until §8.3 needed it: an interview card saying "Tuesday 14:00, in
            // person, at this address" is unusable if the candidate cannot tell
            // *which* application it belongs to, and a list of bare stage
            // badges was not much better. `Application` carries only a
            // `vacancyId`, so the posting is fetched per row — the same
            // treatment, for the same reason, as an §8.2 invitation's subject.
            const SizedBox(height: HhSpace.sm),
            _VacancyLine(vacancyId: application.vacancyId),

            // §8.3, from a single request for every interview this candidate
            // has. Placed on the application because that is where an interview
            // belongs and where a candidate looks: the stage badge above says
            // "Interview", and this says when, what kind and where.
            _Interviews(applicationId: application.id),

            if (application.rejectionReason case final reason?
                when reason.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              // The employer's own words, shown to the candidate (§8.1) and
              // never translated (§2.4).
              Text(reason, style: HhTypography.body),
            ],

            // Only while the application is live: withdrawing is the
            // candidate's own transition, but a finished one has nothing to
            // withdraw from and the server would refuse.
            if (application.canWithdraw) ...[
              const SizedBox(height: HhSpace.sm),
              HhButton.text(
                label: l10n.applicationWithdraw,
                onPressed: _busy ? null : _withdraw,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _withdraw() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.applicationWithdrawTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.applicationWithdraw),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    setState(() => _busy = true);
    try {
      final repository = await ref.read(applicationRepositoryProvider.future);
      await repository.withdraw(widget.application.id);

      ref.invalidate(myApplicationsProvider);
      // Withdrawing frees the candidate to apply again (BR-07), so every feed
      // that shows an Apply button is now wrong.
      for (final feed in Feed.values) {
        ref.invalidate(vacancyFeedProvider(feed));
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Which vacancy an application is for.
///
/// Fetched per row because [Application] carries only a `vacancyId` — the same
/// shape as an §8.2 invitation's subject, and handled the same way: a 404 is an
/// ordinary outcome here rather than a fault, since a candidate must still be
/// able to see what became of something they applied to after the posting
/// closed (UAT-15 draws the same distinction on the feed).
class _VacancyLine extends ConsumerWidget {
  const _VacancyLine({required this.vacancyId});

  final String vacancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(vacancyDetailProvider(vacancyId));
    final muted = HhTypography.caption.copyWith(color: HhColors.inkMuted);

    return switch (detail) {
      AsyncValue(hasError: true, :final error?) => Text(
        error is ApiException && error.statusCode == 404
            ? l10n.vacancyGoneTitle
            : l10n.invitationVacancyUnavailable,
        style: muted,
      ),
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.item.title ?? l10n.invitationVacancyUntitled,
            style: HhTypography.subtitle.copyWith(fontSize: 15),
          ),
          if (value.item.employer.name case final name? when name.isNotEmpty)
            Text(name, style: muted),
        ],
      ),
      // A title still loading is a line of muted text, not a spinner: a card
      // that reserves the space and fills it in reads better in a list than one
      // flickering a progress indicator per row.
      _ => Text(l10n.invitationVacancyLoading, style: muted),
    };
  }
}

/// This application's interviews (§8.3), or nothing.
///
/// Reads the grouped map rather than fetching per application: one request
/// covers a list of any length, and an application with no interview — the
/// common case — costs no request at all and renders nothing.
///
/// A failure renders nothing too, deliberately. The row's own job is §8.1's
/// stage, and an error box about interviews inside every card would turn one
/// failed request into a list that looks broken.
class _Interviews extends ConsumerWidget {
  const _Interviews({required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(myInterviewsByApplicationProvider).value;
    final interviews = grouped?[applicationId] ?? const <Interview>[];
    if (interviews.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final interview in interviews)
          Padding(
            padding: const EdgeInsets.only(top: HhSpace.md),
            child: InterviewCard(interview: interview),
          ),
      ],
    );
  }
}
