import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_manifest.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';

/// §10.3's dictionary administration: the list of types.
///
/// ## The types come from the server, not from a constant
///
/// `DictionaryType.all` exists and says of itself that it is the prefetch list
/// and "not for validation: the server remains the authority on what exists".
/// An administrator's list built from it would be missing any type added after
/// this build shipped — on the one screen whose job is to manage what the
/// server has. So it reads `GET /dictionaries/manifest`, which is the
/// authority, and falls back to the raw code for a type it has no name for.
///
/// ## What §10.3 is on a phone
///
/// There is no web panel (§2.4), so this is a list of types, then a list of
/// items, then one item's actions — three screens deep, each of which fits a
/// phone. The alternative shape, one table with columns, is the web panel this
/// product does not have.
class DictionaryAdminScreen extends ConsumerWidget {
  const DictionaryAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final manifest = ref.watch(dictionaryManifestProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(dictionaryManifestProvider),
          // Error first: with retry disabled app-wide a failing provider is a
          // terminal state, and matching the loading arm first spins over it.
          child: switch (manifest) {
            AsyncValue(hasError: true, :final error?) => ListView(
              padding: const EdgeInsets.all(HhSpace.gutter),
              children: [
                HhErrorState(
                  title: failureTitle(error, l10n),
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(dictionaryManifestProvider),
                ),
              ],
            ),
            AsyncData(:final value) => _Types(manifest: value),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _Types extends StatelessWidget {
  const _Types({required this.manifest});

  final DictionaryManifest manifest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        Text(l10n.adminDictionariesTitle, style: HhTypography.title),
        const SizedBox(height: HhSpace.xs),
        Text(l10n.adminDictionariesBody, style: HhTypography.caption),
        const SizedBox(height: HhSpace.lg),

        HhCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, type) in manifest.types.indexed) ...[
                if (index > 0)
                  const Divider(height: 1, color: HhColors.borderFaint),
                _TypeRow(type: type),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({required this.type});

  final DictionaryTypeVersion type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () =>
            GoRouter.of(context).go(Routes.adminDictionaryFor(type.type)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dictionaryTypeLabel(type.type, l10n),
                      style: HhTypography.body,
                    ),
                    const SizedBox(height: 2),
                    // Active items only, which is the server's own figure and
                    // the honest one: it is what a picker would show, so a
                    // type whose items have all been retired reads as 0 and
                    // still opens onto the list that explains why.
                    Text(
                      l10n.adminDictionaryActiveCount(type.count),
                      style: HhTypography.caption,
                    ),
                  ],
                ),
              ),
              const HhIcon(
                HhIconPath.chevronRight,
                size: 18,
                color: HhColors.inkSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dictionary type's name, or its code where this build has none.
///
/// The fallback is the code rather than a placeholder, the same rule §10.4's
/// audit actions follow: §10.3 lets an administrator extend the platform at
/// runtime, so a type this build has not heard of must still be reachable —
/// and a dotted code is at least a stable identifier. It is the one place in
/// this product where a wire code is shown on purpose (BR-13 forbids it as a
/// *value*, not as a last-resort name for a thing that has none).
String dictionaryTypeLabel(String type, AppL10n l10n) => switch (type) {
  DictionaryType.occupation => l10n.dictTypeOccupation,
  DictionaryType.skill => l10n.dictTypeSkill,
  DictionaryType.industry => l10n.dictTypeIndustry,
  DictionaryType.region => l10n.dictTypeRegion,
  DictionaryType.language => l10n.dictTypeLanguage,
  DictionaryType.employmentType => l10n.dictTypeEmploymentType,
  DictionaryType.workFormat => l10n.dictTypeWorkFormat,
  DictionaryType.shift => l10n.dictTypeShift,
  DictionaryType.attribute => l10n.dictTypeAttribute,
  DictionaryType.skillLevel => l10n.dictTypeSkillLevel,
  DictionaryType.languageLevel => l10n.dictTypeLanguageLevel,
  DictionaryType.educationLevel => l10n.dictTypeEducationLevel,
  DictionaryType.specialization => l10n.dictTypeSpecialization,
  DictionaryType.paymentPeriod => l10n.dictTypePaymentPeriod,
  DictionaryType.filePurpose => l10n.dictTypeFilePurpose,
  DictionaryType.gender => l10n.dictTypeGender,
  DictionaryType.restrictionJustification =>
    l10n.dictTypeRestrictionJustification,
  _ => type,
};
