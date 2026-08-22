import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/domain/vacancy_review.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_queue_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/moderation_queue_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/vacancy_review_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';

import 'admin_fake.dart';

/// §10.2's vacancy moderation — the administrator's half of BR-04.
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({
    this.pages = const [],
    this.review,
    this.reviewError,
    this.conflict = false,
  });

  List<List<ModerationQueueItem>> pages;
  VacancyReview? review;
  ApiException? reviewError;

  /// Whether the decision answers 409 `vacancy.not_under_moderation`.
  bool conflict;

  final requestedOffsets = <int>[];
  final decisions = <({String vacancyId, String decision, String? reason})>[];

  @override
  Future<List<ModerationQueueItem>> moderationQueue({int offset = 0}) async {
    requestedOffsets.add(offset);

    final index = requestedOffsets.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  @override
  Future<VacancyReview> vacancyForReview(String vacancyId) async {
    if (reviewError case final failure?) throw failure;
    return review!;
  }

  @override
  Future<void> moderateVacancy(
    String vacancyId,
    ModerationDecision decision, {
    String? reason,
  }) async {
    decisions.add((
      vacancyId: vacancyId,
      decision: decision.wire,
      reason: reason,
    ));

    if (conflict) {
      throw const AdminDecisionConflict('It is no longer under moderation.');
    }
  }

  // The other half of §10.2 lives behind the other segment and has its own
  // suite, the complaint queue has a third, and the dashboard a fourth. All of
  // them refuse through [FakeAdminBase] — moderation verifies nobody.
}

/// An ISO-8601 timestamp [ago] before now, in the platform's `+05:00`.
String _submittedAgo(Duration ago) {
  final wall = DateTime.now().toUtc().subtract(ago).add(
    const Duration(hours: 5),
  );

  String two(int value) => value.toString().padLeft(2, '0');

  return '${wall.year}-${two(wall.month)}-${two(wall.day)}'
      'T${two(wall.hour)}:${two(wall.minute)}:${two(wall.second)}+05:00';
}

ModerationQueueItem _item({
  required String id,
  String? title = 'Payvandchi kerak',
  String? employerName = 'Alfa Qurilish',
  Duration ago = const Duration(days: 2),
  Map<String, dynamic>? restriction,
}) => ModerationQueueItem.fromJson({
  'vacancyId': id,
  'employerUserId': 'emp-1',
  'employerName': employerName,
  'title': title,
  'submittedAt': _submittedAgo(ago),
  'restriction': restriction,
});

/// The vacancy as **today's server** sends it: the stored row, snake_case.
Map<String, dynamic> _storedRow({
  String title = 'Payvandchi kerak',
  String? description = 'Zavodda ishlash, smenali.',
  Object? salaryFrom = '5000000.00',
  Object? salaryTo,
  bool negotiable = false,
  int? workerCount = 4,
  int? ageMin,
  int? ageMax,
  String? genderId,
  String? justificationId,
  String? justificationNote,
  String? moderationReason,
}) => {
  'id': 'vac-1',
  'category': 'construction',
  'status': 'under_moderation',
  'title': title,
  'description': description,
  'worker_count': workerCount,
  'occupation_id': 'occ-1',
  'region_id': 'reg-1',
  'district_id': 'dist-1',
  'address': 'Chilonzor 12',
  'salary_from': salaryFrom,
  'salary_to': salaryTo,
  'salary_period_id': 'per-1',
  'salary_is_negotiable': negotiable,
  'starts_on': '2026-09-01',
  'ends_on': '2026-11-30',
  'deadline_on': '2026-08-31',
  'age_min': ageMin,
  'age_max': ageMax,
  'gender_id': genderId,
  'restriction_justification_id': justificationId,
  'restriction_justification_note': justificationNote,
  'moderation_reason': moderationReason,
  'employer_user_id': 'usr-employer',
};

VacancyReview _review({
  Map<String, dynamic>? row,
  List<Map<String, dynamic>> requirements = const [],
}) => VacancyReview.fromJson({
  'vacancy': row ?? _storedRow(),
  'requirements': requirements,
});

