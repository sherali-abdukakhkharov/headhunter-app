import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_controller.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:jobbridge_app/src/features/employer/presentation/verification_card.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_tile.dart';

/// The employer's own profile (§6.1) and what BR-03 reads from it.
///
/// ## Not schema-driven, unlike the candidate profile
///
/// §6.1 fixes the field set per employer type, and the backend serves it as a
/// typed DTO rather than through `/schemas`. So this is an ordinary form —
/// which is the right shape for it, and the same judgement ARCHITECTURE.md §6
/// applies to the bespoke candidate sections.
///
/// The one thing it shares with the candidate profile is that **the server
/// computes what matters**: completeness, `isComplete` and `canPublish` all
/// arrive with the response and are rendered as given. A client that ANDed
/// BR-03's two conditions itself would be a second implementation of the rule
/// that decides who may publish.
class EmployerProfileScreen extends ConsumerWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final editor = ref.watch(employerEditorProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (editor) {
          // hasError first: retry is disabled app-wide, so a failure is
          // terminal and matching loading first spins over it forever.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(employerEditorProvider),
            ),
          ),
          AsyncData(:final value) => _Form(state: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form({required this.state});

  final EmployerEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final isCompany = state.type == 'company';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.profile case final profile?) ...[
                  _Standing(profile: profile),
                  const SizedBox(height: HhSpace.md),

                  // §6.2 puts the wallet on the employer *dashboard*, which is
                  // M5's unfinished half. It sits here meanwhile because this
                  // is the built employer-account surface — the widget belongs
                  // to the wallet feature, so the dashboard will place the same
                  // one rather than grow a second copy.
                  const WalletTile(),
                  const SizedBox(height: HhSpace.sectionGap),
                ],

                // The type question comes first and disappears once answered:
                // it decides which fields exist below it, and the server
                // refuses a later change outright.
                if (!state.typeLocked) ...[
                  _TypeChooser(selected: state.type),
                  const SizedBox(height: HhSpace.sectionGap),
                ],

                Text(l10n.employerDetails, style: HhTypography.subtitle),
                const SizedBox(height: HhSpace.md),

                if (isCompany) ...[
                  _text(context, ref, 'legalName', l10n.employerLegalName),
                  _text(context, ref, 'publicName', l10n.employerPublicName),
                  _picker(
                    context,
                    ref,
                    'industryId',
                    l10n.employerIndustry,
                    DictionaryType.industry,
                  ),
                  _text(
                    context,
                    ref,
                    'contactPersonName',
                    l10n.employerContactPerson,
                  ),
                ] else
                  _text(context, ref, 'fullName', l10n.employerFullName),

                _text(
                  context,
                  ref,
                  'contactPhone',
                  l10n.employerContactPhone,
                  keyboardType: TextInputType.phone,
                ),

                // The same region → district cascade the candidate form uses,
                // and the same rule: changing the region clears the district,
                // because a district from the previous province is still a
                // real id and would save without complaint.
                _picker(
                  context,
                  ref,
                  'regionId',
                  l10n.employerRegion,
                  DictionaryType.region,
                  parentScoped: true,
                  onChanged: (id) {
                    ref.read(employerEditorProvider.notifier)
                      ..edit('regionId', id)
                      ..edit('districtId', null);
                  },
                ),
                _picker(
                  context,
                  ref,
                  'districtId',
                  l10n.employerDistrict,
                  DictionaryType.region,
                  parentId: state.valueOf('regionId') as String?,
                  requiresParent: true,
                ),

                _text(context, ref, 'address', l10n.employerAddress),
                _text(
                  context,
                  ref,
                  'description',
                  l10n.employerDescription,
                  maxLines: 4,
                ),

                const SizedBox(height: HhSpace.sectionGap),

                // Only once a profile exists: verification verifies something,
                // and there is nothing to verify before the first save.
                if (!state.isNew) VerificationCard(dirty: state.isDirty),

                const SizedBox(height: HhSpace.xxl),
              ],
            ),
          ),
        ),

        if (state.isDirty || state.isNew)
          _SaveBar(
            saving: state.isSaving,
            onSave: () async {
              final messenger = ScaffoldMessenger.of(context);
              final savedMessage = l10n.profileSaved;

              try {
                final ok = await ref
                    .read(employerEditorProvider.notifier)
                    .save();
                if (ok) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: HhToast(message: savedMessage),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } on ApiException catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
          ),
      ],
    );
  }

  Widget _text(
    BuildContext context,
    WidgetRef ref,
    String field,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: HhSpace.lg),
    child: HhTextField(
      label: label,
      controller: _controllerFor(state.valueOf(field) as String? ?? ''),
      maxLines: maxLines,
      enabled: !state.isSaving,
      keyboardType: keyboardType,
      // Empty means "clear this", which a full-replacement PUT takes literally.
      onChanged: (text) => ref
          .read(employerEditorProvider.notifier)
          .edit(field, text.trim().isEmpty ? null : text),
    ),
  );

  Widget _picker(
    BuildContext context,
    WidgetRef ref,
    String field,
    String label,
    String type, {
    String? parentId,
    bool parentScoped = false,
    bool requiresParent = false,
    ValueChanged<String?>? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: HhSpace.lg),
    child: HhDictionaryPicker(
      label: label,
      type: type,
      value: state.valueOf(field) as String?,
      enabled: !state.isSaving,
      parentScoped: parentScoped,
      parentId: parentId,
      requiresParentLabel: requiresParent
          ? AppL10n.of(context).profileChooseParentFirst
          : null,
      onChanged:
          onChanged ??
          (id) => ref.read(employerEditorProvider.notifier).edit(field, id),
    ),
  );

  static TextEditingController _controllerFor(String text) =>
      TextEditingController.fromValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
}

