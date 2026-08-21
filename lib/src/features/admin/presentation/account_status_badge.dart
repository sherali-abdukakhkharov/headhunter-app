import 'package:flutter/widgets.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

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
///
/// No glyph repeats within the type, and none of the three is borrowed from a
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
  _ => HhBadge(
    label: l10n.adminAccountStatusActive,
    tone: HhTone.success,
    iconPath: HhIconPath.checkCircle,
  ),
};
