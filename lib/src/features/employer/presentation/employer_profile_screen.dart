import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/account/presentation/account_entry_row.dart';
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
              title: failureTitle(error, l10n),
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

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.state});

  final EmployerEditorState state;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  /// Whether Save has been pressed and refused.
  ///
  /// Errors appear only after it. A form that opens with every mandatory field
  /// already red is telling somebody off for not having filled in a form they
  /// have not seen — and it hides which field they are actually on.
  bool _attempted = false;

  /// One key per mandatory field, so a refused save can scroll to the first
  /// one that is empty. §6.1's company form is taller than a phone, so "the
  /// button did nothing" is the failure this prevents.
  final _keys = <String, GlobalKey>{};

  GlobalKey _keyFor(String field) =>
      _keys.putIfAbsent(field, GlobalKey.new);

  EmployerEditorState get state => widget.state;

  @override
  Widget build(BuildContext context) {
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

                // Nothing below it until it is answered. Which fields exist
                // *is* the answer — a company has a legal name and an industry
                // and an individual has neither — so a form drawn before the
                // question is a form drawn for a guess.
                if (state.type == null)
                  Text(
                    l10n.employerTypeFirst,
                    style: HhTypography.body.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  )
                else ...[
                Text(l10n.employerDetails, style: HhTypography.subtitle),
                const SizedBox(height: HhSpace.md),

                if (isCompany) ...[
                  _text(
                  'legalName', l10n.employerLegalName),
                  _text(
                  'publicName', l10n.employerPublicName),
                  _picker(
                  'industryId',
                    l10n.employerIndustry,
                    DictionaryType.industry,
                  ),
                  _text(
                  'contactPersonName',
                    l10n.employerContactPerson,
                  ),
                ] else
                  _text(
                  'fullName', l10n.employerFullName),

                _text(
                  'contactPhone',
                  l10n.employerContactPhone,
                  keyboardType: TextInputType.phone,
                ),

                // The same region → district cascade the candidate form uses,
                // and the same rule: changing the region clears the district,
                // because a district from the previous province is still a
                // real id and would save without complaint.
                _picker(
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
                  'districtId',
                  l10n.employerDistrict,
                  DictionaryType.region,
                  parentId: state.valueOf('regionId') as String?,
                  requiresParent: true,
                ),

                _text(
                  'address', l10n.employerAddress),
                _text(
                  'description',
                  l10n.employerDescription,
                  maxLines: 4,
                ),

                const SizedBox(height: HhSpace.sectionGap),

                // Only once a profile exists: verification verifies something,
                // and there is nothing to verify before the first save.
                if (!state.isNew) VerificationCard(dirty: state.isDirty),

                const SizedBox(height: HhSpace.sectionGap),

                ],

                // Sessions, sign-out and BR-14. The same row the candidate
                // profile carries: §2.3 makes the role a runtime switch, so
                // whichever shell somebody is in has to reach the account.
                const AccountEntryRow(),

                const SizedBox(height: HhSpace.xxl),
              ],
            ),
          ),
        ),

        if ((state.isDirty || state.isNew) && state.type != null)
          _SaveBar(
            saving: state.isSaving,
            // Named rather than counted: "6 fields left" tells nobody which,
            // and the list is short enough to read.
            missing: _attempted
                ? [for (final f in state.missingRequired) _labelFor(f, l10n)]
                : const [],
            onSave: () async {
              final messenger = ScaffoldMessenger.of(context);
              final savedMessage = l10n.profileSaved;

              if (!state.canSave) {
                setState(() => _attempted = true);
                await _revealFirstMissing();
                return;
              }

              try {
                final ok = await ref
                    .read(employerEditorProvider.notifier)
                    .save();
                if (ok) {
                  setState(() => _attempted = false);
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

  /// Whether this field is mandatory, empty, and has been asked for.
  ///
  /// All three: a mandatory field is not an error until Save has been refused
  /// over it, and after the first save nothing is mandatory any more — the
  /// type is settled by then, so a half-finished edit is ordinary work.
  bool _isMissing(String field) =>
      _attempted && state.missingRequired.contains(field);

  Widget _text(
    String field,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => Padding(
    key: _keyFor(field),
    padding: const EdgeInsets.only(bottom: HhSpace.lg),
    child: HhTextField(
      label: label,
      errorText: _isMissing(field)
          ? AppL10n.of(context).employerRequired
          : null,
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
    String field,
    String label,
    String type, {
    String? parentId,
    bool parentScoped = false,
    bool requiresParent = false,
    ValueChanged<String?>? onChanged,
  }) => Padding(
    key: _keyFor(field),
    padding: const EdgeInsets.only(bottom: HhSpace.lg),
    child: HhDictionaryPicker(
      label: label,
      errorText: _isMissing(field)
          ? AppL10n.of(context).employerRequired
          : null,
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

  /// Brings the topmost empty mandatory field into view.
  ///
  /// [EmployerEditorState.missingRequired] is in form order, so the first
  /// entry is the one nearest the top. Without this a refused save on §6.1's
  /// company form scrolls nowhere and reads as a button that does nothing.
  Future<void> _revealFirstMissing() async {
    final first = state.missingRequired.firstOrNull;
    final target = first == null ? null : _keys[first]?.currentContext;
    if (target == null) return;

    await Scrollable.ensureVisible(
      target,
      alignment: 0.2,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// The field's own label, so the list under Save names the same words the
  /// fields do.
  String _labelFor(String field, AppL10n l10n) => switch (field) {
    'contactPhone' => l10n.employerContactPhone,
    'regionId' => l10n.employerRegion,
    'description' => l10n.employerDescription,
    'legalName' => l10n.employerLegalName,
    'publicName' => l10n.employerPublicName,
    'industryId' => l10n.employerIndustry,
    'contactPersonName' => l10n.employerContactPerson,
    'fullName' => l10n.employerFullName,
    // A requirement this build does not know a label for, which can only come
    // from the server's list growing. Naming the code beats naming nothing.
    _ => field,
  };

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

  /// Null until the question is answered. No preselection: the choice is
  /// permanent, and a default answer to a permanent question is a decision the
  /// product made on somebody's behalf.
  final String? selected;

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
  const _SaveBar({
    required this.saving,
    required this.onSave,
    this.missing = const [],
  });

  final bool saving;
  final Future<void> Function() onSave;

  /// The mandatory fields still empty, by label. Empty until a save has been
  /// refused.
  final List<String> missing;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: HhColors.white,
      boxShadow: HhElevation.card,
    ),
    child: Padding(
      padding: const EdgeInsets.all(HhSpace.gutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (missing.isNotEmpty) ...[
            Text(
              AppL10n.of(context).employerMissingRequired(missing.join(', ')),
              style: HhTypography.caption.copyWith(color: HhColors.errorFg),
            ),
            const SizedBox(height: HhSpace.sm),
          ],
          HhButton(
            label: AppL10n.of(context).commonSave,
            loading: saving,
            onPressed: saving ? null : onSave,
          ),
        ],
      ),
    ),
  );
}
