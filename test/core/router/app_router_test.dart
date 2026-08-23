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
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/router/app_router.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/core/router/shell_tabs.dart';
import 'package:jobbridge_app/src/features/admin/presentation/audit_log_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/user_detail_screen.dart';
import 'package:jobbridge_app/src/features/auth/domain/otp_challenge.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';
import 'package:jobbridge_app/src/features/auth/presentation/otp_verification_screen.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/shell/presentation/shell_placeholder_screen.dart';
import 'package:jobbridge_app/src/features/shell/presentation/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A session controller that starts in a state chosen by the test.
///
/// Overriding the whole controller rather than seeding preferences: the real
/// `build` restores asynchronously, so a test that only wrote a preference
/// would race the first redirect - and the flake would look like a router bug.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;

  @override
  SessionState build() => _initial;

  /// Records role switches the *router* asked for, which is how the deep-link
  /// rule is observed: the redirect must activate a granted role rather than
  /// bouncing the link.
  final switched = <AppRole>[];

  @override
  Future<void> switchRole(AppRole role) async {
    switched.add(role);
    final current = state;
    if (current is SessionActive && current.can(role)) {
      state = current.copyWith(activeRole: role);
    }
  }
}

/// Advances enough frames for a redirect and the page transition it triggers,
/// **without** `pumpAndSettle`.
///
/// `pumpAndSettle` cannot be used here: a page transition plus whatever a
/// destination screen animates can keep the tree from going quiet, and the
/// timeout looks exactly like a stuck redirect — a misleading way to spend
/// twenty minutes.
///
/// Two long pumps rather than one: a deep link into a non-active role converges
/// over *two* passes - the first allows the navigation and schedules the role
/// switch, the second runs after that write fires the refresh listenable.
/// Answers every request with a 503, immediately and without a socket.
///
/// **A routing test must not reach the network.** Shell tabs are real screens
/// now, and a real screen fetches the moment it mounts — so without this the
/// suite opens a connection per destination it walks through, and whichever
/// request is still in flight when the test ends is reported as a pending
/// timer, pointing at the router rather than at the screen.
///
/// 503 rather than a canned body: every screen here is expected to render its
/// error arm, which is a state, not a failure of this test.
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

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Tears the tree down **inside the test body**, where there is still a frame.
///
/// A screen that watches an auto-dispose provider schedules that provider's
/// disposal as it unmounts, and a container built outside a `ProviderScope` —
/// which is what [UncontrolledProviderScope] means here — has no widget vsync
/// to hang that on, so it uses a zero-duration timer instead. Left to the
/// framework's own teardown there is no frame left to run the timer on, and
/// nothing registered with `addTearDown` can supply one either: those callbacks
/// run after `fakeAsync` has finished, so a pump there cannot reach the timer.
///
/// The failure reads as "pending timers" attributed to the router, which is
/// where the tree was built rather than where the provider was watched. Any
/// test that ends with a **fetching** shell screen mounted needs this — in
/// practice the ones that walk every role, since the administrator's shell is
/// last in [AppRole.values] and its dashboard is real.
Future<void> _unmountTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Two frames, not one: disposing one provider un-listens the next, so the
  // scheduler queues a second timer while running the first.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    // The real controller reads preferences on some paths; an in-memory store
    // keeps that from touching the platform channel.
    SharedPreferences.setMockInitialValues({});
  });

  /// Pumps the app with [session] and navigates to [initialLocation], returning
  /// the location the redirect chain settled on.
  Future<
    ({
      String location,
      _FakeSessionController controller,
      GoRouter router,
    })
  >
  settle(
    WidgetTester tester,
    SessionState session, {
    String? initialLocation,
  }) async {
    final controller = _FakeSessionController(session);
    final container = ProviderContainer(
      // Matches main.dart: an error is terminal, not an endlessly retried
      // AsyncLoading that carries it.
      retry: (_, _) => null,
      overrides: [
        sessionControllerProvider.overrideWith(() => controller),
      ],
    );
    // The real client with its real interceptors, minus the socket — see
    // [_OfflineAdapter].
    container.read(dioProvider).httpClientAdapter = _OfflineAdapter();
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: HhTheme.light,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocale.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await _pumpRoute(tester);

    if (initialLocation != null) {
      router.go(initialLocation);
      await _pumpRoute(tester);
    }

    return (
      location: router.routerDelegate.currentConfiguration.uri.path,
      controller: controller,
      router: router,
    );
  }

  String locationOf(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.path;

  group('redirect chain', () {
    testWidgets('an unrestored session is held on the splash', (tester) async {
      // The cold-start flash: treating "unknown" as "signed out" shows a
      // signed-in user onboarding for a frame or two.
      final result = await settle(tester, const SessionUnknown());
      expect(result.location, Routes.splash);
      // The screen itself, not a spinner it happens to contain. It used to
      // contain one; the design forbids it on the launch screen, and a test
      // anchored on an incidental child fails when the screen is redrawn
      // correctly.
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('an unrestored session cannot be navigated past', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionUnknown(),
        initialLocation: Routes.candidateHome,
      );
      expect(result.location, Routes.splash);
    });

    testWidgets('no session goes to onboarding', (tester) async {
      final result = await settle(tester, const SessionUnauthenticated());
      expect(result.location, Routes.onboarding);
    });

    testWidgets('no session stays on the code screen (§4.1 step 2)', (
      tester,
    ) async {
      // Sign-in is two screens and the second is reached *while still
      // unauthenticated*. A redirect rule written as `location == onboarding`
      // would bounce the user off code entry the instant they arrived, making
      // sign-in impossible - so this asserts the `startsWith` instead.
      final result = await settle(tester, const SessionUnauthenticated());

      result.router.go(
        Routes.otpVerification,
        extra: OtpVerificationArgs(
          phone: UzPhone.parse('901234567'),
          challenge: OtpChallenge.fromJson(const {
            'expiresAt': '2026-08-05T12:05:00+05:00',
            'resendAvailableAt': '2026-08-05T12:01:00+05:00',
          }),
        ),
      );
      await _pumpRoute(tester);

      expect(locationOf(result.router), Routes.otpVerification);
    });

    testWidgets('the code screen bounces back when it has no phone', (
      tester,
    ) async {
      // A hot restart on this screen, or a deep link into it, arrives with no
      // `extra`. There is no code pending for a number the screen does not
      // know, so the only honest destination is the start of the flow.
      final result = await settle(
        tester,
        const SessionUnauthenticated(),
        initialLocation: Routes.otpVerification,
      );

      expect(result.location, Routes.onboarding);
    });

    testWidgets('no session cannot reach a shell', (tester) async {
      final result = await settle(
        tester,
        const SessionUnauthenticated(),
        initialLocation: Routes.employerVacancies,
      );
      expect(result.location, Routes.onboarding);
    });

    testWidgets('an account with no role goes to role selection', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionActive(roles: {}),
      );
      expect(result.location, Routes.roleSelection);
    });

    testWidgets('a blocked account goes to the notice (BR-10)', (tester) async {
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate},
          status: AccountStatus.blocked,
        ),
      );
      expect(result.location, Routes.blocked);
    });

    testWidgets('blocked outranks role selection', (tester) async {
      // A blocked account must not be walked through choosing a role it cannot
      // use. Order in the chain is the whole behaviour here.
      final result = await settle(
        tester,
        const SessionActive(roles: {}, status: AccountStatus.blocked),
      );
      expect(result.location, Routes.blocked);
    });

    testWidgets('a blocked account cannot navigate into a shell', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate},
          status: AccountStatus.blocked,
        ),
        initialLocation: Routes.candidateHome,
      );
      expect(result.location, Routes.blocked);
    });

    testWidgets('a restricted account is NOT redirected', (tester) async {
      // Deliberate: `restricted` withholds specific actions, and bouncing the
      // user out of the whole app tells them less than blocking the one button
      // they pressed. If this ever starts failing, someone has collapsed
      // restricted and blocked into one branch.
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate},
          status: AccountStatus.restricted,
        ),
      );
      expect(result.location, Routes.candidateHome);
    });

    testWidgets('each role lands in its own shell home', (tester) async {
      for (final role in AppRole.values) {
        final result = await settle(tester, SessionActive(roles: {role}));
        expect(result.location, Routes.homeFor(role), reason: role.name);
      }
      await _unmountTree(tester);
    });

    testWidgets('a path for an ungranted role bounces to the own shell', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionActive(roles: {AppRole.candidate}),
        initialLocation: Routes.adminUsers,
      );
      expect(result.location, Routes.candidateHome);
      // `candidate` *is* activated on arrival - activeRole was unset and the
      // user is now in that shell, so recording it is what makes a relaunch
      // return there. The invariant is narrower and it is the one that matters:
      // the role the account does not hold is never activated, however the user
      // arrived at its path.
      expect(
        result.controller.switched,
        isNot(contains(AppRole.admin)),
        reason: 'an ungranted role must never become active',
      );
    });

    testWidgets('a deep link into a granted role activates it', (tester) async {
      // ARCHITECTURE.md §3: the destination decides the role. A user holding
      // both roles who opens an employer link must arrive there, not be sent
      // back to whichever shell they were last in.
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate, AppRole.employer},
          activeRole: AppRole.candidate,
        ),
        initialLocation: Routes.employerCandidates,
      );

      expect(result.location, Routes.employerCandidates);
      expect(result.controller.switched, [AppRole.employer]);
    });

    testWidgets('switching role alone does NOT move shells', (tester) async {
      // Found on a device, missed by every other test here. After
      // switchRole(employer) the location is still /candidate/home, so the
      // deep-link rule reads that location and re-activates candidate - the
      // switch appears to do nothing.
      //
      // This asserts the behaviour, not the bug: switchRole is state-only by
      // design, and `switchRoleAndGo` is what pairs it with a destination.
      // If someone later makes the redirect chase activeRole instead, this test
      // fails and points at role_navigation.dart for the reason not to.
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate, AppRole.employer},
          activeRole: AppRole.candidate,
        ),
      );
      expect(result.location, Routes.candidateHome);

      await result.controller.switchRole(AppRole.employer);
      await _pumpRoute(tester);

      expect(
        locationOf(result.router),
        Routes.candidateHome,
        reason: 'state changed, but the location still decides the shell',
      );
    });

    testWidgets('switching role and navigating moves shells', (tester) async {
      // The supported pairing, exactly as `switchRoleAndGo` performs it: set
      // the state, then state the destination.
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate, AppRole.employer},
          activeRole: AppRole.candidate,
        ),
      );

      await result.controller.switchRole(AppRole.employer);
      result.router.go(Routes.homeFor(AppRole.employer));
      await _pumpRoute(tester);

      expect(locationOf(result.router), Routes.employerHome);

      final context = tester.element(find.byType(HhBottomNav));
      final l10n = AppL10n.of(context);
      expect(find.text(l10n.navCandidates), findsOneWidget);
      expect(
        find.text(l10n.navApplications),
        findsNothing,
        reason: 'the candidate shell must be gone, not merely behind',
      );
    });

    testWidgets('a stale active role falls back to a granted one', (
      tester,
    ) async {
      // activeRole is persisted locally, roles come from the server. A revoked
      // role must not leave the user in a shell they no longer hold.
      final result = await settle(
        tester,
        const SessionActive(
          roles: {AppRole.candidate},
          activeRole: AppRole.employer,
        ),
      );
      expect(result.location, Routes.candidateHome);
    });
  });

  group('role shells', () {
    testWidgets('each role gets its own five destinations', (tester) async {
      for (final role in AppRole.values) {
        await settle(tester, SessionActive(roles: {role}));

        final bar = tester.widget<HhBottomNav>(find.byType(HhBottomNav));
        expect(bar.items, hasLength(5), reason: role.name);

        final context = tester.element(find.byType(HhBottomNav));
        final expected = ShellTabs.forRole(
          role,
        ).map((t) => t.label(AppL10n.of(context))).toList();
        expect(bar.items.map((i) => i.label).toList(), expected);
      }
      await _unmountTree(tester);
    });

    testWidgets('a candidate destination never appears in the employer shell', (
      tester,
    ) async {
      await settle(tester, const SessionActive(roles: {AppRole.employer}));

      final context = tester.element(find.byType(HhBottomNav));
      final l10n = AppL10n.of(context);

      // "Applications" is the candidate's own list; an employer reaches
      // applications per vacancy instead (§6.5). A shared shell with hidden
      // tabs is exactly how this leaks.
      expect(find.text(l10n.navApplications), findsNothing);
      expect(find.text(l10n.navCandidates), findsOneWidget);
    });

    testWidgets('tapping a destination moves to its route', (tester) async {
      final result = await settle(
        tester,
        const SessionActive(roles: {AppRole.candidate}),
      );

      final context = tester.element(find.byType(HhBottomNav));
      final l10n = AppL10n.of(context);

      expect(locationOf(result.router), Routes.candidateHome);

      await tester.tap(find.text(l10n.navMessages));
      await _pumpRoute(tester);

      // The **location**, not the screen. This used to assert an app bar
      // carrying the tab's title, which only ever worked because every tab it
      // could reach was still a placeholder — the placeholder is the one screen
      // in the app with its own app bar, and real tab screens have none (the
      // bottom bar names the destination). So the assertion broke the moment
      // §9.1's Messages tab became real, having tested the placeholder rather
      // than the routing.
      expect(locationOf(result.router), Routes.candidateMessages);
      expect(
        tester.widget<HhBottomNav>(find.byType(HhBottomNav)).currentIndex,
        ShellTabs.candidate.indexWhere(
          (t) => t.path == Routes.candidateMessages,
        ),
      );
    });
  });

  group('the release shell has no unfinished screens left in it', () {
    testWidgets('every tab but one resolves to a real screen', (tester) async {
      // The audit's release-shell gate (MT-001, MT-002, MT-004). Three tabs
      // shipped in 1.4.1 as `ShellPlaceholderScreen` — the candidate's default
      // Home among them — and nothing failed when they did.
      //
      // Asserted as an **exact list** rather than "none": the last placeholder
      // is §10.3's dictionary management, and a test that merely allowed
      // placeholders would go on passing when a new one appeared. This one
      // fails both ways — a tab that regresses into a placeholder, and the day
      // dictionaries lands and this list stops being true.
      final placeholders = <String>[];

      for (final role in AppRole.values) {
        for (final tab in ShellTabs.forRole(role)) {
          final result = await settle(
            tester,
            SessionActive(roles: {role}),
            initialLocation: tab.path,
          );
          expect(result.location, tab.path, reason: tab.path);

          if (find.byType(ShellPlaceholderScreen).evaluate().isNotEmpty) {
            placeholders.add(tab.path);
          }
        }
      }

      expect(placeholders, [Routes.adminDictionaries]);
      await _unmountTree(tester);
    });
  });

  group('§5.5 names its feed in the location', () {
    testWidgets('a link to saved does not land on recommended', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionActive(roles: {AppRole.candidate}),
        initialLocation: Routes.candidateVacanciesWith(Feed.saved.wire),
      );

      // Home links to two of the three feeds, and the shell keeps each branch
      // across tab switches — a segment held in `State` would ignore the
      // `go` entirely and show whichever feed was last looked at.
      expect(
        result.router.routerDelegate.currentConfiguration.uri.toString(),
        Routes.candidateVacanciesWith(Feed.saved.wire),
      );
      expect(
        tester.widget<HhSegmented>(find.byType(HhSegmented)).selectedIndex,
        Feed.values.indexOf(Feed.saved),
      );

      result.router.go(Routes.candidateVacanciesWith(Feed.recent.wire));
      await _pumpRoute(tester);

      expect(
        tester.widget<HhSegmented>(find.byType(HhSegmented)).selectedIndex,
        Feed.values.indexOf(Feed.recent),
      );
      await _unmountTree(tester);
    });
  });

  group('§10.4 registers two children under one tab', () {
    testWidgets('the audit log wins the path a user id would also match', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionActive(roles: {AppRole.admin}),
        initialLocation: Routes.adminAudit,
      );

      // `:id` matches the literal `audit` as readily as it matches a uuid, so
      // the two child routes are registered in an order that decides this.
      // Asserted through the real router rather than a hand-built one, because
      // a test router would be asserting its own registration order.
      expect(result.location, Routes.adminAudit);
      expect(find.byType(AuditLogScreen), findsOneWidget);
      expect(find.byType(UserDetailScreen), findsNothing);
      await _unmountTree(tester);
    });

    testWidgets('and a uuid still reaches the account', (tester) async {
      final result = await settle(
        tester,
        const SessionActive(roles: {AppRole.admin}),
        initialLocation: Routes.adminUserFor(
          '3f2a1b9c-0000-4000-8000-000000000001',
        ),
      );

      expect(find.byType(UserDetailScreen), findsOneWidget);
      expect(find.byType(AuditLogScreen), findsNothing);
      expect(
        result.location,
        '/admin/users/3f2a1b9c-0000-4000-8000-000000000001',
      );
      await _unmountTree(tester);
    });
  });

  group('development surfaces', () {
    testWidgets('are reachable with no session at all', (tester) async {
      // They must work *because* the session is in an awkward state - guarding
      // them behind the chain they exist to debug locks the keys inside.
      final result = await settle(
        tester,
        const SessionUnauthenticated(),
        initialLocation: Routes.developerTools,
      );
      expect(result.location, Routes.developerTools);
    });

    testWidgets('are reachable while the session is still unknown', (
      tester,
    ) async {
      final result = await settle(
        tester,
        const SessionUnknown(),
        initialLocation: Routes.designGallery,
      );
      expect(result.location, Routes.designGallery);
    });

    testWidgets('are reachable from inside a shell', (tester) async {
      // Deliberately not Routes.health: that screen fetches on build, so
      // pumping it would fire a real request at 10.0.2.2:3001 and make this
      // suite depend on a backend being up. Its reachability is covered by
      // routes_test's development-path assertions instead.
      final result = await settle(
        tester,
        const SessionActive(roles: {AppRole.admin}),
        initialLocation: Routes.developerTools,
      );
      expect(result.location, Routes.developerTools);
    });
  });
}
