import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_record.g.dart';

/// Work experience and education (§5.1) — the two `editor: "bespoke"` sections.
///
/// These are the parts of the profile the field engine deliberately does *not*
/// render. They are repeating records with their own sub-resources, so their
/// shapes are fixed rather than schema-driven, and ARCHITECTURE.md §6 says to
/// write them as ordinary widgets rather than growing the engine to cover them.
///
/// ## Why each has two types
///
/// The server splits `ExperienceDto` from `ExperienceInputDto`, and mirroring
/// that split is what keeps `id` out of a write body. A record comes back with
/// an id; a draft is what an editor holds and sends, and it has none — so a
/// draft cannot accidentally carry a stale id into a `POST`, and the difference
/// is visible in the type rather than in a comment.
///
/// Dates are ISO `yyyy-MM-dd` strings, the same as the engine's `date` kind:
/// the value is data, not display, and it is never a localized format.

/// One work experience record, as the server returns it.
@JsonSerializable(createToJson: false)
@immutable
class ExperienceRecord {
  const ExperienceRecord({
    required this.id,
    required this.roleTitle,
    required this.startedOn,
    required this.isCurrent,
    this.employerName,
    this.occupationId,
    this.endedOn,
    this.responsibilities,
  });

  factory ExperienceRecord.fromJson(Map<String, dynamic> json) =>
      _$ExperienceRecordFromJson(json);

  final String id;

  /// Optional, because §5.1 asks for a simplified entry for informal or
  /// seasonal work — where there is often no employer to name.
  final String? employerName;

  /// The one required field: what the person did.
  final String roleTitle;

  /// An `occupation` dictionary id, so §7.1's "years in the selected
  /// occupation" is computed rather than guessed from the title text.
  final String? occupationId;

  final String startedOn;
  final String? endedOn;
  final bool isCurrent;
  final String? responsibilities;

  ExperienceDraft toDraft() => ExperienceDraft(
    employerName: employerName,
    roleTitle: roleTitle,
    occupationId: occupationId,
    startedOn: startedOn,
    endedOn: endedOn,
    isCurrent: isCurrent,
    responsibilities: responsibilities,
  );
}

/// What an experience editor holds and sends. No id: see the note above.
@JsonSerializable()
@immutable
class ExperienceDraft {
  const ExperienceDraft({
    this.employerName,
    this.roleTitle = '',
    this.occupationId,
    this.startedOn,
    this.endedOn,
    this.isCurrent = false,
    this.responsibilities,
  });

  factory ExperienceDraft.fromJson(Map<String, dynamic> json) =>
      _$ExperienceDraftFromJson(json);

  final String? employerName;
  final String roleTitle;
  final String? occupationId;

  /// Nullable only while the editor is open — [isComplete] gates the save.
  final String? startedOn;

  final String? endedOn;
  final bool isCurrent;
  final String? responsibilities;

  /// The two the server requires. Everything else is genuinely optional, and
  /// the simplified-entry rule is the reason: a seasonal worker may be able to
  /// name only what they did and when they started.
  bool get isComplete => roleTitle.trim().length >= 2 && startedOn != null;

  Map<String, dynamic> toJson() => _$ExperienceDraftToJson(this);

  ExperienceDraft copyWith({
    Object? employerName = _unset,
    String? roleTitle,
    Object? occupationId = _unset,
    Object? startedOn = _unset,
    Object? endedOn = _unset,
    bool? isCurrent,
    Object? responsibilities = _unset,
  }) => ExperienceDraft(
    employerName: employerName == _unset
        ? this.employerName
        : employerName as String?,
    roleTitle: roleTitle ?? this.roleTitle,
    occupationId: occupationId == _unset
        ? this.occupationId
        : occupationId as String?,
    startedOn: startedOn == _unset ? this.startedOn : startedOn as String?,
    endedOn: endedOn == _unset ? this.endedOn : endedOn as String?,
    isCurrent: isCurrent ?? this.isCurrent,
    responsibilities: responsibilities == _unset
        ? this.responsibilities
        : responsibilities as String?,
  );
}

/// One education record, as the server returns it.
@JsonSerializable(createToJson: false)
@immutable
class EducationRecord {
  const EducationRecord({
    required this.id,
    required this.levelId,
    this.institution,
    this.specialization,
    this.graduationYear,
  });

  factory EducationRecord.fromJson(Map<String, dynamic> json) =>
      _$EducationRecordFromJson(json);

  final String id;

  /// An `education_level` dictionary id — the one required field.
  final String levelId;

  final String? institution;
  final String? specialization;
  final int? graduationYear;

  EducationDraft toDraft() => EducationDraft(
    levelId: levelId,
    institution: institution,
    specialization: specialization,
    graduationYear: graduationYear,
  );
}

/// What an education editor holds and sends.
@JsonSerializable()
@immutable
class EducationDraft {
  const EducationDraft({
    this.levelId,
    this.institution,
    this.specialization,
    this.graduationYear,
  });

  factory EducationDraft.fromJson(Map<String, dynamic> json) =>
      _$EducationDraftFromJson(json);

  /// Nullable only while the editor is open — [isComplete] gates the save.
  final String? levelId;

  final String? institution;
  final String? specialization;
  final int? graduationYear;

  bool get isComplete => levelId != null;

  Map<String, dynamic> toJson() => _$EducationDraftToJson(this);

  EducationDraft copyWith({
    Object? levelId = _unset,
    Object? institution = _unset,
    Object? specialization = _unset,
    Object? graduationYear = _unset,
  }) => EducationDraft(
    levelId: levelId == _unset ? this.levelId : levelId as String?,
    institution: institution == _unset
        ? this.institution
        : institution as String?,
    specialization: specialization == _unset
        ? this.specialization
        : specialization as String?,
    graduationYear: graduationYear == _unset
        ? this.graduationYear
        : graduationYear as int?,
  );
}

/// Sentinel telling "leave this field alone" apart from "set it to null".
///
/// Every optional field here is clearable, so a plain `?? this.x` copyWith
/// could never clear one — it would silently keep the old value, which is the
/// same class of bug as treating a null edit as "no edit" in the form engine.
const _unset = Object();
