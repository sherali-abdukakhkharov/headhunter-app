import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_dashboard.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/presentation/verification_queue_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

/// §10.2's employer verification queue, and the administrator's half of BR-03.
class _FakeAdmin implements AdminRepository {
  _FakeAdmin({this.pages = const [], this.conflictOn});

  /// One list per page, served in request order.
  List<List<VerificationQueueItem>> pages;

  /// An employer id whose decision answers 409 `verification_not_pending` —
  /// the normal outcome of two administrators working one queue.
  String? conflictOn;

  final requestedOffsets = <int>[];
  final decisions =
      <({String employerUserId, String decision, String? reason})>[];

  @override
  Future<List<VerificationQueueItem>> verificationQueue({
    int offset = 0,
  }) async {
    requestedOffsets.add(offset);

    final index = requestedOffsets.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  @override
  Future<void> decideVerification(
    String employerUserId,
    VerificationDecision decision, {
    String? reason,
  }) async {
    decisions.add((
      employerUserId: employerUserId,
      decision: decision.wire,
      reason: reason,
    ));

    if (employerUserId == conflictOn) {
      throw const VerificationAlreadyDecided(
        'This employer has already been reviewed.',
      );
    }
  }

  @override
  Future<AdminDashboard> dashboard({String? from, String? to}) =>
      throw UnsupportedError('The queue screen must not read the dashboard.');
}

class _RecordingOpener implements AttachmentOpener {
  final calls = <({String downloadPath, String fileId, String fileName})>[];

  @override
  Future<void> open({
    required String downloadPath,
    required String fileId,
    required String fileName,
  }) async => calls.add((
    downloadPath: downloadPath,
    fileId: fileId,
    fileName: fileName,
  ));
}

/// An ISO-8601 timestamp [ago] before now, written in the platform's `+05:00`.
///
/// The **wall clock** is five hours ahead of the instant, which is what makes
/// the waiting-days assertion able to fail: a comparison that reads
/// `wallClock` (UTC-flagged, so five hours in the future) against `now` loses a
/// day off any duration whose remainder is under five hours.
String _submittedAgo(Duration ago) {
  final wall = DateTime.now().toUtc().subtract(ago).add(
    const Duration(hours: 5),
  );

  String two(int value) => value.toString().padLeft(2, '0');

  return '${wall.year}-${two(wall.month)}-${two(wall.day)}'
      'T${two(wall.hour)}:${two(wall.minute)}:${two(wall.second)}+05:00';
}

VerificationQueueItem _item({
  required String id,
  String type = 'company',
  String? name = 'Qitmir Soft',
  String? legalName = '"QITMIR SOFT" MCHJ',
  String? regionId,
  Duration ago = const Duration(days: 2),
  List<Map<String, dynamic>> files = const [],
}) => VerificationQueueItem.fromJson({
  'employerUserId': id,
  'type': type,
  'name': name,
  'legalName': legalName,
  'regionId': regionId,
  'submittedAt': _submittedAgo(ago),
  'files': files,
});

void main() {
  Future<(_FakeAdmin, _RecordingOpener)> pump(
    WidgetTester tester, {
    List<List<VerificationQueueItem>> pages = const [],
    String? conflictOn,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(pages: pages, conflictOn: conflictOn);
    final opener = _RecordingOpener();

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          adminRepositoryProvider.overrideWithValue(fake),
          // Overridden even where no test taps a file: the real opener reaches
          // for a platform channel and a temporary directory, and neither
          // exists under `flutter test`.
          attachmentOpenerProvider.overrideWithValue(opener),
          dictionaryProvider(
            'region',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const VerificationQueueScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return (fake, opener);
  }

  Future<void> openSheet(WidgetTester tester, String action) async {
    await tester.tap(find.widgetWithText(HhButton, action).first);
    await tester.pumpAndSettle();
  }

  group('the queue keeps the order the server chose', () {
    testWidgets('oldest first, and nothing re-sorts it', (tester) async {
      await pump(
        tester,
        pages: [
          [
            _item(
              id: 'a',
              legalName: 'Zulfiya Savdo',
              ago: const Duration(days: 9),
            ),
            _item(
              id: 'b',
              legalName: 'Alfa Qurilish',
              ago: const Duration(days: 1),
            ),
          ],
        ],
      );

      // Alphabetically Alfa comes first. It is second on screen, because the
      // server sent it second: a queue that is not FIFO is a queue somebody
      // waits in indefinitely, and sorting by name would undo that silently.
      final zulfiya = tester.getTopLeft(find.text('Zulfiya Savdo')).dy;
      final alfa = tester.getTopLeft(find.text('Alfa Qurilish')).dy;
      expect(zulfiya, lessThan(alfa));
    });

    testWidgets('and says how long the top one has waited', (tester) async {
      await pump(
        tester,
        pages: [
          [_item(id: 'a', ago: const Duration(days: 9, hours: 2))],
        ],
      );

      // Nine, not eight. The submitted timestamp carries the platform's
      // +05:00, so comparing its wall clock to `now` would drop the day —
      // understating how long somebody has been waiting, which is the
      // direction that matters in a queue.
      expect(find.text('Waiting 9 days'), findsOneWidget);
    });

    testWidgets('a submission from today does not read as zero days', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [_item(id: 'a', ago: const Duration(hours: 3))],
        ],
      );

      expect(find.text('Submitted today'), findsOneWidget);
    });
  });

