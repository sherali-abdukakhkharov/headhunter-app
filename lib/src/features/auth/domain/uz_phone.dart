import 'package:flutter/foundation.dart';

/// The one place that knows how a phone number becomes a wire value.
///
/// Two different strings are in play and confusing them is silent: the user
/// types a **national** number (`90 123 45 67`) and the API takes an **E.164**
/// one (`+998901234567`). The backend normalises whatever it is given, but its
/// per-phone rate limiter keys on the normalised value, so a screen that sent
/// `901234567` and one that sent `+998901234567` would be counted as one
/// subject only by luck.
///
/// A type rather than two loose functions, so "is this string a wire number or
/// a typed one?" is answerable from the signature.
@immutable
class UzPhone {
  const UzPhone._(this.nationalDigits);

  /// Builds from raw user input, keeping only digits and dropping a leading
  /// country code if the user typed one.
  ///
  /// Tolerant on purpose. People paste `+998 90 123 45 67`, type
  /// `998901234567` out of habit, and add a leading zero from landline
  /// convention. Rejecting any of those teaches nothing — the field wants nine
  /// digits and the prefix chip already says `+998`.
  factory UzPhone.parse(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');

    if (digits.length > nationalLength && digits.startsWith(countryCode)) {
      digits = digits.substring(countryCode.length);
    } else if (digits.length > nationalLength && digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return UzPhone._(digits);
  }

  /// Uzbekistan. The platform is Uzbekistan-only (§1), so this is a constant
  /// rather than a picker — a country selector on the sign-in screen would be
  /// four taps of friction for a choice nobody has.
  static const countryCode = '998';

  /// Subscriber numbers are nine digits: a two-digit operator or area code and
  /// seven digits.
  static const nationalLength = 9;

  /// The national part, digits only. What the user typed, cleaned up.
  final String nationalDigits;

  /// Whether this is a plausible Uzbek number.
  ///
  /// Length only. A whitelist of operator prefixes (90, 91, 93, …) would be
  /// tighter, and it would lock out the first user on whatever code an operator
  /// launches next — a registration failure nobody could diagnose from inside
  /// the app. The real validation is the code arriving.
  bool get isValid => nationalDigits.length == nationalLength;

  /// E.164 for the API: `+998901234567`.
  String get wire => '+$countryCode$nationalDigits';

  /// Grouped for display: `+998 90 123 45 67`.
  ///
  /// Used on the code screen, where the user needs to confirm at a glance that
  /// the code went to the number they meant. An unspaced run of twelve digits
  /// is exactly the thing a typo hides in.
  String get display {
    if (!isValid) return wire;
    final d = nationalDigits;
    return '+$countryCode ${d.substring(0, 2)} ${d.substring(2, 5)} '
        '${d.substring(5, 7)} ${d.substring(7)}';
  }

  @override
  bool operator ==(Object other) =>
      other is UzPhone && other.nationalDigits == nationalDigits;

  @override
  int get hashCode => nationalDigits.hashCode;

  /// Last two digits only, matching the backend's `maskPhone`.
  String get masked {
    final tail = nationalDigits.length < 2
        ? nationalDigits
        : nationalDigits.substring(nationalDigits.length - 2);
    return '***$tail';
  }

  /// Masked. §12.1 forbids logging a full number and `toString` is what ends up
  /// in logs and crash reports; a call site that genuinely needs the number
  /// asks for [wire] or [display] and means it.
  @override
  String toString() => 'UzPhone($masked)';
}
