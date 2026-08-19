import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_status_badge.dart';

/// Confirms one of §8.2's three candidate responses, and sends it.
///
/// Returns the updated invitation, or null if the candidate backed out or the
/// server refused.
Future<Invitation?> showInvitationResponseSheet(
  BuildContext context,
  Invitation invitation,
  String response,
) => showModalBottomSheet<Invitation>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _ResponseSheet(invitation: invitation, response: response),
);

/// §8.2's Accept / Decline / Request details, with the note each one wants.
///
/// ## Accepting is a disclosure, and it is said before the button
///
/// Acceptance is what opens BR-09's contact exposure: the server's
/// `exposureReason` becomes `accepted_invitation`, and this employer then sees
/// the phone, e-mail and CV that were withheld from them a moment earlier. That
/// is the single most consequential tap a candidate makes in this product, and
/// it is irreversible — §8.2 has no `withdrawn` and the server refuses any
/// transition out of a terminal status.
///
/// So the sheet states the consequence in the disclosure's own words rather
/// than asking "are you sure?". A confirmation that does not say what it
/// confirms is a speed bump, not consent.
///
/// ## The question on "Request details" is required here, and optional there
///
/// The server takes `note` as optional on every response. This sheet requires
/// it for `details_requested` only, and that is deliberate rather than an
/// oversight: "the candidate asked for details" with no question attached gives
/// the employer nothing to answer, so it is a message that cannot be replied
/// to. The same idiom as the leveled field editor opening its level picker
/// immediately — making an unusable-but-legal state unreachable in the UI
/// rather than waiting for it to be filed.
///
/// Declining takes an optional note, because a decline needs no justification
/// and asking for one implies it does.
class _ResponseSheet extends ConsumerStatefulWidget {
  const _ResponseSheet({required this.invitation, required this.response});

  final Invitation invitation;

  /// One of [InvitationStatus.candidateResponses].
  final String response;

  @override
  ConsumerState<_ResponseSheet> createState() => _ResponseSheetState();
}

class _ResponseSheetState extends ConsumerState<_ResponseSheet> {
  final _note = TextEditingController();
  bool _busy = false;

  /// The server's refusal, held in the sheet rather than thrown at a snackbar.
  ///
  /// §8.2's two conflicts — `invitation.final` and
  /// `invitation.response_not_allowed` — both mean somebody else moved first,
  /// which is a sentence the candidate needs to read next to the action that
  /// failed rather than four seconds later at the bottom of the screen.
  String? _refusal;

  bool get _needsNote => widget.response == InvitationStatus.detailsRequested;

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
                Text(_title(l10n), style: HhTypography.subtitle),
                const SizedBox(height: HhSpace.sm),
                Text(
                  _explanation(l10n),
                  style: HhTypography.body.copyWith(color: HhColors.inkMuted),
                ),

                const SizedBox(height: HhSpace.lg),
                HhTextField(
                  label: _needsNote
                      ? l10n.invitationQuestionLabel
                      : l10n.invitationNoteLabel,
                  controller: _note,
                  hintText: _needsNote
                      ? l10n.invitationQuestionHint
                      : l10n.invitationNoteHint,
                  maxLines: 4,
                  // The server's own ceiling (§8.2), so the field stops where
                  // the API would have refused rather than after it.
                  maxLength: 2000,
                  enabled: !_busy,
                ),

                // Held in the sheet rather than thrown at a snackbar, the
                // same treatment the unlock sheet gives its refusals: the
                // sentence belongs beside the button that failed.
                if (_refusal case final refusal?) ...[
                  const SizedBox(height: HhSpace.md),
                  HhNotice.restricted(
                    title: l10n.invitationAlreadyAnswered,
                    message: refusal,
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                HhButton(
                  label: invitationResponseLabel(widget.response, l10n),
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

  String _title(AppL10n l10n) => switch (widget.response) {
    InvitationStatus.accepted => l10n.invitationAcceptTitle,
    InvitationStatus.declined => l10n.invitationDeclineTitle,
    _ => l10n.invitationRequestDetailsTitle,
  };

  String _explanation(AppL10n l10n) => switch (widget.response) {
    // The disclosure. Names the three fields rather than saying "your contact
    // details", because a candidate cannot weigh a category — and these are
    // exactly the three §11.1 protects.
    InvitationStatus.accepted => l10n.invitationAcceptDiscloses,
    InvitationStatus.declined => l10n.invitationDeclineFinal,
    _ => l10n.invitationRequestDetailsBody,
  };

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final note = _note.text.trim();

    try {
      final repository = await ref.read(invitationRepositoryProvider.future);
      final updated = await repository.respond(
        widget.invitation.id,
        widget.response,
        note: note.isEmpty ? null : note,
      );

      ref
        ..invalidate(receivedInvitationsProvider)
        // BR-08's trail gained a row. The employer's sent list deliberately is
        // *not* invalidated: they are a different account, so it is not this
        // app's cache to refresh.
        ..invalidate(invitationHistoryProvider(widget.invitation.id));

      if (mounted) Navigator.of(context).pop(updated);
    } on ApiException catch (e) {
      // Held in the sheet: `invitation.final` means the invitation was answered
      // from another device, and the candidate needs that sentence beside the
      // button that just failed.
      if (mounted) {
        setState(() {
          _refusal = e.message;
          _busy = false;
        });
      }
    }
  }
}
