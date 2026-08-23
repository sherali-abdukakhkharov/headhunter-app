import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// An account's status as §10.4 sees it (BR-08, BR-10).
///
/// **Four values, where the session has three.** `AccountStatus` in
/// `core/auth` is what the *signed-in* account can be, and a session is never
/// `deletion_requested` — BR-14 signs that account out. §10.4 looks at other
/// people's accounts, so it meets the fourth state, and meeting it matters:
/// it is the one state no administrator action applies to.
enum UserAccountStatus {
  active('active'),
  restricted('restricted'),
  blocked('blocked'),

  /// BR-14's own flow owns this. The server refuses every transition out of
  /// it — see [UserStatusChange.availableFor].
  deletionRequested('deletion_requested');

  const UserAccountStatus(this.wire);

  /// Anything unrecognised reads as [active], which is the same fallback rule
  /// `accountStatusBadge` already follows: a status a build has not heard of
  /// must not blank out the row it belongs to. It can only ever be a status
  /// added after this build shipped, and the actions offered for `active` are
  /// the ordinary ones — the server refuses anything it should not accept.
  factory UserAccountStatus.fromWire(String? value) =>
      values.firstWhere((s) => s.wire == value, orElse: () => active);

  final String wire;
}

/// The three status changes §10.4 gives an administrator (UAT-14).
///
/// `active` is the unblock — one route sets all three, because they differ
/// only in the status they write.
enum UserStatusChange {
  restricted('restricted'),
  blocked('blocked'),
  active('active');

  const UserStatusChange(this.wire);

  final String wire;

  /// What may be done to an account in [current], in the order it is offered.
  ///
  /// The client is the stricter of the two here, which is the only direction
  /// in which restating a server rule is safe — and the cost if the server's
  /// table moves is a hidden action rather than a broken one. Three facts
  /// drive it:
  ///
  /// - A status change **to the state it is already in** answers 409
  ///   `admin.status_unchanged`, so no status offers itself.
  /// - There is no `restricted → restricted`, so a restriction's end date
  ///   cannot be *extended*: lift it and restrict again. That is the server's
  ///   shape rather than an omission here, and it is recorded in TODO.md.
  /// - `deletion_requested` offers **nothing**. BR-14 owns that state and the
  ///   server answers the same 409 for it — which is why the client must not
  ///   let an administrator reach it. Told apart on screen instead, because
  ///   the two readings of that one code are opposites: "somebody did this
  ///   before you and the work is done" versus "this can never be done from
  ///   here".
  static List<UserStatusChange> availableFor(UserAccountStatus current) =>
      switch (current) {
        UserAccountStatus.active => const [restricted, blocked],
        UserAccountStatus.restricted => const [blocked, active],
        UserAccountStatus.blocked => const [active],
        UserAccountStatus.deletionRequested => const [],
      };

  /// The status an account is in once this change lands.
  UserAccountStatus get result => switch (this) {
    restricted => UserAccountStatus.restricted,
    blocked => UserAccountStatus.blocked,
    active => UserAccountStatus.active,
  };
}

