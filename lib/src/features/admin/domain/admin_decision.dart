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
