import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/features/discovery/data/feed_filter_controller.dart';
import 'package:jobbridge_app/src/features/discovery/domain/feed_filters.dart';
import 'package:jobbridge_app/src/shared/widgets/iso_date_field.dart';

/// Opens §5.5's filters.
Future<void> showFeedFilters(BuildContext context) => Navigator.of(
  context,
  rootNavigator: true,
).push<void>(MaterialPageRoute(builder: (_) => const FeedFilterScreen()));

/// §5.5's vacancy filters — all nine of them, since 2026-08-26.
///
/// ## Edited locally, applied on Apply
///
/// The set is held in this screen's state and written once, rather than saved
/// on every tap. Two reasons: each write re-queries the feeds, and a candidate
/// part-way through choosing an occupation and a region has a *meaningless*
/// filter set — occupation chosen, region not yet — which is the one state they
/// do not want results for.
///
/// ## Two of the controls read backwards
///
/// **Experience** is a ceiling on what the *vacancy* asks for, so a vacancy
/// requiring nothing passes it — the opposite of the employer's filter of the
/// same name, which is a floor on what a person has. **Language** is the other
/// way: it matches vacancies that require the language, so one naming no
/// language does not pass.
///
/// Both are the server's rules and both are stated on screen, next to the
/// control, for the same reason the negotiable-pay note is: a filter whose
/// results look wrong is indistinguishable from a broken one.
class FeedFilterScreen extends ConsumerStatefulWidget {
  const FeedFilterScreen({super.key});

  @override
  ConsumerState<FeedFilterScreen> createState() => _FeedFilterScreenState();
}

class _FeedFilterScreenState extends ConsumerState<FeedFilterScreen> {
  FeedFilters? _draft;

  /// The three free-text numbers, read on Apply rather than per keystroke.
  final _salaryFrom = TextEditingController();
  final _salaryTo = TextEditingController();
  final _experience = TextEditingController();

