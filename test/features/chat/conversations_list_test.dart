import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:jobbridge_app/src/features/chat/presentation/conversations_screen.dart';

import 'chat_fake.dart';

/// §9.1's Messages tab.
void main() {
  Future<FakeChat> pump(
    WidgetTester tester, {
    required List<Conversation> threads,
    Size size = const Size(1080, 2400),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = FakeChat(threads: threads);

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
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: child!,
          ),
          home: const Scaffold(
            body: ConversationsScreen(basePath: Routes.employerMessages),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('the preview line has three cases, not two', () {
    testWidgets('a thread with text shows it', (tester) async {
      await pump(tester, threads: [conversationFixture()]);

      expect(find.text('Salom, vakansiya haqida'), findsOneWidget);
    });

    testWidgets('a thread whose last message was a file says so', (
      tester,
    ) async {
      // The server sends the last message's *body*, and a message that carried
      // only an attachment has none. "Active but nothing to quote" is a real
      // state and it is not the same as a thread nobody has written in.
      await pump(tester, threads: [conversationFixture(lastMessageBody: null)]);

      expect(find.text('Attachment'), findsOneWidget);
      expect(find.text('No messages yet'), findsNothing);
    });

    testWidgets('a thread nobody has written in says that instead', (
      tester,
    ) async {
      await pump(tester, threads: [
        conversationFixture(lastMessageAt: null, lastMessageBody: null),
      ]);

      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Attachment'), findsNothing);
    });
  });

  group('state is a badge, never a colour', () {
    testWidgets('a live thread carries none', (tester) async {
      // "Open" is the default, and badging it would make the exception
      // invisible among the rule.
      await pump(tester, threads: [conversationFixture()]);

      expect(find.byType(HhBadge), findsNothing);
    });

    testWidgets('an ended interaction reads as read-only', (tester) async {
      await pump(tester, threads: [conversationFixture(canSend: false)]);

      expect(find.text('Read-only'), findsOneWidget);
    });

    testWidgets('a block by the other side is its own word', (tester) async {
      await pump(tester, threads: [
        conversationFixture(canSend: false, isBlocked: true),
      ]);

      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('Read-only'), findsNothing);
    });

    testWidgets('a block the reader set says who set it', (tester) async {
      // Only the person who set a block can lift it, so the row has to tell the
      // two apart or the thread's own screen is a surprise.
      await pump(tester, threads: [
        conversationFixture(
          canSend: false,
          isBlocked: true,
          blockedByMe: true,
        ),
      ]);

      expect(find.text('You blocked this'), findsOneWidget);
      expect(find.text('Blocked'), findsNothing);
    });
  });

  group('the unread pill', () {
    // Two tests rather than one with two pumps: a second `pumpWidget` updates
    // the existing `ProviderScope` element instead of replacing it, so the
    // container — and `conversationsProvider`'s already-resolved value — would
    // survive, and the second override would never be read.
    testWidgets('is absent at zero', (tester) async {
      await pump(tester, threads: [conversationFixture()]);

      expect(find.byType(HhUnreadPill), findsNothing);
    });

    testWidgets('shows the count above zero', (tester) async {
      await pump(tester, threads: [conversationFixture(unreadCount: 3)]);

      expect(find.byType(HhUnreadPill), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('carries the word for a screen reader', (tester) async {
      // The pill is a numeral, because the design's "never colour alone" rule
      // is about states and a number conveys itself. A reader hearing only "3"
      // would not know three of what.
      await pump(tester, threads: [conversationFixture(unreadCount: 3)]);

      expect(
        tester.widget<HhUnreadPill>(find.byType(HhUnreadPill)).semanticsLabel,
        '3 unread messages',
      );
    });
  });

  testWidgets('a counterpart with no name still reads as a person', (
    tester,
  ) async {
    // §7.3's permitted-name rule means a missing name is sometimes the correct
    // answer rather than a load that failed.
    await pump(tester, threads: [conversationFixture(counterpartName: null)]);

    expect(find.text('Participant'), findsOneWidget);
  });

  testWidgets('the empty state says how the list fills up', (tester) async {
    await pump(tester, threads: []);

    expect(
      find.textContaining('A conversation opens with a hiring interaction'),
      findsOneWidget,
    );
  });

  testWidgets('nothing on the list mentions money (§9.1)', (tester) async {
    // The way this regresses is a well-meaning "top up to reply" landing on a
    // candidate's screen. §9.1's entitlement is the employer's, and a candidate
    // who was written to has had nothing bought from them.
    await pump(tester, threads: [
      conversationFixture(unreadCount: 2),
      conversationFixture(id: 'conv-2', canSend: false),
    ]);

    for (final word in ['coin', 'Coin', 'unlock', 'UZS', 'top up']) {
      expect(
        find.textContaining(word),
        findsNothing,
        reason: '"$word" must not appear on a conversation list',
      );
    }
  });

  testWidgets('the row survives 320pt at 2.0x text scale', (tester) async {
    // The design's own QA case, and the geometry the §8.2 inbox card overflowed
    // at: a name, a timestamp and a state badge on one row do not fit, which is
    // why the badge is on its own line.
    await pump(
      tester,
      threads: [
        conversationFixture(
          counterpartName: 'Abdurahmon Xudoyberdiyev',
          canSend: false,
          isBlocked: true,
          blockedByMe: true,
          unreadCount: 12,
        ),
      ],
      // 960 physical at dpr 3 is 320 logical — the narrowest screen the design
      // states a case for.
      size: const Size(960, 2400),
      scale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
