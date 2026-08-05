import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/auth/session_controller.dart';
import 'package:headhunter_app/src/core/auth/session_state.dart';
import 'package:headhunter_app/src/core/config/app_flavor.dart';
import 'package:headhunter_app/src/core/router/routes.dart';
import 'package:headhunter_app/src/core/router/shell_tabs.dart';
import 'package:headhunter_app/src/features/auth/presentation/otp_verification_screen.dart';
import 'package:headhunter_app/src/features/design_gallery/presentation/design_gallery_screen.dart';
import 'package:headhunter_app/src/features/dev_tools/presentation/dev_tools_screen.dart';
import 'package:headhunter_app/src/features/health/presentation/health_screen.dart';
import 'package:headhunter_app/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:headhunter_app/src/features/onboarding/presentation/role_selection_screen.dart';
import 'package:headhunter_app/src/features/shell/presentation/blocked_account_screen.dart';
import 'package:headhunter_app/src/features/shell/presentation/role_shell.dart';
import 'package:headhunter_app/src/features/shell/presentation/shell_placeholder_screen.dart';
import 'package:headhunter_app/src/features/shell/presentation/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The app's router: one navigation shell per role, plus the redirect chain.
///
/// ## All three shells are registered at once
///
/// Not "the shell for the active role, rebuilt on switch". Each role owns a
/// path namespace ([AppRole.pathPrefix]) and its own `StatefulShellRoute`, so:
///
/// - **navigation stacks cannot leak across a role switch** - leaving
///   `/candidate/...` for `/employer/...` pops the candidate shell off the
///   router's stack entirely and disposes its branch navigators, which is
///   exactly the isolation §2.3 needs;
/// - **a deep link is self-describing** - the path says which role it needs, so
///   "activate the role, then navigate" is one rule in [_redirect] rather than
///   a branch in every caller that might produce a link;
/// - the router is not rebuilt on a role switch, so switching does not tear
///   down and re-create the whole widget tree.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _SessionRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    // Re-evaluates [_redirect] whenever the session changes, so signing in,
    // signing out, being blocked or having a role revoked all move the user
    // without the screen that caused it having to navigate.
    //
    // A role *switch* is the exception and needs an explicit destination - see
    // `switchRoleAndGo` in role_navigation.dart for why the location must stay
    // authoritative.
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    debugLogDiagnostics: !AppFlavor.current.isProduction,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            // Nested, so `context.go` here *pushes* onto onboarding and the
            // system back gesture returns to the phone field instead of leaving
            // the flow.
            path: 'verify',
            name: 'otpVerification',
            // The screen needs a phone number and the deadlines from the send
            // response, and both live only in `extra`. Anything that arrives
            // without them - a hot restart on this screen, a stray deep link -
            // has no code pending and nothing to verify, so it starts over
            // rather than rendering a form that cannot succeed.
            redirect: (context, state) =>
                state.extra is OtpVerificationArgs ? null : Routes.onboarding,
            builder: (context, state) => OtpVerificationScreen(
              args: state.extra! as OtpVerificationArgs,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.roleSelection,
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: Routes.blocked,
        name: 'blocked',
        builder: (context, state) => const BlockedAccountScreen(),
      ),
      for (final role in AppRole.values) _shellFor(role),

      // Development surfaces. Absent from a production build rather than hidden
      // inside it, so no deep link can reach them there.
      if (AppFlavor.current.allowsDevelopmentTools) ...[
        GoRoute(
          path: Routes.developerTools,
          name: 'developerTools',
          builder: (context, state) => const DevToolsScreen(),
        ),
        GoRoute(
          path: Routes.designGallery,
          name: 'designGallery',
          builder: (context, state) => const DesignGalleryScreen(),
        ),
        GoRoute(
          path: Routes.health,
          name: 'health',
          builder: (context, state) => const HealthScreen(),
        ),
      ],
    ],
  );
}

