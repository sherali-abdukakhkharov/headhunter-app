import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_labels.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_response_sheet.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// One interview as the candidate sees it (§8.3, UAT-09).
///
/// ## It lives on the application, not in a list of its own
///
/// §8.3 hangs an interview off an application, and that is where a candidate
/// looks for it: the stage badge says "Interview", and this says *when*, *what
/// kind* and *where*. A separate destination would need a sixth bottom-nav tab,
/// which the design caps at five, or a third segment on the applications tab —
/// and "Собеседования" does not fit a third of 360pt on one line, the same
/// measurement that kept §8.2's status filter off `HhSegmented`.
///
/// ## The time is the wall clock the platform recorded
///
/// Never `.toLocal()`. Every machine on this project sits at UTC+5, so a
/// `.toLocal()` bug prints the right time all through development and shows a
/// candidate in Moscow an interview two hours early. [Interview.hasPassed]
/// compares **instants** for the same reason, in the direction that cannot hide
/// an interview which has not happened yet.
///
/// ## A link is copied, not opened
///
/// Opening one needs `url_launcher`, and pubspec.yaml's bounds are load-bearing
/// (CLAUDE.md). So the link is copyable, exactly as the contact block handles a
/// phone number — the browser takes it from the clipboard, and no dependency
/// enters the build for it. §2.4 also puts a built-in video engine out of
/// scope, so this is somebody else's meeting URL and nothing more.
class InterviewCard extends StatelessWidget {
  const InterviewCard({required this.interview, super.key});

  final Interview interview;

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
          // A Wrap, not a Row: a badge is icon **plus word**, so it must not be
          // the thing that yields, and "Another time requested" beside a full
          // date does not fit 320pt at 2.0x. The stamp drops to its own line.
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

          const SizedBox(height: HhSpace.sm),
          Text(
            interviewTypeLabel(interview.type, l10n),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),

          // A phone interview carries no detail field at all, so without this
          // it would render as a time and a word. The number is the candidate's
          // own and already verified (BR-01), which is exactly why the employer
          // was not asked to retype it — and why the candidate has to be told
          // that is what will be called.
          if (interview.type == InterviewType.phone) ...[
            const SizedBox(height: 2),
            Text(
              l10n.interviewPhoneNote,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ],

          if (interview.location case final location?
              when location.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            _Detail(
              iconPath: HhIconPath.location,
              label: l10n.interviewWhere,
              value: location,
            ),
          ],

          if (interview.meetingLink case final link? when link.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            _Detail(
              iconPath: HhIconPath.globe,
              label: l10n.interviewLink,
              value: link,
              onCopy: () => _copy(context, link, l10n),
            ),
          ],

          if (interview.instructions case final notes?
              when notes.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            _Detail(
              iconPath: HhIconPath.document,
              label: l10n.interviewInstructions,
              // The employer's own words (§8.3, §2.4): never translated and
              // never trimmed to a preview — "bring your diploma" is exactly
              // the sentence that must survive whole.
              value: notes,
            ),
          ],

          if (interview.responseNote case final note? when note.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            _Detail(
              iconPath: HhIconPath.chat,
              label: l10n.interviewYourReply,
              value: note,
            ),
          ],

          if (interview.isCancelled) ...[
            const SizedBox(height: HhSpace.sm),
            Text(
              l10n.interviewCancelledNotice,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ] else if (interview.hasPassed) ...[
            // Said rather than hidden: an interview whose time has gone by is
            // still the record of what was arranged, and a candidate who missed
            // one needs to see that they did. The actions stay on offer because
            // the server still accepts them — a candidate who was ill can still
            // ask for another time, and refusing here would be the client
            // deciding on the employer's behalf that it is too late.
            const SizedBox(height: HhSpace.sm),
            Text(
              l10n.interviewPassed,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ],

          if (interview.availableResponses.isNotEmpty) ...[
            const SizedBox(height: HhSpace.md),
            Wrap(
              spacing: HhSpace.sm,
              runSpacing: HhSpace.sm,
              children: [
                for (final response in interview.availableResponses)
                  // Confirming is the filled button where it is on offer,
                  // because it is the answer that lets the interview happen.
                  // Asking for another time is a real alternative rather than a
                  // lesser one, so it is secondary and never hidden.
                  if (response == InterviewStatus.confirmed)
                    HhButton(
                      label: interviewResponseLabel(response, l10n),
                      expand: false,
                      compact: true,
                      onPressed: () => showInterviewResponseSheet(
                        context,
                        interview,
                        response,
                      ),
                    )
                  else
                    HhButton.secondary(
                      label: interviewResponseLabel(response, l10n),
                      expand: false,
                      compact: true,
                      onPressed: () => showInterviewResponseSheet(
                        context,
                        interview,
                        response,
                      ),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    String value,
    AppL10n l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(l10n.commonCopied)));
  }
}

/// One labelled line of the interview: a glyph, what it is, and the value.
class _Detail extends StatelessWidget {
  const _Detail({
    required this.iconPath,
    required this.label,
    required this.value,
    this.onCopy,
  });

  final String iconPath;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: HhIcon(
          iconPath,
          size: 15,
          color: HhColors.inkMuted,
          strokeWidth: 2,
        ),
      ),
      const SizedBox(width: HhSpace.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: HhTypography.overline),
            const SizedBox(height: 1),
            Text(value, style: HhTypography.body),
          ],
        ),
      ),
      // A trailing **word**, which is the row idiom `ProtectedContactCard`
      // already uses for a copyable value. Not an icon: there is no copy glyph
      // in the set, and inventing one for a single call site is how a glyph
      // vocabulary stops meaning anything.
      if (onCopy case final copy?) ...[
        const SizedBox(width: HhSpace.sm),
        Semantics(
          button: true,
          label: '${AppL10n.of(context).commonCopy} $label',
          child: InkWell(
            onTap: copy,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 9,
              ),
              child: Text(
                AppL10n.of(context).commonCopy,
                style: HhTypography.meta.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HhColors.brand600,
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
