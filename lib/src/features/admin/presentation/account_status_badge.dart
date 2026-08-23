import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_user.dart';

/// The badge for an account's status (§4.2, BR-10).
///
/// ## Why this is not a named `HhBadge` constructor
///
/// The design system's badge vocabulary covers vacancy, application,
/// invitation, interview, conversation and verification state — six object
/// types, each with named constructors that *are* the vocabulary. Account
/// status is a seventh, and adding it means editing the design system, which
/// this project requires running the gallery on a device to do (three bugs a
/// green `flutter analyze` and a green test suite both missed — MEMORY.md).
///
/// So it is built from the generic constructor here, the same way §10.2's BR-12
/// restriction flag is, and kept in **one function** so it is a single edit to
/// promote later. The glyph rule is still followed rather than ignored:
///
/// - `active` → check-circle, the glyph that means a person was accepted
/// - `restricted` → alert-triangle, warning-toned: some actions refused, and
///   §4.2 makes that a notice at the point of use rather than a lockout
/// - `blocked` → x-circle, the glyph that means a negative outcome with a
///   reason always attached, which BR-10 requires
/// - `deletion_requested` → trash, and **neutral**, because it is not a
///   sanction: BR-14's own flow put the account there and no administrator
///   action applies to it (§10.4). Toning it like a punishment would be the
///   screen inviting exactly the decision the server refuses
///
/// No glyph repeats within the type, and none of the four is borrowed from a
/// different meaning elsewhere.
///
/// An unrecognised status reads as `active`, the same fallback rule
/// `vacancyBadge` uses: a status this build has not heard of should not blank
/// out the row it belongs to.
Widget accountStatusBadge(String? status, AppL10n l10n) => switch (status) {
  'restricted' => HhBadge(
    label: l10n.adminAccountStatusRestricted,
    tone: HhTone.warning,
    iconPath: HhIconPath.alertTriangle,
  ),
  'blocked' => HhBadge(
    label: l10n.adminAccountStatusBlocked,
    tone: HhTone.error,
    iconPath: HhIconPath.xCircle,
  ),
  'deletion_requested' => HhBadge(
    label: l10n.adminAccountStatusDeletionRequested,
    tone: HhTone.neutral,
    iconPath: HhIconPath.trash,
  ),
  _ => HhBadge(
    label: l10n.adminAccountStatusActive,
    tone: HhTone.success,
    iconPath: HhIconPath.checkCircle,
  ),
};

/// The same four words, without the badge.
///
/// §10.4's history reads "restricted, from active" — a sentence about a change,
/// where a second badge would claim the account is in two states at once. The
/// labels come from the same keys the badge uses, so the two can never drift
/// into calling one status by two names.
String accountStatusLabel(UserAccountStatus status, AppL10n l10n) =>
    switch (status) {
      UserAccountStatus.active => l10n.adminAccountStatusActive,
      UserAccountStatus.restricted => l10n.adminAccountStatusRestricted,
      UserAccountStatus.blocked => l10n.adminAccountStatusBlocked,
      UserAccountStatus.deletionRequested =>
        l10n.adminAccountStatusDeletionRequested,
    };

/// One role the account holds, as a meta chip (§2.3).
///
/// Shared by §10.4's list row and its detail so the two cannot end up calling
/// one role by two names or drawing it with two glyphs. The glyphs are the
/// ones the rest of the app already uses for the three roles: a person, a
/// building, a shield.
///
/// **Only single-word labels belong in an `HhMetaChip`.** Its `Row` is
/// `MainAxisSize.min` around an unconstrained `Text`, so a long label overflows
/// its card rather than truncating — the flaw `HhRemovableChip` documents and
/// solves for the filter row. Facts with a date in them are captions here for
/// exactly that reason.
Widget roleChip(AppRole role, AppL10n l10n) => HhMetaChip(
  label: switch (role) {
    AppRole.candidate => l10n.roleCandidate,
    AppRole.employer => l10n.roleEmployer,
    AppRole.admin => l10n.roleAdmin,
  },
  iconPath: switch (role) {
    AppRole.candidate => HhIconPath.person,
    AppRole.employer => HhIconPath.building,
    AppRole.admin => HhIconPath.shieldCheck,
  },
);
