// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
  id: json['id'] as String,
  purposeCode: json['purposeCode'] as String,
  fileName: json['fileName'] as String,
  mimeType: json['mimeType'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  downloadPath: json['downloadPath'] as String,
);
