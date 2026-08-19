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
import 'package:jobbridge_app/src/core/router/app_router.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/core/router/shell_tabs.dart';
import 'package:jobbridge_app/src/features/auth/domain/otp_challenge.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';
import 'package:jobbridge_app/src/features/auth/presentation/otp_verification_screen.dart';
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
Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
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
      await settle(tester, const SessionActive(roles: {AppRole.candidate}));

      final context = tester.element(find.byType(HhBottomNav));
      final l10n = AppL10n.of(context);

      await tester.tap(find.text(l10n.navMessages));
      await _pumpRoute(tester);

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.navMessages),
        ),
        findsOneWidget,
      );
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
