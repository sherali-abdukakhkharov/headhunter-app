import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate_for_employer.g.dart';

/// One attachment an employer may download (§5.4).
@JsonSerializable(createToJson: false)
@immutable
class CandidateFile {
  const CandidateFile({
    required this.id,
    required this.purposeCode,
    required this.fileName,
    required this.downloadPath,
  });

  factory CandidateFile.fromJson(Map<String, dynamic> json) =>
      _$CandidateFileFromJson(json);

  final String id;
  final String purposeCode;
  final String fileName;

  /// A path on this API, never a storage URL (§11.1).
  ///
  /// **Follow it verbatim. Never construct it.** It is scoped to whatever
  /// entitled this employer to the file, so the same CV is
  /// `/applications/…/files/…/content` for an employer holding an application,
  /// `/invitations/…` for one whose invitation was accepted, and `/unlocks/…`
  /// for one who paid — three routes, and hard-coding any of them works for a
  /// third of the cases.
  ///
  /// The reason it is server-built rather than derivable: BR-09 is re-evaluated
  /// on **every download**, so holding a path is not holding permission. A
  /// candidate who withdraws stops the download working mid-session, and this
  /// path is the only thing that stays in step with which interaction is
  /// currently granting access.
  final String downloadPath;
}

/// A candidate as the employer on their application may see them (BR-09).
///
/// ## The phone is the server's decision, not a field to render blindly
///
/// [phone] is present **only** where the candidate's privacy settings and a
/// hiring interaction both allow it, and null is a normal answer rather than
/// an error. BR-09 is the rule that a phone never appears where it has not
/// been earned; the server decides, and the client's only job is to show what
/// arrived and say nothing when nothing did.
///
/// The same goes for [canViewFiles] — when false the server sends no files,
/// so there is nothing to hide client-side and nothing to leak by mistake.
///
/// [exposureReason] is a stable code explaining the decision, logged with the
/// access (§11.1). It is worth surfacing in diagnostics because "why could
/// this employer not call me" is a question a candidate will ask.
@JsonSerializable(createToJson: false)
@immutable
class CandidateForEmployer {
  const CandidateForEmployer({
    required this.candidateUserId,
    required this.completenessPercent,
    required this.canViewFiles,
    required this.exposureReason,
    required this.files,
    this.fullName,
    this.regionId,
    this.districtId,
    this.availableFrom,
    this.phone,
  });

  factory CandidateForEmployer.fromJson(Map<String, dynamic> json) =>
      _$CandidateForEmployerFromJson(json);

  final String candidateUserId;
  final String? fullName;
  final String? regionId;
  final String? districtId;
  final String? availableFrom;
  final int completenessPercent;

  /// Null unless BR-09 allows it. Never inferred, never cached elsewhere.
  final String? phone;

  final bool canViewFiles;
  final List<CandidateFile> files;
  final String exposureReason;
}

/// §6.5's counts: how many have been hired against how many were needed.
@JsonSerializable(createToJson: false)
@immutable
class ApplicationCounts {
  const ApplicationCounts({
    required this.hiredCount,
    required this.byStatus,
    this.workerCount,
  });

  factory ApplicationCounts.fromJson(Map<String, dynamic> json) =>
      _$ApplicationCountsFromJson(json);

  /// BR-05's required worker count. Null when the vacancy has not said.
  final int? workerCount;

  final int hiredCount;

  /// Applications per stage.
  final Map<String, int> byStatus;

  int get total => byStatus.values.fold(0, (sum, n) => sum + n);
}

/// An employer's private note on an application (§8.2).
@JsonSerializable(createToJson: false)
@immutable
class ApplicationNote {
  const ApplicationNote({
    required this.id,
    required this.note,
    required this.createdAt,
  });

  factory ApplicationNote.fromJson(Map<String, dynamic> json) =>
      _$ApplicationNoteFromJson(json);

  final String id;
  final String note;
  final String createdAt;
}
