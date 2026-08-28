import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/account/presentation/account_entry_row.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/domain/candidate_profile.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/history_section.dart';
import 'package:jobbridge_app/src/features/profile/presentation/schema_field_widget.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
      // Above the switch, so the screen has a name and a way to its account
      // settings while it is still loading and if it fails. A header inside the
      // `AsyncData` arm would be a header that disappears exactly when the user
      // most needs the way out.
            HhScreenHeader(
              title: l10n.navProfile,
              action: const AccountEntryAction(),
            ),
            Expanded(child: _body(context, ref, l10n, editor)),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
    AsyncValue<ProfileEditorState> editor,
  ) {
    return switch (editor) {
          // hasError first: Riverpod's retry leaves a failing provider in an
          // AsyncLoading that merely carries the error, so matching loading
          // first shows a spinner over a failure forever.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: failureTitle(error, l10n),
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(profileEditorProvider),
            ),
          ),
      AsyncData(:final value) => _Form(state: value),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// The hub: what is left to do, then one row per part of the profile.
///
/// **Not a form.** It was one — a completeness card, eight to ten schema
/// sections, the attachment slots and the visibility switch on a single scroll,
/// twenty-six fields plus two repeating lists — and the 1.29.0 audit called it
/// monolithic. Length was the smaller half of that: on a page where everything
/// looks alike, *what is still missing* is invisible, and the rows carry it
/// here instead.
///
/// The rows are the schema's sections **in the schema's order**, and they are
/// deliberately not grouped under invented headings. Which sections exist
/// depends on the work category and an administrator can add one at runtime
/// (§5.2, §10.3), so a client-side table saying which group a section belongs
/// to would be wrong the first time one is added — and the new section would
/// land in whatever bucket the code called "other". The server's order already
/// reads as a sequence; it is the server's to change.
class _Form extends ConsumerWidget {
  const _Form({required this.state});

  final ProfileEditorState state;

  /// Opens the page holding [code], for the completeness card's chips.
  ///
  /// This used to scroll: every field was mounted on one eager
  /// `SingleChildScrollView` — a lazy list would not have worked, because a
  /// field below the fold has no context to scroll to — and the chip called
  /// `ensureVisible`. Now it navigates, which is both simpler and better: a
  /// chip that opens the page containing the field leaves the user somewhere
  /// they can see the whole of, rather than part-way down a form.
  ///
  /// A code the schema does not place stays silent, exactly as the scroll did.
  /// A field can be missing *and* unrenderable — an unknown `kind` is skipped
  /// by design — and turning a server-side field addition into a dead end is
  /// better than turning it into a crash.
  void _openFieldSection(BuildContext context, String code) {
    for (final section in state.schema.sections) {
      if (section.fields.any((f) => f.code == code)) {
        context.go(Routes.candidateProfileSection(section.code));

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final missing = {for (final f in state.profile.missingFields) f.code};

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        _Completeness(
          state: state,
          onFix: (code) => _openFieldSection(context, code),
        ),
        const SizedBox(height: HhSpace.sectionGap),

        for (final section in state.schema.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: _SectionRow(
              label: section.label,
              // What is left, not what is there: a row that says "5 fields"
              // tells a finished user something they do not need and an
              // unfinished one nothing they can act on.
              note: _remaining(section, missing, l10n),
              unsaved: state.isDirtyIn({
                for (final f in section.fields) f.code,
              }),
              onTap: () =>
                  context.go(Routes.candidateProfileSection(section.code)),
            ),
          ),

        const SizedBox(height: HhSpace.md),

        // Files are declared by the schema's own block, outside the field union
        // entirely (§4.5), and visibility is its own endpoint (§5.3). Both are
        // parts of the profile and neither is a section, so they sit below the
        // schema's rows rather than among them.
        Padding(
          padding: const EdgeInsets.only(bottom: HhSpace.sm),
          child: _SectionRow(
            label: l10n.attachmentsTitle,
            onTap: () => context.go(Routes.candidateProfileFiles),
          ),
        ),
        _SectionRow(
          label: l10n.profileVisibilityTitle,
          note: state.profile.visibility == 'searchable'
              ? l10n.profileVisibilitySearchable
              : l10n.profileVisibilityHidden,
          onTap: () => context.go(Routes.candidateProfileVisibility),
        ),
      ],
    );
  }

  /// "n left", or null when this section is answered.
  ///
  /// Counted from the server's own `missingFields` rather than from the values
  /// on screen: completeness is §5.3's computation and the client re-deriving
  /// it would be a second implementation of the rule that decides who is
  /// searchable.
  String? _remaining(
    SchemaSection section,
    Set<String> missing,
    AppL10n l10n,
  ) {
    final count = section.fields.where((f) => missing.contains(f.code)).length;

    return count == 0 ? null : l10n.profileSectionRemaining(count);
  }
}

/// One row of the hub: what it is, what is left in it, and a chevron.
class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.label,
    required this.onTap,
    this.note,
    this.unsaved = false,
  });

  final String label;

  /// What is still owed here, or the current setting. Null when there is
  /// nothing to say — which is itself the signal that this part is done.
  final String? note;

  /// Whether this section holds an edit that has not been saved.
  ///
  /// Each page saves only its own fields, so leaving one half-finished is a
  /// thing a user can now do without noticing. The row says so.
  final bool unsaved;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: HhTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (note case final note?) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: HhTypography.caption.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ],
                if (unsaved) ...[
                  const SizedBox(height: HhSpace.xs),
                  // A badge, not a coloured dot: the design's rule is that a
                  // state is an icon **and** a word, and "there is something
                  // unsaved in here" is exactly the state a colour alone would
                  // fail to convey.
                  HhBadge(
                    label: l10n.profileSectionUnsaved,
                    tone: HhTone.warning,
                    iconPath: HhIconPath.edit,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: HhSpace.sm),
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkDisabled,
          ),
        ],
      ),
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

/// One schema section's fields, with no chrome of its own.
///
/// Public because the section *pages* render it — see
/// `profile_section_screen.dart`. It draws no heading: the page it sits on
/// already names itself, and two titles for one thing is how a hub and its
/// pages start disagreeing.
class ProfileSectionFields extends ConsumerWidget {
  const ProfileSectionFields({
    required this.section,
    required this.state,
    super.key,
  });

  final SchemaSection section;
  final ProfileEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!section.isEngine)
          // A bespoke section owns its own sub-resource and its own editor
          // (work history, education), so it is handed to one rather than run
          // through the engine — ARCHITECTURE.md §6.
          BespokeSection(section: section)
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

/// The floating Save, shared by every section page.
class ProfileSaveBar extends StatelessWidget {
  const ProfileSaveBar({
    required this.saving,
    required this.onSave,
    super.key,
  });

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
