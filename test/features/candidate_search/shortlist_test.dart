import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/candidate_search_screen.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/vacancy_shortlist_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

/// One recorded shortlist write.
typedef _Write = ({String vacancyId, String candidateUserId, bool shortlisted});

class _FakeSearch implements CandidateSearchRepository {
  _FakeSearch({this.items = const [], this.fails = false});

  List<CandidateCard> items;
  bool fails;

  int reads = 0;
  final writes = <_Write>[];

  @override
  Future<List<CandidateCard>> shortlist(
    String vacancyId, {
    int limit = 20,
    int offset = 0,
  }) async {
    reads++;
    if (fails) throw const ApiException('nope');
    return items;
  }

  @override
  Future<void> setShortlisted(
    String vacancyId,
    String candidateUserId, {
    required bool shortlisted,
  }) async => writes.add((
    vacancyId: vacancyId,
    candidateUserId: candidateUserId,
    shortlisted: shortlisted,
  ));

  @override
  Future<void> setSaved(String candidateUserId, {required bool saved}) async {}

  @override
  Future<List<CandidateCard>> saved() async => const [];

  @override
  Future<void> setNote(String candidateUserId, String note) async {}

  @override
  Future<List<CandidateCard>> search(Map<String, dynamic> request) async =>
      const [];

  @override
  Future<CandidateCount> count(Map<String, dynamic> request) =>
      throw UnsupportedError('not used');

  @override
  Future<Map<String, dynamic>> prefill(String vacancyId) async => const {};

  @override
  Future<CandidateForEmployer> candidate(String candidateUserId) =>
      throw UnsupportedError('§11.1: never called speculatively');
}

CandidateCard _card({
  String id = 'cand-1',
  String name = 'Aziza Karimova',
  bool shortlisted = false,
  int matchScore = 100,
}) => CandidateCard.fromJson({
  'candidateUserId': id,
  'fullName': name,
  'experienceYears': 4,
  'completenessPercent': 90,
  'salaryIsNegotiable': false,
  'isSaved': false,
  'isShortlisted': shortlisted,
  'matchScore': matchScore,
  'skills': const <dynamic>[],
  'languages': const <dynamic>[],
  'matchBreakdown': const <dynamic>[],
});

