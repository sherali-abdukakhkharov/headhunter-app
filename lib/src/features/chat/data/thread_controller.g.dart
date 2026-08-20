// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(ConversationThread)
final conversationThreadProvider = ConversationThreadFamily._();

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
final class ConversationThreadProvider
    extends $AsyncNotifierProvider<ConversationThread, Thread> {
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
  ConversationThreadProvider._({
    required ConversationThreadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationThreadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationThreadHash();

  @override
  String toString() {
    return r'conversationThreadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConversationThread create() => ConversationThread();

  @override
  bool operator ==(Object other) {
    return other is ConversationThreadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationThreadHash() =>
    r'46e1798cfbe525a62cdb4c6b69ccf6d17241f223';

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

final class ConversationThreadFamily extends $Family
    with
        $ClassFamilyOverride<
          ConversationThread,
          AsyncValue<Thread>,
          Thread,
          FutureOr<Thread>,
          String
        > {
  ConversationThreadFamily._()
    : super(
        retry: null,
        name: r'conversationThreadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  ConversationThreadProvider call(String conversationId) =>
      ConversationThreadProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'conversationThreadProvider';
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

abstract class _$ConversationThread extends $AsyncNotifier<Thread> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  FutureOr<Thread> build(String conversationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Thread>, Thread>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Thread>, Thread>,
              AsyncValue<Thread>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
