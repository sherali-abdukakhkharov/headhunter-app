import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_repository.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:jobbridge_app/src/features/employer/presentation/employer_profile_screen.dart';

/// The employer profile and verification (§6.1, BR-03).
class _FakeEmployer implements EmployerRepository {
  _FakeEmployer({this.profile, this.state});

  EmployerProfile? profile;
  VerificationState? state;

  /// Every body handed to `PUT /employers/me`.
  final saved = <Map<String, dynamic>>[];

  @override
  Future<EmployerProfile?> fetchProfile() async => profile;

  @override
  Future<EmployerProfile> save(Map<String, dynamic> body) async {
    saved.add(body);
    return profile = EmployerProfile.fromJson({
      'type': body['type'],
      'verificationStatus': 'not_submitted',
      'completenessPercent': 20,
      'isComplete': false,
      'canPublish': false,
      'missingFields': const <dynamic>[],
      ...body,
    });
  }

  @override
  Future<VerificationState> verification() async =>
      state ??
      VerificationState.fromJson(const {
        'status': 'not_submitted',
        'requiredEvidence': <dynamic>[],
        'submissions': <dynamic>[],
      });

  @override
  Future<void> submitVerification(List<String> fileIds) async {}
}

EmployerProfile _profile({
  String type = 'company',
  String status = 'not_submitted',
  bool canPublish = false,
  String? reason,
}) => EmployerProfile.fromJson({
  'type': type,
  'legalName': 'Uzum Technologies',
  'verificationStatus': status,
  'verificationReason': reason,
  'completenessPercent': 40,
  'isComplete': false,
  'canPublish': canPublish,
  'missingFields': const [
    {'field': 'contactPhone'},
  ],
});

void main() {
  Future<_FakeEmployer> pump(
    WidgetTester tester, {
    _FakeEmployer? repository,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = repository ?? _FakeEmployer();

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          employerRepositoryProvider.overrideWithValue(fake),
          dictionaryProvider('industry').overrideWith(
            (ref) => const <DictionaryItem>[],
          ),
          dictionaryProvider('region').overrideWith(
            (ref) => const <DictionaryItem>[],
          ),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const EmployerProfileScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group('no profile yet', () {
    // A 404 is not a failure here: `type` decides which fields exist, so there
    // is no neutral empty employer to render and "nothing created yet" is a
    // state the screen has a design for. Mapping it to an error would show a
    // retry button to every first-run employer.
    testWidgets('a missing profile asks which kind of employer this is', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('What kind of employer are you?'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('and warns that the choice is permanent', (tester) async {
      await pump(tester);

      expect(
        find.text('Chosen once and cannot be changed later.'),
        findsOneWidget,
      );
    });

    testWidgets('verification is not offered before there is a profile', (
      tester,
    ) async {
      await pump(tester);

      // Nothing to verify yet, and the server would refuse.
      expect(find.text('Verification'), findsNothing);
    });
  });

  group('the type is fixed once chosen', () {
    testWidgets('an existing profile is not asked again', (tester) async {
      await pump(tester, repository: _FakeEmployer(profile: _profile()));

      // The server refuses a change with `employer.type_immutable`, so
      // offering a control that always fails is worse than not offering it.
      expect(find.text('What kind of employer are you?'), findsNothing);
    });
  });

  group('the type decides which fields exist', () {
    testWidgets('a company is asked for its registered and public names', (
      tester,
    ) async {
      await pump(tester, repository: _FakeEmployer(profile: _profile()));

      expect(find.text('Registered name'), findsOneWidget);
      expect(find.text('Name shown to candidates'), findsOneWidget);
      expect(find.text('Contact person'), findsOneWidget);
      expect(find.text('Your full name'), findsNothing);
    });

    testWidgets('an individual is asked for a name, nothing corporate', (
      tester,
    ) async {
      await pump(
        tester,
        repository: _FakeEmployer(profile: _profile(type: 'individual')),
      );

      expect(find.text('Your full name'), findsOneWidget);
      expect(find.text('Registered name'), findsNothing);
      expect(find.text('Industry'), findsNothing);
    });

    testWidgets("the write carries only the chosen type's fields", (
      tester,
    ) async {
      final fake = await pump(tester);

      await tester.tap(find.text('An individual'));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Ali Valiyev');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final body = fake.saved.single;
      expect(body['type'], 'individual');
      expect(body['fullName'], 'Ali Valiyev');
      // The other type's fields are meaningless to the server here, and
      // sending them would be the client asserting a shape the contract does
      // not have.
      expect(body.containsKey('legalName'), isFalse);
      expect(body.containsKey('industryId'), isFalse);
    });
  });

  group('BR-03', () {
    testWidgets('states both conditions when the employer may not publish', (
      tester,
    ) async {
      await pump(tester, repository: _FakeEmployer(profile: _profile()));

      // Named in full, because an employer who is complete but unverified
      // needs to know which half is missing.
      expect(
        find.text(
          'Complete your profile and get verified before posting a vacancy '
          'or inviting a candidate.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('says so plainly once both are met', (tester) async {
      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(status: 'verified', canPublish: true),
        ),
      );

      expect(
        find.text('You can post vacancies and invite candidates.'),
        findsOneWidget,
      );
    });
  });

  group('verification', () {
    testWidgets("renders the administrator's reason verbatim", (tester) async {
      const reason = "Ustav hujjati o'qib bo'lmaydi";

      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(status: 'changes_required', reason: reason),
          state: VerificationState.fromJson(const {
            'status': 'changes_required',
            'reason': reason,
            'requiredEvidence': <dynamic>[],
            'submissions': <dynamic>[],
          }),
        ),
      );

      // Human text in the language it was written in — never translated, and
      // never reduced to a key (§2.4).
      expect(find.text(reason), findsOneWidget);
    });

    testWidgets('lists the documents the server asks for', (tester) async {
      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(),
          state: VerificationState.fromJson(const {
            'status': 'not_submitted',
            'requiredEvidence': [
              {'purposeCode': 'company_registration', 'required': true},
              {'purposeCode': 'evidence', 'required': false},
            ],
            'submissions': <dynamic>[],
          }),
        ),
      );

      // Served rather than hardcoded: §6.1 leaves the policy open.
      expect(find.text('company_registration'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('is not offered while an attempt is under review', (
      tester,
    ) async {
      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(status: 'under_review'),
          state: VerificationState.fromJson(const {
            'status': 'under_review',
            'requiredEvidence': <dynamic>[],
            'submissions': <dynamic>[],
          }),
        ),
      );

      // A second submission would queue another decision on the same evidence.
      expect(find.text('Submit for verification'), findsNothing);
      expect(find.text('Under review'), findsWidgets);
    });

    testWidgets('an unknown status falls back rather than throwing', (
      tester,
    ) async {
      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(status: 'some_future_state'),
          state: VerificationState.fromJson(const {
            'status': 'some_future_state',
            'requiredEvidence': <dynamic>[],
            'submissions': <dynamic>[],
          }),
        ),
      );

      // Same rule as an unknown field kind: the server may add a sixth state,
      // and a client that throws turns that into a fleet-wide outage.
      expect(tester.takeException(), isNull);
      expect(find.text('Not submitted'), findsWidgets);
    });
  });
}
