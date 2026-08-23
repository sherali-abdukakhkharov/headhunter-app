import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/core/router/shell_tabs.dart';
import 'package:jobbridge_app/src/features/admin/domain/audit_entry.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_queue_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/audit_log_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/complaint_queue_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/complaint_review_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/user_detail_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/user_search_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/vacancy_review_screen.dart';
import 'package:jobbridge_app/src/features/applications/presentation/applications_screen.dart';
import 'package:jobbridge_app/src/features/applications/presentation/vacancy_applicants_screen.dart';
import 'package:jobbridge_app/src/features/auth/presentation/otp_verification_screen.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/candidate_search_screen.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/vacancy_shortlist_screen.dart';
import 'package:jobbridge_app/src/features/chat/presentation/conversation_thread_screen.dart';
import 'package:jobbridge_app/src/features/chat/presentation/conversations_screen.dart';
import 'package:jobbridge_app/src/features/design_gallery/presentation/design_gallery_screen.dart';
import 'package:jobbridge_app/src/features/dev_tools/presentation/dev_tools_screen.dart';
import 'package:jobbridge_app/src/features/dev_tools/presentation/dictionary_probe_screen.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/candidate_home_screen.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_feed_screen.dart';
import 'package:jobbridge_app/src/features/employer/presentation/employer_dashboard_screen.dart';
import 'package:jobbridge_app/src/features/employer/presentation/employer_profile_screen.dart';
import 'package:jobbridge_app/src/features/health/presentation/health_screen.dart';
import 'package:jobbridge_app/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:jobbridge_app/src/features/onboarding/presentation/role_selection_screen.dart';
import 'package:jobbridge_app/src/features/profile/presentation/candidate_profile_screen.dart';
import 'package:jobbridge_app/src/features/shell/presentation/blocked_account_screen.dart';
import 'package:jobbridge_app/src/features/shell/presentation/role_shell.dart';
import 'package:jobbridge_app/src/features/shell/presentation/shell_placeholder_screen.dart';
import 'package:jobbridge_app/src/features/shell/presentation/splash_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_editor_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_list_screen.dart';
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
        GoRoute(
          path: Routes.dictionaryProbe,
          name: 'dictionaryProbe',
          builder: (context, state) => const DictionaryProbeScreen(),
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
            // Tabs are replaced by real screens one at a time as their
            // milestone lands; the rest keep the placeholder, which names the
            // milestone that owns them.
            builder: (context, state) => switch (tab.path) {
              Routes.candidateHome => const CandidateHomeScreen(),
              Routes.candidateProfile => const CandidateProfileScreen(),
              Routes.candidateVacancies => const VacancyFeedScreen(),
              Routes.candidateApplications => const ApplicationsScreen(),
              Routes.employerHome => const EmployerDashboardScreen(),
              Routes.employerCompany => const EmployerProfileScreen(),
              Routes.employerVacancies => const VacancyListScreen(),
              Routes.employerCandidates => const CandidateSearchScreen(),
              // §9.1's Messages tab is one screen in two shells. It is given
              // its own tab path rather than the active role, because the
              // thread is a child of *this* branch and the role can lag the
              // location by a frame during a switch.
              Routes.candidateMessages || Routes.employerMessages =>
                ConversationsScreen(basePath: tab.path),
              // §10. The administrator's tabs land one at a time like every
              // other shell's; the rest keep the placeholder.
              Routes.adminDashboard => const AdminDashboardScreen(),
              Routes.adminQueue => const AdminQueueScreen(),
              Routes.adminComplaints => const ComplaintQueueScreen(),
              Routes.adminUsers => const UserSearchScreen(),
              _ => ShellPlaceholderScreen(tab: tab),
            },
            routes: [
              // §9.1. Nested inside the Messages tab, so a thread keeps the
              // shell's nav bar and the back gesture returns to the list. Two
              // registrations rather than one — the candidate shell and the
              // employer shell each own their own path namespace — and the
              // route **names** must differ for the same reason.
              if (tab.path == Routes.candidateMessages ||
                  tab.path == Routes.employerMessages)
                GoRoute(
                  path: ':id',
                  name: tab.path == Routes.candidateMessages
                      ? 'candidateConversation'
                      : 'employerConversation',
                  builder: (context, state) => ConversationThreadScreen(
                    conversationId: state.pathParameters['id']!,
                  ),
                ),

              // Nested inside the tab, so the vacancy editor keeps the shell's
              // nav bar and the system back gesture returns to the list rather
              // than leaving the branch.
              if (tab.path == Routes.employerVacancies)
                GoRoute(
                  path: ':id',
                  name: 'employerVacancy',
                  builder: (context, state) => VacancyEditorScreen(
                    id: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'applicants',
                      name: 'vacancyApplicants',
                      builder: (context, state) => VacancyApplicantsScreen(
                        vacancyId: state.pathParameters['id']!,
                      ),
                    ),
                    // §7.3. A child of the vacancy rather than of the search
                    // tab, because the vacancy is what the list belongs to:
                    // reached cold, the path carries the only thing the screen
                    // needs, and back goes to the vacancy it was opened from.
                    GoRoute(
                      path: 'shortlist',
                      name: 'vacancyShortlist',
                      builder: (context, state) => VacancyShortlistScreen(
                        vacancyId: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),

              // §10.2. A child of the moderation tab, so the review keeps the
              // shell's nav bar and back returns to the queue it came from.
              // The segment name is in the path rather than the query here —
              // `?queue=` chooses which *list* the tab shows, and this is not a
              // list.
              if (tab.path == Routes.adminQueue)
                GoRoute(
                  path: '${Routes.adminQueueVacancies}/:id',
                  name: 'adminVacancyReview',
                  builder: (context, state) => VacancyReviewScreen(
                    vacancyId: state.pathParameters['id']!,
                  ),
                ),

              // §10.2's third queue. A plain `:id` because the complaints tab
              // holds one list rather than two, so there is no segment to
              // disambiguate against.
              if (tab.path == Routes.adminComplaints)
                GoRoute(
                  path: ':id',
                  name: 'adminComplaintReview',
                  builder: (context, state) => ComplaintReviewScreen(
                    complaintId: state.pathParameters['id']!,
                  ),
                ),

              // §10.4. Both children of the users tab, so back returns to the
              // results the administrator searched for rather than to an
              // empty search form — which is the whole reason the results
              // live in a provider the branch keeps.
              //
              // **The order of these two is load-bearing.** go_router takes
              // the first route that matches, and `:id` matches the literal
              // `audit` as readily as it matches a uuid. The audit log is
              // therefore registered first; nothing else can collide, because
              // a user id is a uuid.
              if (tab.path == Routes.adminUsers) ...[
                GoRoute(
                  path: 'audit',
                  name: 'adminAudit',
                  builder: (context, state) => AuditLogScreen(
                    query: AuditQuery.fromWire(
                      actorUserId:
                          state.uri.queryParameters[Routes
                              .adminAuditActorParam],
                      targetType:
                          state.uri.queryParameters[Routes
                              .adminAuditTargetTypeParam],
                      targetId:
                          state.uri.queryParameters[Routes
                              .adminAuditTargetIdParam],
                    ),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  name: 'adminUserDetail',
                  builder: (context, state) =>
                      UserDetailScreen(userId: state.pathParameters['id']!),
                ),
              ],
            ],
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
