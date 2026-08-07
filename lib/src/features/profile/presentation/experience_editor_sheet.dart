import 'package:flutter/material.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:headhunter_app/src/features/profile/domain/history_record.dart';
import 'package:headhunter_app/src/features/profile/presentation/record_editor_sheet.dart';

/// Opens the work-experience editor and returns the draft to save, or null if
/// the user backed out.
///
/// Pass [initial] to edit an existing record; omit it to add one.
Future<ExperienceDraft?> showExperienceEditor(
  BuildContext context, {
  ExperienceRecord? initial,
}) => showRecordEditor<ExperienceDraft>(
  context,
  title: AppL10n.of(context).experienceAdd,
  initial: initial?.toDraft() ?? const ExperienceDraft(),
  isComplete: (draft) => draft.isComplete,
  builder: (context, draft, onChanged) =>
      _ExperienceForm(draft: draft, onChanged: onChanged),
);

class _ExperienceForm extends StatelessWidget {
  const _ExperienceForm({required this.draft, required this.onChanged});

  final ExperienceDraft draft;
  final ValueChanged<ExperienceDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The one required field, first: §5.1's simplified entry for informal
        // or seasonal work is a record where this and the start date are all
        // the candidate can supply.
        HhTextField(
          label: '${l10n.experienceRole} *',
          controller: seededController(draft.roleTitle),
          maxLength: 160,
          onChanged: (v) => onChanged(draft.copyWith(roleTitle: v)),
        ),
        const SizedBox(height: HhSpace.lg),

        HhTextField(
          label: l10n.experienceEmployer,
          controller: seededController(draft.employerName ?? ''),
          maxLength: 160,
          onChanged: (v) => onChanged(
            draft.copyWith(employerName: v.trim().isEmpty ? null : v),
          ),
        ),
        const SizedBox(height: HhSpace.lg),

        // Bound as an id so §7.1's "years in the selected occupation" can be
        // computed, rather than guessed from the title text.
        HhDictionaryPicker(
          label: l10n.experienceOccupation,
          type: DictionaryType.occupation,
          value: draft.occupationId,
          onChanged: (id) => onChanged(draft.copyWith(occupationId: id)),
        ),
        const SizedBox(height: HhSpace.lg),

        IsoDateField(
          label: '${l10n.experienceStarted} *',
          value: draft.startedOn,
          onChanged: (date) => onChanged(draft.copyWith(startedOn: date)),
        ),
        const SizedBox(height: HhSpace.lg),

        IsoDateField(
          label: l10n.experienceEnded,
          value: draft.endedOn,
          // The server treats the two as mutually exclusive, so the field is
          // inert rather than merely ignored while the role is current.
          enabled: !draft.isCurrent,
          onChanged: (date) => onChanged(draft.copyWith(endedOn: date)),
        ),
        const SizedBox(height: HhSpace.md),

        HhCheckboxRow(
          label: l10n.experienceCurrent,
          value: draft.isCurrent,
          // Turning it on clears any end date already entered: sending both is
          // what the server refuses, and leaving a stale one behind would make
          // the refusal arrive at save time for something the user cannot see.
          onChanged: (on) => onChanged(
            draft.copyWith(isCurrent: on, endedOn: on ? null : draft.endedOn),
          ),
        ),
        const SizedBox(height: HhSpace.lg),

        HhTextField(
          label: l10n.experienceResponsibilities,
          controller: seededController(draft.responsibilities ?? ''),
          maxLines: 4,
          maxLength: 2000,
          keyboardType: TextInputType.multiline,
          onChanged: (v) => onChanged(
            draft.copyWith(responsibilities: v.trim().isEmpty ? null : v),
          ),
        ),
      ],
    );
  }
}
