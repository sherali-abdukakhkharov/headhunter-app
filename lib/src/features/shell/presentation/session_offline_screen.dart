import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// §12.4's explicit offline state, for a cold start that could not reach the
/// server.
///
/// ## Why this is not the sign-in screen
///
/// It used to be. `restore` kept the tokens when a refresh could not complete —
/// which is right, the session is probably fine — and then published
/// `SessionUnauthenticated`, so the redirect chain sent a signed-in user to
/// enter their phone number. Two things were wrong with that. It **says the
/// session is gone** when nothing indicates that, and the only action it offers
/// needs an SMS, over the network that is missing.
///
/// So the screen has one job the sign-in screen cannot do: say the account is
/// still there, and offer the retry.
///
/// ## The retry re-runs the whole restore
///
/// Not a bare refresh call. `restore` reads the stored role, exchanges the
/// token, adopts the roles and account status the server returns and falls back
/// to development roles where there is no token — and a retry that did only the
/// middle step would leave the other four to be discovered as bugs later.
///
/// ## And there is a way out
///
/// A token the server will never accept again, or a server that stays down,
/// would otherwise trap somebody on a screen whose only button does nothing.
/// Sign-out is best-effort and clears locally, so it works without the network
/// this screen is about.
class SessionOfflineScreen extends ConsumerStatefulWidget {
  const SessionOfflineScreen({super.key});

  @override
  ConsumerState<SessionOfflineScreen> createState() =>
      _SessionOfflineScreenState();
}

class _SessionOfflineScreenState extends ConsumerState<SessionOfflineScreen> {
  bool _retrying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = ref.watch(sessionControllerProvider);

    // Read defensively: the redirect chain only sends `SessionUnreachable`
    // here, but this screen is a route and a route can be reached in one more
    // frame than the chain expects.
    final unreachable = session is SessionUnreachable ? session : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: HhBrandLockup(axis: HhBrandLockupAxis.stacked),
              ),
              const SizedBox(height: HhSpace.sectionGap),

              HhErrorState(
                // "No connection" for a request that never left the device,
                // and something else for a server that answered badly — they
                // are different problems and lead to different expectations.
                title: unreachable?.offline ?? true
                    ? l10n.stateOfflineTitle
                    : l10n.sessionUnreachableTitle,
                // The server's own words where there are any, already
                // localized by `ApiException`.
                message: unreachable?.message ?? l10n.stateOfflineBody,
                retryLabel: l10n.commonRetry,
                onRetry: _retrying ? null : _retry,
              ),
              const SizedBox(height: HhSpace.lg),

              // The part the sign-in screen could never say, and the reason
              // this screen exists.
              Text(
                l10n.sessionUnreachableBody,
                style: HhTypography.body.copyWith(color: HhColors.inkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HhSpace.sectionGap),

              HhButton.text(
                label: l10n.sessionUnreachableSignOut,
                onPressed: _retrying ? null : _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      // On success the session state changes and the redirect chain leaves
      // this screen on its own — the rule the whole chain depends on. On
      // failure `restore` publishes `SessionUnreachable` again, with whatever
      // the second attempt said, and the screen updates in place.
      await ref.read(sessionControllerProvider.notifier).restore();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _retrying = true);
    try {
      await ref.read(sessionControllerProvider.notifier).signOut();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }
}
