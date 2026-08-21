import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_queue_item.dart';

/// Confirms one of §10.2's three verification outcomes, and sends it.
///
/// Returns true only when this administrator's decision was the one recorded —
/// so the caller shows nothing when the sheet was dismissed, and nothing when
/// somebody else had already decided.
Future<bool> showVerificationDecisionSheet(
  BuildContext context,
  VerificationQueueItem item,
  VerificationDecision decision,
) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DecisionSheet(item: item, decision: decision),
    ) ??
    false;

/// §10.2's approve / request-changes / reject, with the reason each one needs.
///
/// ## The reason is required here, and optional on the wire
///
/// The server takes `reason` as optional and then refuses a non-approval that
/// omits it — 403 `employer.verification_reason_required`. This sheet requires
/// it for the two non-approvals, which turns that refusal into a disabled
/// button with a label beside it. Re-making a server rule in the client is safe
/// exactly when the client is the stricter of the two, and this is the same
/// idiom as §8.2's "request details" requiring its question.
///
/// It is also the more important half of the feature. §6.1 shows this text to
/// the employer **verbatim** (§2.4), and it is the only thing they are given: a
/// rejection with no reason is a screen telling somebody their documents were
/// refused and not saying what to fix. So the label says the employer reads it
/// word for word, and the hint is an example that would actually be actionable.
///
/// ## Approval says what it unblocks, rather than asking "are you sure?"
///
/// BR-03 is one gate over two features, so verifying an employer releases their
/// vacancy submissions *and* their invitations at once. That is worth saying
/// once, at the moment of the decision, because it is not deducible from the
/// word "verify".
class _DecisionSheet extends ConsumerStatefulWidget {
  const _DecisionSheet({required this.item, required this.decision});

  final VerificationQueueItem item;
  final VerificationDecision decision;

  @override
  ConsumerState<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends ConsumerState<_DecisionSheet> {
  final _reason = TextEditingController();
  bool _busy = false;

  /// The server's refusal, held in the sheet rather than thrown at a snackbar:
  /// it belongs beside the button that failed, and a 409 here has a consequence
  /// the administrator needs to read before the sheet closes.
  String? _refusal;

  /// True once a 409 has told us somebody else decided this one. The actions
  /// come off the sheet, because every one of them would 409 again.
  bool _settled = false;

  bool get _needsReason => widget.decision.needsReason;

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
                Text(_title(l10n), style: HhTypography.subtitle),
                const SizedBox(height: HhSpace.xs),
                Text(
                  // Names who this is about. An administrator working a queue
                  // has three sheets that look alike, and the wrong employer
                  // rejected is not something a confirmation can undo.
                  widget.item.displayName ?? l10n.adminEmployerUnnamed,
                  style: HhTypography.caption,
                ),
                const SizedBox(height: HhSpace.md),
                Text(
                  _body(l10n),
                  style: HhTypography.body.copyWith(color: HhColors.inkMuted),
                ),

                if (_needsReason && !_settled) ...[
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
                    title: l10n.adminAlreadyDecided,
                    message: refusal,
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                if (!_settled)
                  HhButton(
                    label: _confirmLabel(l10n),
                    loading: _busy,
                    onPressed: _needsReason && trimmed.isEmpty ? null : _send,
                  ),
                if (!_settled) const SizedBox(height: HhSpace.sm),
                HhButton.text(
                  label: _settled ? l10n.commonBack : l10n.commonCancel,
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _title(AppL10n l10n) => switch (widget.decision) {
    VerificationDecision.verified => l10n.adminVerifyTitle,
    VerificationDecision.changesRequired => l10n.adminRequestChangesTitle,
    VerificationDecision.rejected => l10n.adminRejectTitle,
  };

  String _body(AppL10n l10n) => switch (widget.decision) {
    VerificationDecision.verified => l10n.adminVerifyBody,
    VerificationDecision.changesRequired => l10n.adminRequestChangesBody,
    VerificationDecision.rejected => l10n.adminRejectBody,
  };

  String _confirmLabel(AppL10n l10n) => switch (widget.decision) {
    VerificationDecision.verified => l10n.adminVerify,
    VerificationDecision.changesRequired => l10n.adminRequestChanges,
    VerificationDecision.rejected => l10n.adminReject,
  };

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final reason = _reason.text.trim();

    try {
      await ref.read(adminRepositoryProvider).decideVerification(
        widget.item.employerUserId,
        widget.decision,
        reason: reason.isEmpty ? null : reason,
      );

      _dropFromQueue();
      if (mounted) Navigator.of(context).pop(true);
    } on VerificationAlreadyDecided catch (e) {
      // Not a failure. A FIFO queue worked by more than one administrator
      // produces this normally, and the work *is* done — so the row leaves the
      // queue exactly as it would have on success, and only the toast differs.
      _dropFromQueue();
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

  /// Takes the decided row out, and re-reads the figure that actually moved.
  ///
  /// The queue is **not** refetched. Every remaining item is older than this
  /// one, so a refetch would reorder nothing and cost a request — and it would
  /// shift the list under the finger of an administrator working down a page,
  /// which is how the next submission gets decided by accident. §10.1's counter
  /// is invalidated because that number did change.
  void _dropFromQueue() {
    ref.read(verificationQueueProvider.notifier).remove(
      widget.item.employerUserId,
    );
    ref.invalidate(adminDashboardProvider);
  }
}