/// The shell for one role: an `IndexedStack` of five branches, one per tab.
///
/// `indexedStack` rather than the lazy variant: each branch keeps its scroll
/// position and its own back stack while the user moves between tabs, which is
/// what makes tab switching feel like switching *between* places instead of
/// reloading one.
StatefulShellRoute _shellFor(AppRole role) => StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      RoleShell(role: role, navigationShell: navigationShell),
  branches: [
    for (final tab in ShellTabs.forRole(role))
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: tab.path,
            builder: (context, state) => ShellPlaceholderScreen(tab: tab),
          ),
        ],
      ),
  ],
);

/// The guard chain of ARCHITECTURE.md §3, in priority order.
///
/// Order is the whole design here, so it is written out:
///
/// 1. **Development paths pass through untouched.** They must work *because*
///    the session is in an awkward state - that is when they are needed.
/// 2. **Session not yet restored → hold on the splash.** Never treat "unknown"
///    as "signed out": that is the cold-start flash where a signed-in user sees
///    onboarding for two frames.
/// 3. **No session → the sign-in flow**, which is every path under
///    `/onboarding`: phone entry and then code entry (§4.1).
/// 4. **Blocked → the notice (BR-10)**, ahead of role selection: a blocked
///    account must not be walked through choosing a role it cannot use.
///    `restricted` deliberately does *not* redirect - see [AccountStatus].
/// 5. **No role granted → role selection.**
/// 6. **A shell path for a role the account does not hold → its own shell.**
/// 7. **A shell path for a granted role that is not the active one → allow,
///    and record the switch.** This is the deep-link rule: the destination
///    decides the role.
String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  if (Routes.isDevelopmentPath(location)) return null;

  final session = ref.read(sessionControllerProvider);

  switch (session) {
    case SessionUnknown():
      return location == Routes.splash ? null : Routes.splash;

    case SessionUnauthenticated():
      // `startsWith`, not equality: sign-in is two screens (§4.1 - phone, then
      // the code), and the second is a child path. Equality here would bounce
      // the user off the code screen the instant they reached it.
      return location.startsWith(Routes.onboarding)
          ? null
          : Routes.onboarding;

    case SessionActive(status: AccountStatus.blocked):
      return location == Routes.blocked ? null : Routes.blocked;

    case SessionActive(needsRoleSelection: true):
      return location == Routes.roleSelection ? null : Routes.roleSelection;

    case SessionActive():
      // needsRoleSelection is false, so at least one role is granted and
      // effectiveRole cannot be null.
      final fallback = Routes.homeFor(session.effectiveRole!);

      final target = AppRole.fromLocation(location);
      // Not a shell path at all: the splash, or a pre-session screen the user
      // no longer belongs on. Send them into their shell.
      if (target == null) return fallback;
      if (!session.can(target)) return fallback;

      if (session.activeRole != target) {
        // Deep link into a granted role that is not the active one. Recorded
        // *after* this redirect returns, because mutating provider state inside
        // a redirect re-enters the router mid-navigation. The write fires the
        // refreshListenable, the chain runs once more, and this time
        // activeRole == target, so it converges in one extra pass.
        final controller = ref.read(sessionControllerProvider.notifier);
        unawaited(Future.microtask(() => controller.switchRole(target)));
      }
      return null;
  }
}

/// Bridges session changes to `GoRouter.refreshListenable`.
///
/// `ref.listen` rather than `ref.watch`: watching inside the provider that
/// *builds* the router would rebuild the router itself on every session change,
/// discarding the entire navigation stack. The router instance must outlive the
/// session's transitions - only the redirect result should change.
class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(Ref ref) {
    // The subscription needs no explicit close: one created through a
    // provider's own `ref` is torn down with that provider, and this notifier
    // is disposed in the same `onDispose` that owns it.
    ref.listen<SessionState>(sessionControllerProvider, (previous, next) {
      if (previous != next) notifyListeners();
    });
  }
}
