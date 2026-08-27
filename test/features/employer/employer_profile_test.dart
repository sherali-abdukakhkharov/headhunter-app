import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_controller.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_repository.dart';
import 'package:jobbridge_app/src/features/employer/data/evidence_repository.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:jobbridge_app/src/features/employer/presentation/employer_profile_screen.dart';
import 'package:jobbridge_app/src/shared/domain/attachment.dart';

/// The employer profile and verification (§6.1, BR-03).
class _FakeEmployer implements EmployerRepository {
  _FakeEmployer({this.profile, this.state});

  EmployerProfile? profile;
  VerificationState? state;

  /// Every body handed to `PUT /employers/me`.
  final saved = <Map<String, dynamic>>[];

  /// How many times the verification state was read — the evidence for
  /// MT-011, which is about a provider that was never invalidated.
  int verificationReads = 0;

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
      _countedVerification();

  VerificationState _countedVerification() {
    verificationReads++;
    return state ??
        VerificationState.fromJson(const {
          'status': 'not_submitted',
          'requiredEvidence': <dynamic>[],
          'submissions': <dynamic>[],
        });
  }

  /// Every list of file ids handed to `POST /employers/me/verification`.
  final submitted = <List<String>>[];

  @override
  Future<void> submitVerification(List<String> fileIds) async {
    submitted.add(fileIds);
  }
}

Attachment _file({
  required String purposeCode,
  String id = 'file-1',
  String fileName = 'registration.pdf',
}) => Attachment(
  id: id,
  purposeCode: purposeCode,
  fileName: fileName,
  mimeType: 'application/pdf',
  sizeBytes: 1024,
  createdAt: '2026-08-28T10:00:00+05:00',
  downloadPath: '/files/$id/content',
);

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

/// Fills §6.1's mandatory set through the notifier.
///
/// The region is a dictionary picker and this harness serves an empty
/// dictionary, so there is no way to choose one through the form. Every test
/// that needs a *saveable* profile needs all of these, which is the rule the
/// first save now enforces.
void _fill(WidgetTester tester, {required String type}) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(EmployerProfileScreen)),
  );

  container.read(employerEditorProvider.notifier)
    ..edit('contactPhone', '+998901234567')
    ..edit('regionId', 'reg-1')
    ..edit('description', 'Uy qurilishi ishlari')
    ..edit(
      type == 'company' ? 'legalName' : 'fullName',
      type == 'company' ? 'Uzum Technologies' : 'Ali Valiyev',
    );

  if (type == 'company') {
    container.read(employerEditorProvider.notifier)
      ..edit('publicName', 'Uzum')
      ..edit('industryId', 'ind-1')
      ..edit('contactPersonName', 'Aziza');
  }
}

