import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';

/// What came back from `POST /invitations` (§8.2).
///
/// Sealed for the same reason `UnlockResult` is: two of the server's refusals
/// change what the screen *offers* rather than merely what it says, so they are
/// outcomes to be rendered and not exceptions to be caught. Everything else —
/// 400 `shape_invalid`, 403 BR-03, 404, `vacancy_not_open` — throws
/// `ApiException` and is shown as the server's sentence, because none of those
/// change the shape of the screen.
sealed class InviteOutcome {
  const InviteOutcome();
}

/// The invitation exists. Free, and it opens no contact on its own — the
/// candidate's acceptance is what does that (§8.2, BR-09).
class InviteSent extends InviteOutcome {
  const InviteSent(this.invitation);

  final Invitation invitation;
}

/// 409 `invitation.daily_limit_reached` — today's cap is used up.
///
/// Not an error the employer did anything wrong to earn, so it is rendered as a
/// state with a time attached rather than as a failure. It carries the server's
/// own figures so the screen's counter can correct itself without a second
/// request, which matters because reaching the cap is exactly the moment the
/// counter on screen is most likely to be stale.
///
/// [limit] and [resetsAt] are nullable because a server that answers the code
/// without the structured fields must still be handled — the sentence in
/// [message] is the part that has to be there, and it is already localized.
class InviteQuotaReached extends InviteOutcome {
  const InviteQuotaReached(this.message, {this.limit, this.resetsAt});

  /// The server's own sentence, localized by `x-lang`. Rendered directly:
  /// rebuilding it in Dart is how two spellings of one refusal appear.
  final String message;

  final int? limit;
  final ZonedTimestamp? resetsAt;
}

/// 409 `invitation.already_invited` — an open invitation to this candidate for
/// this vacancy already exists.
///
/// A fact rather than a failure, and worth its own case because the useful
/// response is to show the employer the invitation they already sent instead of
/// asking them to try again. The server frees the slot once the candidate
/// answers, so this is genuinely "you are already waiting on them".
class InviteAlreadySent extends InviteOutcome {
  const InviteAlreadySent(this.message);

  final String message;
}
