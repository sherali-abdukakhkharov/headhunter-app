import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// One message (§9.1).
///
/// ## Which side it sits on is decided by [mine], and nothing here computes it
///
/// The thread passes it, derived from the conversation's `counterpartUserId` —
/// a conversation has two participants and the server names the other one, so
/// "not them" is "me" without the app ever storing its own user id.
///
/// ## Sent and read, and no third tick
///
/// §9.1 asks for sent / delivered / read. The server sends `isReadByRecipient`
/// and no delivery field, deliberately: delivery is a property of push (M9),
/// and a flag written in the same statement as `createdAt` would be a
/// fabricated answer. So a message shows **sent** or **read** and never a
/// middle state it cannot substantiate.
///
/// The indicator is on outgoing messages only. On an incoming one the field
/// answers whether *the reader* has read it, which they can see for themselves.
class MessageBubble extends ConsumerStatefulWidget {
  const MessageBubble({
    required this.message,
    required this.mine,
    super.key,
    this.onReport,
  });

  final ChatMessage message;

  /// Whether the caller sent this message.
  final bool mine;

  /// Opens the report sheet. Null on outgoing messages — reporting your own
  /// message files a complaint about yourself, and §9.1's queue is for the
  /// other kind.
  final VoidCallback? onReport;

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final message = widget.message;
    final mine = widget.mine;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        // Never the full width: a bubble that reaches both edges stops reading
        // as one side of a conversation, and at 320pt the gap is what tells the
        // two apart before the colour does.
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Semantics(
          button: widget.onReport != null,
          child: InkWell(
            // A **tap**, not a long-press. Nothing else in this app uses
            // long-press, and a gesture used in exactly one place is a gesture
            // nobody discovers — least of all in a product whose audience
            // includes people for whom it is not a learned idiom. Reporting is
            // the only thing a message offers, so the sheet is not a menu
            // somebody has to read.
            onTap: widget.onReport,
            borderRadius: HhRadius.cardAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: mine ? HhColors.brand50 : HhColors.surfaceMuted,
                borderRadius: HhRadius.cardAll,
                border: Border.fromBorderSide(
                  mine ? HhBorders.card : HhBorders.faint,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.body case final body? when body.isNotEmpty)
                    // Somebody's own words (§2.4): never translated, never
                    // trimmed to a preview.
                    Text(body, style: HhTypography.body),

                  if (message.hasAttachment) ...[
                    if (message.body?.isNotEmpty ?? false)
                      const SizedBox(height: HhSpace.sm),
                    _Attachment(
                      fileName: message.fileName!,
                      busy: _busy,
                      onOpen: _open,
                    ),
                  ],

                  const SizedBox(height: 4),
                  // A Wrap and not a Row: the time and the receipt need 240pt
                  // together at the design's 320pt / 2.0x QA case and a bubble
                  // is at most 78% of the width, so they do not fit on one line
                  // there. Neither may truncate — a clipped "Rea…" is worse
                  // than a second line, and a clipped time is unreadable — so
                  // the receipt drops below the stamp instead.
                  Wrap(
                    spacing: 5,
                    runSpacing: 2,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        wallClockTime(message.createdAt.wallClock),
                        style: HhTypography.meta.copyWith(
                          color: HhColors.inkSubtle,
                        ),
                      ),
                      if (mine)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // A word beside the glyph rather than one tick
                            // versus two: two ticks are a convention borrowed
                            // from another app, and this one has exactly two
                            // states to express.
                            HhIcon(
                              message.isReadByRecipient
                                  ? HhIconPath.eye
                                  : HhIconPath.check,
                              size: 13,
                              color: message.isReadByRecipient
                                  ? HhColors.brand600
                                  : HhColors.inkSubtle,
                              strokeWidth: 2.2,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              message.isReadByRecipient
                                  ? l10n.chatRead
                                  : l10n.chatSent,
                              style: HhTypography.meta.copyWith(
                                color: message.isReadByRecipient
                                    ? HhColors.brand600
                                    : HhColors.inkSubtle,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Downloads the attachment and hands it to the OS.
  ///
  /// The path is followed **verbatim**: it is scoped to this conversation,
  /// which is what lets §9.1's gate be re-asked on every download. Every tap
  /// re-downloads for the same reason — a copy on disk is not permission, and
  /// an interaction that has ended has to stop being readable mid-session.
  Future<void> _open() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref.read(attachmentOpenerProvider).open(
        downloadPath: widget.message.downloadPath!,
        fileId: widget.message.fileId!,
        fileName: widget.message.fileName!,
      );
    } on NoViewerException {
      // The bytes arrived and the phone has nothing that reads them. Its own
      // message: "check your connection" would send somebody looking in the
      // wrong place.
      messenger.showSnackBar(SnackBar(content: Text(l10n.fileNoViewer)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// The attachment row inside a bubble.
class _Attachment extends StatelessWidget {
  const _Attachment({
    required this.fileName,
    required this.busy,
    required this.onOpen,
  });

  final String fileName;
  final bool busy;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: busy ? null : onOpen,
    borderRadius: HhRadius.inputAll,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 18,
            child: busy
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const HhIcon(
                    HhIconPath.document,
                    size: 18,
                    color: HhColors.brand600,
                    strokeWidth: 2,
                  ),
          ),
          const SizedBox(width: HhSpace.sm),
          Flexible(
            child: Text(
              // The sender's own file name (§2.4). Displayed, and never used as
              // a path segment — `AttachmentOpener` names the local copy from
              // the server's file id for exactly that reason.
              fileName,
              style: HhTypography.caption.copyWith(
                color: HhColors.brand600,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