/// One account in §10.4's search results.
///
/// Mirrors `AdminUserDto` in headhunter-backend — change both together.
///
/// ## The phone is here because BR-09 has an `admin` branch
///
/// Every other surface in this product hides a phone number until something
/// entitles the viewer to it — a paid unlock for an employer (§6.6), never a
/// search card (BR-09). An administrator is the branch the rule already has:
/// §10.4 asks for search *by* phone, and §11.1 answers it by logging every
/// read rather than by withholding the field. So the number is shown, and the
/// screen that shows it is one an administrator had to ask for.
@immutable
class AdminUser {
  const AdminUser({
    required this.userId,
    required this.roles,
    required this.status,
    required this.createdAt,
    this.phone,
    this.name,
    this.restrictedUntil,
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    userId: json['userId'] as String,
    roles: parseRoles(json['roles']),
    status: UserAccountStatus.fromWire(json['status'] as String?),
    // Every timestamp on these routes is offset-formatted server-side, all
    // four of them, confirmed against the controller rather than assumed —
    // the `Z` that broke the vacancy review came from a route that had not
    // been through one. See MEMORY.md.
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    phone: json['phone'] as String?,
    name: json['name'] as String?,
    restrictedUntil: _timestamp(json['restrictedUntil']),
    lastLoginAt: _timestamp(json['lastLoginAt']),
  );

  final String userId;

  /// The login number, and §10.4's search key. Null on an account that has
  /// none — the DTO admits it, so the screen says so rather than drawing an
  /// empty line.
  final String? phone;

  /// Resolved by the server from five columns in one order of preference, so
  /// a list and a detail can never disagree about what somebody is called.
  /// Null when the account has no name anywhere yet.
  final String? name;

  /// Every role the account **holds** (§2.3), not the one it is using.
  final List<AppRole> roles;

  final UserAccountStatus status;

  /// When a restriction lifts. BR-10's guard clears it once the instant
  /// passes, so a date in the past on a `restricted` account means the guard
  /// has not been asked yet, not that the client is wrong.
  final ZonedTimestamp? restrictedUntil;

  final ZonedTimestamp createdAt;

  /// Null on an account that has never signed in, which is worth showing: it
  /// is what tells a stalled registration from an abandoned account.
  final ZonedTimestamp? lastLoginAt;

  /// Roles as this build understands them, dropping any it does not.
  ///
  /// Dropping rather than throwing, for the reason `AuthSession.grantedRoles`
  /// gives: the server can grow a role before the app ships support for one,
  /// and a queue that died over a role name would be worse than a row listing
  /// one fewer.
  static List<AppRole> parseRoles(Object? value) => [
    if (value is List)
      for (final role in value)
        if (role is String) ?AppRole.fromWire(role),
  ];

  static ZonedTimestamp? _timestamp(Object? value) =>
      value is String ? ZonedTimestamp.parse(value) : null;
}

/// One account with §10.4's "relevant moderation history".
///
/// Mirrors `AdminUserDetailDto`, which the generator emits **flat** rather
/// than as an `allOf` — so this holds an [AdminUser] and the two lists beside
/// it rather than extending anything. Composition also keeps the row shape
/// the search screen renders identical to the one the detail renders.
///
/// **There are no audit entries here**, confirmed at the contract on
/// 2026-08-22 and worth stating because it is the natural guess: the audit log
/// is a different endpoint and a separate fetch (`GET /admin/audit`). What
/// arrives is BR-08's status trail and the complaints filed about the person.
@immutable
class AdminUserDetail {
  const AdminUserDetail({
    required this.user,
    required this.statusHistory,
    required this.complaints,
  });

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) =>
      AdminUserDetail(
        user: AdminUser.fromJson(json),
        statusHistory: _list(
          json['statusHistory'],
          StatusHistoryEntry.fromJson,
        ),
        complaints: _list(json['complaints'], UserComplaint.fromJson),
      );

  final AdminUser user;

  /// BR-08's account trail, newest first.
  final List<StatusHistoryEntry> statusHistory;

  /// Complaints filed about this person — `user` and `profile` targets both,
  /// which the server resolves to the same row.
  final List<UserComplaint> complaints;

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, dynamic>) parse,
  ) => [
    if (value is List)
      for (final row in value)
        if (row is Map<String, dynamic>) parse(row),
  ];
}

/// One BR-08 status change, as §10.4 reads it back.
@immutable
class StatusHistoryEntry {
  const StatusHistoryEntry({
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.actorRole,
    this.reason,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      StatusHistoryEntry(
        toStatus: UserAccountStatus.fromWire(json['toStatus'] as String?),
        createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
        fromStatus: json['fromStatus'] == null
            ? null
            : UserAccountStatus.fromWire(json['fromStatus'] as String?),
        actorRole: AppRole.fromWire(json['actorRole'] as String?),
        reason: json['reason'] as String?,
      );

  /// Null on the first row — an account's creation, which came from nowhere.
  final UserAccountStatus? fromStatus;

  final UserAccountStatus toStatus;

  /// Who made the change. Null where the platform itself did — BR-10's guard
  /// lifting an expired restriction writes a row with no actor, and that is a
  /// distinction worth keeping on screen: it is the difference between a
  /// decision and a deadline.
  final AppRole? actorRole;

  /// The administrator's own words, shown **verbatim** (§2.4). Null on rows
  /// nobody wrote a reason for, which is every automatic one.
  final String? reason;

  final ZonedTimestamp createdAt;
}

/// A complaint about this person, summarised for §10.4's history.
///
/// Deliberately thinner than §10.2's `Complaint`: this is context for a
/// decision about the *account*, not the complaint queue. It carries no target
/// and no reporter, so nothing here invites re-deciding a complaint from a
/// screen that is not the review.
@immutable
class UserComplaint {
  const UserComplaint({
    required this.id,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory UserComplaint.fromJson(Map<String, dynamic> json) => UserComplaint(
    id: json['id'] as String,
    reason: json['reason'] as String,
    status: json['status'] as String,
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
  );

  final String id;

  /// The reporter's own words (§2.4).
  final String reason;

  /// `open`, `actioned` or `dismissed` — unlike the queue, this list is not
  /// filtered, so a decided complaint appears here and that is the point.
  final String status;

  final ZonedTimestamp createdAt;

  bool get isOpen => status == 'open';
}
