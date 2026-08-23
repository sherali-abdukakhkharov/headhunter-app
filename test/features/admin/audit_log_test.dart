import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/audit_entry.dart';
import 'package:jobbridge_app/src/features/admin/presentation/audit_log_screen.dart';

import 'admin_fake.dart';

/// §10.4's immutable log.
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({this.pages = const [], this.failure});

  List<List<AuditEntry>> pages;
  ApiException? failure;

  /// Every request, as the query the server sees, with the offset asked for.
  final requests = <({Map<String, dynamic> query, int offset})>[];

  @override
  Future<List<AuditEntry>> auditLog(AuditQuery query, {int offset = 0}) async {
    if (failure case final error?) throw error;
    requests.add((query: query.toQuery(), offset: offset));

    final index = requests.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  // Every other §10 route refuses through [FakeAdminBase]: this screen reads
  // one endpoint and nothing else.
}

AuditEntry _entry({
  String id = 'aud-1',
  String actorUserId = 'usr-admin',
  String action = 'user.blocked',
  String targetType = 'user',
  String? targetId = 'usr-1',
  String? reason = 'Asked candidates for money',
  Map<String, dynamic>? details,
  String createdAt = '2026-08-22T14:05:00+05:00',
}) => AuditEntry.fromJson({
  'id': id,
  'actorUserId': actorUserId,
  'action': action,
  'targetType': targetType,
  'targetId': targetId,
  'reason': reason,
  'details': details,
  'createdAt': createdAt,
});

