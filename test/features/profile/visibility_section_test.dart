import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/candidate_profile.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/visibility_section.dart';

/// Search visibility (UAT-12, §5.5).
///
/// The wire values are the point. `searchable`, `hidden` and
/// `visible_after_apply` are what `SetVisibilityDto` accepts, and a typo here
/// is a 400 the user reads as "the setting did not save" — with no clue which
/// of three options is broken, because the labels all look right.
class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.fails = false});

  bool fails;
  final sent = <String>[];

  @override
  Future<CandidateProfile> fetchProfile() async =>
      CandidateProfile.fromJson(const {'visibility': 'hidden'});

  @override
  Future<FieldSchema> fetchSchema(String category) async =>
      FieldSchema.fromJson(const {
        'category': 'professional',
        'schemaVersion': 2,
        'locale': 'en',
        'sections': <dynamic>[],
      });

  @override
  Future<FieldSchema> fetchVacancySchema(String category) async =>
      fetchSchema(category);

  @override
  Future<CandidateProfile> patchProfile(Map<String, dynamic> fields) async =>
      fetchProfile();

  @override
  Future<CandidateProfile> setVisibility(String visibility) async {
    sent.add(visibility);
    if (fails) throw const ApiException('Could not save');
    return CandidateProfile.fromJson({'visibility': visibility});
  }
}

void main() {
  Future<_FakeProfileRepository> pump(
    WidgetTester tester, {
    String current = 'hidden',
    bool fails = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = _FakeProfileRepository(fails: fails);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          // Mounted the way the real screen mounts it: inside the loaded
          // profile. `setVisibility` early-returns while the profile is still
          // AsyncLoading, so a test that renders the section on its own taps a
          // control that cannot do anything and proves nothing.
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => switch (ref.watch(
                profileEditorProvider,
              )) {
                AsyncData() => SingleChildScrollView(
                  child: VisibilitySection(current: current),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return repository;
  }

  testWidgets('offers the three options §5.5 defines', (tester) async {
    await pump(tester);

    expect(find.text('Visible in search'), findsOneWidget);
    expect(find.text('Hidden from search'), findsOneWidget);
    expect(find.text('Visible after I apply'), findsOneWidget);
  });

  testWidgets('each option explains what it does', (tester) async {
    await pump(tester);

    // "Hidden" not meaning "deactivated" is the distinction UAT-12 turns on,
    // and the one a bare label cannot carry.
    expect(
      find.text(
        'You can still browse vacancies and apply. Employers cannot find you.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('choosing an option sends the wire value, not the label', (
    tester,
  ) async {
    final repository = await pump(tester);

    await tester.tap(find.text('Visible after I apply'));
    await tester.pumpAndSettle();

    expect(repository.sent, ['visible_after_apply']);
  });

  testWidgets('every option sends a value the server accepts', (tester) async {
    // Walks all three rather than one, because a typo in the least-used branch
    // is exactly the one that ships.
    for (final (label, wire) in const [
      ('Visible in search', 'searchable'),
      ('Visible after I apply', 'visible_after_apply'),
    ]) {
      final repository = await pump(tester);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(repository.sent, [wire], reason: 'for "$label"');
    }

    // `hidden` is the seeded current value, so it is exercised from the other
    // direction: selecting it from a different starting point.
    final repository = await pump(tester, current: 'searchable');
    await tester.tap(find.text('Hidden from search'));
    await tester.pumpAndSettle();
    expect(repository.sent, ['hidden']);
  });

  testWidgets('re-picking the value already stored writes nothing', (
    tester,
  ) async {
    final repository = await pump(tester);

    await tester.tap(find.text('Hidden from search'));
    await tester.pumpAndSettle();

    expect(repository.sent, isEmpty);
  });

  testWidgets('a refused write says so and falls back to what is stored', (
    tester,
  ) async {
    await pump(tester, fails: true);

    await tester.tap(find.text('Visible in search'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save'), findsOneWidget);

    // The radio must not keep showing a choice that did not take: a privacy
    // control the user believes they set is worse than one that refuses.
    final radio = tester.widget<HhRadioRow<String>>(
      find.ancestor(
        of: find.text('Hidden from search'),
        matching: find.byType(HhRadioRow<String>),
      ),
    );
    expect(radio.groupValue, 'hidden');
  });
}
