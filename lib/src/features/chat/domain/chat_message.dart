import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// One message in a §9.1 thread.
///
/// Mirrors `MessageDto` in headhunter-backend — change both together. Named
/// `ChatMessage` rather than `Message` because a bare `Message` in a Flutter
/// app reads as a localized string, and this is neither.
///
/// ## There is no `delivered` state, and that is on purpose
///
/// §9.1 asks for "sent / delivered / read" indicators and the server sends two
/// of the three. [isReadByRecipient] is real; delivery is a property of push
/// (M9) and a field set in the same statement as [createdAt] would be a
/// fabricated answer. So the client shows **sent** and **read**, and does not
/// draw a middle tick it cannot substantiate. When push lands and the server
/// can say when a device took delivery, the field appears here and the tick
/// appears with it.
///
/// [isReadByRecipient] is meaningful **only on messages the caller sent** — it
/// answers "has the other side read this?". On an incoming message it is the
/// server's answer about the caller's own reading, which the caller can see for
/// themselves, so the bubble does not render it there.
///
/// ## The attachment's path comes from the server
///
/// [downloadPath] is scoped to this conversation, which is what makes §9.1's
/// gate re-checkable on every download: holding a path is not holding
/// permission. It is never `/files/{id}/content` — that route stays owner-only,
/// so the recipient of an attachment could not use it — and it is never built
/// here. `AttachmentOpener` follows it verbatim.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.isReadByRecipient,
    required this.createdAt,
    this.body,
    this.fileId,
    this.fileName,
    this.downloadPath,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    conversationId: json['conversationId'] as String,
    senderUserId: json['senderUserId'] as String,
    isReadByRecipient: json['isReadByRecipient'] as bool? ?? false,
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    body: json['body'] as String?,
    fileId: json['fileId'] as String?,
    fileName: json['fileName'] as String?,
    downloadPath: json['downloadPath'] as String?,
  );

  final String id;
  final String conversationId;
  final String senderUserId;

  /// The text, or null on a message that carries only an attachment.
  final String? body;

  final String? fileId;

  /// The name the sender's file was stored under. Content somebody typed
  /// (§2.4), so it is displayed and never used as a path segment.
  final String? fileName;

  /// Where to fetch the attachment, scoped to this conversation.
  final String? downloadPath;

  /// §9.1's read state, for messages the caller **sent**.
  final bool isReadByRecipient;

  final ZonedTimestamp createdAt;

  /// Whether this message carries something to download.
  ///
  /// All three fields are required rather than [fileId] alone: an attachment
  /// with no path cannot be opened, and a row offering to open it would be a
  /// control that fails on tap.
  bool get hasAttachment =>
      fileId != null && fileName != null && downloadPath != null;
}
