import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

/// A floor on an ordered dictionary scale — "B2 or better" (§7.1, §7.4).
///
/// ## It binds a rank, and that is not a BR-13 violation
///
/// Every other control in this app displays a label and binds an id. This one
/// displays a label and binds [DictionaryItem.rank], because the question is a
/// **comparison**: ids are opaque and unordered, so "or better" cannot be
/// expressed with one. `rank` is the field the ordered scales carry for exactly
/// this purpose, and it survives a level being inserted between two others —
/// which `sortOrder` does not.
///
/// The user's side of the interaction is unchanged: they read `B2` and choose
/// `B2`. Only what is stored differs, and it is stored for one filter rather
/// than on anybody's profile.
///
/// ## Chips rather than a sheet
///
/// The scales are four and seven items long. A modal to choose between four
/// visible options costs two taps to learn nothing, and the whole ladder being
/// on screen at once is what makes a *floor* legible — you can see what is
/// above the line you drew.
class LevelFloorField extends ConsumerWidget {
  const LevelFloorField({
    required this.label,
    required this.type,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;

  /// `skill_level` or `language_level` — a scale whose items carry `rank`.
  final String type;

  /// The selected **rank**, or null for "any level".
  final int? value;

  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final items = ref.watch(selectableDictionaryProvider(type));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HhTypography.label.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.sm),

        // hasError before loading: retry is disabled app-wide, so a failed
        // scale is terminal. Rendered as "any level only" rather than as an
        // error screen — a filter that cannot offer a floor still filters.
        switch (items) {
          AsyncValue(hasError: true, :final error?) => _unavailable(
            l10n,
            error,
          ),
          AsyncData(:final value) => _ladder(l10n, _ranked(value)),
          _ => Text(
            '…',
            style: HhTypography.body.copyWith(color: HhColors.inkDisabled),
          ),
        },
      ],
    );
  }

  Widget _ladder(AppL10n l10n, List<DictionaryItem> levels) {
    if (levels.isEmpty) return _unavailable(l10n, 'no ranked items');

    return Wrap(
      spacing: HhSpace.sm,
      runSpacing: HhSpace.sm,
      children: [
        HhFilterChip(
          label: l10n.filterLevelAny,
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        for (final level in levels)
          HhFilterChip(
            label: level.label,
            selected: value == level.rank,
            // Tapping the selected chip clears the floor. Without it the only
            // way back to "any" is a second control, and a filter you cannot
            // undo where you set it is the one people reset the whole form to
            // escape.
            onTap: () =>
                onChanged(value == level.rank ? null : level.rank),
          ),
      ],
    );
  }

  Widget _unavailable(AppL10n l10n, Object reason) {
    debugPrint('[dictionary] level floor: $type unavailable — $reason');
    return Text(
      l10n.filterLevelAny,
      style: HhTypography.body.copyWith(color: HhColors.inkDisabled),
    );
  }

  /// Only the items that actually carry a rank, weakest first.
  ///
  /// An unranked item on an ordered scale is a server-side mistake, and
  /// offering it would bind null as a floor — which reads as "any level" and
  /// silently drops the filter.
  static List<DictionaryItem> _ranked(List<DictionaryItem> items) =>
      [
        for (final item in items)
          if (item.rank != null) item,
      ]..sort((a, b) => a.rank!.compareTo(b.rank!));
}
