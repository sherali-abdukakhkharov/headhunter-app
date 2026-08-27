import 'package:flutter/material.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// Presents [builder] as a modal bottom sheet with the design's chrome.
///
/// Always `isScrollControlled` and always transparent behind the sheet: the
/// rounded top belongs to [HhSheet], and a Material background under it paints
/// square corners behind the curve. Every call site set both by hand, and one
/// forgetting either is a sheet that looks like a different product.
Future<T?> showHhSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: builder,
);

/// The chrome every bottom sheet in this product shares.
///
/// It was copy-pasted into twelve files before this existed, and the copies had
/// drifted in exactly the way copies do: **three had no drag handle** and **two
/// did not lift for the keyboard**, which nobody chose — those sheets simply
/// started from a different one. That is the argument for the component over
/// the convention.
///
/// ## What it owns
///
/// The white ground and [HhRadius.sheetTop]; the safe area; the gutter padding
/// *plus the keyboard inset*, so a sheet with a text field rises instead of
/// hiding under the keyboard; the 40 × 4 drag handle; and an optional title.
///
/// ## Scrolling is the caller's choice, and getting it wrong is silent
///
/// [scrollable] wraps the content, which is right for a column of fields that
/// may outgrow the screen. It is **wrong for a sheet whose child is itself a
/// list**: a `ListView` inside a `SingleChildScrollView` has unbounded height
/// and throws, or — worse, when it does not throw — builds every row at once
/// and loses the laziness the list was for. Those sheets pass `false` and lay
/// themselves out.
class HhSheet extends StatelessWidget {
  const HhSheet({
    required this.child,
    super.key,
    this.title,
    this.scrollable = true,
  });

  final Widget child;

  /// Shown under the handle. Null for a sheet whose content names itself.
  final String? title;

  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Not a control: it says "this drags" to a sighted user, and a screen
        // reader is told to skip it because the gesture is not one it offers.
        const ExcludeSemantics(child: Center(child: HhSheetHandle())),
        const SizedBox(height: HhSpace.md),
        if (title case final text?) ...[
          Text(text, style: HhTypography.subtitle),
          const SizedBox(height: HhSpace.md),
        ],
        if (scrollable)
          Flexible(child: SingleChildScrollView(child: child))
        else
          Flexible(child: child),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          // The keyboard inset is part of the chrome rather than each sheet's
          // problem: a sheet with a text field has to rise, and two of the
          // hand-rolled ones did not.
          padding: EdgeInsets.only(
            left: HhSpace.gutter,
            right: HhSpace.gutter,
            top: HhSpace.gutter,
            bottom: HhSpace.gutter + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// The 40 x 4 grip. Public only so a test can assert it is present: three of
/// the twelve hand-rolled sheets had no handle, which is the kind of omission
/// that needs an assertion rather than a reviewer noticing.
class HhSheetHandle extends StatelessWidget {
  const HhSheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: HhColors.borderSubtle,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
