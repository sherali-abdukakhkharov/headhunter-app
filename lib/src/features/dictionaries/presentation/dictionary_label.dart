import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_picker.dart';

/// Renders the label for a bound dictionary id — read-only (§3.3, BR-13).
///
/// The pickers resolve their own value because they own it. Anything that only
/// *displays* a stored id — a record card, a search result, a summary row —
/// needs the same resolution without the picker around it, and that is this.
///
/// Retired and merged ids resolve too, so a record created before an
/// administrator retired an item still reads as words rather than a UUID
/// (§10.3). Failure and absence both render through [resolveLabel], so this
/// cannot show an ellipsis that never resolves.
class DictionaryLabel extends ConsumerWidget {
  const DictionaryLabel({
    required this.type,
    required this.id,
    super.key,
    this.style,
  });

  final String type;

  /// The stored **id**, never a label.
  final String id;

  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = ref.watch(resolvedLabelsProvider(type, labelKey([id])));

    return Text(
      resolveLabel(resolved, id, AppL10n.of(context), where: type),
      style: style,
    );
  }
}
