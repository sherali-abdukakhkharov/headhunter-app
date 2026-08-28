/// §5's profile, as a hub of sections rather than one form.
///
/// It was a single scroll — a completeness card, eight to ten schema sections,
/// the attachment slots and the visibility switch, twenty-six fields plus two
/// repeating lists — which the 1.29.0 audit called monolithic. Length was the
/// smaller half: on a page where every part looks the same, *what is still
/// missing* is invisible.
///
/// Two properties are worth pinning and one of them is not about layout at all:
///
/// - **the rows are the schema's, in the schema's order**, because which
///   sections exist depends on the work category and an administrator can add
///   one at runtime (§5.2, §10.3) — a client-side list would be wrong the first
///   time that happened;
/// - **a section saves only its own fields**, which is what makes leaving
///   another one half-finished harmless.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/candidate_profile.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/candidate_profile_screen.dart';
import 'package:jobbridge_app/src/features/profile/presentation/profile_section_screen.dart';

/// Two engine sections with two fields each, which is the smallest shape that
/// can show a save leaking from one into the other.
final _schema = FieldSchema.fromJson(const {
  'category': 'service_operations',
  'schemaVersion': 3,
  'locale': 'en',
  'sections': [
    {
      'code': 'personal',
      'label': 'Personal information',
      'editor': 'engine',
      'fields': [
        {
          'code': 'full_name',
          'label': 'Full name',
          'kind': 'text',
          'required': true,
        },
        {
          'code': 'birth_year',
          'label': 'Year of birth',
          'kind': 'text',
          'required': false,
        },
      ],
    },
    {
      'code': 'location',
      'label': 'Location',
      'editor': 'engine',
      'fields': [
        {
          'code': 'address',
          'label': 'Address',
          'kind': 'text',
          'required': false,
        },
      ],
    },
  ],
  'attachments': <dynamic>[],
});

CandidateProfile _profile({List<String> missing = const []}) =>
    CandidateProfile.fromJson({
      'isStarted': true,
      'category': 'service_operations',
      'visibility': 'hidden',
      'completenessPercent': 40,
      'isComplete': false,
      'isSearchable': false,
      'missingFields': [
        for (final code in missing) {'code': code, 'required': true},
      ],
      'fields': const <String, dynamic>{},
    });

/// Records exactly what each save sent.
class _FakeRepository implements ProfileRepository {
  _FakeRepository(this._profile);

  final CandidateProfile _profile;

  final patches = <Map<String, dynamic>>[];

  @override
  Future<CandidateProfile> fetchProfile() async => _profile;

  @override
  Future<FieldSchema> fetchSchema(String category) async => _schema;

  @override
  Future<CandidateProfile> patchProfile(Map<String, dynamic> fields) async {
    patches.add(Map.of(fields));

    return _profile;
  }

  @override
  Never noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'This suite writes profile fields; ${invocation.memberName} is not part '
    'of that.',
  );
}

