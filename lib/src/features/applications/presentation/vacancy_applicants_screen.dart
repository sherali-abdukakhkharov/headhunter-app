import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/data/employer_applications_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:jobbridge_app/src/features/applications/domain/application_stage.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/applications/presentation/applications_screen.dart';
import 'package:jobbridge_app/src/features/applications/presentation/exposure_explanation.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/sent_invitations_screen.dart';

/// Applications on one vacancy, for the employer (§6.5, §8.1).
class VacancyApplicantsScreen extends ConsumerWidget {
  const VacancyApplicantsScreen({required this.vacancyId, super.key});

  final String vacancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final applications = ref.watch(vacancyApplicationsProvider(vacancyId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vacancyApplicants)),
      body: SafeArea(
        child: Column(
          children: [
            _Counts(vacancyId: vacancyId),

            Expanded(
              child: switch (applications) {
                AsyncValue(hasError: true, :final error?) => Padding(
                  padding: const EdgeInsets.all(HhSpace.gutter),
                  child: HhErrorState(
                    title: l10n.stateErrorTitle,
                    message: error is ApiException
                        ? error.message
                        : l10n.stateErrorBody,
                    retryLabel: l10n.commonRetry,
                    onRetry: () => ref.invalidate(
                      vacancyApplicationsProvider(vacancyId),
                    ),
                  ),
                ),
                AsyncData(:final value) when value.isEmpty => HhEmptyState(
                  title: l10n.stateEmptyTitle,
                  message: l10n.vacancyApplicantsEmpty,
                ),
                AsyncData(:final value) => ListView.builder(
                  padding: const EdgeInsets.all(HhSpace.gutter),
                  itemCount: value.length,
                  itemBuilder: (context, index) => _ApplicantRow(
                    application: value[index],
                    vacancyId: vacancyId,
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// §7.4 step 7's four counts, in the one place the specification asks for them.
///
/// "Track invited, accepted, interviewed, and hired counts against the target
/// of 20" needs **two endpoints**: invited and accepted are invitation states,
/// while interviewed and hired are application stages. The server says so
/// itself on `GET /invitations/counts/:vacancyId` — "the last two are
/// application stages and come from `/vacancies/{id}/applications/counts`" — so
/// joining them is the client's job, and this card is where it happens.
///
/// ## Either half may be missing, and the other still shows
///
/// Two providers, watched independently rather than awaited together. A vacancy
/// whose invitation counts 404 still shows its hiring progress, and a card that
/// vanished because one of two requests failed would read as "no applicants".
class _Counts extends ConsumerWidget {
  const _Counts({required this.vacancyId});

  final String vacancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(vacancyApplicationCountsProvider(vacancyId));
    final invitations = ref.watch(invitationCountsProvider(vacancyId));

    final sections = <Widget>[
      if (applications case AsyncData(:final value))
        _Applications(counts: value),
      if (invitations case AsyncData(:final value) when _invited(value) > 0)
        _Invitations(byStatus: value, vacancyId: vacancyId),
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(HhSpace.gutter),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, section) in sections.indexed) ...[
              if (index > 0) const SizedBox(height: HhSpace.md),
              section,
            ],
          ],
        ),
      ),
    );
  }
}

/// §7.4's "invited", which is **not** the count of `sent`.
///
/// A candidate who answered was still invited, so summing every status is the
/// only reading that does not fall as replies arrive — and `byStatus.sent`
/// would have looked right for as long as nobody had answered yet. Summing it
/// also counts a fifth status this build has never heard of, which is why
/// [InvitationRepository.countsForVacancy] returns the server's map rather than
/// a typed pair.
int _invited(Map<String, int> byStatus) =>
    byStatus.values.fold(0, (sum, count) => sum + count);

/// §6.5's hired-against-required, plus the per-stage grouping.
class _Applications extends StatelessWidget {
  const _Applications({required this.counts});

  final ApplicationCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // A vacancy need not state a worker count, and inventing a
          // denominator would be inventing a target.
          switch (counts.workerCount) {
            final target? => l10n.applicationsHired(counts.hiredCount, target),
            _ => l10n.applicationsHiredNoTarget(counts.hiredCount),
          },
          style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),

        if (counts.byStatus.isNotEmpty) ...[
          const SizedBox(height: HhSpace.sm),
          Wrap(
            spacing: HhSpace.sm,
            runSpacing: 4,
            children: [
              for (final entry in counts.byStatus.entries)
                if (entry.value > 0)
                  Text(
                    '${stageLabel(entry.key, l10n)}: ${entry.value}',
                    style: HhTypography.caption.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
            ],
          ),
        ],
      ],
    );
  }
}

