import 'package:flutter/widgets.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// Wraps a block of fields that appeared **because of a choice**.
///
/// This is turquoise's load-bearing job in the product, and the *only* place a
/// turquoise rail may appear. The design gives the accent exactly three uses:
///
/// 1. the brand mark, on navy ground only;
/// 2. **this rail** — a block that exists because of an earlier answer;
/// 3. progress and value on dark surfaces only.
///
/// Never a button fill, never a selected state, never a status tone, never text
/// on white. Selection stays brand blue so that "selected" and "conditional"
/// can never read as the same signal.
///
/// The [trigger] caption is not decoration: §13 of the designer spec requires a
/// conditional field to appear immediately after the option that activates it,
/// and naming that option is what makes the block's sudden appearance
/// comprehensible rather than startling.
class HhConditionalField extends StatelessWidget {
  const HhConditionalField({
    required this.trigger,
    required this.child,
    super.key,
  });

  /// Localized name of the choice that revealed this block, e.g. the occupation
  /// category or the option that was ticked. Rendered uppercase.
  final String trigger;

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: HhColors.accentGround,
      border: Border(
        left: BorderSide(color: HhColors.accent500, width: 3),
      ),
      // Square on the rail side, rounded away from it.
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(HhRadius.card),
        bottomRight: Radius.circular(HhRadius.card),
      ),
    ),
    padding: const EdgeInsets.fromLTRB(13, 12, HhSpace.md, HhSpace.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trigger.toUpperCase(),
          style: HhTypography.overline.copyWith(color: HhColors.accent700),
        ),
        const SizedBox(height: HhSpace.sm),
        child,
      ],
    ),
  );
}
