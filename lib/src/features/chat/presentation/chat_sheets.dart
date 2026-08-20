import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';

/// §9.1's block, with the optional reason the moderator reads.
///
/// Returns true when the block was accepted.
Future<bool> showBlockConversationSheet(
  BuildContext context,
  String conversationId,
) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BlockSheet(conversationId: conversationId),
    ) ??
    false;

/// §9.1's report, with the reason the complaint queue needs.
///
/// Returns true when the complaint was filed.
Future<bool> showReportMessageSheet(
  BuildContext context, {
  required String conversationId,
  required ChatMessage message,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ReportSheet(conversationId: conversationId, message: message),
    ) ??
    false;

/// The shared chrome: the grab handle, the keyboard inset, and the scroll.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: HhColors.white,
      borderRadius: HhRadius.sheetTop,
    ),
    child: SafeArea(
      child: Padding(
        // Lifts the sheet clear of the keyboard, which the reason field raises.
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
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

/// Blocking a conversation (§9.1).
///
/// ## The sheet states what a block does to *both* sides
///
/// §9.1 makes a block read-only for both participants whoever set it, because a
/// block that let the blocker keep writing would be a mute. Somebody reaching
/// for this control is often reaching for the mute, so the consequence is named
/// before the button rather than discovered afterwards: it ends the
/// conversation, for them too, and the messages stay readable.
///
/// The reason is **optional** and labelled as such. It is for the moderator who
/// may review the thread, and requiring a justification from somebody who is
/// blocking for their own safety gets the wrong answer typed in.
class _BlockSheet extends ConsumerStatefulWidget {
  const _BlockSheet({required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<_BlockSheet> createState() => _BlockSheetState();
}

class _BlockSheetState extends ConsumerState<_BlockSheet> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _refusal;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return _Sheet(
      children: [
        Text(l10n.chatBlockTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.sm),
        Text(
          l10n.chatBlockBody,
          style: HhTypography.body.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.lg),
        HhTextField(
          label: l10n.chatBlockReasonLabel,
          controller: _reason,
          hintText: l10n.chatBlockReasonHint,
          maxLines: 3,
          // The server's own ceiling (§9.1), so the field stops where the API
          // would have refused rather than after it.
          maxLength: 1000,
          enabled: !_busy,
        ),
        if (_refusal case final refusal?) ...[
          const SizedBox(height: HhSpace.md),
          HhNotice.restricted(title: l10n.stateErrorTitle, message: refusal),
        ],
        const SizedBox(height: HhSpace.lg),
        HhButton.destructive(
          label: l10n.chatBlockAction,
          loading: _busy,
          onPressed: _block,
        ),
        const SizedBox(height: HhSpace.sm),
        HhButton.text(
          label: l10n.commonCancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Future<void> _block() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final reason = _reason.text.trim();

    try {
      final repository = await ref.read(chatRepositoryProvider.future);
      await repository.block(
        widget.conversationId,
        reason: reason.isEmpty ? null : reason,
      );

      // The header changes and the list's badge with it. The thread's messages
      // do not, which is why they are a separate provider — re-fetching them
      // here would scroll the thread back to the bottom.
      ref
        ..invalidate(conversationProvider(widget.conversationId))
        ..invalidate(conversationsProvider);

      if (mounted) Navigator.of(context).pop(true);
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

/// Reporting one message (§9.1).
///
/// ## The reason is free text and required
///
/// Free text because somebody objecting to a message should not have to find
/// their objection on a list — the server takes it that way for the same
/// reason. Required because the complaint lands in M10's queue as a row a
/// moderator reads: "somebody reported a message" with nothing attached is a
/// task that cannot be actioned, and the server enforces five characters.
///
/// One open report per person per message. A second answers 409
/// `complaint.already_reported`, which is shown as the server's own sentence
/// rather than swallowed — "you have already reported this" is a fact the
/// reporter wants, not a failure.
class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.conversationId, required this.message});

  final String conversationId;
  final ChatMessage message;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _refusal;

  /// The server's floor (§9.1). Enforced here so the button is inert rather
  /// than the request refused.
  static const _minReason = 5;

  @override
  void initState() {
    super.initState();
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

    return _Sheet(
      children: [
        Text(l10n.chatReportTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.sm),
        Text(
          l10n.chatReportBody,
          style: HhTypography.body.copyWith(color: HhColors.inkMuted),
        ),

        if (widget.message.body case final body? when body.isNotEmpty) ...[
          const SizedBox(height: HhSpace.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HhSpace.md),
            decoration: const BoxDecoration(
              color: HhColors.surfaceMuted,
              borderRadius: HhRadius.inputAll,
            ),
            // The message being reported, played back so the reporter can see
            // they picked the right one. Their counterpart's own words (§2.4),
            // untranslated, and trimmed only in height.
            child: Text(
              body,
              style: HhTypography.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        const SizedBox(height: HhSpace.lg),
        HhTextField(
          label: l10n.chatReportReasonLabel,
          controller: _reason,
          hintText: l10n.chatReportReasonHint,
          maxLines: 4,
          maxLength: 1000,
          enabled: !_busy,
        ),
        if (_refusal case final refusal?) ...[
          const SizedBox(height: HhSpace.md),
          HhNotice.restricted(title: l10n.stateErrorTitle, message: refusal),
        ],
        const SizedBox(height: HhSpace.lg),
        HhButton(
          label: l10n.chatReportSubmit,
          loading: _busy,
          onPressed: trimmed.length < _minReason ? null : _report,
        ),
        const SizedBox(height: HhSpace.sm),
        HhButton.text(
          label: l10n.commonCancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Future<void> _report() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    try {
      final repository = await ref.read(chatRepositoryProvider.future);
      await repository.report(
        widget.conversationId,
        widget.message.id,
        reason: _reason.text.trim(),
      );

      // Nothing on this screen changes: a report is filed, not applied. The
      // message stays where it is and the thread stays open, because §9.1 gives
      // the outcome to a moderator and not to the reporter.
      if (mounted) Navigator.of(context).pop(true);
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
