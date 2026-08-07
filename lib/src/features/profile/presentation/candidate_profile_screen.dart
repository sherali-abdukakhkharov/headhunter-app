import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/profile/data/profile_controller.dart';
import 'package:headhunter_app/src/features/profile/domain/candidate_profile.dart';
import 'package:headhunter_app/src/features/profile/domain/field_schema.dart';
import 'package:headhunter_app/src/features/profile/presentation/history_section.dart';
import 'package:headhunter_app/src/features/profile/presentation/schema_field_widget.dart';
import 'package:headhunter_app/src/features/profile/presentation/visibility_section.dart';

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

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.state});

  final ProfileEditorState state;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  /// One key per field code, so a missing-field chip can scroll to the widget
  /// that fixes it.
  ///
  /// Held in state and reused across rebuilds: a key rebuilt each frame points
  /// at a context that has just been discarded, and `ensureVisible` then either
  /// throws or scrolls nowhere.
  final _fieldKeys = <String, GlobalKey>{};

  GlobalKey _keyFor(String code) =>
      _fieldKeys.putIfAbsent(code, GlobalKey.new);

  /// Scrolls the named field into view.
  ///
  /// Silently does nothing when the code has no widget mounted — a field can be
  /// missing *and* unrenderable, because an unknown `kind` is skipped by
  /// design. Throwing here would turn a server-side field addition into a crash
  /// on the completeness card.
  ///
  /// **This is why the form is a `SingleChildScrollView`, not a `ListView`.**
  /// A lazy list only mounts children near the viewport, so every field below
  /// the fold has a null `currentContext` and this method quietly did nothing —
  /// which is every field the user actually needs to be taken to. Found by
  /// tapping a chip on a device; the silent branch made it look like a dead
  /// button rather than a bug.
  void _revealField(String code) {
    final target = _fieldKeys[code]?.currentContext;
    if (target == null) return;

    unawaited(
      Scrollable.ensureVisible(
        target,
        duration: HhDuration.normal,
        // A little above centre, so the field is not tucked under the app bar
        // or hidden behind the save bar.
        alignment: 0.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = widget.state;

    return Column(
      children: [
        Expanded(
          // Eager, not lazy — see _revealField. The field set is bounded by the
          // category's schema (tens of fields, all cheap), so building them all
          // costs little and is what makes every one of them a valid scroll
          // target.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Completeness(state: state, onFix: _revealField),
                const SizedBox(height: HhSpace.sectionGap),

                for (final section in state.schema.sections) ...[
                  _Section(section: section, state: state, keyFor: _keyFor),
                  const SizedBox(height: HhSpace.sectionGap),
                ],

                // Not a schema field, and deliberately outside the save bar's
                // dirty set - see VisibilitySection.
                VisibilitySection(current: state.profile.visibility),
                const SizedBox(height: HhSpace.sectionGap),

                // Room for the save bar, which floats over the list.
                const SizedBox(height: HhSpace.xxl),
              ],
            ),
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
  const _Completeness({required this.state, required this.onFix});

  final ProfileEditorState state;

  /// Scrolls to the field with this code.
  final void Function(String code) onFix;

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

          // §5.3 asks for the missing fields to be listed, not merely counted.
          // Each one is a chip that scrolls to the field, because a list of
          // names the user then has to hunt for is a list that gets ignored.
          if (blocking.isNotEmpty) ...[
            const SizedBox(height: HhSpace.md),
            Wrap(
              spacing: HhSpace.sm,
              runSpacing: HhSpace.sm,
              children: [
                for (final field in blocking)
                  HhFilterChip(
                    label: _labelFor(field, l10n),
                    selected: false,
                    onTap: () => onFix(field.code),
                  ),
              ],
            ),
          ],

          if (profile.lastMeaningfulUpdateAt case final at?) ...[
            const SizedBox(height: HhSpace.md),
            Text(
              l10n.profileLastUpdated(_isoDate(at.wallClock)),
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }

  /// The schema's label for a missing code.
  ///
  /// The server sends the code and leaves the wording to the client, and the
  /// schema already carries a label resolved for the request locale — so
  /// looking it up there keeps one translation of each field name rather than
  /// two. A code with no field falls back to itself, which is ugly but
  /// truthful, and only reachable if the two responses disagree.
  String _labelFor(MissingField field, AppL10n l10n) {
    if (field.label case final label?) return label;

    for (final section in state.schema.sections) {
      for (final candidate in section.fields) {
        if (candidate.code == field.code) return candidate.label;
      }
    }

    return field.code;
  }

  /// `yyyy-MM-dd`, matching every other date this app prints.
  ///
  /// §8.3's display policy is still open; a written month invented here would
  /// have to be undone, and ISO reads the same in all four variants.
  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class _Section extends ConsumerWidget {
  const _Section({
    required this.section,
    required this.state,
    required this.keyFor,
  });

  final SchemaSection section;
  final ProfileEditorState state;

  /// The stable key for a field code, so the completeness card can scroll
  /// to it.
  final GlobalKey Function(String code) keyFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.label, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),

        if (!section.isEngine)
          // A bespoke section owns its own sub-resource and its own editor
          // (work history, education), so it is handed to one rather than run
          // through the engine — ARCHITECTURE.md §6.
          BespokeSection(section: section)
        else
          for (final field in section.renderableFields)
            Padding(
              key: keyFor(field.code),
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
