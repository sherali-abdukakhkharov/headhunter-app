import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/account/data/account_repository.dart';
import 'package:jobbridge_app/src/features/account/domain/user_session.dart';
import 'package:jobbridge_app/src/features/account/presentation/account_screen.dart';

/// Records what the screen asked the server to do.
class _FakeAccount implements AccountRepository {
  _FakeAccount({this.items = const [], this.failure});

  List<UserSession> items;
  ApiException? failure;

  final revoked = <String>[];
  int revokedAll = 0;
  int deletionRequests = 0;

  @override
  Future<List<UserSession>> sessions() async {
    if (failure case final f?) throw f;
    return items;
  }

  @override
  Future<void> revokeSession(String id) async {
    revoked.add(id);
  }

  @override
  Future<void> revokeAll() async {
    revokedAll++;
  }

  @override
  Future<ZonedTimestamp> requestDeletion({String? reason}) async {
    deletionRequests++;
    return ZonedTimestamp.parse('2026-08-20T10:00:00+05:00');
  }
}

UserSession _session({
  required String id,
  bool current = false,
  String? deviceName = 'Pixel 8',
  String? platform = 'Android',
}) => UserSession.fromJson({
  'id': id,
  'createdAt': '2026-08-12T14:00:00+05:00',
  'lastUsedAt': '2026-08-20T09:30:00+05:00',
  'expiresAt': '2026-09-11T14:00:00+05:00',
  'isCurrent': current,
  'deviceName': ?deviceName,
  'platform': ?platform,
});

void main() {
  Future<_FakeAccount> pump(
    WidgetTester tester, {
    List<UserSession> items = const [],
    ApiException? failure,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAccount(items: items, failure: failure);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [accountRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const AccountScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  /// Taps a control and confirms the dialog it opens.
  Future<void> confirm(
    WidgetTester tester,
    Finder control,
    String action,
  ) async {
    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(HhButton, action).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('§4.2: the device list', () {
    testWidgets('names each device and marks the current one', (tester) async {
      await pump(
        tester,
        items: [
          _session(id: 'a', current: true),
          _session(id: 'b', deviceName: 'Redmi Note 12'),
        ],
      );

      expect(find.text('Pixel 8'), findsOneWidget);
      expect(find.text('Redmi Note 12'), findsOneWidget);
      // The server decides which row is current, and it is the one field the
      // screen must not get wrong: revoking that row signs the reader out.
      expect(find.text('This device'), findsOneWidget);
    });

    testWidgets('a session with no name falls back to its platform', (
      tester,
    ) async {
      await pump(tester, items: [_session(id: 'a', deviceName: null)]);

      // "Android" still tells somebody something.
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('Unnamed device'), findsNothing);
    });

    testWidgets('a session with neither is named rather than left blank', (
      tester,
    ) async {
      await pump(
        tester,
        items: [_session(id: 'a', deviceName: null, platform: null)],
      );

      // An older build sent neither field. Three empty lines read as a
      // rendering failure rather than as missing data.
      expect(find.text('Unnamed device'), findsOneWidget);
    });

    testWidgets('the timestamp is the platform wall clock, not converted', (
      tester,
    ) async {
      await pump(tester, items: [_session(id: 'a')]);

      // 09:30 as recorded. `.toLocal()` would re-date a session opened abroad
      // in the reader's zone (§8.3).
      expect(find.textContaining('2026-08-20 09:30'), findsOneWidget);
    });
  });

  group('ending a session is confirmed, and says which one', () {
    testWidgets('revoking another device asks first, then calls the server', (
      tester,
    ) async {
      final fake = await pump(tester, items: [_session(id: 'b')]);

      await tester.tap(find.text('End session'));
      await tester.pumpAndSettle();

      // Nothing happened yet: every action here is irreversible from the
      // client, so none of them is one tap.
      expect(fake.revoked, isEmpty);
      expect(find.text('End this session?'), findsOneWidget);

      await tester.tap(find.widgetWithText(HhButton, 'End session').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.revoked, ['b']);
    });

    testWidgets('revoking this device is worded as signing out', (
      tester,
    ) async {
      await pump(tester, items: [_session(id: 'a', current: true)]);

      await tester.tap(find.text('End session'));
      await tester.pumpAndSettle();

      // A reader who taps it should not be surprised by what happens next.
      expect(find.text('Sign out of this device?'), findsOneWidget);
      expect(
        find.textContaining('You will be signed out now'),
        findsOneWidget,
      );
    });

    testWidgets('cancelling changes nothing', (tester) async {
      final fake = await pump(tester, items: [_session(id: 'b')]);

      await tester.tap(find.text('End session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fake.revoked, isEmpty);
    });

    testWidgets('terminate-all says it includes this phone', (tester) async {
      await pump(
        tester,
        items: [_session(id: 'a', current: true), _session(id: 'b')],
      );

      await tester.tap(find.text('End all sessions'));
      await tester.pumpAndSettle();

      // "Every device" is a phrase most people read as "every *other* device",
      // and the surprise would arrive after the action rather than before it.
      expect(find.textContaining('including this one'), findsOneWidget);
    });

    testWidgets('terminate-all is not offered for a single session', (
      tester,
    ) async {
      await pump(tester, items: [_session(id: 'a', current: true)]);

      // With one device it is the Sign out button under a longer name.
      expect(find.text('End all sessions'), findsNothing);
      expect(find.text('Sign out'), findsOneWidget);
    });
  });

  group('BR-14: deletion is requested, not performed', () {
    testWidgets('the action says request, and warns before it', (tester) async {
      await pump(tester, items: [_session(id: 'a', current: true)]);

      // "Request", because the account moves to `deletion_requested` and
      // nothing is purged as the button is released.
      expect(find.text('Request deletion'), findsOneWidget);
      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });

    testWidgets('it is confirmed, then recorded without inventing a date', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        items: [_session(id: 'a', current: true)],
      );

      await confirm(
        tester,
        find.text('Request deletion'),
        'Request deletion',
      );

      expect(fake.deletionRequests, 1);
      expect(find.text('Deletion requested'), findsOneWidget);
      // The server sends `purgeAfter: null` while the retention period is an
      // open client question, so no date may appear — a made-up one is the kind
      // of promise that ends up in a complaint.
      expect(find.textContaining('Support can tell you'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('a failed list still lets somebody sign out', (tester) async {
      await pump(tester, failure: const ApiException('Server unreachable'));

      // A screen that can only fail traps whoever came here to leave — and
      // signing out of this device needs no list.
      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
