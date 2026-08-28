import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';

/// Switches the active role **and** navigates into its shell (§2.3).
///
/// ## Why this is one function and not two calls
///
/// A role switch is not a state change that the router can complete on its own,
/// and the reason is worth stating because the opposite seems true:
///
/// After `switchRole(employer)` the *location is still* `/candidate/home`. The
/// redirect chain's deep-link rule - a granted role named by the path becomes
/// the active one, so a notification can open an employer screen without the
/// guard bouncing it (ARCHITECTURE.md §3) - then reads that location and
/// re-activates **candidate**, silently undoing the switch. The two rules are
/// both correct and they pull in opposite directions, because
/// `(location, session)` cannot distinguish "the user asked for a different
/// role" from "the user opened a link belonging to a different role".
///
/// Resolving it in the redirect is not possible without a flag that says which
/// of the two just happened - which is a mode bit in a guard, and guards with
/// mode bits are where routing bugs live. So the location stays authoritative,
/// and a role switch states its destination explicitly. One rule, no ambiguity.
///
/// Found on a device: the switcher appeared to do nothing, and both the widget
/// tests and `flutter analyze` were green.
///
/// ## The window between the two, and why it needs a flag after all
///
/// The paragraphs above end with "one rule, no ambiguity" and that was half
/// right. The location is authoritative and the switch states its destination —
/// but not at the same instant. Between the moment the role changes and the
/// moment `context.go` runs, the location still names the role being *left*, so
/// the deep-link rule reads it and starts a switch back. Both switches then
/// publish to `/auth/active-role` and the access token ends up naming whichever
/// answered last: Admin opened on the employer's token and said *"This action
/// requires admin."* until the user pressed Retry (MT-027).
///
/// So the transition is bracketed. [SessionController.beginRoleSwitch] opens
/// the window and the redirect chain leaves the deep-link rule alone while it
/// is open; the `finally` closes it once the destination has been stated and
/// the two agree again. It is the mode bit the paragraph above hoped to avoid —
/// but it is scoped to one function's `try`, it names the window it covers, and
/// the alternative was a race that reached a device.
Future<void> switchRoleAndGo(
  BuildContext context,
  WidgetRef ref,
  AppRole role,
) async {
  final controller = ref.read(sessionControllerProvider.notifier);

  // A second tap while the first switch is still in flight. Dropping out is
  // right: the first one is already going where this one wanted to go.
  if (!controller.beginRoleSwitch(role)) return;

  try {
    await controller.switchRole(role);
    if (context.mounted) context.go(Routes.homeFor(role));
  } finally {
    controller.endRoleSwitch();
  }
}
