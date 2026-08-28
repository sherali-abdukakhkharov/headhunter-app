import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/upload_cancelled.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/data/thread_controller.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:jobbridge_app/src/features/chat/domain/message_attachment.dart';
import 'package:jobbridge_app/src/features/chat/presentation/chat_sheets.dart';
import 'package:jobbridge_app/src/features/chat/presentation/message_bubble.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// One conversation (§9.1): its history, and its composer while it is open.
///
/// ## The header and the messages are two providers, on purpose
///
/// They change for different reasons. Sending appends a message and leaves the
/// header alone; blocking changes the header and appends nothing. One provider
/// would re-fetch both on either, and the visible cost is the thread jumping
/// back to the newest message every time somebody blocks.
///
/// ## The thread does not update itself, and that is a stated limitation
///
/// There is no poll. §9.2 gives message delivery to push (M9), and until that
/// lands a timer asking every few seconds would drain a battery to answer
/// "nothing yet" — on a product whose users are often on prepaid data. So the
/// app bar carries an explicit refresh, and a notification tap will reuse the
/// same route when M9 opens.
///
/// ## Read is marked on open, once
///
/// `PUT /read` is one timestamp per participant on the server, so it is
/// idempotent and cheap. It runs from `initState` rather than from the build,
/// so a rebuild does not re-send it, and the conversations list is invalidated
/// afterwards so the tab's unread pill clears without the user going back to
/// watch it happen.
class ConversationThreadScreen extends ConsumerStatefulWidget {
  const ConversationThreadScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ConversationThreadScreen> createState() =>
      _ConversationThreadScreenState();
}

