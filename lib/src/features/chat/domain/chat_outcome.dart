import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';

/// What came back from `POST /conversations` (§9.1).
///
/// Sealed for the same reason `InviteOutcome` is: the refusal changes what the
/// screen *offers* rather than merely what it says. Everything else — a 404, a
/// transport failure — throws `ApiException`.
sealed class OpenOutcome {
  const OpenOutcome();
}

/// The thread exists. Idempotent: there is only ever one between two people, so
/// this is equally "created" and "the one that was already there".
class ConversationOpened extends OpenOutcome {
  const ConversationOpened(this.conversation);

  final Conversation conversation;
}

/// 403 `chat.no_interaction` — nothing permits this conversation (§9.1).
///
/// **The client holds no copy of the gate**, deliberately, and this class is
/// how that is possible: §9.1's rule is whatever `HiringInteractionService`
/// answers, and the client asks rather than predicts. Two reasons, and the
/// second is the load-bearing one:
///
/// 1. The rule is a moving target in the specification. §9.1 as revised on
///    2026-08-10 reads that employer-initiated chat is enabled only once the
///    employer holds a Candidate Unlock; the server treats a live application
///    as sufficient, exactly as it treats one for BR-09's contact exposure. The
///    client answered that same question in the lenient direction on
///    2026-08-19 for contact, and gating chat harder than the API would tell an
///    employer to pay for something the server would have given them.
/// 2. A gate the client re-derives is a gate that can disagree with the one
///    that matters. The message here is the **server's own localized
///    sentence**, so there is exactly one wording of the refusal.
class ChatNotPermitted extends OpenOutcome {
  const ChatNotPermitted(this.message);

  /// The server's sentence, localized by `x-lang`. Rendered directly.
  final String message;
}

/// What came back from `POST /conversations/:id/messages` (§9.1).
///
/// Both refusals are outcomes rather than errors because both **remove the
/// composer**: after either, the thread is history and an input the user can
/// type into would be a lie. They are told apart by status — 403 for a block,
/// 409 for read-only — and they need different sentences, since one is undone
/// by unblocking and the other by the hiring interaction resuming.
sealed class SendOutcome {
  const SendOutcome();
}

/// The message is on the thread.
class MessageSent extends SendOutcome {
  const MessageSent(this.message);

  final ChatMessage message;
}

/// 409 `chat.read_only` — the hiring interaction ended while the screen was
/// open (§9.1). The thread stays readable.
class SendRefusedReadOnly extends SendOutcome {
  const SendRefusedReadOnly(this.message);

  final String message;
}

/// 403 `chat.blocked` — somebody blocked, and a block is read-only for **both**
/// sides whoever set it (§9.1). A block that let the blocker keep writing would
/// be a mute.
class SendRefusedBlocked extends SendOutcome {
  const SendRefusedBlocked(this.message);

  final String message;
}
