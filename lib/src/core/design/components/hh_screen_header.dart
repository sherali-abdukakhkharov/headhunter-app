import 'package:flutter/widgets.dart';

import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// A screen's own title, with an optional action on the right.
///
/// ## Why the shells need one at all
///
/// The role shells provide no chrome — each tab builds its own page — which is
/// deliberate: several of them open with the design's inverted navy header and
/// an `AppBar` above that would be two headers. What it left, though, is that a
/// screen with no header of its own has **no name and no top inset**, and the
/// 1.29.0 audit found both: the Messages list started at `y = 0` under the
/// status bar, and neither profile screen said what it was or offered a way to
/// the account settings without scrolling past the whole form.
///
/// So this is the small version: the title, an optional trailing action, and
/// the gutter above it that keeps content clear of the system bar when the
/// screen wraps its body in a `SafeArea`.
///
/// ## It is not an `AppBar`
///
/// An `AppBar` brings a back button, a 56pt minimum, its own colour and its own
/// text style. A tab is not pushed and has nothing to go back to, and the
/// design gives titles [HhTypography.title] rather than Material's. Borrowing
/// the widget would mean overriding most of it.
class HhScreenHeader extends StatelessWidget {
  const HhScreenHeader({required this.title, super.key, this.action});

  final String title;

  /// Sits at the end of the row. Keep it short — at 200% text this row is the
  /// title's, and an action that wraps competes with the thing it labels.
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      HhSpace.gutter,
      HhSpace.gutter,
      HhSpace.gutter,
      HhSpace.md,
    ),
    child: Row(
      // The action stays level with the *first* line of a title that wraps,
      // which is where a reader's eye is.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: HhTypography.title,
            // Two lines rather than one: at 200% a title of two words needs
            // them, and truncating the name of the screen is worse than a
            // taller header.
            maxLines: 2,
          ),
        ),
        if (action case final action?) ...[
          const SizedBox(width: HhSpace.sm),
          // `Flexible`, not a bare child: a Row lays its inflexible children
          // out at their full intrinsic width *first*, so a long action pushes
          // the title's `Expanded` to zero and then overflows anyway. Keep the
          // action short — this is the backstop, not the plan.
          Flexible(child: action),
        ],
      ],
    ),
  );
}
