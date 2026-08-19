import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';

/// One direct employer invitation (§8.2).
///
/// Mirrors `InvitationDto` in headhunter-backend — change both together.
///
/// ## Two shapes, and exactly one of them
///
/// §8.2 allows an invitation "attached to an active vacancy or sent as a
/// general work invitation", and the server enforces exactly-one with a CHECK
/// constraint plus an `invitation.shape_invalid` refusal. So [isGeneral] is a
/// null test on [vacancyId] rather than a flag the server sends: a flag could
/// disagree with the ids beside it, and this cannot.
///
/// The two shapes carry their details differently, which is the whole reason
/// they are two shapes. A **vacancy** invitation carries a `vacancyId` and
/// nothing else — occupation, place, schedule and pay all live on the vacancy,
/// and duplicating them into the invitation would let them drift apart from the
/// posting the candidate is about to open. A **general** invitation has no
/// vacancy to borrow from, so it carries its own occupation, location, pay and
/// schedule note.
///
/// ## Every id here is a dictionary id (BR-13)
///
/// [occupationId], [regionId], [districtId] and [salaryPeriodId] are ids, not
/// labels, and must be resolved for display through `resolvedLabelsProvider`.
/// [districtId] resolves against the **`region`** dictionary too — districts
/// are that dictionary's children (§5.1), not a type of their own.
@immutable
class Invitation {
  const Invitation({
    required this.id,
    required this.employerUserId,
    required this.candidateUserId,
    required this.status,
    required this.salaryIsNegotiable,
    required this.createdAt,
    required this.updatedAt,
    this.vacancyId,
    this.occupationId,
    this.regionId,
    this.districtId,
    this.salaryFrom,
    this.salaryTo,
    this.salaryPeriodId,
    this.scheduleNote,
    this.message,
    this.responseNote,
    this.respondedAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
    id: json['id'] as String,
    employerUserId: json['employerUserId'] as String,
    candidateUserId: json['candidateUserId'] as String,
    status: json['status'] as String,
    salaryIsNegotiable: json['salaryIsNegotiable'] as bool? ?? false,
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    updatedAt: ZonedTimestamp.parse(json['updatedAt'] as String),
    vacancyId: json['vacancyId'] as String?,
    occupationId: json['occupationId'] as String?,
    regionId: json['regionId'] as String?,
    districtId: json['districtId'] as String?,
    salaryFrom: (json['salaryFrom'] as num?)?.toInt(),
    salaryTo: (json['salaryTo'] as num?)?.toInt(),
    salaryPeriodId: json['salaryPeriodId'] as String?,
    scheduleNote: json['scheduleNote'] as String?,
    message: json['message'] as String?,
    responseNote: json['responseNote'] as String?,
    respondedAt: switch (json['respondedAt']) {
      final String at => ZonedTimestamp.parse(at),
      _ => null,
    },
  );

  final String id;
  final String employerUserId;
  final String candidateUserId;

  /// One of [InvitationStatus]'s four codes, or something newer.
  final String status;

  /// Null on a general invitation, which carries its own details instead.
  final String? vacancyId;
  final String? occupationId;
  final String? regionId;
  final String? districtId;

  final int? salaryFrom;
  final int? salaryTo;

  /// A `payment_period` dictionary id — per month, per day, per shift.
  final String? salaryPeriodId;

  /// True when the employer said the figure is open to discussion.
  ///
  /// Mutually exclusive with a range **by intent, not by validation**: a
  /// negotiable figure and a stated one are different answers, so the UI shows
  /// one or the other rather than "500,000 (negotiable)".
  final bool salaryIsNegotiable;

  /// Free text on a general invitation (§8.2). Deliberately unstructured — the
  /// structured version of a schedule is what publishing a vacancy is for.
  final String? scheduleNote;

  /// The employer's own words, never translated (§2.4).
  final String? message;

  /// The candidate's reply, and where "Request details" puts its question.
  /// Also the employer's own words in reverse — never translated (§2.4).
  final String? responseNote;

  final ZonedTimestamp? respondedAt;
  final ZonedTimestamp createdAt;
  final ZonedTimestamp updatedAt;

  /// A general work invitation rather than one attached to a vacancy (§8.2).
  bool get isGeneral => vacancyId == null;

  /// Whether the candidate still has an action to take.
  bool get isOpen => !InvitationStatus.terminal.contains(status);

  /// The responses §8.2 offers on this invitation right now, possibly empty.
  List<String> get availableResponses => InvitationStatus.responsesFor(status);

  /// Whether the employer may see this candidate's contact details **because of
  /// this invitation** (§8.2, BR-09).
  ///
  /// Acceptance is what opens contact, and it is the server that decides —
  /// `exposureReason` becomes `accepted_invitation` and the phone appears in
  /// the response. This getter exists to explain *the invitation's* part in
  /// that on the employer's own list, never to unhide a field the server
  /// withheld: BR-17 means the client has no hidden value to reveal.
  bool get opensContact => status == InvitationStatus.accepted;
}
