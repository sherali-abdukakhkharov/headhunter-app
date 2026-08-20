// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatRepository>,
          ChatRepository,
          FutureOr<ChatRepository>
        >
    with $FutureModifier<ChatRepository>, $FutureProvider<ChatRepository> {
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChatRepository> create(Ref ref) {
    return chatRepository(ref);
  }
}

String _$chatRepositoryHash() => r'16048697798f0087453ceb2f5de06b9eef97a03f';

/// The caller's conversations (§9.1). One list for whichever role is active —
/// the server scopes it.

@ProviderFor(conversations)
final conversationsProvider = ConversationsProvider._();

/// The caller's conversations (§9.1). One list for whichever role is active —
/// the server scopes it.

final class ConversationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Conversation>>,
          List<Conversation>,
          FutureOr<List<Conversation>>
        >
    with
        $FutureModifier<List<Conversation>>,
        $FutureProvider<List<Conversation>> {
  /// The caller's conversations (§9.1). One list for whichever role is active —
  /// the server scopes it.
  ConversationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Conversation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Conversation>> create(Ref ref) {
    return conversations(ref);
  }
}

String _$conversationsHash() => r'633d0c1d6c4d6132cfdcb62a2a57079ff6646ec6';

/// One thread's header, watched separately from its messages.
///
/// Two providers rather than one, because they invalidate for different
/// reasons: sending appends a message and changes nothing in the header, while
/// blocking changes the header and appends nothing. A single provider would
/// re-fetch both on either, and the visible cost is the thread jumping back to
/// the bottom every time somebody blocks.

@ProviderFor(conversation)
final conversationProvider = ConversationFamily._();

/// One thread's header, watched separately from its messages.
///
/// Two providers rather than one, because they invalidate for different
/// reasons: sending appends a message and changes nothing in the header, while
/// blocking changes the header and appends nothing. A single provider would
/// re-fetch both on either, and the visible cost is the thread jumping back to
/// the bottom every time somebody blocks.

final class ConversationProvider
    extends
        $FunctionalProvider<
          AsyncValue<Conversation>,
          Conversation,
          FutureOr<Conversation>
        >
    with $FutureModifier<Conversation>, $FutureProvider<Conversation> {
  /// One thread's header, watched separately from its messages.
  ///
  /// Two providers rather than one, because they invalidate for different
  /// reasons: sending appends a message and changes nothing in the header, while
  /// blocking changes the header and appends nothing. A single provider would
  /// re-fetch both on either, and the visible cost is the thread jumping back to
  /// the bottom every time somebody blocks.
  ConversationProvider._({
    required ConversationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationHash();

  @override
  String toString() {
    return r'conversationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Conversation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Conversation> create(Ref ref) {
    final argument = this.argument as String;
    return conversation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationHash() => r'3f4e9c9fdf56973bbf272388002272d0f2c50cbf';

/// One thread's header, watched separately from its messages.
///
/// Two providers rather than one, because they invalidate for different
/// reasons: sending appends a message and changes nothing in the header, while
/// blocking changes the header and appends nothing. A single provider would
/// re-fetch both on either, and the visible cost is the thread jumping back to
/// the bottom every time somebody blocks.

final class ConversationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Conversation>, String> {
  ConversationFamily._()
    : super(
        retry: null,
        name: r'conversationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One thread's header, watched separately from its messages.
  ///
  /// Two providers rather than one, because they invalidate for different
  /// reasons: sending appends a message and changes nothing in the header, while
  /// blocking changes the header and appends nothing. A single provider would
  /// re-fetch both on either, and the visible cost is the thread jumping back to
  /// the bottom every time somebody blocks.

  ConversationProvider call(String id) =>
      ConversationProvider._(argument: id, from: this);

  @override
  String toString() => r'conversationProvider';
}
