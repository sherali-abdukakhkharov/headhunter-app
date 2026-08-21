/// §10.2's two moderation outcomes (BR-04).
///
/// ## Approving is what publishes it
///
/// BR-04 makes moderation the gate on publication: a submitted vacancy reaches
/// no candidate until a moderator passes it, and for a **BR-12 restricted**
/// vacancy this is the only route to `active` there is — which is the point of
/// making review part of the rule rather than a spot check.
///
/// So there is no "approve without publishing". The server moves the status to
/// `active` and the vacancy is live; a moderator who wants it seen and then
/// held uses §10.2's pause instead, which is a different action on a different
/// route.
///
/// ## The rejection reason is mandatory, and it is the whole of the feedback
///
/// The server refuses a rejection with no reason —
/// `vacancy.moderation_reason_required` — and §6.4 shows that text to the
/// employer **verbatim** (§2.4). Editing a rejected vacancy returns it to
/// draft, so the reason is not a verdict but an instruction: it is the only
/// thing telling the employer what to change before submitting again.
enum ModerationDecision {
  /// Publishes it (BR-04). No reason wanted, and none is asked for.
  approve('active'),

  /// Sends it back. §6.4 puts a rejected vacancy back in the employer's hands,
  /// so this is a correction path rather than an ending.
  reject('rejected');

  const ModerationDecision(this.wire);

  /// The status the route takes — a *destination* rather than a verb, because
  /// that is what `POST /admin/moderation/:vacancyId` accepts.
  final String wire;

  /// Whether the server will refuse this decision without a reason.
  bool get needsReason => this == ModerationDecision.reject;
}
