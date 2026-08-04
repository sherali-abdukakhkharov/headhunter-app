import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/auth/session_controller.dart';
import 'package:headhunter_app/src/core/router/routes.dart';

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
Future<void> switchRoleAndGo(
  BuildContext context,
  WidgetRef ref,
  AppRole role,
) async {
  await ref.read(sessionControllerProvider.notifier).switchRole(role);
  if (context.mounted) context.go(Routes.homeFor(role));
}