  group('the card is the review', () {
    testWidgets('legal name leads, trading name follows', (tester) async {
      await pump(
        tester,
        pages: [
          [_item(id: 'a')],
        ],
      );

      // A company is verified on its legal identity — that is what the
      // documents are about — so the registered name heads the card.
      expect(find.text('"QITMIR SOFT" MCHJ'), findsOneWidget);
      expect(find.text('Qitmir Soft'), findsOneWidget);
      expect(find.text('Company'), findsOneWidget);
    });

    testWidgets('an employer with no name says so rather than going blank', (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [_item(id: 'a', name: null, legalName: null, type: 'individual')],
        ],
      );

      expect(find.text('No name on file'), findsOneWidget);
      expect(find.text('Individual employer'), findsOneWidget);
    });

    testWidgets('a submission with no files says that too', (tester) async {
      await pump(
        tester,
        pages: [
          [_item(id: 'a')],
        ],
      );

      // The server refuses a submission missing a *required* document, not one
      // missing an optional one, so an empty list is a real state.
      expect(find.text('No documents attached'), findsOneWidget);
    });

    testWidgets('an empty queue explains how it fills up', (tester) async {
      await pump(tester);

      expect(find.text('Nobody is waiting'), findsOneWidget);
      expect(
        find.text('Submissions appear here as employers send their '
            'documents in.'),
        findsOneWidget,
      );
    });
  });

  group('evidence is followed, never constructed', () {
    testWidgets('the server-built path is passed through untouched', (
      tester,
    ) async {
      final (_, opener) = await pump(
        tester,
        pages: [
          [
            _item(
              id: 'emp-1',
              files: [
                {
                  'id': 'file-9',
                  'purposeCode': 'evidence',
                  'fileName': 'guvohnoma.pdf',
                  'path': '/admin/employers/emp-1/evidence/file-9',
                },
              ],
            ),
          ],
        ],
      );

      // Nothing is fetched until it is asked for: every read of protected data
      // is logged (§11.1), so a prefetch would write an audit entry nobody
      // asked for.
      expect(opener.calls, isEmpty);

      await tester.tap(find.text('guvohnoma.pdf'));
      await tester.pumpAndSettle();

      expect(opener.calls.single.downloadPath,
          '/admin/employers/emp-1/evidence/file-9');
      expect(opener.calls.single.fileId, 'file-9');
    });

    testWidgets("the purpose is the server's own code, not a Dart label", (
      tester,
    ) async {
      await pump(
        tester,
        pages: [
          [
            _item(
              id: 'emp-1',
              files: [
                {
                  'id': 'file-9',
                  'purposeCode': 'evidence',
                  'fileName': 'guvohnoma.pdf',
                  'path': '/admin/employers/emp-1/evidence/file-9',
                },
              ],
            ),
          ],
        ],
      );

      // A `file_purpose` is a dictionary row an administrator edits at runtime
      // (§10.3), so a switch in Dart would go stale the day one is added — and
      // the reader of this screen is the person who maintains that dictionary.
      expect(find.text('evidence'), findsOneWidget);
    });
  });

  group('a reason is mandatory for anything but an approval', () {
    testWidgets('approval sends immediately, and sends no reason', (
      tester,
    ) async {
      final (fake, _) = await pump(
        tester,
        pages: [
          [_item(id: 'emp-1')],
        ],
      );

      await openSheet(tester, 'Verify');

      // Named on the sheet: three sheets look alike, and the wrong employer
      // verified is not something a confirmation can undo.
      expect(find.text('"QITMIR SOFT" MCHJ'), findsWidgets);
      expect(find.text('Verify this employer?'), findsOneWidget);
      // No reason field at all — asking for one would imply the server wants
      // it, and it does not.
      expect(find.byType(HhTextField), findsNothing);

      await tester.tap(find.widgetWithText(HhButton, 'Verify').last);
      await tester.pumpAndSettle();

      expect(fake.decisions.single.decision, 'verified');
      expect(fake.decisions.single.reason, isNull);
    });

    testWidgets('rejection refuses to send until a reason exists', (
      tester,
    ) async {
      final (fake, _) = await pump(
        tester,
        pages: [
          [_item(id: 'emp-1')],
        ],
      );

      await openSheet(tester, 'Reject');
      expect(find.text('Reject this submission?'), findsOneWidget);

      // Disabled rather than refused after the fact. The server answers 403
      // `employer.verification_reason_required`, and re-making that rule here
      // turns a refusal into a label.
      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Reject').last,
      );
      expect(button.onPressed, isNull);
      expect(fake.decisions, isEmpty);

      await tester.enterText(
        find.byType(HhTextField),
        '  The certificate is unreadable.  ',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(HhButton, 'Reject').last);
      await tester.pumpAndSettle();

      expect(fake.decisions.single.decision, 'rejected');
      // Trimmed: §6.1 shows this to the employer verbatim, and leading
      // whitespace is not something they should read.
      expect(fake.decisions.single.reason, 'The certificate is unreadable.');
    });

    testWidgets('asking for changes wants a reason too', (tester) async {
      final (fake, _) = await pump(
        tester,
        pages: [
          [_item(id: 'emp-1')],
        ],
      );

      await openSheet(tester, 'Ask for changes');

      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Ask for changes').last,
      );
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(HhTextField), 'Add the tax number.');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(HhButton, 'Ask for changes').last);
      await tester.pumpAndSettle();

      expect(fake.decisions.single.decision, 'changes_required');
    });
  });

  group('a decided row leaves the queue without a refetch', () {
    testWidgets('because everything above it is older', (tester) async {
      final (fake, _) = await pump(
        tester,
        pages: [
          [
            _item(id: 'emp-1', legalName: 'Alfa'),
            _item(id: 'emp-2', legalName: 'Beta'),
          ],
        ],
      );

      await openSheet(tester, 'Verify');
      await tester.tap(find.widgetWithText(HhButton, 'Verify').last);
      await tester.pumpAndSettle();

      expect(find.text('Alfa'), findsNothing);
      expect(find.text('Beta'), findsOneWidget);
      // One request, the first page. A refetch would reorder nothing and would
      // move the list under the finger of whoever is working down it.
      expect(fake.requestedOffsets, [0]);
    });

    testWidgets('a 409 is an outcome: the row goes, the sheet explains', (
      tester,
    ) async {
      final (fake, _) = await pump(
        tester,
        pages: [
          [
            _item(id: 'emp-1', legalName: 'Alfa'),
            _item(id: 'emp-2', legalName: 'Beta'),
          ],
        ],
        conflictOn: 'emp-1',
      );

      await openSheet(tester, 'Verify');
      // Two cards contribute a Verify each, and the open sheet a third.
      expect(find.widgetWithText(HhButton, 'Verify'), findsNWidgets(3));

      await tester.tap(find.widgetWithText(HhButton, 'Verify').last);
      await tester.pumpAndSettle();

      expect(find.text('Already decided'), findsOneWidget);
      expect(
        find.text('This employer has already been reviewed.'),
        findsOneWidget,
      );
      // One left, on Beta's card. Two things happened at once and both are the
      // point: the sheet's action came off, because every decision would 409
      // again, and Alfa's row left the queue in the same beat — the work *is*
      // done. Its dismiss reads "Back" rather than "Cancel", because there is
      // nothing left to cancel.
      expect(find.widgetWithText(HhButton, 'Verify'), findsOneWidget);
      expect(find.widgetWithText(HhButton, 'Cancel'), findsNothing);
      expect(fake.decisions.length, 1);

      await tester.tap(find.widgetWithText(HhButton, 'Back'));
      await tester.pumpAndSettle();

      // The work *is* done, so the row leaves exactly as it would have on
      // success. Only the toast differs.
      expect(find.text('Alfa'), findsNothing);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Decision recorded.'), findsNothing);
    });

    testWidgets('a successful decision is confirmed', (tester) async {
      await pump(
        tester,
        pages: [
          [_item(id: 'emp-1')],
        ],
      );

      await openSheet(tester, 'Verify');
      await tester.tap(find.widgetWithText(HhButton, 'Verify').last);
      await tester.pumpAndSettle();

      expect(find.text('Decision recorded.'), findsOneWidget);
    });
  });

  group('paging appends', () {
    testWidgets('show more is offered only when a page came back full', (
      tester,
    ) async {
      final (fake, _) = await pump(
        tester,
        pages: [
          [
            for (var i = 0; i < adminPageSize; i++)
              _item(id: 'emp-$i', legalName: 'Employer $i'),
          ],
          [_item(id: 'emp-last', legalName: 'Last one')],
        ],
      );

      // A full page of cards puts the control below the fold, and the list is
      // lazy, so it has to be scrolled into existence before it can be tapped.
      final showMore = find.widgetWithText(HhButton, 'Show more');
      await tester.scrollUntilVisible(showMore, 400);
      await tester.tap(showMore);
      await tester.pumpAndSettle();

      expect(fake.requestedOffsets, [0, adminPageSize]);
      expect(find.text('Last one'), findsOneWidget);
      // The short second page ends the paging, so the control goes.
      expect(showMore, findsNothing);
    });
  });
}
