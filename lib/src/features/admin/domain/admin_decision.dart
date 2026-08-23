/// Somebody already decided the thing this administrator was deciding.
///
/// Its own type rather than an exception rendered as a failure, because a FIFO
/// queue worked by more than one administrator produces this **normally**: two
/// people open the top item, one decides, and the other's request answers 409 —
/// `employer.verification_not_pending` on §10.2's first queue,
/// `vacancy.not_under_moderation` on its second.
///
/// Nothing went wrong and the work *is* done, so both queues answer it the same
/// way: the row leaves the list exactly as it would have on success, and only
/// the confirmation differs.
///
/// One type for both, because the remedy is identical and the two queues sit
/// behind one tab. A per-queue exception would make the shared decision sheet
/// carry a branch that says nothing.
class AdminDecisionConflict implements Exception {
  const AdminDecisionConflict(this.message);

  /// The server's own sentence, already in the caller's language.
  final String message;
}

/// What an administrator filled in before confirming a decision.
///
/// One object rather than a widening list of callback parameters, because
/// every §10 decision takes a reason and exactly one of them takes a second
/// value — §10.4's restriction end date. A second positional parameter would
/// put a date nobody uses in the signature of five sheets that have no date.
class AdminDecisionInput {
  const AdminDecisionInput({this.reason, this.until});

  /// Trimmed, and null when the field was left empty. Never empty-string: a
  /// route that requires a reason must fail on an absent one, not on a blank.
  final String? reason;

  /// §10.4's `restrictedUntil`, already converted to the value the route
  /// takes. Null everywhere else, and null on a restriction with no end.
  final String? until;
}

/// An optional second field on a decision sheet: a date.
///
/// Only §10.4's restriction has one. It is described rather than built by the
/// sheet so that the conversion from *a day somebody tapped on a calendar* to
/// *the instant the route means* stays with the caller — that conversion needs
/// the platform's offset, which is a fact about a server response and not
/// something a bottom sheet should know.
class AdminDecisionDate {
  const AdminDecisionDate({
    required this.label,
    required this.caption,
    required this.toWire,
  });

  final String label;

  /// Shown under the field. It has to say what **leaving it empty** means,
  /// because an optional date whose absence is a different outcome is the one
  /// field a confirmation sheet cannot leave unexplained.
  final String caption;

  /// Turns the picked calendar day (`yyyy-MM-dd`) into the wire value.
  final String Function(String day) toWire;
}

/// What a decision sheet ended up doing.
///
/// Three outcomes rather than a bool, because "dismissed" and "somebody else
/// got there first" must not be confirmed to the administrator as their own
/// decision — and the second one still empties a row from the queue.
enum AdminDecisionOutcome {
  /// This administrator's decision was recorded.
  sent,

  /// The server answered 409: already decided, by someone else.
  alreadyDecided,

  /// The sheet was closed without deciding anything.
  dismissed,
}
