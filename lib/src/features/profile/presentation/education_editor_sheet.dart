import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:headhunter_app/src/features/profile/domain/history_record.dart';
import 'package:headhunter_app/src/features/profile/presentation/record_editor_sheet.dart';

/// Opens the education editor and returns the draft to save, or null if the
/// user backed out.
///
/// Pass [initial] to edit an existing record; omit it to add one.
Future<EducationDraft?> showEducationEditor(
  BuildContext context, {
  EducationRecord? initial,
}) => showRecordEditor<EducationDraft>(
  context,
  title: AppL10n.of(context).educationAdd,
  initial: initial?.toDraft() ?? const EducationDraft(),
  isComplete: (draft) => draft.isComplete,
  builder: (context, draft, onChanged) =>
      _EducationForm(draft: draft, onChanged: onChanged),
);

class _EducationForm extends StatelessWidget {
  const _EducationForm({required this.draft, required this.onChanged});

  final EducationDraft draft;
  final ValueChanged<EducationDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The only required field, and a dictionary id rather than free text -
        // §7.1 filters on it.
        HhDictionaryPicker(
          label: '${l10n.educationLevel} *',
          type: DictionaryType.educationLevel,
          value: draft.levelId,
          onChanged: (id) => onChanged(draft.copyWith(levelId: id)),
        ),
        const SizedBox(height: HhSpace.lg),

        HhTextField(
          label: l10n.educationInstitution,
          controller: seededController(draft.institution ?? ''),
          maxLength: 200,
          onChanged: (v) => onChanged(
            draft.copyWith(institution: v.trim().isEmpty ? null : v),
          ),
        ),
        const SizedBox(height: HhSpace.lg),

        HhTextField(
          label: l10n.educationSpecialization,
          controller: seededController(draft.specialization ?? ''),
          maxLength: 200,
          onChanged: (v) => onChanged(
            draft.copyWith(specialization: v.trim().isEmpty ? null : v),
          ),
        ),
        const SizedBox(height: HhSpace.lg),

        // A year, not a date: an expected graduation up to ten years out is
        // accepted, so this is not a past-only date picker.
        HhTextField(
          label: l10n.educationYear,
          controller: seededController(draft.graduationYear?.toString() ?? ''),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (v) => onChanged(
            draft.copyWith(graduationYear: v.isEmpty ? null : int.tryParse(v)),
          ),
        ),
      ],
    );
  }
}
