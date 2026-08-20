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

/// §5.5's vacancy filters.
///
/// ## Edited locally, applied on Apply
///
/// The set is held in this screen's state and written once, rather than saved
/// on every tap. Two reasons: each write re-queries the feeds, and a candidate
/// part-way through choosing an occupation and a region has a *meaningless*
/// filter set — occupation chosen, region not yet — which is the one state they
/// do not want results for.
///
/// ## Three of §5.5's filters are not here
///
/// Experience, language, and the upper end of the pay range have no query
/// parameter on `GET /discovery/{feed}`. Offering them would produce controls
/// that visibly do nothing to the list, which is worse than controls that were
/// never there — the results look like an answer. The screen says so out loud
/// rather than leaving somebody hunting, and it is a backend ask in TODO.md.
class FeedFilterScreen extends ConsumerStatefulWidget {
  const FeedFilterScreen({super.key});

  @override
  ConsumerState<FeedFilterScreen> createState() => _FeedFilterScreenState();
}

class _FeedFilterScreenState extends ConsumerState<FeedFilterScreen> {
  FeedFilters? _draft;
  final _salary = TextEditingController();

  @override
  void dispose() {
    _salary.dispose();
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
        _salary.text = value.salaryFrom?.toString() ?? '';
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
                      salary: _salary,
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
    _salary.clear();
  }

  Future<void> _apply(FeedFilters draft) async {
    // The pay field is free text, read here rather than tracked per keystroke.
    // An empty box clears the filter, and anything unparseable is treated as
    // empty rather than as zero — a floor of 0 is one every vacancy passes,
    // which is not what somebody who typed letters meant.
    final typed = int.tryParse(_salary.text.trim());
    final applied = typed == null
        ? draft.copyWith(clearSalary: true)
        : draft.copyWith(salaryFrom: typed);

    await ref.read(feedFilterControllerProvider.notifier).set(applied);
    if (mounted) Navigator.of(context).pop();
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.draft,
    required this.salary,
    required this.onChanged,
  });

  final FeedFilters draft;
  final TextEditingController salary;
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

        HhTextField(
          label: l10n.filtersSalaryFrom,
          controller: salary,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: HhSpace.xs),
        // The server's rule, stated where somebody would otherwise conclude
        // the filter is broken: a negotiable vacancy **passes** a pay floor,
        // because it has not said no to the figure — and excluding it would
        // hide much of the seasonal work.
        Text(
          l10n.filtersSalaryNegotiableNote,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
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

        // Says plainly what §5.5 asks for and the API cannot do, rather than
        // leaving somebody hunting for a control that is not there.
        HhNotice.permission(
          title: l10n.filtersUnavailableTitle,
          message: l10n.filtersUnavailableBody,
        ),
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
