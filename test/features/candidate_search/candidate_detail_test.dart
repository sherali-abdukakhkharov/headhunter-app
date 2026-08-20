import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/applications/presentation/exposure_explanation.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/candidate_detail_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

/// §7.3's "View profile" — the screen where BR-09 **does** open.
///
/// The search-card test (`br09_no_phone_test.dart`) asserts a phone can never
/// appear. This is its other half, and it needs the same rigour for the
/// opposite reason: here a phone number is *correct* when the server sent one,
/// so the thing to pin is that the client never invents, retains or infers one
/// — and that an absence is explained rather than left as a blank line.
void main() {
  const phone = '+998901234567';

  CandidateForEmployer candidate({
    String? phone,
    bool canViewFiles = false,
    String exposureReason = 'no_interaction',
    List<Map<String, dynamic>> files = const [],
  }) => CandidateForEmployer.fromJson({
    'candidateUserId': 'cand-1',
    'fullName': 'Aziza Karimova',
    'regionId': 'region-1',
    'completenessPercent': 90,
    'canViewFiles': canViewFiles,
    'exposureReason': exposureReason,
    'files': files,
    'phone': ?phone,
  });

  Future<void> pump(
    WidgetTester tester, {
    CandidateForEmployer? subject,
    Exception? error,
    AttachmentOpener? opener,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // Mirrors main.dart: an error is terminal, so the error arm renders
        // rather than spinning forever.
        retry: (retryCount, error) => null,
        overrides: [
          searchCandidateProvider('cand-1').overrideWith(
            (ref) => error != null ? throw error : subject!,
          ),
          // Overridden even where a test never taps a file: the real opener
          // reaches for a platform channel and a temporary directory, and
          // neither exists under `flutter test`.
          attachmentOpenerProvider.overrideWithValue(
            opener ?? _RecordingOpener(),
          ),
          dictionaryProvider(
            'region',
          ).overrideWith((ref) => const <DictionaryItem>[]),
          dictionaryProvider(
            'file_purpose',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const CandidateDetailScreen(candidateUserId: 'cand-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  List<String> renderedText(WidgetTester tester) => [
    for (final widget in tester.widgetList<Text>(find.byType(Text)))
      widget.data ?? '',
  ];

  group('BR-09: the phone is the server’s decision', () {
    testWidgets('a phone the server sent is shown', (tester) async {
      // The positive case has to be asserted too. A screen that never showed a
      // phone would pass every privacy test and be useless — BR-09 is a rule
      // about *when*, not a rule against.
      await pump(
        tester,
        subject: candidate(phone: phone, exposureReason: 'application'),
      );

      expect(find.text(phone), findsOneWidget);
    });

    testWidgets('no phone means no phone-shaped text anywhere', (tester) async {
      await pump(tester, subject: candidate());

      final text = renderedText(tester).join(' | ');

      expect(text, isNot(contains(phone)));
      expect(
        RegExp(r'\+?998\s*\d').hasMatch(text),
        isFalse,
        reason: 'a phone-shaped string reached the profile: $text',
      );
      expect(
        RegExp(r'\d{7,}').hasMatch(text),
        isFalse,
        reason: 'a long digit run reached the profile: $text',
      );
    });

    testWidgets('an absent phone is explained, not left blank', (tester) async {
      // A blank where a number should be reads as a bug. This is the whole
      // reason exposureReason is rendered at all.
      await pump(tester, subject: candidate());

      expect(
        find.textContaining('applies to one of your vacancies'),
        findsOneWidget,
      );
    });

    testWidgets('the explanation follows the reason, not the absence', (
      tester,
    ) async {
      // Same missing phone, different reason — and it must not read the same.
      await pump(
        tester,
        subject: candidate(exposureReason: 'hidden_by_candidate'),
      );

      expect(find.textContaining('hidden their profile'), findsOneWidget);
      expect(
        find.textContaining('applies to one of your vacancies'),
        findsNothing,
      );
    });

    testWidgets('an allowed read with no number says exactly that', (
      tester,
    ) async {
      // `application` *permitted* contact, so nothing was withheld — the
      // candidate simply has no number on file. Saying "withheld" here would
      // accuse the platform of hiding something that does not exist.
      await pump(
        tester,
        subject: candidate(exposureReason: 'application', canViewFiles: true),
      );

      expect(find.textContaining('no phone number on file'), findsOneWidget);
    });
  });

  group('§5.4: files', () {
    testWidgets('files the server sent are listed', (tester) async {
      await pump(
        tester,
        subject: candidate(
          canViewFiles: true,
          exposureReason: 'application',
          files: const [
            {
              'id': 'f1',
              'purposeCode': 'cv',
              'fileName': 'Aziza-CV.pdf',
              'downloadPath': '/applications/a1/files/f1',
            },
          ],
        ),
      );

      expect(find.text('Aziza-CV.pdf'), findsOneWidget);
    });

    testWidgets('withheld files are stated, not silently missing', (
      tester,
    ) async {
      await pump(tester, subject: candidate());

      expect(find.text('Files not available'), findsOneWidget);
    });

    testWidgets('permitted-but-empty reads differently from withheld', (
      tester,
    ) async {
      // Two different facts. "You may not see these" and "there are none" look
      // identical if both render as nothing.
      await pump(
        tester,
        subject: candidate(canViewFiles: true, exposureReason: 'application'),
      );

      expect(find.text('Files not available'), findsNothing);
      expect(
        find.text('This candidate has not uploaded anything'),
        findsOneWidget,
      );
    });

    testWidgets('a download path is never rendered as text', (tester) async {
      // §11.1: paths are on this API, not storage URLs — and either way a path
      // on screen is an invitation to copy it somewhere it does not belong.
      await pump(
        tester,
        subject: candidate(
          canViewFiles: true,
          exposureReason: 'application',
          files: const [
            {
              'id': 'f1',
              'purposeCode': 'cv',
              'fileName': 'Aziza-CV.pdf',
              'downloadPath': '/applications/a1/files/f1',
            },
          ],
        ),
      );

      expect(
        renderedText(tester).join(' | '),
        isNot(contains('/applications/')),
      );
    });
  });

  group('a refusal is rendered as a refusal', () {
    testWidgets('a 404 shows the error state, never a spinner', (tester) async {
      // "Not findable and no interaction" is a normal answer here, and with
      // retry disabled it is terminal — matching loading first would leave a
      // spinner that resolves at no point.
      await pump(tester, error: Exception('not found'));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });

  group('every exposure reason maps to something an employer can act on', () {
    /// The six codes in `contact-exposure.ts`. If the server grows a seventh,
    /// this list is where it gets noticed.
    const reasons = [
      'admin',
      'application',
      'accepted_invitation',
      'not_verified_employer',
      'no_interaction',
      'hidden_by_candidate',
    ];

    testWidgets('no two groups share a message', (tester) async {
      late AppL10n l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final messages = {
        for (final reason in reasons) reason: exposureExplanation(reason, l10n),
      };

      // The three allowing codes share one message — contact was permitted, so
      // there is one thing to say. The three denying codes must each say
      // something different, because each is undone by a different action.
      expect(messages['admin'], messages['application']);
      expect(messages['application'], messages['accepted_invitation']);

      final denials = {
        messages['not_verified_employer'],
        messages['no_interaction'],
        messages['hidden_by_candidate'],
      };
      expect(
        denials.length,
        3,
        reason: 'two denials that read the same are two rules told apart by '
            'nothing the employer can see',
      );

      // And no denial may be mistaken for the allowed-but-empty case.
      expect(denials.contains(messages['application']), isFalse);
    });

    testWidgets('an unknown code falls back rather than throwing', (
      tester,
    ) async {
      late AppL10n l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // A server ahead of this build. Saying less is right here — inventing a
      // specific explanation for a rule we do not know would be worse.
      expect(
        exposureExplanation('some_future_rule', l10n),
        l10n.candidatePhoneHiddenWhy,
      );
    });
  });
  group('attachments open through the path the server gave', () {
    testWidgets('tapping a file downloads it and hands it to the OS', (
      tester,
    ) async {
      final opener = _RecordingOpener();

      await pump(
        tester,
        subject: candidate(
          exposureReason: 'accepted_invitation',
          canViewFiles: true,
          files: const [
            {
              'id': 'f1',
              'purposeCode': 'cv',
              'fileName': 'rezyume.pdf',
              'downloadPath': '/invitations/inv-1/files/f1/content',
            },
          ],
        ),
        opener: opener,
      );

      await tester.tap(find.text('rezyume.pdf'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // **Verbatim.** The same CV is /applications/… for an employer holding an
      // application, /invitations/… for one whose invitation was accepted and
      // /unlocks/… for one who paid, so a client that built the path would be
      // right a third of the time. This asserts the path was passed through
      // untouched rather than merely that a request happened.
      expect(opener.calls, [
        (
          downloadPath: '/invitations/inv-1/files/f1/content',
          fileId: 'f1',
          fileName: 'rezyume.pdf',
        ),
      ]);
    });

    testWidgets('a device with no viewer says so, not "check your network"', (
      tester,
    ) async {
      await pump(
        tester,
        subject: candidate(
          exposureReason: 'accepted_invitation',
          canViewFiles: true,
          files: const [
            {
              'id': 'f1',
              'purposeCode': 'cv',
              'fileName': 'rezyume.pdf',
              'downloadPath': '/invitations/inv-1/files/f1/content',
            },
          ],
        ),
        opener: _RecordingOpener(failure: const NoViewerException()),
      );

      await tester.tap(find.text('rezyume.pdf'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The bytes arrived and the server allowed it; the gap is on the phone.
      expect(find.textContaining('No app on this phone'), findsOneWidget);
    });

    testWidgets('a refusal is rendered as the server worded it', (
      tester,
    ) async {
      await pump(
        tester,
        subject: candidate(
          exposureReason: 'accepted_invitation',
          canViewFiles: true,
          files: const [
            {
              'id': 'f1',
              'purposeCode': 'cv',
              'fileName': 'rezyume.pdf',
              'downloadPath': '/invitations/inv-1/files/f1/content',
            },
          ],
        ),
        opener: _RecordingOpener(
          failure: const ApiException('This invitation was withdrawn.'),
        ),
      );

      await tester.tap(find.text('rezyume.pdf'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // BR-09 is re-evaluated per download, so a mid-session refusal is a
      // normal outcome and the server's sentence is the honest thing to show.
      expect(find.text('This invitation was withdrawn.'), findsOneWidget);
    });

    testWidgets('nothing is offered when the server sent no files', (
      tester,
    ) async {
      final opener = _RecordingOpener();

      await pump(
        tester,
        // `canViewFiles: false` is the default: the point of this case is that
        // the server sent nothing, so there is nothing to leak and nothing to
        // tap.
        subject: candidate(exposureReason: 'unlock_required'),
        opener: opener,
      );

      expect(find.byType(HhCard), findsWidgets);
      expect(opener.calls, isEmpty);
    });
  });
}

/// Records what the screen asked for, and can fail the way the device does.
class _RecordingOpener implements AttachmentOpener {
  _RecordingOpener({this.failure});

  final Exception? failure;

  final calls = <({String downloadPath, String fileId, String fileName})>[];

  @override
  Future<void> open({
    required String downloadPath,
    required String fileId,
    required String fileName,
  }) async {
    calls.add((
      downloadPath: downloadPath,
      fileId: fileId,
      fileName: fileName,
    ));
    if (failure case final f?) throw f;
  }
}
