import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_form_sheet.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_labels.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// One application's interviews, from the employer's side (§8.3).
///
/// ## The route is the one open to both sides, and that is the whole reason
///
/// `GET /interviews/mine` carries `@RequireRole('candidate')`, so this cannot
/// reuse the candidate's single grouped request; the per-application route is
/// open to either participant and is what this asks. The cost is one request
/// per applicant row, which is why it is mounted where an employer is already
/// looking at one application rather than on every row of every list.
///
/// What is genuinely missing is an employer's **aggregate** list, which is why
/// §6.2's dashboard shows three counts instead of four. That blocks a metric,
/// not this screen.
///
/// ## The platform offset comes from the server, never from Dart
///
/// Scheduling has to run `ZonedTimestamp`'s conversion backwards — a picked
/// date and time into an instant — and that needs the platform's offset. It is
/// read from [applicationCreatedAt], a timestamp the server sent about this
/// very application, because a `+05:00` constant in the client would be a
/// second source of truth for the platform zone. If that string is unreadable
/// the control is **not offered**: scheduling an interview an hour off is worse
/// than not scheduling one from this screen.
class EmployerInterviews extends ConsumerWidget {
  const EmployerInterviews({
    required this.applicationId,
    required this.applicationCreatedAt,
    super.key,
  });

  final String applicationId;

  /// Any timestamp the server sent about this application, used only for its
  /// offset.
  final String applicationCreatedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final offset = _platformOffset;
    final interviews = ref.watch(
      applicationInterviewsProvider(applicationId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A failure renders nothing rather than an error box inside a card: the
        // row's own job is §8.1's stage, and one failed request should not make
        // every applicant look broken. The employer can still schedule.
        for (final interview in interviews.value ?? const <Interview>[])
          Padding(
            padding: const EdgeInsets.only(top: HhSpace.sm),
            child: _Row(
              interview: interview,
              applicationId: applicationId,
              offset: offset,
            ),
          ),

        if (offset != null) ...[
          const SizedBox(height: HhSpace.sm),
          HhButton.text(
            label: l10n.interviewSchedule,
            onPressed: () => showInterviewForm(
              context,
              applicationId: applicationId,
              platformOffset: offset,
            ),
          ),
        ],
      ],
    );
  }

  /// The platform's offset, or null when the timestamp cannot be read.
  Duration? get _platformOffset {
    try {
      return ZonedTimestamp.parse(applicationCreatedAt).offset;
    } on FormatException {
      // A timestamp with no offset is a contract violation the repository layer
      // already shouts about elsewhere. Here it costs the scheduling control,
      // which is the safe direction.
      return null;
    }
  }
}

/// One interview, with the two things §8.3 gives the employer: move it, or call
/// it off.
class _Row extends StatelessWidget {
  const _Row({
    required this.interview,
    required this.applicationId,
    required this.offset,
  });

  final Interview interview;
  final String applicationId;
  final Duration? offset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HhSpace.md),
      decoration: const BoxDecoration(
        color: HhColors.surfaceMuted,
        borderRadius: HhRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A Wrap, not a Row: a badge is icon plus word and must not truncate,
          // and "Another time asked" beside a full date does not fit 320pt at
          // 2.0x.
          Wrap(
            spacing: HhSpace.sm,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              interviewStatusBadge(interview.status, l10n),
              Text(
                wallClockStamp(interview.scheduledAt.wallClock),
                style: HhTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: HhColors.brand900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            interviewTypeLabel(interview.type, l10n),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),

          // What the candidate said, in their own words (§2.4). The employer's
          // reason for wanting it is the point of the whole feature: "another
          // time please" is useless without the times.
          if (interview.responseNote case final note? when note.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            Text(l10n.interviewCandidateReply, style: HhTypography.overline),
            Text(note, style: HhTypography.body),
          ],

          // Cancelling is §8.3's only ending, so a cancelled interview offers
          // nothing: rescheduling one would be reviving it, which the server
          // refuses with `interview.final`.
          if (!interview.isCancelled) ...[
            const SizedBox(height: HhSpace.sm),
            Wrap(
              spacing: HhSpace.sm,
              runSpacing: HhSpace.sm,
              children: [
                if (offset case final offset?)
                  HhButton.text(
                    label: l10n.interviewReschedule,
                    onPressed: () => showInterviewForm(
                      context,
                      applicationId: applicationId,
                      platformOffset: offset,
                      existing: interview,
                    ),
                  ),
                HhButton.text(
                  label: l10n.interviewCancelAction,
                  onPressed: () => showCancelInterviewSheet(
                    context,
                    interview: interview,
                    applicationId: applicationId,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
