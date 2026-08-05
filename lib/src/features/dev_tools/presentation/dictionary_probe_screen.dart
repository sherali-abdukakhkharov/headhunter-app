import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/l10n/app_locale.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_cache.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_picker.dart';

/// **Development only.** Exercises the dictionary layer against the real API.
///
/// This is a probe, not a product screen: the profile and vacancy forms that
/// will actually carry these pickers are schema-driven (§5.2, §6.3) and belong
/// to M3. Until they exist there is nowhere else to see a picker fail, and
/// "compiles and has unit tests" is not the same as "renders 200 regions on a
/// device without jank".
///
/// What it is here to make visible, all of which a green test suite misses:
///
/// - **UAT-13, the client half.** Switch language at the top and every label
///   re-resolves while the selected ids below stay exactly as they were. That
///   is the whole of BR-13 in one gesture.
/// - **The cascade.** District stays disabled until a region is chosen, then
///   offers only that region's children.
/// - **Cache behaviour.** The second visit should not hit the network; "clear
///   the cache" forces the cold path back so it can be watched.
class DictionaryProbeScreen extends ConsumerStatefulWidget {
  const DictionaryProbeScreen({super.key});

  @override
  ConsumerState<DictionaryProbeScreen> createState() =>
      _DictionaryProbeScreenState();
}

class _DictionaryProbeScreenState extends ConsumerState<DictionaryProbeScreen> {
  String? _regionId;
  String? _districtId;
  String? _occupationId;
  List<String> _skillIds = [];

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(activeLocaleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dictionaries')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            const HhNotice.pending(
              title: 'Development probe',
              message:
                  'Switch language and watch every label change while the '
                  'selected ids below stay put. That is BR-13 / UAT-13.',
            ),
            const SizedBox(height: HhSpace.sectionGap),

            Text('Interface language', style: HhTypography.subtitle),
            const SizedBox(height: HhSpace.md),
            HhSegmented(
              labels: [for (final l in AppLocale.values) l.tag],
              selectedIndex: AppLocale.values.indexOf(activeLocale),
              onChanged: (index) => ref
                  .read(localeControllerProvider.notifier)
                  .select(AppLocale.values[index]),
            ),

            const SizedBox(height: HhSpace.sectionGap),
            Text('Cascading (§5.1)', style: HhTypography.subtitle),
            const SizedBox(height: HhSpace.md),

            HhDictionaryPicker(
              label: 'Region',
              type: DictionaryType.region,
              // Regions and districts share one type; without this the region
              // list also offers every district.
              parentScoped: true,
              value: _regionId,
              onChanged: (id) => setState(() {
                _regionId = id;
                // Clearing the child is not tidiness: a district from the old
                // region would still be a valid id and would save without
                // complaint, producing a profile whose district is in a
                // different province.
                _districtId = null;
              }),
            ),
            const SizedBox(height: HhSpace.lg),
            HhDictionaryPicker(
              label: 'District',
              type: DictionaryType.region,
              parentId: _regionId,
              requiresParentLabel: 'Choose a region first',
              value: _districtId,
              onChanged: (id) => setState(() => _districtId = id),
            ),

            const SizedBox(height: HhSpace.sectionGap),
            Text('Single and multi select', style: HhTypography.subtitle),
            const SizedBox(height: HhSpace.md),

            HhDictionaryPicker(
              label: 'Occupation',
              type: DictionaryType.occupation,
              value: _occupationId,
              onChanged: (id) => setState(() => _occupationId = id),
            ),
            const SizedBox(height: HhSpace.lg),
            HhDictionaryMultiPicker(
              label: 'Skills',
              type: DictionaryType.skill,
              values: _skillIds,
              onChanged: (ids) => setState(() => _skillIds = ids),
            ),

            const SizedBox(height: HhSpace.sectionGap),
            Text('Bound values (ids)', style: HhTypography.subtitle),
            const SizedBox(height: HhSpace.md),
            // Printed deliberately. These are what a form would send, and
            // seeing them stay byte-identical across a language switch is the
            // only direct evidence that labels are not being bound.
            HhCard(
              child: Text(
                'region:     ${_regionId ?? '-'}\n'
                'district:   ${_districtId ?? '-'}\n'
                'occupation: ${_occupationId ?? '-'}\n'
                'skills:     ${_skillIds.isEmpty ? '-' : _skillIds.join(', ')}',
                style: HhTypography.caption.copyWith(
                  fontFamily: 'monospace',
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: HhSpace.sectionGap),
            HhButton.tertiary(
              label: 'Clear the dictionary cache',
              iconPath: HhIconPath.trash,
              onPressed: () async {
                final cache = await ref.read(dictionaryCacheProvider.future);
                await cache.clear();
                for (final type in DictionaryType.all) {
                  ref.invalidate(dictionaryProvider(type));
                }
              },
            ),
            const SizedBox(height: HhSpace.xxl),
          ],
        ),
      ),
    );
  }
}
