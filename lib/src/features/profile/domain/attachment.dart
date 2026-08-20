import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

/// A file attached to the profile (§4.5, §5.4): CV, photo, certificate or
/// supporting document.
///
/// Uploads are deliberately outside the field union — §4.5 keeps every file out
/// of `kind`, and the schema declares the slots in its own `attachments` block
/// instead. So this is not a form value and never reaches `PATCH`.
///
/// [downloadPath] is a path on **this API**, not a storage URL. The bytes are
/// proxied after an ownership check, because a storage URL would carry the
/// bucket credential and could never be handed to a client
/// (ARCHITECTURE.md §9, §11.1).
@JsonSerializable(createToJson: false)
@immutable
class Attachment {
  const Attachment({
    required this.id,
    required this.purposeCode,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    required this.downloadPath,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  final String id;

  /// The `file_purpose` **code** — `cv`, `photo`, `certificate`, `evidence`.
  /// Matches `SchemaAttachment.code`, which is how a file finds its slot.
  final String purposeCode;

  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String createdAt;
  final String downloadPath;
}
