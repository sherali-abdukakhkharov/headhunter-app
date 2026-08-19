import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_quota.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invite_outcome.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/sent_invitations_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';

/// One recorded call to `GET /invitations/sent`, with the filters it carried.
typedef _Query = ({String? vacancyId, String? status});

class _FakeInvitations implements InvitationRepository {
  _FakeInvitations({this.items = const [], this.error});

  List<Invitation> items;
  ApiException? error;

  final queries = <_Query>[];

  @override
  Future<List<Invitation>> sent({String? vacancyId, String? status}) async {
    queries.add((vacancyId: vacancyId, status: status));

    if (error case final failure?) throw failure;

    // The server filters; the fake has to as well, or a test asserting that
    // "Accepted" shows only acceptances would pass on a screen that sent no
    // filter at all.
    return status == null
        ? items
        : items.where((i) => i.status == status).toList();
  }

  @override
  Future<List<Invitation>> received() async => const [];

  @override
  Future<InvitationQuota?> quota() async => null;

  @override
  Future<Map<String, int>> countsForVacancy(String vacancyId) async => const {};

  @override
  Future<InviteOutcome> invite({
    required String candidateUserId,
    String? vacancyId,
    String? occupationId,
    String? regionId,
    String? districtId,
    int? salaryFrom,
    int? salaryTo,
    String? salaryPeriodId,
    bool? salaryIsNegotiable,
    String? scheduleNote,
    String? message,
  }) => throw UnsupportedError('not the screen under test');

  @override
  Future<Invitation> respond(String id, String status, {String? note}) =>
      throw UnsupportedError('the employer never responds');

  @override
  Future<Invitation> byId(String id) => throw UnsupportedError('not used');

  @override
  Future<List<InvitationEvent>> history(String id) =>
      throw UnsupportedError('not used');
}

/// Counts reads of §11.1's protected-data route.
///
/// The whole reason this fake exists is one assertion: **rendering rows must
/// not call `candidate`.** Its contract says every call is a logged access and
/// so it "is never called speculatively", and a list that resolved a name per
/// row would write one audit entry per row into the log BR-09 exists to make
/// meaningful. Counting is the only way to state that in a test — a name simply
/// being absent from the screen would also pass if the request were made and
/// the result thrown away.
class _CountingCandidates implements CandidateSearchRepository {
  int reads = 0;

  @override
  Future<CandidateForEmployer> candidate(String candidateUserId) async {
    reads++;
    throw UnsupportedError('no row may reach for a candidate');
  }

  @override
  Future<List<CandidateCard>> search(Map<String, dynamic> request) async =>
      const [];

  @override
  Future<CandidateCount> count(Map<String, dynamic> request) =>
      throw UnsupportedError('not used');

  @override
  Future<Map<String, dynamic>> prefill(String vacancyId) async => const {};

  @override
  Future<List<CandidateCard>> saved() async => const [];

  @override
  Future<void> setSaved(String candidateUserId, {required bool saved}) async {}

  @override
  Future<void> setNote(String candidateUserId, String note) async {}

  @override
  Future<void> setShortlisted(
    String vacancyId,
    String candidateUserId, {
    required bool shortlisted,
  }) async {}
}

Invitation _entry({
  required String id,
  String status = InvitationStatus.sent,
  String? vacancyId = 'vac-1',
  String? occupationId,
  String? candidateName,
  String? message,
  String? responseNote,
  String createdAt = '2026-08-19T10:00:00+05:00',
}) => Invitation.fromJson({
  'id': id,
  'employerUserId': 'emp-1',
  'candidateUserId': 'cand-$id',
  'status': status,
  'vacancyId': ?vacancyId,
  'occupationId': ?occupationId,
  'candidateName': ?candidateName,
  'message': ?message,
  'responseNote': ?responseNote,
  'salaryIsNegotiable': false,
  'createdAt': createdAt,
  'updatedAt': createdAt,
});

Vacancy _vacancy({required String id, required String title}) =>
    Vacancy.fromJson({
      'id': id,
      'status': 'active',
      'fields': {'title': title},
      'missingForSubmit': const <String>[],
      'isOpenForApplications': true,
      'hiredCount': 0,
    });

