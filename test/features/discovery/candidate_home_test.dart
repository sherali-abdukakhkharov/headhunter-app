import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/applications/data/application_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_card.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/candidate_home_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/candidate_profile.dart';

/// §5.5's candidate home — MT-001, which shipped as a milestone placeholder in
/// 1.4.1 and was the audit's first Critical.
CandidateProfile _profile({
  int completeness = 40,
  bool complete = false,
  bool searchable = false,
  bool started = true,
}) => CandidateProfile.fromJson({
  'isStarted': started,
  'visibility': searchable ? 'searchable' : 'hidden',
  'completenessPercent': completeness,
  'isComplete': complete,
  'isSearchable': searchable,
  'missingFields': const <dynamic>[],
  'fields': const <String, dynamic>{},
});

VacancyCard _card({String id = 'vac-1', String title = 'Payvandchi kerak'}) =>
    VacancyCard.fromJson({
      'id': id,
      'title': title,
      'employer': const {'isVerified': true, 'name': 'Uzum Market'},
      'isSaved': false,
      'salaryIsNegotiable': false,
      'hasApplied': false,
    });

Application _application({String status = 'submitted'}) =>
    Application.fromJson({
      'id': 'app-1',
      'vacancyId': 'vac-1',
      'candidateUserId': 'usr-1',
      'status': status,
      'createdAt': '2026-08-20T09:00:00+05:00',
      'updatedAt': '2026-08-20T09:00:00+05:00',
    });

Invitation _invitation({String status = 'sent'}) => Invitation.fromJson({
  'id': 'inv-1',
  'employerUserId': 'usr-emp',
  'candidateUserId': 'usr-1',
  'vacancyId': 'vac-1',
  'status': status,
  'salaryIsNegotiable': false,
  'createdAt': '2026-08-20T09:00:00+05:00',
  'updatedAt': '2026-08-20T09:00:00+05:00',
});

