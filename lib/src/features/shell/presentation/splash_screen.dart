import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// Held on screen while the session is being restored — the visible form of
/// `SessionUnknown`.
///
/// It exists to *prevent* a flash, not to brand the launch: without a state
/// meaning "we do not know yet", a cold start renders onboarding for a frame or
/// two before the stored session resolves, reading as a crash and a recovery.
///
/// ## The design's launch screen, and why it inverts the icon
///
/// Navy ground, a **turquoise plate** at 44% of the screen width, and the mark
/// **navy inside it** — the reverse of the launcher icon, which is a turquoise
/// arch on navy. The design gives the reason: inverted, this screen can never
/// be mistaken for the home-screen icon frozen mid-load. Somebody staring at a
/// stalled launch can tell which thing has stalled.
///
/// ## No spinner, and no visible loading string
///
/// Both are the design's instruction, and this screen used to carry a spinner.
/// The `Semantics` live region stays, because it is not visible: a sighted user
/// sees a brand screen for a few hundred milliseconds and needs no explanation,
/// while a screen-reader user gets no visual cue at all that the app is working
/// and would otherwise hear silence.
///
/// ## "Optically centred" is what centring the group already does
///
/// The design asks for the plate to be optically centred, and the specimen
/// centres the *group* — plate, gap, word — geometrically. Those agree: with a
/// caption hanging below it, a geometrically centred group puts the plate above
/// the geometric centre, which is what optical centring means here. So there is
/// no magic offset, and adding one would double the correction.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plate = HhBrandLaunchPlate(
      screenSize: MediaQuery.sizeOf(context),
    );

    return Scaffold(
      backgroundColor: HhColors.brand900,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            plate,

            // The specimen's gap, as a fraction of the plate rather than of the
            // screen: 13 of a 46pt plate.
            SizedBox(height: plate.plateWidth * 0.283),

            // White, per the lockup rule for a navy ground. The specimen draws
            // this word letterspaced, uppercase and in `accentOnDark`, which
            // contradicts two stated rules — see docs/design-feedback.md. Where
            // a rule and a 12pt thumbnail disagree, the rule is implemented.
            HhBrandWordmark(
              fontSize: plate.plateWidth * 0.26,
              color: HhColors.white,
            ),

            // Semantics only — the design's launch screen carries no visible
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
}