class _ConversationThreadScreenState
    extends ConsumerState<ConversationThreadScreen> {
  @override
  void initState() {
    super.initState();
    // Post-frame rather than inline: `initState` may not read a provider that
    // could rebuild this widget, and marking read invalidates the list.
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  Future<void> _markRead() async {
    try {
      final repository = await ref.read(chatRepositoryProvider.future);
      await repository.markRead(widget.conversationId);
      if (!mounted) return;
      ref
        ..invalidate(conversationsProvider)
        ..invalidate(conversationProvider(widget.conversationId));
    } on ApiException catch (error) {
      // Deliberately silent. Failing to mark a thread read costs an unread
      // count that is one too high, and there is nothing the reader would do
      // with an error about it — they came here to read, and the reading
      // worked.
      debugPrint('[chat] markRead failed: ${error.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final header = ref.watch(conversationProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (header) {
            AsyncData(:final value) =>
              value.counterpartName ?? l10n.chatParticipantUnknown,
            // Not the participant's name and not blank: a title that says
            // "Messages" while the header loads is honest, and one that says a
            // name before it arrives would have to change under the reader.
            _ => l10n.navMessages,
          },
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: l10n.commonRetry,
            icon: const HhIcon(HhIconPath.refresh, size: 21),
          ),
          if (header case AsyncData(:final value)) _BlockAction(value),
        ],
      ),
      body: SafeArea(
        child: switch (header) {
          // Error first, before any loading arm: retry is off app-wide, so a
          // failure is terminal and a spinner over it would be permanent.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: failureTitle(error, l10n),
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: _refresh,
            ),
          ),
          AsyncData(:final value) => _Body(conversation: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  void _refresh() {
    ref
      ..invalidate(conversationProvider(widget.conversationId))
      ..invalidate(conversationThreadProvider(widget.conversationId));
    unawaited(_markRead());
  }
}

/// The block / unblock control.
///
/// **Unblock is offered only where `blockedByMe`.** The route removes the
/// caller's own block and cannot lift the other side's, so a control there
/// would look like it clears a condition it cannot touch — the same rule
/// `HhNotice`'s dismiss follows.
class _BlockAction extends ConsumerWidget {
  const _BlockAction(this.conversation);

  final Conversation conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    if (conversation.isBlocked) {
      if (!conversation.blockedByMe) return const SizedBox.shrink();

      return TextButton(
        onPressed: () => _unblock(context, ref),
        child: Text(l10n.chatUnblock),
      );
    }

    return IconButton(
      onPressed: () => showBlockConversationSheet(context, conversation.id),
      tooltip: l10n.chatBlockAction,
      icon: const HhIcon(HhIconPath.xCircle, size: 21),
    );
  }

  Future<void> _unblock(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final repository = await ref.read(chatRepositoryProvider.future);
      await repository.unblock(conversation.id);
      ref
        ..invalidate(conversationProvider(conversation.id))
        ..invalidate(conversationsProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    messenger.showSnackBar(SnackBar(content: Text(l10n.chatUnblocked)));
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final thread = ref.watch(conversationThreadProvider(conversation.id));

    return Column(
      children: [
        Expanded(
          child: switch (thread) {
            AsyncValue(hasError: true, :final error?) => Padding(
              padding: const EdgeInsets.all(HhSpace.gutter),
              child: HhErrorState(
                title: failureTitle(error, l10n),
                message: error is ApiException
                    ? error.message
                    : l10n.stateErrorBody,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(
                  conversationThreadProvider(conversation.id),
                ),
              ),
            ),
            AsyncData(:final value) when value.messages.isEmpty => Padding(
              padding: const EdgeInsets.all(HhSpace.gutter),
              child: HhEmptyState(
                title: l10n.stateEmptyTitle,
                message: conversation.canSend
                    ? l10n.chatThreadEmpty
                    : l10n.chatThreadEmptyClosed,
              ),
            ),
            AsyncData(:final value) => _Messages(
              conversation: conversation,
              thread: value,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),

        // §9.1's read-only rule, or the composer. Never both: an input on a
        // thread that cannot accept one is a control that lies, and the notice
        // is what says which of the two reasons applies.
        if (conversation.canSend)
          _Composer(conversation: conversation)
        else
          Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: _ClosedNotice(conversation: conversation),
          ),
      ],
    );
  }
}

/// Why this thread takes no more messages, and what would change it.
///
/// Three sentences over two states, because the remedy differs: an ended
/// interaction resumes on its own terms, a block set here is lifted here, and a
/// block set by the other side is neither.
class _ClosedNotice extends StatelessWidget {
  const _ClosedNotice({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (!conversation.isBlocked) {
      // Expired rather than restricted: nothing was refused and nobody is at
      // fault — the hiring interaction that opened the thread has ended, and
      // §9.1 keeps the history readable on purpose.
      return HhNotice.expired(
        title: l10n.chatReadOnlyTitle,
        message: l10n.chatReadOnlyBody,
      );
    }

    return HhNotice.restricted(
      title: conversation.blockedByMe
          ? l10n.chatBlockedByYouTitle
          : l10n.chatBlockedTitle,
      message: conversation.blockedByMe
          ? l10n.chatBlockedByYouBody
          : l10n.chatBlockedBody,
    );
  }
}

/// The thread itself, newest at the bottom.
///
/// `reverse: true` rather than reversing the list: the model stays newest
/// first, which is the order the server sends and the order the `before`
/// cursor is derived from. Reversing the data would make the oldest message
/// the first element in one place and the last in another, and the paging
/// cursor is exactly what that confusion breaks.
class _Messages extends ConsumerWidget {
  const _Messages({required this.conversation, required this.thread});

  final Conversation conversation;
  final Thread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final messages = thread.messages;

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(HhSpace.gutter),
      // One extra row at the far end of the reversed list — visually the top —
      // for the control that fetches older messages.
      itemCount: messages.length + (thread.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.md),
            child: HhButton.tertiary(
              label: l10n.chatEarlier,
              onPressed: () => ref
                  .read(conversationThreadProvider(conversation.id).notifier)
                  .loadEarlier(),
            ),
          );
        }

        final message = messages[index];
        // A conversation has two participants and the server names the other
        // one, so "not them" is "me" — no stored user id, and no second answer
        // to who the caller is.
        final mine = message.senderUserId != conversation.counterpartUserId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The separator sits above the first message of a day. In a
            // reversed list the older neighbour is the *next* index, so a day
            // change is detected against index + 1 — and the oldest row loaded
            // always gets one, since there is nothing above it to compare with.
            if (_startsADay(messages, index))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: HhSpace.sm),
                child: Center(
                  child: Text(
                    wallClockDay(message.createdAt.wallClock),
                    style: HhTypography.meta.copyWith(
                      color: HhColors.inkSubtle,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: MessageBubble(
                message: message,
                mine: mine,
                // Reporting your own message would file a complaint about
                // yourself; §9.1's queue is for the other kind.
                onReport: mine
                    ? null
                    : () => _report(context, message),
              ),
            ),
          ],
        );
      },
    );
  }

  static bool _startsADay(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;

    return !isSameWallClockDay(
      messages[index].createdAt.wallClock,
      messages[index + 1].createdAt.wallClock,
    );
  }

  Future<void> _report(BuildContext context, ChatMessage message) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final filed = await showReportMessageSheet(
      context,
      conversationId: conversation.id,
      message: message,
    );

    if (filed) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.chatReportDone)));
    }
  }
}

