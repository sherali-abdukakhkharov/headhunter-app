import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:jobbridge_app/src/core/network/upload_cancelled.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:jobbridge_app/src/features/chat/domain/message_attachment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'chat_repository.g.dart';

/// Gated chat, both sides of it (§9.1).
///
/// One repository, as the server has one controller: §9.1's asymmetry is *when*
/// each side may send, not which resource they are talking about, and the
/// server answers that per request. There is no employer half and candidate
/// half to keep in step.
///
/// ## Nothing here decides who may chat
///
/// Every route is called and the refusal rendered. §9.1's gate is
/// `HiringInteractionService` on the server — the same service that answers
/// BR-09 — so an employer who may read a phone number and one who may send a
/// message are the same employer by construction. A second copy of the rule in
/// Dart would be a second answer, and the one that would be wrong is the one
/// nobody can see failing.
class ChatRepository {
  const ChatRepository(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _keyPrefix = 'chat.idempotency.';

  /// `POST /conversations` — open the thread with somebody, or return the one
  /// that already exists (§9.1).
  ///
  /// Idempotent on the server by a unique constraint on the pair, so no key is
  /// needed: "message this candidate" is a button somebody taps twice, and a
  /// replay is answered by the existing thread rather than by a second one.
  Future<OpenOutcome> open(String counterpartUserId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/conversations',
        data: {'counterpartUserId': counterpartUserId},
      );

      return ConversationOpened(_one(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return ChatNotPermitted(ApiException.fromDioException(e).message);
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /conversations` — the caller's threads, most recently active first.
  ///
  /// The server's order is kept. Sorting here would need `lastMessageAt`, which
  /// is null on a thread opened and never used, and any tie-break invented in
  /// Dart would reorder rows under a finger between two refreshes.
  Future<List<Conversation>> list() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/conversations');

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) Conversation.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /conversations/:id` — one thread's header, including whether it still
  /// accepts messages.
  Future<Conversation> byId(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/conversations/$id',
      );

      return _one(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /conversations/:id/messages` — a page of the thread, **newest
  /// first**.
  ///
  /// Readable whether or not sending is: §9.1 keeps closed and blocked
  /// interactions in history, and a moderator reviewing a report needs them.
  /// [before] is the cursor for scrolling back — the `createdAt` instant of the
  /// oldest message already held.
  Future<List<ChatMessage>> messages(
    String id, {
    int? limit,
    DateTime? before,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/conversations/$id/messages',
        queryParameters: {
          'limit': ?limit,
          // The true instant in UTC, never the wall clock: this is a cursor and
          // not a display value, and `ZonedTimestamp` keeps the two apart
          // precisely so a paging request cannot be built out of the one that
          // was shifted for reading.
          'before': ?before?.toUtc().toIso8601String(),
        },
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) ChatMessage.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /conversations/:id/messages` — send (§9.1, §12.4).
  ///
  /// ## The idempotency key is scoped to the **draft**, not the conversation
  ///
  /// §12.4 requires a retry not to produce a second message, so the key is
  /// persisted before the request and cleared once the server has answered —
  /// the same discipline as an invitation's. What is different here is what the
  /// key belongs to.
  ///
  /// A key held per conversation would be worse than no key at all. The server
  /// answers the same key with a **different body** with 409
  /// `idempotency.key_reused`, deliberately: two different operations under one
  /// key means the client's key generation is broken, and saying so beats
  /// guessing. So a send that died with the request in flight would leave a key
  /// behind, and the next thing the user typed — a *different* message — would
  /// be refused by that stale key, permanently, naming nothing they did.
  ///
  /// So the slot holds the draft beside its key: the same text retried reuses
  /// the key and the server replays the original message, and different text
  /// mints a new one. One slot per conversation, overwritten rather than
  /// accumulated, so an abandoned draft leaks nothing.
  /// The file types the picker offers for a message attachment.
  ///
  /// Mirrors the server's accepted list, and **the server is the authority**:
  /// this decides what the picker shows, not what is allowed. A file that gets
  /// past it is refused on upload with a message the server has already
  /// translated, which is the failure worth having — the alternative is a
  /// picker that offers everything and an upload that usually fails.
  static const attachmentExtensions = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  /// `POST /conversations/:id/attachments` — store a file to send here (§9.1).
  ///
  /// **Two calls, not a multipart send.** The send route takes a `fileId` the
  /// caller owns, so a refused or failed send costs the typed message and not
  /// the upload as well — and an upload with a progress bar and a send without
  /// one are two different things to show.
  ///
  /// No idempotency key. A replayed upload stores a second file rather than
  /// a second *message*, which costs bytes and nothing else; the key that
  /// matters is on the send, where a replay would be a duplicate somebody
  /// reads.
  Future<MessageAttachment> uploadAttachment(
    String conversationId, {
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final form = FormData.fromMap({
        // No purpose field: every file this route takes is a message
        // attachment. Naming one would let a caller mint a profile document
        // through the chat gate, so the server does not accept it.
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/conversations/$conversationId/attachments',
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      );

      return MessageAttachment.fromJson(_body(response.data));
    } on DioException catch (e) {
      // A cancel is a thing the user did, not a thing that went wrong.
      if (CancelToken.isCancel(e)) throw const UploadCancelled();
      throw ApiException.fromDioException(e);
    }
  }

  Future<SendOutcome> send(
    String conversationId, {
    String? body,
    String? fileId,
  }) async {
    assert(
      (body != null && body.isNotEmpty) || fileId != null,
      'A message needs text or an attachment. The server would store a row '
      'with neither, which is a message nobody can read.',
    );

    final key = await _keyFor(conversationId, body: body, fileId: fileId);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/conversations/$conversationId/messages',
        data: {'body': ?body, 'fileId': ?fileId},
        options: Options(extra: {IdempotencyInterceptor.keyExtra: key}),
      );

      final message = ChatMessage.fromJson(_body(response.data));
      await _prefs.remove('$_keyPrefix$conversationId');
      return MessageSent(message);
    } on DioException catch (e) {
      final message = ApiException.fromDioException(e).message;

      // Both refusals keep the key in place, deliberately: the thread can
      // reopen — a block gets lifted, an interaction resumes — and the same
      // draft sent afterwards is still the same operation.
      return switch (e.response?.statusCode) {
        403 => SendRefusedBlocked(message),
        409 when _isReadOnly(e) => SendRefusedReadOnly(message),
        _ => throw ApiException.fromDioException(e),
      };
    }
  }

  /// The key for this exact draft, minting and persisting one when the slot
  /// holds a different draft or nothing.
  ///
  /// Stored as a three-element list rather than a delimited string: a body is
  /// four thousand characters of whatever somebody typed, and any delimiter
  /// that could be chosen is one they could type.
  Future<String> _keyFor(
    String conversationId, {
    String? body,
    String? fileId,
  }) async {
    final slot = '$_keyPrefix$conversationId';
    final stored = _prefs.getStringList(slot);

    if (stored != null &&
        stored.length == 3 &&
        stored[1] == (fileId ?? '') &&
        stored[2] == (body ?? '')) {
      return stored[0];
    }

    final key = const Uuid().v4();
    await _prefs.setStringList(slot, [key, fileId ?? '', body ?? '']);
    return key;
  }

  /// Whether a 409 is §9.1's read-only refusal rather than something else that
  /// shares the status.
  ///
  /// Read by `code`, not by status: `idempotency.key_reused` and
  /// `idempotency.in_progress` are 409s too, and neither means the thread has
  /// become history. Rendering those as read-only would take the composer away
  /// over a client bug and leave nobody able to discover it.
  bool _isReadOnly(DioException e) {
    final data = e.response?.data;
    return data is Map && data['code'] == 'chat.read_only';
  }

  /// `PUT /conversations/:id/read` — mark everything up to now as read (§9.1).
  ///
  /// One timestamp per participant on the server, so it is idempotent and cheap
  /// enough to call on every open.
  Future<void> markRead(String id) async {
    try {
      await _dio.put<void>('/conversations/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /conversations/:id/block` — block, with an optional reason for the
  /// moderator who reviews it (§9.1).
  Future<void> block(String id, {String? reason}) async {
    try {
      await _dio.post<void>(
        '/conversations/$id/block',
        data: {'reason': ?reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `DELETE /conversations/:id/block` — remove the caller's **own** block.
  ///
  /// It cannot lift the other side's, which is why the screen offers it only
  /// where `blockedByMe`.
  Future<void> unblock(String id) async {
    try {
      await _dio.delete<void>('/conversations/$id/block');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /conversations/:id/messages/:messageId/report` — file a complaint
  /// about one message (§9.1).
  ///
  /// Lands in the same queue M10 reviews vacancy reports through, with
  /// `target_type = "message"`. [reason] is free text and required: somebody
  /// reporting a message should not have to find their objection on a list.
  ///
  /// A second report of the same message by the same person answers 409
  /// `complaint.already_reported`, which is left to throw — it is a fact worth
  /// telling the reporter in the server's own words, and it changes nothing
  /// about the screen.
  Future<String> report(
    String conversationId,
    String messageId, {
    required String reason,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/conversations/$conversationId/messages/$messageId/report',
        data: {'reason': reason},
      );

      final id = response.data?['id'];
      if (id is! String) {
        throw const ApiException('The server returned an empty response.');
      }
      return id;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Conversation _one(Map<String, dynamic>? data) =>
      Conversation.fromJson(_body(data));

  Map<String, dynamic> _body(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('The server returned an empty response.');
    }
    return data;
  }
}

@riverpod
Future<ChatRepository> chatRepository(Ref ref) async => ChatRepository(
  ref.watch(dioProvider),
  await ref.watch(sharedPreferencesProvider.future),
);

/// The caller's conversations (§9.1). One list for whichever role is active —
/// the server scopes it.
@riverpod
Future<List<Conversation>> conversations(Ref ref) async =>
    (await ref.watch(chatRepositoryProvider.future)).list();

/// One thread's header, watched separately from its messages.
///
/// Two providers rather than one, because they invalidate for different
/// reasons: sending appends a message and changes nothing in the header, while
/// blocking changes the header and appends nothing. A single provider would
/// re-fetch both on either, and the visible cost is the thread jumping back to
/// the bottom every time somebody blocks.
@riverpod
Future<Conversation> conversation(Ref ref, String id) async =>
    (await ref.watch(chatRepositoryProvider.future)).byId(id);
