import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/core/router/shell_tabs.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notification_primer.dart';

/// The navigation shell for one role.
///
/// There is one of these per role rather than a single shell that hides tabs,
/// because §2.2 and §10 give the three roles genuinely different information
/// architectures, and §2.3 lets a user switch between them at runtime. A shared
/// shell leaks navigation state across the switch - you land on the employer's
/// "Vacancies" tab showing the stack you left behind in the candidate's.
class RoleShell extends ConsumerStatefulWidget {
  const RoleShell({
    required this.role,
    required this.navigationShell,
    super.key,
  });

  final AppRole role;

  /// Supplied by `StatefulShellRoute.indexedStack`. Owns one navigator per tab,
  /// which is what keeps each tab's back stack intact across tab switches.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends ConsumerState<RoleShell> {
  @override
  void initState() {
    super.initState();

    // §9.2's permission, asked **after** onboarding rather than inside it.
    //
    // Here rather than at sign-in because this is the first moment the user is
    // somewhere: a role is chosen, a shell is on screen, and the sheet can name
    // what a notification would be about. The audit found the OS dialog opening
    // straight after the OTP, sometimes before a role had been picked at all.
    //
    // A post-frame callback because a route cannot be pushed while the tree
    // that would host it is still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerNotifications());
  }

  Future<void> _offerNotifications() async {
    // Read, not watched: this asks once per install, and a rebuild is not a
    // reason to ask again.
    final seen = await ref.read(notificationPrimerProvider.future);
    if (seen || !mounted) return;

    await showNotificationPrimer(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final tabs = ShellTabs.forRole(widget.role);

    return Scaffold(
      // No backgroundColor override: HhTheme.light already sets
      // scaffoldBackgroundColor from the design's tokens, and restating it here
      // is how a screen ends up one shade off the rest of the app.
      body: widget.navigationShell,
      // Dev-only way back to the tools, and it belongs on the shell rather than
      // on a screen for two reasons: every tab inherits it, and the placeholder
      // screens that would otherwise host it are deleted milestone by
      // milestone. Without it there is no route out of a shell once signed in -
      // the role switcher becomes unreachable, and deep links are not wired up
      // until M8. Absent entirely in the production flavor.
      floatingActionButton: AppFlavor.current.allowsDevelopmentTools
          ? FloatingActionButton.small(
              onPressed: () => context.push(Routes.developerTools),
              backgroundColor: HhColors.brand900,
              foregroundColor: HhColors.accentOnDark,
              tooltip: 'Developer tools',
              child: const HhIcon(
                HhIconPath.filters,
                size: 20,
                color: HhColors.accentOnDark,
                semanticLabel: 'Developer tools',
              ),
            )
          : null,
      bottomNavigationBar: HhBottomNav(
        items: [
          for (final tab in tabs)
            HhNavItem(iconPath: tab.iconPath, label: tab.label(l10n)),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        // initialLocation: true when the tab is re-tapped, which pops that
        // branch back to its root. The platform-standard gesture for "get me
        // out of wherever I drilled to", and users try it before they try Back.
        onSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
