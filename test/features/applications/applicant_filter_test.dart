import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/applications/data/employer_applications_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:jobbridge_app/src/features/applications/domain/application_stage.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/applications/presentation/vacancy_applicants_screen.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';

/// One recorded call to `GET /vacancies/{id}/applications`.
typedef _Query = ({String vacancyId, String? status});

class _FakeApplications implements EmployerApplicationsRepository {
  _FakeApplications({this.items = const [], this.notes_ = const []});

  List<Application> items;
  List<ApplicationNote> notes_;

  final queries = <_Query>[];
  final added = <String>[];
  final moves = <String>[];

  @override
  Future<List<Application>> forVacancy(
    String vacancyId, {
    String? status,
  }) async {
    queries.add((vacancyId: vacancyId, status: status));

    // The server filters; the fake must too, or a test asserting that a stage
    // shows only its own applicants would pass on a screen sending no filter.
    return status == null
        ? items
        : items.where((i) => i.status == status).toList();
  }

  @override
  Future<ApplicationCounts> counts(String vacancyId) async =>
      const ApplicationCounts(hiredCount: 0, byStatus: {});

  @override
  Future<Application> moveStage(
    String id,
    String status, {
    String? reason,
  }) async {
    moves.add('$id:$status');
    return items.first;
  }

  @override
  Future<CandidateForEmployer> candidate(String id) async =>
      CandidateForEmployer.fromJson(const {
        'candidateUserId': 'cand-1',
        'fullName': 'Aziza Karimova',
        'completenessPercent': 90,
        'canViewFiles': false,
        'exposureReason': 'application',
        'files': <dynamic>[],
      });

  @override
  Future<List<ApplicationNote>> notes(String id) async => notes_;

  @override
  Future<void> addNote(String id, String note) async => added.add(note);
}

Application _application({required String id, required String status}) =>
    Application.fromJson({
      'id': id,
      'vacancyId': 'vac-1',
      'candidateUserId': 'cand-$id',
      'status': status,
      'createdAt': '2026-08-19T10:00:00+05:00',
      'updatedAt': '2026-08-19T10:00:00+05:00',
    });

void main() {
  Finder chip(String label) => find.widgetWithText(HhFilterChip, label);

  Future<_FakeApplications> pump(
    WidgetTester tester, {
    List<Application> items = const [],
    List<ApplicationNote> notes = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeApplications(items: items, notes_: notes);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          employerApplicationsRepositoryProvider.overrideWithValue(fake),
          // §7.4's invitation half of the counts card; not under test here.
          invitationCountsProvider(
            'vac-1',
          ).overrideWith((ref) async => const <String, int>{}),
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

    return fake;
  }

  group('§6.5: the stage filter is the server’s', () {
    testWidgets('the first request carries no status', (tester) async {
      final fake = await pump(
        tester,
        items: [_application(id: 'a', status: 'submitted')],
      );

      expect(fake.queries, [(vacancyId: 'vac-1', status: null)]);
    });

    testWidgets('choosing a stage re-requests with it', (tester) async {
      final fake = await pump(
        tester,
        items: [
          _application(id: 'a', status: 'submitted'),
          _application(id: 'b', status: 'hired'),
        ],
      );

      await tester.ensureVisible(chip('Hired'));
      await tester.pumpAndSettle();
      await tester.tap(chip('Hired'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The status reaches the query, which is what makes a filtered list
      // **complete** rather than filtered-over-what-was-loaded.
      expect(fake.queries.length, 2);
      expect(fake.queries.last, (vacancyId: 'vac-1', status: 'hired'));
    });

    testWidgets('every stage the server stores is offered', (tester) async {
      await pump(tester, items: [_application(id: 'a', status: 'submitted')]);

      // Driven off ApplicationStage.all, so a ninth status needs a label and
      // nothing else. Includes the exits — `withdrawn` is the candidate's to
      // set and still the thing an employer filters out.
      expect(chip('All'), findsOneWidget);
      for (final code in ApplicationStage.all) {
        expect(
          find.byWidgetPredicate(
            (w) => w is HhFilterChip && w.label.isNotEmpty,
          ),
          findsWidgets,
          reason: code,
        );
      }
      expect(ApplicationStage.all, hasLength(8));
    });

    testWidgets('an empty stage reads differently from an empty vacancy', (
      tester,
    ) async {
      await pump(tester, items: [_application(id: 'a', status: 'submitted')]);

      await tester.ensureVisible(chip('Hired'));
      await tester.pumpAndSettle();
      await tester.tap(chip('Hired'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Telling an employer looking at "Hired" that nobody has applied would
      // be false — somebody has, they are just at another stage.
      expect(find.textContaining('Nobody is at this stage'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
  });

  group('§7.3: the private note', () {
    testWidgets('the sheet says the candidate never sees it', (tester) async {
      await pump(tester, items: [_application(id: 'a', status: 'submitted')]);

      await tester.tap(find.text('Private notes'));
      await tester.pumpAndSettle();

      // A recruiter has to know for certain, or they write nothing useful.
      expect(find.textContaining('Only you can see'), findsOneWidget);
      expect(find.text('No notes yet.'), findsOneWidget);
    });

    testWidgets('a note is appended, and the field cleared', (tester) async {
      final fake = await pump(
        tester,
        items: [_application(id: 'a', status: 'submitted')],
      );

      await tester.tap(find.text('Private notes'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(HhTextField),
          matching: find.byType(TextField),
        ),
        'Asked for 8m',
      );
      await tester.tap(find.text('Add note'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.added, ['Asked for 8m']);
    });

    testWidgets('an empty note is not sent', (tester) async {
      final fake = await pump(
        tester,
        items: [_application(id: 'a', status: 'submitted')],
      );

      await tester.tap(find.text('Private notes'));
      await tester.pumpAndSettle();

      // Trimmed first, so a field holding only spaces is not a note either.
      await tester.enterText(
        find.descendant(
          of: find.byType(HhTextField),
          matching: find.byType(TextField),
        ),
        '   ',
      );
      await tester.tap(find.text('Add note'));
      await tester.pump();

      expect(fake.added, isEmpty);
    });
  });
}
