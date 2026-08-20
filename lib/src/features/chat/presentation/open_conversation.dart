import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';

/// Opens the thread with somebody, or finds the one that exists (§9.1).
///
/// Returns the conversation id, or **null** when there is nothing to open —
/// either because §9.1 does not permit it or because the request failed. Both
/// have already been reported to the user by the time this returns, in the
/// server's own words.
///
/// ## It does not navigate, deliberately
///
/// The caller does. §7.3's candidate profile is pushed on the **root
/// navigator** — every open is a logged access to protected data (§11.1), so it
/// has no route — which means reaching the Messages tab from it is a
/// `popUntil` and then a `go`, while a caller already inside a shell branch
/// just goes. That is knowledge the caller has and this function would have to
/// be told, so it stays with the caller.
///
/// ## The refusal is the server's sentence, not a guess
///
/// §9.1's gate is `HiringInteractionService` — the same service that answers
/// BR-09 — and the client keeps no copy of it. Where a caller offers this
/// action only in places contact is already open, that is a choice about
/// **placement**: it puts the control where it will work rather than where it
/// would mostly fail. The authority is still the 403, which is why
/// [ChatNotPermitted] carries a message and not a code the client would have to
/// map to prose.
Future<String?> openConversationWith(
  BuildContext context,
  WidgetRef ref, {
  required String counterpartUserId,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final repository = await ref.read(chatRepositoryProvider.future);
    final outcome = await repository.open(counterpartUserId);

    switch (outcome) {
      case ConversationOpened(:final conversation):
        // A thread that did not exist a moment ago belongs on the list, and one
        // that did may have moved to the top of it.
        ref.invalidate(conversationsProvider);
        return conversation.id;

      case ChatNotPermitted(:final message):
        messenger.showSnackBar(SnackBar(content: Text(message)));
        return null;
    }
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  }
}
