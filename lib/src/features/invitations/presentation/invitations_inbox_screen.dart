import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_detail_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_response_sheet.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_status_badge.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_subject.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// The candidate's invitation inbox (§8.2, UAT-07).
///
/// ## Nothing here is ever gated on money
///
/// §8.2's entitlement is the **employer's**, and the 2026-08-10 revision did
/// not change that. A candidate who has been invited has already had whatever
/// was paid for spent on them, so a paywall here would charge the wrong person
/// for somebody else's decision. There is deliberately no balance, no price and
/// no unlock anywhere in this file — the same rule §9.1 states for chat.
///
/// ## Two shapes render differently, and one of them can be gone
///
/// A vacancy invitation points at a posting, so it shows that posting — fetched
/// per row, because [Invitation] carries only the id. The inbox is deliberately
/// *not* filtered by whether the vacancy is still visible (a candidate needs to
/// see what became of something addressed to them), so a row may point at a
/// vacancy that answers 404. That is rendered as "no longer available" rather
/// than as a fault, the same distinction UAT-15 draws on the feed.
///
/// A general invitation has no posting to borrow from and carries its own
/// occupation, location, pay and schedule — every one of them a dictionary id
/// resolved for display (BR-13).
class InvitationsInboxScreen extends ConsumerWidget {
  const InvitationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final invitations = ref.watch(receivedInvitationsProvider);

    return switch (invitations) {
      // Error first, before any loading arm: with Riverpod's retry disabled a
      // failure is terminal, and a spinner over it would be permanent.
      AsyncValue(hasError: true, :final error?) => Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhErrorState(
          title: l10n.stateErrorTitle,
          message: error is ApiException ? error.message : l10n.stateErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(receivedInvitationsProvider),
        ),
      ),
      AsyncData(:final value) when value.isEmpty => HhEmptyState(
        title: l10n.stateEmptyTitle,
        message: l10n.invitationsInboxEmpty,
        // The default neutral drawing, deliberately: nothing a candidate does
        // fills this list — an employer has to write first.
      ),
      AsyncData(:final value) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(receivedInvitationsProvider),
        child: ListView.builder(
          padding: const EdgeInsets.all(HhSpace.gutter),
          itemCount: value.length,
          itemBuilder: (context, index) =>
              _InvitationCard(invitation: value[index]),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A Wrap and not a Row with a Spacer, which is what this was and
            // which overflowed by 32pt at 360 wide: "Details requested" plus a
            // timestamp needs 330 of the card's 298, and Russian and 2.0x text
            // scale both make it worse. A badge must not be the thing that
            // yields — it is icon **plus word**, and a truncated word puts the
            // state back on colour alone — so the stamp drops to its own line
            // instead.
            Wrap(
              spacing: HhSpace.sm,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                invitationStatusBadge(
                  invitation.status,
                  l10n,
                  received: true,
                ),
                Text(
                  wallClockStamp(invitation.createdAt.wallClock),
                  style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: HhSpace.md),

            if (invitation.isGeneral)
              InvitationGeneralSubject(invitation: invitation)
            else
              _VacancySubject(invitation: invitation),

            if (invitation.message case final message?
                when message.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              // The employer's own words (§2.4), never translated and never
              // trimmed to a preview: this is the whole of what they wanted to
              // say, and a candidate deciding whether to accept needs all of
              // it.
              Text(message, style: HhTypography.body),
            ],

            if (invitation.responseNote case final note?
                when note.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              _OwnReply(note: note),
            ],

            if (invitation.availableResponses.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              _Responses(invitation: invitation),
            ],
          ],
        ),
      ),
    );
  }
}

/// A vacancy invitation: the posting it points at, or the fact that it is gone.
class _VacancySubject extends ConsumerWidget {
  const _VacancySubject({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final id = invitation.vacancyId!;
    final detail = ref.watch(vacancyDetailProvider(id));
    final muted = HhTypography.body.copyWith(color: HhColors.inkMuted);

    return switch (detail) {
      // 404 is an ordinary outcome here rather than a fault: this inbox shows
      // invitations to vacancies that have since closed, on purpose. Anything
      // else is a real failure and says so, so a candidate can tell "it is
      // gone" from "we could not reach the server".
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
            style: HhTypography.subtitle,
          ),
          if (value.item.employer.name case final name? when name.isNotEmpty)
            Text(name, style: muted),
          const SizedBox(height: HhSpace.sm),
          HhButton.text(
            label: l10n.invitationOpenVacancy,
            // No feed: an invitation names a vacancy directly, so there is no
            // list behind this screen to refresh on the way back.
            onPressed: () => showVacancyDetail(context, id: id),
          ),
        ],
      ),
      // A title still loading is a line of muted text, not a spinner: a card
      // that reserves the space and fills it in reads better in a list than one
      // flickering a progress indicator per row.
      _ => Text(l10n.invitationVacancyLoading, style: muted),
    };
  }
}

/// What the candidate already said, played back to them.
class _OwnReply extends StatelessWidget {
  const _OwnReply({required this.note});

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
          Text(l10n.invitationYourReply, style: HhTypography.overline),
          const SizedBox(height: 2),
          Text(note, style: HhTypography.body),
        ],
      ),
    );
  }
}

/// §8.2's three actions, minus the ones this invitation cannot take.
///
/// Rendered from [Invitation.availableResponses] rather than as a fixed row of
/// three, so an answered invitation offers nothing and one already at
/// `details_requested` no longer offers to ask again. The server refuses both,
/// and offering a refusal is worse than offering nothing.
class _Responses extends StatelessWidget {
  const _Responses({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Wrap(
      spacing: HhSpace.sm,
      runSpacing: HhSpace.sm,
      children: [
        for (final response in invitation.availableResponses)
          // Accept is the only filled button, because it is the only response
          // that changes what an employer can see. Declining and asking a
          // question are equal alternatives to each other, not lesser ones — a
          // candidate who wants to decline should not have to find the quiet
          // control.
          if (response == InvitationStatus.accepted)
            HhButton(
              label: invitationResponseLabel(response, l10n),
              expand: false,
              onPressed: () =>
                  showInvitationResponseSheet(context, invitation, response),
            )
          else
            HhButton.secondary(
              label: invitationResponseLabel(response, l10n),
              expand: false,
              onPressed: () =>
                  showInvitationResponseSheet(context, invitation, response),
            ),
      ],
    );
  }
}
