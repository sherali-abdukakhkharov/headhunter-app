import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';

/// Confirms one administrator decision and sends it (§10.2).
///
/// [send] performs the request and nothing else. It must throw
/// [AdminDecisionConflict] for the 409 that means somebody decided first, and
/// [ApiException] for anything else; the sheet renders both and the caller acts
/// on the returned [AdminDecisionOutcome].
Future<AdminDecisionOutcome> showAdminDecisionSheet(
  BuildContext context, {
  required String title,
  required String subject,
  required String body,
  required String confirmLabel,
  required bool needsReason,
  required Future<void> Function(String? reason) send,
}) async =>
    await showModalBottomSheet<AdminDecisionOutcome>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DecisionSheet(
        title: title,
        subject: subject,
        body: body,
        confirmLabel: confirmLabel,
        needsReason: needsReason,
        send: send,
      ),
    ) ??
    AdminDecisionOutcome.dismissed;

/// The one sheet behind every §10.2 decision.
///
/// ## The reason is required here, and optional on the wire
///
/// Both of §10.2's queues take `reason` as optional and then refuse a
/// non-approval that omits it — `employer.verification_reason_required`,
/// `vacancy.moderation_reason_required`. This sheet requires it, which turns
/// that refusal into a disabled button with a label beside it. Re-making a
/// server rule in the client is safe exactly when the client is the stricter of
/// the two, and it is the same idiom as §8.2's "request details" requiring its
/// question.
///
/// It is also the more important half of the feature: §6.1 and §6.4 show this
/// text to the employer **verbatim** (§2.4), and it is the only thing they are
/// given. A refusal with no reason is a screen saying something was rejected
/// and not saying what to fix.
///
/// ## One sheet, not one per queue
///
/// The mechanics are identical across §10.2 — a named subject, a consequence
/// stated before the button, a mandatory-reason gate, a refusal held beside the
/// action that failed, and a 409 that settles rather than fails. A second copy
/// would drift, and the first thing to drift would be the 409 handling, which
/// is the branch nobody exercises by hand.
class _DecisionSheet extends StatefulWidget {
  const _DecisionSheet({
    required this.title,
    required this.subject,
    required this.body,
    required this.confirmLabel,
    required this.needsReason,
    required this.send,
  });

  final String title;

  /// Who or what is being decided about. Named on the sheet because an
  /// administrator working a queue sees sheets that look alike, and the wrong
  /// employer rejected is not something a confirmation can undo.
  final String subject;

  final String body;
  final String confirmLabel;
  final bool needsReason;
  final Future<void> Function(String? reason) send;

  @override
  State<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<_DecisionSheet> {
  final _reason = TextEditingController();
  bool _busy = false;

  /// The server's refusal, held in the sheet rather than thrown at a snackbar:
  /// it belongs beside the button that failed, and a 409 here has a consequence
  /// the administrator needs to read before the sheet closes.
  String? _refusal;

  /// True once a 409 has told us somebody decided first. The action comes off
  /// the sheet, because every retry would 409 again.
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    // Enables the send button the moment the field stops being empty, which is
    // the only thing that gates it.
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final trimmed = _reason.text.trim();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          // Lifts the sheet clear of the keyboard, which the reason field
          // raises.
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
                Text(widget.title, style: HhTypography.subtitle),
                const SizedBox(height: HhSpace.xs),
                Text(widget.subject, style: HhTypography.caption),
                const SizedBox(height: HhSpace.md),
                Text(
                  widget.body,
                  style: HhTypography.body.copyWith(color: HhColors.inkMuted),
                ),

                if (widget.needsReason && !_settled) ...[
                  const SizedBox(height: HhSpace.lg),
                  HhTextField(
                    label: l10n.adminReasonLabel,
                    controller: _reason,
                    hintText: l10n.adminReasonHint,
                    maxLines: 4,
                    // The server's own ceiling, so the field stops where the
                    // API would have refused rather than after it.
                    maxLength: 2000,
                    enabled: !_busy,
                  ),
                ],

                if (_refusal case final refusal?) ...[
                  const SizedBox(height: HhSpace.md),
                  HhNotice.restricted(
                    // The 409 and an ordinary failure are both held here and
                    // they are not the same news: one means the work is done,
                    // the other that it is not. Titling both "already decided"
                    // would tell an administrator to stop looking.
                    title: _settled
                        ? l10n.adminAlreadyDecided
                        : l10n.stateErrorTitle,
                    message: refusal,
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                if (!_settled) ...[
                  HhButton(
                    label: widget.confirmLabel,
                    loading: _busy,
                    onPressed: widget.needsReason && trimmed.isEmpty
                        ? null
                        : _send,
                  ),
                  const SizedBox(height: HhSpace.sm),
                ],
                HhButton.text(
                  // "Back" once there is nothing left to cancel.
                  label: _settled ? l10n.commonBack : l10n.commonCancel,
                  onPressed: _busy ? null : _dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dismiss() => Navigator.of(context).pop(
    _settled
        ? AdminDecisionOutcome.alreadyDecided
        : AdminDecisionOutcome.dismissed,
  );

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final reason = _reason.text.trim();

    try {
      await widget.send(reason.isEmpty ? null : reason);
      if (mounted) Navigator.of(context).pop(AdminDecisionOutcome.sent);
    } on AdminDecisionConflict catch (e) {
      // Not a failure: two administrators on one FIFO queue produce this
      // normally, and the work *is* done. The sheet says so and the caller
      // empties the row either way.
      if (mounted) {
        setState(() {
          _refusal = e.message;
          _settled = true;
          _busy = false;
        });
      }
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
