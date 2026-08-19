import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_quota.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invite_outcome.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/compose_invitation_screen.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';

/// One recorded call to `POST /invitations`.
typedef _Sent = ({
  String candidateUserId,
  String? vacancyId,
  String? occupationId,
  int? salaryFrom,
  bool? negotiable,
  String? message,
});

class _FakeInvitations implements InvitationRepository {
  _FakeInvitations({this.outcome, this.quotaValue, this.error});

  /// What `invite` answers. Defaults to a sent invitation.
  InviteOutcome? outcome;

  /// What `quota` answers. **Null models a server without the cap**, which is
  /// the state today's backend was in before the quota shipped and the state
  /// any older deployment stays in.
  InvitationQuota? quotaValue;

  /// Thrown from `invite` when set, for the refusals that are not outcomes.
  ApiException? error;

  final calls = <_Sent>[];

  @override
  Future<InvitationQuota?> quota() async => quotaValue;

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
  }) async {
    calls.add((
      candidateUserId: candidateUserId,
      vacancyId: vacancyId,
      occupationId: occupationId,
      salaryFrom: salaryFrom,
      negotiable: salaryIsNegotiable,
      message: message,
    ));

    if (error case final failure?) throw failure;

    return outcome ?? InviteSent(_invitation());
  }

  @override
  Future<List<Invitation>> received() async => const [];

  @override
  Future<List<Invitation>> sent({String? vacancyId, String? status}) async =>
      const [];

  @override
  Future<Invitation> respond(String id, String status, {String? note}) =>
      throw UnsupportedError('the employer never responds');

  @override
  Future<Map<String, int>> countsForVacancy(String vacancyId) async => const {};

  @override
  Future<Invitation> byId(String id) => throw UnsupportedError('not used');

  @override
  Future<List<InvitationEvent>> history(String id) =>
      throw UnsupportedError('not used');
}

Invitation _invitation() => Invitation.fromJson(const {
  'id': 'inv-1',
  'employerUserId': 'emp-1',
  'candidateUserId': 'cand-1',
  'status': 'sent',
  'vacancyId': 'vac-1',
  'salaryIsNegotiable': false,
  'createdAt': '2026-08-19T10:00:00+05:00',
  'updatedAt': '2026-08-19T10:00:00+05:00',
});

Vacancy _vacancy({
  required String id,
  required String title,
  required bool open,
}) => Vacancy.fromJson({
  'id': id,
  'status': open ? 'active' : 'draft',
  'fields': {'title': title},
  'missingForSubmit': const <String>[],
  'isOpenForApplications': open,
  'hiredCount': 0,
});

InvitationQuota _quota({
  required int remaining,
  int limit = 30,
  String resetsAt = '2026-08-20T00:00:00+05:00',
}) => InvitationQuota.fromJson({
  'remaining': remaining,
  'limit': limit,
  'resetsAt': resetsAt,
});

