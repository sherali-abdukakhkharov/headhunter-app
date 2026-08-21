import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/presentation/moderation_queue_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/verification_queue_screen.dart';

/// §10.2's moderation tab: two queues behind one segmented control.
///
/// ## Why one tab holds two queues
///
/// §10.2 is one section covering employer verification *and* vacancy
/// moderation, and the admin shell has five destinations against the design's
/// five-tab cap — the same cap that kept Wallet off the employer's nav bar and
/// made the balance chip the way in. Two segments at 360pt give each about
/// 175pt, which fits both labels in all four interface variants; the status
/// filters that were kept off `HhSegmented` had five and nine.
///
/// ## Which queue is showing lives in the location, not in state
///
/// `StatefulShellRoute` keeps a branch's state across tab switches, so a
/// segment held in a `State` would survive a later `go` and ignore it — and
/// §10.1's dashboard has a counter per queue. Both counters would then land on
/// whichever queue was last looked at, which is the class of bug
/// `switchRoleAndGo` exists to prevent one level up. So the segment is a query
/// parameter and tapping one navigates.
///
/// Anything unrecognised — or absent — reads as verification, because that is
/// the queue an unqualified "moderation" most likely means and because a
/// mistyped deep link should land somewhere real.
class AdminQueueScreen extends ConsumerWidget {
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final router = GoRouter.of(context);

    final showingVacancies =
        GoRouterState.of(
          context,
        ).uri.queryParameters[Routes.adminQueueParam] ==
        Routes.adminQueueVacancies;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HhSpace.gutter,
                HhSpace.gutter,
                HhSpace.gutter,
                HhSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.adminQueueTitle, style: HhTypography.title),
                  const SizedBox(height: HhSpace.md),
                  HhSegmented(
                    labels: [
                      l10n.adminQueueEmployers,
                      l10n.adminQueueVacancies,
                    ],
                    selectedIndex: showingVacancies ? 1 : 0,
                    onChanged: (index) => router.go(
                      Routes.adminQueueWith(
                        index == 1
                            ? Routes.adminQueueVacancies
                            : Routes.adminQueueVerification,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: showingVacancies
                  ? const ModerationQueueList()
                  : const VerificationQueueList(),
            ),
          ],
        ),
      ),
    );
  }
}