void main() {
  ({Widget widget, GoRouter router}) routed(
    _FakeAdmin fake, {
    String at = Routes.adminAudit,
  }) {
    final router = GoRouter(
      initialLocation: at,
      routes: [
        GoRoute(
          path: Routes.adminUsers,
          builder: (context, state) => const SizedBox.shrink(),
          routes: [
            // The same order the app registers them in, and for the same
            // reason — `:id` would otherwise match the literal `audit`. That
            // the *app's* order is right is asserted against the real router
            // in test/core/router/app_router_test.dart; here it only has to
            // resolve so the screen can be driven.
            GoRoute(
              path: 'audit',
              builder: (context, state) => AuditLogScreen(
                query: AuditQuery.fromWire(
                  actorUserId:
                      state.uri.queryParameters[Routes.adminAuditActorParam],
                  targetType: state
                      .uri
                      .queryParameters[Routes.adminAuditTargetTypeParam],
                  targetId: state
                      .uri
                      .queryParameters[Routes.adminAuditTargetIdParam],
                ),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  Text('account ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );

    return (
      widget: ProviderScope(
        // Riverpod 3 retries a throwing provider by default and reports
        // `AsyncLoading` while it does, so a failure would render as a
        // spinner. The app disables it in `main.dart`; the tests must match.
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

  Future<({_FakeAdmin fake, GoRouter router})> pump(
    WidgetTester tester, {
    List<List<AuditEntry>> pages = const [],
    ApiException? failure,
    String at = Routes.adminAudit,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(pages: pages, failure: failure);
    final app = routed(fake, at: at);
    await tester.pumpWidget(app.widget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return (fake: fake, router: app.router);
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  group('a row says what was done, when, why and by whom', () {
    testWidgets('the four facts render', (tester) async {
      await pump(
        tester,
        pages: [
          [_entry()],
        ],
      );

      expect(find.text('User blocked'), findsOneWidget);
      // Date **and** time: a run of actions on one busy day is the ordinary
      // case, and a log that says only the day cannot be read against
      // anything else that happened.
      expect(find.text('2026-08-22 14:05'), findsOneWidget);
      expect(find.text('Asked candidates for money'), findsOneWidget);
      expect(find.text('usr-admin'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('an action this build has never heard of shows its code', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [_entry(action: 'wallet.refunded')],
        ],
      );

      // The set grows server-side. A dotted code is a stable identifier
      // somebody can search the backend for; "unknown action" is not, and a
      // row that did not appear at all would make the log lie.
      expect(find.text('wallet.refunded'), findsOneWidget);
    });

    testWidgets('the details bag is text, keys and all', (tester) async {
      await pump(
        tester,
        pages: [
          [
            _entry(
              details: const {
                'from': 'active',
                'to': 'blocked',
                'restrictedUntil': '2026-09-01T00:00:00+05:00',
              },
            ),
          ],
        ],
      );

      // Rendered, never parsed: the keys differ per action, are enumerated
      // nowhere, and a client that read one by name would be wrong for the
      // next action added.
      expect(find.text('from: active'), findsOneWidget);
      expect(find.text('to: blocked'), findsOneWidget);
      expect(
        find.text('restrictedUntil: 2026-09-01T00:00:00+05:00'),
        findsOneWidget,
      );
    });

    testWidgets('a nested value is JSON, not Dart map notation', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [
            _entry(
              details: const {
                'labels': {'ru': 'Сварщик'},
                'merged': 3,
                'active': false,
              },
            ),
          ],
        ],
      );

      // `{"ru":"Сварщик"}` can be pasted back into a query; Dart's
      // `{ru: Сварщик}` is a notation that exists nowhere else in the system.
      expect(find.text('labels: {"ru":"Сварщик"}'), findsOneWidget);
      expect(find.text('merged: 3'), findsOneWidget);
      expect(find.text('active: false'), findsOneWidget);
    });

    testWidgets('a row with no reason and no details still renders', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [
            // `details` is already null by default; the point of this row is
            // that BR-10's guard writes one with neither.
            _entry(action: 'user.restriction_expired', reason: null),
          ],
        ],
      );

      // BR-10's guard writes this one, and it has neither.
      expect(find.text('Restriction expired'), findsOneWidget);
      expect(find.text('What changed'), findsNothing);
    });
  });

  group('a uuid is a way in, not a name', () {
    testWidgets('the actor opens that administrator account', (tester) async {
      final app = await pump(
        tester,
        pages: [
          [_entry()],
        ],
      );

      await tester.tap(find.text('usr-admin'));
      await tester.pumpAndSettle();

      // Nothing resolves an id to a name — that would be a request per
      // distinct actor, each writing a §11.1 access log line, to obtain a
      // string. One deliberate tap costs one deliberate read instead.
      expect(
        app.router.routerDelegate.currentConfiguration.uri.path,
        Routes.adminUserFor('usr-admin'),
      );
    });

    testWidgets('a user target opens the account it names', (tester) async {
      final app = await pump(
        tester,
        pages: [
          [_entry()],
        ],
      );

      await tester.tap(find.text('usr-1'));
      await tester.pumpAndSettle();

      expect(
        app.router.routerDelegate.currentConfiguration.uri.path,
        Routes.adminUserFor('usr-1'),
      );
    });

    testWidgets('a vacancy target leads nowhere, and says so', (tester) async {
      await pump(
        tester,
        pages: [
          [
            _entry(
              action: 'vacancy.moderated',
              targetType: 'vacancy',
              targetId: 'vac-1',
            ),
          ],
        ],
      );

      expect(find.text('Vacancy'), findsOneWidget);
      expect(find.text('vac-1'), findsOneWidget);

      // One chevron on the card, not two: the actor's. A vacancy id has no
      // screen that would accept it, and an affordance that opened one unable
      // to show the object would be worse than none.
      final chevrons = find.byWidgetPredicate(
        (w) => w is HhIcon && w.path == HhIconPath.chevronRight,
      );
      expect(chevrons, findsOneWidget);
    });

    testWidgets('a target kind added later still draws a row', (tester) async {
      await pump(
        tester,
        pages: [
          [_entry(targetType: 'payment', targetId: 'pay-1')],
        ],
      );

      // It is a record of something that happened. It can simply not be named.
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('pay-1'), findsOneWidget);
    });
  });

  group('the two questions §10.4 asks of the log', () {
    testWidgets('an unfiltered log asks for no filter', (tester) async {
      final app = await pump(tester);

      expect(app.fake.requests.single.query, isEmpty);
      expect(find.text('Only this administrator'), findsNothing);
      expect(find.text('Show the whole log'), findsNothing);
    });

    testWidgets('by actor', (tester) async {
      final app = await pump(
        tester,
        at: Routes.adminAuditByActor('usr-admin'),
        pages: [
          [_entry()],
        ],
      );

      expect(app.fake.requests.single.query, {'actorUserId': 'usr-admin'});
      expect(find.text('Only this administrator'), findsOneWidget);
    });

    testWidgets('by target', (tester) async {
      final app = await pump(
        tester,
        at: Routes.adminAuditForTarget('user', 'usr-1'),
        pages: [
          [_entry()],
        ],
      );

      expect(app.fake.requests.single.query, {
        'targetType': 'user',
        'targetId': 'usr-1',
      });
      expect(find.text('Only this record'), findsOneWidget);
    });

    testWidgets('and the way back to the whole log', (tester) async {
      final app = await pump(
        tester,
        at: Routes.adminAuditByActor('usr-admin'),
        pages: [
          [_entry()],
          [_entry()],
        ],
      );

      await tester.tap(find.text('Show the whole log'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // A second question, not a re-run of the first: the provider is keyed by
      // the query, so this is a different family member.
      expect(app.fake.requests.last.query, isEmpty);
      expect(find.text('Show the whole log'), findsNothing);
    });

    test('a target type this build cannot name is dropped, not forwarded', () {
      final query = AuditQuery.fromWire(targetType: 'payment', targetId: 'p-1');

      // A mistyped deep link should show the log, not earn a 400 from the DTO
      // for a filter value the server does not accept.
      expect(query.targetType, isNull);
      expect(query.toQuery(), {'targetId': 'p-1'});
    });

    test('two identical questions are the same provider', () {
      // The family key. Two questions asked in one session must not overwrite
      // each other, and a question that is equal is the same question.
      expect(
        const AuditQuery(actorUserId: 'a'),
        const AuditQuery(actorUserId: 'a'),
      );
      expect(
        const AuditQuery(actorUserId: 'a'),
        isNot(const AuditQuery(actorUserId: 'b')),
      );
      expect(
        const AuditQuery(actorUserId: 'a').hashCode,
        const AuditQuery(actorUserId: 'a').hashCode,
      );
    });
  });

  group('the states around the list', () {
    testWidgets('an empty log and an empty slice are different sentences', (
      tester,
    ) async {
      await pump(tester);
      expect(
        find.textContaining('An entry appears here whenever'),
        findsOneWidget,
      );

      await pump(tester, at: Routes.adminAuditByActor('usr-admin'));
      // The log is not empty here; this slice of it is.
      expect(
        find.textContaining('Nothing has been recorded for this one'),
        findsOneWidget,
      );
    });

    testWidgets('the immutability note is on a log that has rows', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [_entry()],
        ],
      );

      expect(
        find.textContaining('Nothing here can be changed or removed'),
        findsOneWidget,
      );
    });

    testWidgets('a failure is terminal and offers a retry', (tester) async {
      await pump(tester, failure: const ApiException('Service unavailable'));

      expect(find.text('Service unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('a full page pages, and asks for the next offset', (
      tester,
    ) async {
      final app = await pump(
        tester,
        pages: [
          [
            for (var i = 0; i < adminPageSize; i++)
              _entry(id: 'aud-$i', targetId: 'usr-$i'),
          ],
          [_entry(id: 'aud-last', targetId: 'usr-last')],
        ],
      );

      await reveal(tester, find.text('Show more'));
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(app.fake.requests.map((r) => r.offset).toList(), [
        0,
        adminPageSize,
      ]);
      // The short second page ends the paging.
      expect(find.text('Show more'), findsNothing);
    });
  });
}