/// The composer (§9.1, §12.4).
///
/// ## A refused send keeps the draft
///
/// Both refusals — a block and the read-only 409 — leave the typed text where
/// it is. Somebody who wrote three paragraphs into a thread that closed under
/// them must be able to copy it out; clearing the field would be the app
/// deleting their words to report its own failure.
///
/// ## Sending is refused locally only when there is nothing to send
///
/// The button is inert when there is neither text nor an attachment, and
/// enabled otherwise. It is never disabled by a rule about *whether this
/// person may chat*: that is the server's, and a client that guessed would
/// refuse sends the API would have accepted.
///
/// ## An attachment is uploaded before it is sent, and the two are separate
///
/// Picking a file uploads it immediately and holds the returned `fileId`. Two
/// waits, shown as two things: a refused or failed *send* keeps the upload, so
/// somebody whose thread closed under them does not pay for the bytes twice.
///
/// **Removing it only removes it from the composer.** Nothing was attached to
/// anything, so there is nothing to detach — and the upload is not left forever
/// either: the server expires a chat upload that never became a message after
/// seven days (MT-023). Deleting it on the tap instead would make re-attaching
/// mean uploading again, for the very ordinary case of changing your mind.
///
/// **The extension list decides what the picker offers, not what is allowed.**
/// The server is the authority and refuses with a message it has already
/// translated; the list exists so the picker does not offer files that will
/// bounce.
class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final _body = TextEditingController();
  bool _busy = false;
  String? _refusal;

  /// Uploaded and waiting for a message to carry it.
  MessageAttachment? _attachment;

  /// True while the bytes are going up — a different wait from [_busy], which
  /// is the send. One indicator for both would make a slow upload look like a
  /// slow send.
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _body.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final trimmed = _body.text.trim();
    final attachment = _attachment;
    final canSend = trimmed.isNotEmpty || attachment != null;

    return Container(
      padding: const EdgeInsets.all(HhSpace.gutter),
      decoration: const BoxDecoration(
        color: HhColors.white,
        border: Border(top: HhBorders.card),
      ),
      child: Column(
        children: [
          if (_refusal case final refusal?) ...[
            HhNotice.restricted(
              title: l10n.chatSendRefusedTitle,
              message: refusal,
            ),
            const SizedBox(height: HhSpace.md),
          ],
          if (_uploading) ...[
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: HhSpace.sm),
                Text(
                  l10n.chatAttachmentUploading,
                  style: HhTypography.caption,
                ),
              ],
            ),
            const SizedBox(height: HhSpace.sm),
          ] else if (attachment != null) ...[
            Row(
              children: [
                // The same glyph the bubble gives a received attachment: it is
                // the same thing, one moment earlier.
                const HhIcon(
                  HhIconPath.document,
                  size: 15,
                  color: HhColors.inkSubtle,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.chatAttachmentReady(attachment.fileName),
                    style: HhTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _attachment = null),
                  icon: const HhIcon(
                    HhIconPath.close,
                    size: 16,
                    color: HhColors.inkSubtle,
                  ),
                  tooltip: l10n.chatAttachmentRemove,
                ),
              ],
            ),
            const SizedBox(height: HhSpace.sm),
          ],
          Row(
            // `end`, so the attachment and send controls stay level with the
            // *last* line of a message that has grown to four.
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // The name is on the icon, not on the tooltip: a tooltip is
              // not an accessible name, and an icon-only control without one
              // announces as "button" (MT-015).
              IconButton(
                onPressed: _busy || _uploading || attachment != null
                    ? null
                    : _pickAndUpload,
                // `upload` is the act; `document` is the thing. The set has no
                // paperclip, which is the conventional affordance here — raised
                // in docs/design-feedback.md rather than invented.
                icon: HhIcon(
                  HhIconPath.upload,
                  size: 20,
                  color: HhColors.inkMuted,
                  semanticLabel: l10n.chatAttach,
                ),
              ),
              Expanded(
                // The composer variant, not the ordinary field: a persistent
                // label and a multiline box that starts at 83pt make this
                // read as a form, which is what the 1.29.0 audit called it.
                // `label` is still carried and is still the accessible name.
                child: HhTextField.composer(
                  label: l10n.chatComposerLabel,
                  controller: _body,
                  hintText: l10n.chatComposerHint,
                  // The server's own ceiling (§9.1), so the field stops where
                  // the API would have refused rather than after it.
                  maxLength: 4000,
                  enabled: !_busy,
                ),
              ),
              const SizedBox(width: HhSpace.sm),
              _SendButton(
                busy: _busy,
                onPressed: canSend ? _send : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ChatRepository.attachmentExtensions,
    );

    final file = picked?.files.singleOrNull;
    final path = file?.path;
    if (file == null || path == null) return;

    setState(() {
      _uploading = true;
      _refusal = null;
    });

    try {
      final repository = await ref.read(chatRepositoryProvider.future);
      final attachment = await repository.uploadAttachment(
        widget.conversation.id,
        filePath: path,
        fileName: file.name,
      );

      if (!mounted) return;
      setState(() {
        _attachment = attachment;
        _uploading = false;
      });
    } on UploadCancelled {
      // Something the user did, not something that went wrong.
      if (mounted) setState(() => _uploading = false);
    } on ApiException catch (e) {
      // Includes the gate: a thread that closed while the picker was open
      // refuses here rather than at send, which is the earlier and cheaper
      // place to find out.
      if (mounted) {
        setState(() {
          _refusal = e.message;
          _uploading = false;
        });
      }
    }
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final body = _body.text.trim();
    final attachment = _attachment;

    try {
      final repository = await ref.read(chatRepositoryProvider.future);
      final outcome = await repository.send(
        widget.conversation.id,
        // Empty rather than absent would be a message with a blank line above
        // its attachment; the server takes either field alone.
        body: body.isEmpty ? null : body,
        fileId: attachment?.fileId,
      );

      if (!mounted) return;

      switch (outcome) {
        case MessageSent(:final message):
          ref
              .read(
                conversationThreadProvider(widget.conversation.id).notifier,
              )
              .appendSent(message);
          // The list's preview line and its ordering both changed.
          ref.invalidate(conversationsProvider);
          _body.clear();
          setState(() {
            _busy = false;
            _attachment = null;
          });

        case SendRefusedReadOnly(:final message) ||
            SendRefusedBlocked(:final message):
          // The header is now wrong on screen: `canSend` was true when it was
          // fetched and the server has just said otherwise. Re-fetching it
          // replaces the composer with the notice that explains which of the
          // two happened — so the refusal is shown once, by the part of the
          // screen that owns the state, rather than as a message beside an
          // input that still invites another attempt.
          ref
            ..invalidate(conversationProvider(widget.conversation.id))
            ..invalidate(conversationsProvider);
          setState(() {
            _refusal = message;
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

/// Send, as a circle rather than a labelled button.
///
/// **The label was costing the message more than it was worth.** With
/// `Yuborish` on the button and an attach control on the left, the input
/// between them measured 148pt of a 360pt screen — a stub you cannot read a
/// sentence in. Icon-only gives it back about a hundred points, which is the
/// difference between seeing what you wrote and scrolling it.
///
/// It is icon-only and **named**: `semanticLabel` is the accessible name, the
/// same rule the attach control on the other side of the row follows. An
/// icon-only control without one announces as "button" (MT-015).
///
/// Filled rather than outlined, because it is the primary action of the screen
/// and the neutral affordance beside it is not.
class _SendButton extends StatelessWidget {
  const _SendButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  /// 48, which is the platform minimum tap target and fits the 52 row.
  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final enabled = onPressed != null && !busy;

    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.chatSend,
      excludeSemantics: true,
      onTap: enabled ? onPressed : null,
      child: Material(
        color: enabled ? HhColors.brand600 : HhColors.fill,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: _size,
            height: _size,
            child: Center(
              child: busy
                  // Same footprint as the glyph, so the row does not twitch
                  // when a message is in flight.
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: HhColors.inkMuted,
                      ),
                    )
                  : HhIcon(
                      HhIconPath.send,
                      size: 20,
                      color: enabled ? HhColors.white : HhColors.inkDisabled,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