  @override
  void dispose() {
    _salaryFrom.dispose();
    _salaryTo.dispose();
    _experience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Seeded from storage on the first build that has it, then left alone: this
    // screen owns the draft from that moment, and re-seeding on a later rebuild
    // would discard whatever the candidate had already chosen.
    if (_draft == null) {
      final stored = ref.watch(feedFilterControllerProvider);
      if (stored case AsyncData(:final value)) {
        _draft = value;
        _salaryFrom.text = value.salaryFrom?.toString() ?? '';
        _salaryTo.text = value.salaryTo?.toString() ?? '';
        _experience.text = value.experienceYearsMax?.toString() ?? '';
      }
    }

    final draft = _draft;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filtersTitle),
        actions: [
          if (draft != null && !draft.isEmpty)
            HhButton.text(label: l10n.filtersReset, onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: draft == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: _Form(
                      draft: draft,
                      salaryFrom: _salaryFrom,
                      salaryTo: _salaryTo,
                      experience: _experience,
                      onChanged: (next) => setState(() => _draft = next),
                    ),
                  ),
                  _ApplyBar(onApply: () => _apply(draft)),
                ],
              ),
      ),
    );
  }

  void _reset() {
    setState(() => _draft = const FeedFilters());
    _salaryFrom.clear();
    _salaryTo.clear();
    _experience.clear();
  }

  Future<void> _apply(FeedFilters draft) async {
    // An empty box clears its filter, and anything unparseable is treated as
    // empty rather than as zero. Zero is a real and very different answer in
    // two of the three: a pay floor of 0 passes every vacancy, and an
    // experience ceiling of 0 hides every vacancy that asks for any.
    final from = int.tryParse(_salaryFrom.text.trim());
    final to = int.tryParse(_salaryTo.text.trim());
    final years = int.tryParse(_experience.text.trim());

    final applied = draft.copyWith(
      salaryFrom: from,
      clearSalaryFrom: from == null,
      salaryTo: to,
      clearSalaryTo: to == null,
      experienceYearsMax: years,
      clearExperience: years == null,
    );

    await ref.read(feedFilterControllerProvider.notifier).set(applied);
    if (mounted) Navigator.of(context).pop();
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.draft,
    required this.salaryFrom,
    required this.salaryTo,
    required this.experience,
    required this.onChanged,
  });

  final FeedFilters draft;
  final TextEditingController salaryFrom;
  final TextEditingController salaryTo;
  final TextEditingController experience;
  final ValueChanged<FeedFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        HhDictionaryMultiPicker(
          label: l10n.filtersOccupation,
          type: DictionaryType.occupation,
          values: draft.occupationIds.toList(),
          onChanged: (ids) =>
              onChanged(draft.copyWith(occupationIds: ids.toSet())),
        ),
        const SizedBox(height: HhSpace.md),

        // One place, not a set: the API takes a single `regionId`. Both region
        // and district are ids in the **region** dictionary, since districts
        // are its children (§5.1) rather than a type of their own — so choosing
        // a district here sets `regionId`, which is what the server expects.
        HhDictionaryPicker(
          label: l10n.filtersRegion,
          type: DictionaryType.region,
          value: draft.districtId ?? draft.regionId,
          onChanged: (id) => onChanged(
            id == null
                ? draft.copyWith(clearRegion: true, clearDistrict: true)
                : draft.copyWith(regionId: id, clearDistrict: true),
          ),
        ),
        const SizedBox(height: HhSpace.md),

        HhDictionaryMultiPicker(
          label: l10n.filtersEmploymentType,
          type: DictionaryType.employmentType,
          values: draft.employmentTypeIds.toList(),
          onChanged: (ids) =>
              onChanged(draft.copyWith(employmentTypeIds: ids.toSet())),
        ),
        const SizedBox(height: HhSpace.md),

        HhDictionaryMultiPicker(
          label: l10n.filtersWorkFormat,
          type: DictionaryType.workFormat,
          values: draft.workFormatIds.toList(),
          onChanged: (ids) =>
              onChanged(draft.copyWith(workFormatIds: ids.toSet())),
        ),
        const SizedBox(height: HhSpace.md),

        HhDictionaryMultiPicker(
          label: l10n.filtersShift,
          type: DictionaryType.shift,
          values: draft.shiftIds.toList(),
          onChanged: (ids) => onChanged(draft.copyWith(shiftIds: ids.toSet())),
        ),
        const SizedBox(height: HhSpace.md),

        // §5.5's "salary/payment range" — one filter, two boxes, and one note
        // covering both because the negotiable rule applies to each.
        HhTextField(
          label: l10n.filtersSalaryFrom,
          controller: salaryFrom,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: HhSpace.md),
        HhTextField(
          label: l10n.filtersSalaryTo,
          controller: salaryTo,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: HhSpace.xs),
        // The server's rule, stated where somebody would otherwise conclude
        // the filter is broken: a negotiable vacancy **passes** a pay bound,
        // because it has not said no to the figure — and excluding it would
        // hide much of the seasonal work.
        Text(
          l10n.filtersSalaryNegotiableNote,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),

        HhTextField(
          label: l10n.filtersExperienceUpTo,
          controller: experience,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: HhSpace.xs),
        // The direction, in the one place it can be misread. This is a ceiling
        // on what the *vacancy* asks for, so vacancies asking for nothing are
        // the ones a candidate setting it most wants to see.
        Text(
          l10n.filtersExperienceAnyNote,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),

        HhDictionaryMultiPicker(
          label: l10n.filtersLanguageRequired,
          type: DictionaryType.language,
          values: draft.languageIds.toList(),
          onChanged: (ids) =>
              onChanged(draft.copyWith(languageIds: ids.toSet())),
        ),
        const SizedBox(height: HhSpace.md),

        IsoDateField(
          label: l10n.filtersPublishedFrom,
          value: draft.publishedFrom,
          onChanged: (value) => onChanged(
            value == null
                ? draft.copyWith(clearPublished: true)
                : draft.copyWith(publishedFrom: value),
          ),
        ),
        const SizedBox(height: HhSpace.sectionGap),
      ],
    );
  }
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HhSpace.gutter),
    decoration: const BoxDecoration(
      color: HhColors.white,
      boxShadow: HhElevation.sheet,
    ),
    child: SafeArea(
      top: false,
      child: HhButton(
        label: AppL10n.of(context).filtersApply,
        onPressed: onApply,
      ),
    ),
  );
}