/// §7.4's invited and accepted, and the way through to who they were.
class _Invitations extends StatelessWidget {
  const _Invitations({required this.byStatus, required this.vacancyId});

  final Map<String, int> byStatus;
  final String vacancyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.invitationCounts(
            _invited(byStatus),
            byStatus[InvitationStatus.accepted] ?? 0,
          ),
          style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),
        // A count with nowhere to go answers "how many" and leaves "who"
        // unanswerable, and on `details_requested` the who is holding a
        // question. Scoped to this vacancy, server-side.
        HhButton.text(
          label: l10n.invitationsSentTitle,
          onPressed: () => showSentInvitations(context, vacancyId: vacancyId),
        ),
      ],
    );
  }
}

class _ApplicantRow extends ConsumerStatefulWidget {
  const _ApplicantRow({required this.application, required this.vacancyId});

  final Application application;
  final String vacancyId;

  @override
  ConsumerState<_ApplicantRow> createState() => _ApplicantRowState();
}

class _ApplicantRowState extends ConsumerState<_ApplicantRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final application = widget.application;
    final next = ApplicationStage.nextFor(application.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stageBadge(application.status, l10n),

            if (application.coverNote case final note?
                when note.isNotEmpty) ...[
              const SizedBox(height: HhSpace.sm),
              Text(note, style: HhTypography.caption),
            ],

            const SizedBox(height: HhSpace.sm),
            _CandidateSummary(applicationId: application.id),

            // Forward only, skipping allowed (§8.1). A terminal stage yields
            // nothing, so the control disappears rather than offering a move
            // the server refuses.
            if (next.isNotEmpty) ...[
              const SizedBox(height: HhSpace.sm),
              Wrap(
                spacing: HhSpace.sm,
                children: [
                  for (final stage in next)
                    HhButton.text(
                      label: stageLabel(stage, l10n),
                      onPressed: _busy ? null : () => _move(stage),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _move(String stage) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref
          .read(employerApplicationsRepositoryProvider)
          .moveStage(widget.application.id, stage);

      // Both: the row's badge and §6.5's counts, which a hire changes.
      ref
        ..invalidate(vacancyApplicationsProvider(widget.vacancyId))
        ..invalidate(vacancyApplicationCountsProvider(widget.vacancyId));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// What BR-09 lets this employer see of the candidate.
class _CandidateSummary extends ConsumerWidget {
  const _CandidateSummary({required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final candidate = ref.watch(applicationCandidateProvider(applicationId));

    return switch (candidate) {
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value.fullName case final name? when name.isNotEmpty)
            Text(
              name,
              style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),

          if (value.regionId case final regionId?)
            DictionaryLabel(
              type: DictionaryType.region,
              id: regionId,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),

          Text(
            l10n.candidateCompleteness(value.completenessPercent),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),

          const SizedBox(height: 4),
          _Phone(candidate: value),

          if (!value.canViewFiles)
            Text(
              l10n.candidateFilesHidden,
              style: HhTypography.caption.copyWith(
                color: HhColors.inkDisabled,
              ),
            )
          else
            for (final file in value.files)
              Text(file.fileName, style: HhTypography.caption),
        ],
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// BR-09 on screen.
///
/// The phone is rendered **only** when the server sent one. Null is a normal
/// answer, so the absence is stated rather than left as a blank line that
/// looks like a loading failure — and there is deliberately nothing here that
/// could reconstruct a number the server withheld.
class _Phone extends StatelessWidget {
  const _Phone({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (candidate.phone case final phone? when phone.isNotEmpty) {
      return Text(phone, style: HhTypography.body);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.candidatePhoneHidden,
          style: HhTypography.caption.copyWith(color: HhColors.inkDisabled),
        ),
        // The specific reason, not a generic line. On this screen the usual
        // answer is that contact *was* allowed and the candidate simply has no
        // number on file — which is a different fact from "withheld", and the
        // one an employer would otherwise misread.
        Text(
          exposureExplanation(candidate.exposureReason, l10n),
          style: HhTypography.caption.copyWith(color: HhColors.inkDisabled),
        ),
      ],
    );
  }
}
