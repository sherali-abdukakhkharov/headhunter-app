import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

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
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });

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

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
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
        Text(
          widget.label,
          style: HhTypography.label.copyWith(
            color: _labelColour,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: HhDuration.fast,
          constraints: BoxConstraints(
            minHeight: multiline ? HhSize.control * 1.6 : HhSize.control,
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

  Widget _field() => TextField(
    controller: widget.controller,
    focusNode: _node,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    obscureText: widget.obscureText,
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