void main() {
  /// A filter chip by its label, not just the text — "Accepted" is also a badge
  /// on the cards below, so `find.text` would match two widgets and tap the
  /// wrong one.
  Finder chip(String label) => find.widgetWithText(HhFilterChip, label);

  /// Scrolls a filter chip into view, then taps it.
  ///
  /// Five statuses do not fit 360pt, so "Accepted" and "Declined" start off
  /// screen and a bare `tap` misses — silently hitting whatever is at those
  /// coordinates rather than failing. The chips live in a plain `Row`, which
  /// builds all of them, so `ensureVisible` works here where a lazy list would
  /// have needed `dragUntilVisible`.
  Future<void> tapChip(WidgetTester tester, String label) async {
    await tester.ensureVisible(chip(label));
    await tester.pumpAndSettle();
    await tester.tap(chip(label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<(_FakeInvitations, _CountingCandidates)> pump(
    WidgetTester tester, {
    List<Invitation> items = const [],
    List<Vacancy> vacancies = const [],
    String? vacancyId,
    ApiException? error,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final invitations = _FakeInvitations(items: items, error: error);
    final candidates = _CountingCandidates();

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          invitationRepositoryProvider.overrideWith((ref) => invitations),
          candidateSearchRepositoryProvider.overrideWithValue(candidates),
          myVacanciesProvider.overrideWith((ref) async => vacancies),
          dictionaryProvider('occupation').overrideWith(
            (ref) => const [
              DictionaryItem(
                id: 'occ-1',
                code: 'welder',
                label: 'Payvandchi',
                sortOrder: 1,
                isActive: true,
              ),
            ],
          ),
          dictionaryProvider(
            'region',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: SentInvitationsScreen(vacancyId: vacancyId),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return (invitations, candidates);
  }

  group('the filter is the server’s, not a where over a loaded list', () {
    testWidgets('"All" sends no status parameter', (tester) async {
      final (fake, _) = await pump(tester, items: [_entry(id: 'a')]);

      expect(fake.queries, [(vacancyId: null, status: null)]);
    });

    testWidgets('choosing a status re-requests with it', (tester) async {
      final (fake, _) = await pump(
        tester,
        items: [
          _entry(id: 'a'),
          _entry(id: 'b', status: InvitationStatus.accepted),
        ],
      );

      await tapChip(tester, 'Accepted');

      // The second query carries the status. This is what makes the filtered
      // list *complete* rather than filtered-over-what-was-loaded, unlike the
      // Coin ledger's client-side filter — and the reason there is no "showing
      // some of possibly more" caveat on this screen.
      expect(fake.queries.length, 2);
      expect(fake.queries.last, (vacancyId: null, status: 'accepted'));
    });

    testWidgets('a scoped screen sends the vacancy on every query', (
      tester,
    ) async {
      final (fake, _) = await pump(
        tester,
        vacancyId: 'vac-1',
        items: [_entry(id: 'a')],
      );

      await tapChip(tester, 'Declined');

      expect(fake.queries, [
        (vacancyId: 'vac-1', status: null),
        (vacancyId: 'vac-1', status: 'declined'),
      ]);
    });

    testWidgets('every status the server knows is offered', (tester) async {
      await pump(tester, items: [_entry(id: 'a')]);

      // Driven off InvitationStatus.all rather than a literal list, so a fifth
      // status server-side needs a label and nothing else. Includes the ones no
      // employer action can produce — a filter has to offer them anyway.
      expect(chip('All'), findsOneWidget);
      for (final label in [
        'Sent',
        'Details requested',
        'Accepted',
        'Declined',
      ]) {
        expect(chip(label), findsOneWidget, reason: label);
      }
    });
  });

  group('§11.1: no row reaches for a candidate', () {
    testWidgets('rendering rows reads no protected data', (tester) async {
      final (_, candidates) = await pump(
        tester,
        items: [
          _entry(id: 'a'),
          _entry(id: 'b', status: InvitationStatus.accepted),
          _entry(id: 'c', status: InvitationStatus.detailsRequested),
        ],
      );

      expect(candidates.reads, 0);
    });

    testWidgets('the name shows when the server sends one', (tester) async {
      // `candidateName` is a field no server sends yet. Parsed already so the
      // day it lands the name appears with no client release — the same shape
      // as the quota's 404 and `unlock_required`.
      await pump(
        tester,
        items: [_entry(id: 'a', candidateName: 'Anvar Karimov')],
      );

      expect(find.text('Anvar Karimov'), findsOneWidget);
    });

    testWidgets('a row without a name renders no gap for one', (tester) async {
      final (_, candidates) = await pump(tester, items: [_entry(id: 'a')]);

      // Not a placeholder, not an id, and above all not a request: an unnamed
      // row is identified by what was sent, and "View candidate" is where the
      // deliberate access happens.
      expect(find.text('cand-a'), findsNothing);
      expect(candidates.reads, 0);
      expect(find.text('View candidate'), findsOneWidget);
    });
  });

  group('the two rows that need doing something about', () {
    testWidgets('an acceptance says contact is open and unpriced', (
      tester,
    ) async {
      await pump(
        tester,
        items: [_entry(id: 'a', status: InvitationStatus.accepted)],
      );

      expect(find.text('Contact is open'), findsOneWidget);
      // The sentence has to rule the unlock out explicitly. An employer shown a
      // paid unlock on every other candidate screen has every reason to assume
      // one is needed here, and BR-09 grants contact on an acceptance for free.
      expect(find.textContaining('No unlock needed'), findsOneWidget);
    });

    testWidgets('an unanswered invitation promises no contact', (tester) async {
      await pump(tester, items: [_entry(id: 'a')]);

      expect(find.text('Contact is open'), findsNothing);
    });

    testWidgets('a declined invitation promises no contact either', (
      tester,
    ) async {
      await pump(
        tester,
        items: [_entry(id: 'a', status: InvitationStatus.declined)],
      );

      expect(find.text('Contact is open'), findsNothing);
    });

    testWidgets('a question is shown in full, labelled as the candidate’s', (
      tester,
    ) async {
      await pump(
        tester,
        items: [
          _entry(
            id: 'a',
            status: InvitationStatus.detailsRequested,
            responseNote: 'Is transport provided, and what are the hours?',
          ),
        ],
      );

      expect(find.text("Candidate's reply"), findsOneWidget);
      expect(
        find.text('Is transport provided, and what are the hours?'),
        findsOneWidget,
      );
    });

    testWidgets('the employer’s own message is played back', (tester) async {
      await pump(
        tester,
        items: [_entry(id: 'a', message: 'We hire welders for a night shift.')],
      );

      expect(find.text('What you wrote'), findsOneWidget);
      expect(
        find.text('We hire welders for a night shift.'),
        findsOneWidget,
      );
    });
  });

  group('the subject of a row', () {
    testWidgets('a vacancy title comes from the employer’s own list', (
      tester,
    ) async {
      // Never from `GET /discovery/vacancies/:id`: that controller carries
      // `@RequireRole('candidate')`, so an employer calling it gets 403 rather
      // than a title. One request for the whole list, then a local lookup.
      await pump(
        tester,
        items: [_entry(id: 'a')],
        vacancies: [_vacancy(id: 'vac-1', title: 'Night-shift welder')],
      );

      expect(find.text('Night-shift welder'), findsOneWidget);
    });

    testWidgets('a scoped list does not repeat the vacancy on every row', (
      tester,
    ) async {
      await pump(
        tester,
        vacancyId: 'vac-1',
        items: [_entry(id: 'a'), _entry(id: 'b')],
        vacancies: [_vacancy(id: 'vac-1', title: 'Night-shift welder')],
      );

      expect(find.text('Night-shift welder'), findsNothing);
      expect(find.text('This vacancy only'), findsOneWidget);
    });

    testWidgets('a general invitation shows what it carries itself', (
      tester,
    ) async {
      await pump(
        tester,
        items: [_entry(id: 'a', vacancyId: null, occupationId: 'occ-1')],
      );

      expect(find.text('General invitation'), findsOneWidget);
      // The occupation is a dictionary id resolved to a label (BR-13), never
      // the id itself.
      expect(find.text('Payvandchi'), findsOneWidget);
      expect(find.text('occ-1'), findsNothing);
    });
  });

  group('states', () {
    testWidgets('an empty list says what would fill it', (tester) async {
      await pump(tester);

      expect(find.textContaining('Candidates you invite'), findsOneWidget);
    });

    testWidgets('a filter that matched nothing says so instead', (
      tester,
    ) async {
      await pump(tester, items: [_entry(id: 'a')]);

      await tapChip(tester, 'Declined');

      // Two different facts: one is fixed by clearing the filter, the other by
      // using the app. Telling an employer looking at "Declined" that they have
      // invited nobody would simply be false.
      expect(find.textContaining('No invitations with this status'),
          findsOneWidget);
      expect(find.textContaining('Candidates you invite'), findsNothing);
    });

    testWidgets('clearing the filter from the empty state restores the list', (
      tester,
    ) async {
      await pump(tester, items: [_entry(id: 'a')]);

      await tapChip(tester, 'Declined');

      await tester.tap(find.text('Reset'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sent'), findsWidgets);
      expect(find.textContaining('No invitations with this status'),
          findsNothing);
    });

    testWidgets('a failure is terminal and offers a retry', (tester) async {
      await pump(tester, error: const ApiException('Server unreachable'));

      // Riverpod's retry is off app-wide, so the error arm must come before any
      // loading arm or a spinner would sit over the failure forever.
      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('the design’s QA case: 320pt at 2.0x text scale', () {
    testWidgets('the longest status, a stamp and the filter row survive', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final fake = _FakeInvitations(
        items: [
          _entry(id: 'a', status: InvitationStatus.detailsRequested),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            invitationRepositoryProvider.overrideWith((ref) => fake),
            candidateSearchRepositoryProvider.overrideWithValue(
              _CountingCandidates(),
            ),
            myVacanciesProvider.overrideWith(
              (ref) async => [_vacancy(id: 'vac-1', title: 'Welder')],
            ),
          ],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SentInvitationsScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Five chips at 2.0x cannot fit 320pt, which is why they scroll rather
      // than divide the width: `HhSegmented` would have clipped "Details
      // requested" to one line, and a status filter whose labels are truncated
      // is a filter nobody can use.
      expect(tester.takeException(), isNull);
      expect(find.text('Details requested'), findsWidgets);
    });
  });

  group('the status vocabulary mirrors the server', () {
    test('all four, in the order INVITATION_STATUSES declares them', () {
      expect(InvitationStatus.all, [
        'sent',
        'details_requested',
        'accepted',
        'declined',
      ]);
    });

    test('the filter list is a superset of what a candidate can set', () {
      // Every response a candidate may make is a state an employer may filter
      // by. The reverse does not hold: `sent` is nobody's response.
      expect(
        InvitationStatus.all,
        containsAll(InvitationStatus.candidateResponses),
      );
      expect(
        InvitationStatus.candidateResponses,
        isNot(contains(InvitationStatus.sent)),
      );
    });
  });
}