void main() {
  /// Each section reads a provider of its own, so each is overridden of its
  /// own — including with a failure, which is the case the screen is built
  /// around.
  ({Widget widget, GoRouter router}) routed({
    AsyncValue<CandidateProfile>? profile,
    AsyncValue<List<VacancyCard>>? recommended,
    AsyncValue<List<Application>>? applications,
    AsyncValue<List<Invitation>>? invitations,
  }) {
    final router = GoRouter(
      initialLocation: Routes.candidateHome,
      routes: [
        GoRoute(
          path: Routes.candidateHome,
          builder: (context, state) => const CandidateHomeScreen(),
        ),
        GoRoute(
          path: Routes.candidateVacancies,
          builder: (context, state) => const Text('vacancies'),
        ),
        GoRoute(
          path: Routes.candidateApplications,
          builder: (context, state) => const Text('applications'),
        ),
        GoRoute(
          path: Routes.candidateProfile,
          builder: (context, state) => const Text('profile'),
        ),
      ],
    );

    return (
      widget: ProviderScope(
        // Riverpod 3 retries a throwing provider by default and reports
        // `AsyncLoading` while it does. The app disables it in `main.dart`.
        retry: (retryCount, error) => null,
        overrides: [
          candidateProfileProvider.overrideWith(
            (ref) => switch (profile ?? AsyncData(_profile())) {
              AsyncError(:final error) => Future<CandidateProfile>.error(error),
              final value => Future.value(value.requireValue),
            },
          ),
          vacancyFeedProvider(Feed.recommended).overrideWith(
            (ref) => switch (recommended ?? const AsyncData(<VacancyCard>[])) {
              AsyncError(:final error) => Future<List<VacancyCard>>.error(
                error,
              ),
              final value => Future.value(value.requireValue),
            },
          ),
          myApplicationsProvider.overrideWith(
            (ref) => switch (applications ?? const AsyncData(<Application>[])) {
              AsyncError(:final error) => Future<List<Application>>.error(
                error,
              ),
              final value => Future.value(value.requireValue),
            },
          ),
          receivedInvitationsProvider.overrideWith(
            (ref) => switch (invitations ?? const AsyncData(<Invitation>[])) {
              AsyncError(:final error) => Future<List<Invitation>>.error(error),
              final value => Future.value(value.requireValue),
            },
          ),
        ],
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

  Future<GoRouter> pump(
    WidgetTester tester, {
    AsyncValue<CandidateProfile>? profile,
    AsyncValue<List<VacancyCard>>? recommended,
    AsyncValue<List<Application>>? applications,
    AsyncValue<List<Invitation>>? invitations,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final app = routed(
      profile: profile,
      recommended: recommended,
      applications: applications,
      invitations: invitations,
    );
    await tester.pumpWidget(app.widget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return app.router;
  }

  String locationOf(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  group('the screen a candidate lands on is not a milestone note', () {
    testWidgets('no placeholder copy reaches it', (tester) async {
      await pump(tester);

      // MT-001: 1.4.1 shipped "This screen arrives in M6" as the default
      // candidate destination, on every login and every restart.
      expect(find.textContaining('M6'), findsNothing);
      expect(find.textContaining('arrives in'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('what is waiting on the candidate comes first', () {
    testWidgets('an unanswered invitation is counted', (tester) async {
      await pump(tester, invitations: AsyncData([_invitation()]));

      expect(find.text('1 invitation awaits your answer'), findsOneWidget);
    });

    testWidgets('one already answered is not', (tester) async {
      await pump(
        tester,
        invitations: AsyncData([_invitation(status: 'accepted')]),
      );

      expect(find.textContaining('awaits your answer'), findsNothing);
    });

    testWidgets('nor is one where the employer is the one to answer', (
      tester,
    ) async {
      // `details_requested` is the candidate waiting on the employer. Counting
      // it would ask somebody to answer their own question.
      await pump(
        tester,
        invitations: AsyncData([_invitation(status: 'details_requested')]),
      );

      expect(find.textContaining('awaits your answer'), findsNothing);
    });

    testWidgets('a live application is counted and a finished one is not', (
      tester,
    ) async {
      await pump(
        tester,
        applications: AsyncData([
          _application(),
          _application(status: 'hired'),
          _application(status: 'withdrawn'),
        ]),
      );

      expect(find.text('1 application in progress'), findsOneWidget);
    });

    testWidgets('the counts lead to the tab that holds them', (tester) async {
      final router = await pump(
        tester,
        invitations: AsyncData([_invitation()]),
      );

      await tester.tap(find.text('1 invitation awaits your answer'));
      await tester.pumpAndSettle();

      expect(locationOf(router), Routes.candidateApplications);
    });

    testWidgets('with nothing waiting, the card is absent rather than empty', (
      tester,
    ) async {
      await pump(tester);

      expect(find.textContaining('awaits your answer'), findsNothing);
      expect(find.textContaining('in progress'), findsNothing);
    });
  });

  group('the profile prompt appears where it is relevant', () {
    testWidgets('an unfinished profile says it cannot be found yet', (
      tester,
    ) async {
      await pump(tester, profile: AsyncData(_profile()));

      expect(find.text('Finish your profile'), findsOneWidget);
      // BR-02 is a threshold, not a preference, and this is the answer to
      // "why is nobody inviting me".
      expect(
        find.textContaining('Employers cannot find you yet'),
        findsOneWidget,
      );
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('a profile nobody has started says so differently', (
      tester,
    ) async {
      await pump(
        tester,
        profile: AsyncData(_profile(started: false, completeness: 0)),
      );

      expect(find.text('Start your profile'), findsOneWidget);
    });

    testWidgets('a searchable but unfinished profile is not warned about', (
      tester,
    ) async {
      await pump(
        tester,
        profile: AsyncData(_profile(completeness: 80, searchable: true)),
      );

      expect(find.text('Finish your profile'), findsOneWidget);
      expect(find.textContaining('cannot find you yet'), findsNothing);
    });

    testWidgets('a complete profile gets no prompt at all', (tester) async {
      await pump(
        tester,
        profile: AsyncData(
          _profile(completeness: 100, complete: true, searchable: true),
        ),
      );

      // A bar at 100% on every visit is a permanent reminder of a finished job.
      expect(find.text('Finish your profile'), findsNothing);
      expect(find.text('Start your profile'), findsNothing);
    });

    testWidgets('it opens the profile tab', (tester) async {
      final router = await pump(tester, profile: AsyncData(_profile()));

      await tester.tap(find.text('Finish your profile'));
      await tester.pumpAndSettle();

      expect(locationOf(router), Routes.candidateProfile);
    });
  });

  group('the recommended work, and the feed it hands over to', () {
    testWidgets('at most three, from the recommended feed', (tester) async {
      await pump(
        tester,
        recommended: AsyncData([
          for (var i = 0; i < 6; i++) _card(id: 'vac-$i', title: 'Vacancy $i'),
        ]),
      );

      expect(find.text('Vacancy 0'), findsOneWidget);
      expect(find.text('Vacancy 2'), findsOneWidget);
      // Home is not a second feed: the fourth card is the Vacancies tab's job.
      expect(find.text('Vacancy 3'), findsNothing);
    });

    testWidgets('"See all" names the feed it means', (tester) async {
      final router = await pump(tester);

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      // Not the bare tab path: the shell keeps each branch, so a link with no
      // feed named would arrive at whichever one was last looked at.
      expect(
        locationOf(router),
        Routes.candidateVacanciesWith(Feed.recommended.wire),
      );
    });

    testWidgets('an empty feed offers the one that needs no profile', (
      tester,
    ) async {
      final router = await pump(tester);

      expect(find.text('No recommendations yet'), findsOneWidget);
      await tester.tap(find.text('Browse new vacancies'));
      await tester.pumpAndSettle();

      expect(
        locationOf(router),
        Routes.candidateVacanciesWith(Feed.recent.wire),
      );
    });
  });

  group('a section that fails does not make the screen look broken', () {
    testWidgets('a failed feed reads as no recommendations', (tester) async {
      await pump(
        tester,
        recommended: const AsyncError(
          ApiException('Service unavailable'),
          StackTrace.empty,
        ),
      );

      // The Vacancies tab reports the same failure properly, with a retry.
      // Home's job is not to be a second error screen.
      expect(find.text('No recommendations yet'), findsOneWidget);
      expect(find.text('Service unavailable'), findsNothing);
      expect(find.byType(HhErrorState), findsNothing);
    });

    testWidgets('a failed profile removes the prompt rather than breaking it', (
      tester,
    ) async {
      await pump(
        tester,
        profile: const AsyncError(
          ApiException('Service unavailable'),
          StackTrace.empty,
        ),
      );

      expect(find.text('Finish your profile'), findsNothing);
      expect(find.byType(HhErrorState), findsNothing);
      // And the rest of the screen is still there.
      expect(find.text('Recommended for you'), findsOneWidget);
    });

    testWidgets('failed lists simply are not counted', (tester) async {
      await pump(
        tester,
        applications: const AsyncError(
          ApiException('Service unavailable'),
          StackTrace.empty,
        ),
        invitations: const AsyncError(
          ApiException('Service unavailable'),
          StackTrace.empty,
        ),
      );

      expect(find.textContaining('in progress'), findsNothing);
      expect(find.byType(HhErrorState), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
