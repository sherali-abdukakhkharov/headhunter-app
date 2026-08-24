/// What a tapped push actually opens (§9.2).
///
/// The case worth the harness is the **cold start**: a tap on a notification
/// for a closed app is delivered once, as launch state, at a moment when the
/// session is still `SessionUnknown` and the router is on the splash screen.
/// Navigating then loses the destination — the redirect chain resolves a frame
/// later and moves to the shell's home over the top of it — and the symptom is
/// "tapping a notification just opens the app", which reads as a platform
/// quirk rather than as a bug anybody put there.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/router/app_router.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_messaging.dart';
import 'package:jobbridge_app/src/features/notifications/domain/app_notification.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/push_host.dart';

/// A session the test moves by hand, so the launch tap can be observed both
/// before and after the session has an answer.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;

  @override
  SessionState build() => _initial;

  /// The answer the session has arrived at. Setting it is how a test releases
  /// the launch tap that has been held since the app started.
  SessionState get resolved => state;
  set resolved(SessionState next) => state = next;
}

class _FakeMessaging implements PushMessaging {
  PushPayload? launchTap;
  final _opened = StreamController<PushPayload>.broadcast();
  final _foreground = StreamController<PushPayload>.broadcast();

  void tap(PushPayload payload) => _opened.add(payload);
  void arrive(PushPayload payload) => _foreground.add(payload);

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> tokenRefreshes() => const Stream.empty();

  @override
  Stream<PushPayload> opened() => _opened.stream;

  @override
  Future<PushPayload?> initialMessage() async => launchTap;

  @override
  Stream<PushPayload> foregroundMessages() => _foreground.stream;

  Future<void> close() async {
    await _opened.close();
    await _foreground.close();
  }
}

class _FakeRepository implements NotificationRepository {
  final read = <String>[];
  int unreadReads = 0;

  @override
  Future<void> markRead(String id) async => read.add(id);

  @override
  Future<int> unreadCount() async {
    unreadReads++;
    return 3;
  }

  @override
  Future<List<AppNotification>> list({
    bool unreadOnly = false,
    int offset = 0,
  }) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used here');
}

/// Answers every request with a 503 rather than opening a socket.
///
/// A shell tab is a real screen and fetches the moment it mounts, so without
/// this the suite would leave a request in flight and report it as a pending
/// timer pointing at PushHost.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('{}', 503);

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeMessaging messaging;
  late _FakeRepository repository;

  setUp(() {
    messaging = _FakeMessaging();
    repository = _FakeRepository();
  });

  tearDown(() async => messaging.close());

  /// Enough frames for a redirect and the page transition it schedules.
  /// Deliberately not `pumpAndSettle`: a destination screen that animates keeps
  /// the tree from going quiet, and the timeout looks like a stuck redirect.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<({GoRouter router, _FakeSessionController session})> pump(
    WidgetTester tester, {
    required SessionState session,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final controller = _FakeSessionController(session);
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sessionControllerProvider.overrideWith(() => controller),
        pushMessagingProvider.overrideWithValue(messaging),
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    container.read(dioProvider).httpClientAdapter = _OfflineAdapter();
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppL10n.supportedLocales,
          routerConfig: router,
          // The same position as app.dart: below Localizations, so the channel
          // name follows the interface variant rather than the phone locale.
          builder: (context, child) =>
              PushHost(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
    await settle(tester);

    // Tearing the tree down inside the test body, where there is still a frame
    // for the screens' auto-dispose providers to unmount against.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });

    return (router: router, session: controller);
  }

  String locationOf(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  group('a tap that launched the app', () {
    testWidgets('waits for the session rather than losing to the redirect', (
      tester,
    ) async {
      messaging.launchTap = const PushPayload(
        event: 'message_received',
        notificationId: 'ntf-1',
        targetType: 'conversation',
        targetId: 'cnv-7',
      );

      final app = await pump(tester, session: const SessionUnknown());

      // Still restoring: the router is holding on splash, and anything sent
      // now would be undone by the redirect that follows.
      expect(locationOf(app.router), Routes.splash);

      app.session.resolved = const SessionActive(
        roles: {AppRole.candidate},
        activeRole: AppRole.candidate,
      );
      await settle(tester);

      expect(locationOf(app.router), '${Routes.candidateMessages}/cnv-7');
      // Tapping is having seen it, so the badge does not still count something
      // the user is looking at.
      expect(repository.read, ['ntf-1']);
    });

    testWidgets('is dropped when the answer is "signed out"', (tester) async {
      messaging.launchTap = const PushPayload(
        event: 'message_received',
        targetType: 'conversation',
        targetId: 'cnv-7',
      );

      final app = await pump(tester, session: const SessionUnknown());
      app.session.resolved = const SessionUnauthenticated();
      await settle(tester);

      // Not held for a later sign-in: the notification is still in the centre,
      // which is where somebody who has just signed in will look.
      expect(locationOf(app.router), Routes.onboarding);
    });
  });

  group('a tap while the app is running', () {
    testWidgets('opens what the notification is about', (tester) async {
      final app = await pump(
        tester,
        session: const SessionActive(
          roles: {AppRole.employer},
          activeRole: AppRole.employer,
        ),
      );

      messaging.tap(
        const PushPayload(
          event: 'vacancy_approved',
          notificationId: 'ntf-2',
          targetType: 'vacancy',
          targetId: 'vac-3',
        ),
      );
      await settle(tester);

      expect(locationOf(app.router), '${Routes.employerVacancies}/vac-3');
    });

    testWidgets('a notice about the account is read, and leads nowhere', (
      tester,
    ) async {
      final app = await pump(
        tester,
        session: const SessionActive(
          roles: {AppRole.candidate},
          activeRole: AppRole.candidate,
        ),
      );
      final before = locationOf(app.router);

      // BR-10's restriction notice: the explanation *is* the notification, so
      // there is nothing to open and the app must not invent somewhere to go.
      messaging.tap(
        const PushPayload(
          event: 'account_restricted',
          notificationId: 'ntf-3',
          targetType: 'user',
          targetId: 'usr-1',
        ),
      );
      await settle(tester);

      expect(locationOf(app.router), before);
      expect(repository.read, ['ntf-3']);
    });
  });

  group('a push that arrives while the app is open', () {
    testWidgets('refreshes the badge, which Android will not', (tester) async {
      await pump(
        tester,
        session: const SessionActive(
          roles: {AppRole.candidate},
          activeRole: AppRole.candidate,
        ),
      );
      final before = repository.unreadReads;

      // Android displays nothing when the app is in front, so without this the
      // count would sit stale until something else refetched — and a count that
      // lags is worse than none, because it is read as authoritative.
      messaging.arrive(
        const PushPayload(event: 'message_received', notificationId: 'ntf-4'),
      );
      await settle(tester);

      expect(repository.unreadReads, greaterThan(before));
    });
  });
}
