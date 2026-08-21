import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_detail.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';

/// A vacancy's structured requirements, grouped by schema field (§6.3).
///
/// **Mandatory and preferred are told apart by a badge, never by order alone.**
/// A preference that looked like a requirement would stop candidates applying,
/// which is the opposite of what a preference is for — and the design system's
/// rule is that status is never colour alone.
///
/// ## The group heading comes from the vacancy schema
///
/// A requirement arrives carrying `fieldCode` — `employment_type_ids` — and the
/// wording for it lives in the schema the vacancy form was built from, already
/// localized by the server. The first version of this rendered the code and it
/// read as a bug on a device. A code-to-string table in Dart would be worse:
/// administrators add fields at runtime (§10.3), so it would go stale silently
/// and in one language at a time.
///
/// The schema load is deliberately **not** allowed to hold up the requirements:
/// while it is in flight, or if it fails, the code is shown. A heading that
/// arrives a moment late is better than a screen that waits for one.
///
/// ## Shared by the candidate and the administrator
///
/// §5.6's detail screen and §10.2's moderation review read the same rows for
/// different reasons, and the two rules above are exactly the ones a second
/// copy would lose first — a moderator shown a preference as a requirement
/// would reject a vacancy for a condition it never imposed.
class VacancyRequirementGroups extends ConsumerWidget {
  const VacancyRequirementGroups({
    required this.requirements,
    required this.category,
    super.key,
  });

  final List<VacancyRequirement> requirements;

  /// The vacancy's §2.1 work category, which is what selects the schema. Null
  /// until an occupation is chosen, and then the codes stand in for labels.
  final String? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final groups = groupRequirementsByField(requirements);

    final schema = switch (category) {
      final category? => ref.watch(vacancyFieldSchemaProvider(category)),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.md),
            child: HhCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _heading(schema, entry.key),
                    style: HhTypography.label.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: HhSpace.sm),

                  for (final requirement in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _value(context, requirement, l10n)),
                          const SizedBox(width: HhSpace.sm),
                          HhBadge(
                            label: requirement.isMandatory
                                ? l10n.vacancyMandatory
                                : l10n.vacancyPreferred,
                            tone: requirement.isMandatory
                                ? HhTone.warning
                                : HhTone.neutral,
                            iconPath: requirement.isMandatory
                                ? HhIconPath.alertTriangle
                                : HhIconPath.checkCircle,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// The schema's label for a field code, or the code itself.
  ///
  /// Loading and failure both fall through to the code, and that is the point:
  /// the requirement below the heading is the information the reader came for,
  /// and it must never be withheld waiting on a word.
  static String _heading(AsyncValue<FieldSchema>? schema, String fieldCode) =>
      switch (schema) {
        AsyncData(:final value) =>
          value.fieldByCode(fieldCode)?.label ?? fieldCode,
        _ => fieldCode,
      };

  /// One requirement's value, from whichever slot is filled.
  ///
  /// The order is not arbitrary: a levelled row carries **both** an item and a
  /// level, so the item must be tested first and the level rendered beside it;
  /// text is last because it is the only slot that means nothing else.
  Widget _value(
    BuildContext context,
    VacancyRequirement requirement,
    AppL10n l10n,
  ) {
    if (requirement.itemId case final itemId?) {
      return Row(
        children: [
          Flexible(
            child: DictionaryLabel(
              type: _typeFor(requirement.fieldCode),
              id: itemId,
              style: HhTypography.body,
            ),
          ),
          if (requirement.levelId case final levelId?) ...[
            const SizedBox(width: 6),
            Text('·', style: HhTypography.caption),
            const SizedBox(width: 6),
            Flexible(
              child: DictionaryLabel(
                type: _levelTypeFor(requirement.fieldCode),
                id: levelId,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),
            ),
          ],
        ],
      );
    }

    if (requirement.valueInt case final number?) {
      return Text('$number', style: HhTypography.body);
    }

    if (requirement.valueBool case final flag?) {
      return Text(
        flag ? l10n.commonYes : l10n.commonNo,
        style: HhTypography.body,
      );
    }

    return Text(requirement.valueText ?? '—', style: HhTypography.body);
  }

  /// The dictionary a requirement's item belongs to, inferred from its field.
  ///
  /// An inference, and it is worth saying why it is acceptable: an unknown
  /// field resolves against `attribute`, and a miss there renders the picker's
  /// "unknown value" rather than a UUID or a crash. The alternative — reading
  /// `dictionaryType` per field off the vacancy schema — is a second request
  /// for wording this already shows honestly.
  static String _typeFor(String fieldCode) => switch (fieldCode) {
    'languages' => DictionaryType.language,
    'skills' => DictionaryType.skill,
    'occupation' || 'occupations' => DictionaryType.occupation,
    'education_level' || 'educationLevel' => DictionaryType.educationLevel,
    'employment_type' || 'employmentType' => DictionaryType.employmentType,
    'work_format' || 'workFormat' => DictionaryType.workFormat,
    'shift' || 'shifts' => DictionaryType.shift,
    _ => DictionaryType.attribute,
  };

  static String _levelTypeFor(String fieldCode) => switch (fieldCode) {
    'languages' => DictionaryType.languageLevel,
    _ => DictionaryType.skillLevel,
  };
}
