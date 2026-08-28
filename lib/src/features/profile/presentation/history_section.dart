import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/profile/data/history_controller.dart';
import 'package:jobbridge_app/src/features/profile/data/history_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/domain/history_record.dart';
import 'package:jobbridge_app/src/features/profile/presentation/education_editor_sheet.dart';
import 'package:jobbridge_app/src/features/profile/presentation/experience_editor_sheet.dart';

/// Renders a `editor: "bespoke"` section of the candidate profile (§5.1).
///
/// The field engine deliberately does not cover these: work history and
/// education are repeating records with their own sub-resources and their own
/// shapes, and ARCHITECTURE.md §6 says to write those as ordinary widgets
/// rather than growing the engine until it can express everything.
///
/// **An unrecognised bespoke section still renders the notice.** That is the
/// same rule as `FieldKind.unknown`: the server may declare a section this app
/// version has no editor for, and the answer is to say so, never to crash and
/// never to silently omit it — an absent section reads as a finished one, and
/// then the completeness percentage cannot be explained.
class BespokeSection extends StatelessWidget {
  const BespokeSection({required this.section, super.key});

  final SchemaSection section;

  @override
  Widget build(BuildContext context) => switch (section.code) {
    'experience' => ExperienceSection(
      path: section.endpoint ?? HistoryRepository.experiencePath,
    ),
    'education' => EducationSection(
      path: section.endpoint ?? HistoryRepository.educationPath,
    ),
    _ => HhNotice.pending(
      title: section.label,
      message: AppL10n.of(context).profileSectionElsewhere,
    ),
  };
}

/// Work experience (§5.1).
class ExperienceSection extends ConsumerWidget {
  const ExperienceSection({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final records = ref.watch(experienceListProvider(path));

    return HistoryList(
      records: records,
      emptyLabel: l10n.experienceEmpty,
      addLabel: l10n.experienceAdd,
      onRetry: () => ref.invalidate(experienceListProvider(path)),
      onAdd: () async {
        final draft = await showExperienceEditor(context);
        if (draft == null) return;
        await ref.read(experienceListProvider(path).notifier).add(draft);
      },
      itemBuilder: (record) => _ExperienceCard(record: record, path: path),
    );
  }
}

/// Education (§5.1). Optional for the categories where it is not relevant,
/// which is why no category makes it required for searchability.
class EducationSection extends ConsumerWidget {
  const EducationSection({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final records = ref.watch(educationListProvider(path));

    return HistoryList(
      records: records,
      emptyLabel: l10n.educationEmpty,
      addLabel: l10n.educationAdd,
      onRetry: () => ref.invalidate(educationListProvider(path)),
      onAdd: () async {
        final draft = await showEducationEditor(context);
        if (draft == null) return;
        await ref.read(educationListProvider(path).notifier).add(draft);
      },
      itemBuilder: (record) => _EducationCard(record: record, path: path),
    );
  }
}

/// The list-plus-add shell both sections share.
///
/// Generic over the record so the two sections differ only in their card, their
/// strings and their endpoint — the async states, the empty state and the add
/// button are one implementation.
class HistoryList<T> extends StatelessWidget {
  const HistoryList({
    required this.records,
    required this.emptyLabel,
    required this.addLabel,
    required this.onAdd,
    required this.onRetry,
    required this.itemBuilder,
    super.key,
  });

  final AsyncValue<List<T>> records;
  final String emptyLabel;
  final String addLabel;
  final Future<void> Function() onAdd;
  final VoidCallback onRetry;
  final Widget Function(T record) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return switch (records) {
      // hasError first, deliberately: with Riverpod's retry disabled app-wide
      // a failure is terminal, and matching loading first would spin forever
      // over it.
      AsyncValue(hasError: true, :final error?) => HhErrorState(
        title: failureTitle(error, l10n),
        message: error is ApiException ? error.message : l10n.stateErrorBody,
        retryLabel: l10n.commonRetry,
        onRetry: onRetry,
      ),

      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value.isEmpty)
            Text(
              emptyLabel,
              style: HhTypography.body.copyWith(color: HhColors.inkDisabled),
            )
          else
            for (final record in value)
              Padding(
                padding: const EdgeInsets.only(bottom: HhSpace.sm),
                child: itemBuilder(record),
              ),

