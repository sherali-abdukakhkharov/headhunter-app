import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/features/profile/data/profile_repository.dart';

/// A 422 has to land **on the field that caused it** (§4.6).
///
/// The interesting case is the composite one: `dictionary_leveled` and
/// `money_range` are single widgets the server reports on by part, so a
/// rejection arrives keyed on something no widget answers to.
void main() {
  FieldValidationException refusal(List<(String, String)> errors) =>
      FieldValidationException('Validation failed', [
        for (final (code, message) in errors)
          FieldError(code: code, rule: 'invalid', message: message),
      ]);

  test('a plain field keys on itself', () {
    final byCode = refusal([('firstName', 'Too short')]).byCode;

    expect(byCode, {'firstName': 'Too short'});
  });

  test('a composite field keys on the widget, not the part', () {
    // `skills` is one editor. Keyed on `skills.levelId` the message attaches to
    // nothing and the form shows a banner with no indication of where to look.
    final byCode = refusal([('skills.levelId', 'Pick a level')]).byCode;

    expect(byCode, {'skills': 'Pick a level'});
  });

  test('several parts of one field collapse to the first message', () {
    final byCode = refusal([
      ('salary.from', 'Must not exceed the maximum'),
      ('salary.to', 'Must be at least the minimum'),
    ]).byCode;

    // One message under the field rather than a last-write-wins scramble.
    expect(byCode, {'salary': 'Must not exceed the maximum'});
  });

  test('a part does not shadow a sibling field', () {
    final byCode = refusal([
      ('skills.levelId', 'Pick a level'),
      ('languages.itemId', 'Unknown language'),
    ]).byCode;

    expect(byCode, {
      'skills': 'Pick a level',
      'languages': 'Unknown language',
    });
  });

  test('falls back to the rule when the server sent no message', () {
    const refused = FieldValidationException('Validation failed', [
      FieldError(code: 'birthDate', rule: 'must_be_in_the_past'),
    ]);

    expect(refused.byCode, {'birthDate': 'must_be_in_the_past'});
  });
}
