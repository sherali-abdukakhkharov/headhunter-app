import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';

/// The word for one of §2.3's three roles.
///
/// One function rather than a `switch` at each call site. There were four —
/// the admin user detail, the admin user search, the account status badge and
/// the role switcher — and four switches over the same three values is how a
/// role ends up worded differently on two screens, which is the same reasoning
/// `verificationLabel` is written down for.
String roleLabel(AppRole role, AppL10n l10n) => switch (role) {
  AppRole.candidate => l10n.roleCandidate,
  AppRole.employer => l10n.roleEmployer,
  AppRole.admin => l10n.roleAdmin,
};
