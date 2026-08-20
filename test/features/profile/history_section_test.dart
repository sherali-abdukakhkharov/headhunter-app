import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/profile/data/history_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/domain/history_record.dart';
import 'package:jobbridge_app/src/features/profile/presentation/history_section.dart';

/// The bespoke profile sections (§5.1).
///
/// Only [historyRepositoryProvider] is faked, so the real controllers run —
/// the same choice the picker tests make, and for the same reason: the list
/// state, the empty state and the error ordering are the rules under test.
class _FakeHistory implements HistoryRepository {
  _FakeHistory({
    this.experience = const [],
    this.education = const [],
    this.fails = false,
  });

  List<ExperienceRecord> experience;
  List<EducationRecord> education;
  bool fails;

  final removed = <String>[];

  @override
  Future<List<ExperienceRecord>> listExperience(String path) async {
    if (fails) throw const ApiException('No connection');
    return experience;
  }

  @override
  Future<List<EducationRecord>> listEducation(String path) async {
    if (fails) throw const ApiException('No connection');
    return education;
  }

  @override
  Future<void> add(String path, Object draft) async {}

  @override
  Future<void> replace(String path, String id, Object draft) async {}

  @override
  Future<void> remove(String path, String id) async => removed.add(id);
}

void main() {
  const levelId = '9b3f-0d47';

  final levels = [
    const DictionaryItem(
      id: levelId,
      code: 'bachelor',
      label: 'Bakalavr',
      sortOrder: 0,
      isActive: true,
    ),
  ];

  SchemaSection section(String code, {String? endpoint}) => SchemaSection(
    code: code,
    label: code == 'experience' ? 'Ish tajribasi' : 'Taʼlim',
    repeating: true,
    editor: 'bespoke',
    endpoint: endpoint,
    fields: const [],
  );

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    _FakeHistory? history,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // Mirrors main.dart, so a failure is terminal rather than a retrying
        // AsyncLoading — which is what the error test below depends on.
        retry: (retryCount, error) => null,
        overrides: [
          historyRepositoryProvider.overrideWithValue(
            history ?? _FakeHistory(),
          ),
          dictionaryProvider('education_level').overrideWith((ref) => levels),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('dispatch', () {
    testWidgets('an unknown bespoke section still renders the notice', (
      tester,
    ) async {
      // The same rule as FieldKind.unknown: the server may declare a section
      // this app version has no editor for. Saying so beats crashing, and beats
      // omitting it — an absent section reads as a finished one.
      await pump(tester, BespokeSection(section: section('portfolio')));

      expect(
        find.text('This section has its own editor and is not part of this '
            'build yet.'),
        findsOneWidget,
      );
    });

    testWidgets('experience and education each get their own editor', (
      tester,
    ) async {
      await pump(tester, BespokeSection(section: section('experience')));
      expect(find.text('Add experience'), findsOneWidget);

      await pump(tester, BespokeSection(section: section('education')));
      expect(find.text('Add education'), findsOneWidget);
    });
  });

  group('work experience', () {
    testWidgets('an empty section says so rather than rendering nothing', (
      tester,
    ) async {
      await pump(tester, const ExperienceSection(path: '/x'));

      expect(find.text('No work experience yet'), findsOneWidget);
      expect(find.text('Add experience'), findsOneWidget);
    });

    testWidgets('a record shows its role, employer and period', (tester) async {
      await pump(
        tester,
        const ExperienceSection(path: '/x'),
        history: _FakeHistory(
          experience: const [
            ExperienceRecord(
              id: 'rec-1',
              roleTitle: 'Dasturchi',
              startedOn: '2024-03-01',
              isCurrent: false,
              employerName: 'Uzum',
              endedOn: '2025-08-31',
            ),
          ],
        ),
      );

      expect(find.text('Dasturchi'), findsOneWidget);
      expect(find.text('Uzum'), findsOneWidget);
      expect(find.text('2024-03-01 — 2025-08-31'), findsOneWidget);
    });

    testWidgets('an ongoing role reads as Present rather than a blank end', (
      tester,
    ) async {
      await pump(
        tester,
        const ExperienceSection(path: '/x'),
        history: _FakeHistory(
          experience: const [
            ExperienceRecord(
              id: 'rec-1',
              roleTitle: 'Terimchi',
              startedOn: '2025-06-01',
              isCurrent: true,
            ),
          ],
        ),
      );

      expect(find.text('2025-06-01 — Present'), findsOneWidget);
    });

    // Found by running it. The server accepts `isCurrent: false` with no end
    // date, and it is the combination the editor produces most easily — leave
    // the end blank and do not tick the box. Rendering that as "Present" is the
    // card asserting the role is ongoing over a record that says it is not.
    testWidgets('a role with no end and not current claims no end at all', (
      tester,
    ) async {
      await pump(
        tester,
        const ExperienceSection(path: '/x'),
        history: _FakeHistory(
          experience: const [
            ExperienceRecord(
              id: 'rec-1',
              roleTitle: 'Terimchi',
              startedOn: '2025-06-01',
              isCurrent: false,
            ),
          ],
        ),
      );

      expect(find.text('2025-06-01'), findsOneWidget);
      expect(find.textContaining('Present'), findsNothing);
    });

    testWidgets('a failed load shows the error state, not a spinner', (
      tester,
    ) async {
      await pump(
        tester,
        const ExperienceSection(path: '/x'),
        history: _FakeHistory(fails: true),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      // The repository's own message, not a generic one: it is already
      // user-presentable by the time it gets here.
      expect(find.text('No connection'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('education', () {
    testWidgets('a record resolves its level id to a label', (tester) async {
      await pump(
        tester,
        const EducationSection(path: '/x'),
        history: _FakeHistory(
          education: const [
            EducationRecord(
              id: 'edu-1',
              levelId: levelId,
              institution: 'TATU',
              specialization: 'Dasturiy injiniring',
              graduationYear: 2020,
            ),
          ],
        ),
      );

      // The label, never the bound id (BR-13).
      expect(find.text('Bakalavr'), findsOneWidget);
      expect(find.text(levelId), findsNothing);
      expect(find.text('TATU'), findsOneWidget);
      expect(find.text('Dasturiy injiniring · 2020'), findsOneWidget);
    });
  });

  group('deleting', () {
    testWidgets('is confirmed first, and backing out deletes nothing', (
      tester,
    ) async {
      final history = _FakeHistory(
        experience: const [
          ExperienceRecord(
            id: 'rec-1',
            roleTitle: 'Dasturchi',
            startedOn: '2024-03-01',
            isCurrent: true,
          ),
        ],
      );

      await pump(tester, const ExperienceSection(path: '/x'), history: history);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this entry?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // A record that cannot be recovered is not deleted by one stray tap.
      expect(history.removed, isEmpty);
    });
  });
}