void main() {
  /// The editable box belonging to the field labelled [label].
  ///
  /// Not `find.text(label)`: the label is drawn above the box, so tapping it
  /// hits nothing. Not an index either — that breaks the moment a field is
  /// inserted, and silently, by driving the wrong one.
  Finder fieldNamed(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is HhTextField && w.label == label,
    ),
    matching: find.byType(TextField),
  );

  /// Scrolls the submit button into view, then taps it.
  ///
  /// The form is a lazy `ListView`, so in general-invitation mode — occupation,
  /// region, the negotiable switch, two pay fields, a period and a schedule —
  /// the button is below the fold and **not built at all**. Tapping it directly
  /// fails with "found 0 widgets", which reads like a missing button rather
  /// than an unmounted one. `ensureVisible` cannot help here for the same
  /// reason: it needs an element that exists.
  Future<void> tapSend(WidgetTester tester) async {
    await tester.dragUntilVisible(
      find.text('Send'),
      find.byType(ListView),
      const Offset(0, -120),
    );
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
  }

  Future<_FakeInvitations> pump(
    WidgetTester tester, {
    InvitationQuota? quota,
    InviteOutcome? outcome,
    ApiException? error,
    List<Vacancy> vacancies = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeInvitations(
      quotaValue: quota,
      outcome: outcome,
      error: error,
    );

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          invitationRepositoryProvider.overrideWith((ref) => fake),
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
          dictionaryProvider(
            'payment_period',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const ComposeInvitationScreen(
            candidateUserId: 'cand-1',
            candidateName: 'Anvar Karimov',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('sending is free, and the screen says so', () {
    // §8.2's prose reads unlock-then-invite; §7.3 lists Send invitation beside
    // two free actions and §7.4's own example needs dozens of them. The client
    // resolved it on 2026-08-19 in the server's favour, and this screen has to
    // say so — an employer who thinks inviting costs Coins will not invite.
    testWidgets('no price, balance or Coin wording anywhere', (tester) async {
      await pump(
        tester,
        quota: _quota(remaining: 12),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' | ')
          .toLowerCase();

      for (final forbidden in ['coin', 'unlock', 'uzs', 'top up']) {
        expect(
          texts.contains(forbidden),
          isFalse,
          reason: '"$forbidden" must not appear: sending is free',
        );
      }
      expect(find.textContaining('Sending is free'), findsOneWidget);
    });
  });

  group('the quota is rendered, never computed or invented', () {
    testWidgets('the server’s two figures are shown as given', (tester) async {
      await pump(
        tester,
        quota: _quota(remaining: 12),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      expect(find.text('12 of 30 invitations left today'), findsOneWidget);
    });

    testWidgets('a limit the client would never have guessed still renders', (
      tester,
    ) async {
      // The point of the fixture: 47 is not 30, not a round number and not
      // derivable from anything. A client holding a constant fails here, which
      // is the same idiom as the wallet fixture whose UZS value disagrees with
      // coins x price.
      await pump(
        tester,
        quota: _quota(remaining: 3, limit: 47),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      expect(find.text('3 of 47 invitations left today'), findsOneWidget);
    });

    testWidgets('zero blocks the send and names the reset time', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        quota: _quota(remaining: 0),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      await tester.tap(find.text('Welder'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      expect(fake.calls, isEmpty, reason: 'a spent quota must not send');
      expect(
        find.textContaining('Today’s invitations are used up'),
        findsOneWidget,
      );
      expect(find.textContaining('2026-08-20 00:00'), findsOneWidget);
    });

    testWidgets('no quota on the server blocks nothing', (tester) async {
      // This is the state every deployment without the cap is in. A form
      // disabled by an absent counter would refuse sends the API accepts, which
      // is a worse failure than showing no counter at all.
      final fake = await pump(
        tester,
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      expect(find.textContaining('invitations left today'), findsNothing);

      await tester.tap(find.text('Welder'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      expect(fake.calls, hasLength(1));
    });
  });

  group('the two shapes are mutually exclusive on the wire', () {
    testWidgets('a vacancy invitation sends a vacancy id and no occupation', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        vacancies: [
          _vacancy(id: 'v1', title: 'Welder', open: true),
          _vacancy(id: 'v2', title: 'Driver', open: true),
        ],
      );

      await tester.tap(find.text('Driver'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      expect(fake.calls.single.vacancyId, 'v2');
      expect(fake.calls.single.occupationId, isNull);
    });

    testWidgets('a general invitation sends an occupation and no vacancy', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      // Choose the vacancy first, then switch shape: the binding from the shape
      // being left behind must not travel, or the server answers
      // `invitation.shape_invalid`.
      await tester.tap(find.text('Welder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('General invitation'));
      await tester.pumpAndSettle();

      await tester.tap(fieldNamed('Occupation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Payvandchi').last);
      await tester.pumpAndSettle();

      await tapSend(tester);

      expect(fake.calls.single.occupationId, 'occ-1');
      expect(
        fake.calls.single.vacancyId,
        isNull,
        reason: 'switching shape must clear the other binding',
      );
    });

    testWidgets('send is disabled until the shape has its required id', (
      tester,
    ) async {
      final fake = await pump(
        tester,
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      await tapSend(tester);

      expect(
        fake.calls,
        isEmpty,
        reason: 'no vacancy chosen: the server would answer shape_invalid',
      );
    });
  });

  group('only open vacancies can carry an invitation (BR-06)', () {
    testWidgets('a draft is not offered', (tester) async {
      await pump(
        tester,
        vacancies: [
          _vacancy(id: 'v1', title: 'Welder', open: true),
          _vacancy(id: 'v2', title: 'Unfinished draft', open: false),
        ],
      );

      expect(find.text('Welder'), findsOneWidget);
      expect(
        find.text('Unfinished draft'),
        findsNothing,
        reason: 'the server refuses it with invitation.vacancy_not_open',
      );
    });

    testWidgets('no open vacancy is a notice, not an error', (tester) async {
      // The general shape is still available, so the employer has a way forward
      // that needs nothing published.
      await pump(
        tester,
        vacancies: [_vacancy(id: 'v2', title: 'Draft', open: false)],
      );

      expect(find.text('No open vacancies'), findsOneWidget);
      expect(find.textContaining('general work invitation'), findsOneWidget);
    });
  });

  group('negotiable pay excludes a figure rather than qualifying it', () {
    testWidgets('turning it on discards a typed range', (tester) async {
      final fake = await pump(tester);

      await tester.tap(find.text('General invitation'));
      await tester.pumpAndSettle();
      await tester.tap(fieldNamed('Occupation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Payvandchi').last);
      await tester.pumpAndSettle();

      await tester.enterText(fieldNamed('Pay from'), '4000000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay is negotiable'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      expect(fake.calls.single.negotiable, isTrue);
      expect(
        fake.calls.single.salaryFrom,
        isNull,
        reason: 'a negotiable figure and a stated one are different answers',
      );
    });
  });

  group('the refusals that change what the screen offers', () {
    testWidgets('a quota 409 stays on the screen with its own words', (
      tester,
    ) async {
      await pump(
        tester,
        outcome: const InviteQuotaReached(
          'You have used all 30 invitations for today.',
        ),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      await tester.tap(find.text('Welder'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      // The server's sentence, rendered rather than rebuilt in Dart — it is
      // already localized by `x-lang`.
      expect(
        find.text('You have used all 30 invitations for today.'),
        findsOneWidget,
      );
      // Still on the compose screen, not popped: the employer's draft survives.
      expect(find.text('Send'), findsOneWidget);
    });

    testWidgets('already invited reads as a fact, not a failure', (
      tester,
    ) async {
      await pump(
        tester,
        outcome: const InviteAlreadySent('This candidate is already invited.'),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      await tester.tap(find.text('Welder'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      expect(find.text('Already invited'), findsOneWidget);
    });

    testWidgets('BR-03’s 403 is a snackbar and does not stay on the form', (
      tester,
    ) async {
      // It does not change what the screen offers — the remedy is elsewhere —
      // so it is said once and the form is left as it was.
      await pump(
        tester,
        error: const ApiException(
          'Your company must be verified first.',
          statusCode: 403,
        ),
        vacancies: [_vacancy(id: 'v1', title: 'Welder', open: true)],
      );

      await tester.tap(find.text('Welder'));
      await tester.pumpAndSettle();
      await tapSend(tester);

      expect(find.text('Your company must be verified first.'), findsOneWidget);
    });
  });

  group('the domain', () {
    test('a quota with nothing left knows it', () {
      expect(_quota(remaining: 0).hasRemaining, isFalse);
      expect(_quota(remaining: 1).hasRemaining, isTrue);
    });

    test('a zero limit cannot divide by zero', () {
      // The server should never send it, and if it ever does the screen must
      // not crash on the way to saying so.
      expect(_quota(remaining: 0, limit: 0).usedFraction, 0);
    });

    test('the reset keeps the platform wall clock, not the device zone', () {
      // Rendered as 00:00 in Tashkent. `.toLocal()` would show 19:00 the
      // previous day for a viewer in London, and "resets at 19:00 yesterday" is
      // not a sentence.
      final quota = _quota(remaining: 5);

      expect(quota.resetsAt.wallClock.hour, 0);
      expect(quota.resetsAt.wallClock.day, 20);
      expect(quota.resetsAt.offset, const Duration(hours: 5));
    });

    test('a reset time without an offset is refused at the boundary', () {
      // The API contract requires an explicit numeric offset on every
      // timestamp; a loud parse failure beats a plausible wrong reset time.
      expect(
        () => _quota(remaining: 5, resetsAt: '2026-08-20T00:00:00Z'),
        throwsFormatException,
      );
    });
  });
}