/// Completeness, verification state and BR-03's verdict.
class _Standing extends StatelessWidget {
  const _Standing({required this.profile});

  final EmployerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HhCompletenessRing(
            percent: profile.completenessPercent,
            title: l10n.profileCompleteness,
          ),
          const SizedBox(height: HhSpace.md),

          // The design system's own verification vocabulary, not a badge
          // assembled here: these five states are the vocabulary, and
          // inventing one inline is how it stops being learnable.
          verificationBadge(profile.verificationStatus, l10n),

          const SizedBox(height: HhSpace.md),

          // BR-03 in words, below the badge rather than inside it. An employer
          // who is complete but unverified needs to know which half is
          // missing, and that will not fit in a badge.
          Text(
            profile.canPublish
                ? l10n.employerCanPublish
                : l10n.employerCannotPublish,
            style: HhTypography.caption.copyWith(
              color: profile.canPublish
                  ? HhColors.inkMuted
                  : HhColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChooser extends ConsumerWidget {
  const _TypeChooser({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.employerChooseType, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),

        for (final (value, label, hint) in [
          (
            'company',
            l10n.employerTypeCompany,
            l10n.employerTypeCompanyHint,
          ),
          (
            'individual',
            l10n.employerTypeIndividual,
            l10n.employerTypeIndividualHint,
          ),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HhRadioRow<String>(
                  label: label,
                  value: value,
                  groupValue: selected,
                  onChanged: ref
                      .read(employerEditorProvider.notifier)
                      .chooseType,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: HhSpace.xl),
                  child: Text(
                    hint,
                    style: HhTypography.caption.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 6),
        Text(
          l10n.employerTypeFixed,
          style: HhTypography.caption.copyWith(color: HhColors.warning),
        ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave});

  final bool saving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: HhColors.white,
      boxShadow: HhElevation.card,
    ),
    child: Padding(
      padding: const EdgeInsets.all(HhSpace.gutter),
      child: HhButton(
        label: AppL10n.of(context).commonSave,
        loading: saving,
        onPressed: saving ? null : onSave,
      ),
    ),
  );
}
