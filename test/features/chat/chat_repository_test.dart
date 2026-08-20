import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers each request from a queue, and keeps every request it saw.
///
/// A queue rather than one canned reply, because the interesting properties of
/// §12.4 are about the *second* request: whether it carries the key the first
/// attempt minted.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.replies);

  /// `(statusCode, body)` per call, in order. The last one repeats.
  final List<(int, String)> replies;

  final requests = <RequestOptions>[];

  int _index = 0;

  String? keyOf(int call) =>
      requests[call].headers[IdempotencyInterceptor.headerName] as String?;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = replies[_index.clamp(0, replies.length - 1)];
    _index++;

    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _messageBody = '''
{
  "id": "msg-1",
  "conversationId": "conv-1",
  "senderUserId": "me",
  "body": "Salom",
  "fileId": null,
  "fileName": null,
  "downloadPath": null,
  "isReadByRecipient": false,
  "createdAt": "2026-08-20T14:05:00+05:00"
}
''';

const _conversationBody = '''
{
  "id": "conv-1",
  "employerUserId": "emp-1",
  "candidateUserId": "cand-1",
  "counterpartUserId": "cand-1",
  "counterpartName": "Anvar",
  "lastMessageAt": "2026-08-20T14:05:00+05:00",
  "lastMessageBody": "Salom",
  "unreadCount": 2,
  "canSend": true,
  "isBlocked": false,
  "blockedByMe": false
}
''';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<({ChatRepository repo, _Adapter adapter})> build(
    List<(int, String)> replies,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3001'));
    // The real path: the key is minted and persisted by the repository and put
    // on the wire by the interceptor. Installing it here is what makes the
    // `extra` slot the repository writes the same one production reads.
    dio.interceptors.add(const IdempotencyInterceptor());
    final adapter = _Adapter(replies);
    dio.httpClientAdapter = adapter;

    return (
      repo: ChatRepository(dio, await SharedPreferences.getInstance()),
      adapter: adapter,
    );
  }

  group('§12.4: the idempotency key is scoped to the draft', () {
    test('the same text retried carries the first attempt’s key', () async {
      // The first attempt dies; the second is the retry §12.4 exists for.
      final (:repo, :adapter) = await build([
        (500, '{}'),
        (200, _messageBody),
      ]);

      await expectLater(
        repo.send('conv-1', body: 'Salom'),
        throwsA(isA<ApiException>()),
      );
      await repo.send('conv-1', body: 'Salom');

      expect(adapter.requests, hasLength(2));
      expect(adapter.keyOf(0), isNotNull);
      expect(adapter.keyOf(1), adapter.keyOf(0));
    });

    test('different text after a failure mints a new key', () async {
      // The case a key held per *conversation* would break: the stale key
      // belongs to a body the server never accepted, and reusing it earns
      // `idempotency.key_reused` — refusing a message forever over an error the
      // user cannot see. Mutation check: keying on the conversation alone makes
      // this expectation fail.
      final (:repo, :adapter) = await build([
        (500, '{}'),
        (200, _messageBody),
      ]);

      await expectLater(
        repo.send('conv-1', body: 'Salom'),
        throwsA(isA<ApiException>()),
      );
      await repo.send('conv-1', body: 'Boshqa gap');

      expect(adapter.keyOf(1), isNot(adapter.keyOf(0)));
    });

    test('an attachment is part of the draft, not just the text', () async {
      final (:repo, :adapter) = await build([
        (500, '{}'),
        (200, _messageBody),
      ]);

      await expectLater(
        repo.send('conv-1', body: 'Salom'),
        throwsA(isA<ApiException>()),
      );
      await repo.send('conv-1', body: 'Salom', fileId: 'file-1');

      expect(adapter.keyOf(1), isNot(adapter.keyOf(0)));
    });

    test('a delivered message frees the slot, so the same text sends twice',
        () async {
      // Deliberate: a retry is only a retry when the first attempt was never
      // confirmed. Somebody who types "ok" twice means two messages, and a key
      // that survived success would swallow the second.
      final (:repo, :adapter) = await build([(200, _messageBody)]);

      await repo.send('conv-1', body: 'ok');
      await repo.send('conv-1', body: 'ok');

      expect(adapter.keyOf(1), isNot(adapter.keyOf(0)));
    });

    test('two conversations never share a key', () async {
      final (:repo, :adapter) = await build([
        (500, '{}'),
        (500, '{}'),
      ]);

      await expectLater(
        repo.send('conv-1', body: 'Salom'),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        repo.send('conv-2', body: 'Salom'),
        throwsA(isA<ApiException>()),
      );

      expect(adapter.keyOf(1), isNot(adapter.keyOf(0)));
    });
  });

  group('§9.1: the refusals that reshape the screen are outcomes', () {
    test('403 is a block', () async {
      final (:repo, adapter: _) = await build([
        (403, '{"code":"chat.blocked","message":"Suhbat bloklangan."}'),
      ]);

      final outcome = await repo.send('conv-1', body: 'Salom');

      expect(outcome, isA<SendRefusedBlocked>());
      expect(
        (outcome as SendRefusedBlocked).message,
        'Suhbat bloklangan.',
        reason: 'the server’s own localized sentence, never rebuilt in Dart',
      );
    });

    test('409 chat.read_only is history, not a failure', () async {
      final (:repo, adapter: _) = await build([
        (409, '{"code":"chat.read_only","message":"Suhbat tugagan."}'),
      ]);

      expect(
        await repo.send('conv-1', body: 'Salom'),
        isA<SendRefusedReadOnly>(),
      );
    });

    test('a 409 that is NOT read-only still throws', () async {
      // Read by `code`, never by status. `idempotency.key_reused` is a 409
      // and a client bug: rendering it as read-only would take the composer
      // away and leave nobody able to find out why. Mutation check: matching
      // on 409 alone makes this expectation fail.
      final (:repo, adapter: _) = await build([
        (
          409,
          '{"code":"idempotency.key_reused",'
          '"message":"Kalit qayta ishlatildi."}',
        ),
      ]);

      await expectLater(
        repo.send('conv-1', body: 'Salom'),
        throwsA(isA<ApiException>()),
      );
    });

    test('open answers 403 chat.no_interaction as a refusal to render',
        () async {
      final (:repo, adapter: _) = await build([
        (
          403,
          '{"code":"chat.no_interaction","message":"Yozishmaga asos yo‘q."}',
        ),
      ]);

      final outcome = await repo.open('cand-1');

      expect(outcome, isA<ChatNotPermitted>());
      expect((outcome as ChatNotPermitted).message, 'Yozishmaga asos yo‘q.');
    });

    test('open returns the thread the server already had', () async {
      final (:repo, adapter: _) = await build([(200, _conversationBody)]);

      final outcome = await repo.open('cand-1');

      expect(outcome, isA<ConversationOpened>());
      expect((outcome as ConversationOpened).conversation.id, 'conv-1');
    });
  });

  group('the paging cursor is an instant, not a wall clock', () {
    test('before is sent as UTC', () async {
      final (:repo, :adapter) = await build([(200, '{"items":[]}')]);

      // 14:05 in Tashkent is 09:05Z. Sending the wall clock would ask for
      // messages five hours further back than the reader can see — the same
      // class of bug `ZonedTimestamp` exists to prevent, reached from the other
      // direction.
      final message = ChatMessage.fromJson(
        const {
          'id': 'm',
          'conversationId': 'conv-1',
          'senderUserId': 'me',
          'isReadByRecipient': false,
          'createdAt': '2026-08-20T14:05:00+05:00',
        },
      );

      await repo.messages(
        'conv-1',
        limit: 50,
        before: message.createdAt.instant,
      );

      expect(
        adapter.requests.single.queryParameters['before'],
        '2026-08-20T09:05:00.000Z',
      );
      expect(adapter.requests.single.queryParameters['limit'], 50);
    });
  });

  group('the domain', () {
    test('read-only and blocked are separate facts', () {
      Conversation at({required bool canSend, required bool isBlocked}) =>
          Conversation.fromJson({
            'id': 'c',
            'employerUserId': 'e',
            'candidateUserId': 'k',
            'counterpartUserId': 'k',
            'unreadCount': 0,
            'canSend': canSend,
            'isBlocked': isBlocked,
            'blockedByMe': false,
          });

      expect(at(canSend: true, isBlocked: false).isReadOnly, isFalse);
      // Blocked and ended both close the thread, and only one of them is
      // undone by unblocking — so the notice needs to tell them apart.
      expect(at(canSend: false, isBlocked: false).isEnded, isTrue);
      expect(at(canSend: false, isBlocked: true).isEnded, isFalse);
    });

    test('an attachment needs all three fields to be openable', () {
      ChatMessage withFile({String? fileName, String? downloadPath}) =>
          ChatMessage.fromJson({
            'id': 'm',
            'conversationId': 'c',
            'senderUserId': 's',
            'isReadByRecipient': false,
            'createdAt': '2026-08-20T14:05:00+05:00',
            'fileId': 'f',
            'fileName': fileName,
            'downloadPath': downloadPath,
          });

      expect(
        withFile(fileName: 'cv.pdf', downloadPath: '/x').hasAttachment,
        isTrue,
      );
      // A file id with no path cannot be fetched, so offering to open it would
      // be a control that fails on tap.
      expect(withFile(fileName: 'cv.pdf').hasAttachment, isFalse);
      expect(withFile(downloadPath: '/x').hasAttachment, isFalse);
    });

    test('a timestamp without an offset is refused at the boundary', () {
      expect(
        () => ChatMessage.fromJson(const {
          'id': 'm',
          'conversationId': 'c',
          'senderUserId': 's',
          'isReadByRecipient': false,
          'createdAt': '2026-08-20T14:05:00Z',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
