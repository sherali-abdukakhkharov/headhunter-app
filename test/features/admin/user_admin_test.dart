import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_user.dart';
import 'package:jobbridge_app/src/features/admin/domain/user_search_filters.dart';
import 'package:jobbridge_app/src/features/admin/presentation/user_detail_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/user_search_screen.dart';

import 'admin_fake.dart';

/// §10.4's user search and its four actions (UAT-14).
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({this.pages = const [], this.detail, this.detailError});

  List<List<AdminUser>> pages;
  AdminUserDetail? detail;
  ApiException? detailError;

  /// Whether the status change answers 409 `admin.status_unchanged`.
  bool statusConflict = false;

  /// Every search that reached the repository, as the query the server sees.
  final searches = <Map<String, dynamic>>[];
  final requestedOffsets = <int>[];
  final statusChanges =
      <({String userId, String status, String reason, String? until})>[];
  final warnings = <({String userId, String reason})>[];

  @override
  Future<List<AdminUser>> searchUsers(
    UserSearchFilters filters, {
    int offset = 0,
  }) async {
    searches.add(filters.toQuery());
    requestedOffsets.add(offset);

    final index = requestedOffsets.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  @override
  Future<AdminUserDetail> user(String userId) async {
    if (detailError case final error?) throw error;
    return detail!;
  }

  @override
  Future<void> setUserStatus(
    String userId,
    UserStatusChange status,
    String reason, {
    String? restrictedUntil,
  }) async {
    statusChanges.add((
      userId: userId,
      status: status.wire,
      reason: reason,
      until: restrictedUntil,
    ));

    if (statusConflict) {
      throw const AdminDecisionConflict('This account is already blocked.');
    }
  }

  @override
  Future<void> warnUser(String userId, String reason) async =>
      warnings.add((userId: userId, reason: reason));

  // Every §10.1 and §10.2 route refuses through [FakeAdminBase]: neither of
  // §10.4's screens reads one.
}

AdminUser _user({
  String userId = 'usr-1',
  String? phone = '+998901234567',
  String? name = 'Alisher Karimov',
  List<String> roles = const ['candidate'],
  String status = 'active',
  String? restrictedUntil,
  String createdAt = '2026-03-14T09:00:00+05:00',
  String? lastLoginAt = '2026-08-20T18:30:00+05:00',
}) => AdminUser.fromJson({
  'userId': userId,
  'phone': phone,
  'name': name,
  'roles': roles,
  'status': status,
  'restrictedUntil': restrictedUntil,
  'createdAt': createdAt,
  'lastLoginAt': lastLoginAt,
});

AdminUserDetail _detail({
  String status = 'active',
  String? restrictedUntil,
  String createdAt = '2026-03-14T09:00:00+05:00',
  List<Map<String, dynamic>> history = const [],
  List<Map<String, dynamic>> complaints = const [],
}) => AdminUserDetail.fromJson({
  'userId': 'usr-1',
  'phone': '+998901234567',
  'name': 'Alisher Karimov',
  'roles': const ['candidate', 'employer'],
  'status': status,
  'restrictedUntil': restrictedUntil,
  'createdAt': createdAt,
  'lastLoginAt': '2026-08-20T18:30:00+05:00',
  'statusHistory': history,
  'complaints': complaints,
});

