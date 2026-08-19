import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// Held on screen while the session is being restored - the visible form of
/// `SessionUnknown`.
///
/// It exists to *prevent* a flash, not to brand the launch: without a state
/// that means "we do not know yet", a cold start renders onboarding for a frame
/// or two before the stored session resolves, reading as a crash and recovery.
///
/// Navy ground with the app name, matching the launch screen the design
/// specifies, so the handoff from the platform splash to the first Flutter
/// frame has no visible seam.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: HhColors.brand900,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppL10n.of(context).appTitle,
            style: HhTypography.title.copyWith(color: HhColors.white),
          ),
          const SizedBox(height: HhSpace.xl),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              // Turquoise on navy is one of the accent's three sanctioned jobs
              // (progress and value on a dark surface). It is never a fill or a
              // selected state.
              valueColor: AlwaysStoppedAnimation(HhColors.accentOnDark),
            ),
          ),
          // Semantics only - the design's launch screen carries no visible
          // loading string, but a screen reader needs to know why it waits.
          Semantics(
            liveRegion: true,
            label: AppL10n.of(context).stateLoading,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
}
