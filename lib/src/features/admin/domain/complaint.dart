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
    this.targetSummary,
    this.resolution,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: json['id'] as String,
    targetType: ComplaintTarget.fromWire(json['targetType'] as String?),
    targetId: json['targetId'] as String,
    targetSummary: json['targetSummary'] as String?,
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

  /// The reported thing's id. The detail route resolves it to a small row;
  /// this is what a short reference is built from when there is no name.
  final String targetId;

  /// What the reported thing **is**, in one line (MT-017).
  ///
  /// A vacancy's title, a person's name, and for a message the **sender's**
  /// name — not the body. That last one is the server's privacy decision and
  /// worth knowing here: a queue is not the place to read twenty private
  /// messages, and the review screen shows the message itself after a
  /// deliberate open.
  ///
  /// Null when the target has been deleted, which a complaint is meant to
  /// outlive. [targetReference] is what the card shows instead.
  final String? targetSummary;

  /// A short, stable stand-in for a target with no name.
  ///
  /// The first eight characters of the id. Enough to tell two rows apart and to
  /// carry into a support conversation, without putting a 36-character uuid on
  /// a card. Built here rather than sent by the server: it is a truncation of a
  /// field that already travels, and a second field could disagree with the
  /// first.
  String get targetReference => targetId.length <= 8
      ? targetId
      : targetId.substring(0, 8);

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
