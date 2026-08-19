import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitations_inbox_screen.dart';

/// §8.2's candidate inbox (UAT-07).
class _FakeInvitations implements InvitationRepository {
  _FakeInvitations({this.items = const []});

  List<Invitation> items;

  /// Every response sent through this fake, so a test can assert that opening a
  /// sheet and cancelling sends nothing. Not called `sent` — that is the
  /// employer route's name on the interface being implemented.
  final responses = <(String id, String status, String? note)>[];

  @override
  Future<List<Invitation>> received() async => items;

  @override
  Future<Invitation> respond(String id, String status, {String? note}) async {
    responses.add((id, status, note));
    return items.firstWhere((i) => i.id == id);
  }

  @override
  Future<Invitation> invite({
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
  }) => throw UnsupportedError('the candidate inbox must not send invitations');

  @override
  Future<List<Invitation>> sent({String? vacancyId, String? status}) =>
      throw UnsupportedError('not the candidate’s route');

  @override
  Future<Map<String, int>> countsForVacancy(String vacancyId) =>
      throw UnsupportedError('not the candidate’s route');

  @override
  Future<Invitation> byId(String id) =>
      throw UnsupportedError('the inbox lists, it does not fetch one');

  @override
  Future<List<InvitationEvent>> history(String id) =>
      throw UnsupportedError('no history surface yet');
}

Invitation _entry({
  required String id,
  required String status,
  String? vacancyId,
  String? occupationId,
  int? salaryFrom,
  int? salaryTo,
  bool salaryIsNegotiable = false,
  String? message,
  String? responseNote,
  String? scheduleNote,
}) => Invitation.fromJson({
  'id': id,
  'employerUserId': 'emp-1',
  'candidateUserId': 'cand-1',
  'status': status,
  'vacancyId': vacancyId,
  'occupationId': occupationId,
  'regionId': null,
  'districtId': null,
  'salaryFrom': salaryFrom,
  'salaryTo': salaryTo,
  'salaryPeriodId': null,
  'salaryIsNegotiable': salaryIsNegotiable,
  'scheduleNote': scheduleNote,
  'message': message,
  'responseNote': responseNote,
  'respondedAt': null,
  'createdAt': '2026-08-18T09:30:00+05:00',
  'updatedAt': '2026-08-18T09:30:00+05:00',
});

