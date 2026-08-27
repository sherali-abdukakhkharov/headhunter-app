// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerProfile _$EmployerProfileFromJson(Map<String, dynamic> json) =>
    EmployerProfile(
      type: json['type'] as String,
      verificationStatus: json['verificationStatus'] as String,
      completenessPercent: (json['completenessPercent'] as num).toInt(),
      isComplete: json['isComplete'] as bool,
      canPublish: json['canPublish'] as bool,
      missingFields: EmployerProfile._missingFrom(json['missingFields']),
      contactPhone: json['contactPhone'] as String?,
      regionId: json['regionId'] as String?,
      districtId: json['districtId'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      fullName: json['fullName'] as String?,
      legalName: json['legalName'] as String?,
      publicName: json['publicName'] as String?,
      industryId: json['industryId'] as String?,
      contactPersonName: json['contactPersonName'] as String?,
      logoFileId: json['logoFileId'] as String?,
      verificationReason: json['verificationReason'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

RequiredEvidence _$RequiredEvidenceFromJson(Map<String, dynamic> json) =>
    RequiredEvidence(
      purposeCode: json['purposeCode'] as String,
      required: json['required'] as bool,
    );

UploadPolicy _$UploadPolicyFromJson(Map<String, dynamic> json) => UploadPolicy(
  acceptedExtensions: (json['acceptedExtensions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  maxSizeBytes: (json['maxSizeBytes'] as num).toInt(),
);

VerificationSubmission _$VerificationSubmissionFromJson(
  Map<String, dynamic> json,
) => VerificationSubmission(
  id: json['id'] as String,
  status: json['status'] as String,
  submittedAt: json['submittedAt'] as String,
  fileIds: (json['fileIds'] as List<dynamic>).map((e) => e as String).toList(),
  decidedAt: json['decidedAt'] as String?,
  reason: json['reason'] as String?,
);

VerificationState _$VerificationStateFromJson(Map<String, dynamic> json) =>
    VerificationState(
      status: json['status'] as String,
      requiredEvidence: (json['requiredEvidence'] as List<dynamic>)
          .map((e) => RequiredEvidence.fromJson(e as Map<String, dynamic>))
          .toList(),
      submissions: (json['submissions'] as List<dynamic>)
          .map(
            (e) => VerificationSubmission.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      upload: UploadPolicy.fromJson(json['upload'] as Map<String, dynamic>),
      reason: json['reason'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
    );
