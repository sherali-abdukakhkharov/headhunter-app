import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dictionary_item.g.dart';

/// One entry in a dictionary: **a stable id and a label for one locale.**
///
/// Mirrors `DictionaryItemDto` in headhunter-backend — change both together.
///
/// ## The rule this type exists to enforce (BR-13, §3.3)
///
/// **Pickers display [label] and bind [id].** A label is display-only and
/// changes with the interface language; the id is what every filter, every
/// write body and every stored value carries. Binding a label works perfectly
/// in one language and silently returns nothing in the other three — the
/// failure is invisible to whoever built the screen, because they are testing
/// in the language they wrote it in.
///
/// [code] is a machine string for diagnostics and deep links. It is **not** a
/// display value (§3.2) and not an alternative key: only [id] is stable across
/// a merge.
@JsonSerializable(createToJson: false)
@immutable
class DictionaryItem {
  const DictionaryItem({
    required this.id,
    required this.code,
    required this.label,
    required this.sortOrder,
    required this.isActive,
    this.category,
    this.group,
    this.parentId,
    this.rank,
    this.mergedIntoId,
  });

  factory DictionaryItem.fromJson(Map<String, dynamic> json) =>
      _$DictionaryItemFromJson(json);

  /// The value that travels on the wire and gets stored. Never displayed.
  final String id;

  /// Stable machine code — diagnostics and deep links only.
  final String code;

  /// Resolved for the request locale by the server's §3.2 fallback chain.
  /// Display this, bind [id].
  final String label;

  /// Work category (§2.1) on occupations and work types; null elsewhere. This
  /// is what makes a picker's options depend on the chosen category.
  final String? category;

  /// Second grouping, used by `attribute` items only (§6.3).
  final String? group;

  /// Parent item — the region a district belongs to. Drives the cascading
  /// picker: a district list is the items whose [parentId] is the chosen
  /// region.
  final String? parentId;

  final int sortOrder;

  /// Only on the ordered scales (`skill_level`, `language_level`), where it is
  /// the value a "≥ B2" comparison uses (§7.4). Comparing labels or sort order
  /// instead would break the moment a level is inserted.
  final int? rank;

  /// False once an administrator retires an item (§10.3). **Hidden from
  /// pickers, still resolvable**, because records created while it was live
  /// must keep rendering a label rather than a raw id.
  final bool isActive;

  /// The surviving item when this one was merged away (§10.3).
  final String? mergedIntoId;

  /// Whether a picker should offer this. Merged items are excluded even if the
  /// server still calls them active: offering both sides of a merge lets a user
  /// pick the one that is about to stop existing.
  bool get isSelectable => isActive && mergedIntoId == null;

  @override
  bool operator ==(Object other) => other is DictionaryItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DictionaryItem($code)';
}
