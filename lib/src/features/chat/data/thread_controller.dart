import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thread_controller.g.dart';

/// One page-set of a thread: what has been loaded, and whether there is more.
///
/// [hasMore] is derived from the **page size**, not from a total the server
/// does not send: a page that came back full is evidence there may be another,
/// and a short one is proof there is not. The consequence to know is that a
/// thread whose length is an exact multiple of [ConversationThread.pageSize]
/// offers "earlier messages" once more and finds none — the harmless direction
/// of that error, and better than a count the API would have to grow a field
/// to provide.
@immutable
class Thread {
  const Thread({required this.messages, required this.hasMore});

  /// **Newest first**, exactly as the server orders them. Reversed at the point
  /// of rendering rather than here, because the cursor for the next page is the
  /// oldest message's instant and reversing the model would make that the first
  /// element in one place and the last in another.
  final List<ChatMessage> messages;

  final bool hasMore;

  ChatMessage? get oldest => messages.isEmpty ? null : messages.last;
}

/// A thread's messages, accumulated a page at a time (§9.1).
///
/// A notifier rather than a plain future provider because scrolling back adds
/// to what is on screen rather than replacing it, and because a successful send
/// has a message in hand already.
///
/// ## A sent message is prepended, not re-fetched
///
/// Re-fetching the first page after every send would work and would cost a
/// round trip per message on a connection that is often the reason somebody is
/// typing instead of calling. So [appendSent] puts the server's own returned
/// message at the head.
///
/// **De-duplicated by id**, which is not defensive: §12.4's replay means a
/// retried send returns the message the *first* attempt created, and that one
/// is already in the list. Without the id check a lost response would show the
/// message twice — the exact duplicate the idempotency key exists to prevent,
/// reintroduced in the widget layer.
@riverpod
class ConversationThread extends _$ConversationThread {
  /// Deliberately below the server's 100 maximum and equal to its default.
  /// Large enough that most threads arrive whole, small enough that a long one
  /// paints before it has all been read.
  static const pageSize = 50;

  @override
  Future<Thread> build(String conversationId) async {
    final repository = await ref.watch(chatRepositoryProvider.future);
    final messages = await repository.messages(
      conversationId,
      limit: pageSize,
    );

    return Thread(
      messages: messages,
      hasMore: messages.length >= pageSize,
    );
  }

  /// Fetches the page before the oldest message held (§9.1's `before` cursor).
  ///
  /// Silently does nothing while the first page is still loading or when there
  /// is nothing older: both are states a scroll listener can reach, and neither
  /// is worth an error the user has to dismiss.
  Future<void> loadEarlier() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;

    final cursor = current.oldest?.createdAt.instant;
    if (cursor == null) return;

    final repository = await ref.read(chatRepositoryProvider.future);
    final older = await repository.messages(
      conversationId,
      limit: pageSize,
      before: cursor,
    );

    state = AsyncData(
      Thread(
        messages: [...current.messages, ...older],
        hasMore: older.length >= pageSize,
      ),
    );
  }

  /// Puts a message the server just accepted at the head of the thread.
  void appendSent(ChatMessage message) {
    final current = state.value;
    if (current == null) return;
    if (current.messages.any((m) => m.id == message.id)) return;

    state = AsyncData(
      Thread(
        messages: [message, ...current.messages],
        hasMore: current.hasMore,
      ),
    );
  }
}
