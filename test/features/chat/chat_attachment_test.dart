import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/upload_cancelled.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';
import 'package:jobbridge_app/src/features/chat/presentation/conversation_thread_screen.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chat_fake.dart';

/// §9.1's "approved attachments", the sending half (2026-08-26).
///
/// Receiving one has worked since M8. Sending was blocked on a server route,
/// and what these pin is the composer's half of it: an upload is a separate
/// wait from a send, an attachment is enough to send with no text at all, and
/// removing one takes it out of the draft rather than deleting anything.
///
/// `FilePicker.platform` is settable, so the whole path runs headlessly — pick,
/// upload, hold, send. Without that these would have to poke at private state
/// and would stop being a test of the screen.
void main() {
  late _FakePicker picker;

  setUp(() {
    picker = _FakePicker();
    FilePicker.platform = picker;
  });

  Future<FakeChat> pump(
    WidgetTester tester, {
    SendOutcome? sendOutcome,
    MessageAttachmentError? uploadError,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final conversation = conversationFixture();
    final fake = FakeChat(
      threads: [conversation],
      // What a successful send echoes back. `FakeChat` answers with the first
      // of these unless `sendOutcome` overrides it.
      page: [messageFixture(id: 'echo', body: null, fileName: 'offer.pdf')],
      sendOutcome: sendOutcome,
    )..uploadError = uploadError?.error;

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [chatRepositoryProvider.overrideWith((ref) => fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: ConversationThreadScreen(conversationId: conversation.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return fake;
  }

  Future<void> attach(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Attach a file'));
    await tester.pumpAndSettle();
  }

  final send = find.widgetWithText(HhButton, 'Send');

  bool enabled(WidgetTester tester) =>
      tester.widget<HhButton>(send).onPressed != null;

  group('picking a file uploads it', () {
    testWidgets('and the composer says it is ready to send', (tester) async {
      final fake = await pump(tester);

      await attach(tester);

      expect(fake.uploads, [('conv-1', 'offer.pdf')]);
      // "Ready to send", not "attached": nothing is attached to anything until
      // a message carries it.
      expect(find.text('Ready to send: offer.pdf'), findsOneWidget);
    });

    testWidgets('the picker is asked for the types the server accepts', (
      tester,
    ) async {
      await pump(tester);
      await attach(tester);

      // The client's list decides what the picker *offers*; the server decides
      // what is allowed. They are kept the same so a pick does not usually end
      // in a refusal.
      expect(picker.allowedExtensions, ChatRepository.attachmentExtensions);
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      final fake = await pump(tester);
      picker.result = null;

      await attach(tester);

      expect(fake.uploads, isEmpty);
      expect(find.textContaining('Ready to send'), findsNothing);
    });
  });

  group('an attachment is enough to send', () {
    testWidgets('Send is inert with neither text nor a file', (tester) async {
      await pump(tester);

      expect(enabled(tester), isFalse);
    });

    testWidgets('Send is enabled by the attachment alone', (tester) async {
      await pump(tester);
      await attach(tester);

      // A file with no covering note is a real message, and §9.1 does not ask
      // for text beside it.
      expect(enabled(tester), isTrue);
    });

    testWidgets('sending carries the fileId and no empty body', (tester) async {
      final fake = await pump(tester);
      await attach(tester);

      await tester.tap(send);
      await tester.pumpAndSettle();

      // Null rather than '': an empty string would be a blank line above the
      // attachment, and the server takes either field on its own.
      expect(fake.sent, [('conv-1', null, 'file-1')]);
    });

    testWidgets('text and a file travel together', (tester) async {
      final fake = await pump(tester);

      await tester.enterText(find.byType(TextField), 'The offer, attached.');
      await attach(tester);
      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(fake.sent, [('conv-1', 'The offer, attached.', 'file-1')]);
    });

    testWidgets('a sent attachment leaves the composer', (tester) async {
      await pump(tester);
      await attach(tester);

      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(find.textContaining('Ready to send'), findsNothing);
      expect(enabled(tester), isFalse);
    });
  });

  group('removing one takes it out of the draft', () {
    testWidgets('and nothing is deleted, because nothing was attached', (
      tester,
    ) async {
      final fake = await pump(tester);
      await attach(tester);

      await tester.tap(find.byTooltip('Remove the attachment'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ready to send'), findsNothing);
      expect(enabled(tester), isFalse);
      // The composer forgot it and the server was never told: there is no
      // "detach", because nothing was attached. The row is not immortal either
      // — the server expires an upload that never became a message after seven
      // days (MT-023), which is why no call belongs here.
      expect(fake.sent, isEmpty);
    });

    testWidgets('typed text survives removing the file', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'Still here');
      await attach(tester);
      await tester.tap(find.byTooltip('Remove the attachment'));
      await tester.pumpAndSettle();

      expect(find.text('Still here'), findsOneWidget);
      expect(enabled(tester), isTrue);
    });
  });

  group('when the upload does not land', () {
    testWidgets('a refusal is shown and nothing is held', (tester) async {
      await pump(
        tester,
        uploadError: const MessageAttachmentError(
          ApiException('That file type is not accepted.'),
        ),
      );

      await attach(tester);

      expect(find.text('That file type is not accepted.'), findsOneWidget);
      expect(find.textContaining('Ready to send'), findsNothing);
      expect(enabled(tester), isFalse);
    });

    testWidgets('a cancel says nothing at all', (tester) async {
      // Pressing Cancel and then reading "the request failed" reads as the
      // cancel itself having broken.
      await pump(
        tester,
        uploadError: const MessageAttachmentError(UploadCancelled()),
      );

      await attach(tester);

      expect(find.byType(HhNotice), findsNothing);
      expect(find.textContaining('Ready to send'), findsNothing);
    });

    testWidgets('a refused send keeps the attachment', (tester) async {
      // The same rule the typed draft has: somebody whose thread closed under
      // them should not pay for the bytes twice.
      final fake = await pump(
        tester,
        sendOutcome: const SendRefusedReadOnly('This conversation is history.'),
      );
      await attach(tester);

      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(fake.sent, [('conv-1', null, 'file-1')]);
      expect(find.text('Ready to send: offer.pdf'), findsOneWidget);
    });
  });

  group('the attach control is reachable', () {
    testWidgets('it has a name, not just a glyph', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);

      // An icon-only control with no accessible name announces as "button"
      // (MT-015). A tooltip is not a name.
      expect(find.bySemanticsLabel('Attach a file'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('a second file cannot be queued over the first', (
      tester,
    ) async {
      // §9.1 is one file per message. Offering the control again would either
      // silently replace the first or imply two can go, and both are worse than
      // asking somebody to remove one.
      final fake = await pump(tester);
      await attach(tester);

      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.bySemanticsLabel('Attach a file'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(fake.uploads, hasLength(1));
    });
  });
}

/// Wraps the error a fake upload should throw, so a null default reads as
/// "succeed" rather than as "no opinion".
class MessageAttachmentError {
  const MessageAttachmentError(this.error);

  final Exception error;
}

/// A picker that answers with one file and records what it was asked for.
class _FakePicker extends FilePicker with MockPlatformInterfaceMixin {
  List<String>? allowedExtensions;

  /// What the next pick returns. Null is the user backing out.
  FilePickerResult? result = FilePickerResult([
    PlatformFile(name: 'offer.pdf', size: 1024, path: '/tmp/offer.pdf'),
  ]);

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    this.allowedExtensions = allowedExtensions;

    return result;
  }
}
