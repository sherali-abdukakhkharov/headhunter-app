import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/data/employer_applications_repository.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';

/// Opens the employer's private notes on one application (§7.3).
Future<void> showApplicationNotes(
  BuildContext context, {
  required String applicationId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: HhColors.white,
  shape: const RoundedRectangleBorder(borderRadius: HhRadius.sheetTop),
  builder: (_) => ApplicationNotesSheet(applicationId: applicationId),
);

/// §7.3's private employer note, on an application.
///
/// ## Private is the whole point, and it is said on screen
///
/// "Saved candidates can be attached to a vacancy-specific shortlist and
/// receive a private employer note." A recruiter writing "asked for 8m, may
/// take 6.5" has to know for certain the candidate will not read it, or they
/// write nothing useful — so the sheet states it rather than leaving it to be
/// inferred from the word "note".
///
/// ## Append-only, deliberately
///
/// The API offers `GET` and `POST` and no edit or delete, and the sheet does
/// not pretend otherwise. A note is a dated observation rather than a field:
/// "may take 6.5" written in March and silently rewritten in June is worse than
/// two notes, because the first one is what the employer acted on.
class ApplicationNotesSheet extends ConsumerStatefulWidget {
  const ApplicationNotesSheet({required this.applicationId, super.key});

  final String applicationId;

  @override
  ConsumerState<ApplicationNotesSheet> createState() =>
      _ApplicationNotesSheetState();
}

class _ApplicationNotesSheetState
    extends ConsumerState<ApplicationNotesSheet> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final notes = ref.watch(applicationNotesProvider(widget.applicationId));

    return Padding(
      // The sheet holds a text field, so it has to rise with the keyboard or
      // the thing being typed into sits behind it.
      padding: EdgeInsets.only(
        left: HhSpace.gutter,
        right: HhSpace.gutter,
        top: HhSpace.gutter,
        bottom: MediaQuery.viewInsetsOf(context).bottom + HhSpace.gutter,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.notesTitle, style: HhTypography.subtitle),
          const SizedBox(height: HhSpace.xs),
          Text(
            l10n.notesHint,
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
          const SizedBox(height: HhSpace.md),

          Flexible(
            child: switch (notes) {
              // Error before any loading arm: retry is off app-wide, so a
              // failure is terminal.
              AsyncValue(hasError: true, :final error?) => HhErrorState(
                title: l10n.stateErrorTitle,
                message: error is ApiException
                    ? error.message
                    : l10n.stateErrorBody,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(
                  applicationNotesProvider(widget.applicationId),
                ),
              ),
              AsyncData(:final value) when value.isEmpty => Text(
                l10n.notesEmpty,
                style: HhTypography.body.copyWith(color: HhColors.inkMuted),
              ),
              AsyncData(:final value) => ListView.builder(
                shrinkWrap: true,
                itemCount: value.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: HhSpace.sm),
                  child: _NoteRow(note: value[index]),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),

          const SizedBox(height: HhSpace.md),
          HhTextField(
            label: l10n.notesNewLabel,
            hintText: l10n.notesNewHint,
            controller: _controller,
            maxLines: 3,
            enabled: !_saving,
          ),
          const SizedBox(height: HhSpace.md),
          HhButton(
            label: l10n.notesAdd,
            loading: _saving,
            onPressed: _saving ? null : _add,
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final text = _controller.text.trim();
    // An empty note is not a note. Trimmed first, so a field holding only
    // spaces does not become one either.
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    try {
      await ref
          .read(employerApplicationsRepositoryProvider)
          .addNote(widget.applicationId, text);

      _controller.clear();
      ref.invalidate(applicationNotesProvider(widget.applicationId));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// One note, and when it was written.
class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note});

  final ApplicationNote note;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(HhSpace.md),
    decoration: const BoxDecoration(
      color: HhColors.surfaceMuted,
      borderRadius: HhRadius.inputAll,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The date, and only the date. `createdAt` is a plain string on this
        // DTO rather than an offset-carrying timestamp, so there is nothing
        // here to render a time from honestly — and the first ten characters of
        // an ISO string are the date in any zone the server might have used.
        Text(
          note.createdAt.length >= 10
              ? note.createdAt.substring(0, 10)
              : note.createdAt,
          style: HhTypography.overline.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: 2),
        // The employer's own words (§2.4), never trimmed to a preview.
        Text(note.note, style: HhTypography.body),
      ],
    ),
  );
}
