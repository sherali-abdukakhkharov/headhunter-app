import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';

/// A date and time as the platform recorded it.
///
/// Takes a `ZonedTimestamp.wallClock` and formats its fields directly — never
/// `.toLocal()`, which would re-render in the device's zone and show a
/// candidate abroad the wrong time (§8.3). ISO-ordered rather than localized
/// because §8.3's display policy is still open, and a wrong-looking date is
/// better than a plausible wrong one.
///
/// Shared by both sides of §8.2: the candidate's inbox and the employer's sent
/// list are two views of one resource and must not date it differently.
String invitationStamp(DateTime wallClock) =>
    '${wallClock.year.toString().padLeft(4, '0')}-'
    '${wallClock.month.toString().padLeft(2, '0')}-'
    '${wallClock.day.toString().padLeft(2, '0')} '
    '${wallClock.hour.toString().padLeft(2, '0')}:'
    '${wallClock.minute.toString().padLeft(2, '0')}';

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
