import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
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
  @override
  Future<String?> accountLocale() =>
      throw UnsupportedError('This suite must not read the account language.');

  @override
  Future<void> updateLocale(String tag) =>
      throw UnsupportedError('This suite must not write the account language.');

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
    Set<AppRole> roles = const {AppRole.candidate},
  }) async {
    // Tall enough for the whole screen: a `ListView` builds only the children
    // in its viewport, and the language and role sections pushed the deletion
    // block off a phone-sized one.
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAccount(items: items, failure: failure);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          accountRepositoryProvider.overrideWithValue(fake),
          sessionControllerProvider.overrideWith(() => _Session(roles)),
        ],
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
  group('§3.2 language', () {
    testWidgets('is changeable here, in the words of each', (
      tester,
    ) async {
      await pump(tester, items: [_session(id: 's-1')]);

      // It was selectable on the sign-in screen and nowhere else, so anybody
      // who picked wrong once had no way back short of reinstalling.
      expect(find.text('Language'), findsOneWidget);

      // nativeName, never a translated language name: a picker rendering every
      // option in the *current* language is unusable to the one person who
      // needs it — somebody who cannot read the current language.
      expect(find.text('Ўзбекча (Кирилл)'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
      expect(find.text('Uzbek (Cyrillic)'), findsNothing);
      expect(find.text('Russian'), findsNothing);
    });

    testWidgets('says the choice is stored on the account', (tester) async {
      await pump(tester, items: [_session(id: 's-1')]);

      // §3.2: it follows the user to their other devices, which is worth
      // saying — otherwise changing it here reads as a setting on this phone.
      expect(
        find.textContaining('follows you to your other devices'),
        findsOneWidget,
      );
    });
  });

  group('§2.3 role switching', () {
    testWidgets('is not offered to an account with one role', (tester) async {
      await pump(tester, items: [_session(id: 's-1')]);

      // A switcher with one option is a control that does nothing.
      expect(find.text('Role'), findsNothing);
    });

    testWidgets('lists every granted role and marks the one in use', (
      tester,
    ) async {
      await pump(
        tester,
        items: [_session(id: 's-1')],
        roles: {AppRole.candidate, AppRole.employer},
      );

      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Candidate'), findsOneWidget);
      expect(find.text('Employer'), findsOneWidget);

      // A word, never colour alone.
      expect(find.text('In use'), findsOneWidget);

      // The role that is not granted is absent rather than disabled: this is
      // the product surface, not the dev screen, and an administrator row on a
      // candidate's account would be a question nobody can answer.
      expect(find.text('Administrator'), findsNothing);
    });

    testWidgets('the role in use is not a control', (tester) async {
      await pump(
        tester,
        items: [_session(id: 's-1')],
        roles: {AppRole.candidate, AppRole.employer},
      );

      final rows = tester.widgetList<HhCard>(
        find.ancestor(
          of: find.text('In use'),
          matching: find.byType(HhCard),
        ),
      );

      // Pressing it would switch to the role already active, which is a no-op
      // that navigates — the worst kind, because it looks like it worked.
      expect(rows.single.onTap, isNull);
    });
  });

}

/// A session holding exactly the roles a case needs.
class _Session extends SessionController {
  _Session(this.roles);

  final Set<AppRole> roles;

  @override
  SessionState build() => SessionActive(roles: roles);
}
