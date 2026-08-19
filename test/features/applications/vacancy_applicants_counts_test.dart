import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/data/employer_applications_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/applications/presentation/vacancy_applicants_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';

/// §7.4 step 7 on one screen: "track invited, accepted, interviewed, and hired
/// counts against the target of 20".
///
/// Two endpoints answer it — invitation states from
/// `GET /invitations/counts/:vacancyId`, application stages from
/// `/vacancies/{id}/applications/counts` — and joining them is the client's
/// job. These tests are about the join, not about either endpoint.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    ApplicationCounts? applications,
    Map<String, int>? invitations,
    ApiException? applicationsError,
    ApiException? invitationsError,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          vacancyApplicationsProvider(
            'vac-1',
          ).overrideWith((ref) async => const <Application>[]),
          vacancyApplicationCountsProvider('vac-1').overrideWith(
            (ref) => applicationsError != null
                ? throw applicationsError
                : applications ??
                      const ApplicationCounts(hiredCount: 0, byStatus: {}),
          ),
          invitationCountsProvider('vac-1').overrideWith(
            (ref) => invitationsError != null
                ? throw invitationsError
                : invitations ?? const <String, int>{},
          ),
          // The screen the counts link to. Overridden at the provider rather
          // than the repository so no test here needs SharedPreferences, which
          // the real `invitationRepositoryProvider` awaits.
          sentInvitationsProvider(
            vacancyId: 'vac-1',
          ).overrideWith((ref) async => const <Invitation>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const VacancyApplicantsScreen(vacancyId: 'vac-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('§7.4: "invited" is every status, not the count of `sent`', () {
    testWidgets('an answered invitation is still an invitation', (
      tester,
    ) async {
      await pump(
        tester,
        invitations: const {'sent': 3, 'accepted': 5, 'declined': 2},
      );

      // 10, not 3. Reading `byStatus['sent']` would have looked right for as
      // long as nobody had answered and then quietly counted downwards as
      // replies arrived — the kind of wrong number that never looks wrong.
      expect(find.text('10 invited, 5 accepted'), findsOneWidget);
    });

    testWidgets('a status this build has never heard of still counts', (
      tester,
    ) async {
      await pump(
        tester,
        invitations: const {'sent': 2, 'accepted': 1, 'renegotiated': 4},
      );

      // Summing the server's map rather than adding four known keys is what
      // makes this true, and it is why the repository returns the map instead
      // of a typed pair.
      expect(find.text('7 invited, 1 accepted'), findsOneWidget);
    });

    testWidgets('no invitations means no invitation line', (tester) async {
      await pump(
        tester,
        applications: const ApplicationCounts(hiredCount: 0, byStatus: {}),
      );

      expect(find.textContaining('invited'), findsNothing);
      expect(find.text('Invitations sent'), findsNothing);
    });
  });

  group('either half may be missing and the other still shows', () {
    testWidgets('invitation counts survive an application-counts failure', (
      tester,
    ) async {
      await pump(
        tester,
        applicationsError: const ApiException('counts unavailable'),
        invitations: const {'sent': 4, 'accepted': 1},
      );

      expect(find.text('5 invited, 1 accepted'), findsOneWidget);
    });

    testWidgets('hiring progress survives an invitation-counts failure', (
      tester,
    ) async {
      await pump(
        tester,
        applications: const ApplicationCounts(
          hiredCount: 3,
          workerCount: 20,
          byStatus: {'submitted': 12},
        ),
        invitationsError: const ApiException('vacancy.not_found'),
      );

      // §7.4's own example, and the half that must not vanish because the other
      // request failed: a card that disappeared would read as "no applicants".
      expect(find.text('3 of 20 hired'), findsOneWidget);
    });

    testWidgets('both failing leaves no card rather than an empty one', (
      tester,
    ) async {
      await pump(
        tester,
        applicationsError: const ApiException('a'),
        invitationsError: const ApiException('b'),
      );

      expect(find.byType(HhCard), findsNothing);
    });
  });

  group('the counts lead somewhere', () {
    testWidgets('the sent list opens scoped to this vacancy', (tester) async {
      await pump(tester, invitations: const {'sent': 4});

      await tester.tap(find.text('Invitations sent'));
      // Not `pumpAndSettle`: the pushed screen's loading arm holds a
      // `CircularProgressIndicator`, which never settles — so settling would
      // time out on a screen that is working correctly.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Scoped: the screen says so, which is the visible difference between
      // "four invitations" and "four on this vacancy".
      expect(find.text('This vacancy only'), findsOneWidget);
    });
  });
}
