import 'package:flutter/foundation.dart';

/// §10.1's administrator dashboard, in one response.
///
/// Mirrors `DashboardDto` in headhunter-backend — change both together.
///
/// ## Two kinds of number, and the type keeps them apart
///
/// §10.1 lists its counters as one paragraph, but they are not one kind of
/// fact. [candidates], [employers], [activeVacancies] and [applications] are
/// **bounded by [period]**; [awaitingVerification], [awaitingModeration],
/// [openComplaints], [restrictedUsers] and [blockedUsers] are **current
/// state**, and the backend says why in its own contract: what matters about a
/// queue is how long it is now.
///
/// Rendering a queue length under a date range would say "seven employers
/// waited during July". Seven are waiting *now*, and the sentence would be
/// false the moment the period ended. So the screen groups them the way this
/// class does, and the grouping is the reason the class exists rather than a
/// flat bag of ints.
@immutable
class AdminDashboard {
  const AdminDashboard({
    required this.period,
    required this.candidates,
    required this.employers,
    required this.awaitingVerification,
    required this.awaitingModeration,
    required this.activeVacancies,
    required this.applications,
    required this.openComplaints,
    required this.restrictedUsers,
    required this.blockedUsers,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => AdminDashboard(
    period: DashboardPeriod.fromJson(json['period'] as Map<String, dynamic>),
    candidates: CountPair.fromJson(json['candidates'] as Map<String, dynamic>),
    employers: CountPair.fromJson(json['employers'] as Map<String, dynamic>),
    awaitingVerification: _int(json['awaitingVerification']),
    awaitingModeration: _int(json['awaitingModeration']),
    activeVacancies: _int(json['activeVacancies']),
    applications: _int(json['applications']),
    openComplaints: _int(json['openComplaints']),
    restrictedUsers: _int(json['restrictedUsers']),
    blockedUsers: _int(json['blockedUsers']),
  );

  /// The period the **server** applied, which is not always the one requested:
  /// sending nothing gets the last thirty days, and the response is how the
  /// client learns which thirty.
  final DashboardPeriod period;

  final CountPair candidates;
  final CountPair employers;

  /// Employers whose verification is pending, right now (§10.2's first queue).
  final int awaitingVerification;

  /// Vacancies under moderation, right now (BR-04).
  final int awaitingModeration;

  /// Published inside [period].
  final int activeVacancies;

  /// Submitted inside [period].
  final int applications;

  final int openComplaints;

  /// Accounts an administrator has restricted (§4.2) — they can still sign in.
  final int restrictedUsers;

  /// Accounts BR-10 shuts out entirely. Counted apart from [restrictedUsers]
  /// because the two are different states with different remedies, and adding
  /// them together would hide the more serious one inside the milder one.
  final int blockedUsers;

  /// Whether anything at all is waiting on an administrator.
  ///
  /// Complaints included: §10.2 puts the complaint queue beside the other two,
  /// and a dashboard that says "nothing to do" while a complaint sits open
  /// would be the one screen in the product actively hiding work.
  bool get hasQueuedWork =>
      awaitingVerification > 0 || awaitingModeration > 0 || openComplaints > 0;

  /// `(json as num).toInt()`, tolerating the `number` OpenAPI types a count as.
  static int _int(Object? value) => value is num ? value.toInt() : 0;
}

/// One §10.1 count and how much of it is new (`CountPairDto`).
@immutable
class CountPair {
  const CountPair({required this.total, required this.newInPeriod});

  factory CountPair.fromJson(Map<String, dynamic> json) => CountPair(
    total: AdminDashboard._int(json['total']),
    // `new` is a Dart keyword, so the field is renamed and the wire key is
    // not. Reading `json['newInPeriod']` would silently yield zero.
    newInPeriod: AdminDashboard._int(json['new']),
  );

  /// Everyone registered, ever.
  final int total;

  /// Registered inside the dashboard's period.
  final int newInPeriod;
}

/// The date range §10.1 calls "the selected period", inclusive at both ends.
///
/// Date-only, and deliberately not a [DateTime] pretending to be an instant: a
/// day has no offset, and parsing `2026-07-08` in the device's zone then
/// subtracting days can land on 23:00 the day before across a DST boundary —
/// which formats back as the *wrong date*. Every date here is built with
/// [DateTime.utc] for that reason alone.
@immutable
class DashboardPeriod {
  const DashboardPeriod({required this.from, required this.to});

  factory DashboardPeriod.fromJson(Map<String, dynamic> json) =>
      DashboardPeriod(
        from: parseDate(json['from'] as String),
        to: parseDate(json['to'] as String),
      );

  /// Inclusive start.
  ///
  /// **Both ends are inclusive calendar dates in `PLATFORM_TIME_ZONE`**, and
  /// that was confirmed at the contract on 2026-08-22 rather than assumed: the
  /// server had been casting these to `::date` and comparing against a
  /// `timestamptz`, which Postgres resolves in the *session* zone — so a
  /// period starting `2026-08-01` actually started at 05:00 Tashkent and missed
  /// anyone who registered overnight. Every count on this screen was wrong at
  /// both ends, in the same direction.
  ///
  /// Nothing here needed changing when it was fixed, which is the payoff of
  /// keeping this type to **dates**: hand-split, UTC-flagged, whole-day
  /// arithmetic, never an instant and never the device's idea of today. The
  /// strings mean what the field names say and the server decides which
  /// instants they resolve to. That is also the only reason a client can send a
  /// date to a single-zone product safely — see MEMORY.md, because the
  /// arithmetic being right did not stop the figures being wrong.
  final DateTime from;

  /// Inclusive end. The server's "today" in `PLATFORM_TIME_ZONE`, unless the
  /// caller asked for something else.
  final DateTime to;

  /// Whole days covered, both ends counted — so a one-day period is 1, not 0.
  int get days => to.difference(from).inDays + 1;

  /// `2026-07-08` → `DateTime.utc(2026, 7, 8)`.
  ///
  /// Hand-split rather than [DateTime.parse] so the result cannot be a local
  /// midnight that shifts under arithmetic.
  static DateTime parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected a yyyy-MM-dd date.', value);
    }

    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Back to the wire format the query parameters take.
  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// A period to ask the dashboard for.
///
/// ## The client never invents "today"
///
/// `to` defaults server-side to today in `PLATFORM_TIME_ZONE`, and that is the
/// only clock the platform agrees on. An administrator travelling — or a device
/// whose zone is simply wrong — would compute a different day, and the figures
/// would quietly disagree with everyone else's for a day at each end.
///
/// So there is no `DashboardRange.lastMonth()` reading the device clock.
/// [DashboardRange.lastDays] counts back from a date the **server** sent, which
/// is why it takes an `endingOn` rather than defaulting it: a range is a query
/// the client may compose, and a calendar is not something it may guess.
@immutable
class DashboardRange {
  const DashboardRange({required this.from, required this.to});

  /// The [days]-day window ending on [endingOn], both ends inclusive.
  ///
  /// So `lastDays(30, endingOn: 8 August)` starts on 10 July — 30 days
  /// *including* today, matching the backend's own default rather than being
  /// one day wider than it.
  factory DashboardRange.lastDays(int days, {required DateTime endingOn}) =>
      DashboardRange(
        from: endingOn.subtract(Duration(days: days - 1)),
        to: endingOn,
      );

  final DateTime from;
  final DateTime to;

  String get fromWire => DashboardPeriod.formatDate(from);
  String get toWire => DashboardPeriod.formatDate(to);

  @override
  bool operator ==(Object other) =>
      other is DashboardRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}
