import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/profile/domain/history_record.dart';

/// The two bespoke record types (§5.1).
///
/// The clearing semantics are what these mostly defend. Every optional field
/// here is clearable, and a `copyWith` written the usual way (`?? this.x`)
/// cannot express "set this to null" — it silently keeps the old value. That is
/// the same class of bug as treating a null edit as "no edit" in the form
/// engine, and it only shows up as a field that refuses to be emptied.
void main() {
  group('ExperienceDraft', () {
    const filled = ExperienceDraft(
      employerName: 'Uzum',
      roleTitle: 'Dasturchi',
      occupationId: 'f1a0-9c33',
      startedOn: '2024-03-01',
      endedOn: '2025-08-31',
      responsibilities: 'Flutter',
    );

    test('needs a role and a start date, and nothing else', () {
      // §5.1's simplified entry: a seasonal worker may be able to supply only
      // what they did and when they started.
      const minimal = ExperienceDraft(
        roleTitle: 'Terimchi',
        startedOn: '2025-06-01',
      );

      expect(minimal.isComplete, isTrue);
    });

    test('is incomplete without a start date', () {
      const draft = ExperienceDraft(roleTitle: 'Terimchi');

      expect(draft.isComplete, isFalse);
    });

    test('is incomplete with a one-character role', () {
      // The server's own floor is 2, so accepting 1 here would only move the
      // refusal to save time.
      const draft = ExperienceDraft(roleTitle: 'X', startedOn: '2025-06-01');

      expect(draft.isComplete, isFalse);
    });

    test('is incomplete when the role is only whitespace', () {
      const draft = ExperienceDraft(roleTitle: '   ', startedOn: '2025-06-01');

      expect(draft.isComplete, isFalse);
    });

    test('copyWith clears an optional field when asked', () {
      final cleared = filled.copyWith(employerName: null, endedOn: null);

      expect(cleared.employerName, isNull);
      expect(cleared.endedOn, isNull);
      // Untouched fields survive the clear.
      expect(cleared.roleTitle, 'Dasturchi');
      expect(cleared.occupationId, 'f1a0-9c33');
    });

    test('copyWith leaves a field alone when it is not named', () {
      final same = filled.copyWith(roleTitle: 'Katta dasturchi');

      expect(same.employerName, 'Uzum');
      expect(same.endedOn, '2025-08-31');
      expect(same.roleTitle, 'Katta dasturchi');
    });

    test('toJson carries every key the input DTO declares', () {
      // A dropped key is a field that silently stops saving, and `PUT` is a
      // full replacement — so an omitted key clears the value server-side.
      expect(filled.toJson().keys, {
        'employerName',
        'roleTitle',
        'occupationId',
        'startedOn',
        'endedOn',
        'isCurrent',
        'responsibilities',
      });
    });

    test('a record round-trips into a draft carrying the same values', () {
      const record = ExperienceRecord(
        id: 'rec-1',
        roleTitle: 'Dasturchi',
        startedOn: '2024-03-01',
        isCurrent: true,
        employerName: 'Uzum',
      );

      final draft = record.toDraft();

      expect(draft.roleTitle, 'Dasturchi');
      expect(draft.startedOn, '2024-03-01');
      expect(draft.isCurrent, isTrue);
      expect(draft.employerName, 'Uzum');
      // The id is deliberately not on a draft: a draft cannot carry a stale id
      // into a POST, because there is nowhere to put one.
      expect(draft.toJson().containsKey('id'), isFalse);
    });

    test('parses the shape the server returns', () {
      final record = ExperienceRecord.fromJson(const {
        'id': 'rec-1',
        'employerName': null,
        'roleTitle': 'Terimchi',
        'occupationId': null,
        'startedOn': '2025-06-01',
        'endedOn': null,
        'isCurrent': false,
        'responsibilities': null,
      });

      expect(record.roleTitle, 'Terimchi');
      expect(record.employerName, isNull);
      expect(record.isCurrent, isFalse);
    });
  });

  group('EducationDraft', () {
    test('needs only a level', () {
      const draft = EducationDraft(levelId: '9b3f-0d47');

      expect(draft.isComplete, isTrue);
    });

    test('is incomplete without one', () {
      const draft = EducationDraft(institution: 'TATU');

      expect(draft.isComplete, isFalse);
    });

    test('copyWith clears an optional field when asked', () {
      const filled = EducationDraft(
        levelId: '9b3f-0d47',
        institution: 'TATU',
        specialization: 'Dasturiy injiniring',
        graduationYear: 2020,
      );

      final cleared = filled.copyWith(institution: null, graduationYear: null);

      expect(cleared.institution, isNull);
      expect(cleared.graduationYear, isNull);
      expect(cleared.levelId, '9b3f-0d47');
      expect(cleared.specialization, 'Dasturiy injiniring');
    });

    test('toJson carries every key the input DTO declares', () {
      const draft = EducationDraft(levelId: '9b3f-0d47');

      expect(draft.toJson().keys, {
        'levelId',
        'institution',
        'specialization',
        'graduationYear',
      });
    });
  });
}