          const SizedBox(height: HhSpace.md),
          HhButton.secondary(
            label: addLabel,
            iconPath: HhIconPath.plus,
            compact: true,
            onPressed: onAdd,
          ),
        ],
      ),

      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _ExperienceCard extends ConsumerWidget {
  const _ExperienceCard({required this.record, required this.path});

  final ExperienceRecord record;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return _RecordCard(
      title: Text(
        record.roleTitle,
        style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: record.employerName,
      detail: _period(record, l10n),
      body: record.responsibilities,
      onEdit: () async {
        final draft = await showExperienceEditor(context, initial: record);
        if (draft == null) return;
        await ref
            .read(experienceListProvider(path).notifier)
            .replace(record.id, draft);
      },
      onDelete: () =>
          ref.read(experienceListProvider(path).notifier).remove(record.id),
    );
  }

  /// `2024-03-01 — Present`, from the ISO strings as they arrive.
  ///
  /// Deliberately not localized into a written month: §8.3's time-zone and
  /// display policy is still open, and inventing a format here would have to be
  /// undone. The ISO form is unambiguous in every one of the four variants.
  ///
  /// **Three cases, not two.** The server accepts `isCurrent: false` with no
  /// end date — a role that ended on a date the candidate did not give — and
  /// that is the combination this editor produces most easily. Folding it in
  /// with the ongoing case prints "Present" over a record that explicitly says
  /// it is not current, which is the card asserting something the data denies.
  /// So an unknown end prints no end at all.
  String _period(ExperienceRecord record, AppL10n l10n) {
    if (record.isCurrent) {
      return '${record.startedOn} — ${l10n.experiencePresent}';
    }
    if (record.endedOn case final end?) return '${record.startedOn} — $end';

    return record.startedOn;
  }
}

class _EducationCard extends ConsumerWidget {
  const _EducationCard({required this.record, required this.path});

  final EducationRecord record;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _RecordCard(
    // The level is a dictionary id, so the card resolves it to a label the
    // same way every other bound id on this screen does.
    title: DictionaryLabel(
      type: DictionaryType.educationLevel,
      id: record.levelId,
      style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
    ),
    subtitle: record.institution,
    detail: [
      ?record.specialization,
      ?record.graduationYear?.toString(),
    ].join(' · '),
    onEdit: () async {
      final draft = await showEducationEditor(context, initial: record);
      if (draft == null) return;
      await ref
          .read(educationListProvider(path).notifier)
          .replace(record.id, draft);
    },
    onDelete: () =>
        ref.read(educationListProvider(path).notifier).remove(record.id),
  );
}

/// One record, with its edit and delete affordances.
///
/// [title] is a widget rather than a string because an education record's title
/// is a dictionary id that resolves asynchronously, while an experience
/// record's is text the candidate typed.
class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.title,
    required this.onEdit,
    required this.onDelete,
    this.subtitle,
    this.detail,
    this.body,
  });

  final Widget title;
  final String? subtitle;
  final String? detail;
  final String? body;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,

          if (subtitle case final text? when text.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              text,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ],

          if (detail case final text? when text.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              text,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ],

          if (body case final text? when text.isNotEmpty) ...[
            const SizedBox(height: HhSpace.sm),
            Text(text, style: HhTypography.caption),
          ],

          const SizedBox(height: HhSpace.sm),
          Row(
            children: [
              HhButton.text(label: l10n.commonEdit, onPressed: onEdit),
              const SizedBox(width: HhSpace.sm),
              HhButton.text(
                label: l10n.commonDelete,
                onPressed: () async {
                  // Confirmed, because a deleted record cannot be recovered and
                  // the button sits next to Edit.
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.historyDeleteTitle),
                      content: Text(l10n.historyDeleteMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.commonCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l10n.commonDelete),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) await onDelete();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
