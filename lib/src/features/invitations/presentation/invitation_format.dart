import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';

/// §8.2's payment context on a **general** invitation, or null when it carried
/// none.
///
/// Vacancy invitations deliberately have no pay of their own — theirs lives on
/// the vacancy, and copying it here would let the two drift apart.
///
/// Negotiable wins over a figure rather than being appended to it: they are
/// different answers, and "500,000 (negotiable)" is neither of them. The
/// thousands separators come from the ARB's `decimalPattern`, so they follow
/// the interface variant rather than being punched in with a Dart format
/// string.
String? invitationPay(Invitation invitation, AppL10n l10n) {
  if (invitation.salaryIsNegotiable) return l10n.vacancyNegotiablePay;

  return switch ((invitation.salaryFrom, invitation.salaryTo)) {
    (final from?, final to?) => l10n.invitationPayRange(from, to),
    (final from?, null) => l10n.invitationPayFrom(from),
    (null, final to?) => l10n.invitationPayUpTo(to),
    _ => null,
  };
}
