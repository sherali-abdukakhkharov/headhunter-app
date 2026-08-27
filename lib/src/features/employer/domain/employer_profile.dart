import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employer_profile.g.dart';

/// The employer's own profile (§6.1) and what BR-03 reads from it.
///
/// ## `type` decides which fields exist
///
/// A company has a legal name, a public name, an industry and a contact
/// person; an individual employer has a full name and a description of the
/// work. That is why there is **no neutral empty employer** — the server
/// answers 404 before the first write rather than inventing one, and the
/// client asks which kind of employer this is before it can draw a form.
///
/// It is also **fixed after creation**. Changing it would strand the other
/// type's answers and, worse, the evidence verification was granted against.
@JsonSerializable(createToJson: false)
@immutable
class EmployerProfile {
  const EmployerProfile({
    required this.type,
    required this.verificationStatus,
    required this.completenessPercent,
    required this.isComplete,
    required this.canPublish,
    required this.missingFields,
    this.contactPhone,
    this.regionId,
    this.districtId,
    this.address,
    this.description,
    this.fullName,
    this.legalName,
    this.publicName,
    this.industryId,
    this.contactPersonName,
    this.logoFileId,
    this.verificationReason,
    this.verifiedAt,
    this.updatedAt,
  });

  factory EmployerProfile.fromJson(Map<String, dynamic> json) =>
      _$EmployerProfileFromJson(json);

  /// `company` or `individual`.
  final String type;

  /// The number a candidate should call. Deliberately **not** the login phone:
  /// the verified identity (BR-01) must not be overwritten by a business
  /// contact detail.
  final String? contactPhone;

  final String? regionId;
  final String? districtId;
  final String? address;
  final String? description;

  /// Individual employers.
  final String? fullName;

  /// Companies.
  final String? legalName;
  final String? publicName;
  final String? industryId;
  final String? contactPersonName;
  final String? logoFileId;

  /// One of the five §6.1 states: `not_submitted`, `under_review`, `verified`,
  /// `rejected`, `changes_required`.
  final String verificationStatus;

  /// The administrator's words for a rejection or a correction request.
  /// **Human text already in the language it was written in** — never a
  /// translatable key, and shown verbatim.
  final String? verificationReason;

  final String? verifiedAt;

  final int completenessPercent;

  /// BR-03's first condition. An employer may not submit a vacancy or send an
  /// invitation until this is true.
  final bool isComplete;

  /// **Both** BR-03 conditions: complete *and* verified.
  ///
  /// Computed server-side and rendered as given. A client that ANDed the two
  /// itself would be a second implementation of the rule that decides who may
  /// publish, and the two would drift.
  final bool canPublish;

  @JsonKey(fromJson: _missingFrom)
  final List<String> missingFields;

  final String? updatedAt;

  static List<String> _missingFrom(Object? raw) => [
    for (final entry in raw as List<dynamic>? ?? const [])
      if (entry is Map<String, dynamic> && entry['field'] is String)
        entry['field'] as String,
  ];
}

/// One document verification asks for.
///
/// **Served, not hardcoded.** Which documents each employer type must provide
/// is still an open client decision (§6.1, "if required by policy"), so the
/// answer arrives as data and a policy change needs no release.
@JsonSerializable(createToJson: false)
@immutable
class RequiredEvidence {
  const RequiredEvidence({required this.purposeCode, required this.required});

  factory RequiredEvidence.fromJson(Map<String, dynamic> json) =>
      _$RequiredEvidenceFromJson(json);

  final String purposeCode;

  /// Whether a submission is refused without it.
  final bool required;
}

/// What an evidence upload may be (`FILE_MAX_SIZE_BYTES` and the accepted
/// extensions).
///
/// Served for the same reason [RequiredEvidence] is: the size cap is a
/// deployment setting, and a client that hardcodes it either refuses files this
/// instance would take or promises ones it would not.
@JsonSerializable(createToJson: false)
@immutable
class UploadPolicy {
  const UploadPolicy({
    required this.acceptedExtensions,
    required this.maxSizeBytes,
  });

  factory UploadPolicy.fromJson(Map<String, dynamic> json) =>
      _$UploadPolicyFromJson(json);

  /// Lower-case, without the dot — what `FilePicker`'s `allowedExtensions`
  /// wants.
  ///
  /// **Empty means "do not filter locally"**, not "accept nothing": that is
  /// what an API too old to serve the policy leaves behind, and a picker
  /// offering no file types at all would be unusable rather than unhelpful.
  final List<String> acceptedExtensions;

  /// Zero means unknown — skip the local pre-check and let the server answer.
  final int maxSizeBytes;
}

/// A past verification attempt and why it was refused.
@JsonSerializable(createToJson: false)
@immutable
class VerificationSubmission {
  const VerificationSubmission({
    required this.id,
    required this.status,
    required this.submittedAt,
    required this.fileIds,
    this.decidedAt,
    this.reason,
  });

  factory VerificationSubmission.fromJson(Map<String, dynamic> json) =>
      _$VerificationSubmissionFromJson(json);

  final String id;
  final String status;
  final String submittedAt;
  final String? decidedAt;
  final String? reason;
  final List<String> fileIds;
}

/// Verification state and history (§6.1).
@JsonSerializable(createToJson: false)
@immutable
class VerificationState {
  const VerificationState({
    required this.status,
    required this.requiredEvidence,
    required this.submissions,
    required this.upload,
    this.reason,
    this.verifiedAt,
  });

  factory VerificationState.fromJson(Map<String, dynamic> json) =>
      _$VerificationStateFromJson({
        // Defaulted rather than required, so an API that predates the policy
        // being served cannot take the whole verification card down with it.
        // The local extension filter and size check are optimizations — the
        // server enforces both regardless — so losing them degrades to "let
        // the server refuse it", which is a worse upload, not a dead screen.
        // The spread order means a served policy always wins.
        'upload': const {'acceptedExtensions': <String>[], 'maxSizeBytes': 0},
        ...json,
      });

  final String status;
  final String? reason;
  final String? verifiedAt;
  final List<RequiredEvidence> requiredEvidence;

  /// Newest first.
  final List<VerificationSubmission> submissions;

  /// The accepted extensions and size cap for the evidence above.
  final UploadPolicy upload;

  /// Whether the employer may submit at all right now.
  ///
  /// Re-submitting while an attempt is under review would queue a second
  /// decision on the same evidence, and a verified employer has nothing to
  /// prove.
  bool get canSubmit =>
      status != 'under_review' && status != 'verified';
}
