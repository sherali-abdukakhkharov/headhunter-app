import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/search_filters.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/level_floor_field.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/shared/widgets/iso_date_field.dart';

/// Opens §7.1's filter builder and returns the edited configuration, or null if
/// the employer backed out.
///
/// Pushed on the **root** navigator: a filter set is not a location. There is
/// no deep link that means "the builder, holding these thirty filters", so
/// giving it a route would add a path that only ever arrives empty, and it
/// would sit inside a shell branch whose nav bar has nothing to do with it.
Future<SearchConfig?> showFilterBuilder(
  BuildContext context, {
  required SearchConfig initial,
}) => Navigator.of(context, rootNavigator: true).push<SearchConfig>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => FilterBuilderScreen(initial: initial),
  ),
);

/// §7.1's eleven filter groups, plus §7.3's sort.
///
/// ## Editing is local until Apply
///
/// The screen owns a draft and the caller receives it once, on Apply. Backing
/// out leaves the applied search exactly as it was — which matters more here
/// than in most forms, because the alternative is an employer who opened the
/// builder to *look* at their filters and left having silently changed them.
///
/// ## Two rules are enforced here rather than by the server
///
/// Both are refusals the server already makes, and both are re-made here for
/// the same reason: the difference between being told *why* before searching
/// and getting a 403 after.
///
/// - **BR-12** — an age or gender filter needs a declared justification. The
///   Apply button is blocked and says so.
/// - **`search.occupation_required`** — "years in this occupation" needs an
///   occupation. The field is disabled until one is chosen, so the state never
///   arises.
class FilterBuilderScreen extends ConsumerStatefulWidget {
  const FilterBuilderScreen({required this.initial, super.key});

  final SearchConfig initial;

  @override
  ConsumerState<FilterBuilderScreen> createState() =>
      _FilterBuilderScreenState();
}

class _FilterBuilderScreenState extends ConsumerState<FilterBuilderScreen> {
  late CandidateSearchFilters _filters = widget.initial.filters;
  late CandidateSearchSort _sort = widget.initial.sort;

