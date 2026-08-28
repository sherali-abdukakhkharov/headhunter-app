import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:jobbridge_app/src/features/chat/domain/message_attachment.dart';

/// A `ChatRepository` that answers from memory (§9.1).
///
/// Every route the screens do not use throws rather than returning something
/// plausible: a fake that quietly answers a call the screen should never make
/// hides exactly the bug worth catching.
class FakeChat implements ChatRepository {
  FakeChat({
    this.threads = const [],
    this.page = const [],
    this.sendOutcome,
  });

  List<Conversation> threads;

  /// Set to make the list fail, for the screen's error arm.
  Exception? listError;

  /// The first page the thread returns. Named `page` rather than `messages` so
  /// it cannot be confused with the route of the same name.
  List<ChatMessage> page;

  /// What the next send answers. Null means "the first message in [page]",
  /// which is the ordinary success.
  SendOutcome? sendOutcome;

  final sent = <(String id, String? body, String? fileId)>[];
  final uploads = <(String conversationId, String fileName)>[];

  /// What the next upload answers. Null is the ordinary success below.
  MessageAttachment? uploadResult;

  /// Set to make the next upload throw — a refusal, or a cancel.
  Exception? uploadError;
  final marked = <String>[];
  final blocked = <(String id, String? reason)>[];
  final unblocked = <String>[];
  final reports = <(String conversationId, String messageId, String reason)>[];
  final pageRequests = <(String id, DateTime? before)>[];

  @override
  Future<MessageAttachment> uploadAttachment(
    String conversationId, {
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    uploads.add((conversationId, fileName));

    // Reported before the throw as well as before the success: a composer that
    // leaves a progress bar at zero after a failure looks stuck rather than
    // failed, and that is a state worth being able to reproduce.
    onProgress?.call(1, 1);

    final error = uploadError;
    if (error != null) throw error;

    return uploadResult ??
        MessageAttachment(
          fileId: 'file-${uploads.length}',
          fileName: fileName,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
        );
  }

  @override
  Future<List<Conversation>> list() async {
    final error = listError;
    if (error != null) throw error;

    return threads;
  }

  @override
  Future<Conversation> byId(String id) async =>
      threads.firstWhere((c) => c.id == id);

  @override
  Future<List<ChatMessage>> messages(
    String id, {
    int? limit,
    DateTime? before,
  }) async {
    pageRequests.add((id, before));
    return before == null ? page : const [];
  }

  @override
  Future<SendOutcome> send(
    String conversationId, {
    String? body,
    String? fileId,
  }) async {
    sent.add((conversationId, body, fileId));
    return sendOutcome ?? MessageSent(page.first);
  }

  @override
  Future<void> markRead(String id) async => marked.add(id);

  @override
  Future<void> block(String id, {String? reason}) async =>
      blocked.add((id, reason));

  @override
  Future<void> unblock(String id) async => unblocked.add(id);

  @override
  Future<String> report(
    String conversationId,
    String messageId, {
    required String reason,
  }) async {
    reports.add((conversationId, messageId, reason));
    return 'complaint-1';
  }

  @override
  Future<OpenOutcome> open(String counterpartUserId) =>
      throw UnsupportedError('these screens list threads; none opens one');
}

/// A conversation fixture. Defaults to a live thread with nothing unread.
Conversation conversationFixture({
  String id = 'conv-1',
  String? counterpartName = 'Anvar Qodirov',
  String counterpartUserId = 'them',
  int unreadCount = 0,
  bool canSend = true,
  bool isBlocked = false,
  bool blockedByMe = false,
  String? lastMessageAt = '2026-08-20T14:05:00+05:00',
  String? lastMessageBody = 'Salom, vakansiya haqida',
}) => Conversation.fromJson({
  'id': id,
  'employerUserId': 'emp-1',
  'candidateUserId': 'cand-1',
  'counterpartUserId': counterpartUserId,
  'counterpartName': counterpartName,
  'unreadCount': unreadCount,
  'canSend': canSend,
  'isBlocked': isBlocked,
  'blockedByMe': blockedByMe,
  'lastMessageAt': lastMessageAt,
  'lastMessageBody': lastMessageBody,
});

/// A message fixture. `senderUserId` decides which side of the thread it lands
/// on: anything other than the conversation's `counterpartUserId` is the
/// caller's own.
ChatMessage messageFixture({
  required String id,
  String senderUserId = 'me',
  String? body = 'Salom',
  bool isReadByRecipient = false,
  String createdAt = '2026-08-20T14:05:00+05:00',
  String? fileId,
  String? fileName,
  String? downloadPath,
}) => ChatMessage.fromJson({
  'id': id,
  'conversationId': 'conv-1',
  'senderUserId': senderUserId,
  'body': body,
  'fileId': fileId,
  'fileName': fileName,
  'downloadPath': downloadPath,
  'isReadByRecipient': isReadByRecipient,
  'createdAt': createdAt,
});
