import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_labels.dart';

/// Confirms one of §8.3's two candidate responses, and sends it.
///
/// Returns the updated interview, or null if the candidate backed out or the
/// server refused.
Future<Interview?> showInterviewResponseSheet(
  BuildContext context,
  Interview interview,
  String response,
) => showModalBottomSheet<Interview>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _ResponseSheet(interview: interview, response: response),
);

/// §8.3's "confirm or request another time".
///
/// ## The note is required for "another time" and optional for "confirm"
///
/// The server takes it as optional on both. Requiring it here for
/// `reschedule_requested` is deliberate, and it is the same judgement the
/// invitation sheet makes about "Request details": *"the candidate wants
/// another time"* with no time attached is a message the employer cannot act
/// on, so the interview stalls while both sides wait for the other. Asking for
/// the answer in the same tap is cheaper than a round of messages.
///
/// Confirming takes an optional note, marked optional, because a confirmation
/// owes no explanation.
///
/// ## Neither answer is final, and the sheet does not pretend otherwise
///
/// §8.3's only ending is the employer cancelling. A candidate who confirms may
/// still ask for another time afterwards — plans change — so this sheet carries
/// none of the "this cannot be undone" weight the invitation's Accept does.
/// What it *does* say is what the employer will see, because that is the part
/// the candidate is deciding about.
class _ResponseSheet extends ConsumerStatefulWidget {
  const _ResponseSheet({required this.interview, required this.response});

  final Interview interview;

  /// One of [InterviewStatus.candidateResponses].
  final String response;

  @override
  ConsumerState<_ResponseSheet> createState() => _ResponseSheetState();
}

class _ResponseSheetState extends ConsumerState<_ResponseSheet> {
  final _note = TextEditingController();
  bool _busy = false;

  /// The server's refusal, held in the sheet rather than thrown at a snackbar:
  /// `interview.response_not_allowed` and `interview.final` both mean somebody
  /// moved first, and that is a sentence the candidate needs beside the button
  /// that failed rather than four seconds later at the bottom of the screen.
  String? _refusal;

  bool get _needsNote =>
      widget.response == InterviewStatus.rescheduleRequested;

  @override
  void initState() {
    super.initState();
    // Enables the send button the moment the field stops being empty, which is
    // the only thing that gates it.
    _note.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final trimmed = _note.text.trim();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          // Lifts the sheet clear of the keyboard, which the note field raises.
          padding: EdgeInsets.only(
            left: HhSpace.gutter,
            right: HhSpace.gutter,
            top: HhSpace.gutter,
            bottom: HhSpace.gutter + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: HhColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: HhSpace.lg),
                Text(
                  _needsNote
                      ? l10n.interviewRescheduleTitle
                      : l10n.interviewConfirmTitle,
                  style: HhTypography.subtitle,
                ),
                const SizedBox(height: HhSpace.sm),
                Text(
                  _needsNote
                      ? l10n.interviewRescheduleBody
                      : l10n.interviewConfirmBody,
                  style: HhTypography.body.copyWith(color: HhColors.inkMuted),
                ),

                const SizedBox(height: HhSpace.lg),
                HhTextField(
                  label: _needsNote
                      ? l10n.interviewNoteLabel
                      : l10n.interviewReplyNoteLabel,
                  controller: _note,
                  hintText: _needsNote
                      ? l10n.interviewNoteHint
                      : l10n.interviewReplyNoteHint,
                  maxLines: 3,
                  // The server's own ceiling (§8.3), so the field stops where
                  // the API would have refused rather than after it.
                  maxLength: 1000,
                  enabled: !_busy,
                ),

                if (_refusal case final refusal?) ...[
                  const SizedBox(height: HhSpace.md),
                  HhNotice.restricted(
                    title: l10n.interviewNotAllowed,
                    message: refusal,
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                HhButton(
                  label: interviewResponseLabel(widget.response, l10n),
                  loading: _busy,
                  onPressed: _needsNote && trimmed.isEmpty ? null : _send,
                ),
                const SizedBox(height: HhSpace.sm),
                HhButton.text(
                  label: l10n.commonCancel,
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final note = _note.text.trim();

    try {
      final updated = await ref
          .read(interviewRepositoryProvider)
          .respond(
            widget.interview.id,
            widget.response,
            note: note.isEmpty ? null : note,
          );

      ref
        ..invalidate(myInterviewsProvider)
        // BR-08's trail gained a row. The employer's own view is a different
        // account, so it is not this app's cache to refresh.
        ..invalidate(interviewHistoryProvider(widget.interview.id));

      if (mounted) Navigator.of(context).pop(updated);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _refusal = e.message;
          _busy = false;
        });
      }
    }
  }
}
