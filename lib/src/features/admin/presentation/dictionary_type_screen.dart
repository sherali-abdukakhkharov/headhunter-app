import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/dictionary_draft.dart';
import 'package:jobbridge_app/src/features/admin/presentation/dictionary_admin_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';

/// One dictionary type's items (§10.3, BR-13).
///
/// ## Nothing is ever deleted, so the list shows everything
///
/// It reads `dictionaryProvider`, which is the **unfiltered** set — active,
/// retired and merged alike — rather than the picker's `selectableDictionary`.
/// That is the whole point of the screen: an administrator's questions are
/// "what is in use", "what did we retire" and "what did we merge into what",
/// and a list that answered only the first would hide the two that matter for
/// tidying up.
///
/// ## A write is a delta, not a reload
///
/// Every dictionary write bumps the global revision through a database
/// trigger, so invalidating the provider re-reads with `since=` and merges the
/// delta the client already knows how to apply. There is no admin read route
/// and none is needed.
///
/// ## Labels can be written here and not rewritten
///
/// Creating an item collects all four (§3.2), because nothing is being read.
/// Editing an existing item's labels is missing on purpose: the only read is
/// resolved through §3.2's fallback chain, so an item with no Russian label
/// reads back with its Uzbek one and the client cannot tell the two apart —
/// saving that would write a fallback into the database as a translation. The
/// ask is in docs/BACKEND_ASKS.md and this screen says so rather than offering
/// a field that would quietly do the wrong thing.
class DictionaryTypeScreen extends ConsumerStatefulWidget {
  const DictionaryTypeScreen({required this.type, super.key});

  final String type;

  @override
  ConsumerState<DictionaryTypeScreen> createState() =>
      _DictionaryTypeScreenState();
}

class _DictionaryTypeScreenState extends ConsumerState<DictionaryTypeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = ref.watch(dictionaryProvider(widget.type));
    final query = _search.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(dictionaryTypeLabel(widget.type, l10n)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HhTextField(
                  label: l10n.adminDictionarySearch,
                  controller: _search,
                  hintText: l10n.adminDictionarySearchHint,
                  trailingIconPath: HhIconPath.search,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: HhSpace.md),
                HhButton.secondary(
                  label: l10n.adminDictionaryAdd,
                  iconPath: HhIconPath.plus,
                  onPressed: () => _add(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: switch (items) {
              AsyncValue(hasError: true, :final error?) => Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () =>
                      ref.invalidate(dictionaryProvider(widget.type)),
                ),
              ),
              AsyncData(:final value) => _List(
                type: widget.type,
                items: [
                  for (final item in value)
                    // Code as well as label: an administrator hunting a
                    // duplicate often has the code, and the label they are
                    // looking at may be in a language they cannot type.
                    if (query.isEmpty ||
                        item.label.toLowerCase().contains(query) ||
                        item.code.toLowerCase().contains(query))
                      item,
                ],
                query: query,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final created = await showDictionaryItemForm(context, type: widget.type);
    if (created ?? false) {
      // The write bumped the global revision; this re-reads as a delta.
      ref.invalidate(dictionaryProvider(widget.type));
    }
  }
}

class _List extends StatelessWidget {
  const _List({required this.type, required this.items, required this.query});

  final String type;
  final List<DictionaryItem> items;
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhEmptyState(
          title: query.isEmpty
              ? l10n.adminDictionaryEmpty
              : l10n.adminDictionaryNoMatch,
          message: query.isEmpty
              ? l10n.adminDictionaryEmptyBody
              : l10n.adminDictionaryNoMatchBody,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        HhSpace.gutter,
        0,
        HhSpace.gutter,
        HhSpace.gutter,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: HhSpace.sm),
        child: _ItemRow(type: type, item: items[index]),
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({required this.type, required this.item});

  final String type;
  final DictionaryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () => _open(context, ref),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: HhTypography.body),
                const SizedBox(height: 2),
                Text(
                  item.code,
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkSubtle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: HhSpace.sm),
          // Three states, and each is a different fact: in use, retired, or
          // merged away into something else. Only the first is a picker's
          // business; the other two are why a historical record still reads.
          if (item.mergedIntoId != null)
            HhMetaChip(
              label: l10n.adminDictionaryMerged,
              iconPath: HhIconPath.refresh,
            )
          else if (!item.isActive)
            HhMetaChip(
              label: l10n.adminDictionaryRetired,
              iconPath: HhIconPath.eye,
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final changed = await showDictionaryItemActions(
      context,
      type: type,
      item: item,
    );
    if (changed ?? false) ref.invalidate(dictionaryProvider(type));
  }
}

