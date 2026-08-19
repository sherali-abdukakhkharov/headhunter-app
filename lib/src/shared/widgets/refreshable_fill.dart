import 'package:flutter/widgets.dart';

/// Makes a non-scrolling child scrollable, so `RefreshIndicator` still fires.
///
/// `RefreshIndicator` only responds to a drag on a **scrollable** descendant,
/// and neither `HhEmptyState` nor `HhErrorState` is one. Without this wrapper
/// pull-to-refresh is dead on exactly the two screens where a user most wants
/// to retry — an empty list and a failed one — while working everywhere it is
/// least needed.
///
/// The `ConstrainedBox` is the load-bearing half: a `SingleChildScrollView`
/// around a short child scrolls nothing, because there is nothing to scroll.
/// Filling the viewport's height is what gives the gesture somewhere to start.
class RefreshableFill extends StatelessWidget {
  const RefreshableFill({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}
