import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/upload_cancelled.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_controller.dart';
import 'package:jobbridge_app/src/features/employer/data/evidence_repository.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:jobbridge_app/src/shared/domain/attachment.dart';

/// One document verification asks for, and the control that uploads it (§6.1).
///
/// ## Why this exists at all
///
/// The card listed the required documents and marked them "Required" from the
/// day it shipped, and there was nowhere to upload one — `submit` sent an empty
/// list and relied on the server to explain the refusal. A screen that names an
/// obligation it gives you no way to meet is worse than one that says nothing.
///
/// ## The picker's filter and the size check come from the server
///
/// [policy] is `FILE_MAX_SIZE_BYTES` and the accepted extensions this
/// deployment enforces, carried on the verification state. Both are re-checked
/// here even though the server enforces them: bouncing a file locally turns a
/// minute of progress bar ending in a refusal into an instant answer.
class EvidenceSlot extends ConsumerStatefulWidget {
  const EvidenceSlot({
    required this.evidence,
    required this.files,
    required this.policy,
    super.key,
  });

  final RequiredEvidence evidence;

  /// The employer's files already uploaded against this purpose.
  final List<Attachment> files;

  final UploadPolicy policy;

  @override
  ConsumerState<EvidenceSlot> createState() => _EvidenceSlotState();
}

class _EvidenceSlotState extends ConsumerState<EvidenceSlot> {
  /// 0..1 while an upload is in flight, null otherwise.
  double? _progress;

  /// Held so Cancel has something to cancel — the widget that started the
  /// upload is the only thing that can stop it.
  CancelToken? _cancel;

  /// The last failure, in the server's words. Cleared when a retry starts.
  String? _error;

