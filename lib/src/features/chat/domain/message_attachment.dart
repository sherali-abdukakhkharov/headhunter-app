import 'package:flutter/foundation.dart';

/// A file uploaded into a conversation but not yet sent (§9.1).
///
/// Mirrors `MessageAttachmentDto` in headhunter-backend — change both together.
///
/// ## It is not attached to anything yet
///
/// The upload stores a file the caller owns; it becomes an *attachment* when a
/// message carries its [fileId]. So a composer holding one of these has
/// something to send, not something sent.
///
/// ## Abandoning one is safe, and it does not last (MT-023)
///
/// There is no "delete the draft attachment" call, because there is nothing to
/// detach — but "nothing happens to it" was not a policy either, and an
/// unreferenced row that nobody can reach is exactly what BR-14 exists to put a
/// period on. The server sweeps chat uploads that never became messages after
/// **seven days** (`unsent_message_attachments` in its retention policy).
///
/// Seven rather than deleting the moment somebody taps remove: removing a file
/// and changing your mind is the ordinary case, and deleting on the tap would
/// make re-attaching mean uploading again.
@immutable
class MessageAttachment {
  const MessageAttachment({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        fileId: json['fileId'] as String,
        fileName: json['fileName'] as String,
        mimeType: json['mimeType'] as String,
        sizeBytes: (json['sizeBytes'] as num).toInt(),
      );

  /// What to send as `fileId` on the message that carries it.
  final String fileId;

  final String fileName;
  final String mimeType;
  final int sizeBytes;

  @override
  bool operator ==(Object other) =>
      other is MessageAttachment &&
      other.fileId == fileId &&
      other.fileName == fileName &&
      other.mimeType == mimeType &&
      other.sizeBytes == sizeBytes;

  @override
  int get hashCode => Object.hash(fileId, fileName, mimeType, sizeBytes);

  @override
  String toString() => 'MessageAttachment($fileName, $sizeBytes bytes)';
}
