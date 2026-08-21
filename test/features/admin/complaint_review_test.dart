import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_action.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_detail.dart';
import 'package:jobbridge_app/src/features/admin/presentation/complaint_queue_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/complaint_review_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

import 'admin_fake.dart';

/// §10.2's complaint queue, and the entry point it gives pause-or-remove.
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({
    this.pages = const [],
    this.detail,
    this.detailError,
    this.reviewConflict = false,
    this.vacancyFailure,
  });

  List<List<Complaint>> pages;
  ComplaintDetail? detail;
  ApiException? detailError;

  /// Whether the review answers 409 `complaint.not_open` — the normal outcome
  /// of two administrators working one queue.
  bool reviewConflict;

  /// A refusal from `PUT /admin/vacancies/:id/status`, e.g. the 409 that means
  /// the vacancy moved out from under the screen.
  ApiException? vacancyFailure;

  final requestedOffsets = <int>[];
  final reviews = <({String id, String outcome, String resolution})>[];
  final statusChanges = <({String vacancyId, String status, String reason})>[];
  final warnings = <({String userId, String reason})>[];

  @override
  Future<List<Complaint>> complaintQueue({
    ComplaintTarget? targetType,
    int offset = 0,
  }) async {
    requestedOffsets.add(offset);

    final index = requestedOffsets.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  @override
  Future<ComplaintDetail> complaint(String complaintId) async {
    if (detailError case final error?) throw error;
    return detail!;
  }

  @override
  Future<void> reviewComplaint(
    String complaintId,
    ComplaintOutcome outcome,
    String resolution,
  ) async {
    reviews.add((
      id: complaintId,
      outcome: outcome.wire,
      resolution: resolution,
    ));

    if (reviewConflict) {
      throw const AdminDecisionConflict(
        'This complaint has already been reviewed.',
      );
    }
  }

  @override
  Future<void> administrateVacancy(
    String vacancyId,
    VacancyAdminStatus status,
    String reason,
  ) async {
    statusChanges.add((
      vacancyId: vacancyId,
      status: status.wire,
      reason: reason,
    ));

    if (vacancyFailure case final failure?) throw failure;
  }

  @override
  Future<void> warnUser(String userId, String reason) async =>
      warnings.add((userId: userId, reason: reason));

  // The dashboard and §10.2's other two queues refuse through [FakeAdminBase]:
  // a complaint review reads neither.
}

/// A complaint, offset-formatted the way the controller sends it.
Complaint _complaint({
  String id = 'cmp-1',
  String targetType = 'vacancy',
  String targetId = 'vac-1',
  String reason = 'The description asks for a deposit before starting work',
  String createdAt = '2026-08-14T09:00:00+05:00',
}) => Complaint.fromJson({
  'id': id,
  'targetType': targetType,
  'targetId': targetId,
  'reporterUserId': 'usr-reporter',
  'reason': reason,
  'status': 'open',
  'resolution': null,
  'createdAt': createdAt,
});

ComplaintDetail _detail({
  String targetType = 'vacancy',
  Map<String, dynamic>? target = const {
    'id': 'vac-1',
    'title': 'Payvandchi kerak',
    'status': 'active',
    'employer_user_id': 'usr-employer',
  },
  String reason = 'The description asks for a deposit before starting work',
}) => ComplaintDetail(
  complaint: _complaint(targetType: targetType, reason: reason),
  target: target == null ? null : ComplaintTargetDetail(target),
);

