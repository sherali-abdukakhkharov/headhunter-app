import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// Part of a selection row's label that opens something — the document a
/// consent names.
///
/// [text] must occur **verbatim** in the row's label, and that is how it is
/// placed: the label stays one translatable sentence, and each language
/// chooses which words are the link ("Maxfiylik siyosatini" in Uzbek,
/// "Политику конфиденциальности" in Russian). If it does not occur the label
/// is drawn plain and the link survives only as the screen-reader action —
/// a translation slip costs the underline, never the document.
class HhInlineLink {
  const HhInlineLink({
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  final String text;

  /// What a screen reader offers in its actions menu — a verb phrase such as
  /// "Open the Privacy Policy", since [text] is inflected to fit a sentence.
  final String actionLabel;
  final VoidCallback onTap;
}

/// A checkbox with its label, as one tappable row.
///
/// The whole row is the target, not just the 22px box — on a phone, hitting a
/// 22px square is a miss waiting to happen. A [link] inside the label is the
/// one exception: tapping those words opens it and leaves the box alone.
class HhCheckboxRow extends StatelessWidget {
  const HhCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.description,
    this.link,
  });

  final String label;

  /// Words in [label] that open something, drawn as a link. See
  /// [HhInlineLink].
  final HhInlineLink? link;

  /// Optional second line saying what the choice means, mirroring
  /// [HhSwitchRow.description].
  ///
  /// Worth filling in wherever the label is a noun the reader may not yet have
  /// a definition for — "Employer" is a word; what an employer can do in this
  /// app is the thing somebody choosing needs.
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => _SelectionRow(
    label: label,
    description: description,
    link: link,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    semantics: (checked: value, inMutuallyExclusiveGroup: false),
    control: AnimatedContainer(
      duration: HhDuration.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? HhColors.brand600 : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: value
            ? null
            : Border.all(color: HhColors.controlOutline, width: 1.8),
      ),
      child: value
          ? const Center(
              child: HhIcon(
                HhIconPath.check,
                size: 14,
                color: HhColors.white,
                strokeWidth: 3,
              ),
            )
          : null,
    ),
  );
}

/// A radio option with its label, as one tappable row.
///
/// The selected state is drawn as a thick ring rather than a dot-in-circle,
/// matching the design.
class HhRadioRow<T> extends StatelessWidget {
  const HhRadioRow({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.description,
  });

  final String label;

  /// Optional second line saying what this option means. See
  /// [HhCheckboxRow.description].
  final String? description;
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return _SelectionRow(
      label: label,
      description: description,
      onTap: onChanged == null ? null : () => onChanged!(value),
      semantics: (checked: selected, inMutuallyExclusiveGroup: true),
      control: AnimatedContainer(
        duration: HhDuration.fast,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? HhColors.brand600 : HhColors.controlOutline,
            width: selected ? 6.5 : 1.8,
          ),
        ),
      ),
    );
  }
}

