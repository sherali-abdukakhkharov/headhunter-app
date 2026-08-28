import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_message.dart';
import 'package:jobbridge_app/src/features/chat/domain/chat_outcome.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:jobbridge_app/src/features/chat/presentation/conversation_thread_screen.dart';
import 'package:jobbridge_app/src/features/chat/presentation/message_bubble.dart';

import 'chat_fake.dart';

/// §9.1's thread.
void main() {
  Future<FakeChat> pump(
    WidgetTester tester, {
    required Conversation conversation,
    List<ChatMessage> page = const [],
    SendOutcome? sendOutcome,
    Size size = const Size(1080, 2400),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = FakeChat(
      threads: [conversation],
      page: page,
      sendOutcome: sendOutcome,
    );

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [chatRepositoryProvider.overrideWith((ref) => fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: ConversationThreadScreen(conversationId: conversation.id),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('which side a message sits on comes from the counterpart', () {
    testWidgets('the read receipt appears on outgoing messages only', (
      tester,
    ) async {
      // The app stores no user id, and does not need one: a conversation has
      // two participants and the server names the other, so "not them" is "me".
      // `isReadByRecipient` is true on both fixtures — the incoming one must
      // still show nothing, because there it answers whether *the reader* read
      // it, which they can see for themselves.
      await pump(
        tester,
        conversation: conversationFixture(),
        page: [
          messageFixture(id: 'a', isReadByRecipient: true),
          messageFixture(
            id: 'b',
            senderUserId: 'them',
            body: 'Assalomu alaykum',
            isReadByRecipient: true,
          ),
        ],
      );

      expect(find.byType(MessageBubble), findsNWidgets(2));
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Sent'), findsNothing);
    });

    testWidgets('an unread outgoing message says sent, not read', (
      tester,
    ) async {
      await pump(
        tester,
        conversation: conversationFixture(),
        page: [messageFixture(id: 'a')],
      );

      expect(find.text('Sent'), findsOneWidget);
      expect(find.text('Read'), findsNothing);
    });

    testWidgets('reporting is offered on incoming messages only', (
      tester,
    ) async {
      // Reporting your own message files a complaint about yourself, and §9.1's
      // queue is for the other kind.
      await pump(
        tester,
        conversation: conversationFixture(),
        page: [
          messageFixture(id: 'a'),
          messageFixture(id: 'b', senderUserId: 'them', body: 'Theirs'),
        ],
      );

      final bubbles = tester
          .widgetList<MessageBubble>(find.byType(MessageBubble))
          .toList();

      expect(bubbles.where((b) => b.mine).single.onReport, isNull);
      expect(bubbles.where((b) => !b.mine).single.onReport, isNotNull);
    });
  });

  group('§9.1: a closed thread has a notice where the composer was', () {
    testWidgets('an open thread has a composer and no notice', (tester) async {
      await pump(
        tester,
        conversation: conversationFixture(),
        page: [messageFixture(id: 'a')],
      );

      expect(find.byType(HhTextField), findsOneWidget);
      expect(find.text('This conversation is history'), findsNothing);
    });

    testWidgets('an ended interaction says so, and offers no input', (
      tester,
    ) async {
      // Never both: an input on a thread that cannot accept one is a control
      // that lies.
      await pump(
        tester,
        conversation: conversationFixture(canSend: false),
        page: [messageFixture(id: 'a')],
      );

      expect(find.byType(HhTextField), findsNothing);
      expect(find.text('This conversation is history'), findsOneWidget);
    });

    testWidgets('a block by the other side offers no unblock', (tester) async {
      // The route lifts the caller's own block and cannot touch theirs, so a
      // control here would look like it clears a condition it cannot.
      await pump(
        tester,
        conversation: conversationFixture(canSend: false, isBlocked: true),
        page: [messageFixture(id: 'a')],
      );

      expect(find.text('Unblock'), findsNothing);
      expect(
        find.textContaining('The other person blocked this conversation'),
        findsOneWidget,
      );
    });

    testWidgets('a block the reader set offers the way out', (tester) async {
      await pump(
        tester,
        conversation: conversationFixture(
          canSend: false,
          isBlocked: true,
          blockedByMe: true,
        ),
        page: [messageFixture(id: 'a')],
      );

      expect(find.text('Unblock'), findsOneWidget);
      // "Including you" is the part worth saying: somebody reaching for a block
      // is often reaching for a mute, and §9.1 does not have one.
      expect(find.textContaining('including you'), findsOneWidget);
    });

    testWidgets('an empty closed thread does not invite a first message', (
      tester,
    ) async {
      await pump(tester, conversation: conversationFixture(canSend: false));

      expect(
        find.textContaining('No messages were sent before'),
        findsOneWidget,
      );
      expect(find.textContaining('Write the first one'), findsNothing);
    });
  });

  group('sending', () {
    testWidgets('the button is inert until there is something to send', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        conversation: conversationFixture(),
        page: [messageFixture(id: 'a')],
      );

      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      expect(fake.sent, isEmpty);

      await tester.enterText(find.byType(TextField), 'Salom');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.sent, [('conv-1', 'Salom', null)]);
    });

    testWidgets('a refusal keeps the draft', (tester) async {
      // Somebody who wrote three paragraphs into a thread that closed under
      // them must be able to copy them out. Clearing the field would be the app
      // deleting their words to report its own failure.
      await pump(
        tester,
        conversation: conversationFixture(),
        page: [messageFixture(id: 'a')],
        sendOutcome: const SendRefusedReadOnly('Suhbat tugagan.'),
      );

      await tester.enterText(find.byType(TextField), 'Uzoq xabar');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Uzoq xabar'), findsOneWidget);
      // The server's own sentence, beside the button that failed.
      expect(find.text('Suhbat tugagan.'), findsOneWidget);
    });

    testWidgets('a sent message appears without a re-fetch', (tester) async {
      final fake = await pump(
        tester,
        conversation: conversationFixture(),
        page: [messageFixture(id: 'a', body: 'Birinchi')],
        sendOutcome: MessageSent(messageFixture(id: 'b', body: 'Ikkinchi')),
      );

      await tester.enterText(find.byType(TextField), 'Ikkinchi');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MessageBubble), findsNWidgets(2));
      // One page request, from the first build. A round trip per message costs
      // most on exactly the connection that makes somebody type instead of
      // call.
      expect(fake.pageRequests, hasLength(1));
    });

    testWidgets('a replayed send does not show the message twice', (
      tester,
    ) async {
      // §12.4's replay returns the message the *first* attempt created, and
      // that one is already on the thread. Without the id check a lost response
      // would reintroduce, in the widget layer, the very duplicate the
      // idempotency key exists to prevent.
      final replayed = messageFixture(id: 'a', body: 'Birinchi');
      await pump(
        tester,
        conversation: conversationFixture(),
        page: [replayed],
        sendOutcome: MessageSent(replayed),
      );

      await tester.enterText(find.byType(TextField), 'Birinchi');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MessageBubble), findsOneWidget);
    });
  });

  testWidgets('opening the thread marks it read', (tester) async {
    final fake = await pump(
      tester,
      conversation: conversationFixture(unreadCount: 4),
      page: [messageFixture(id: 'a', senderUserId: 'them')],
    );

    expect(fake.marked, ['conv-1']);
  });

  testWidgets('a day separator appears once per day', (tester) async {
    // Newest first, so the older neighbour is the *next* index — and the oldest
    // row loaded always gets one, since there is nothing above it to compare
    // with.
    await pump(
      tester,
      conversation: conversationFixture(),
      page: [
        messageFixture(id: 'c', createdAt: '2026-08-20T09:00:00+05:00'),
        messageFixture(id: 'b', createdAt: '2026-08-19T18:00:00+05:00'),
        messageFixture(id: 'a', createdAt: '2026-08-19T09:00:00+05:00'),
      ],
    );

    expect(find.text('2026-08-20'), findsOneWidget);
    expect(find.text('2026-08-19'), findsOneWidget);
  });

  testWidgets('nothing in the thread mentions money (§9.1)', (tester) async {
    // §9.1's entitlement is the employer's. The way this regresses is a
    // well-meaning "top up to reply" landing on a candidate's screen — and the
    // candidate is the side that never owed anything.
    await pump(
      tester,
      conversation: conversationFixture(canSend: false),
      page: [messageFixture(id: 'a', senderUserId: 'them')],
    );

    for (final word in ['coin', 'Coin', 'unlock', 'Unlock', 'UZS', 'top up']) {
      expect(
        find.textContaining(word),
        findsNothing,
        reason: '"$word" must not appear in a conversation',
      );
    }
  });

  testWidgets('the thread survives 320pt at 2.0x text scale', (tester) async {
    await pump(
      tester,
      conversation: conversationFixture(),
      page: [
        messageFixture(
          id: 'a',
          body: 'Assalomu alaykum, vakansiya bo‘yicha savolim bor edi.',
          isReadByRecipient: true,
        ),
        messageFixture(
          id: 'b',
          senderUserId: 'them',
          body: 'Kelishdik, ertaga soat 10 da qo‘ng‘iroq qilaman.',
          fileId: 'f-1',
          fileName: 'shartnoma.pdf',
          downloadPath: '/conversations/conv-1/messages/b/file',
        ),
      ],
      // 960 physical at dpr 3 is 320 logical.
      size: const Size(960, 2400),
      scale: 2,
    );

    expect(tester.takeException(), isNull);
  });

  group('the composer is an action bar, not a form', () {
    testWidgets('it is built to grow from one line, not to start at four', (
      tester,
    ) async {
      await pump(tester, conversation: conversationFixture());

      final field = tester.widget<HhTextField>(find.byType(HhTextField));

      // **A `TextField` with `maxLines: 4` and no `minLines` is a fixed
      // four-line box**, which is Flutter's rule and is what made this a
      // textarea. The pair below is the whole difference, and it is the part a
      // font cannot distort — see the height case underneath.
      expect(field.minLines, 1);
      expect(field.maxLines, 4);
      expect(field.showLabel, isFalse);
    });

    testWidgets('and it is not the form box', (tester) async {
      await pump(tester, conversation: conversationFixture());

      // The painted box, not the widget: `HhTextField` is a Column whose
      // height its parent stretches, and the claim is about the control.
      final box = tester.getSize(find.byType(AnimatedContainer));

      // A bound rather than 52 exactly, and the reason is the test font:
      // `FlutterTest` draws every glyph one em wide, so the placeholder wraps
      // here at a width where Golos would not. What the bound still catches is
      // the regression that matters — going back to the ordinary field, whose
      // multiline minimum is 52 * 1.6 *before* its persistent label.
      expect(box.height, lessThan(HhSize.control * 1.6));
    });

    testWidgets('and it still has a name', (tester) async {
      await pump(tester, conversation: conversationFixture());

      final l10n = lookupAppL10n(const Locale('en'));

      // The label stopped being *drawn*; it did not stop existing. A field
      // whose only name is its hint is one MT-015 would have filed.
      // A TextField merges its hint into its name, so the match is on the
      // label being *present* rather than on it being the whole string.
      expect(
        find.bySemanticsLabel(RegExp(l10n.chatComposerLabel)),
        findsOneWidget,
      );
    });

    testWidgets('it grows with the message, up to four lines', (tester) async {
      await pump(tester, conversation: conversationFixture());

      final oneLine = tester.getSize(find.byType(AnimatedContainer)).height;

      await tester.enterText(
        find.byType(HhTextField),
        List.filled(12, 'Assalomu alaykum').join(' '),
      );
      await tester.pumpAndSettle();

      final grown = tester.getSize(find.byType(AnimatedContainer)).height;

      expect(grown, greaterThan(oneLine));
      // Four lines and no further: past that the composer would start eating
      // the conversation it belongs to.
      expect(grown, lessThan(HhSize.control * 3));
      expect(
        tester.widget<HhTextField>(find.byType(HhTextField)).maxLines,
        4,
      );
    });
  });
}
