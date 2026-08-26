import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// What an audit row is about (§10.4).
///
/// Five kinds, and the client draws all five — unlike a complaint target,
/// which it can act on, this is a record of something that already happened,
/// so a kind this build does not recognise still renders as a row with a date
/// and an action. It just cannot be named.
enum AuditTargetType {
  user('user'),
  employer('employer'),
  vacancy('vacancy'),
  complaint('complaint'),
  dictionaryItem('dictionary_item'),

  /// A kind added after this build shipped.
  unknown('');

  const AuditTargetType(this.wire);

  factory AuditTargetType.fromWire(String? value) => values.firstWhere(
    (target) => target.wire == value,
    orElse: () => AuditTargetType.unknown,
  );

  final String wire;
}

/// One row of §10.4's immutable log.
///
/// Mirrors `AuditEntryDto` in headhunter-backend — change both together.
///
/// ## Immutability is the table's property, not this client's
///
/// Three statement-level triggers refuse `UPDATE`, `DELETE` and `TRUNCATE` on
/// the backing table, which is worth knowing here for one reason: nothing on
/// this screen may offer to edit or hide a row, and no future "tidy up the
/// log" feature is implementable. The log is the account of what was done.
///
/// ## [details] is opaque and stays that way
///
/// Its keys differ per [action], are enumerated nowhere, and a client that
/// guessed at them would be wrong for the next action added. So it is rendered
/// as text — key beside value — and **never parsed**. Any timestamp inside
/// already carries §2's offset because it was formatted where it was written:
/// a `jsonb` bag admits no read-side fix, since nothing downstream can tell a
/// timestamp from any other string.
@immutable
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.actorUserId,
    required this.action,
    required this.targetType,
    required this.createdAt,
    this.actorName,
    this.targetId,
    this.targetName,
    this.reason,
    this.details,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
    id: json['id'] as String,
    actorUserId: json['actorUserId'] as String,
    actorName: json['actorName'] as String?,
    action: json['action'] as String,
    targetType: AuditTargetType.fromWire(json['targetType'] as String?),
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    targetId: json['targetId'] as String?,
    targetName: json['targetName'] as String?,
    reason: json['reason'] as String?,
    details: switch (json['details']) {
      final Map<String, dynamic> bag => bag,
      _ => null,
    },
  );

  final String id;

  /// The administrator who did it.
  ///
  /// Kept beside [actorName] rather than replaced by it, because a name is not
  /// an account: this is what the row *opens*, and what "everything this
  /// administrator has done" filters on.
  final String actorUserId;

  /// Who [actorUserId] is, resolved by the server (2026-08-26).
  ///
  /// Null for an administrator with no name anywhere, which a seeded account
  /// is — so a reader still needs the uuid as a fallback, and the screen shows
  /// it.
  ///
  /// The client deliberately does **not** resolve this itself, and could not
  /// affordably: a name per distinct actor would mean `GET /admin/users/:id`
  /// each, which returns a phone number, a status history and a complaint list
  /// to obtain a string, and writes a §11.1 access log line every time. Twenty
  /// rows would buy a page of names with a page of logged reads of other
  /// people's contact details, on a screen nobody opened to read contact
  /// details. The server resolves it once, in the query already reading the
  /// row.
  final String? actorName;

  /// A dotted code from one exported constant on the server, e.g.
  /// `user.blocked`, `vacancy.moderated`, `dictionary.items_merged`.
  ///
  /// Kept as a **string**, not an enum. The set grows server-side and a row
  /// this build cannot name must still render: the code itself is a stable
  /// identifier somebody can search the backend for, which is more use than a
  /// row that says "unknown action" or, worse, one that does not appear.
  final String action;

  final AuditTargetType targetType;

  /// Null on the few actions with no single target. A uuid — and for
  /// [AuditTargetType.user] it is the one kind this app has a screen for.
  final String? targetId;

  /// Who [targetId] is, and **only when [targetType] is
  /// [AuditTargetType.user]**.
  ///
  /// Null for the other four, which are not accounts and have no name to
  /// resolve. A vacancy's title and a dictionary item's label are in [details]
  /// instead, put there by the action that touched them — so a row about one of
  /// those is not nameless, it just does not name it here.
  final String? targetName;

  /// What the administrator typed, shown **verbatim** (§2.4).
  final String? reason;

  /// See the class doc: opaque, rendered as text, never parsed.
  final Map<String, dynamic>? details;

  final ZonedTimestamp createdAt;

  /// [details] flattened into printable pairs, in the order the server sent
  /// them.
  ///
  /// A non-primitive value is JSON-encoded rather than `toString()`d, so a
  /// nested object reads as `{"a":1}` instead of Dart's `{a: 1}` — the first
  /// is what a support engineer can paste back into a query, and the second is
  /// a notation that exists nowhere else in the system.
  List<(String, String)> get detailPairs => [
    for (final entry in (details ?? const <String, dynamic>{}).entries)
      (
        entry.key,
        switch (entry.value) {
          final String value => value,
          final num value => '$value',
          final bool value => '$value',
          null => '—',
          final Object value => jsonEncode(value),
        },
      ),
  ];
}

/// Which slice of the log is being looked at (§10.4).
///
/// The section names two questions and this is both of them: "what has this
/// administrator done" ([actorUserId]) and "what was done to this thing"
/// ([targetType] plus [targetId]). An empty query is the whole log, newest
/// first.
///
/// A value type because it keys the provider family — two questions asked in
/// one session must not overwrite each other's results, and a query that is
/// equal is the same question.
@immutable
class AuditQuery {
  const AuditQuery({this.actorUserId, this.targetType, this.targetId});

  /// Reads three raw values off a route.
  ///
  /// Takes strings rather than the route's parameter map because the parameter
  /// *names* belong to `Routes` with every other one, and a domain type that
  /// knew them would be the feature reaching into the router.
  ///
  /// A target type this build does not recognise is **dropped rather than
  /// forwarded**: a mistyped deep link should show the whole log, not a filter
  /// the server refuses with a 400.
  factory AuditQuery.fromWire({
    String? actorUserId,
    String? targetType,
    String? targetId,
  }) {
    final type = AuditTargetType.fromWire(targetType);

    return AuditQuery(
      actorUserId: actorUserId,
      targetType: type == AuditTargetType.unknown ? null : type,
      targetId: targetId,
    );
  }

  final String? actorUserId;
  final AuditTargetType? targetType;
  final String? targetId;

  /// The whole log.
  bool get isEmpty =>
      actorUserId == null && targetType == null && targetId == null;

  Map<String, dynamic> toQuery() => {
    'actorUserId': ?actorUserId,
    'targetType': ?targetType?.wire,
    'targetId': ?targetId,
  };

  @override
  bool operator ==(Object other) =>
      other is AuditQuery &&
      other.actorUserId == actorUserId &&
      other.targetType == targetType &&
      other.targetId == targetId;

  @override
  int get hashCode => Object.hash(actorUserId, targetType, targetId);

  @override
  String toString() =>
      'AuditQuery(actor: $actorUserId, target: ${targetType?.wire} $targetId)';
}
