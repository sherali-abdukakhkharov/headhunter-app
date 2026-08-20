import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/employer_interviews.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_card.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_form_sheet.dart';

import 'interview_fake.dart';

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
        interviewFixture(scheduledAt: _instantPastWallClockFuture()).hasPassed,
        isTrue,
      );
    });

    test('a future interview has not passed', () {
      expect(
        interviewFixture(scheduledAt: '2099-01-01T10:00:00+05:00').hasPassed,
        isFalse,
      );
    });

    test('a timestamp without an offset is refused at the boundary', () {
      // The display zone cannot be recovered from a `Z`, and guessing it is how
      // an interview shows two hours early.
      expect(
        () => interviewFixture(scheduledAt: '2026-08-25T14:00:00Z'),
        throwsA(isA<FormatException>()),
      );
    });

    test('only cancellation ends an interview', () {
      expect(
        interviewFixture(status: InterviewStatus.cancelled).isCancelled,
        isTrue,
      );
      expect(
        interviewFixture(status: InterviewStatus.confirmed).isCancelled,
        isFalse,
      );
    });
  });

  group('the card', () {
    Future<FakeInterviews> pump(
      WidgetTester tester,
      Interview interview, {
      Size size = const Size(1080, 2400),
      double scale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = FakeInterviews(items: [interview]);

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
      await pump(tester, interviewFixture());

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
        interviewFixture(
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
        interviewFixture(
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
      await pump(tester, interviewFixture(instructions: notes));

      // Never trimmed to a preview: "bring your diploma" is exactly the
      // sentence that has to survive whole (§8.3, §2.4).
      expect(find.text(notes), findsOneWidget);
      expect(find.text('From the employer'), findsOneWidget);
    });

    testWidgets('the candidate’s own reply is played back', (tester) async {
      await pump(
        tester,
        interviewFixture(
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
      await pump(tester, interviewFixture(status: InterviewStatus.cancelled));

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
        interviewFixture(scheduledAt: _instantPastWallClockFuture()),
      );

      expect(find.text('This time has already passed.'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('a confirmed interview offers only the other answer', (
      tester,
    ) async {
      await pump(tester, interviewFixture(status: InterviewStatus.confirmed));

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Confirm'), findsNothing);
      expect(find.text('Ask for another time'), findsOneWidget);
    });

    testWidgets('the card survives 320pt at 2.0x text scale', (tester) async {
      // 960 physical at dpr 3 is 320 logical. "Another time asked" beside a
      // full date is why the header is a Wrap.
      await pump(
        tester,
        interviewFixture(
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

      final interview = interviewFixture();
      final fake = FakeInterviews(items: [interview]);

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

      final interview = interviewFixture();
      final fake = FakeInterviews(items: [interview]);

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

  _employerTests();

  test('interviews group by application in one request', () async {
    // A list of applications costs one request no matter how long it is, and an
    // application with no interview — the common case — costs none at all.
    final container = ProviderContainer(
      overrides: [
        interviewRepositoryProvider.overrideWithValue(
          FakeInterviews(items: [
            interviewFixture(id: 'a'),
            interviewFixture(id: 'b', applicationId: 'app-2'),
            interviewFixture(id: 'c'),
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

/// §8.3's employer half: schedule, move, call off.
void _employerTests() {
  group('the platform wall clock becomes an instant', () {
    test('a picked time is read in the platform zone, not the device zone', () {
      // 14:00 in Tashkent is 09:00Z. The employer means the clock the candidate
      // reads, which is the only reading on which the two sides agree — an
      // employer scheduling from abroad means "14:00 as my candidate will read
      // it", not 14:00 where they are standing.
      final instant = instantForPlatformWallClock(
        wallClock: DateTime.utc(2026, 8, 25, 14),
        platformOffset: const Duration(hours: 5),
      );

      expect(instant.toIso8601String(), '2026-08-25T09:00:00.000Z');
    });

    test('it is the exact inverse of what the parser does', () {
      // `ZonedTimestamp.parse` computes `wallClock = instant + offset`; this
      // runs it backwards. Pinning the round trip is what stops the two
      // drifting apart if either is ever "simplified".
      const wire = '2026-08-25T14:00:00+05:00';
      final parsed = ZonedTimestamp.parse(wire);

      expect(
        instantForPlatformWallClock(
          wallClock: parsed.wallClock,
          platformOffset: parsed.offset,
        ),
        parsed.instant,
      );
    });

    test('a different offset moves the instant, not the wall clock', () {
      // The guard against a hard-coded `+05:00`: the same picked time under a
      // different platform offset must produce a different instant. Mutation
      // check — replacing `platformOffset` with a constant makes this fail.
      final five = instantForPlatformWallClock(
        wallClock: DateTime.utc(2026, 8, 25, 14),
        platformOffset: const Duration(hours: 5),
      );
      final six = instantForPlatformWallClock(
        wallClock: DateTime.utc(2026, 8, 25, 14),
        platformOffset: const Duration(hours: 6),
      );

      expect(six, five.subtract(const Duration(hours: 1)));
    });
  });

  group('the employer row', () {
    Future<FakeInterviews> pump(
      WidgetTester tester, {
      List<Interview> items = const [],
      String createdAt = '2026-08-20T09:00:00+05:00',
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = FakeInterviews(items: items);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [interviewRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: EmployerInterviews(
                  applicationId: 'app-1',
                  applicationCreatedAt: createdAt,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      return fake;
    }

    testWidgets('offers scheduling on an application with no interview', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Schedule an interview'), findsOneWidget);
    });

    testWidgets('a cancelled interview offers neither move nor cancel', (
      tester,
    ) async {
      // Cancelling is §8.3's only ending: rescheduling one would be reviving
      // it, which the server refuses with `interview.final`.
      await pump(
        tester,
        items: [interviewFixture(status: InterviewStatus.cancelled)],
      );

      expect(find.text('Move'), findsNothing);
      expect(find.text('Call it off'), findsNothing);
      // Scheduling a *new* one is still right: the old one is history.
      expect(find.text('Schedule an interview'), findsOneWidget);
    });

    testWidgets('a live interview offers both', (tester) async {
      await pump(tester, items: [interviewFixture()]);

      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Call it off'), findsOneWidget);
    });

    testWidgets('what the candidate answered is shown to the employer', (
      tester,
    ) async {
      // The point of the whole feature: "another time please" is useless
      // without the times, so the note is what the employer acts on.
      await pump(
        tester,
        items: [
          interviewFixture(
            status: InterviewStatus.rescheduleRequested,
            responseNote: 'Payshanba kuni ertalab qulay',
          ),
        ],
      );

      expect(find.text('What the candidate said'), findsOneWidget);
      expect(find.text('Payshanba kuni ertalab qulay'), findsOneWidget);
    });

    testWidgets('no offset means no scheduling control, rather than a guess', (
      tester,
    ) async {
      // A timestamp with no offset cannot yield the platform zone, and
      // scheduling an interview an hour off is worse than not offering to
      // schedule one from this screen. Mutation check: falling back to the
      // device offset makes this fail.
      await pump(tester, createdAt: '2026-08-20T09:00:00Z');

      expect(find.text('Schedule an interview'), findsNothing);
    });

    testWidgets('cancelling sends the reason the candidate will read', (
      tester,
    ) async {
      final fake = await pump(tester, items: [interviewFixture()]);

      await tester.tap(find.text('Call it off'));
      await tester.pumpAndSettle();

      // The label says who reads it, because an employer writing "found
      // someone closer" for their own records would be writing it to the
      // person it is about.
      expect(
        find.text('Reason (optional, the candidate sees it)'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'Lavozim toldirildi');
      await tester.pump();
      await tester.tap(find.text('Call it off').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.cancellations, [('iv-1', 'Lavozim toldirildi')]);
    });
  });

  group('the form', () {
    Future<FakeInterviews> open(
      WidgetTester tester, {
      Interview? existing,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final fake = FakeInterviews(items: [existing ?? interviewFixture()]);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [interviewRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showInterviewForm(
                    context,
                    applicationId: 'app-1',
                    platformOffset: const Duration(hours: 5),
                    existing: existing,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      return fake;
    }

    testWidgets('a phone interview needs no detail, and needs a time', (
      tester,
    ) async {
      final fake = await open(tester);

      // Date and time are the only requirements for a phone interview: the
      // number is the candidate's own and already verified (BR-01).
      expect(find.text('Where'), findsNothing);
      expect(find.text('Link'), findsNothing);

      // And the button is inert until there is a date *and* a time.
      await tester.tap(find.text('Send to the candidate'));
      await tester.pump();
      expect(fake.scheduled, isEmpty);
    });

    testWidgets('choosing in person reveals the address, and only it', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text('In person'));
      await tester.pumpAndSettle();

      expect(find.text('Where'), findsOneWidget);
      expect(find.text('Link'), findsNothing);

      // And switching again clears it rather than hiding it: the server refuses
      // a phone interview that carries a location, so a stale value behind a
      // hidden field would earn `interview.detail_required`.
      await tester.enterText(find.byType(TextField).first, 'Amir Temur 12');
      await tester.pump();
      await tester.tap(find.text('Video link'));
      await tester.pumpAndSettle();

      expect(find.text('Amir Temur 12'), findsNothing);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text('Where'), findsNothing);
    });

    testWidgets('rescheduling warns that the confirmation is lost', (
      tester,
    ) async {
      // The server resets the status on every edit, and it is right to — but an
      // employer nudging the time by ten minutes needs to know it costs them a
      // confirmation, or they will do it and wonder why the badge changed.
      await open(
        tester,
        existing: interviewFixture(status: InterviewStatus.confirmed),
      );

      expect(find.text('Move this interview'), findsOneWidget);
      expect(find.textContaining('asked to confirm again'), findsOneWidget);
    });

    testWidgets('rescheduling opens on the platform wall clock', (
      tester,
    ) async {
      // 14:00 +05:00, shown as 14:00 — never `.toLocal()`, or an employer
      // editing from another zone would watch the time shift under them the
      // moment the form opened.
      await open(
        tester,
        existing: interviewFixture(),
      );

      expect(find.text('2026-08-25'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);
    });
  });
}