void main() {
  Future<_FakeInvitations> pump(
    WidgetTester tester, {
    required List<Invitation> items,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeInvitations(items: items);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          invitationRepositoryProvider.overrideWith((ref) => fake),
          // Occupation labels come from the dictionary, so the fixture supplies
          // one rather than letting label resolution reach the network.
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
          // A vacancy-scoped invitation fetches its posting. Refused here so no
          // test reaches the network, which also exercises the 404 arm the
          // inbox needs: it deliberately lists invitations to vacancies that
          // have since closed.
          vacancyDetailProvider('vac-1').overrideWith(
            (ref) => throw const ApiException('gone', statusCode: 404),
          ),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const Scaffold(body: InvitationsInboxScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('the three actions follow the status, never a fixed row', () {
    testWidgets('a sent invitation offers all three', (tester) async {
      await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Ask a question'), findsOneWidget);
    });

    testWidgets('one already asking cannot ask again', (tester) async {
      // The server refuses a second `details_requested`, so offering it would
      // be offering a refusal — and the candidate must still be able to answer.
      await pump(tester, items: [
        _entry(
          id: 'a',
          status: InvitationStatus.detailsRequested,
          occupationId: 'occ-1',
        ),
      ]);

      expect(find.text('Ask a question'), findsNothing);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('an answered invitation offers nothing', (tester) async {
      await pump(tester, items: [
        _entry(
          id: 'a',
          status: InvitationStatus.accepted,
          occupationId: 'occ-1',
        ),
      ]);

      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Ask a question'), findsNothing);
    });
  });

  group('accepting is a disclosure, and it is stated before the tap', () {
    testWidgets('the sheet names the three protected fields', (tester) async {
      // BR-09's exposure is what acceptance buys, and a candidate cannot weigh
      // "your contact details" — these are exactly the three §11.1 protects.
      await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(find.textContaining('phone number'), findsOneWidget);
      expect(find.textContaining('e-mail address'), findsOneWidget);
      expect(find.textContaining('CV'), findsOneWidget);
      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });

    testWidgets('opening the sheet and cancelling sends nothing', (
      tester,
    ) async {
      final fake = await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fake.responses, isEmpty);
    });

    testWidgets('confirming sends exactly the response that was offered', (
      tester,
    ) async {
      final fake = await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();
      // The sheet's own button carries the same verb as the card's.
      await tester.tap(find.text('Decline').last);
      await tester.pumpAndSettle();

      expect(fake.responses, [('a', InvitationStatus.declined, null)]);
    });
  });

  group('a question with no question is not sent', () {
    testWidgets('the send button is disabled until something is typed', (
      tester,
    ) async {
      // "The candidate asked for details" with nothing attached gives the
      // employer nothing to answer, so the UI makes that state unreachable
      // rather than waiting for it to be filed.
      final fake = await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      await tester.tap(find.text('Ask a question'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ask a question').last);
      await tester.pumpAndSettle();
      expect(
        fake.responses,
        isEmpty,
        reason: 'an empty question must not send',
      );

      await tester.enterText(find.byType(TextField), 'Where is the site?');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ask a question').last);
      await tester.pumpAndSettle();

      expect(fake.responses, [
        ('a', InvitationStatus.detailsRequested, 'Where is the site?'),
      ]);
    });

    testWidgets('whitespace alone is not a question', (tester) async {
      final fake = await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      await tester.tap(find.text('Ask a question'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ask a question').last);
      await tester.pumpAndSettle();

      expect(fake.responses, isEmpty);
    });

    testWidgets('a decline needs no note', (tester) async {
      // Asking for a reason implies one is owed, and it is not.
      final fake = await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
      ]);

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      expect(find.textContaining('optional'), findsOneWidget);

      await tester.tap(find.text('Decline').last);
      await tester.pumpAndSettle();
      expect(fake.responses, hasLength(1));
    });
  });

  group('the two shapes render differently', () {
    testWidgets('a general invitation names itself and resolves its ids', (
      tester,
    ) async {
      await pump(tester, items: [
        _entry(
          id: 'a',
          status: InvitationStatus.sent,
          occupationId: 'occ-1',
          salaryFrom: 4000000,
          salaryTo: 6000000,
          scheduleNote: 'Six days a week, mornings',
        ),
      ]);

      expect(find.text('General invitation'), findsOneWidget);
      // BR-13: the label is shown, the id is bound. A UUID on screen would be
      // this test failing.
      expect(find.text('Payvandchi'), findsOneWidget);
      expect(find.textContaining('occ-1'), findsNothing);
      expect(find.text('4,000,000 – 6,000,000 UZS'), findsOneWidget);
      expect(find.text('Six days a week, mornings'), findsOneWidget);
    });

    testWidgets('negotiable pay replaces a figure rather than joining it', (
      tester,
    ) async {
      await pump(tester, items: [
        _entry(
          id: 'a',
          status: InvitationStatus.sent,
          occupationId: 'occ-1',
          salaryFrom: 4000000,
          salaryIsNegotiable: true,
        ),
      ]);

      expect(find.text('Pay negotiable'), findsOneWidget);
      expect(find.textContaining('4,000,000'), findsNothing);
    });

    testWidgets('a vacancy invitation is not labelled general', (tester) async {
      await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, vacancyId: 'vac-1'),
      ]);

      expect(find.text('General invitation'), findsNothing);
    });
  });

  group('the employer’s words are shown as written (§2.4)', () {
    testWidgets('the message is rendered in full, not as a preview', (
      tester,
    ) async {
      const message =
          'We are hiring for a three-month contract starting in September and '
          'would like to talk to you about it before the season begins.';

      await pump(tester, items: [
        _entry(
          id: 'a',
          status: InvitationStatus.sent,
          occupationId: 'occ-1',
          message: message,
        ),
      ]);

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('the candidate’s own reply is played back to them', (
      tester,
    ) async {
      await pump(tester, items: [
        _entry(
          id: 'a',
          status: InvitationStatus.detailsRequested,
          occupationId: 'occ-1',
          responseNote: 'Which district exactly?',
        ),
      ]);

      expect(find.text('Your reply'), findsOneWidget);
      expect(find.text('Which district exactly?'), findsOneWidget);
    });
  });

  group('no paywall reaches the candidate', () {
    // §9.1 states it for chat and §8.2 implies it here: the entitlement is the
    // employer's, so a candidate must never be shown a price for somebody
    // else's decision. Swept rather than asserted case by case, because the way
    // this regresses is a well-meaning "top up to reply" landing on the wrong
    // screen.
    testWidgets('no Coin, price or unlock wording anywhere in the inbox', (
      tester,
    ) async {
      await pump(tester, items: [
        _entry(id: 'a', status: InvitationStatus.sent, occupationId: 'occ-1'),
        _entry(
          id: 'b',
          status: InvitationStatus.accepted,
          vacancyId: 'vac-1',
        ),
      ]);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' | ')
          .toLowerCase();

      for (final forbidden in ['coin', 'unlock', 'top up', 'uzs']) {
        expect(
          texts.contains(forbidden),
          isFalse,
          reason: '"$forbidden" must never appear on a candidate surface',
        );
      }
    });
  });

  group('the design’s QA case: 320pt at 2.0x text scale', () {
    // The card header used to be a Row with a Spacer and overflowed by 32pt at
    // 360 wide with the longest status: a badge is icon **plus word**, so
    // truncating it puts the state back on colour alone, and the timestamp has
    // to yield instead. Pinned at the worst case the design specifies rather
    // than at the width that happened to fail.
    testWidgets('the longest status and a timestamp do not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final fake = _FakeInvitations(items: [
        _entry(
          id: 'a',
          status: InvitationStatus.detailsRequested,
          occupationId: 'occ-1',
        ),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            invitationRepositoryProvider.overrideWith((ref) => fake),
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
          ],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(body: InvitationsInboxScreen()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Details requested'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('an empty inbox says what would fill it', (tester) async {
      await pump(tester, items: []);

      expect(
        find.textContaining('Employers who invite you'),
        findsOneWidget,
      );
    });
  });
}
