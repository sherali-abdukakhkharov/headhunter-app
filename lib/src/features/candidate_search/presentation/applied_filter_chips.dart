import 'package:flutter/material.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/candidate_search/domain/search_filters.dart';

/// The filters currently narrowing the search, each removable (§7.1).
///
/// ## Why a chip names its group and not its value
///
/// Almost every filter here is one or more dictionary ids, and an id is not
/// readable — turning eight of them into words is eight asynchronous
/// resolutions in a row that wraps. A row of chips that fills in one word at a
/// time as the network answers is worse than one that is correct immediately,
/// so a chip says *what is constrained* and how many ways, and the builder says
/// what to.
///
/// The exceptions are the filters whose value needs no dictionary at all —
/// numbers, dates and the yes/no toggles. Those carry their value, because for
/// them "Salary" alone would be hiding something the user can already read.
class AppliedFilterChips extends StatelessWidget {
  const AppliedFilterChips({
    required this.filters,
    required this.onChanged,
    super.key,
  });

  final CandidateSearchFilters filters;

  /// Called with the filter set minus the removed group. Removing a group may
  /// drop others that cannot stand without it — see
  /// [CandidateSearchFilters.removing].
  final ValueChanged<CandidateSearchFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final keys = filters.activeKeys;

    if (keys.isEmpty) {
      return Text(
        l10n.filtersNone,
        style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
      );
    }

    return Wrap(
      spacing: HhSpace.sm,
      runSpacing: HhSpace.sm,
      children: [
        for (final key in keys)
          HhRemovableChip(
            label: _label(l10n, key),
            onRemove: () => onChanged(filters.removing(key)),
          ),
        HhButton.text(
          label: l10n.filtersClearAll,
          onPressed: () => onChanged(const CandidateSearchFilters()),
        ),
      ],
    );
  }

  String _label(AppL10n l10n, String key) => switch (key) {
    FilterKey.occupationIds => _count(
      l10n,
      l10n.filterOccupations,
      filters.occupationIds.length,
    ),
    FilterKey.primaryOnly => l10n.filterPrimaryOnly,
    FilterKey.category => l10n.filtersOccupation,
    FilterKey.occupationLevelIds => _count(
      l10n,
      l10n.filterOccupationLevels,
      filters.occupationLevelIds.length,
    ),
    FilterKey.skillIds => _count(
      l10n,
      l10n.filterSkills,
      filters.skillIds.length,
    ),
    FilterKey.skillMinLevelRank => l10n.filterMinLevel,
    // Shortened deliberately: a chip is a reminder of what is constrained, and
    // "Total years, minimum: 5" is a form label wearing a chip. The builder is
    // where the exact wording belongs.
    FilterKey.experienceYearsMin => l10n.filterChipValue(
      l10n.filtersExperience,
      '${filters.experienceYearsMin}',
    ),
    FilterKey.occupationExperienceYearsMin => l10n.filterChipValue(
      l10n.filterOccupationExperience,
      '${filters.occupationExperienceYearsMin}',
    ),
    FilterKey.currentOccupationIds => _count(
      l10n,
      l10n.filterCurrentOccupations,
      filters.currentOccupationIds.length,
    ),
    FilterKey.languages => _count(
      l10n,
      l10n.filterLanguages,
      filters.languages.length,
    ),
    FilterKey.educationLevelIds => _count(
      l10n,
      l10n.filterEducationLevels,
      filters.educationLevelIds.length,
    ),
    FilterKey.specializationIds => _count(
      l10n,
      l10n.filterSpecializations,
      filters.specializationIds.length,
    ),
    FilterKey.regionId => l10n.filterRegion,
    FilterKey.districtIds => _count(
      l10n,
      l10n.filterDistricts,
      filters.districtIds.length,
    ),
    FilterKey.willingToRelocate => l10n.filterWillingToRelocate,
    FilterKey.willingToTravel => l10n.filterWillingToTravel,
    FilterKey.proximityDistrictId => l10n.filterProximityDistrict,
    FilterKey.employmentTypeIds => _count(
      l10n,
      l10n.filterEmploymentTypes,
      filters.employmentTypeIds.length,
    ),
    FilterKey.workFormatIds => _count(
      l10n,
      l10n.filterWorkFormats,
      filters.workFormatIds.length,
    ),
    FilterKey.shiftIds => _count(
      l10n,
      l10n.filterShifts,
      filters.shiftIds.length,
    ),
    FilterKey.salaryMin => l10n.filterChipValue(
      l10n.filterSalaryMin,
      '${filters.salaryMin}',
    ),
    FilterKey.salaryMax => l10n.filterChipValue(
      l10n.filterSalaryMax,
      '${filters.salaryMax}',
    ),
    FilterKey.availableBy => l10n.filterChipValue(
      l10n.filterAvailableBy,
      filters.availableBy ?? '',
    ),
    FilterKey.availableImmediately => l10n.filterAvailableImmediately,
    FilterKey.attributeIds => _count(
      l10n,
      l10n.filterAttributes,
      filters.attributeIds.length,
    ),
    FilterKey.crewSizeMin => l10n.filterChipValue(
      l10n.filterCrewSizeMin,
      '${filters.crewSizeMin}',
    ),
    FilterKey.minCompleteness => l10n.filterChipValue(
      l10n.filtersProfile,
      '${filters.minCompleteness}%',
    ),
    FilterKey.updatedSince => l10n.filterChipValue(
      l10n.filterUpdatedSince,
      filters.updatedSince ?? '',
    ),
    FilterKey.ageMin => l10n.filterChipValue(
      l10n.filterAgeMin,
      '${filters.ageMin}',
    ),
    FilterKey.ageMax => l10n.filterChipValue(
      l10n.filterAgeMax,
      '${filters.ageMax}',
    ),
    FilterKey.genderId => l10n.filterGender,
    // BR-12: the justification earns a chip of its own even though it narrows
    // nothing, because removing it is how an employer drops the whole
    // restriction — and because a restricted search must never be running
    // without something on screen saying so.
    FilterKey.restrictionJustificationId => l10n.filtersRestrictions,
    // Not reachable through `activeKeys`, which only ever yields the keys
    // above. A chip for a key this build does not know is still better than a
    // crash, and better than a chip whose label is a wire name.
    _ => l10n.filtersTitle,
  };

  /// A group with more than one value says how many; with exactly one it does
  /// not, because "Skills (1)" is a count nobody needed.
  String _count(AppL10n l10n, String label, int count) =>
      count > 1 ? l10n.filterChipCount(label, count) : label;
}
