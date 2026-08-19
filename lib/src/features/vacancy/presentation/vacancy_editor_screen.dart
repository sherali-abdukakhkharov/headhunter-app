import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/search_config_controller.dart';
import 'package:jobbridge_app/src/features/profile/presentation/schema_field_widget.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_controller.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_status.dart';

/// One vacancy, rendered from `GET /schemas/vacancy` (§6.3, §6.4).
///
/// **The same engine as the candidate profile.** `SchemaFieldWidget` draws
/// every field, so the six §6.3 categories, the structured requirements and
/// the mandatory-versus-preferred language rows all arrive as declarations
/// rather than as screens written here. Adding a vacancy field is a backend
/// change.
class VacancyEditorScreen extends ConsumerWidget {
  const VacancyEditorScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final editor = ref.watch(vacancyEditorProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vacancyMine),
        actions: [
          // Only where there is something to look at: a draft has no
          // applicants, and the endpoint would answer an empty list that
          // reads as a dead end.
          if (editor.value?.vacancy.status case final status?
              when status != 'draft')
            TextButton(
              onPressed: () => context.go(
                '${Routes.employerVacancies}/$id/applicants',
              ),
              child: Text(l10n.vacancyApplicants),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (editor) {
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(vacancyEditorProvider(id)),
            ),
          ),
          AsyncData(:final value) => _Form(id: id, state: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form({required this.id, required this.state});

  final String id;
  final VacancyEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final vacancy = state.vacancy;
    final notifier = ref.read(vacancyEditorProvider(id).notifier);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Standing(state: state),
                const SizedBox(height: HhSpace.sectionGap),

                // BR-12 said on the form, not discovered at submit: an age or
                // gender restriction needs a justification and always goes to
                // a moderator, even when moderation is otherwise off.
                // `pending`, not `restricted`: BR-12 does not block the
                // form, it guarantees a moderator will look. Error-toning an
                // advisory rule reads as a refusal.
                HhNotice.pending(
                  title: l10n.vacancyRestrictionTitle,
                  message: l10n.vacancyRestrictionWarning,
                ),
                const SizedBox(height: HhSpace.sectionGap),

                for (final section in state.schema.sections) ...[
                  Text(section.label, style: HhTypography.subtitle),
                  const SizedBox(height: HhSpace.md),
                  for (final field in section.renderableFields)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HhSpace.lg),
                      child: SchemaFieldWidget(
                        field: field,
                        value: state.valueOf(field.code),
                        parentValue: field.parentFieldCode == null
                            ? null
                            : state.valueOf(field.parentFieldCode!),
                        errorText: state.fieldErrors[field.code],
                        // Read-only rather than accepting keystrokes the
                        // server will refuse: it answers
                        // `vacancy.under_moderation` or `not_editable`.
                        enabled: vacancy.isEditable && !state.isSaving,
                        onChanged: (value) {
                          notifier.edit(field.code, value);

                          // Changing a parent invalidates its children, the
                          // same cascade rule the candidate profile follows.
                          for (final other in state.schema.sections
                              .expand((s) => s.fields)
                              .where((f) => f.parentFieldCode == field.code)) {
                            notifier.edit(other.code, null);
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: HhSpace.sectionGap),
                ],

                const SizedBox(height: HhSpace.xxl),
              ],
            ),
          ),
        ),

        _Actions(id: id, state: state),
      ],
    );
  }
}

/// Status, the moderator's reason, and what still blocks publication.
class _Standing extends StatelessWidget {
  const _Standing({required this.state});

  final VacancyEditorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final vacancy = state.vacancy;

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vacancyBadge(vacancy.status, l10n),

          if (vacancy.moderationReason case final reason?
              when reason.isNotEmpty) ...[
            const SizedBox(height: HhSpace.md),
            // The moderator's own words. §6.4 requires a rejection to carry a
            // reason, and §2.4 forbids translating it.
            Text(reason, style: HhTypography.body),
          ],

          if (vacancy.missingForSubmit.isNotEmpty) ...[
            const SizedBox(height: HhSpace.md),
            // Shown before the refusal rather than after it: the server
            // answers one 422 per unfilled code, and a count up front turns
            // that into a checklist.
            Text(
              l10n.vacancyMissingForSubmit(vacancy.missingForSubmit.length),
              style: HhTypography.caption.copyWith(color: HhColors.warning),
            ),
          ],

          if (!vacancy.isEditable) ...[
            const SizedBox(height: HhSpace.md),
            Text(
              l10n.vacancyNotEditable,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Save, submit, and the §6.4 transitions this status allows.
class _Actions extends ConsumerWidget {
  const _Actions({required this.id, required this.state});

  final String id;
  final VacancyEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final vacancy = state.vacancy;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        boxShadow: HhElevation.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.isDirty)
              HhButton(
                label: l10n.commonSave,
                loading: state.isSaving,
                onPressed: state.isSaving ? null : () => _save(context, ref),
              )
            else if (vacancy.isSubmittable)
              HhButton(
                label: l10n.vacancySubmit,
                loading: state.isSaving,
                onPressed: state.isSaving
                    ? null
                    : () => _submit(context, ref),
              ),

            // UAT-06. Not on a draft: a draft has no agreed requirements to
            // derive filters from, and prefilling from a half-written vacancy
            // produces a search nobody meant to run.
            if (vacancy.status != 'draft' && !state.isDirty) ...[
              const SizedBox(height: HhSpace.sm),
              HhButton.secondary(
                label: l10n.searchFromVacancy,
                iconPath: HhIconPath.search,
                onPressed: () => _findCandidates(context, ref),
              ),
            ],

            // Only the transitions §6.4 allows from here. Closing is terminal
            // (BR-11), so it never appears as something to undo.
            if (vacancy.employerTransitions.isNotEmpty && !state.isDirty) ...[
              const SizedBox(height: HhSpace.sm),
              Row(
                children: [
                  for (final target in vacancy.employerTransitions) ...[
                    Expanded(
                      child: HhButton.secondary(
                        label: transitionLabel(target, l10n),
                        onPressed: () => _transition(context, ref, target),
                      ),
                    ),
                    const SizedBox(width: HhSpace.sm),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// UAT-06: opens candidate search with this vacancy's requirements applied.
  ///
  /// The prefill is fetched *before* navigating, so the search tab is never
  /// entered showing the previous search's filters and then reshuffled a
  /// moment later. A failed prefill leaves the employer where they are with a
  /// reason, rather than on a search screen that quietly ignored the vacancy.
  Future<void> _findCandidates(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final filters = await ref
          .read(candidateSearchRepositoryProvider)
          .prefill(id);

      await ref
          .read(searchConfigControllerProvider.notifier)
          .prefillFrom(id, filters);

      router.go(Routes.employerCandidates);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(vacancyEditorProvider(id).notifier).save();
    } on ApiException catch (e) {
      // Field-level rejections are already attached to their fields by the
      // controller; this is the summary read first.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(vacancyEditorProvider(id).notifier).submit();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _transition(
    BuildContext context,
    WidgetRef ref,
    String target,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Closing is confirmed; pausing and resuming are not. BR-11 makes closing
    // terminal, and a terminal action reached by one tap is a trap.
    if (target == 'closed') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.vacancyCloseTitle),
          content: Text(l10n.vacancyCloseMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.vacancyClose),
            ),
          ],
        ),
      );
      if (!(confirmed ?? false)) return;
    }

    try {
      await ref
          .read(vacancyEditorProvider(id).notifier)
          .changeStatus(target);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
