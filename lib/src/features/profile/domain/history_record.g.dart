// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperienceRecord _$ExperienceRecordFromJson(Map<String, dynamic> json) =>
    ExperienceRecord(
      id: json['id'] as String,
      roleTitle: json['roleTitle'] as String,
      startedOn: json['startedOn'] as String,
      isCurrent: json['isCurrent'] as bool,
      employerName: json['employerName'] as String?,
      occupationId: json['occupationId'] as String?,
      endedOn: json['endedOn'] as String?,
      responsibilities: json['responsibilities'] as String?,
    );

ExperienceDraft _$ExperienceDraftFromJson(Map<String, dynamic> json) =>
    ExperienceDraft(
      employerName: json['employerName'] as String?,
      roleTitle: json['roleTitle'] as String? ?? '',
      occupationId: json['occupationId'] as String?,
      startedOn: json['startedOn'] as String?,
      endedOn: json['endedOn'] as String?,
      isCurrent: json['isCurrent'] as bool? ?? false,
      responsibilities: json['responsibilities'] as String?,
    );

Map<String, dynamic> _$ExperienceDraftToJson(ExperienceDraft instance) =>
    <String, dynamic>{
      'employerName': instance.employerName,
      'roleTitle': instance.roleTitle,
      'occupationId': instance.occupationId,
      'startedOn': instance.startedOn,
      'endedOn': instance.endedOn,
      'isCurrent': instance.isCurrent,
      'responsibilities': instance.responsibilities,
    };

EducationRecord _$EducationRecordFromJson(Map<String, dynamic> json) =>
    EducationRecord(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      institution: json['institution'] as String?,
      specialization: json['specialization'] as String?,
      graduationYear: (json['graduationYear'] as num?)?.toInt(),
    );

EducationDraft _$EducationDraftFromJson(Map<String, dynamic> json) =>
    EducationDraft(
      levelId: json['levelId'] as String?,
      institution: json['institution'] as String?,
      specialization: json['specialization'] as String?,
      graduationYear: (json['graduationYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EducationDraftToJson(EducationDraft instance) =>
    <String, dynamic>{
      'levelId': instance.levelId,
      'institution': instance.institution,
      'specialization': instance.specialization,
      'graduationYear': instance.graduationYear,
    };
