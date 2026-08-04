import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/auth/session_controller.dart';
import 'package:headhunter_app/src/core/auth/session_state.dart';
import 'package:headhunter_app/src/core/design/design.dart';

/// **BR-10.** Where a blocked account is held, with the reason.
///
/// The requirement is not merely to deny access - it is to *explain*. An app
/// that silently fails every request teaches the user that the product is
/// broken, and they contact support about the wrong problem. So this screen
/// names the restriction and shows the administrator's stated reason (§10.4).
///
/// The reason is rendered **verbatim**: it is admin-authored content, and §2.4
/// forbids translating that client-side. The server already returns it in the
/// `x-lang` locale. Only the fallback body - shown when no reason was given -
/// is a localized string of ours.
///
/// Signing out stays available. A blocked user may hold another account, and
/// trapping them on a dead end with no action is the state people screenshot
/// and send to support.
class BlockedAccountScreen extends ConsumerWidget {
  const BlockedAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final session = ref.watch(sessionControllerProvider);

    final reason = session is SessionActive ? session.restrictionReason : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HhSpace.xxl),
              HhNotice.restricted(
                title: l10n.blockedTitle,
                message: reason ?? l10n.blockedBody,
              ),
              const SizedBox(height: HhSpace.sectionGap),
              HhButton.secondary(
                label: l10n.commonSignOut,
                iconPath: HhIconPath.lock,
                onPressed: () =>
                    ref.read(sessionControllerProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
