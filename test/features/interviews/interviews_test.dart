import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_card.dart';

/// §8.3's interviews, the candidate's side (UAT-09).
class _FakeInterviews implements InterviewRepository {
  _FakeInterviews({this.items = const []});

  List<Interview> items;

  final responses = <(String id, String status, String? note)>[];

  @override
  Future<List<Interview>> mine() async => items;

  @override
  Future<Interview> respond(String id, String status, {String? note}) async {
    responses.add((id, status, note));
    return items.firstWhere((i) => i.id == id);
  }

  @override
  Future<List<Interview>> forApplication(String applicationId) async =>
      items.where((i) => i.applicationId == applicationId).toList();

  @override
  Future<List<InterviewEvent>> history(String id) =>
      throw UnsupportedError('no history surface yet');
}

Interview _interview({
  String id = 'iv-1',
  String applicationId = 'app-1',
  String type = InterviewType.phone,
  String status = InterviewStatus.scheduled,
  String scheduledAt = '2026-08-25T14:00:00+05:00',
  String? location,
  String? meetingLink,
  String? instructions,
  String? responseNote,
}) => Interview.fromJson({
  'id': id,
  'applicationId': applicationId,
  'type': type,
  'scheduledAt': scheduledAt,
  'location': location,
  'meetingLink': meetingLink,
  'instructions': instructions,
  'status': status,
  'responseNote': responseNote,
  'respondedAt': null,
  'createdAt': '2026-08-20T09:00:00+05:00',
  'updatedAt': '2026-08-20T09:00:00+05:00',
});

/// A wire timestamp whose **instant** is [ago] in the past while its **wall
/// clock** is still in the future, which is only possible because the platform
/// offset is +05:00.
///
/// This is the fixture that tells the two readings apart: anything comparing
/// the wall clock to `DateTime.now()` says the interview has not happened yet.
String _instantPastWallClockFuture({Duration ago = const Duration(hours: 1)}) {
  final instant = DateTime.now().toUtc().subtract(ago);
  final wall = instant.add(const Duration(hours: 5));
  String two(int v) => v.toString().padLeft(2, '0');

  return '${wall.year}-${two(wall.month)}-${two(wall.day)}'
      'T${two(wall.hour)}:${two(wall.minute)}:${two(wall.second)}+05:00';
}

