import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/profile/data/attachments_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/attachment.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/attachments_section.dart';

/// Profile files (§5.4, UAT-03).
class _FakeAttachments implements AttachmentsRepository {
  _FakeAttachments({this.files = const [], this.fails = false});

  List<Attachment> files;
  bool fails;
  final removed = <String>[];

  @override
  Future<List<Attachment>> list() async {
    if (fails) throw const ApiException('No connection');
    return files;
  }

  @override
  Future<Attachment> upload({
    required String purposeCode,
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onProgress,
    Object? cancelToken,
  }) async => throw UnimplementedError();

  @override
  Future<void> remove(String id) async => removed.add(id);
}

void main() {
  const cvSlot = SchemaAttachment(
    purposeId: 'p1',
    code: 'cv',
    label: 'CV',
    required: false,
    accept: ['pdf', 'doc', 'docx'],
    maxSizeBytes: 10485760,
    maxCount: 1,
  );

  Future<void> pump(
    WidgetTester tester, {
    List<SchemaAttachment> slots = const [cvSlot],
    _FakeAttachments? repository,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          attachmentsRepositoryProvider.overrideWithValue(
            repository ?? _FakeAttachments(),
          ),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          // The real mounting: inside the profile form's scroll view, which is
          // where the vertical constraints are unbounded.
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [AttachmentsSection(slots: slots)],
              ),
            ),
          ),
        ),
      ),
    );
    // Bounded pumps, not pumpAndSettle: a CircularProgressIndicator animates
    // forever, so settling times out and the timeout looks exactly like a
    // stuck provider. MEMORY.md records this trap.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('lays out without overflowing or collapsing', (tester) async {
    await pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('CV'), findsOneWidget);
    expect(find.text('Nothing uploaded yet'), findsOneWidget);
    expect(find.text('Upload'), findsOneWidget);

    // The heading, the slot label and the empty state must occupy distinct
    // rows. All three at one offset is the zero-height collapse that made this
    // section unreadable on device while nothing threw.
    final heading = tester.getTopLeft(find.text('Documents')).dy;
    final label = tester.getTopLeft(find.text('CV')).dy;
    final empty = tester.getTopLeft(find.text('Nothing uploaded yet')).dy;

    expect(label, greaterThan(heading));
    expect(empty, greaterThan(label));
  });

  testWidgets('a full single-file slot offers Replace instead of Upload', (
    tester,
  ) async {
    await pump(
      tester,
      repository: _FakeAttachments(
        files: const [
          Attachment(
            id: 'a1',
            purposeCode: 'cv',
            fileName: 'cv.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 2048,
            createdAt: '2026-08-07T12:00:00+05:00',
            downloadPath: '/files/a1/content',
          ),
        ],
      ),
    );

    expect(find.text('cv.pdf'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);
    // A file that uploaded must never be described as empty — rounding a
    // small one to KB prints "0 KB", which is what a 193-byte CV did on
    // device.
    expect(find.text('0 KB'), findsNothing);
    // §5.4's replace: one CV, so a second upload supersedes rather than adds.
    expect(find.text('Replace'), findsOneWidget);
    expect(find.text('Upload'), findsNothing);
  });

  testWidgets('a file for another purpose does not fill this slot', (
    tester,
  ) async {
    await pump(
      tester,
      repository: _FakeAttachments(
        files: const [
          Attachment(
            id: 'a2',
            purposeCode: 'certificate',
            fileName: 'diploma.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 1024,
            createdAt: '2026-08-07T12:00:00+05:00',
            downloadPath: '/files/a2/content',
          ),
        ],
      ),
    );

    expect(find.text('diploma.pdf'), findsNothing);
    expect(find.text('Upload'), findsOneWidget);
  });

  testWidgets('a failed load shows the error state, not a spinner', (
    tester,
  ) async {
    await pump(tester, repository: _FakeAttachments(fails: true));

    expect(find.text('No connection'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a category declaring no file slots renders nothing', (
    tester,
  ) async {
    await pump(tester, slots: const []);

    expect(find.text('Documents'), findsNothing);
  });

  testWidgets('a sub-kilobyte file reads in bytes, never as 0 KB', (
    tester,
  ) async {
    await pump(
      tester,
      repository: _FakeAttachments(
        files: const [
          Attachment(
            id: 'a3',
            purposeCode: 'cv',
            fileName: 'tiny.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 193,
            createdAt: '2026-08-07T12:00:00+05:00',
            downloadPath: '/files/a3/content',
          ),
        ],
      ),
    );

    expect(find.text('193 B'), findsOneWidget);
  });
}
