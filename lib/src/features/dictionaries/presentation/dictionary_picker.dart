import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';

/// A dictionary-backed picker (§3.3, BR-13).
///
/// ## The contract, which is the whole reason this widget exists
///
/// **It displays [DictionaryItem.label] and calls back with
/// [DictionaryItem.id].** Nothing above it ever sees a label, and nothing below
/// it ever stores one. Binding a label is the failure BR-13 is written against:
/// it works perfectly in the language it was built in, and returns nothing in
/// the other three, silently.
///
/// So the value type here is `String?` — an id — and the widget resolves it to
/// text itself. A caller cannot hold the wrong thing, because the wrong thing
/// is never handed to it.
///
/// ## Resolving the current value
///
/// The selected id may name an item no longer in the picker's list: an
/// administrator can retire an occupation (§10.3) while a profile still
/// references it. [resolvedLabelsProvider] falls back to
/// `GET /dictionaries/items`, which resolves retired and merged ids forever, so
/// an old record reads as words rather than a UUID. The item stays unselectable
/// — visible, but not offered to anyone choosing afresh.
class HhDictionaryPicker extends ConsumerWidget {
  const HhDictionaryPicker({
    required this.label,
    required this.type,
    required this.value,
    required this.onChanged,
    super.key,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.parentId,
    this.requiresParentLabel,
    this.parentScoped = false,
  });

  final String label;

  /// A `DictionaryType` constant.
  final String type;

  /// The selected **id**, never a label.
  final String? value;

  final ValueChanged<String?> onChanged;

  final String? hintText;
  final String? errorText;
  final bool enabled;

  /// Restricts the options to children of this id — a district picker under a
  /// chosen region. Null means the top level (items with no parent).
  ///
  /// **The distinction between "no parent filter" and "parent not chosen yet"
  /// cannot be expressed by this field alone**, which is why
  /// [requiresParentLabel] exists.
  final String? parentId;

  /// Set on a cascading picker to mean "this list is empty until a parent is
  /// chosen, and here is what to say meanwhile" — e.g. "Choose a region first".
  ///
  /// Without it a district picker with no region selected would show every
  /// district in the country, which is both wrong and unusable.
  final String? requiresParentLabel;

  /// Set on **both halves of a hierarchy**, including the top one.
  ///
  /// A single type holds every level — `region` contains regions *and* their
  /// districts, told apart only by `parentId` (§5.1). So a region picker is not
  /// "the whole type", it is "the items with no parent", and the difference is
  /// invisible until you look: without this the region list quietly includes
  /// all twelve Tashkent districts, each of which is a valid-looking option
  /// that binds a real id.
  ///
  /// [parentId] alone cannot express it, because null there already means "no
  /// parent chosen yet".
  final bool parentScoped;

  bool get _blockedOnParent => requiresParentLabel != null && parentId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    if (_blockedOnParent) {
      return HhTextField(
        label: label,
        enabled: false,
        disabledHint: requiresParentLabel,
        errorText: errorText,
      );
    }

    final selected = value;
    final resolved = selected == null
        ? null
        : ref.watch(resolvedLabelsProvider(type, labelKey([selected])));

    return HhTextField(
      label: label,
      readOnly: true,
      enabled: enabled,
      errorText: errorText,
      hintText: hintText ?? l10n.pickerChoose,
      trailingIconPath: HhIconPath.chevronDown,
      // A read-only field still shows a caret and an empty box, so the text is
      // supplied through the controller rather than by typing.
      controller: TextEditingController(
        text: switch (resolved) {
          null => '',
          AsyncData(:final value) =>
            value[selected]?.label ?? l10n.pickerUnknownValue,
          _ => '…',
        },
      ),
      onTap: enabled ? () => _open(context, ref) : null,
      onTrailingTap: enabled ? () => _open(context, ref) : null,
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final chosen = await showModalBottomSheet<_PickResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: label,
        type: type,
        parentId: parentId,
        // A chosen parent implies scoping even if the caller forgot to say so.
        parentScoped: parentScoped || parentId != null,
        selected: {?value},
        multiple: false,
      ),
    );

    if (chosen != null) onChanged(chosen.ids.firstOrNull);
  }
}

/// The multi-select form of [HhDictionaryPicker] — skills, languages,
/// employment types (§5.1).
///
/// Same contract: chips display labels, the callback carries ids.
class HhDictionaryMultiPicker extends ConsumerWidget {
  const HhDictionaryMultiPicker({
    required this.label,
    required this.type,
    required this.values,
    required this.onChanged,
    super.key,
    this.errorText,
    this.enabled = true,
    this.emptyLabel,
  });

  final String label;
  final String type;

  /// The selected **ids**, in the order the user chose them.
  final List<String> values;

  final ValueChanged<List<String>> onChanged;