void main() {
  group('§8.3: the two actions follow the status, never a fixed pair', () {
    test('a scheduled interview offers both', () {
      expect(InterviewStatus.responsesFor(InterviewStatus.scheduled), [
        InterviewStatus.confirmed,
        InterviewStatus.rescheduleRequested,
      ]);
    });

    test('a confirmed one cannot confirm again', () {
      // And it can still ask for another time — that is the whole reason
      // `confirmed` is not terminal: plans change.
      expect(InterviewStatus.responsesFor(InterviewStatus.confirmed), [
        InterviewStatus.rescheduleRequested,
      ]);
    });

    test('one already asking cannot ask again', () {
      expect(
        InterviewStatus.responsesFor(InterviewStatus.rescheduleRequested),
        [InterviewStatus.confirmed],
      );
    });

    test('a cancelled one offers nothing', () {
      expect(InterviewStatus.responsesFor(InterviewStatus.cancelled), isEmpty);
    });

    test('an unknown status offers nothing rather than throwing', () {
      // A server that adds a fifth state should leave the controls off, not
      // crash the list.
      expect(InterviewStatus.responsesFor('rescheduled_by_alien'), [
        InterviewStatus.confirmed,
        InterviewStatus.rescheduleRequested,
      ]);
      expect(InterviewStatus.canRespond('anything', 'hired'), isFalse);
    });
  });

  group('the domain', () {
    test('hasPassed compares instants, not wall clocks', () {
      // The fixture's wall clock is four hours in the *future* and its instant
      // an hour in the past. Reading the wall clock would tell a candidate
      // abroad that an interview they missed is still to come — the direction
      // that costs somebody a job. Mutation check: comparing
      // `scheduledAt.wallClock` to `DateTime.now()` makes this fail.
      expect(
        _interview(scheduledAt: _instantPastWallClockFuture()).hasPassed,
        isTrue,
      );
    });

    test('a future interview has not passed', () {
      expect(_interview(scheduledAt: '2099-01-01T10:00:00+05:00').hasPassed,
          isFalse);
    });

    test('a timestamp without an offset is refused at the boundary', () {
      // The display zone cannot be recovered from a `Z`, and guessing it is how
      // an interview shows two hours early.
      expect(
        () => _interview(scheduledAt: '2026-08-25T14:00:00Z'),
        throwsA(isA<FormatException>()),
      );
    });

    test('only cancellation ends an interview', () {
      expect(_interview(status: InterviewStatus.cancelled).isCancelled, isTrue);
      expect(
        _interview(status: InterviewStatus.confirmed).isCancelled,
        isFalse,
      );
    });
  });

  group('the card', () {
    Future<_FakeInterviews> pump(
      WidgetTester tester,
      Interview interview, {
      Size size = const Size(1080, 2400),
      double scale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = _FakeInterviews(items: [interview]);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [interviewRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: InterviewCard(interview: interview),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      return fake;
    }

    testWidgets('a phone interview says what will be called', (tester) async {
      // The one type with no detail field of its own: without this line a
      // card would be a time and a word. The number is already verified
      // (BR-01), which is why the employer was never asked to retype it.
      await pump(tester, _interview());

      expect(find.text('Phone call'), findsOneWidget);
      expect(
        find.text('The employer will call the number on your profile.'),
        findsOneWidget,
      );
    });

    testWidgets('an in-person interview shows where, and no link row', (
      tester,
    ) async {
      await pump(
        tester,
        _interview(
          type: InterviewType.inPerson,
          location: 'Toshkent, Amir Temur 12, 3-qavat',
        ),
      );

      expect(find.text('In person'), findsOneWidget);
      expect(find.text('Where'), findsOneWidget);
      expect(find.text('Toshkent, Amir Temur 12, 3-qavat'), findsOneWidget);
      expect(find.text('Link'), findsNothing);
      // The phone line belongs to the phone type only, or every interview would
      // tell the candidate to expect a call.
      expect(
        find.textContaining('will call the number'),
        findsNothing,
      );
    });

    testWidgets('a link is offered as copy, never as a tap-to-open', (
      tester,
    ) async {
      // Opening it needs `url_launcher`, and pubspec.yaml's bounds are
      // load-bearing. The browser takes it from the clipboard, exactly as the
      // dialler takes a phone number.
      await pump(
        tester,
        _interview(
          type: InterviewType.externalLink,
          meetingLink: 'https://meet.example.com/abc-defg-hij',
        ),
      );

      expect(find.text('Video link'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(
        find.text('https://meet.example.com/abc-defg-hij'),
        findsOneWidget,
      );
    });

    testWidgets('the employer’s instructions are shown whole', (tester) async {
      const notes = 'Diplomingizni va ish daftaringizni olib keling. '
          'Kirishda qorovulga mening ismimni aytsangiz kifoya.';
      await pump(tester, _interview(instructions: notes));

      // Never trimmed to a preview: "bring your diploma" is exactly the
      // sentence that has to survive whole (§8.3, §2.4).
      expect(find.text(notes), findsOneWidget);
      expect(find.text('From the employer'), findsOneWidget);
    });

    testWidgets('the candidate’s own reply is played back', (tester) async {
      await pump(
        tester,
        _interview(
          status: InterviewStatus.rescheduleRequested,
          responseNote: 'Payshanba kuni ertalab qulay',
        ),
      );

      expect(find.text('Your reply'), findsOneWidget);
      expect(find.text('Payshanba kuni ertalab qulay'), findsOneWidget);
    });

    testWidgets('a cancelled interview names who called it off', (
      tester,
    ) async {
      // §8.3 gives cancelling to the employer alone, and a candidate reading
      // "cancelled" would otherwise wonder whether they had done it.
      await pump(tester, _interview(status: InterviewStatus.cancelled));

      expect(
        find.text('The employer called this interview off.'),
        findsOneWidget,
      );
      expect(find.text('Confirm'), findsNothing);
      expect(find.text('Ask for another time'), findsNothing);
    });

    testWidgets('a time that has passed is said, and still answerable', (
      tester,
    ) async {
      // Hiding it would hide the record of what was arranged. The actions stay
      // because the server still accepts them: a candidate who was ill can ask
      // for another time, and refusing here would be the client deciding on the
      // employer's behalf that it is too late.
      await pump(
        tester,
        _interview(scheduledAt: _instantPastWallClockFuture()),
      );

      expect(find.text('This time has already passed.'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('a confirmed interview offers only the other answer', (
      tester,
    ) async {
      await pump(tester, _interview(status: InterviewStatus.confirmed));

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Confirm'), findsNothing);
      expect(find.text('Ask for another time'), findsOneWidget);
    });

    testWidgets('the card survives 320pt at 2.0x text scale', (tester) async {
      // 960 physical at dpr 3 is 320 logical. "Another time asked" beside a
      // full date is why the header is a Wrap.
      await pump(
        tester,
        _interview(
          type: InterviewType.inPerson,
          status: InterviewStatus.rescheduleRequested,
          location: 'Toshkent shahri, Yunusobod tumani, Amir Temur 12',
          instructions: 'Diplomingizni olib keling.',
          responseNote: 'Payshanba kuni ertalab qulay',
        ),
        size: const Size(960, 2400),
        scale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('responding', () {
    testWidgets('asking for another time requires saying which', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final interview = _interview();
      final fake = _FakeInterviews(items: [interview]);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [interviewRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: Scaffold(body: InterviewCard(interview: interview)),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Ask for another time'));
      await tester.pumpAndSettle();

      // The sheet is up and the send button is inert: "the candidate wants
      // another time" with no time attached is a message the employer cannot
      // act on.
      expect(find.text('Which times suit you'), findsOneWidget);
      await tester.tap(find.text('Ask for another time').last);
      await tester.pump();
      expect(fake.responses, isEmpty);

      await tester.enterText(
        find.byType(TextField),
        'Payshanba kuni ertalab',
      );
      await tester.pump();
      await tester.tap(find.text('Ask for another time').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.responses, [
        ('iv-1', InterviewStatus.rescheduleRequested, 'Payshanba kuni ertalab'),
      ]);
    });

    testWidgets('confirming needs no note', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final interview = _interview();
      final fake = _FakeInterviews(items: [interview]);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [interviewRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: Scaffold(body: InterviewCard(interview: interview)),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // And it says the answer is changeable, which is what stops somebody
      // hesitating over a tap §8.3 lets them take back.
      expect(find.text('Note (optional)'), findsOneWidget);
      expect(
        find.textContaining('you can still ask for another time'),
        findsOneWidget,
      );

      await tester.tap(find.text('Confirm').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.responses, [('iv-1', InterviewStatus.confirmed, null)]);
    });
  });

  test('interviews group by application in one request', () async {
    // A list of applications costs one request no matter how long it is, and an
    // application with no interview — the common case — costs none at all.
    final container = ProviderContainer(
      overrides: [
        interviewRepositoryProvider.overrideWithValue(
          _FakeInterviews(items: [
            _interview(id: 'a'),
            _interview(id: 'b', applicationId: 'app-2'),
            _interview(id: 'c'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final grouped = await container.read(
      myInterviewsByApplicationProvider.future,
    );

    expect(grouped['app-1']!.map((i) => i.id), ['a', 'c']);
    expect(grouped['app-2']!.map((i) => i.id), ['b']);
    expect(grouped['app-3'], isNull);
  });
}