/// What can be done to one item (§10.3).
///
/// Returns true when something changed, so the caller re-reads.
Future<bool?> showDictionaryItemActions(
  BuildContext context, {
  required String type,
  required DictionaryItem item,
}) => showHhSheet<bool>(
  context,
  builder: (_) => _ActionsSheet(type: type, item: item),
);

class _ActionsSheet extends ConsumerStatefulWidget {
  const _ActionsSheet({required this.type, required this.item});

  final String type;
  final DictionaryItem item;

  @override
  ConsumerState<_ActionsSheet> createState() => _ActionsSheetState();
}

class _ActionsSheetState extends ConsumerState<_ActionsSheet> {
  bool _busy = false;
  String? _refusal;
  String? _survivorId;

  DictionaryItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final merged = item.mergedIntoId != null;

    return _Sheet(
      children: [
        Text(item.label, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.xs),
        Text(item.code, style: HhTypography.caption),

        if (merged) ...[
          const SizedBox(height: HhSpace.lg),
          // A merged item is finished. Offering to activate one would put a
          // duplicate back into the pickers it was merged out of.
          HhNotice(
            title: l10n.adminDictionaryMerged,
            message: l10n.adminDictionaryMergedBody,
            iconPath: HhIconPath.infoCircle,
          ),
        ] else ...[
          const SizedBox(height: HhSpace.lg),
          HhButton.secondary(
            label: item.isActive
                ? l10n.adminDictionaryRetire
                : l10n.adminDictionaryActivate,
            loading: _busy,
            onPressed: _busy ? null : _toggleActive,
          ),

          const SizedBox(height: HhSpace.sectionGap),
          Text(l10n.adminDictionaryMerge, style: HhTypography.label),
          const SizedBox(height: HhSpace.xs),
          Text(
            // Said before the picker, because the direction is the one thing
            // about a merge somebody can get backwards, and it cannot be
            // undone from this app.
            l10n.adminDictionaryMergeBody,
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
          const SizedBox(height: HhSpace.md),
          HhDictionaryPicker(
            label: l10n.adminDictionaryMergeInto,
            type: widget.type,
            value: _survivorId,
            enabled: !_busy,
            onChanged: (id) => setState(() => _survivorId = id),
          ),
          const SizedBox(height: HhSpace.md),
          HhButton.destructive(
            label: l10n.adminDictionaryMergeConfirm,
            loading: _busy,
            onPressed: _busy || _survivorId == null ? null : _merge,
          ),
        ],

        if (_refusal case final refusal?) ...[
          const SizedBox(height: HhSpace.md),
          HhNotice.restricted(title: l10n.stateErrorTitle, message: refusal),
        ],

        const SizedBox(height: HhSpace.lg),
        HhButton.text(
          label: l10n.commonBack,
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Future<void> _toggleActive() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    try {
      await ref
          .read(adminRepositoryProvider)
          .setDictionaryItemActive(item.id, isActive: !item.isActive);
      if (mounted) Navigator.of(context).pop(true);
    } on AdminDecisionConflict {
      // `dictionary.state_unchanged`: somebody else already did it, and the
      // work is done. The list re-reads either way.
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        // 422 is the database refusing to activate an item that is missing
        // one of §3.2's four labels — a translation still to be written, not
        // a fault. Said in those words rather than as a server error.
        _refusal = e.statusCode == 422
            ? AppL10n.of(context).adminDictionaryLabelsMissing
            : e.message;
        _busy = false;
      });
    }
  }

  Future<void> _merge() async {
    final survivor = _survivorId;
    if (survivor == null) return;

    setState(() {
      _busy = true;
      _refusal = null;
    });

    try {
      await ref
          .read(adminRepositoryProvider)
          .mergeDictionaryItems(item.id, survivor);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      // Three refusals, all the administrator's to read: merging into itself,
      // a type mismatch, and a survivor that was itself merged away. The
      // server's own sentence says which.
      setState(() {
        _refusal = e.message;
        _busy = false;
      });
    }
  }
}

/// §10.3's new item, with all four labels.
///
/// Returns true when one was created.
Future<bool?> showDictionaryItemForm(
  BuildContext context, {
  required String type,
}) => showHhSheet<bool>(
  context,
  builder: (_) => _ItemForm(type: type),
);

class _ItemForm extends ConsumerStatefulWidget {
  const _ItemForm({required this.type});