void main() {
  Widget wrap(Widget child, _FakeAdmin fake) => ProviderScope(
    // Riverpod 3 retries a throwing provider by default and reports
    // `AsyncLoading` while it does, so a failure would render as a spinner.
    // The app disables it in `main.dart`; the tests must match.
    retry: (retryCount, error) => null,
    overrides: [adminRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(
      theme: HhTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: child,
    ),
  );

  /// The search screen reads `?status=` off the location, so it only exists
  /// inside a router.
  ({Widget widget, GoRouter router}) routed(
    _FakeAdmin fake, {
    String at = Routes.adminUsers,
  }) {
    final router = GoRouter(
      initialLocation: at,
      routes: [
        GoRoute(
          path: Routes.adminUsers,
          builder: (context, state) => const UserSearchScreen(),
          routes: [
            // Registered so a row tap resolves; the detail is exercised on its
            // own below.
            GoRoute(
              path: ':id',
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );

    return (
      widget: ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [adminRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp.router(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          routerConfig: router,
        ),
      ),
      router: router,
    );
  }

  Future<({_FakeAdmin fake, GoRouter router})> pumpSearch(
    WidgetTester tester, {
    List<List<AdminUser>> pages = const [],
    String at = Routes.adminUsers,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(pages: pages);
    final app = routed(fake, at: at);
    await tester.pumpWidget(app.widget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return (fake: fake, router: app.router);
  }

  Future<_FakeAdmin> pumpDetail(
    WidgetTester tester, {
    AdminUserDetail? detail,
    ApiException? error,
    bool conflict = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(detail: detail ?? _detail(), detailError: error)
      ..statusConflict = conflict;
    await tester.pumpWidget(
      wrap(const UserDetailScreen(userId: 'usr-1'), fake),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  /// Brings [finder] fully on screen. `scrollUntilVisible` stops as soon as the
  /// widget is *built*, which can leave it a few pixels past the bottom edge —
  /// a `tap` then warns that the offset misses and does nothing.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  group('the screen does not search until it is asked to', () {
    testWidgets('opening the tab sends nothing', (tester) async {
      final app = await pumpSearch(tester);

      // §11.1 logs every read of protected data, and this route answers with
      // phone numbers. A tab that searched on open would write a log line
      // every time somebody passed through it — the same reason the
      // verification queue does not prefetch evidence.
      expect(app.fake.searches, isEmpty);
      expect(find.text('Find an account'), findsOneWidget);
    });

    testWidgets('the idle state is not the empty state', (tester) async {
      final app = await pumpSearch(tester);

      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Both are "no rows on screen", and they answer different questions.
      expect(app.fake.searches, hasLength(1));
      expect(find.text('Find an account'), findsNothing);
      expect(find.text('No account matches'), findsOneWidget);
    });
  });

  group("the server's minimums are on the fields", () {
    testWidgets('a two-digit phone blocks the search', (tester) async {
      final app = await pumpSearch(tester);

      await tester.enterText(find.byType(TextField).first, '99');
      await tester.pump();

      expect(find.text('At least 3 digits.'), findsOneWidget);

      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();

      // Refused before it leaves rather than after a 400.
      expect(app.fake.searches, isEmpty);

      // And the gate really is the length: a third digit lifts it.
      await tester.enterText(find.byType(TextField).first, '990');
      await tester.pump();
      expect(find.text('At least 3 digits.'), findsNothing);

      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(app.fake.searches, hasLength(1));
    });

    testWidgets('a one-character name blocks the search', (tester) async {
      final app = await pumpSearch(tester);

      await tester.enterText(find.byType(TextField).at(1), 'A');
      await tester.pump();

      expect(find.text('At least 2 characters.'), findsOneWidget);
      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      expect(app.fake.searches, isEmpty);
    });
  });

  group('what leaves the client', () {
    testWidgets('a pasted phone number is reduced to the stored form', (
      tester,
    ) async {
      final app = await pumpSearch(tester);

      await tester.enterText(
        find.byType(TextField).first,
        '+998 90 123 45 67',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The match is a raw LIKE against an E.164 column, so the spaces would
      // be *in the pattern* and this number pasted out of a chat would match
      // nothing. Sending it as typed is the bug this asserts against.
      expect(app.fake.searches.single['phone'], '+998901234567');
    });

    test('the filters go under the keys the server documents', () {
      const filters = UserSearchFilters(
        phone: '9012',
        name: 'Uzum',
        registeredFrom: '2026-01-01',
        registeredTo: '2026-08-07',
      );

      expect(filters.toQuery(), {
        'phone': '9012',
        'name': 'Uzum',
        'registeredFrom': '2026-01-01',
        'registeredTo': '2026-08-07',
      });
    });

    test('an unset filter is omitted rather than sent as null', () {
      expect(const UserSearchFilters().toQuery(), isEmpty);
      expect(const UserSearchFilters(name: '  ').toQuery(), isEmpty);
    });

    test('a reversed date range is refused before it is sent', () {
      const filters = UserSearchFilters(
        registeredFrom: '2026-08-07',
        registeredTo: '2026-01-01',
      );

      // The server answers this with an empty list rather than a refusal,
      // which is the answer hardest to tell from "no such person".
      expect(filters.datesAreReversed, isTrue);
      expect(filters.isRunnable, isFalse);
    });
  });

  group('the results say what they are', () {
    testWidgets('a full page says how it is ordered', (tester) async {
      final app = await pumpSearch(
        tester,
        pages: [
          [for (var i = 0; i < adminPageSize; i++) _user(userId: 'usr-$i')],
        ],
      );

      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // An old account matching a broad filter sits past the page rather than
      // outside the filter, and from the client those look identical.
      expect(
        find.textContaining('Newest registration first'),
        findsOneWidget,
      );
      expect(app.fake.searches, hasLength(1));
    });

    testWidgets('a short page does not', (tester) async {
      await pumpSearch(
        tester,
        pages: [
          [_user()],
        ],
      );

      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Nothing is past this page, so the sentence would be noise.
      expect(find.textContaining('Newest registration first'), findsNothing);
      expect(find.text('Alisher Karimov'), findsOneWidget);
      expect(find.text('+998901234567'), findsOneWidget);
    });

    testWidgets('a nameless account says so rather than drawing a gap', (
      tester,
    ) async {
      await pumpSearch(
        tester,
        pages: [
          [_user(name: null, phone: null)],
        ],
      );

      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No name on the account'), findsOneWidget);
      expect(find.text('No phone number'), findsOneWidget);
    });
  });

  group('a dashboard counter is a destination', () {
    testWidgets('arriving with a status searches for exactly it', (
      tester,
    ) async {
      final app = await pumpSearch(
        tester,
        at: Routes.adminUsersWithStatus('blocked'),
        pages: [
          [_user(status: 'blocked')],
        ],
      );

      // Arriving from a counter *is* an administrator asking, which is why
      // this is the one search the screen runs without a button press.
      expect(app.fake.searches.single, {'status': 'blocked'});
    });

    testWidgets("the second counter does not show the first one's list", (
      tester,
    ) async {
      final app = await pumpSearch(
        tester,
        at: Routes.adminUsersWithStatus('restricted'),
      );

      app.router.go(Routes.adminUsersWithStatus('blocked'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The shell keeps a branch across tab switches, so a segment held in
      // widget state would ignore the second `go` entirely — the bug the
      // moderation tab's `?queue=` exists to prevent.
      expect(app.fake.searches, [
        {'status': 'restricted'},
        {'status': 'blocked'},
      ]);
    });

    testWidgets('it clears whatever was filtering before', (tester) async {
      final app = await pumpSearch(tester);

      await tester.enterText(find.byType(TextField).at(1), 'Uzum');
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      app.router.go(Routes.adminUsersWithStatus('restricted'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // "Show me the restricted accounts", not "show me the restricted
      // accounts among the ones I was looking for ten minutes ago".
      expect(app.fake.searches.last, {'status': 'restricted'});
    });
  });

  group('the offered actions come from the status the account is in', () {
    testWidgets('an active account can be restricted or blocked', (
      tester,
    ) async {
      await pumpDetail(tester);

      expect(find.widgetWithText(HhButton, 'Restrict'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Block'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Unblock'), findsNothing);
    });

    testWidgets('a blocked account offers only the way back', (tester) async {
      await pumpDetail(tester, detail: _detail(status: 'blocked'));

      expect(find.widgetWithText(HhButton, 'Unblock'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Block'), findsNothing);
      expect(find.widgetWithText(HhButton, 'Restrict'), findsNothing);
    });

    testWidgets('a restricted account is lifted, not unblocked', (
      tester,
    ) async {
      await pumpDetail(tester, detail: _detail(status: 'restricted'));

      // Same transition, two sentences: "unblock" says nothing to somebody
      // looking at a restricted account.
      expect(
        find.widgetWithText(HhButton, 'Lift the restriction'),
        findsOneWidget,
      );
      expect(find.widgetWithText(HhButton, 'Unblock'), findsNothing);
      expect(find.widgetWithText(HhButton, 'Block'), findsOneWidget);
    });

    testWidgets('an account awaiting deletion offers none of the three', (
      tester,
    ) async {
      await pumpDetail(tester, detail: _detail(status: 'deletion_requested'));

      // BR-14 owns that state and the server answers 409 for every transition
      // out of it — the same 409 that means "somebody decided first"
      // everywhere else. Never offering the action is what keeps the code
      // meaning one thing.
      expect(find.text('Nothing can be done from here'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Restrict'), findsNothing);
      expect(find.widgetWithText(HhButton, 'Block'), findsNothing);
      expect(find.widgetWithText(HhButton, 'Unblock'), findsNothing);

      // A warning changes no status, so it survives BR-14's state.
      expect(find.widgetWithText(HhButton, 'Warn this person'), findsOneWidget);
    });

    test('the table itself', () {
      expect(UserStatusChange.availableFor(UserAccountStatus.active), [
        UserStatusChange.restricted,
        UserStatusChange.blocked,
      ]);
      expect(UserStatusChange.availableFor(UserAccountStatus.restricted), [
        UserStatusChange.blocked,
        UserStatusChange.active,
      ]);
      expect(UserStatusChange.availableFor(UserAccountStatus.blocked), [
        UserStatusChange.active,
      ]);
      expect(
        UserStatusChange.availableFor(UserAccountStatus.deletionRequested),
        isEmpty,
      );
    });
  });

  group("the restriction's end date is an instant, not a day", () {
    test('it carries the offset it was given', () {
      // A bare `2026-09-01` is parsed by the server as UTC midnight, which is
      // 05:00 in Tashkent — so the restriction would run five hours into a day
      // the administrator ended it on.
      expect(
        restrictionEndsAt('2026-09-01', const Duration(hours: 5)),
        '2026-09-01T00:00:00+05:00',
      );
    });

    test('and it is not a constant', () {
      // Mutation guard: a `+05:00` written into Dart would pass the test above
      // and be wrong the day the platform's offset moves.
      expect(
        restrictionEndsAt('2026-09-01', const Duration(hours: 3)),
        '2026-09-01T00:00:00+03:00',
      );
      expect(
        restrictionEndsAt(
          '2026-09-01',
          const Duration(hours: -3, minutes: -30),
        ),
        '2026-09-01T00:00:00-03:30',
      );
    });

    testWidgets('the offset comes from the account, not from Dart', (
      tester,
    ) async {
      // A user row whose timestamps carry +03:00. Nothing else about the
      // fixture differs, so a hard-coded platform offset fails here and
      // nowhere else.
      final fake = await pumpDetail(
        tester,
        detail: _detail(createdAt: '2026-03-14T09:00:00+03:00'),
      );

      await reveal(tester, find.widgetWithText(HhButton, 'Restrict'));
      await tester.tap(find.widgetWithText(HhButton, 'Restrict'));
      await tester.pumpAndSettle();

      // The date field is offered only on a restriction.
      expect(find.text('Ends on'), findsOneWidget);

      // Open the calendar and accept whatever day it opens on: the assertion
      // is about the offset and the time, not about which day was tapped.
      // The field itself, not its label — the label is a separate Text above
      // the box and taps nothing.
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).last,
        'Asking candidates for money',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Restrict').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final sent = fake.statusChanges.single;
      expect(sent.status, 'restricted');
      expect(sent.reason, 'Asking candidates for money');
      expect(sent.until, endsWith('T00:00:00+03:00'));
    });

    testWidgets('a restriction with no date sends none', (tester) async {
      final fake = await pumpDetail(tester);

      await reveal(tester, find.widgetWithText(HhButton, 'Restrict'));
      await tester.tap(find.widgetWithText(HhButton, 'Restrict'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Under review');
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Restrict').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // An optional date whose absence means "until an administrator lifts
      // it", which the sheet's caption says out loud.
      expect(fake.statusChanges.single.until, isNull);
    });

    testWidgets('blocking is not offered one', (tester) async {
      final fake = await pumpDetail(tester);

      await reveal(tester, find.widgetWithText(HhButton, 'Block'));
      await tester.tap(find.widgetWithText(HhButton, 'Block'));
      await tester.pumpAndSettle();

      // BR-10's guard only ever expires a restriction, so a date on a block
      // would be a field the server ignores.
      expect(find.text('Ends on'), findsNothing);

      await tester.enterText(find.byType(TextField).last, 'Fraud');
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Block').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.statusChanges.single.status, 'blocked');
      expect(fake.statusChanges.single.until, isNull);
    });
  });

  group('the decision, and what it leaves behind', () {
    testWidgets('a mandatory reason gates the confirmation', (tester) async {
      final fake = await pumpDetail(tester);

      await reveal(tester, find.widgetWithText(HhButton, 'Block'));
      await tester.tap(find.widgetWithText(HhButton, 'Block'));
      await tester.pumpAndSettle();

      // §10.4 requires a reason for all four actions, and BR-10 requires the
      // app to explain a restriction rather than fail mysteriously.
      await tester.tap(find.widgetWithText(HhButton, 'Block').last);
      await tester.pump();
      expect(fake.statusChanges, isEmpty);
    });

    testWidgets('a 409 still leaves the account in the status asked for', (
      tester,
    ) async {
      final fake = await pumpDetail(tester, conflict: true);

      await reveal(tester, find.widgetWithText(HhButton, 'Block'));
      await tester.tap(find.widgetWithText(HhButton, 'Block'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Fraud');
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Block').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // `admin.status_unchanged` means it was *already* blocked, so the work
      // is done — the sheet says so rather than reporting a failure.
      expect(find.text('This account is already blocked.'), findsOneWidget);
      expect(fake.statusChanges, hasLength(1));
    });

    testWidgets('a warning changes nothing on screen', (tester) async {
      final fake = await pumpDetail(tester);

      await reveal(tester, find.widgetWithText(HhButton, 'Warn this person'));
      await tester.tap(find.widgetWithText(HhButton, 'Warn this person'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        'Contact details in a public description',
      );
      await tester.pump();
      await tester.tap(
        find.widgetWithText(HhButton, 'Warn this person').last,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.warnings.single.userId, 'usr-1');
      expect(fake.statusChanges, isEmpty);
      // The account is still active: the audit row is the whole record, and
      // it is not on this screen.
      expect(find.text('Active'), findsWidgets);
    });
  });

  group("§10.4's moderation history is two lists", () {
    testWidgets('the status trail renders, with its reason verbatim', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: _detail(
          status: 'restricted',
          restrictedUntil: '2026-09-01T00:00:00+05:00',
          history: const [
            {
              'fromStatus': 'active',
              'toStatus': 'restricted',
              'actorRole': 'admin',
              'reason': 'Three upheld complaints in a month',
              'createdAt': '2026-08-22T11:00:00+05:00',
            },
          ],
        ),
      );

      expect(find.text('Restricted until 2026-09-01'), findsOneWidget);
      expect(
        find.text('Three upheld complaints in a month'),
        findsOneWidget,
      );
      expect(find.text('By Administrator'), findsOneWidget);
      expect(find.text('2026-08-22'), findsOneWidget);
    });

    testWidgets('a row with no actor reads as the platform, not as blank', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: _detail(
          history: const [
            {
              'fromStatus': 'restricted',
              'toStatus': 'active',
              'actorRole': null,
              'reason': null,
              'createdAt': '2026-08-22T00:00:00+05:00',
            },
          ],
        ),
      );

      // BR-10's guard lifting an expired restriction writes a row with no
      // actor: the difference between a decision and a deadline.
      expect(
        find.text('By the platform, when the date passed'),
        findsOneWidget,
      );
    });

    testWidgets('a restriction with no end date says which it is', (
      tester,
    ) async {
      await pumpDetail(tester, detail: _detail(status: 'restricted'));

      expect(
        find.text('Restricted until an administrator lifts it'),
        findsOneWidget,
      );
    });

    testWidgets('complaints are listed, open and decided alike', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: _detail(
          complaints: const [
            {
              'id': 'cmp-1',
              'reason': 'Asked me to pay for the interview',
              'status': 'open',
              'createdAt': '2026-08-21T10:00:00+05:00',
            },
            {
              'id': 'cmp-2',
              'reason': 'Rude messages',
              'status': 'dismissed',
              'createdAt': '2026-07-02T10:00:00+05:00',
            },
          ],
        ),
      );

      // Both are below the fold of a lazy list. The first one joined them when
      // §10.5's wallet link landed above it — this account holds the employer
      // role, so it gets the link.
      await reveal(tester, find.text('Asked me to pay for the interview'));
      expect(find.text('Open'), findsOneWidget);

      await reveal(tester, find.text('Rude messages'));
      expect(find.text('Reviewed'), findsOneWidget);
    });

    testWidgets('a gone account is an outcome, not a failure', (tester) async {
      await pumpDetail(
        tester,
        error: const ApiException('Not found', statusCode: 404),
      );

      expect(find.text('This account is gone'), findsOneWidget);
      // 'Try again' is `commonRetry`. Asserting the wrong string here would
      // pass for the wrong reason — a retry that exists but is worded
      // differently.
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('the model reads what the server sends', () {
    test('a role this build does not know is dropped, not thrown on', () {
      final user = _user(roles: const ['candidate', 'recruiter']);

      // The server can grow a role before the app ships support for one, and
      // a list that died over a role name would be worse than a row listing
      // one fewer.
      expect(user.roles, hasLength(1));
    });

    test('every timestamp on these routes carries an offset', () {
      final user = _user(restrictedUntil: '2026-09-01T00:00:00+05:00');

      expect(user.createdAt.offset, const Duration(hours: 5));
      expect(user.restrictedUntil?.wallClock.day, 1);
      expect(user.lastLoginAt?.wallClock.hour, 18);
    });

    test('a null last login is a fact, not a missing field', () {
      expect(_user(lastLoginAt: null).lastLoginAt, isNull);
    });

    test('an unrecognised status reads as active rather than blanking', () {
      expect(UserAccountStatus.fromWire('suspended'), UserAccountStatus.active);
      expect(
        UserAccountStatus.fromWire('deletion_requested'),
        UserAccountStatus.deletionRequested,
      );
    });
  });
}
