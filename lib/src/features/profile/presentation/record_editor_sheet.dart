import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// Opens a bottom sheet holding one draft record, and returns it on save.
///
/// Returns null when the user backs out, so a caller can tell "nothing to do"
/// from "save this" without a sentinel — the same shape `pickDictionaryItem`
/// uses for the pickers.
///
/// The draft lives in this sheet's state and the caller receives it only once,
/// on save. That is deliberate: a half-typed record must not reach the server,
/// and a cancelled edit must leave the existing record exactly as it was.
///
/// [isComplete] gates the save button. It is the *client's* half of validation
/// and covers only what the server requires unconditionally — the server
/// re-validates regardless, so a rule missed here costs a round trip, not
/// correctness.
Future<T?> showRecordEditor<T>(
  BuildContext context, {
  required String title,
  required T initial,
  required bool Function(T draft) isComplete,
  required Widget Function(
    BuildContext context,
    T draft,
    ValueChanged<T> onChanged,
  )
  builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _RecordEditorSheet<T>(
    title: title,
    initial: initial,
    isComplete: isComplete,
    builder: builder,
  ),
);

class _RecordEditorSheet<T> extends StatefulWidget {
  const _RecordEditorSheet({
    required this.title,
    required this.initial,
    required this.isComplete,
    required this.builder,
  });

  final String title;
  final T initial;
  final bool Function(T draft) isComplete;
  final Widget Function(
    BuildContext context,
    T draft,
    ValueChanged<T> onChanged,
  )
  builder;

  @override
  State<_RecordEditorSheet<T>> createState() => _RecordEditorSheetState<T>();
}

class _RecordEditorSheetState<T> extends State<_RecordEditorSheet<T>> {
  late T _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => DecoratedBox(
        decoration: const BoxDecoration(
          color: HhColors.white,
          borderRadius: HhRadius.sheetTop,
        ),
        child: Padding(
          // Lifts the form clear of the keyboard, which otherwise covers the
          // save button on a phone.
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: HhSpace.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HhColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: HhSpace.md),
              Text(widget.title, style: HhTypography.subtitle),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(HhSpace.gutter),
                  child: widget.builder(
                    context,
                    _draft,
                    (next) => setState(() => _draft = next),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhButton(
                  label: l10n.commonSave,
                  // Disabled rather than hidden: the user can see there is a
                  // save and that something is still missing, which a vanished
                  // button does not say.
                  onPressed: widget.isComplete(_draft)
                      ? () => Navigator.of(context).pop(_draft)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A controller seeded with [text], caret parked at the end.
///
/// These forms rebuild on every keystroke because the draft lives one level up,
/// so a controller built fresh each frame would otherwise send the caret back
/// to the start after every character. Same reasoning as the field engine's.
TextEditingController seededController(String text) =>
    TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