  final String? errorText;
  final bool enabled;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final resolved = ref.watch(resolvedLabelsProvider(type, labelKey(values)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HhTypography.label.copyWith(
            color: errorText != null ? HhColors.error : HhColors.inkMuted,
          ),
        ),
        const SizedBox(height: 6),

        if (values.isEmpty)
          Text(
            emptyLabel ?? l10n.pickerNothingSelected,
            style: HhTypography.body.copyWith(color: HhColors.inkDisabled),
          )
        else
          Wrap(
            spacing: HhSpace.sm,
            runSpacing: HhSpace.sm,
            children: [
              for (final id in values)
                HhRemovableChip(
                  // Resolved through the same path as the single picker, so a
                  // retired skill on an old profile still reads as a word.
                  label: switch (resolved) {
                    AsyncData(:final value) =>
                      value[id]?.label ?? l10n.pickerUnknownValue,
                    _ => '…',
                  },
                  onRemove: enabled
                      ? () => onChanged([...values]..remove(id))
                      : null,
                ),
            ],
          ),

        const SizedBox(height: HhSpace.md),
        HhButton.secondary(
          label: l10n.pickerAdd,
          iconPath: HhIconPath.plus,
          compact: true,
          onPressed: enabled ? () => _open(context, ref) : null,
        ),

        if (errorText case final message?) ...[
          const SizedBox(height: 6),
          Text(
            message,
            style: HhTypography.caption.copyWith(color: HhColors.error),
          ),
        ],
      ],
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final chosen = await showModalBottomSheet<_PickResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: label,
        type: type,
        parentId: null,
        // Multi-select types (skills, languages) are flat, so the whole set is
        // the right list.
        parentScoped: false,
        selected: values.toSet(),
        multiple: true,
      ),
    );

    if (chosen != null) onChanged(chosen.ids);
  }
}

class _PickResult {
  const _PickResult(this.ids);
  final List<String> ids;
}

/// Opens the searchable list on its own and returns the chosen **id**, or null
/// if the user backed out.
///
/// For callers that are not a field — the leveled editor asks for an item and
/// then a level from the same sheet, and a row without both is never created.
/// Exposed rather than duplicated so search, empty state and the retired-item
/// rules stay in one place.
Future<String?> pickDictionaryItem(
  BuildContext context, {
  required String title,
  required String type,
  String? parentId,
  bool parentScoped = false,
}) async {
  final chosen = await showModalBottomSheet<_PickResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PickerSheet(
      title: title,
      type: type,
      parentId: parentId,
      parentScoped: parentScoped || parentId != null,
      selected: const {},
      multiple: false,
    ),
  );

  return chosen?.ids.firstOrNull;
}

/// The searchable list both pickers open.
///
/// Search filters on the **label**, which is the one place matching text
/// against a label is correct: the user is reading labels, so that is what they
/// are searching. The result of the search is still an id.
class _PickerSheet extends ConsumerStatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.type,
    required this.parentId,
    required this.parentScoped,
    required this.selected,
    required this.multiple,
  });

  final String title;
  final String type;
  final String? parentId;

  /// True for either half of a hierarchy. With a null [parentId] that means
  /// "top-level items only", **not** "everything".
  final bool parentScoped;
  final Set<String> selected;
  final bool multiple;

  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  late final Set<String> _selected = {...widget.selected};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = widget.parentScoped
        ? ref.watch(dictionaryChildrenProvider(widget.type, widget.parentId))
        : ref.watch(selectableDictionaryProvider(widget.type));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => DecoratedBox(
        decoration: const BoxDecoration(
          color: HhColors.white,
          borderRadius: HhRadius.sheetTop,
        ),
        child: Padding(
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
              Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: Column(
                  children: [
                    Text(widget.title, style: HhTypography.subtitle),
                    const SizedBox(height: HhSpace.md),
                    HhTextField(
                      label: l10n.commonSearch,
                      hintText: l10n.pickerSearchHint,
                      onChanged: (q) => setState(() => _query = q),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: switch (items) {
                  // hasError first, deliberately: Riverpod's retry leaves a
                  // provider in AsyncLoading that merely *carries* an error, so
                  // matching loading first shows a spinner over a failure.
                  AsyncValue(hasError: true, :final error?) => HhErrorState(
                    title: l10n.stateErrorTitle,
                    message: error is Exception
                        ? l10n.stateErrorBody
                        : l10n.stateErrorBody,
                    retryLabel: l10n.commonRetry,
                    onRetry: () => ref.invalidate(
                      dictionaryProvider(widget.type),
                    ),
                  ),
                  AsyncData(:final value) => _list(
                    context,
                    scrollController,
                    _filter(value),
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),

              if (widget.multiple)
                Padding(
                  padding: const EdgeInsets.all(HhSpace.gutter),
                  child: HhButton(
                    label: l10n.commonSave,
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_PickResult(_selected.toList())),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<DictionaryItem> _filter(List<DictionaryItem> items) {
    if (_query.trim().isEmpty) return items;
    final q = _query.trim().toLowerCase();
    return items.where((i) => i.label.toLowerCase().contains(q)).toList();
  }

  Widget _list(
    BuildContext context,
    ScrollController controller,
    List<DictionaryItem> items,
  ) {
    final l10n = AppL10n.of(context);

    if (items.isEmpty) {
      return HhEmptyState(
        title: l10n.stateEmptyTitle,
        message: l10n.pickerNoMatches,
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: HhSpace.gutter),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selected.contains(item.id);

        return widget.multiple
            ? HhCheckboxRow(
                label: item.label,
                value: isSelected,
                onChanged: (checked) => setState(() {
                  if (checked) {
                    _selected.add(item.id);
                  } else {
                    _selected.remove(item.id);
                  }
                }),
              )
            : HhRadioRow<String>(
                label: item.label,
                value: item.id,
                groupValue: _selected.firstOrNull,
                onChanged: (_) => Navigator.of(
                  context,
                ).pop(_PickResult([item.id])),
              );
      },
    );
  }
}
