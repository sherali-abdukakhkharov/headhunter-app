import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/data/employer_applications_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_controller.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:jobbridge_app/src/features/employer/presentation/employer_dashboard_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';

Vacancy _vacancy({
  required String id,
  String title = 'Call-markaz operatori',
  String status = 'active',
  bool open = true,
  int workerCount = 20,
  int hiredCount = 0,
}) => Vacancy.fromJson({
  'id': id,
  'status': status,
  'fields': {'title': title, 'worker_count': workerCount},
  'missingForSubmit': const <String>[],
  'isOpenForApplications': open,
  'hiredCount': hiredCount,
});

void main() {
  Future<void> pump(
    WidgetTester tester, {
    List<Vacancy> vacancies = const [],
    Map<String, ApplicationCounts> counts = const {},
    Map<String, Map<String, int>> invitations = const {},
    List<CandidateCard> saved = const [],
    String verification = 'verified',
    ApiException? vacanciesError,
    EmployerProfile? employer,
    bool hasProfile = true,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          myVacanciesProvider.overrideWith(
            (ref) async =>
                vacanciesError != null ? throw vacanciesError : vacancies,
          ),
          savedCandidatesProvider.overrideWith((ref) async => saved),
          verificationProvider.overrideWith(
            () => _FakeVerification(verification),
          ),
          employerEditorProvider.overrideWith(
            () => _FakeEditor(
              profile: hasProfile ? employer ?? _employer() : null,
            ),
          ),
          // §6.2's seventh widget makes its own request. Failed rather than
          // stubbed: the tile has its own suite, and what matters here is that
          // its failure stays inside it and the rest of the dashboard renders.
          walletProvider.overrideWith(
            (ref) => throw const ApiException('not under test'),
          ),
          for (final entry in counts.entries)
            vacancyApplicationCountsProvider(
              entry.key,
            ).overrideWith((ref) async => entry.value),
          for (final entry in invitations.entries)
            invitationCountsProvider(
              entry.key,
            ).overrideWith((ref) async => entry.value),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const EmployerDashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('the header counts what §6.2 asks it to', () {
    testWidgets('open positions add up the worker counts, not the vacancies', (
      tester,
    ) async {
      await pump(
        tester,
        vacancies: [
          _vacancy(id: 'a'),
          _vacancy(id: 'b', workerCount: 5),
        ],
        counts: {
          'a': const ApplicationCounts(hiredCount: 0, byStatus: {}),
          'b': const ApplicationCounts(hiredCount: 0, byStatus: {}),
        },
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('a vacancy with no worker count contributes nothing, not one', (
      tester,
    ) async {
      await pump(
        tester,
        vacancies: [
          Vacancy.fromJson(const {
            'id': 'a',
            'status': 'active',
            'fields': {'title': 'Payvandchi'},
            'missingForSubmit': <String>[],
            'isOpenForApplications': true,
            'hiredCount': 0,
          }),
        ],
        counts: {'a': const ApplicationCounts(hiredCount: 0, byStatus: {})},
      );

      // Inventing a position would inflate the one figure an employer might
      // quote to somebody.
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('a closed vacancy is not active, even if its status says so', (
      tester,
    ) async {
      await pump(
        tester,
        // BR-06's flag is computed from the status *and* the deadline, so this
        // is the case a `status == 'active'` comparison would get wrong.
        vacancies: [_vacancy(id: 'a', open: false, workerCount: 9)],
      );

      expect(find.text('0'), findsWidgets);
      expect(find.text('9'), findsNothing);
    });

    testWidgets('new applications wait for every count before showing one', (
      tester,
    ) async {
      await pump(
        tester,
        vacancies: [_vacancy(id: 'a'), _vacancy(id: 'b')],
        // Only one of the two answers; the other stays loading.
        counts: {
          'a': const ApplicationCounts(
            hiredCount: 0,
            byStatus: {'submitted': 12},
          ),
        },
      );

      // 12 would be a *wrong* number rather than a partial one, and this is the
      // figure an employer acts on first.
      expect(find.text('12'), findsNothing);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('and sums them once they all arrive', (tester) async {
      await pump(
        tester,
        vacancies: [_vacancy(id: 'a'), _vacancy(id: 'b')],
        counts: {
          'a': const ApplicationCounts(
            hiredCount: 0,
            byStatus: {'submitted': 12, 'viewed': 3},
          ),
          'b': const ApplicationCounts(
            hiredCount: 0,
            byStatus: {'submitted': 4},
          ),
        },
      );

      // 16, not 19: `viewed` has been looked at, and §6.2 asks for the ones
      // that have not.
      expect(find.text('16'), findsOneWidget);
    });
  });

  group('pending work comes first, in the order it blocks the employer', () {
    testWidgets('verification outranks everything', (tester) async {
      await pump(
        tester,
        verification: 'not_submitted',
        vacancies: [_vacancy(id: 'a', status: 'rejected', open: false)],
        saved: [_card()],
      );

      final rows = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((t) => t.isNotEmpty)
          .toList();

      // BR-03 first: an unverified employer cannot publish, search or unlock,
      // so nothing else on the screen works until it is done.
      expect(
        rows.indexWhere((t) => t.contains('Verification is not complete')),
        lessThan(rows.indexWhere((t) => t.contains('Changes are required'))),
      );
    });

    testWidgets('a moderated-back vacancy is listed with its title', (
      tester,
    ) async {
      await pump(
        tester,
        vacancies: [
          _vacancy(
            id: 'a',
            title: 'Payvandchi (argon)',
            status: 'rejected',
            open: false,
          ),
        ],
      );

      expect(find.text('Changes are required'), findsOneWidget);
      expect(find.text('Payvandchi (argon)'), findsOneWidget);
    });

    testWidgets('unreviewed applicants are listed per vacancy', (tester) async {
      await pump(
        tester,
        vacancies: [_vacancy(id: 'a')],
        counts: {
          'a': const ApplicationCounts(
            hiredCount: 0,
            byStatus: {'submitted': 12},
          ),
        },
      );

      expect(
        find.text('12 applications not yet reviewed'),
        findsOneWidget,
      );
    });

    testWidgets('an empty queue is stated as good news, not as absence', (
      tester,
    ) async {
      await pump(tester);

      // Drawing it as an empty state would read as a failure to load.
      expect(find.textContaining('Nothing is waiting on you'), findsOneWidget);
      expect(find.byType(HhEmptyState), findsNothing);
    });
  });

  group('the hiring meter keeps its segments disjoint', () {
    testWidgets('invited counts only the invitations still in the air', (
      tester,
    ) async {
      await pump(
        tester,
        vacancies: [_vacancy(id: 'a', hiredCount: 7)],
        counts: {
          'a': const ApplicationCounts(
            hiredCount: 7,
            workerCount: 20,
            byStatus: {},
          ),
        },
        invitations: {
          'a': const {
            'sent': 3,
            'details_requested': 1,
            // Terminal: these people either said no or are already counted
            // among the hires, and adding them would make the three segments
            // sum past the openings.
            'accepted': 5,
            'declined': 6,
          },
        },
      );

      expect(find.text('Hired 7'), findsOneWidget);
      expect(find.text('Invited 4'), findsOneWidget);
      expect(find.text('Remaining 9'), findsOneWidget);
      expect(find.text('7 of 20'), findsOneWidget);
    });

    testWidgets('no worker count means no denominator is invented', (
      tester,
    ) async {
      await pump(
        tester,
        vacancies: [_vacancy(id: 'a', hiredCount: 3)],
        counts: {'a': const ApplicationCounts(hiredCount: 3, byStatus: {})},
      );

      // §6.5 lets a vacancy state no worker count, and a target nobody set is
      // not a target to measure against.
      expect(find.textContaining(' of '), findsNothing);
      expect(find.textContaining('Remaining'), findsNothing);
      expect(find.text('Hired 3'), findsOneWidget);
    });

    test('more hires than openings still fills one bar, in proportion', () {
      // §6.5 treats `worker_count` as a target rather than a cap, so this is a
      // state the server can report. Clamping segments individually would let
      // the first one eat the second.
      const meter = HhMeter(
        total: 10,
        segments: [
          HhMeterSegment(value: 9, color: Color(0xFF000000), label: 'a'),
          HhMeterSegment(value: 6, color: Color(0xFF111111), label: 'b'),
        ],
      );

      expect(meter.remaining, 0);
    });
  });

  group('states', () {
    testWidgets('a failed vacancy list is terminal and offers a retry', (
      tester,
    ) async {
      await pump(
        tester,
        vacanciesError: const ApiException('Server unreachable'),
      );

      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('the quick actions are always offered', (tester) async {
      await pump(tester);

      // Even with nothing published: an employer whose first visit shows no
      // vacancies is exactly the one who needs Create most.
      expect(find.text('New vacancy'), findsOneWidget);
      expect(find.text('Find candidates'), findsOneWidget);
    });
  });

  group('an incomplete employer is never told nothing is waiting (MT-010)', () {
    testWidgets('no profile at all is the first thing on the list', (
      tester,
    ) async {
      await pump(tester, hasProfile: false);

      // The audit's sequence: the dashboard said everything was fine, and then
      // New vacancy and Candidates both refused. Without a profile the
      // verification read 404s, which produced no row — so the *only* thing on
      // the screen was "Nothing is waiting on you".
      expect(find.text('Complete your company profile'), findsOneWidget);
      expect(find.textContaining('Nothing is waiting on you'), findsNothing);
    });

    testWidgets('a half-filled one says how far it has to go', (tester) async {
      await pump(
        tester,
        employer: _employer(complete: false, percent: 60),
      );

      // BR-03 needs all of §6.1, so 60% is not "mostly working".
      expect(find.text('Complete your company profile'), findsOneWidget);
      expect(find.textContaining('60% filled in'), findsOneWidget);
    });

    testWidgets('a complete one leaves the list to the real work', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Complete your company profile'), findsNothing);
      expect(find.textContaining('Nothing is waiting on you'), findsOneWidget);
    });
  });
}

CandidateCard _card() => CandidateCard.fromJson(const {
  'candidateUserId': 'cand-1',
  'fullName': 'Aziza Karimova',
  'experienceYears': 4,
  'completenessPercent': 90,
  'salaryIsNegotiable': false,
  'isSaved': true,
  'isShortlisted': false,
  'matchScore': 82,
  'skills': <dynamic>[],
  'languages': <dynamic>[],
  'matchBreakdown': <dynamic>[],
});

class _FakeVerification extends Verification {
  _FakeVerification(this._status);

  final String _status;

  @override
  Future<VerificationState> build() async => VerificationState(
    status: _status,
    requiredEvidence: const [],
    submissions: const [],
  );
}

class _FakeEditor extends EmployerEditor {
  _FakeEditor({this.profile});

  /// Null is "no employer profile yet", which is its own attention row now —
  /// see the MT-010 group.
  final EmployerProfile? profile;

  @override
  Future<EmployerEditorState> build() async =>
      EmployerEditorState(
        type: profile?.type ?? 'organisation',
        profile: profile,
      );
}

EmployerProfile _employer({bool complete = true, int percent = 100}) =>
    EmployerProfile.fromJson({
      'type': 'company',
      'legalName': 'Uzum Technologies',
      'verificationStatus': 'verified',
      'completenessPercent': percent,
      'isComplete': complete,
      'canPublish': complete,
      'missingFields': const <dynamic>[],
    });