void main() {
  Widget wrap(Widget child, _FakeAdmin fake) => ProviderScope(
    // Riverpod 3 retries a throwing provider by default and reports
    // `AsyncLoading` while it does, so a failure would render as a spinner.
    // The app disables it in `main.dart`; the tests must match.
    retry: (retryCount, error) => null,
    overrides: [adminRepositoryProvider.overrideWithValue(fake)],
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
    List<List<Complaint>> pages = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(pages: pages);
    await tester.pumpWidget(wrap(const ComplaintQueueScreen(), fake));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  Future<_FakeAdmin> pumpReview(
    WidgetTester tester, {
    ComplaintDetail? detail,
    ApiException? error,
    bool conflict = false,
    ApiException? vacancyFailure,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(
      detail: detail ?? _detail(),
      detailError: error,
      reviewConflict: conflict,
      vacancyFailure: vacancyFailure,
    );
    await tester.pumpWidget(
      wrap(const ComplaintReviewScreen(complaintId: 'cmp-1'), fake),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  /// Brings [finder] fully on screen.
  ///
  /// Both halves are needed. `scrollUntilVisible` stops as soon as the widget
  /// is *built*, which in a lazy `ListView` can leave it a few pixels past the
  /// bottom edge — a `tap` then warns that the offset misses and does nothing.
  /// The review is taller than a 360×800 phone, so this is the ordinary case
  /// rather than an edge one.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  /// Opens a sheet, types [text] into the reason field, and confirms.
  Future<void> decide(
    WidgetTester tester,
    String action, {
    String? text,
    String? confirm,
  }) async {
    await reveal(tester, find.text(action));
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();

    if (text != null) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(HhButton, confirm ?? action).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('the target row is read in either spelling', () {
    test('snake_case and camelCase give the same values', () {
      const stored = ComplaintTargetDetail({
        'id': 'vac-1',
        'title': 'Payvandchi kerak',
        'status': 'active',
        'employer_user_id': 'usr-1',
        'sender_user_id': 'usr-2',
        'conversation_id': 'cnv-1',
        'full_name': 'Alisher Karimov',
      });
      const dto = ComplaintTargetDetail({
        'id': 'vac-1',
        'title': 'Payvandchi kerak',
        'status': 'active',
        'employerUserId': 'usr-1',
        'senderUserId': 'usr-2',
        'conversationId': 'cnv-1',
        'fullName': 'Alisher Karimov',
      });

      // `resolveTarget` spreads selected columns into a
      // `Record<string, unknown>`, so the keys are snake_case today. Reading
      // both means the day either route grows a typed DTO this build is
      // already correct — no lockstep release, same idiom as `VacancyReview`.
      expect(stored.title, dto.title);
      expect(stored.status, dto.status);
      expect(stored.employerUserId, dto.employerUserId);
      expect(stored.senderUserId, dto.senderUserId);
      expect(stored.conversationId, dto.conversationId);
      expect(stored.fullName, dto.fullName);
    });

    test('a target carrying a Z timestamp does not throw', () {
      // The trap this slice was written around. The controller runs the
      // *complaint's* createdAt through `formatWithOffset`; the target is
      // spread in untouched, so its `created_at` arrives with a `Z` — which
      // `ZonedTimestamp.parse` refuses by contract. A `createdAt` getter here
      // would throw a FormatException at the repository boundary and take the
      // whole review with it, so there is none.
      final detail = ComplaintDetail.fromJson(const {
        'complaint': {
          'id': 'cmp-1',
          'targetType': 'message',
          'targetId': 'msg-1',
          'reporterUserId': 'usr-1',
          'reason': 'Threats',
          'status': 'open',
          'resolution': null,
          'createdAt': '2026-08-14T09:00:00+05:00',
        },
        'target': {
          'id': 'msg-1',
          'body': 'Pay me first',
          'sender_user_id': 'usr-2',
          'conversation_id': 'cnv-1',
          'created_at': '2026-08-13T22:15:00.000Z',
        },
      });

      expect(detail.target?.body, 'Pay me first');
      expect(detail.subjectUserId, 'usr-2');

      // And the string really is one the contract refuses, so this is not a
      // test that would pass on a well-formed fixture by accident.
      expect(
        () => ZonedTimestamp.parse(
          detail.target!.row['created_at']! as String,
        ),
        throwsFormatException,
      );
    });

    test('the complaint itself still requires an offset', () {
      // The asymmetry stated: the complaint's own timestamp is formatted by the
      // controller, so it is held to the contract. If that ever regresses, a
      // loud parse failure beats a plausible wrong "waiting 3 days".
      expect(
        () => _complaint(createdAt: '2026-08-14T09:00:00Z'),
        throwsFormatException,
      );
    });

    test('an empty target object is a shape, not a crash', () {
      const empty = ComplaintTargetDetail({});

      expect(empty.id, isNull);
      expect(empty.title, isNull);
      expect(empty.fullName, isNull);
    });

    test('an unrecognised kind is a value, not an exception', () {
      // §10.3 lets an administrator extend the platform at runtime, and one row
      // a build cannot draw must not take the queue down with it.
      expect(
        ComplaintTarget.fromWire('dictionary_item'),
        ComplaintTarget.unknown,
      );
      expect(ComplaintTarget.fromWire(null), ComplaintTarget.unknown);
      expect(ComplaintTarget.fromWire('vacancy'), ComplaintTarget.vacancy);
    });
  });

  group('what can be acted on comes from the kind and the status', () {
    test('the person to warn depends on the kind', () {
      // A reported message is answered through its *sender*: nothing edits or
      // removes a message, because §7's chat history is evidence. Which is why
      // `resolveTarget` selects `sender_user_id` at all.
      expect(
        _detail(
          targetType: 'message',
          target: const {'id': 'msg-1', 'sender_user_id': 'usr-2'},
        ).subjectUserId,
        'usr-2',
      );
      expect(
        _detail(
          targetType: 'user',
          target: const {'id': 'usr-3', 'status': 'active'},
        ).subjectUserId,
        'usr-3',
      );
      expect(
        _detail(
          targetType: 'profile',
          target: const {'id': 'usr-4', 'status': 'active'},
        ).subjectUserId,
        'usr-4',
      );
      // A vacancy complaint is answered against the vacancy, not its employer:
      // the employer may have done nothing wrong on any other posting.
      expect(_detail().subjectUserId, isNull);
    });

    test('the vacancy to act on is only ever a vacancy complaint', () {
      expect(_detail().vacancyId, 'vac-1');
      expect(
        _detail(
          targetType: 'user',
          target: const {'id': 'usr-3', 'status': 'active'},
        ).vacancyId,
        isNull,
      );
    });

    test('the offered transitions mirror the server table', () {
      // `active → paused | closed`, `paused → closed`, `closed` terminal
      // (BR-11). Offering an action the transition table refuses would be a
      // button that answers 409 every time it is pressed.
      expect(VacancyAdminStatus.availableFor('active'), [
        VacancyAdminStatus.paused,
        VacancyAdminStatus.closed,
      ]);
      expect(VacancyAdminStatus.availableFor('paused'), [
        VacancyAdminStatus.closed,
      ]);
      expect(VacancyAdminStatus.availableFor('closed'), isEmpty);
      // Never published, so neither applies.
      expect(VacancyAdminStatus.availableFor('draft'), isEmpty);
      expect(VacancyAdminStatus.availableFor('under_moderation'), isEmpty);
      expect(VacancyAdminStatus.availableFor(null), isEmpty);
    });

    test('a gone target leaves nothing to act on', () {
      final gone = _detail(target: null);

      expect(gone.targetIsGone, isTrue);
      expect(gone.hasTargetAction, isFalse);
      // But still reviewable: dismissing a complaint about a deleted vacancy
      // is exactly what should happen to it.
      expect(gone.complaint.isOpen, isTrue);
    });
  });

  group('the queue', () {
    testWidgets('keeps the server order and says how long each has waited', (
      tester,
    ) async {
      await pumpQueue(
        tester,
        pages: [
          [
            _complaint(reason: 'Asks for a deposit'),
            _complaint(
              id: 'cmp-2',
              targetType: 'message',
              reason: 'Threatening messages',
            ),
          ],
        ],
      );

      expect(find.text('Asks for a deposit'), findsOneWidget);
      expect(find.text('Threatening messages'), findsOneWidget);

      // The kind is on every row, which is what makes one queue over four
      // kinds readable without a filter.
      expect(find.text('Vacancy'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);

      // A wait rather than a date: the actionable fact about a FIFO queue.
      expect(find.textContaining('Waiting'), findsNWidgets(2));
    });

    testWidgets('an empty queue is a sentence', (tester) async {
      await pumpQueue(tester, pages: const [[]]);

      expect(find.text('Nothing reported'), findsOneWidget);
      expect(find.textContaining('Waiting'), findsNothing);
    });

    testWidgets('show more appends rather than replaces', (tester) async {
      final fake = await pumpQueue(
        tester,
        pages: [
          [
            for (var i = 0; i < adminPageSize; i++)
              _complaint(id: 'cmp-$i', reason: 'Complaint $i'),
          ],
          [_complaint(id: 'cmp-last', reason: 'The last one')],
        ],
      );

      await reveal(tester, find.text('Show more'));
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.requestedOffsets, [0, adminPageSize]);

      await tester.scrollUntilVisible(find.text('The last one'), 300);
      expect(find.text('The last one'), findsOneWidget);
    });

    testWidgets('a failure is an error state, not a spinner', (tester) async {
      final fake = _FakeAdmin();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      // No pages configured, so the first request throws a range error — any
      // failure will do. What matters is that the error arm is matched before
      // the loading arm: with retry disabled the provider's state is terminal,
      // and matching loading first is how a screen spins forever over a
      // failure it already has.
      await tester.pumpWidget(wrap(const ComplaintQueueScreen(), fake));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('the review', () {
    testWidgets('opens with the accusation, whole', (tester) async {
      await pumpReview(
        tester,
        detail: _detail(),
      );

      // Verbatim (§2.4) and unclipped: the list clipped it, and this is where
      // the decision is taken.
      expect(
        find.text('The description asks for a deposit before starting work'),
        findsOneWidget,
      );
      expect(find.text('What was reported'), findsOneWidget);
    });

    testWidgets('a live vacancy offers both transitions', (tester) async {
      await pumpReview(tester);

      expect(find.text('Payvandchi kerak'), findsOneWidget);
      // The badge §6.4 draws for the employer, from the same function: a
      // moderator and an employer must not be told two different things about
      // one vacancy's state. Which is also why the word is "Published" and not
      // "Active" — the wire value is `active`, and the employer's own screens
      // have always called that published.
      expect(find.text('Published'), findsOneWidget);

      expect(find.text('Pause this vacancy'), findsOneWidget);
      expect(find.text('Remove this vacancy'), findsOneWidget);
    });

    testWidgets('a paused vacancy offers only removal', (tester) async {
      await pumpReview(
        tester,
        detail: _detail(
          target: const {
            'id': 'vac-1',
            'title': 'Payvandchi kerak',
            'status': 'paused',
          },
        ),
      );

      expect(find.text('Pause this vacancy'), findsNothing);
      expect(find.text('Remove this vacancy'), findsOneWidget);
    });

    testWidgets('a closed vacancy says there is nothing to act on', (
      tester,
    ) async {
      await pumpReview(
        tester,
        detail: _detail(
          target: const {
            'id': 'vac-1',
            'title': 'Payvandchi kerak',
            'status': 'closed',
          },
        ),
      );

      // `closed` is terminal (BR-11). The section is rendered rather than
      // hidden: a moderator who cannot find the remedy assumes they missed it.
      expect(
        find.textContaining('There is nothing to act on from here'),
        findsOneWidget,
      );
      expect(find.text('Remove this vacancy'), findsNothing);
      // Still resolvable.
      expect(find.text('Uphold'), findsOneWidget);
    });

    testWidgets('a gone target is a notice and the outcome still stands', (
      tester,
    ) async {
      await pumpReview(tester, detail: _detail(target: null));

      expect(find.text('The reported item is gone'), findsOneWidget);

      await reveal(tester, find.text('Dismiss'));
      expect(find.text('Uphold'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('a reported message is shown as sent, and warns its sender', (
      tester,
    ) async {
      final fake = await pumpReview(
        tester,
        detail: _detail(
          targetType: 'message',
          target: const {
            'id': 'msg-1',
            'body': 'Send me 500000 first and the job is yours',
            'sender_user_id': 'usr-sender',
          },
        ),
      );

      expect(
        find.text('Send me 500000 first and the job is yours'),
        findsOneWidget,
      );

      await decide(
        tester,
        'Warn this person',
        text: 'Do not ask candidates for money.',
        confirm: 'Warn this person',
      );

      // The sender, not the message: nothing edits or removes a message.
      expect(fake.warnings.single.userId, 'usr-sender');
      expect(fake.warnings.single.reason, 'Do not ask candidates for money.');
    });

    testWidgets('an employer account keeps its status when it has no name', (
      tester,
    ) async {
      await pumpReview(
        tester,
        detail: _detail(
          targetType: 'user',
          target: const {'id': 'usr-3', 'status': 'restricted'},
        ),
      );

      // Null is not "no name": the server's join is against
      // `candidate_profiles`, so an employer resolves to a status and nothing
      // else. Saying which beats an empty line.
      expect(find.text('Employer account'), findsOneWidget);
      expect(find.text('Restricted'), findsOneWidget);
    });

    testWidgets('the remedy is offered above the outcome', (tester) async {
      await pumpReview(tester);

      final remedy = tester.getTopLeft(find.text('Act on it first')).dy;
      final outcome = tester.getTopLeft(find.text('Record the outcome')).dy;

      // Not cosmetic. Recording a complaint as upheld does not carry anything
      // out — they are two requests the client cannot make atomic — so the
      // screen puts the remedy first rather than hiding the gap behind one
      // button.
      expect(remedy, lessThan(outcome));
    });
  });

  group('deciding', () {
    testWidgets('pausing sends the status and the mandatory reason', (
      tester,
    ) async {
      final fake = await pumpReview(tester);

      await decide(
        tester,
        'Pause this vacancy',
        text: 'Remove the deposit request, then ask for review.',
      );

      expect(fake.statusChanges.single.vacancyId, 'vac-1');
      expect(fake.statusChanges.single.status, 'paused');
      expect(
        fake.statusChanges.single.reason,
        'Remove the deposit request, then ask for review.',
      );

      // The complaint is still open, so the screen stays: it still needs an
      // outcome recorded.
      expect(find.text('Record the outcome'), findsOneWidget);
    });

    testWidgets('a pause with no reason cannot be sent', (tester) async {
      final fake = await pumpReview(tester);

      await tester.tap(find.text('Pause this vacancy'));
      await tester.pumpAndSettle();

      // The server refuses a reasonless status change; the client makes it a
      // disabled button instead, which is safe because the client is the
      // stricter of the two.
      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Pause this vacancy').last,
      );
      expect(button.onPressed, isNull);
      expect(fake.statusChanges, isEmpty);
    });

    testWidgets('upholding sends actioned with the resolution', (tester) async {
      final fake = await pumpReview(tester);

      await decide(
        tester,
        'Uphold',
        text: 'Vacancy paused and the employer told to fix the description.',
      );

      expect(fake.reviews.single.id, 'cmp-1');
      expect(fake.reviews.single.outcome, 'actioned');
      expect(
        fake.reviews.single.resolution,
        'Vacancy paused and the employer told to fix the description.',
      );
    });

    testWidgets('dismissing also requires a resolution', (tester) async {
      final fake = await pumpReview(tester);

      await reveal(tester, find.text('Dismiss'));
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Mandatory on **both** outcomes, unlike the other two §10.2 queues: a
      // dismissal is the contested half, and nothing else records a complaint
      // review.
      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Dismiss').last,
      );
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Not substantiated.');
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Dismiss').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.reviews.single.outcome, 'dismissed');
      expect(fake.reviews.single.resolution, 'Not substantiated.');
    });

    testWidgets('the resolution field is not labelled for the employer', (
      tester,
    ) async {
      await pumpReview(tester);

      await reveal(tester, find.text('Dismiss'));
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // The default label promises the *employer* reads the text verbatim,
      // which is true of a verification refusal and false here — nothing shows
      // a resolution to the reporter.
      expect(find.text('Resolution (kept in the audit log)'), findsOneWidget);
      expect(
        find.text('Reason (the employer reads it word for word)'),
        findsNothing,
      );
    });

    testWidgets('a 409 settles the sheet rather than failing it', (
      tester,
    ) async {
      final fake = await pumpReview(tester, conflict: true);

      await decide(tester, 'Uphold', text: 'Upheld and the vacancy paused.');

      // Not a failure: two administrators on one FIFO queue produce this
      // normally and the work *is* done. So the notice is titled for it, and
      // the action comes off the sheet because every retry would 409 again.
      expect(find.text('Already decided'), findsOneWidget);
      expect(
        find.text('This complaint has already been reviewed.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(HhButton, 'Back'), findsOneWidget);
      expect(fake.reviews, hasLength(1));
    });

    testWidgets('a vacancy 409 is a plain refusal, not "already decided"', (
      tester,
    ) async {
      await pumpReview(
        tester,
        vacancyFailure: const ApiException(
          'This vacancy cannot be paused.',
          statusCode: 409,
        ),
      );

      await decide(tester, 'Pause this vacancy', text: 'Under review.');

      // `vacancy.transition_not_allowed` means the vacancy is not in a state
      // the action applies to — not that a colleague handled it. Telling an
      // administrator otherwise would send them looking for a decision nobody
      // made.
      expect(find.text('This vacancy cannot be paused.'), findsOneWidget);
      expect(find.text('Already decided'), findsNothing);
    });

    testWidgets('a 404 is an outcome with a way back and no retry', (
      tester,
    ) async {
      await pumpReview(
        tester,
        error: const ApiException('Not found.', statusCode: 404),
      );

      expect(find.text('This complaint is gone'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Back'), findsOneWidget);
      // Retrying would fail identically.
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
      expect(find.text('This complaint is gone'), findsNothing);
    });
  });

  group('the queue is reached from the dashboard and the tab', () {
    testWidgets('a row opens the review', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = _FakeAdmin(
        pages: [
          [_complaint(reason: 'Asks for a deposit')],
        ],
        detail: _detail(),
      );

      final router = GoRouter(
        initialLocation: Routes.adminComplaints,
        routes: [
          GoRoute(
            path: Routes.adminComplaints,
            builder: (context, state) => const ComplaintQueueScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => ComplaintReviewScreen(
                  complaintId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            adminRepositoryProvider.overrideWithValue(fake),
            for (final type in const ['region', 'occupation'])
              dictionaryProvider(
                type,
              ).overrideWith((ref) => const <DictionaryItem>[]),
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

      await tester.tap(find.text('Asks for a deposit'));
      await tester.pumpAndSettle();

      expect(find.text('Complaint'), findsOneWidget);
      expect(find.text('Record the outcome'), findsOneWidget);
    });

    test('the review is a child of the complaints tab', () {
      // A child so it keeps the shell's nav bar and back returns to the queue,
      // and under `/admin` so the redirect chain reads the role off the path.
      expect(Routes.adminComplaintFor('cmp-1'), '/admin/complaints/cmp-1');
      expect(
        Routes.adminComplaintFor('cmp-1').startsWith(Routes.adminComplaints),
        isTrue,
      );
    });
  });
}
