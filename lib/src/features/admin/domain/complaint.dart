import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// What a complaint was filed about (§10.2).
///
/// Four kinds from **one** table, which is the backend's own design decision:
/// M6 created a generic `complaints` row so §10.2 is one queue rather than
/// four. The client keeps that shape — a moderator works a queue, not four
/// inboxes, and the oldest open complaint is the oldest open complaint
/// whatever it is about.
///
/// `user` and `profile` resolve to the *same* row and get the same treatment:
/// from a moderator's point of view both questions are "who is this and what
/// state is their account in". They stay two values because the reporter chose
/// between them and the audit trail keeps the choice.
enum ComplaintTarget {
  vacancy('vacancy'),
  user('user'),
  profile('profile'),
  message('message'),

  /// Anything the server sends that this build does not know.
  ///
  /// Not paranoia about a validated enum: §10.3 lets an administrator extend
  /// the platform at runtime, and a client that *threw* on an unrecognised
  /// value would take the whole queue down over one row it could not draw.
  /// This row draws, says what it can, and offers no action.
  unknown('');

  const ComplaintTarget(this.wire);

  factory ComplaintTarget.fromWire(String? value) => values.firstWhere(
    (target) => target.wire == value,
    orElse: () => ComplaintTarget.unknown,
  );

  final String wire;
}

/// One complaint awaiting §10.2's decision.
///
/// Mirrors `ComplaintDto` in headhunter-backend — change both together.
@immutable
class Complaint {
  const Complaint({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reporterUserId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolution,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: json['id'] as String,
    targetType: ComplaintTarget.fromWire(json['targetType'] as String?),
    targetId: json['targetId'] as String,
    reporterUserId: json['reporterUserId'] as String,
    reason: json['reason'] as String,
    status: json['status'] as String,
    // Safe to parse: the controller runs both the list and the detail through
    // `formatWithOffset`, so this carries the platform offset. The *target's*
    // timestamps do not — see [ComplaintTargetDetail].
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    resolution: json['resolution'] as String?,
  );

  final String id;
  final ComplaintTarget targetType;

  /// The reported thing's id. Resolved to a small row by the detail route,
  /// which is the only way to learn what it *is*.
  final String targetId;

  /// Who filed it, and **deliberately not shown**.
  ///
  /// It is a bare uuid — there is no route that turns it into a name — so it
  /// would put an unreadable identifier on a review screen. And a complaint is
  /// judged on what was reported and what the target actually says: inviting a
  /// moderator to weigh who complained is the wrong question in the one place
  /// where §10.2 asks for a fair reading. Kept on the model because the audit
  /// trail is about this record, not about the screen.
  final String reporterUserId;

  /// The reporter's own words. Shown **verbatim** (§2.4) — this is the
  /// accusation, and a paraphrase would be the moderator judging something
  /// nobody said.
  final String reason;

  /// `open`, `actioned` or `dismissed`. Everything in the queue is `open`,
  /// because that is what the server selects.
  final String status;

  /// What a previous moderator decided, where this is not open any more.
  final String? resolution;

  /// When it was filed. The queue is oldest-first.
  final ZonedTimestamp createdAt;

  bool get isOpen => status == 'open';
}
