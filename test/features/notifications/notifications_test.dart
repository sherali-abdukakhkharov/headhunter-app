import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/domain/app_notification.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notifications_screen.dart';

/// §9.2's in-app notification centre — MT-005's client half.
class _FakeNotifications implements NotificationRepository {
  _FakeNotifications({this.pages = const [], this.failure});

  /// One entry per request, in order, so paging is observable.
  List<List<AppNotification>> pages;
  /// The badge figure. Its own endpoint, so it is not derived from [pages].
  int unread = 0;
  ApiException? failure;

  /// How many `markAllRead` reports as having been unread.
  int marked = 0;

  final requests = <({bool unreadOnly, int offset})>[];
  final read = <String>[];
  final preferenceWrites = <({String category, bool enabled})>[];
  int allReadCalls = 0;

  @override
  Future<List<AppNotification>> list({
    bool unreadOnly = false,
    int offset = 0,
  }) async {
    if (failure case final error?) throw error;
    requests.add((unreadOnly: unreadOnly, offset: offset));

    final index = requests.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  @override
  Future<int> unreadCount() async => unread;

  @override
  Future<void> markRead(String id) async => read.add(id);

  @override
  Future<int> markAllRead() async {
    allReadCalls++;
    return marked;
  }

  @override
  Future<List<NotificationPreference>> preferences() async => const [
    NotificationPreference(
      category: NotificationCategory.applications,
      enabled: true,
      canDisable: true,
    ),
    NotificationPreference(
      category: NotificationCategory.account,
      enabled: true,
      canDisable: false,
    ),
  ];

  @override
  Future<void> setPreference(
    NotificationCategory category, {
    required bool enabled,
  }) async => preferenceWrites.add((
    category: category.wire,
    enabled: enabled,
  ));

  /// Push's half of the contract. Recorded rather than stubbed away, so a
  /// screen that started registering devices of its own accord shows up here
  /// — the in-app centre has no business touching either of these.
  final registered = <({String token, String? appVersion})>[];
  final unregistered = <String>[];

  @override
  Future<void> registerDevice({
    required String token,
    String? appVersion,
  }) async => registered.add((token: token, appVersion: appVersion));

  @override
  Future<void> unregisterDevice(String token) async =>
      unregistered.add(token);
}

AppNotification _notification({
  String id = 'ntf-1',
  String event = 'message_received',
  String category = 'messages',
  String text = 'Uzum Market sent you a message',
  String? targetType = 'conversation',
  String? targetId = 'cnv-1',
  bool isRead = false,
}) => AppNotification.fromJson({
  'id': id,
  'event': event,
  'category': category,
  'text': text,
  'targetType': targetType,
  'targetId': targetId,
  'isRead': isRead,
  'createdAt': '2026-08-22T14:05:00+05:00',
});

void main() {
  Future<_FakeNotifications> pump(
    WidgetTester tester, {
    List<List<AppNotification>> pages = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeNotifications(pages: pages);

    await tester.pumpWidget(
      ProviderScope(
        // Riverpod 3 retries a throwing provider by default and reports
        // `AsyncLoading` while it does. The app disables it in `main.dart`.
        retry: (retryCount, error) => null,
        overrides: [
          notificationRepositoryProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('the sentence is the server’s and the branch is the code', () {
    testWidgets('the text is shown as given', (tester) async {
      await pump(
        tester,
        pages: [
          [_notification()],
        ],
      );

      // The row stores a message key and its parameters; the server renders it
      // in the language of the request, so a client-side table would be a
      // second translation of one event.
      expect(find.text('Uzum Market sent you a message'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('2026-08-22 14:05'), findsOneWidget);
    });

    testWidgets('a category this build has not heard of still draws', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [_notification(category: 'payments', text: 'Your top-up went in')],
        ],
      );

      expect(find.text('Your top-up went in'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });
  });

  group('where a notification leads depends on who is reading it', () {
    test('a conversation opens in whichever shell has a Messages tab', () {
      final item = _notification();

      expect(
        notificationDestination(item, AppRole.candidate),
        '${Routes.candidateMessages}/cnv-1',
      );
      expect(
        notificationDestination(item, AppRole.employer),
        '${Routes.employerMessages}/cnv-1',
      );
      // The administrator has no Messages tab, so there is nowhere honest to
      // send them.
      expect(notificationDestination(item, AppRole.admin), isNull);
    });

    test('an application opens the candidate list, and nothing else', () {
      final item = _notification(
        event: 'application_status_changed',
        category: 'applications',
        targetType: 'application',
        targetId: 'app-1',
      );

      // §8.1's applications, §8.2's invitations and §8.3's interviews all live
      // behind one candidate tab, which is why none of the three needs an id.
      expect(
        notificationDestination(item, AppRole.candidate),
        Routes.candidateApplications,
      );
      // An employer reaches applicants *through a vacancy*, and this
      // notification does not name one. Guessing it would be a request this
      // has no business making.
      expect(notificationDestination(item, AppRole.employer), isNull);
    });

    test('an employer vacancy is addressable, a candidate one pushed', () {
      final item = _notification(
        event: 'vacancy_moderated',
        category: 'account',
        targetType: 'vacancy',
        targetId: 'vac-1',
      );

      expect(
        notificationDestination(item, AppRole.employer),
        '${Routes.employerVacancies}/vac-1',
      );
      // The candidate's vacancy detail has no path of its own, so the row
      // carries a sentinel the screen turns into a push.
      expect(
        notificationDestination(item, AppRole.candidate),
        isNot(anyOf(isNull, startsWith('/'))),
      );
    });

    test('a notice about the account itself leads nowhere', () {
      final item = _notification(
        event: 'account_action',
        category: 'account',
        targetType: 'user',
        targetId: 'usr-1',
      );

      // BR-10's restriction notice *is* the explanation; there is nothing to
      // open. For an administrator the same target is somebody else.
      expect(notificationDestination(item, AppRole.candidate), isNull);
      expect(
        notificationDestination(item, AppRole.admin),
        Routes.adminUserFor('usr-1'),
      );
    });

    test('a target this build cannot place leads nowhere, not to a guess', () {
      final item = _notification(targetType: 'payment', targetId: 'pay-1');

      expect(notificationDestination(item, AppRole.candidate), isNull);
    });

    testWidgets('a row with no destination has no chevron', (tester) async {
      await pump(
        tester,
        pages: [
          [
            _notification(
              event: 'account_action',
              category: 'account',
              targetType: null,
              targetId: null,
              text: 'Your account has been restricted',
            ),
          ],
        ],
      );

      // Still shown: it is a record, and the notice is the whole of it.
      expect(find.text('Your account has been restricted'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is HhIcon && w.path == HhIconPath.chevronRight,
        ),
        findsNothing,
      );
    });
  });

  group('reading is one request, not a reload', () {
    testWidgets('tapping marks it read and leaves it in place', (tester) async {
      final fake = await pump(
        tester,
        pages: [
          [
            _notification(
              targetType: null,
              targetId: null,
              text: 'Your account has been restricted',
            ),
          ],
        ],
      );

      await tester.tap(find.text('Your account has been restricted'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.read, ['ntf-1']);
      // One list request, not two: the route answers 204, so a refetch would
      // spend a request learning what the request just did.
      expect(fake.requests, hasLength(1));
      expect(find.text('Your account has been restricted'), findsOneWidget);
    });

    testWidgets('an already-read one is not marked again', (tester) async {
      final fake = await pump(
        tester,
        pages: [
          [
            _notification(
              isRead: true,
              targetType: null,
              targetId: null,
              text: 'Old news',
            ),
          ],
        ],
      );

      await tester.tap(find.text('Old news'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.read, isEmpty);
    });

    testWidgets('marking all read says how many actually were', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        pages: [
          [_notification()],
        ],
      );
      fake.marked = 3;

      await tester.tap(find.text('Mark all read'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.allReadCalls, 1);
      expect(find.text('3 marked as read'), findsOneWidget);
    });

    testWidgets('and says so plainly when there was nothing to do', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        pages: [
          [_notification(isRead: true)],
        ],
      );
      fake.marked = 0;

      await tester.tap(find.text('Mark all read'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Marking an already-read list succeeds and marks zero. Confirming that
      // as an action would confirm something that did not happen.
      expect(find.text('Everything was already read'), findsOneWidget);
    });
  });

  group('the unread filter is a different question', () {
    testWidgets('switching to it asks the server rather than filtering here', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        pages: [
          [_notification(isRead: true)],
          [_notification(id: 'ntf-2')],
        ],
      );

      await tester.tap(find.text('Unread'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Filtering the page here would under-report the moment there are more
      // than twenty: the page is one page and the filter is over all of them.
      expect(fake.requests.last.unreadOnly, isTrue);
    });

    testWidgets('an empty filter is not an empty list', (tester) async {
      await pump(tester);

      expect(find.text('Nothing yet'), findsOneWidget);

      await tester.tap(find.text('Unread'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nothing unread'), findsOneWidget);
      expect(find.text('Nothing yet'), findsNothing);
    });

    testWidgets('paging asks for the next offset', (tester) async {
      final fake = await pump(
        tester,
        pages: [
          [
            for (var i = 0; i < notificationPageSize; i++)
              _notification(id: 'ntf-$i', targetType: null, targetId: null),
          ],
          [_notification(id: 'ntf-last')],
        ],
      );

      await tester.scrollUntilVisible(find.text('Show more'), 200);
      await tester.ensureVisible(find.text('Show more'));
      await tester.pump();
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.requests.map((r) => r.offset).toList(), [
        0,
        notificationPageSize,
      ]);
    });
  });

  group('§9.2 keeps the account category on', () {
    testWidgets('its switch is shown and cannot be thrown', (tester) async {
      final fake = await pump(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Shown greyed out rather than omitted: a user who cannot find a switch
      // assumes it is off.
      expect(find.text('Account'), findsOneWidget);
      expect(
        find.textContaining('Security and account notices'),
        findsOneWidget,
      );

      await tester.tap(find.text('Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.preferenceWrites, isEmpty);
    });

    testWidgets('a disableable one writes', (tester) async {
      final fake = await pump(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Applications'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.preferenceWrites.single, (
        category: 'applications',
        enabled: false,
      ));
    });
  });

  group('the states around the list', () {
    testWidgets('a failure is terminal and offers a retry', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = _FakeNotifications(
        failure: const ApiException('Service unavailable'),
      );

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            notificationRepositoryProvider.overrideWithValue(fake),
          ],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: const NotificationsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Service unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