/// Serves canned responses so the repository can be tested without a server.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => _respond(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  Widget wrap(Widget child, _FakeSearch fake) => ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      candidateSearchRepositoryProvider.overrideWithValue(fake),
      dictionaryProvider(
        'region',
      ).overrideWith((ref) => const <DictionaryItem>[]),
    ],
    child: MaterialApp(
      theme: HhTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: child,
    ),
  );

  Future<_FakeSearch> pumpCard(
    WidgetTester tester, {
    required CandidateCard card,
    String? vacancyId,
    bool showMatch = true,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeSearch();

    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: SingleChildScrollView(
            child: CandidateResultCard(
              card: card,
              vacancyId: vacancyId,
              showMatch: showMatch,
            ),
          ),
        ),
        fake,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  Future<_FakeSearch> pumpScreen(
    WidgetTester tester, {
    List<CandidateCard> items = const [],
    bool fails = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeSearch(items: items, fails: fails);

    await tester.pumpWidget(
      wrap(const VacancyShortlistScreen(vacancyId: 'vac-1'), fake),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('§7.3: a shortlist belongs to a vacancy', () {
    testWidgets('a card with no vacancy offers no shortlist action', (
      tester,
    ) async {
      // The action is absent rather than disabled, and that is the point: with
      // no vacancy there is nothing to add to, and `isShortlisted` on the card
      // is false for everybody — including people who *are* shortlisted
      // somewhere — so a control here could only lie.
      await pumpCard(tester, card: _card(shortlisted: true));

      expect(find.text('Add to shortlist'), findsNothing);
      expect(find.text('Shortlisted'), findsNothing);
      // The actions that do not need a vacancy are still there.
      expect(find.text('View profile'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('a card for a vacancy offers it, in the state the card says', (
      tester,
    ) async {
      await pumpCard(tester, card: _card(), vacancyId: 'vac-1');
      expect(find.text('Add to shortlist'), findsOneWidget);

      await pumpCard(
        tester,
        card: _card(shortlisted: true),
        vacancyId: 'vac-1',
      );
      expect(find.text('Shortlisted'), findsOneWidget);
      expect(find.text('Add to shortlist'), findsNothing);
    });

    testWidgets('the write names the vacancy the card was opened for', (
      tester,
    ) async {
      final fake = await pumpCard(
        tester,
        card: _card(id: 'cand-7'),
        vacancyId: 'vac-9',
      );

      await tester.tap(find.text('Add to shortlist'));
      await tester.pumpAndSettle();

      expect(fake.writes, [
        (vacancyId: 'vac-9', candidateUserId: 'cand-7', shortlisted: true),
      ]);
    });

    testWidgets('the label flips without the list being re-fetched', (
      tester,
    ) async {
      // The card is handed a value from a list its parent loaded, so without a
      // local override the label reverts the moment the request succeeds —
      // which reads as the tap having failed. Re-fetching the list to move one
      // word would reorder the rows under the finger that tapped.
      final fake = await pumpCard(tester, card: _card(), vacancyId: 'vac-1');

      await tester.tap(find.text('Add to shortlist'));
      await tester.pumpAndSettle();

      expect(find.text('Shortlisted'), findsOneWidget);
      expect(fake.reads, 0);
    });

    testWidgets('saving flips its own label too', (tester) async {
      // Same defect, same fix, and it was shipped this way: the save label
      // never changed until something else reloaded the list.
      await pumpCard(tester, card: _card());

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
    });
  });

  group('a match score is only a number where a filter produced it', () {
    testWidgets('a search card shows it', (tester) async {
      await pumpCard(tester, card: _card(matchScore: 82));

      expect(find.text('82% match'), findsOneWidget);
    });

    testWidgets('a shortlisted card does not', (tester) async {
      // The server has nothing to have matched in an unfiltered list and scores
      // every card 100. "100% match" on every row of a shortlist reads as a
      // computed result, and is not one.
      await pumpScreen(tester, items: [_card()]);

      expect(find.text('100% match'), findsNothing);
      expect(find.textContaining('% match'), findsNothing);
    });
  });

  group('the shortlist screen', () {
    testWidgets('renders one card per shortlisted candidate', (tester) async {
      final fake = await pumpScreen(
        tester,
        items: [
          _card(id: 'a', shortlisted: true),
          _card(id: 'b', name: 'Bekzod Tursunov', shortlisted: true),
        ],
      );

      expect(fake.reads, 1);
      expect(find.text('Aziza Karimova'), findsOneWidget);
      expect(find.text('Bekzod Tursunov'), findsOneWidget);
      // Every row is on this vacancy's list, so every row offers the removal.
      expect(find.text('Shortlisted'), findsNWidgets(2));
    });

    testWidgets('removing somebody re-reads this vacancy’s list', (
      tester,
    ) async {
      // Invalidated by name: the row has to leave the screen, and no other
      // vacancy's shortlist changed.
      final fake = await pumpScreen(
        tester,
        items: [_card(shortlisted: true)],
      );

      await tester.tap(find.text('Shortlisted'));
      await tester.pumpAndSettle();

      expect(fake.writes.single.shortlisted, isFalse);
      expect(fake.reads, 2);
    });

    testWidgets('empty says nobody is shortlisted, and offers the search', (
      tester,
    ) async {
      // Not "you have shortlisted nobody": BR-02 takes a candidate who hides
      // their profile out of this list without anyone having removed them.
      await pumpScreen(tester);

      expect(find.text('Nobody is shortlisted yet'), findsOneWidget);
      // The only thing that fills a shortlist is a search, and it is two
      // screens away otherwise.
      expect(find.text('Find candidates'), findsOneWidget);
    });

    testWidgets('a failure renders the error, not a spinner', (tester) async {
      // Riverpod's retry is off app-wide, so a thrown provider stays in a
      // loading state that merely carries the error. Matching loading first
      // would spin forever.
      await pumpScreen(tester, fails: true);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('nope'), findsOneWidget);
    });
  });

  group('the repository call', () {
    Dio dioReturning(ResponseBody Function(RequestOptions o) respond) => Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3001',
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    )..httpClientAdapter = _StubAdapter(respond);

    test('asks the vacancy for its shortlist, with paging', () async {
      RequestOptions? seen;

      final repo = CandidateSearchRepository(
        dioReturning((options) {
          seen = options;
          return ResponseBody.fromString(
            '{"items":[],"groups":[]}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      await repo.shortlist('vac-1', limit: 5, offset: 10);

      // Under /vacancies, not /candidate-search: the same prefix the PUT and
      // DELETE use, even though one controller serves all three.
      expect(seen?.path, '/vacancies/vac-1/shortlist');
      expect(seen?.queryParameters, {'limit': 5, 'offset': 10});
    });

    test('a response with no items is an empty list, not a crash', () async {
      final repo = CandidateSearchRepository(
        dioReturning(
          (options) => ResponseBody.fromString(
            '{}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ),
      );

      expect(await repo.shortlist('vac-1'), isEmpty);
    });

    test('a refusal arrives as an ApiException', () async {
      final repo = CandidateSearchRepository(
        dioReturning(
          (options) => ResponseBody.fromString(
            '{"message":"vacancy.not_found"}',
            404,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ),
      );

      await expectLater(
        repo.shortlist('vac-1'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