void main() {
  Widget wrap(Widget child, _FakeAdmin fake) => ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      adminRepositoryProvider.overrideWithValue(fake),
      for (final type in const ['region', 'occupation', 'gender',
          'restriction_justification'])
        dictionaryProvider(
          type,
        ).overrideWith((ref) => const <DictionaryItem>[]),
      // The requirement group headings come from the vacancy schema. Failed
      // rather than stubbed: the widget is required to fall back to the field
      // code rather than wait on a word, and that rule has its own suite.
      vacancyFieldSchemaProvider('construction').overrideWith(
        (ref) => throw const ApiException('not under test'),
      ),
    ],
    child: MaterialApp(
      theme: HhTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: child,
    ),
  );

  Future<_FakeAdmin> pumpQueue(
    WidgetTester tester, {
    List<List<ModerationQueueItem>> pages = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(pages: pages);
    await tester.pumpWidget(
      wrap(const Scaffold(body: ModerationQueueList()), fake),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  Future<_FakeAdmin> pumpReview(
    WidgetTester tester, {
    VacancyReview? review,
    ApiException? error,
    bool conflict = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(
      review: review ?? _review(),
      reviewError: error,
      conflict: conflict,
    );
    await tester.pumpWidget(
      wrap(const VacancyReviewScreen(vacancyId: 'vac-1'), fake),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('the review reads the row in either spelling', () {
    test('a snake_case row and a camelCase DTO give the same values', () {
      final stored = _review(row: _storedRow());
      final dto = _review(
        row: const {
          'id': 'vac-1',
          'title': 'Payvandchi kerak',
          'workerCount': 4,
          'occupationId': 'occ-1',
          'regionId': 'reg-1',
          'salaryFrom': 5000000,
          'salaryIsNegotiable': false,
          'deadlineOn': '2026-08-31',
        },
      );

      // One build correct against today's server *and* against the DTO
      // recorded as a backend ask. The same idiom as `unlock_required`: a
      // client that works before and after a server change beats one that has
      // to ship in lockstep with it.
      expect(stored.title, dto.title);
      expect(stored.workerCount, dto.workerCount);
      expect(stored.occupationId, dto.occupationId);
      expect(stored.regionId, dto.regionId);
      expect(stored.salaryFrom, dto.salaryFrom);
      expect(stored.deadlineOn, dto.deadlineOn);
      expect(stored.salaryIsNegotiable, isFalse);
    });

    test('pay survives arriving as a numeric string', () {
      // Postgres stores salary as `numeric`, which the driver hands over as a
      // string. `as int` would throw on a perfectly valid "5000000.00".
      expect(_review(row: _storedRow()).salaryFrom, 5000000);
      expect(
        _review(row: _storedRow(salaryFrom: 4200)).salaryFrom,
        4200,
      );
      expect(_review(row: _storedRow(salaryFrom: null)).salaryFrom, isNull);
    });

    test('an empty vacancy object is a shape, not a crash', () {
      final empty = VacancyReview.fromJson(const {});

      expect(empty.title, isNull);
      expect(empty.requirements, isEmpty);
      expect(empty.restriction, isNull);
      expect(empty.salaryIsNegotiable, isFalse);
    });
  });

  group('the employer card names two numbers and tells them apart', () {
    test('the name and both numbers are read in either spelling', () {
      final stored = _review(
        row: {
          ..._storedRow(),
          'employer_name': 'Qurilish Servis MChJ',
          'employer_phone': '+998901234567',
          'employer_contact_phone': '+998712001122',
        },
      );
      final dto = _review(
        row: {
          ..._storedRow(),
          'employerName': 'Qurilish Servis MChJ',
          'employerPhone': '+998901234567',
          'employerContactPhone': '+998712001122',
        },
      );

      expect(stored.employerName, dto.employerName);
      expect(stored.employerPhone, dto.employerPhone);
      expect(stored.employerContactPhone, dto.employerContactPhone);
      expect(stored.hasEmployerContact, isTrue);
      expect(stored.employerPhonesAgree, isFalse);
    });

    test('a row with no employer keys is a shape, not a crash', () {
      // The state the card was written for: it rendered nothing at all for the
      // day between asking for these fields and getting them, and the same
      // branch now covers an employer whose profile carries no name.
      final bare = _review(row: _storedRow());

      expect(bare.employerUserId, 'usr-employer');
      expect(bare.employerName, isNull);
      expect(bare.hasEmployerContact, isFalse);
      expect(bare.employerPhonesAgree, isFalse);
    });

    testWidgets('the published number leads and the sign-in number follows', (
      tester,
    ) async {
      await pumpReview(tester);
      expect(find.text('Employer'), findsNothing);

      await pumpReview(
        tester,
        review: _review(
          row: {
            ..._storedRow(),
            'employer_name': 'Qurilish Servis MChJ',
            'employer_phone': '+998901234567',
            'employer_contact_phone': '+998712001122',
          },
        ),
      );

      await tester.scrollUntilVisible(find.text('Employer'), 200);
      expect(find.text('Qurilish Servis MChJ'), findsOneWidget);

      // Both are shown, labelled, and the published one comes first: it is
      // what the employer chose to be reached on, and calling somebody's login
      // identity about a job posting is the wrong number to have picked. The
      // sign-in number stays because it is §10.4's user-search key.
      final contact = tester
          .getTopLeft(find.text('+998712001122'))
          .dy;
      final signIn = tester.getTopLeft(find.text('+998901234567')).dy;
      expect(contact, lessThan(signIn));
    });

    testWidgets('one number under two labels is drawn once', (tester) async {
      await pumpReview(
        tester,
        review: _review(
          row: {
            ..._storedRow(),
            'employer_name': 'Alisher Karimov',
            // A sole trader who published the number they signed up with,
            // which is the common case for an individual employer.
            'employer_phone': '+998901234567',
            'employer_contact_phone': '+998901234567',
          },
        ),
      );

      await tester.scrollUntilVisible(find.text('Employer'), 200);
      expect(find.text('+998901234567'), findsOneWidget);
      expect(find.text('Contact number'), findsOneWidget);
      // Twice would read as a data error rather than as two fields.
      expect(find.text('Sign-in number'), findsNothing);
    });

    testWidgets('there is no e-mail row, and there never will be', (
      tester,
    ) async {
      await pumpReview(
        tester,
        review: _review(
          row: {
            ..._storedRow(),
            'employer_name': 'Qurilish Servis MChJ',
            'employer_contact_phone': '+998712001122',
            // Ignored on purpose. This product has no e-mail column anywhere —
            // login is phone + OTP (§4.1) and every contact field in it is a
            // phone number. A getter for this was written on 2026-08-22 in the
            // hope the join would carry one, and removed the same day.
            'employer_email': 'hr@qurilish.uz',
          },
        ),
      );

      await tester.scrollUntilVisible(find.text('Employer'), 200);
      expect(find.text('hr@qurilish.uz'), findsNothing);
      expect(find.text('E-mail'), findsNothing);
    });
  });

  group('the BR-12 restriction is rebuilt from the row', () {
    test('an age bound alone is a restriction', () {
      final review = _review(row: _storedRow(ageMin: 18, ageMax: 40));

      expect(review.restriction?.ageMin, 18);
      expect(review.restriction?.ageMax, 40);
      expect(review.restriction?.genderId, isNull);
    });

    test('a gender bound alone is a restriction', () {
      final review = _review(row: _storedRow(genderId: 'g-1'));

      expect(review.restriction?.genderId, 'g-1');
      expect(review.restriction?.hasAgeRange, isFalse);
    });

    test('neither is no restriction at all', () {
      // Rebuilt rather than taken from the queue item, so a review reached cold
      // still shows it — and so an unrestricted vacancy shows no empty card.
      expect(_review(row: _storedRow()).restriction, isNull);
    });
  });

  group('the queue keeps the order the server chose', () {
    testWidgets('oldest first, and nothing re-sorts it', (tester) async {
      await pumpQueue(
        tester,
        pages: [
          [
            _item(
              id: 'a',
              title: 'Zavod ishchisi',
              ago: const Duration(days: 9),
            ),
            _item(id: 'b', title: 'Avtoulov haydovchisi'),
          ],
        ],
      );

      final first = tester.getTopLeft(find.text('Zavod ishchisi')).dy;
      final second = tester.getTopLeft(find.text('Avtoulov haydovchisi')).dy;
      expect(first, lessThan(second));
    });

    testWidgets('a restricted vacancy is flagged and an ordinary one is not', (
      tester,
    ) async {
      await pumpQueue(
        tester,
        pages: [
          [
            _item(
              id: 'a',
              title: 'Restricted one',
              restriction: const {'ageMin': 18, 'ageMax': 35},
            ),
            _item(id: 'b', title: 'Ordinary one'),
          ],
        ],
      );

      // One badge, on the restricted row. §10.2 requires a person to judge the
      // restriction, and a flag on every row would say nothing.
      expect(find.text('Age or gender limit'), findsOneWidget);
    });

    testWidgets('an untitled vacancy says so rather than going blank', (
      tester,
    ) async {
      await pumpQueue(
        tester,
        pages: [
          [_item(id: 'a', title: null, employerName: null)],
        ],
      );

      expect(find.text('Untitled vacancy'), findsOneWidget);
    });

    testWidgets('an empty queue explains how it fills up', (tester) async {
      await pumpQueue(tester);

      expect(find.text('No vacancy is waiting'), findsOneWidget);
      expect(
        find.text('Vacancies appear here as employers submit them for '
            'publication.'),
        findsOneWidget,
      );
    });
  });

  group('the review puts the restriction before the vacancy', () {
    testWidgets('because it is why the vacancy is on this screen', (
      tester,
    ) async {
      await pumpReview(
        tester,
        review: _review(
          row: _storedRow(
            ageMin: 18,
            ageMax: 35,
            justificationId: 'j-1',
            justificationNote: 'Heavy lifting all shift.',
          ),
        ),
      );

      final restriction = tester
          .getTopLeft(find.text('Age and gender restrictions'))
          .dy;
      final title = tester.getTopLeft(find.text('Payvandchi kerak')).dy;
      expect(restriction, lessThan(title));

      // The employer's argument, verbatim (§2.4) — a moderator judging a
      // paraphrase would be judging something the employer did not say.
      expect(find.text('Heavy lifting all shift.'), findsOneWidget);
      // And the task is stated, not just the facts.
      expect(
        find.text('A limit is only allowed where the reason genuinely '
            'requires it. Judge the reason, not the limit.'),
        findsOneWidget,
      );
    });

    testWidgets('an unrestricted vacancy shows no restriction card', (
      tester,
    ) async {
      await pumpReview(tester);

      expect(find.text('Age and gender restrictions'), findsNothing);
      expect(find.text('Payvandchi kerak'), findsOneWidget);
      // Written by the employer, shown as written (§2.4).
      expect(find.text('Zavodda ishlash, smenali.'), findsOneWidget);
    });

    testWidgets('a previous rejection reason is shown, not repeated blindly', (
      tester,
    ) async {
      await pumpReview(
        tester,
        review: _review(
          row: _storedRow(moderationReason: 'Photo did not match the job.'),
        ),
      );

      expect(find.text('Sent back before, for this'), findsOneWidget);
      expect(find.text('Photo did not match the job.'), findsOneWidget);
    });
  });

  group('a decision follows §10.2', () {
    testWidgets('publishing sends no reason and does not ask for one', (
      tester,
    ) async {
      final fake = await pumpReview(tester);

      await tester.tap(find.widgetWithText(HhButton, 'Publish').first);
      await tester.pumpAndSettle();

      expect(find.text('Publish this vacancy?'), findsOneWidget);
      expect(find.byType(HhTextField), findsNothing);

      await tester.tap(find.widgetWithText(HhButton, 'Publish').last);
      await tester.pumpAndSettle();

      // The destination, not a verb: the route takes the status it moves to.
      expect(fake.decisions.single.decision, 'active');
      expect(fake.decisions.single.reason, isNull);
    });

    testWidgets('sending back refuses until a reason exists', (tester) async {
      final fake = await pumpReview(tester);

      await tester.tap(find.widgetWithText(HhButton, 'Send back').first);
      await tester.pumpAndSettle();

      // Disabled rather than refused after the fact: the server answers
      // `vacancy.moderation_reason_required`, and §6.4 shows this text to the
      // employer verbatim as the only guidance they get.
      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Send back').last,
      );
      expect(button.onPressed, isNull);
      expect(fake.decisions, isEmpty);

      await tester.enterText(
        find.byType(HhTextField),
        '  The address is missing.  ',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(HhButton, 'Send back').last);
      await tester.pumpAndSettle();

      expect(fake.decisions.single.decision, 'rejected');
      expect(fake.decisions.single.reason, 'The address is missing.');
    });

    testWidgets('a 409 reads as already decided, not as a fault', (
      tester,
    ) async {
      final fake = await pumpReview(tester, conflict: true);

      await tester.tap(find.widgetWithText(HhButton, 'Publish').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(HhButton, 'Publish').last);
      await tester.pumpAndSettle();

      expect(find.text('Already decided'), findsOneWidget);
      expect(find.text('It is no longer under moderation.'), findsOneWidget);
      expect(fake.decisions.length, 1);
    });
  });

  group('a vacancy that has left the queue is not a fault', () {
    testWidgets('404 gets its own notice, a way back, and no retry', (
      tester,
    ) async {
      await pumpReview(
        tester,
        error: const ApiException('Not found.', statusCode: 404),
      );

      expect(find.text('This vacancy has left the queue'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Back'), findsOneWidget);
      // Retrying would fail identically, so it is not offered — the same
      // distinction UAT-15 draws on the candidate's detail screen.
      expect(find.widgetWithText(HhButton, 'Try again'), findsNothing);
    });

    testWidgets('any other failure keeps the error state and its retry', (
      tester,
    ) async {
      await pumpReview(
        tester,
        error: const ApiException('Server exploded.', statusCode: 500),
      );

      expect(find.text('Server exploded.'), findsOneWidget);
      expect(find.text('This vacancy has left the queue'), findsNothing);
    });
  });

  group('which queue is showing comes from the location', () {
    Future<void> pumpTab(WidgetTester tester, String location) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = _FakeAdmin(pages: const [[]]);
      final router = GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: Routes.adminQueue,
            builder: (context, state) => const AdminQueueScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            adminRepositoryProvider.overrideWithValue(fake),
            // The other segment's list must not fetch when it is not showing,
            // which is what makes this fake safe to leave unimplemented for it.
            verificationQueueProvider.overrideWith(_EmptyVerification.new),
          ],
          child: MaterialApp.router(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('no parameter shows the verification queue', (tester) async {
      await pumpTab(tester, Routes.adminQueue);

      expect(find.text('Nobody is waiting'), findsOneWidget);
      expect(find.text('No vacancy is waiting'), findsNothing);
    });

    testWidgets('the vacancies parameter shows the moderation queue', (
      tester,
    ) async {
      await pumpTab(
        tester,
        Routes.adminQueueWith(Routes.adminQueueVacancies),
      );

      // Not screen state: the shell keeps a branch across tab switches, so a
      // segment in a `State` would ignore a later `go` and both dashboard
      // counters would land on whichever queue was last looked at.
      expect(find.text('No vacancy is waiting'), findsOneWidget);
      expect(find.text('Nobody is waiting'), findsNothing);
    });

    testWidgets('an unrecognised value lands somewhere real', (tester) async {
      await pumpTab(tester, Routes.adminQueueWith('nonsense'));

      expect(find.text('Nobody is waiting'), findsOneWidget);
    });
  });

  group('the paths are built in one place', () {
    test('the review is a child of the moderation tab', () {
      // A child so it keeps the shell's nav bar and back returns to the queue,
      // and under `/admin` so the redirect chain reads the role off it.
      expect(
        Routes.adminVacancyReviewFor('vac-1'),
        '/admin/queue/vacancies/vac-1',
      );
      expect(
        Routes.adminVacancyReviewFor('vac-1').startsWith(Routes.adminQueue),
        isTrue,
      );
    });

    test('a queue is named in the query, not in a second path', () {
      expect(
        Routes.adminQueueWith(Routes.adminQueueVerification),
        '/admin/queue?queue=verification',
      );
    });
  });
}

/// A verification queue that answers empty without a repository call.
class _EmptyVerification extends VerificationQueue {
  @override
  Future<AdminQueuePage<VerificationQueueItem>> build() async =>
      const AdminQueuePage(items: [], hasMore: false);
}
