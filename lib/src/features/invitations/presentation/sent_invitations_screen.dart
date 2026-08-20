import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/candidate_detail_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_status_badge.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_subject.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_status.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';
import 'package:jobbridge_app/src/shared/widgets/refreshable_fill.dart';

/// Opens the employer's sent invitations (§8.2), optionally for one vacancy.
Future<void> showSentInvitations(
  BuildContext context, {
  String? vacancyId,
}) => Navigator.of(context, rootNavigator: true).push<void>(
  MaterialPageRoute(
    builder: (_) => SentInvitationsScreen(vacancyId: vacancyId),
  ),
);

/// What this employer has sent, and what came back (§8.2, §7.4, UAT-07).
///
/// ## The status filter is the server's, and that matters
///
/// `GET /invitations/sent` takes `vacancyId` and `status`, unlike the Coin
/// ledger which takes neither — so a filtered list here is **complete**, not
/// filtered-over-what-was-loaded, and "Accepted" means every acceptance
/// rather than the acceptances in the first page. That is why the chips pass
/// the status down to the request instead of running `where` over a loaded
/// list, and why there is no "showing 3 of possibly more" caveat.
///
/// ## The two rows that need doing something about
///
/// **Accepted** is the one that pays: BR-09's `expose()` grants contact
/// details *and* files on an accepted invitation, at the same strength as an
/// application and without a Coin — and it survives a candidate hiding a
/// profile,
/// because the hidden branch only fires when there is no application, no
/// accepted invitation and no unlock. So an acceptance is announced rather than
/// left as a badge, since the employer's next move is to phone somebody and
/// nothing else on this screen says they now can.
///
/// **Details requested** is the other: it carries the candidate's question in
/// `responseNote`, and a question nobody sees is worse than no question. §8.2
/// gives the employer no reply route — the answer goes through chat (§9) or a
/// second invitation — so this screen's job is to make sure it is read.
///
/// ## Why no candidate name yet
///
/// [Invitation.candidateName] is a field the server does not send yet, and the
/// obvious client-side substitute is the wrong one: the only route returning a
/// candidate logs a protected-data access per call (§11.1) and its contract
/// says it "is never called speculatively", so resolving thirty rows would
/// write
/// thirty audit entries nobody asked for. The name is a backend ask, parsed
/// already, and rendered the day it arrives. Until then a row is identified by
/// what was sent, and "View candidate" is the deliberate access.
class SentInvitationsScreen extends ConsumerStatefulWidget {
  const SentInvitationsScreen({super.key, this.vacancyId});

  /// When set, the server narrows the list and the vacancy is not repeated on
  /// every row — the employer arrived from it and already knows.
  final String? vacancyId;

  @override
  ConsumerState<SentInvitationsScreen> createState() =>
      _SentInvitationsScreenState();
}

class _SentInvitationsScreenState extends ConsumerState<SentInvitationsScreen> {
  /// Null is "all", and is deliberately not a fifth [InvitationStatus] — the
  /// server's absent-parameter means unfiltered, so the client's absent value
  /// should too rather than mapping a sentinel onto it.
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final provider = sentInvitationsProvider(
      vacancyId: widget.vacancyId,
      status: _status,
    );
    final invitations = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invitationsSentTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(HhSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.vacancyId != null) ...[
                    HhMetaChip(
                      label: l10n.invitationsSentForVacancy,
                      iconPath: HhIconPath.briefcase,
                    ),
                    const SizedBox(height: HhSpace.md),
                  ],
                  _StatusFilter(
                    status: _status,
                    onChanged: (next) => setState(() => _status = next),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(provider),
                child: switch (invitations) {
                  // Error before any loading arm: retry is off app-wide, so a
                  // failure is terminal and a spinner over it would be
                  // permanent.
                  AsyncValue(hasError: true, :final error?) => RefreshableFill(
                    child: Padding(
                      padding: const EdgeInsets.all(HhSpace.gutter),
                      child: HhErrorState(
                        title: l10n.stateErrorTitle,
                        message: error is ApiException
                            ? error.message
                            : l10n.stateErrorBody,
                        retryLabel: l10n.commonRetry,
                        onRetry: () => ref.invalidate(provider),
                      ),
                    ),
                  ),
                  AsyncData(:final value) when value.isEmpty =>
                    RefreshableFill(
                      child: Padding(
                        padding: const EdgeInsets.all(HhSpace.gutter),
                        // A filter that matched nothing is a different fact
                        // from having invited nobody: one is fixed by clearing
                        // the filter, the other by using the app. Saying "you
                        // have invited nobody" to an employer looking at
                        // "Declined" would be false.
                        child: _status == null
                            ? HhEmptyState(
                                title: l10n.stateEmptyTitle,
                                message: l10n.invitationsSentEmpty,
                              )
                            : HhEmptyState(
                                title: l10n.stateEmptyTitle,
                                message: l10n.invitationsSentNoMatch,
                                actionLabel: l10n.filtersReset,
                                onAction: () =>
                                    setState(() => _status = null),
                              ),
                      ),
                    ),
                  AsyncData(:final value) => ListView.builder(
                    padding: const EdgeInsets.all(HhSpace.gutter),
                    itemCount: value.length,
                    itemBuilder: (context, index) => _SentCard(
                      invitation: value[index],
                      // Suppressed only when the screen itself is scoped: on
                      // the unscoped list an employer with several postings
                      // cannot tell the rows apart without it.
                      showVacancy: widget.vacancyId == null,
                    ),
                  ),
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

/// §8.2's four statuses plus "all", as chips rather than a segmented control.
///
/// `HhSegmented` divides its width equally and clips to one line, which at
/// 360pt gives each of five segments about 66pt — not enough for "Details
/// requested" in any of the four interface variants. Chips size to their label
/// and scroll, so the longest status keeps its whole word; a status filter
/// whose labels are truncated is a filter nobody can use.
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.status, required this.onChanged});