void main() {
  Future<_FakeEmployer> pump(
    WidgetTester tester, {
    _FakeEmployer? repository,
    List<Attachment> evidence = const [],
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
          // Without this the card reaches the real `/files` through the real
          // Dio, and the pending request outlives the widget tree.
          evidenceFilesProvider.overrideWith((ref) => evidence),
          dictionaryProvider('industry').overrideWith(
            (ref) => const <DictionaryItem>[],
          ),
          dictionaryProvider('region').overrideWith(
            (ref) => const <DictionaryItem>[],
          ),
          // The required-evidence list now shows the dictionary's word for
          // each purpose rather than its code (MT-012). `evidence` is
          // deliberately absent, so one row exercises the fallback.
          dictionaryProvider('file_purpose').overrideWith(
            (ref) => const [
              DictionaryItem(
                id: 'purpose-1',
                code: 'company_registration',
                label: 'Company registration document',
                sortOrder: 1,
                isActive: true,
              ),
            ],
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

      // Through the notifier rather than the form: §6.1's mandatory set now
      // gates the first save, and this harness serves an empty region
      // dictionary, so the picker cannot be driven. What this test is about is
      // the *body*, not the typing.
      _fill(tester, type: 'individual');
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

      // Served rather than hardcoded: §6.1 leaves the policy open. And named
      // in words — an employer being told which document to upload is the last
      // person who should have to read `company_registration` (MT-012).
      expect(find.text('Company registration document'), findsOneWidget);
      expect(find.text('company_registration'), findsNothing);

      // The dictionary has no row for this one, so it falls back to the
      // humanised code rather than to "Unavailable value".
      expect(find.text('Evidence'), findsOneWidget);

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('offers a way to upload each document it demands', (
      tester,
    ) async {
      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(),
          state: VerificationState.fromJson(const {
            'status': 'not_submitted',
            'requiredEvidence': [
              {'purposeCode': 'company_registration', 'required': true},
            ],
            'submissions': <dynamic>[],
            'upload': {
              'acceptedExtensions': ['pdf'],
              'maxSizeBytes': 10485760,
            },
          }),
        ),
      );

      // **The bug this exists for.** The card marked the certificate
      // "Required" from the day it shipped and gave no way to supply one:
      // `submit` sent an empty list and left the server to explain the
      // refusal. A screen that names an obligation it cannot let you meet is
      // worse than one that says nothing.
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Nothing uploaded yet'), findsOneWidget);
    });

    testWidgets('will not submit while a required document is missing', (
      tester,
    ) async {
      final fake = _FakeEmployer(
        profile: _profile(),
        state: VerificationState.fromJson(const {
          'status': 'not_submitted',
          'requiredEvidence': [
            {'purposeCode': 'company_registration', 'required': true},
          ],
          'submissions': <dynamic>[],
        }),
      );

      await pump(tester, repository: fake);

      // Stated, not implied: a disabled button with no reason is the same
      // dead end as a button that fails when pressed.
      expect(
        find.text(
          'Upload every required document before submitting for verification.',
        ),
        findsOneWidget,
      );

      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Submit for verification'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an optional document alone does not block the submission', (
      tester,
    ) async {
      final fake = _FakeEmployer(
        profile: _profile(),
        state: VerificationState.fromJson(const {
          'status': 'not_submitted',
          'requiredEvidence': [
            {'purposeCode': 'evidence', 'required': false},
          ],
          'submissions': <dynamic>[],
        }),
      );

      await pump(tester, repository: fake);

      // `required: false` is §6.1's "if required by policy" saying no. Holding
      // the submission for it would make the flag meaningless.
      final button = tester.widget<HhButton>(
        find.widgetWithText(HhButton, 'Submit for verification'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('submits the ids of the documents it was asked for', (
      tester,
    ) async {
      final fake = _FakeEmployer(
        profile: _profile(),
        state: VerificationState.fromJson(const {
          'status': 'not_submitted',
          'requiredEvidence': [
            {'purposeCode': 'company_registration', 'required': true},
          ],
          'submissions': <dynamic>[],
        }),
      );

      await pump(
        tester,
        repository: fake,
        evidence: [
          _file(purposeCode: 'company_registration', id: 'wanted'),
          // The account holds this one too. Attaching it would put a document
          // in front of an administrator that nobody asked for.
          _file(purposeCode: 'logo', id: 'unwanted', fileName: 'logo.png'),
        ],
      );

      // The profile form is long enough that the card sits below the fold.
      final submit = find.text('Submit for verification');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(fake.submitted, [
        ['wanted'],
      ]);
    });

    testWidgets('an uploaded document is named, and offers replacement', (
      tester,
    ) async {
      await pump(
        tester,
        repository: _FakeEmployer(
          profile: _profile(),
          state: VerificationState.fromJson(const {
            'status': 'not_submitted',
            'requiredEvidence': [
              {'purposeCode': 'company_registration', 'required': true},
            ],
            'submissions': <dynamic>[],
          }),
        ),
        evidence: [_file(purposeCode: 'company_registration')],
      );

      expect(find.text('registration.pdf'), findsOneWidget);
      expect(find.text('Nothing uploaded yet'), findsNothing);
      // §5.4's "replace": uploading again retires the old one server-side, so
      // the button says what pressing it does.
      expect(find.text('Replace'), findsOneWidget);
      expect(find.text('Upload'), findsNothing);
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

  group('a permanent choice is never made by default (MT-007)', () {
    testWidgets('nothing is preselected, and no form is drawn yet', (
      tester,
    ) async {
      await pump(tester);

      // The type used to default to Company, and the first Save locked it —
      // so a premature tap committed a decision nobody made, with no route
      // back. `employer.type_immutable` is the server's word for permanent.
      expect(find.text('A company'), findsOneWidget);
      expect(find.text('An individual'), findsOneWidget);
      expect(
        tester
            .widgetList<HhRadioRow<String>>(find.byType(HhRadioRow<String>))
            .every((row) => row.groupValue == null),
        isTrue,
      );

      // Which fields exist *is* the answer to the question above them.
      expect(find.text('Registered name'), findsNothing);
      expect(find.text('Your full name'), findsNothing);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('an empty first save writes nothing and says what is left', (
      tester,
    ) async {
      final fake = await pump(tester);

      await tester.tap(find.text('An individual'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The 0%-complete, type-locked account the audit found: one tap, and
      // vacancies, candidate search and verification all blocked with no reset.
      expect(fake.saved, isEmpty);
      expect(find.textContaining('Still needed'), findsOneWidget);
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('and it goes through once §6.1 is answered', (tester) async {
      final fake = await pump(tester);

      await tester.tap(find.text('An individual'));
      await tester.pump();
      _fill(tester, type: 'individual');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.saved, hasLength(1));
      expect(find.textContaining('Still needed'), findsNothing);
    });

    testWidgets('a later edit is not held to the same bar', (tester) async {
      // The first save is the strict one because it is what locks the type.
      // Afterwards the type is settled, so refusing a half-finished edit would
      // only lose somebody's typing.
      final fake = await pump(
        tester,
        repository: _FakeEmployer(profile: _profile(type: 'individual')),
      );

      await tester.enterText(find.byType(TextField).first, 'Ali Valiyev');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.saved, hasLength(1));
    });
  });

  group('a save refreshes what depends on the profile (MT-011)', () {
    testWidgets('verification is re-read rather than left on its 404', (
      tester,
    ) async {
      final fake = await pump(tester);

      await tester.tap(find.text('An individual'));
      await tester.pump();
      _fill(tester, type: 'individual');
      await tester.pump();

      final before = fake.verificationReads;

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Until this, a successful first save left the verification card showing
      // `employer.not_found` until somebody tapped Try again — a save that
      // looked like it had not unlocked its next step.
      expect(fake.verificationReads, greaterThan(before));
    });
  });
}