  /// What to send again on Retry, so the user does not re-pick the file.
  ({String path, String name})? _lastPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final evidence = widget.evidence;

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                // The dictionary's word for it, not the raw
                // `company_registration` (MT-012). An employer being told which
                // document to upload is the last person who should have to read
                // a column name.
                child: DictionaryCodeLabel(
                  type: DictionaryType.filePurpose,
                  code: evidence.purposeCode,
                  style: HhTypography.body,
                ),
              ),
              Text(
                evidence.required
                    ? l10n.employerEvidenceRequired
                    : l10n.employerEvidenceOptional,
                style: HhTypography.caption.copyWith(
                  color: evidence.required
                      ? HhColors.warning
                      : HhColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          if (widget.files.isEmpty && _progress == null)
            Text(
              l10n.attachmentNone,
              style: HhTypography.caption.copyWith(
                color: HhColors.inkDisabled,
              ),
            ),

          for (final file in widget.files)
            _UploadedFile(file: file, onDeleted: _refresh),

          if (_progress case final progress?) ...[
            const SizedBox(height: HhSpace.sm),
            // The themed LinearProgressIndicator, not a hand-rolled bar — see
            // MEMORY.md, one of those laid out to zero height and was invisible
            // on device while every test stayed green.
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.attachmentUploading(
                      (progress * 100).round().toString(),
                    ),
                    style: HhTypography.caption.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ),
                HhButton.text(
                  label: l10n.commonCancel,
                  onPressed: () => _cancel?.cancel(),
                ),
              ],
            ),
          ],

          if (_error case final message?) ...[
            const SizedBox(height: 4),
            Text(
              message,
              style: HhTypography.caption.copyWith(color: HhColors.error),
            ),
          ],

          if (_progress == null) ...[
            const SizedBox(height: HhSpace.sm),
            Row(
              children: [
                HhButton.secondary(
                  label: widget.files.isEmpty
                      ? l10n.attachmentUpload
                      : l10n.attachmentReplace,
                  iconPath: HhIconPath.plus,
                  compact: true,
                  // Required inside a Row: `expand` defaults to true, which
                  // sets `width: double.infinity`, and a Row gives its
                  // children unbounded width. The combination collapses the
                  // section to zero height and paints every label on one line —
                  // nothing throws in release, only on screen.
                  expand: false,
                  onPressed: _pickAndUpload,
                ),
                if (_error != null && _lastPick != null) ...[
                  const SizedBox(width: HhSpace.sm),
                  HhButton.text(
                    label: l10n.commonRetry,
                    onPressed: () => _send(_lastPick!.path, _lastPick!.name),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final l10n = AppL10n.of(context);
    final accept = widget.policy.acceptedExtensions;

    // `FileType.custom` with an empty list throws. An empty list is what an
    // API too old to serve the policy leaves, and the server still validates
    // both the type and the leading bytes, so showing everything is the right
    // degradation.
    final picked = await FilePicker.platform.pickFiles(
      type: accept.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: accept.isEmpty ? null : accept,
    );

    final file = picked?.files.singleOrNull;
    final path = file?.path;
    if (file == null || path == null) return;

    final extension = file.extension?.toLowerCase();
    if (accept.isNotEmpty &&
        (extension == null || !accept.contains(extension))) {
      setState(() => _error = l10n.attachmentWrongType(accept.join(', ')));
      return;
    }
    if (widget.policy.maxSizeBytes > 0 &&
        file.size > widget.policy.maxSizeBytes) {
      final limit = (widget.policy.maxSizeBytes / (1024 * 1024))
          .toStringAsFixed(0);
      setState(() => _error = l10n.attachmentTooLarge(limit));
      return;
    }

    _lastPick = (path: path, name: file.name);
    await _send(path, file.name);
  }

  Future<void> _send(String path, String name) async {
    final cancel = CancelToken();
    setState(() {
      _error = null;
      _progress = 0;
      _cancel = cancel;
    });

    try {
      await ref
          .read(evidenceRepositoryProvider)
          .upload(
            purposeCode: widget.evidence.purposeCode,
            filePath: path,
            fileName: name,
            cancelToken: cancel,
            onProgress: (sent, total) {
              if (!mounted || total <= 0) return;
              setState(() => _progress = sent / total);
            },
          );

      _lastPick = null;
      await _refresh();
    } on UploadCancelled {
      // Nothing to report: the user did this on purpose.
    } on ApiException catch (e) {
      // The server's words — whichever of size, type or content-mismatch it
      // refused on. Local to this slot, never the page's error state, whose
      // heading claims the whole screen failed (MT-013).
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() {
          _progress = null;
          _cancel = null;
        });
      }
    }
  }

  /// Re-reads the file list and the verification state.
  ///
  /// The second one because the submit button's enabled state is derived from
  /// what has been uploaded, and an employer who has just supplied the last
  /// required document should not have to leave the screen to find that out.
  Future<void> _refresh() async {
    ref
      ..invalidate(evidenceFilesProvider)
      ..invalidate(verificationProvider);
  }
}

/// A file already uploaded against this purpose, and the control that drops it.
class _UploadedFile extends ConsumerWidget {
  const _UploadedFile({required this.file, required this.onDeleted});

  final Attachment file;
  final Future<void> Function() onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Row(
      children: [
        const HhIcon(
          HhIconPath.document,
          size: 16,
          color: HhColors.inkMuted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            file.fileName,
            style: HhTypography.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => _confirmAndDelete(context, ref, l10n),
          constraints: const BoxConstraints(
            minWidth: HhSize.minTarget,
            minHeight: HhSize.minTarget,
          ),
          // Icon-only, so it says what it removes rather than "button" — a row
          // of three identical delete buttons is unusable otherwise (MT-015).
          tooltip: l10n.commonDelete,
          icon: const HhIcon(
            HhIconPath.close,
            size: 16,
            color: HhColors.inkMuted,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.attachmentDeleteTitle),
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
    if (!(confirmed ?? false)) return;

    await ref.read(evidenceRepositoryProvider).remove(file.id);
    await onDeleted();
  }
}