/// A labelled switch row — label left, switch right.
///
/// Used for candidate search visibility, notification categories, and any other
/// on/off preference.
class HhSwitchRow extends StatelessWidget {
  const HhSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.description,
  });

  final String label;

  /// Optional second line explaining the consequence of the switch. Worth
  /// filling in for anything privacy-related.
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    label: label,
    // Same three as the checkbox and radio rows above, for the same reason:
    // the label is also drawn as a `Text`, so without `excludeSemantics` a
    // screen reader says it twice (MT-015) — and excluding the subtree drops
    // the InkWell's action with it.
    hint: description,
    enabled: onChanged != null,
    excludeSemantics: true,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    child: InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Container(
        constraints: const BoxConstraints(minHeight: HhSize.minTarget),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: HhTypography.body.copyWith(
                      fontSize: 14.5,
                      color: HhColors.brand900,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(description!, style: HhTypography.caption),
                  ],
                ],
              ),
            ),
            const SizedBox(width: HhSpace.md),
            ExcludeSemantics(
              child: AnimatedContainer(
                duration: HhDuration.fast,
                width: 46,
                height: 27,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: value ? HhColors.brand600 : HhColors.controlOutline,
                  borderRadius: HhRadius.pillAll,
                ),
                child: Align(
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 21,
                    height: 21,
                    decoration: const BoxDecoration(
                      color: HhColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shared layout for checkbox and radio rows.
class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.control,
    required this.onTap,
    required this.semantics,
    this.description,
    this.link,
  });

  final String label;
  final String? description;
  final HhInlineLink? link;
  final Widget control;
  final VoidCallback? onTap;
  final ({bool checked, bool inMutuallyExclusiveGroup}) semantics;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: semantics.checked,
    inMutuallyExclusiveGroup: semantics.inMutuallyExclusiveGroup,
    label: label,
    // The description is announced **after** the name and state rather than as
    // a second focus stop, which is what a hint is for: "Candidate, checkbox,
    // not checked" then what a candidate can do here.
    hint: description,
    enabled: onTap != null,
    // Without this the node's label and the child `Text`'s merge, and a screen
    // reader announces "Candidate, Candidate" (MT-015). The action has to be
    // restated because excluding the subtree also drops the InkWell's.
    excludeSemantics: true,
    onTap: onTap,
    // The inline link is inside the excluded subtree, so it is restated too —
    // as a custom action, the way TalkBack offers a second thing a control can
    // do. Double-tap still checks the box; the policy is in the actions menu.
    customSemanticsActions: switch (link) {
      final link? => {
        CustomSemanticsAction(label: link.actionLabel): link.onTap,
      },
      null => null,
    },
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: HhSize.minTarget),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          // Centred against a single line; against a label *and* a description
          // the control belongs beside the label, not halfway down the block.
          crossAxisAlignment: description == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Padding(
              // Optical centring on the first line: the box is 22px and the
              // label's line box is taller, so it sits two points low.
              padding: EdgeInsets.only(top: description == null ? 0 : 2),
              child: ExcludeSemantics(child: control),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  switch (link) {
                    final link? => _LinkedLabel(label: label, link: link),
                    null => Text(label, style: _labelStyle),
                  },
                  if (description case final text?) ...[
                    const SizedBox(height: 2),
                    Text(text, style: HhTypography.caption),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final TextStyle _labelStyle = HhTypography.body.copyWith(
  fontSize: 14.5,
  color: HhColors.brand900,
);

/// A selection label with one span that opens something.
///
/// Stateful only to own the recognizer, which has to be disposed. A span's
/// recognizer wins the tap over the row's `InkWell` — it joins the gesture
/// arena first, being deeper — so the link opens without toggling the box.
class _LinkedLabel extends StatefulWidget {
  const _LinkedLabel({required this.label, required this.link});

  final String label;
  final HhInlineLink link;

  @override
  State<_LinkedLabel> createState() => _LinkedLabelState();
}

class _LinkedLabelState extends State<_LinkedLabel> {
  // Reads `widget` at tap time, so a rebuilt row with a new callback is the
  // one that runs.
  late final _recognizer = TapGestureRecognizer()
    ..onTap = () => widget.link.onTap();

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final text = widget.link.text;
    final start = label.indexOf(text);

    if (text.isEmpty || start < 0) return Text(label, style: _labelStyle);

    return Text.rich(
      TextSpan(
        style: _labelStyle,
        children: [
          TextSpan(text: label.substring(0, start)),
          TextSpan(
            text: text,
            // Colour **and** an underline: a link that is only a different
            // blue is colour alone, which this design system does not do.
            style: const TextStyle(
              color: HhColors.brand600,
              decoration: TextDecoration.underline,
              decorationColor: HhColors.brand600,
            ),
            recognizer: _recognizer,
          ),
          TextSpan(text: label.substring(start + text.length)),
        ],
      ),
    );
  }
}
