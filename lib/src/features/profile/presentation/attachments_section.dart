import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/upload_cancelled.dart';
import 'package:jobbridge_app/src/features/profile/data/attachments_repository.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/shared/domain/attachment.dart';

/// The profile's files (§5.4, UAT-03) — one slot per schema-declared purpose.
///
/// **The slots come from the schema, not from here.** CV, photo, certificates
/// and supporting documents are `schema.attachments`, each with its own
/// accepted extensions, size limit and `maxCount`. A category that declares a
/// fifth purpose gets a fifth slot with no client change, which is the same
/// bargain the field engine makes.
class AttachmentsSection extends ConsumerWidget {
  const AttachmentsSection({required this.slots, super.key});

  final List<SchemaAttachment> slots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    if (slots.isEmpty) return const SizedBox.shrink();

    final files = ref.watch(attachmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.attachmentsTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),

        switch (files) {
          // hasError first: with retry disabled a failure is terminal, and
          // matching loading first spins over it forever.
          AsyncValue(hasError: true, :final error?) => HhErrorState(
            title: l10n.stateErrorTitle,
            message: error is ApiException
                ? error.message
                : l10n.stateErrorBody,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(attachmentsProvider),
          ),
          AsyncData(:final value) => Column(
            children: [
              for (final slot in slots)
                Padding(
                  padding: const EdgeInsets.only(bottom: HhSpace.lg),
                  child: _Slot(
                    slot: slot,
                    files: value
                        .where((f) => f.purposeCode == slot.code)
                        .toList(),
                  ),
                ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

/// One purpose: its files, and the control that adds another.
class _Slot extends ConsumerStatefulWidget {
  const _Slot({required this.slot, required this.files});

  final SchemaAttachment slot;
  final List<Attachment> files;

  @override
  ConsumerState<_Slot> createState() => _SlotState();
}

class _SlotState extends ConsumerState<_Slot> {
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
    final slot = widget.slot;
    final full = widget.files.length >= slot.maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          slot.required ? '${slot.label} *' : slot.label,
          style: HhTypography.label.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.sm),

        if (widget.files.isEmpty && _progress == null)
          Text(
            l10n.attachmentNone,
            style: HhTypography.body.copyWith(color: HhColors.inkDisabled),
          ),

        for (final file in widget.files)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: _FileRow(file: file, onDeleted: _refresh),
          ),

        if (_progress case final progress?) ...[
          const SizedBox(height: HhSpace.sm),
          // The themed LinearProgressIndicator, not a hand-rolled bar — see
          // MEMORY.md, one of those laid out to zero height and was invisible
          // on device while every test stayed green.
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.attachmentUploading((progress * 100).round().toString()),
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
              ),
              HhButton.text(label: l10n.commonCancel, onPressed: _cancelUpload),
            ],
          ),
        ],

        if (_error case final message?) ...[
          const SizedBox(height: 6),
          Text(
            message,
            style: HhTypography.caption.copyWith(color: HhColors.error),
          ),
        ],

        const SizedBox(height: HhSpace.sm),
        if (_progress == null)
          Row(
            children: [
              HhButton.secondary(
                // §5.4's "replace" on a one-file slot: the server retires the
                // oldest of the purpose, so the button says what happens.
                label: full
                    ? l10n.attachmentReplace
                    : l10n.attachmentUpload,
                iconPath: HhIconPath.plus,
                compact: true,
                // Required inside a Row. `expand` defaults to true, which sets
                // `width: double.infinity`, and a Row gives its children
                // unbounded width — the combination collapses the whole
                // section to zero height and paints every label on one line.
                // Nothing throws in release; it is only visible on screen.
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
    );
  }

  Future<void> _pickAndUpload() async {
    final l10n = AppL10n.of(context);
    final slot = widget.slot;

    final picked = await FilePicker.platform.pickFiles(
      // The schema's list, never a hardcoded one — a category can accept a
      // different set and the picker has to follow it.
      type: FileType.custom,
      allowedExtensions: slot.accept,
    );

    final file = picked?.files.singleOrNull;
    final path = file?.path;
    if (file == null || path == null) return;

    // Both limits are re-checked here even though the server enforces them.
    // Bouncing a file locally saves uploading something that cannot land, and
    // on a slow connection that is the difference between an instant "too
    // large" and a minute of progress bar ending in a refusal.
    final extension = file.extension?.toLowerCase();
    if (extension == null || !slot.accept.contains(extension)) {
      setState(() => _error = l10n.attachmentWrongType(slot.accept.join(', ')));
      return;
    }
    if (slot.maxSizeBytes > 0 && file.size > slot.maxSizeBytes) {
      final limit = (slot.maxSizeBytes / (1024 * 1024)).toStringAsFixed(0);
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
          .read(attachmentsRepositoryProvider)
          .upload(
            purposeCode: widget.slot.code,
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
      // The server's words, not ours — UAT-03 asks for the reason, and the
      // reason is whichever of size, type or content-mismatch it refused on.
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

  void _cancelUpload() => _cancel?.cancel();

  /// Re-reads the file list and the profile.
  ///
  /// The second one because a required attachment counts toward completeness
  /// (§5.3), so the ring is stale the moment a CV lands. Same reasoning — and
  /// the same non-invalidating call — as the bespoke sections.
  Future<void> _refresh() async {
    ref.invalidate(attachmentsProvider);
    await ref.read(profileEditorProvider.notifier).refreshProfile();
  }
}

class _FileRow extends ConsumerWidget {
  const _FileRow({required this.file, required this.onDeleted});

  final Attachment file;
  final Future<void> Function() onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.fileName, style: HhTypography.body),
                const SizedBox(height: 2),
                Text(
                  _size(file.sizeBytes),
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
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

              await ref.read(attachmentsRepositoryProvider).remove(file.id);
              await onDeleted();
            },
            constraints: const BoxConstraints(
              minWidth: HhSize.minTarget,
              minHeight: HhSize.minTarget,
            ),
            icon: const HhIcon(
              HhIconPath.close,
              size: 18,
              color: HhColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Bytes as B, KB or MB. Not localized: §8.3's display policy is open, and a
  /// digit-and-unit reads the same in all four variants.
  ///
  /// The bytes case is not pedantry — rounding to KB prints "0 KB" for anything
  /// under half a kilobyte, and a file that uploaded successfully must never be
  /// described as empty.
  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
