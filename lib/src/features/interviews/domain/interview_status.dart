/// §8.3's interview statuses and types, and what the candidate may do.
///
/// Plain `String` codes rather than enums, the same rule as `InvitationStatus`
/// and `ApplicationStage`: an unrecognised code from a newer server is carried
/// and displayed rather than crashing the list.
///
/// Mirrors `interview-rules.ts` in headhunter-backend — change both together.
/// Three things are worth stating rather than read off the list:
///
/// - **`confirmed` is not terminal, and that is deliberate.** A candidate who
///   confirmed and then found a clash must be able to ask for another time;
///   §8.3's only ending is `cancelled`.
/// - **The refusal is "the same thing twice", not "you already answered".**
///   `canRespond`'s `to != from` is what blocks confirming twice and asking
///   twice, and it is also what leaves the *other* answer available.
/// - **Cancelling is the employer's and rescheduling resets the answer.** An
///   interview moved to another time comes back as `scheduled` whatever was
///   said about the old time, so the client never has to reconcile a
///   confirmation with a time the candidate never saw.
abstract final class InterviewStatus {
  static const scheduled = 'scheduled';
  static const confirmed = 'confirmed';
  static const rescheduleRequested = 'reschedule_requested';
  static const cancelled = 'cancelled';

  /// All four, in the order `INTERVIEW_STATUSES` declares them.
  static const List<String> all = [
    scheduled,
    confirmed,
    rescheduleRequested,
    cancelled,
  ];

  /// Only cancellation ends an interview (§8.3).
  static const Set<String> terminal = {cancelled};

  /// §8.3's "confirm or request another time", in the order offered.
  static const List<String> candidateResponses = [
    confirmed,
    rescheduleRequested,
  ];

  /// May the candidate move an interview from [from] to [to]?
  ///
  /// An unrecognised [from] yields false rather than throwing: a server that
  /// adds a fifth status should leave the controls off, not crash the screen.
  static bool canRespond(String from, String to) =>
      !terminal.contains(from) && candidateResponses.contains(to) && to != from;

  /// The responses worth offering on an interview currently at [from].
  ///
  /// Empty once cancelled, and never containing [from] itself — so a confirmed
  /// interview offers only "another time", and one already asking offers only
  /// "confirm".
  static List<String> responsesFor(String from) => [
    for (final to in candidateResponses)
      if (canRespond(from, to)) to,
  ];
}

/// §8.3's three interview types.
///
/// The type decides which detail exists at all, and the server refuses the
/// others: `inPerson` requires a location and forbids a link, `externalLink`
/// the reverse, and `phone` permits neither — the number is the candidate's
/// own, already verified on their profile (BR-01), so asking an employer to
/// retype it would be a second copy of a verified value.
abstract final class InterviewType {
  static const phone = 'phone';
  static const inPerson = 'in_person';
  static const externalLink = 'external_link';

  static const List<String> all = [phone, inPerson, externalLink];
}