  final String type;

  @override
  ConsumerState<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends ConsumerState<_ItemForm> {
  final _code = TextEditingController();
  final Map<AppLocale, TextEditingController> _labels = {
    for (final locale in AppLocale.values) locale: TextEditingController(),
  };

  bool _busy = false;
  String? _refusal;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
    for (final controller in _labels.values) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _code.dispose();
    for (final controller in _labels.values) {
      controller.dispose();
    }
    super.dispose();
  }

  NewDictionaryItem get _draft => NewDictionaryItem(
    code: _code.text.trim(),
    labels: {
      for (final entry in _labels.entries) entry.key.tag: entry.value.text,
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final draft = _draft;
    // The server's own minimum, so the field stops where the API would have
    // refused rather than after it.
    final codeIsUsable = draft.code.length >= 2;

    return _Sheet(
      children: [
        Text(l10n.adminDictionaryAdd, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.xs),
        Text(
          dictionaryTypeLabel(widget.type, l10n),
          style: HhTypography.caption,
        ),

        const SizedBox(height: HhSpace.lg),
        HhTextField(
          label: l10n.adminDictionaryCode,
          controller: _code,
          hintText: l10n.adminDictionaryCodeHint,
          enabled: !_busy,
        ),
        const SizedBox(height: HhSpace.xs),
        Text(
          // BR-13: the code is what everything stores, so it must outlive
          // every label. Saying so is what stops somebody typing a name here.
          l10n.adminDictionaryCodeNote,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),

        const SizedBox(height: HhSpace.lg),
        Text(l10n.adminDictionaryLabels, style: HhTypography.label),
        const SizedBox(height: HhSpace.xs),
        Text(
          l10n.adminDictionaryLabelsNote,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),
        for (final locale in AppLocale.values) ...[
          HhTextField(
            label: locale.nativeName,
            controller: _labels[locale],
            enabled: !_busy,
          ),
          const SizedBox(height: HhSpace.md),
        ],

        if (draft.missingLocales.isNotEmpty)
          Text(
            // Not an error: a partial set is a legitimate draft, and §3.2
            // stops it reaching a picker by refusing to activate it. What
            // would be wrong is letting somebody believe it is finished.
            l10n.adminDictionaryDraftNote(draft.missingLocales.length),
            style: HhTypography.caption.copyWith(color: HhColors.warningFg),
          ),

        if (_refusal case final refusal?) ...[
          const SizedBox(height: HhSpace.md),
          HhNotice.restricted(title: l10n.stateErrorTitle, message: refusal),
        ],

        const SizedBox(height: HhSpace.lg),
        HhButton(
          label: l10n.adminDictionaryCreate,
          loading: _busy,
          onPressed: _busy || !codeIsUsable ? null : _create,
        ),
        const SizedBox(height: HhSpace.sm),
        HhButton.text(
          label: l10n.commonCancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    try {
      await ref
          .read(adminRepositoryProvider)
          .createDictionaryItem(widget.type, _draft);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      // `dictionary.code_taken` is the one worth reading: it means the item
      // already exists, and the answer is to merge rather than to add again.
      setState(() {
        _refusal = e.message;
        _busy = false;
      });
    }
  }
}

/// The bottom-sheet chrome both of §10.3's sheets sit in.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: HhColors.white,
      borderRadius: HhRadius.sheetTop,
    ),
    child: SafeArea(
      child: Padding(
        // Lifts the sheet clear of the keyboard, which every field here
        // raises.
        padding: EdgeInsets.only(
          left: HhSpace.gutter,
          right: HhSpace.gutter,
          top: HhSpace.gutter,
          bottom: HhSpace.gutter + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}
