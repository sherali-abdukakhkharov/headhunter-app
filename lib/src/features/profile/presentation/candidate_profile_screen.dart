import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/profile/data/profile_controller.dart';
import 'package:headhunter_app/src/features/profile/domain/field_schema.dart';
import 'package:headhunter_app/src/features/profile/presentation/schema_field_widget.dart';

/// The candidate profile (§5), rendered from the server's field schema.
///
/// **Nothing about the field set is written here.** Which sections exist, which
/// fields they hold, which are required and which dictionary feeds each picker
/// all come from `GET /schemas/candidate-profile`. That is §5.2's requirement —
/// the form adapts to the work category, and administrators add categories at
/// runtime (§10.3) — so a hardcoded form could only ever be right for the
/// categories that existed when it shipped.
///
/// The consequence worth stating: **adding a field to this screen is a backend
/// change.** If you find yourself adding a widget here for a specific field
/// code, the schema is the place that wants editing.
class CandidateProfileScreen extends ConsumerWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final editor = ref.watch(profileEditorProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (editor) {
          // hasError first: Riverpod's retry leaves a failing provider in an
          // AsyncLoading that merely carries the error, so matching loading
          // first shows a spinner over a failure forever.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(profileEditorProvider),
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

  final ProfileEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              _Completeness(state: state),
              const SizedBox(height: HhSpace.sectionGap),

              for (final section in state.schema.sections) ...[
                _Section(section: section, state: state),
                const SizedBox(height: HhSpace.sectionGap),
              ],

              // Room for the save bar, which floats over the list.
              const SizedBox(height: HhSpace.xxl),
            ],
          ),
        ),

        if (state.isDirty)
          _SaveBar(
            saving: state.isSaving,
            onSave: () async {
              // Both resolved before the await. The widget can be rebuilt or
              // disposed while the write is in flight, and reaching for
              // `context` afterwards is the classic way that becomes a crash
              // only on a slow connection.
              final messenger = ScaffoldMessenger.of(context);
              final savedMessage = l10n.profileSaved;

              try {
                final ok = await ref
                    .read(profileEditorProvider.notifier)
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
                // Field-level rejections are already attached to their fields
                // by the controller; this is the summary read first.
                messenger.showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
          ),
      ],
    );
  }
}

/// §5.3: a completeness percentage and the list of what is missing, each entry
/// naming a field the user can go and fill.
class _Completeness extends StatelessWidget {
  const _Completeness({required this.state});

  final ProfileEditorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final profile = state.profile;
    final blocking = profile.blockingFields;

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HhCompletenessRing(
            percent: profile.completenessPercent,
            title: l10n.profileCompleteness,
            subtitle: blocking.isEmpty
                ? null
                : l10n.profileMissingRequired(blocking.length),
          ),
          const SizedBox(height: HhSpace.md),

          // Searchability is what BR-02 actually gates, so it is stated rather
          // than left to be inferred from the percentage - a profile can be
          // 80% complete and still invisible.
          HhBadge(
            label: profile.isSearchable
                ? l10n.profileSearchable
                : l10n.profileNotSearchable,
            tone: profile.isSearchable ? HhTone.success : HhTone.neutral,
            iconPath: profile.isSearchable
                ? HhIconPath.checkCircle
                : HhIconPath.eye,
          ),
        ],
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.section, required this.state});

  final SchemaSection section;
  final ProfileEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.label, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),

        if (!section.isEngine)
          // A bespoke section owns its own sub-resource and its own editor
          // (work history, education). Saying so beats rendering an empty box
          // that reads as a finished, empty section.
          HhNotice.pending(
            title: section.label,
            message: l10n.profileSectionElsewhere,
          )
        else
          for (final field in section.renderableFields)
            Padding(
              padding: const EdgeInsets.only(bottom: HhSpace.lg),
              child: SchemaFieldWidget(
                field: field,
                value: state.valueOf(field.code),
                // The schema names the parent; the engine never knows that a
                // district belongs to a region.
                parentValue: field.parentFieldCode == null
                    ? null
                    : state.valueOf(field.parentFieldCode!),
                errorText: state.fieldErrors[field.code],
                enabled: !state.isSaving,
                onChanged: (value) {
                  final notifier = ref.read(profileEditorProvider.notifier)
                    ..edit(field.code, value);

                  // Changing a parent invalidates its children: a district from
                  // the previous region is still a real id and would save
                  // without complaint, leaving a profile whose district sits in
                  // another province.
                  for (final other in state.schema.sections
                      .expand((s) => s.fields)
                      .where((f) => f.parentFieldCode == field.code)) {
                    notifier.edit(other.code, null);
                  }
                },
              ),
            ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Container(
      padding: const EdgeInsets.all(HhSpace.gutter),
      decoration: const BoxDecoration(
        color: HhColors.white,
        boxShadow: HhElevation.sheet,
      ),
      child: SafeArea(
        top: false,
        child: HhButton(
          label: l10n.commonSave,
          loading: saving,
          onPressed: saving ? null : onSave,
        ),
      ),
    );
  }
}
