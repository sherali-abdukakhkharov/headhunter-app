import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// One employer waiting on §10.2's verification decision.
///
/// Mirrors `VerificationQueueItemDto` in headhunter-backend — change both
/// together.
///
/// ## The queue item *is* the review
///
/// Everything §10.2 asks an administrator to look at — which kind of employer,
/// the names, where they are, and every piece of evidence they uploaded —
/// arrives in the list response. So there is no detail screen and no second
/// request: a route that re-fetched data already in hand would cost a round
/// trip to show the same fields, and the administrator would lose their place
/// in the queue to read them.
///
/// What is deliberately **not** here is anything about contact. §11.1 protects
/// an employer's phone and e-mail the same way it protects a candidate's, and
/// approving a submission needs neither, so the DTO carries neither.
@immutable
class VerificationQueueItem {
  const VerificationQueueItem({
    required this.employerUserId,
    required this.type,
    required this.submittedAt,
    required this.files,
    this.name,
    this.legalName,
    this.regionId,
  });

  factory VerificationQueueItem.fromJson(Map<String, dynamic> json) =>
      VerificationQueueItem(
        employerUserId: json['employerUserId'] as String,
        type: json['type'] as String,
        submittedAt: ZonedTimestamp.parse(json['submittedAt'] as String),
        files: switch (json['files']) {
          final List<dynamic> list => list
              .whereType<Map<String, dynamic>>()
              .map(EvidenceFile.fromJson)
              .toList(),
          _ => const <EvidenceFile>[],
        },
        name: json['name'] as String?,
        legalName: json['legalName'] as String?,
        regionId: json['regionId'] as String?,
      );

  /// The employer's **user** id, which is what the decision route takes.
  final String employerUserId;

  /// `company` or `individual`. §6.1 gives the two different fields, so the
  /// card says which it is rather than leaving an empty legal name to imply it.
  final String type;

  /// When the employer submitted. The queue is oldest-first, so on the top card
  /// this is the longest anyone has been waiting.
  final ZonedTimestamp submittedAt;

  /// §10.2's "uploaded evidence". Possibly empty: the server refuses a
  /// submission missing a *required* document, not one missing an optional one.
  final List<EvidenceFile> files;

  /// Public name — a company's trading name, an individual's full name.
  final String? name;

  /// A company's registered legal name, null for an individual employer.
  final String? legalName;

  /// A dictionary **id** (BR-13). Resolved to a label for display, never shown
  /// raw and never compared as text.
  final String? regionId;

  /// True for `company`, so a caller need not spell the wire value twice.
  bool get isCompany => type == 'company';

  /// The name to head the card with, preferring the registered one.
  ///
  /// A company is decided on its legal identity — that is what the evidence
  /// documents are about — so the legal name leads where there is one and the
  /// trading name sits under it. Null when the employer has filled in neither,
  /// which is a real state: verification can be submitted from a profile that
  /// is complete enough for the server and still thin on screen.
  String? get displayName => legalName ?? name;

  /// The other name, when it differs from [displayName] and adds something.
  String? get secondaryName {
    final second = legalName == null ? null : name;
    return second == displayName ? null : second;
  }
}

/// A file attached to a verification submission (`EvidenceFileDto`).
@immutable
class EvidenceFile {
  const EvidenceFile({
    required this.id,
    required this.purposeCode,
    required this.fileName,
    required this.path,
  });

  factory EvidenceFile.fromJson(Map<String, dynamic> json) => EvidenceFile(
    id: json['id'] as String,
    purposeCode: json['purposeCode'] as String,
    fileName: json['fileName'] as String,
    path: json['path'] as String,
  );

  final String id;

  /// A `file_purpose` dictionary code — an admin-editable row (§10.3), so it is
  /// rendered as the server's own code rather than mapped to a Dart enum that
  /// would go stale the day a purpose is added.
  final String purposeCode;

  /// The name the employer's device gave the file. **Content, not a path**:
  /// used for an extension and a label and nothing else (§2.4).
  final String fileName;

  /// Where to fetch it on this API, built by the server (ARCHITECTURE.md §9).
  ///
  /// Followed verbatim and never constructed here. Every download is logged
  /// because §11.1 requires access to protected data to be, which is also why
  /// nothing prefetches these: a speculative read would write an audit entry
  /// nobody asked for, into the log that exists to make reads accountable.
  final String path;
}
