import 'package:jobbridge_app/l10n/generated/app_l10n.dart';

/// One vacancy's pay, worded (§6.3).
///
/// ## Why this is shared
///
/// Three screens showed pay — the candidate's feed, the vacancy detail behind
/// it, and the administrator's moderation review — and all three had their own
/// copy of the same six lines. Every copy rendered `150000 – 250000`: no
/// separators, no currency, no period. A reader had to count digits to tell a
/// hundred and fifty thousand from a million and a half, and there was nothing
/// on screen saying what currency it was or what it was per (MT-012).
///
/// Three copies is also how they came to disagree in the first place, and why
/// this is a function rather than a fourth copy.
///
/// ## Nothing here is computed
///
/// §12.3.1 puts amounts on the server. These integers are rendered, never
/// combined into a monthly equivalent, converted, or averaged. The separators
/// come from the ARB's `decimalPattern`, so grouping follows the interface
/// variant rather than a rule written in Dart.
///
/// [negotiable] wins over a range because that is the server's own precedence:
/// the vacancy form discards a typed range when negotiable is set.
///
/// [period] is a **resolved** `payment_period` label, never an id and never a
/// code — see `optionalLabel`. Null is a normal answer, both while the
/// dictionary is still loading and when the vacancy states no period, and it is
/// omitted rather than guessed. "150 000 so'm / …" reads as a rendering fault;
/// "150 000 so'm" is simply the part that is known.
String formatPay(
  AppL10n l10n, {
  required bool negotiable,
  int? from,
  int? to,
  String? period,
}) {
  if (negotiable || (from == null && to == null)) {
    return l10n.vacancyNegotiablePay;
  }

  final money = switch ((from, to)) {
    (final f?, final t?) => l10n.vacancyPayRange(f, t),
    (final f?, null) => l10n.vacancyPayFrom(f),
    (null, final t?) => l10n.vacancyPayUpTo(t),
    // Unreachable: the guard above returns for two nulls. Written out because
    // an exhaustive switch is what keeps it that way.
    _ => l10n.vacancyNegotiablePay,
  };

  if (period == null) return money;

  return l10n.vacancyPayPeriod(money, period);
}
