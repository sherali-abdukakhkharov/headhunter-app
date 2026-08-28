import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/attachments_section.dart';
import 'package:jobbridge_app/src/features/profile/presentation/candidate_profile_screen.dart';
import 'package:jobbridge_app/src/features/profile/presentation/visibility_section.dart';

/// One section of §5's profile, on its own page.
///
/// ## Why the profile is a hub and not a form
///
/// It was one scroll: a completeness card, eight to ten schema sections, the
/// attachment slots and the visibility switch — twenty-six fields plus two
/// repeating lists, four to six screens before anybody starts typing. The
/// 1.29.0 audit called it monolithic, and the cost was not only the scrolling:
/// what is *left to do* is invisible when everything looks the same, and the
/// controls people go to a profile for were furthest from the top.
///
/// ## The section is addressed by its schema code
///
/// Not by an index and not by a route per section. Which sections exist is the
/// server's answer — §5.2 makes the form depend on the work category, §10.3
/// lets an administrator add one at runtime, and a section whose fields do not
/// apply to the category is dropped from the response entirely. So this screen
/// looks the code up in the schema it was handed, and **a code that is not
/// there sends the user back to the hub** rather than drawing an empty page:
/// that is what a stale deep link or a category change looks like, and neither
/// is an error.
class ProfileSectionScreen extends ConsumerWidget {
  const ProfileSectionScreen({required this.sectionCode, super.key});

  final String sectionCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final editor = ref.watch(profileEditorProvider);

    return switch (editor) {
      // hasError first: retry is disabled app-wide, so a failure is terminal
      // and matching the loading arm first would spin over it forever.
      AsyncValue(hasError: true, :final error?) => _Page(
        title: l10n.navProfile,
        child: Padding(
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
      ),
      AsyncData(:final value) => _resolve(context, value, l10n),
      _ => _Page(
        title: l10n.navProfile,
        child: const Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _resolve(
    BuildContext context,
    ProfileEditorState state,
    AppL10n l10n,
  ) {
    final section = state.schema.sections
        .where((s) => s.code == sectionCode)
        .firstOrNull;

    if (section == null) {
      // Said rather than redirected. Navigating out of a `build` would need a
      // post-frame callback re-entering the router, and it would leave a cold
      // deep link — the case this exists for — showing a spinner on the way to
      // somewhere it did not ask for. The page above carries a way back.
      return _Page(
        title: l10n.navProfile,
        child: Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: HhEmptyState(
            title: l10n.stateEmptyTitle,
            message: l10n.profileSectionGone,
          ),
        ),
      );
    }

    return _SectionForm(section: section, state: state);
  }
}

/// The attachment slots (§4.5), which the schema declares outside its field
/// union and which therefore save themselves as they are uploaded.
///
/// No save bar: an upload is the write. A bar that appeared here would be a
/// button with nothing to do.
class ProfileFilesScreen extends ConsumerWidget {
  const ProfileFilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final editor = ref.watch(profileEditorProvider);

    return _Page(
      title: l10n.attachmentsTitle,
      child: switch (editor) {
        AsyncData(:final value) => SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: AttachmentsSection(slots: value.schema.attachments),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// BR-02's switch, which is its own endpoint and its own page.
///
/// Deliberately **not** part of the section save. `PUT /candidates/me/
/// visibility` exists separately because it must not refresh
/// `lastMeaningfulUpdateAt` (§5.3) — a privacy toggle cannot be used to make a
/// stale profile look maintained — so it writes on change, like the uploads.
class ProfileVisibilityScreen extends ConsumerWidget {
  const ProfileVisibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final editor = ref.watch(profileEditorProvider);

    return _Page(
      title: l10n.profileVisibilityTitle,
      child: switch (editor) {
        AsyncData(:final value) => SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: VisibilitySection(current: value.profile.visibility),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// The chrome every page here shares: a heading, a back action, a safe area.
class _Page extends StatelessWidget {
  const _Page({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HhScreenHeader(
            title: title,
            // The system back gesture does this too. The control exists for
            // the reach: these pages are opened from a list at the top of the
            // screen, and the thumb that opened one is nowhere near the edge.
            // `maybePop`, not `context.go`: the section pages are routes on
            // the profile tab's own navigator, so popping is what returns to
            // the hub — and it is also what the system back gesture does, so
            // the two cannot disagree.
            action: HhButton.text(
              label: AppL10n.of(context).commonBack,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

/// One schema section's fields, and a save bar that writes only them.
class _SectionForm extends ConsumerStatefulWidget {
  const _SectionForm({required this.section, required this.state});

  final SchemaSection section;
  final ProfileEditorState state;

  @override
  ConsumerState<_SectionForm> createState() => _SectionFormState();
}

class _SectionFormState extends ConsumerState<_SectionForm> {
  /// The field codes this page owns, and therefore the only ones it saves.
  ///
  /// Read from the section rather than from the edits: a page saves what it
  /// *shows*, so a field that was edited here and is no longer in the schema —
  /// a category change between load and save — is not silently sent by a page
  /// that no longer displays it.
  Set<String> get _codes => {for (final f in widget.section.fields) f.code};

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = widget.state;

    return _Page(
      title: widget.section.label,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(HhSpace.gutter),
              child: ProfileSectionFields(
                section: widget.section,
                state: state,
              ),
            ),
          ),

          if (state.isDirtyIn(_codes))
            ProfileSaveBar(
              saving: state.isSaving,
              onSave: () async {
                // Both resolved before the await: this widget can be rebuilt or
                // disposed while the write is in flight, and reaching for
                // `context` afterwards is how that becomes a crash only on a
                // slow connection.
                final messenger = ScaffoldMessenger.of(context);
                final savedMessage = l10n.profileSaved;

                try {
                  final ok = await ref
                      .read(profileEditorProvider.notifier)
                      .save(only: _codes);

                  if (ok) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(savedMessage)),
                    );
                  }
                } on ApiException catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text(e.message)));
                } on Object {
                  // A field-level rejection is rendered on the fields
                  // themselves; a snack bar repeating it would say the same
                  // thing twice, in the place that cannot be acted on.
                }
              },
            ),
        ],
      ),
    );
  }
}