  final String? status;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Built from the server's own status list, so a fifth status added
    // server-side needs a label here and nothing else.
    final options = <(String?, String)>[
      (null, l10n.invitationFilterAll),
      for (final code in InvitationStatus.all)
        (code, invitationStatusLabel(code, l10n)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, (code, label)) in options.indexed) ...[
            if (index > 0) const SizedBox(width: HhSpace.sm),
            HhFilterChip(
              label: label,
              selected: code == status,
              onTap: () => onChanged(code),
            ),
          ],
        ],
      ),
    );
  }
}

/// One sent invitation.
class _SentCard extends StatelessWidget {
  const _SentCard({required this.invitation, required this.showVacancy});

  final Invitation invitation;
  final bool showVacancy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A Wrap, not a Row with a Spacer: "Details requested" beside a
            // timestamp overflowed a 360pt card by 32pt on the inbox, and a
            // badge must not be the thing that yields — truncating it puts the
            // state back on colour alone.
            Wrap(
              spacing: HhSpace.sm,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                invitationStatusBadge(invitation.status, l10n),
                Text(
                  wallClockStamp(invitation.createdAt.wallClock),
                  style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: HhSpace.md),

            if (invitation.candidateName case final name? when name.isNotEmpty)
              Text(
                name,
                style: HhTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

            if (invitation.isGeneral)
              InvitationGeneralSubject(invitation: invitation)
            else if (showVacancy)
              _VacancyLine(vacancyId: invitation.vacancyId!),

            if (invitation.message case final message?
                when message.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              // The employer's own pitch, played back. Worth the space: with
              // thirty invitations out, which one this was is the question, and
              // for a candidate's question it is the half that gives the
              // question its meaning.
              Text(l10n.invitationYourMessage, style: HhTypography.overline),
              Text(message, style: HhTypography.body),
            ],

            if (invitation.responseNote case final note?
                when note.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              _CandidateReply(note: note),
            ],

            if (invitation.opensContact) ...[
              const SizedBox(height: HhSpace.md),
              HhNotice.done(
                title: l10n.invitationContactOpenTitle,
                message: l10n.invitationContactOpenBody,
              ),
            ],

            const SizedBox(height: HhSpace.md),
            HhButton.text(
              label: l10n.invitationOpenCandidate,
              // Every open is a logged protected-data access (§11.1), so it is
              // a tap and never a prefetch.
              onPressed: () => showCandidateDetail(
                context,
                candidateUserId: invitation.candidateUserId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Which of the employer's own postings this invitation names.
///
/// Resolved from [myVacanciesProvider] — one request for the whole list, then a
/// local lookup — rather than per row. The candidate side's equivalent fetches
/// each vacancy from `GET /discovery/vacancies/:id`, which is on a controller
/// carrying `@RequireRole('candidate')`: an employer calling it gets 403.
///
/// A vacancy missing from the list renders as nothing rather than as an error.
/// It should not happen — `/vacancies/mine` returns every status including
/// closed — and if it ever does, a silent gap costs the employer less than a
/// red line about a posting they can no longer act on.
class _VacancyLine extends ConsumerWidget {
  const _VacancyLine({required this.vacancyId});

  final String vacancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final vacancies = ref.watch(myVacanciesProvider);

    return switch (vacancies) {
      AsyncData(:final value) => switch (value.where(
        (v) => v.id == vacancyId,
      ).firstOrNull) {
        final vacancy? => Text(
          vacancyTitle(vacancy, l10n),
          style: HhTypography.subtitle,
        ),
        _ => const SizedBox.shrink(),
      },
      _ => Text(
        l10n.invitationVacancyLoading,
        style: HhTypography.body.copyWith(color: HhColors.inkMuted),
      ),
    };
  }
}

/// What the candidate said back, and on `details_requested` what they asked.
///
/// The mirror of the inbox's own-reply block, with a different label: the same
/// words, and whose they are is the whole difference.
class _CandidateReply extends StatelessWidget {
  const _CandidateReply({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HhSpace.md),
      decoration: const BoxDecoration(
        color: HhColors.surfaceMuted,
        borderRadius: HhRadius.inputAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.invitationCandidateReply, style: HhTypography.overline),
          const SizedBox(height: 2),
          // The candidate's own words (§2.4), never translated and never cut to
          // a preview.
          Text(note, style: HhTypography.body),
        ],
      ),
    );
  }
}
