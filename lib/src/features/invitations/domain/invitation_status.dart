/// §8.2's invitation statuses and the transitions the candidate may make.
///
/// Plain `String` codes rather than an enum, the same rule as
/// `ApplicationStage`: an unrecognised status from a newer server is carried
/// and displayed rather than crashing the list.
///
/// The machine is small because §8.2 is small — an invitation is `sent`, and
/// then the candidate may Accept, Decline or Request details. Three things are
/// worth stating rather than left to be read off the list, and all three mirror
/// the server's own `invitation-status.ts`:
///
/// - **Every transition is the candidate's.** There is no column for who may
///   set what, because there is only one answer. The employer creates and then
///   waits.
/// - **`detailsRequested` is not an ending.** It is a question; the candidate
///   may still accept or decline afterwards. What they may not do is ask twice,
///   which is what [canRespond]'s `to != from` refuses.
/// - **There is no `withdrawn` and no `expired`.** Neither is in the
///   specification, so neither is here — a status nothing can set is a state
///   every reader has to consider for nothing.
abstract final class InvitationStatus {
  static const sent = 'sent';
  static const detailsRequested = 'details_requested';
  static const accepted = 'accepted';
  static const declined = 'declined';

  /// Answered. Nothing can change an invitation once it is here.
  static const Set<String> terminal = {accepted, declined};

  /// §8.2's three actions, in the order the candidate is offered them.
  static const List<String> candidateResponses = [
    accepted,
    declined,
    detailsRequested,
  ];

  /// May the candidate move an invitation from [from] to [to]?
  ///
  /// `to != from` is what refuses a second "request details" — and,
  /// incidentally, accepting something already accepted, which a retrying
  /// client would otherwise turn into a second history row.
  ///
  /// An unrecognised [from] yields false rather than throwing: a server that
  /// adds a fifth status should grey the controls, not crash the screen.
  static bool canRespond(String from, String to) =>
      !terminal.contains(from) && candidateResponses.contains(to) && to != from;

  /// The responses worth offering on an invitation currently at [from].
  ///
  /// Empty once answered, and never containing [from] itself.
  static List<String> responsesFor(String from) => [
    for (final to in candidateResponses)
      if (canRespond(from, to)) to,
  ];
}
