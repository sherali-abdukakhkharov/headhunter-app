import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_icons.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// A text field at the design's single control height, with a **persistent
/// label above the box**.
///
/// Two rules from the design that this widget enforces rather than merely
/// allows:
///
/// - **Never placeholder-only.** The label always exists and stays visible once
///   the field is filled, so a half-completed form is still readable. This is
///   why there is no `labelText`-style floating label here.
/// - **Units live in a chip beside the value, not in the placeholder.** Pass
///   [unit] (e.g. `so'm / oy`); it renders as a chip that cannot be mistaken for
///   the value or scroll out of view.
///
/// The label turns brand-blue when focused and red when [errorText] is set, so
/// the field's state is legible from the label alone.
class HhTextField extends StatefulWidget {
  const HhTextField({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.disabledHint,
    this.prefix,
    this.unit,
    this.trailingIconPath,
    this.onTrailingTap,
    this.trailingSemanticLabel,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.autofillHints,
    this.minLines,
  }) : showLabel = true,
       assert(
         onTrailingTap == null || trailingSemanticLabel != null,
         'A tappable trailing icon needs a trailingSemanticLabel. An '
         'icon-only control with no name is one a screen-reader user cannot '
         'identify at all — MT-015 found every picker chevron in the app in '
         'exactly that state, and an assert is what stops the next one.',
       );

  /// A chat composer: **no visible label, and 52 tall until it needs more.**
  ///
  /// The design's "every control is 52px with a persistent label" is a rule
  /// about **forms** — a screen of stacked fields, filled once, where a label
  /// that disappears on focus is how somebody loses track of what they are
  /// answering. A composer is not one of those. It is a single input in an
  /// action bar, used over and over, and what it is for is said by the entire
  /// screen above it. The persistent label plus the taller multiline box put
  /// the ordinary version at about 103pt before the send button, and the
  /// 1.29.0 audit's designer note called it "a multi-field form" occupying too
  /// much of a conversation.
  ///
  /// So this variant exists, it is **named**, and it is the only exception —
  /// putting it in the design system rather than letting a screen hand-roll a
  /// `Container` is what stops it becoming the dense mode the design refuses.
  ///
  /// [label] is still required and still carried: it becomes the field's
  /// accessible name instead of a `Text` above it, so nothing is lost to a
  /// screen reader.
  const HhTextField.composer({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.maxLines = 4,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType = TextInputType.multiline,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.autofillHints,
  }) : minLines = 1,
       showLabel = false,
       errorText = null,
       disabledHint = null,
       prefix = null,
       unit = null,
       trailingIconPath = null,
       onTrailingTap = null,
       trailingSemanticLabel = null,
       obscureText = false,
       readOnly = false,
       onTap = null;

  /// Persistent label shown above the box.
  final String label;

  final TextEditingController? controller;
  final String? hintText;

  /// When non-null the field renders its error state and shows this message
  /// with a warning glyph beneath the box.
  final String? errorText;

  final bool enabled;

  /// Explanation shown in place of the value when disabled — e.g.
  /// "Unlocked after verification". Far more useful than an empty grey box.
  final String? disabledHint;

  /// Static leading text such as a dial code. Separated from the value by a
  /// rule.
  final String? prefix;

  /// Unit chip on the right, e.g. `so'm / oy`.
  final String? unit;

  /// Trailing affordance, from [HhIconPath] — a calendar or picker glyph.
  final String? trailingIconPath;
  final VoidCallback? onTrailingTap;

  /// What a screen reader calls the trailing button.
  ///
  /// **Required whenever [onTrailingTap] is supplied**, and asserted below: an
  /// icon-only control with no name is one a screen-reader user cannot
  /// identify at all, and every picker in the app shipped that way (MT-015).
  ///
  /// Name the *action and its subject* — "Choose industry", not "Open" and not
  /// the glyph. The field's own label is already announced separately, so a
  /// bare "Choose" on a form with four pickers names four identical controls.
  final String? trailingSemanticLabel;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Input restrictions, e.g. `FilteringTextInputFormatter.digitsOnly` for a
  /// phone or a one-time code.
  ///
  /// [keyboardType] is a *hint* — it chooses which keyboard appears, and every
  /// platform still lets a user paste. A phone field with `maxLength: 9` and no
  /// formatter silently truncates a pasted `+998 90 123 45 67` to nine
  /// characters of punctuation.
  final List<TextInputFormatter>? inputFormatters;

  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  /// Read-only fields are still focusable and still look enabled — use this for
  /// values chosen through a picker rather than typed.
  final bool readOnly;
  final VoidCallback? onTap;

  /// Takes focus on first build, which also opens the keyboard [keyboardType]
  /// asks for.
  ///
  /// For a screen whose *only* job is one field — the OTP code — this is the
  /// difference between arriving ready to type and arriving needing a tap.
  /// Never set it on a screen with several fields: the one that grabs focus
  /// decides where the user starts, and the answer is rarely the first field.
  final bool autofocus;

  /// Platform autofill categories, e.g. `[AutofillHints.oneTimeCode]`.
  ///
  /// On Android this is what puts the code from an SMS above the keyboard.
  /// A field that declares a hint should sit inside an `AutofillGroup`.
  final List<String>? autofillHints;

