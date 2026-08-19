import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';

/// A `dictionary_leveled` field (§4.4): rows of **item + proficiency**.
///
/// Skills at a level, languages at a CEFR grade. That pair is what §7.4's
/// "Russian at C1 or better" filters on, which is why the level is not
/// decoration — a row without one cannot answer the question the field exists
/// to answer.
///
/// ## Every row has a level, by construction
///
/// The server requires it and rejects a row without one. Rather than let an
/// incomplete row exist and be refused on save, **adding an item opens the
/// level picker immediately**, and backing out of it adds nothing. The
/// invariant then matches the server's exactly, and the "pick a level" 422
/// becomes unreachable rather than merely unlikely.
///
/// Value shape, in and out: `[{itemId, levelId}]` — symmetric with what the
/// profile returns, so nothing is translated in either direction. The server
/// also stores a `levelRank` denormalized from the level, but that is its
/// business and it does not come back.
class LeveledFieldEditor extends ConsumerWidget {
  const LeveledFieldEditor({
    required this.field,
    required this.rows,
    required this.onChanged,
    super.key,
    this.errorText,
    this.enabled = true,
  });

  final SchemaField field;

  /// Current rows, each `{itemId, levelId}`.
  final List<Map<String, dynamic>> rows;

  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  final String? errorText;
  final bool enabled;

  String get _itemType => field.dictionaryType ?? '';
  String get _levelType => field.levelDictionaryType ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    final itemIds = rows.map((r) => r['itemId'] as String).toList();
    final levelIds = rows.map((r) => r['levelId'] as String).toList();

    final items = ref.watch(
      resolvedLabelsProvider(_itemType, labelKey(itemIds)),
    );
    final levels = ref.watch(
      resolvedLabelsProvider(_levelType, labelKey(levelIds)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.required ? '${field.label} *' : field.label,
          style: HhTypography.label.copyWith(
            color: errorText != null ? HhColors.error : HhColors.inkMuted,
          ),
        ),
        const SizedBox(height: HhSpace.sm),

        if (rows.isEmpty)
          Text(
            l10n.pickerNothingSelected,
            style: HhTypography.body.copyWith(color: HhColors.inkDisabled),
          )
        else
          for (final (index, row) in rows.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: HhSpace.sm),
              child: HhCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _labelOf(items, row['itemId'] as String, l10n),
                            style: HhTypography.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _labelOf(levels, row['levelId'] as String, l10n),
                            style: HhTypography.caption.copyWith(
                              color: HhColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HhButton.text(
                      label: l10n.leveledChangeLevel,
                      onPressed: enabled
                          ? () => _changeLevel(context, index)
                          : null,
                    ),
                    IconButton(
                      onPressed: enabled ? () => _remove(index) : null,
                      constraints: const BoxConstraints(
                        minWidth: HhSize.minTarget,
                        minHeight: HhSize.minTarget,
                      ),
                      icon: const HhIcon(
                        HhIconPath.close,
                        size: 18,
                        color: HhColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

        const SizedBox(height: HhSpace.md),
        HhButton.secondary(
          label: l10n.pickerAdd,
          iconPath: HhIconPath.plus,
          compact: true,
          onPressed: enabled ? () => _add(context) : null,
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

  /// Resolves one id to a label, via the rule both pickers use.
  ///
  /// The error-before-loading ordering that [resolveLabel] encodes is the whole
  /// point here: a row that cannot name its skill is worse than one that names
  /// it as unavailable.
  String _labelOf(
    AsyncValue<Map<String, DictionaryItem>> resolved,
    String id,
    AppL10n l10n,
  ) => resolveLabel(resolved, id, l10n, where: field.code);

  Future<void> _add(BuildContext context) async {
    // Read before the first await: the two sheets open back to back and the
    // context cannot be touched across the gap.
    final levelTitle = AppL10n.of(context).leveledChangeLevel;

    final itemId = await pickDictionaryItem(
      context,
      title: field.label,
      type: _itemType,
    );
    if (itemId == null || !context.mounted) return;

    // The level sheet is titled for the level, not for the field. Both sheets
    // carrying `field.label` reads as the same question asked twice, and the
    // second one is the one nothing on screen explains.
    final levelId = await pickDictionaryItem(
      context,
      title: levelTitle,
      type: _levelType,
    );
    // Backing out of the level leaves nothing behind: a row without one would
    // be refused on save, so it is never created.
    if (levelId == null) return;

    // Re-adding an existing item is a corrected level, not a duplicate - which
    // is exactly how the server reads it too.
    final next = [
      for (final row in rows)
        if (row['itemId'] != itemId) row,
      {'itemId': itemId, 'levelId': levelId},
    ];

    onChanged(next);
  }

  Future<void> _changeLevel(BuildContext context, int index) async {
    final levelId = await pickDictionaryItem(
      context,
      title: AppL10n.of(context).leveledChangeLevel,
      type: _levelType,
    );
    if (levelId == null) return;

    onChanged([
      for (final (i, row) in rows.indexed)
        if (i == index) {...row, 'levelId': levelId} else row,
    ]);
  }

  void _remove(int index) => onChanged([
    for (final (i, row) in rows.indexed)
      if (i != index) row,
  ]);
}
