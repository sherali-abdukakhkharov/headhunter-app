/// §10.2's three verification outcomes.
///
/// ## The reason is mandatory for anything but an approval
///
/// The server refuses a non-approval with no reason —
/// `employer.verification_reason_required`, a 403 — and this enum carries that
/// rule so the administrator reads it *before* the request rather than as a
/// refusal after it. The same idiom as BR-12 gating Apply in the candidate
/// search filter builder: re-making a server rule in the client is safe
/// exactly when the client is the stricter of the two, and it turns a rejection
/// into a disabled button with a label.
///
/// The rule is not arbitrary. §6.1's rejected and changes-required states show
/// the administrator's reason to the employer **verbatim** (§2.4), so a reason
/// that does not exist is a screen telling somebody their documents were
/// refused and not saying what to fix.
enum VerificationDecision {
  /// Approves. This is what makes BR-03 pass for that employer, which unblocks
  /// their vacancy submissions *and* their invitations at once.
  verified('verified'),

  /// Sends it back to be re-submitted. The employer keeps their profile and
  /// their files; §6.1 puts them back in a state they can act on.
  changesRequired('changes_required'),

  /// Refuses it. §6.1's terminal refusal, and the reason is the whole of what
  /// the employer is left with.
  rejected('rejected');

  const VerificationDecision(this.wire);

  /// The value `POST /admin/verification/:employerUserId` takes.
  final String wire;

  /// Whether the server will refuse this decision without a reason.
  bool get needsReason => this != VerificationDecision.verified;
}

/// Somebody already decided this submission.
///
/// Its own type rather than an [Exception] rendered as a failure, because a
/// FIFO queue worked by more than one administrator produces this **normally**:
/// two people open the top item, one decides, the other's request answers 409
/// `employer.verification_not_pending`. Nothing went wrong — the work is done —
/// so the screen says so and reloads the queue rather than offering a retry
/// that would 409 again.
class VerificationAlreadyDecided implements Exception {
  const VerificationAlreadyDecided(this.message);

  /// The server's own sentence, already in the caller's language.
  final String message;
}
