import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';

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

/// Renders the label for a dictionary **code** — `cv`, `company_registration` —
/// rather than for a stored id.
///
/// ## Why this exists separately from [DictionaryLabel]
///
/// Most of the product binds ids (BR-13), but a few DTOs deliberately carry the
/// *code*: `purposeCode` on a file, on required evidence, on a moderation
/// queue's attachment. That is the right contract — the upload endpoint takes a
/// purpose code, so a client that held only the id would have to resolve
/// backwards to upload anything.
///
/// Passing one of those codes to [DictionaryLabel] compiles, runs, and renders
/// **"Unavailable value"** forever, because `id` and `code` are both `String`
/// and the resolver only ever looks at ids. That is exactly what shipped: an
/// employer opening an entitled candidate's CV saw `Unavailable value` under
/// the filename in every language (MT-009), and two more screens printed the
/// raw `snake_case` instead (MT-012).
///
/// Resolution is over the whole type rather than through `resolveIds`, because
/// there is no by-code lookup on the server and one dictionary is small — the
/// list is already cached for the pickers.
class DictionaryCodeLabel extends ConsumerWidget {
  const DictionaryCodeLabel({
    required this.type,
    required this.code,
    super.key,
    this.style,
  });

  final String type;

  /// The stable machine **code**, never an id and never a label.
  final String code;

  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      resolveCodeLabel(
        ref.watch(dictionaryProvider(type)),
        code,
        where: type,
      ),
      style: style,
    );
  }
}

/// The label for [code] within an already-fetched dictionary.
///
/// Mirrors `resolveLabel`'s rules — error is terminal rather than an ellipsis
/// that never resolves — with one deliberate difference in the last resort.
///
/// **An unresolved code is humanised, not replaced.** `resolveLabel` answers
/// "Unavailable value" for an id, and that is right: a UUID tells a reader
/// nothing, so there is nothing to lose. A code is different — it was written
/// to be legible, and `company_registration` read as *Company registration*
/// carries the whole meaning while `Unavailable value` carries none. The audit
/// asked for a human-readable fallback and for no `snake_case` on screen; this
/// is both.
///
/// It is a last resort all the same, and it is logged: reaching it means the
/// dictionary has no row for a code the server is still sending.
String resolveCodeLabel(
  AsyncValue<List<DictionaryItem>> dictionary,
  String code, {
  required String where,
}) {
  if (dictionary case AsyncValue(hasError: true, :final error?)) {
    debugPrint('[dictionary] $where: could not load to resolve "$code" — '
        '$error');
    return humanizeCode(code);
  }

  return switch (dictionary) {
    AsyncData(:final value) => value
            .where((item) => item.code == code)
            .firstOrNull
            ?.label ??
        () {
          debugPrint('[dictionary] $where: no item with code "$code"');
          return humanizeCode(code);
        }(),
    _ => '…',
  };
}

/// The label for a bound [id], or **null** while it is not yet known.
///
/// For callers building a sentence out of several parts rather than rendering
/// one label on its own. `resolveLabel` answers `'…'` while a lookup is in
/// flight, which is right for a field that holds exactly one value and wrong in
/// the middle of a phrase: "150 000 so'm / …" reads as a rendering fault, while
/// "150 000 so'm" is simply the part that is known.
///
/// Null for a null [id] too, so a caller need not check twice.
String? optionalLabel(
  WidgetRef ref, {
  required String type,
  required String? id,
}) {
  if (id == null) return null;

  final resolved = ref.watch(resolvedLabelsProvider(type, labelKey([id])));

  return switch (resolved) {
    AsyncData(:final value) => value[id]?.label,
    _ => null,
  };
}

/// `company_registration` → `Company registration`.
///
/// Not a translation and never presented as one — it is what a screen shows
/// instead of a machine code when the dictionary cannot say better.
String humanizeCode(String code) {
  final words = code.replaceAll(RegExp('[_-]+'), ' ').trim();
  if (words.isEmpty) return code;

  return words[0].toUpperCase() + words.substring(1);
}