  /// Sets or clears one filter, named by its wire key.
  ///
  /// Null, an empty list and `false` all mean *clear*: the three ways this
  /// app's controls say "no constraint", collapsed into one so a caller never
  /// has to decide which of them the server understands. (It understands the
  /// key being absent, and nothing else — see [CandidateSearchFilters.toJson].)
  void _set(String key, Object? value) => setState(() {
    final next = {..._filters.toJson()};

    if (value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.isEmpty) ||
        value == false) {
      next.remove(key);
    } else {
      next[key] = value;
    }

    _filters = CandidateSearchFilters.fromJson(next);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final blocked = !_filters.restrictionIsJustified;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filtersTitle),
        actions: [
          if (!_filters.isEmpty)
            TextButton(
              onPressed: () =>
                  setState(() => _filters = const CandidateSearchFilters()),
              child: Text(l10n.filtersReset),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            _section(l10n.filtersOccupation),
            HhDictionaryMultiPicker(
              label: l10n.filterOccupations,
              type: DictionaryType.occupation,
              values: _filters.occupationIds,
              onChanged: (ids) => _set(FilterKey.occupationIds, ids),
            ),
            const SizedBox(height: HhSpace.md),
            HhSwitchRow(
              label: l10n.filterPrimaryOnly,
              description: l10n.filterPrimaryOnlyHint,
              value: _filters.primaryOnly,
              onChanged: (on) => _set(FilterKey.primaryOnly, on),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryMultiPicker(
              label: l10n.filterCurrentOccupations,
              type: DictionaryType.occupation,
              values: _filters.currentOccupationIds,
              onChanged: (ids) => _set(FilterKey.currentOccupationIds, ids),
            ),

            _section(l10n.filtersSkills),
            HhDictionaryMultiPicker(
              label: l10n.filterSkills,
              type: DictionaryType.skill,
              values: _filters.skillIds,
              onChanged: (ids) => _set(FilterKey.skillIds, ids),
            ),
            // Shown only once there are skills to combine. Before that the
            // control asks a question with no subject, and the value would be
            // dropped on the way out anyway (`toJson` omits a mode with no
            // group).
            if (_filters.skillIds.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              _matchMode(
                l10n,
                value: _filters.skillsMatchMode,
                onChanged: (mode) =>
                    _set(FilterKey.skillsMatchMode, mode.wire),
              ),
              const SizedBox(height: HhSpace.md),
              LevelFloorField(
                label: l10n.filterMinLevel,
                type: DictionaryType.skillLevel,
                value: _filters.skillMinLevelRank,
                onChanged: (rank) =>
                    _set(FilterKey.skillMinLevelRank, rank),
              ),
            ],

            _section(l10n.filtersExperience),
            _number(
              label: l10n.filterExperienceYearsMin,
              value: _filters.experienceYearsMin,
              onChanged: (n) => _set(FilterKey.experienceYearsMin, n),
            ),
            const SizedBox(height: HhSpace.md),
            _number(
              label: l10n.filterOccupationExperience,
              value: _filters.occupationExperienceYearsMin,
              onChanged: (n) =>
                  _set(FilterKey.occupationExperienceYearsMin, n),
              // `search.occupation_required`, made unreachable rather than
              // merely unlikely: years *in an occupation* has no meaning until
              // one is named.
              enabled: _filters.occupationIds.isNotEmpty,
              disabledHint: l10n.filterOccupationExperienceNeedsOccupation,
            ),

            _section(l10n.filtersLanguages),
            _LanguageRows(
              rows: _filters.languages,
              onChanged: (rows) => _set(FilterKey.languages, [
                for (final row in rows) row.toJson(),
              ]),
            ),

            _section(l10n.filtersEducation),
            HhDictionaryMultiPicker(
              label: l10n.filterEducationLevels,
              type: DictionaryType.educationLevel,
              values: _filters.educationLevelIds,
              onChanged: (ids) => _set(FilterKey.educationLevelIds, ids),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryMultiPicker(
              label: l10n.filterSpecializations,
              type: DictionaryType.specialization,
              values: _filters.specializationIds,
              onChanged: (ids) => _set(FilterKey.specializationIds, ids),
            ),

            _section(l10n.filtersLocation),
            HhDictionaryPicker(
              label: l10n.filterRegion,
              type: DictionaryType.region,
              // Top level only: one type holds regions *and* their districts,
              // told apart by parentId alone.
              parentScoped: true,
              value: _filters.regionId,
              onChanged: (id) => setState(() {
                // Districts belong to the region that was chosen. Keeping them
                // across a region change would filter on districts that are no
                // longer offered and cannot be seen.
                _filters = CandidateSearchFilters.fromJson({
                  ..._filters.removing(FilterKey.regionId).toJson(),
                  FilterKey.regionId: ?id,
                });
              }),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryMultiPicker(
              label: l10n.filterDistricts,
              type: DictionaryType.region,
              parentId: _filters.regionId,
              requiresParentLabel: l10n.filterDistrictsNeedRegion,
              values: _filters.districtIds,
              onChanged: (ids) => _set(FilterKey.districtIds, ids),
            ),
            const SizedBox(height: HhSpace.md),
            HhSwitchRow(
              label: l10n.filterWillingToRelocate,
              value: _filters.willingToRelocate,
              onChanged: (on) => _set(FilterKey.willingToRelocate, on),
            ),
            HhSwitchRow(
              label: l10n.filterWillingToTravel,
              value: _filters.willingToTravel,
              onChanged: (on) => _set(FilterKey.willingToTravel, on),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryPicker(
              label: l10n.filterProximityDistrict,
              type: DictionaryType.region,
              parentId: _filters.regionId,
              requiresParentLabel: l10n.filterDistrictsNeedRegion,
              hintText: l10n.filterProximityHint,
              value: _filters.proximityDistrictId,
              onChanged: (id) => _set(FilterKey.proximityDistrictId, id),
            ),

            _section(l10n.filtersPreferences),
            HhDictionaryMultiPicker(
              label: l10n.filterEmploymentTypes,
              type: DictionaryType.employmentType,
              values: _filters.employmentTypeIds,
              onChanged: (ids) => _set(FilterKey.employmentTypeIds, ids),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryMultiPicker(
              label: l10n.filterWorkFormats,
              type: DictionaryType.workFormat,
              values: _filters.workFormatIds,
              onChanged: (ids) => _set(FilterKey.workFormatIds, ids),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryMultiPicker(
              label: l10n.filterShifts,
              type: DictionaryType.shift,
              values: _filters.shiftIds,
              onChanged: (ids) => _set(FilterKey.shiftIds, ids),
            ),
            const SizedBox(height: HhSpace.md),
            _number(
              label: l10n.filterSalaryMin,
              value: _filters.salaryMin,
              onChanged: (n) => _set(FilterKey.salaryMin, n),
            ),
            const SizedBox(height: HhSpace.md),
            _number(
              label: l10n.filterSalaryMax,
              value: _filters.salaryMax,
              onChanged: (n) => _set(FilterKey.salaryMax, n),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.filterSalaryMaxHint,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),

            _section(l10n.filtersAvailability),
            HhSwitchRow(
              label: l10n.filterAvailableImmediately,
              value: _filters.availableImmediately,
              onChanged: (on) => _set(FilterKey.availableImmediately, on),
            ),
            const SizedBox(height: HhSpace.md),
            IsoDateField(
              label: l10n.filterAvailableBy,
              value: _filters.availableBy,
              onChanged: (date) => _set(FilterKey.availableBy, date),
            ),

            _section(l10n.filtersAttributes),
            HhDictionaryMultiPicker(
              label: l10n.filterAttributes,
              type: DictionaryType.attribute,
              values: _filters.attributeIds,
              onChanged: (ids) => _set(FilterKey.attributeIds, ids),
            ),
            if (_filters.attributeIds.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              _matchMode(
                l10n,
                value: _filters.attributesMatchMode,
                onChanged: (mode) =>
                    _set(FilterKey.attributesMatchMode, mode.wire),
              ),
            ],
            const SizedBox(height: HhSpace.md),
            _number(
              label: l10n.filterCrewSizeMin,
              value: _filters.crewSizeMin,
              onChanged: (n) => _set(FilterKey.crewSizeMin, n),
            ),

            _section(l10n.filtersProfile),
            _number(
              label: l10n.filterMinCompleteness,
              value: _filters.minCompleteness,
              onChanged: (n) => _set(FilterKey.minCompleteness, n),
            ),
            const SizedBox(height: HhSpace.md),
            IsoDateField(
              label: l10n.filterUpdatedSince,
              value: _filters.updatedSince,
              onChanged: (date) => _set(FilterKey.updatedSince, date),
            ),

            _section(l10n.filtersRestrictions),
            Text(
              l10n.filterRestrictionExplain,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
            const SizedBox(height: HhSpace.md),
            Row(
              children: [
                Expanded(
                  child: _number(
                    label: l10n.filterAgeMin,
                    value: _filters.ageMin,
                    onChanged: (n) => _set(FilterKey.ageMin, n),
                  ),
                ),
                const SizedBox(width: HhSpace.md),
                Expanded(
                  child: _number(
                    label: l10n.filterAgeMax,
                    value: _filters.ageMax,
                    onChanged: (n) => _set(FilterKey.ageMax, n),
                  ),
                ),
              ],
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryPicker(
              label: l10n.filterGender,
              type: DictionaryType.gender,
              value: _filters.genderId,
              onChanged: (id) => _set(FilterKey.genderId, id),
            ),
            const SizedBox(height: HhSpace.md),
            HhDictionaryPicker(
              label: l10n.filterJustification,
              type: DictionaryType.restrictionJustification,
              value: _filters.restrictionJustificationId,
              errorText: blocked ? l10n.filterRestrictionRequired : null,
              onChanged: (id) =>
                  _set(FilterKey.restrictionJustificationId, id),
            ),

            _section(l10n.filtersSort),
            for (final sort in CandidateSearchSort.values)
              HhRadioRow<CandidateSearchSort>(
                label: _sortLabel(l10n, sort),
                value: sort,
                groupValue: _sort,
                onChanged: (value) => setState(() => _sort = value),
              ),

            const SizedBox(height: HhSpace.xl),
            if (blocked) ...[
              HhNotice.restricted(
                title: l10n.filtersBlockedTitle,
                message: l10n.filterRestrictionRequired,
              ),
              const SizedBox(height: HhSpace.md),
            ],
            HhButton(
              label: l10n.filtersApply,
              onPressed: blocked
                  ? null
                  : () => Navigator.of(context).pop(
                      SearchConfig(filters: _filters, sort: _sort),
                    ),
            ),
            const SizedBox(height: HhSpace.xl),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: HhSpace.xl, bottom: HhSpace.md),
    child: Text(title, style: HhTypography.subtitle),
  );

  Widget _matchMode(
    AppL10n l10n, {
    required MatchMode value,
    required ValueChanged<MatchMode> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l10n.filterMatchMode,
        style: HhTypography.label.copyWith(color: HhColors.inkMuted),
      ),
      const SizedBox(height: HhSpace.sm),
      HhSegmented(
        labels: [l10n.filterMatchAny, l10n.filterMatchAll],
        selectedIndex: value == MatchMode.all ? 1 : 0,
        onChanged: (i) => onChanged(i == 1 ? MatchMode.all : MatchMode.any),
      ),
    ],
  );

  /// A whole-number field that clears itself when emptied.
  ///
  /// The controller is rebuilt from the model on every frame, which is safe
  /// only because the value round-trips exactly: an int in, its digits out. A
  /// text field holding free text cannot be driven this way — the caret would
  /// jump — so this helper is deliberately numbers-only.
  Widget _number({
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
    bool enabled = true,
    String? disabledHint,
  }) {
    final text = value?.toString() ?? '';

    return HhTextField(
      label: label,
      enabled: enabled,
      disabledHint: disabledHint,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: TextEditingController(text: text)
        ..selection = TextSelection.collapsed(offset: text.length),
      onChanged: (raw) => onChanged(int.tryParse(raw)),
    );
  }

  String _sortLabel(AppL10n l10n, CandidateSearchSort sort) => switch (sort) {
    CandidateSearchSort.match => l10n.sortMatch,
    CandidateSearchSort.recent => l10n.sortRecent,
    CandidateSearchSort.experience => l10n.sortExperience,
    CandidateSearchSort.salary => l10n.sortSalary,
    CandidateSearchSort.proximity => l10n.sortProximity,
  };
}

/// §7.1's language filter: languages, each with an optional floor and an
/// optional certificate requirement.
///
/// The languages are chosen with the ordinary multi-picker, and the two
/// qualifiers appear per chosen language. Unlike the profile's leveled field, a
/// row **without** a level is meaningful here — "any Russian at all" is a real
/// filter — so nothing is forced.
class _LanguageRows extends StatelessWidget {
  const _LanguageRows({required this.rows, required this.onChanged});

  final List<LanguageFilter> rows;
  final ValueChanged<List<LanguageFilter>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HhDictionaryMultiPicker(
          label: l10n.filterLanguages,
          type: DictionaryType.language,
          values: [for (final row in rows) row.itemId],
          onChanged: (ids) => onChanged([
            // Keeps each language's floor and certificate flag across an edit
            // of the *set* — removing one language must not reset the others.
            for (final id in ids)
              rows.firstWhere(
                (row) => row.itemId == id,
                orElse: () => LanguageFilter(itemId: id),
              ),
          ]),
        ),

        for (final (index, row) in rows.indexed) ...[
          const SizedBox(height: HhSpace.md),
          HhCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DictionaryLabel(
                  type: DictionaryType.language,
                  id: row.itemId,
                  style: HhTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: HhSpace.md),
                LevelFloorField(
                  label: l10n.filterMinLevel,
                  type: DictionaryType.languageLevel,
                  value: row.minLevelRank,
                  onChanged: (rank) => _replace(index, row.withLevel(rank)),
                ),
                const SizedBox(height: HhSpace.sm),
                HhSwitchRow(
                  label: l10n.filterLanguageCertificate,
                  value: row.requireCertificate,
                  onChanged: (on) => _replace(
                    index,
                    row.withCertificate(required: on),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _replace(int index, LanguageFilter next) => onChanged([
    for (final (i, row) in rows.indexed)
      if (i == index) next else row,
  ]);
}