  /// Lines the box is drawn at before it has content to fill them.
  ///
  /// **A `TextField` with `maxLines: 4` and no `minLines` is a fixed four-line
  /// box**, not one that grows into four — that is Flutter's rule, and it is
  /// why every multiline field here has always been drawn at its full height.
  /// For a form that is right: the box is the affordance that says how much
  /// there is room for. For the composer it is not, so it passes 1 and grows a
  /// line at a time.
  final int? minLines;

  /// Whether the persistent label is drawn above the box.
  ///
  /// True for every field but the composer — see [HhTextField.composer].
  final bool showLabel;

  @override
  State<HhTextField> createState() => _HhTextFieldState();
}

class _HhTextFieldState extends State<HhTextField> {
  FocusNode? _ownedNode;
  bool _focused = false;

  FocusNode get _node => widget.focusNode ?? (_ownedNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _ownedNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_node.hasFocus != _focused) {
      setState(() => _focused = _node.hasFocus);
    }
  }

  bool get _hasError => widget.errorText != null;

  Color get _labelColour {
    if (!widget.enabled) return HhColors.inkDisabled;
    if (_hasError) return HhColors.error;
    if (_focused) return HhColors.brand600;
    return HhColors.inkMuted;
  }

  BorderSide get _side {
    if (!widget.enabled) return HhBorders.controlDisabled;
    if (_hasError) return HhBorders.controlError;
    if (_focused) return HhBorders.controlFocused;
    return HhBorders.control;
  }

  Color get _fill {
    if (!widget.enabled) return const Color(0xFFF7F8FA);
    if (_hasError) return HhColors.errorSurface;
    return HhColors.white;
  }

  @override
  Widget build(BuildContext context) {
    final multiline = widget.maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: HhTypography.label.copyWith(
              color: _labelColour,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: HhDuration.fast,
          constraints: BoxConstraints(
            // The taller multiline box is a *form* affordance: it says "there
            // is room to write here" on a screen you are filling in. A composer
            // says that by being a composer, so it starts at the standard 52
            // and grows a line at a time up to `maxLines`.
            minHeight: multiline && widget.showLabel
                ? HhSize.control * 1.6
                : HhSize.control,
          ),
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: HhRadius.buttonAll,
            border: Border.fromBorderSide(_side),
            // The focus glow is additive to the 2px border, matching the
            // design's focused-field treatment.
            boxShadow: _focused && !_hasError ? HhBorders.focusGlow : null,
          ),
          padding: EdgeInsets.only(
            left: 14,
            right: widget.unit != null || widget.trailingIconPath != null
                ? 8
                : 14,
            top: multiline ? 12 : 0,
            bottom: multiline ? 12 : 0,
          ),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: HhTypography.body.copyWith(
                    color: HhColors.inkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  width: 1,
                  height: 22,
                  color: HhColors.borderSubtle,
                ),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: widget.enabled
                    ? _field()
                    : Text(
                        widget.disabledHint ?? '',
                        style: HhTypography.body.copyWith(
                          color: HhColors.inkDisabled,
                        ),
                      ),
              ),
              if (widget.unit != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: HhColors.fill,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(
                    widget.unit!,
                    style: HhTypography.caption.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ),
              ],
              if (widget.trailingIconPath != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: widget.enabled ? widget.onTrailingTap : null,
                  // Long-press affordance for a sighted user. **Not** the
                  // accessible name: `Tooltip` sets the semantics *tooltip*
                  // property rather than the label, so a button with only a
                  // tooltip still announces nothing. Verified — the name has
                  // to come from the icon below, which `IconButton` merges
                  // into its own node.
                  tooltip: widget.trailingSemanticLabel,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: HhSize.minTarget,
                    minHeight: HhSize.minTarget,
                  ),
                  icon: HhIcon(
                    widget.trailingIconPath!,
                    size: 20,
                    color: _hasError ? HhColors.error : HhColors.inkMuted,
                    strokeWidth: 1.8,
                    // What makes the control announceable at all. Without it
                    // Android's hierarchy dump marks the chevron `NAF=true`,
                    // which is how the audit found every picker in the app
                    // (MT-015).
                    semanticLabel: widget.trailingSemanticLabel,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: HhIcon(
                  HhIconPath.alertTriangle,
                  size: 15,
                  color: HhColors.error,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: HhTypography.caption.copyWith(
                    color: HhColors.error,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _field() {
    final field = _bareField();

    // With no `Text` above it the box would announce as its hint, or as
    // nothing. The label did not stop existing — it stopped being drawn.
    return widget.showLabel
        ? field
        : Semantics(label: widget.label, child: field);
  }

  Widget _bareField() => TextField(
    controller: widget.controller,
    focusNode: _node,
    autofocus: widget.autofocus,
    autofillHints: widget.autofillHints,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    inputFormatters: widget.inputFormatters,
    obscureText: widget.obscureText,
    minLines: widget.minLines,
    maxLines: widget.maxLines,
    maxLength: widget.maxLength,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    readOnly: widget.readOnly,
    onTap: widget.onTap,
    cursorColor: HhColors.brand600,
    cursorWidth: 1.5,
    style: HhTypography.body.copyWith(
      color: HhColors.brand900,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      isDense: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      // The box already reserves height; a counter would break the 52px rule.
      counterText: '',
      hintText: widget.hintText,
      hintStyle: HhTypography.body.copyWith(color: HhColors.inkDisabled),
    ),
  );
}
