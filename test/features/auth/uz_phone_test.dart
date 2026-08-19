import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';

/// The wire format is the thing worth pinning here.
///
/// A phone that reaches the API in two different spellings is counted as two
/// different subjects by the backend's per-phone rate limiter and its
/// one-live-code-per-phone index. Both failures are silent and neither shows up
/// until someone is locked out of registration.
void main() {
  group('UzPhone.parse', () {
    test('takes nine typed digits as the national part', () {
      final phone = UzPhone.parse('901234567');

      expect(phone.isValid, isTrue);
      expect(phone.wire, '+998901234567');
    });

    test('strips the formatting a user pastes', () {
      // Every one of these is a real thing people paste out of a contact card
      // or a chat message, and all of them mean one number.
      for (final input in [
        '+998 90 123 45 67',
        '998901234567',
        '+998901234567',
        '(90) 123-45-67',
        '90 123 45 67',
      ]) {
        expect(
          UzPhone.parse(input).wire,
          '+998901234567',
          reason: '$input should reach the API in one spelling',
        );
      }
    });

    test('drops a landline-habit leading zero', () {
      expect(UzPhone.parse('0901234567').wire, '+998901234567');
    });

    test('does not mistake a national number starting 998 for a code', () {
      // 99 is a real operator code, so `998123456` is nine digits of national
      // number - not the country code plus six. Stripping a prefix that is
      // already the whole number would corrupt it.
      final phone = UzPhone.parse('998123456');

      expect(phone.isValid, isTrue);
      expect(phone.wire, '+998998123456');
    });

    test('an incomplete number is invalid rather than sent', () {
      expect(UzPhone.parse('9012345').isValid, isFalse);
      expect(UzPhone.parse('').isValid, isFalse);
      expect(UzPhone.parse('abc').isValid, isFalse);
    });

    test('accepts any operator code of the right length', () {
      // Deliberately not a whitelist: a new operator prefix must not lock its
      // first users out of registration.
      expect(UzPhone.parse('001234567').isValid, isTrue);
    });
  });

  group('display', () {
    test('groups the number so a typo is visible', () {
      expect(UzPhone.parse('901234567').display, '+998 90 123 45 67');
    });

    test('falls back to the wire form when incomplete', () {
      expect(UzPhone.parse('9012').display, '+9989012');
    });
  });

  test('toString masks the number (§12.1)', () {
    // toString is what reaches log lines and crash reports.
    final phone = UzPhone.parse('901234567');

    expect(phone.toString(), isNot(contains('901234')));
    expect(phone.toString(), contains('67'));
  });

  test('two spellings of one number are equal', () {
    expect(UzPhone.parse('+998 90 123 45 67'), UzPhone.parse('901234567'));
    expect(
      UzPhone.parse('+998 90 123 45 67').hashCode,
      UzPhone.parse('901234567').hashCode,
    );
  });
}