void main() {
  final en = lookupAppL10n(const Locale('en'));

  ProviderContainer containerWith(_FakeRepository repository) {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    return container;
  }

  group('a section saves only its own fields', () {
    test('the patch carries this section and not the other', () async {
      final repository = _FakeRepository(_profile());
      final container = containerWith(repository);

      await container.read(profileEditorProvider.future);
      final editor = container.read(profileEditorProvider.notifier)
        ..edit('full_name', 'Aziza Karimova')
        ..edit('address', 'Chilonzor 12');

      await editor.save(only: {'full_name', 'birth_year'});

      // The endpoint has always been partial by field code — that is why the
      // edits are held apart from the profile — so scoping a save is a matter
      // of sending a subset.
      expect(repository.patches, [
        {'full_name': 'Aziza Karimova'},
      ]);
    });

    test('and the other section is still waiting afterwards', () async {
      final repository = _FakeRepository(_profile());
      final container = containerWith(repository);

      await container.read(profileEditorProvider.future);
      final editor = container.read(profileEditorProvider.notifier)
        ..edit('full_name', 'Aziza Karimova')
        ..edit('address', 'Chilonzor 12');

      await editor.save(only: {'full_name'});

      final state = container.read(profileEditorProvider).requireValue;

      // Clearing everything on success is what would make a per-section save a
      // lie: the address was never sent, so it cannot be saved.
      expect(state.isDirtyIn({'address'}), isTrue);
      expect(state.isDirtyIn({'full_name'}), isFalse);
      expect(state.valueOf('address'), 'Chilonzor 12');
    });

    test('a scope with nothing pending sends no request at all', () async {
      final repository = _FakeRepository(_profile());
      final container = containerWith(repository);

      await container.read(profileEditorProvider.future);
      container.read(profileEditorProvider.notifier).edit('address', 'X');

      final saved = await container
          .read(profileEditorProvider.notifier)
          .save(only: {'full_name'});

      expect(saved, isFalse);
      expect(repository.patches, isEmpty);
    });

    test('an unscoped save still writes everything', () async {
      // The employer profile is still one form, and so is any caller that has
      // not been split.
      final repository = _FakeRepository(_profile());
      final container = containerWith(repository);

      await container.read(profileEditorProvider.future);
      container.read(profileEditorProvider.notifier)
        ..edit('full_name', 'Aziza')
        ..edit('address', 'Chilonzor 12');

      await container.read(profileEditorProvider.notifier).save();

      expect(repository.patches.single, hasLength(2));
    });
  });

  group('the hub', () {
    Future<void> pump(
      WidgetTester tester,
      _FakeRepository repository,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [profileRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: const CandidateProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('lists the schema sections, in the schema order', (
      tester,
    ) async {
      await pump(tester, _FakeRepository(_profile()));

      final rows = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .toList();

      expect(rows, contains('Personal information'));
      expect(rows, contains('Location'));
      expect(
        rows.indexOf('Personal information'),
        lessThan(rows.indexOf('Location')),
        reason: 'the schema decides the order, not a client grouping',
      );
    });

    testWidgets('and the two parts that are not schema sections', (
      tester,
    ) async {
      await pump(tester, _FakeRepository(_profile()));

      // Files are declared outside the field union (§4.5) and visibility is its
      // own endpoint (§5.3). Both belong to the profile; neither is a section.
      expect(find.text(en.attachmentsTitle), findsOneWidget);
      expect(find.text(en.profileVisibilityTitle), findsOneWidget);
    });

    testWidgets('says what is left in a section, from the server count', (
      tester,
    ) async {
      await pump(tester, _FakeRepository(_profile(missing: ['full_name'])));

      expect(find.text(en.profileSectionRemaining(1)), findsOneWidget);
    });

    testWidgets('and says nothing about a section that is answered', (
      tester,
    ) async {
      await pump(tester, _FakeRepository(_profile()));

      // Silence is the signal. A row reading "2 fields" would tell a finished
      // user something they do not need and an unfinished one nothing they can
      // act on.
      expect(find.textContaining('left'), findsNothing);
    });

    testWidgets('shows no form fields of its own', (tester) async {
      await pump(tester, _FakeRepository(_profile()));

      // The whole point: the hub is a list of places, not twenty-six controls.
      expect(find.byType(HhTextField), findsNothing);
    });
  });

  group('a section page', () {
    Future<void> pumpSection(
      WidgetTester tester,
      String code, {
      _FakeRepository? repository,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            profileRepositoryProvider.overrideWithValue(
              repository ?? _FakeRepository(_profile()),
            ),
          ],
          child: MaterialApp(
            theme: HhTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: ProfileSectionScreen(sectionCode: code),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows its own fields and no other section\u2019s', (
      tester,
    ) async {
      await pumpSection(tester, 'personal');

      // `textContaining`: a required field's label carries the marker the
      // design puts on it, and the claim here is about which fields are on
      // the page rather than about how one is decorated.
      expect(find.textContaining('Full name'), findsOneWidget);
      expect(find.textContaining('Year of birth'), findsOneWidget);
      expect(find.textContaining('Address'), findsNothing);
    });

    testWidgets('names itself with the schema label', (tester) async {
      await pumpSection(tester, 'location');

      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('offers no save until something in it changes', (tester) async {
      await pumpSection(tester, 'personal');

      expect(find.byType(ProfileSaveBar), findsNothing);

      await tester.enterText(find.byType(HhTextField).first, 'Aziza');
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSaveBar), findsOneWidget);
    });

    testWidgets('a code the schema does not carry draws no form', (
      tester,
    ) async {
      // A stale deep link, or a category change that dropped the section.
      // Neither is an error, and neither should render an empty page.
      await pumpSection(tester, 'nothing_like_this');

      expect(find.byType(HhTextField), findsNothing);
      expect(find.text(en.profileSectionGone), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
