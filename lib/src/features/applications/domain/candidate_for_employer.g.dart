// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_for_employer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateFile _$CandidateFileFromJson(Map<String, dynamic> json) =>
    CandidateFile(
      id: json['id'] as String,
      purposeCode: json['purposeCode'] as String,
      fileName: json['fileName'] as String,
      downloadPath: json['downloadPath'] as String,
    );

CandidateForEmployer _$CandidateForEmployerFromJson(
  Map<String, dynamic> json,
) => CandidateForEmployer(
  candidateUserId: json['candidateUserId'] as String,
  completenessPercent: (json['completenessPercent'] as num).toInt(),
  canViewFiles: json['canViewFiles'] as bool,
  exposureReason: json['exposureReason'] as String,
  files: (json['files'] as List<dynamic>)
      .map((e) => CandidateFile.fromJson(e as Map<String, dynamic>))
      .toList(),
  fullName: json['fullName'] as String?,
  regionId: json['regionId'] as String?,
  districtId: json['districtId'] as String?,
  availableFrom: json['availableFrom'] as String?,
  phone: json['phone'] as String?,
);

ApplicationCounts _$ApplicationCountsFromJson(Map<String, dynamic> json) =>
    ApplicationCounts(
      hiredCount: (json['hiredCount'] as num).toInt(),
      byStatus: Map<String, int>.from(json['byStatus'] as Map),
      workerCount: (json['workerCount'] as num?)?.toInt(),
    );

ApplicationNote _$ApplicationNoteFromJson(Map<String, dynamic> json) =>
    ApplicationNote(
      id: json['id'] as String,
      note: json['note'] as String,
      createdAt: json['createdAt'] as String,
    );
