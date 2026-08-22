/// How §10.2's review of a complaint ends.
///
/// Mirrors `ComplaintReviewDto.outcome`.
///
/// ## Both outcomes need a resolution, unlike every other §10.2 decision
///
/// The verification and moderation queues take a reason only for a refusal,
/// because an approval explains itself. A complaint does not: `dismissed` is
/// the more contested half of the two — somebody reported something and was
/// told no — and the server makes `resolution` mandatory on both for that
/// reason ("a review with no resolution is a status change nobody can account
/// for"). Nothing else records a complaint review, so the audit row is the
/// only record there is.
enum ComplaintOutcome {
  /// Something was done about it. Says nothing about *what*: the remedy is a
  /// separate route, so an `actioned` complaint with no action taken is a true
  /// statement of the record and a false statement about the world. Which is
  /// why the review screen puts the remedy above the outcome.
  actioned('actioned'),

  /// The complaint does not stand.
  dismissed('dismissed');

  const ComplaintOutcome(this.wire);

  final String wire;
}

/// §10.2's "pause, or remove a vacancy with an audit record".
///
/// `PUT /admin/vacancies/:vacancyId/status`, for a vacancy that is **already
/// published** — which is why it is not part of the moderation queue: that
/// queue only ever holds `under_moderation`, and this is the route for a
/// complaint upheld or a policy breach found later.
enum VacancyAdminStatus {
  /// Off the feed, and reversible: `paused → active` exists, so a pause is the
  /// proportionate answer while something is being checked.
  paused('paused'),

  /// **Terminal** (BR-11). A closed vacancy leaves discovery and stays in
  /// history; nothing reopens it, because "closed" would then mean nothing to
  /// the candidates who saw it.
  closed('closed');

  const VacancyAdminStatus(this.wire);

  /// The actions a vacancy in [status] can actually take.
  ///
  /// This mirrors the **administrative** transition table in the backend's
  /// `vacancy-status.ts` — the one `PUT /admin/vacancies/:id/status` checks:
  /// `active → paused | closed`, `paused → closed`, and `closed` is terminal
  /// (BR-11). A vacancy still in `draft`, `under_moderation` or `rejected` was
  /// never published, so neither applies.
  ///
  /// **Administrative specifically**, and that is the useful precision: that
  /// file holds several tables. The employer's own transitions and
  /// moderation's `active | rejected` decision are separate, so a change to
  /// either of those does not reach this list and must not be mirrored into
  /// it. `closed` being terminal is enforced by the table alone — a reopen
  /// path would be a schema question rather than a table edit, so it would not
  /// arrive quietly.
  ///
  /// Restating a server table in the client is safe here for the same reason
  /// the decision sheet's mandatory reason is: the client is the **stricter**
  /// of the two. The cost if the table ever moves is a hidden action rather
  /// than a button that answers 409 every time it is pressed, and that is the
  /// direction to be wrong in. Confirmed against the backend on 2026-08-22,
  /// including an undertaking to say before it moves.
  static List<VacancyAdminStatus> availableFor(String? status) =>
      switch (status) {
        'active' => const [
          VacancyAdminStatus.paused,
          VacancyAdminStatus.closed,
        ],
        'paused' => const [VacancyAdminStatus.closed],
        _ => const [],
      };

  final String wire;
}
