import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

/// What `GET /dictionaries/{type}` returns: either the whole set, or only what
/// changed since a revision the client already has.
///
/// Mirrors `DictionaryDeltaDto` in headhunter-backend — change both together.
class DictionaryDelta {
  const DictionaryDelta({
    required this.type,
    required this.locale,
    required this.version,
    required this.isFull,
    required this.items,
    required this.removed,
    this.since,
  });

  factory DictionaryDelta.fromJson(Map<String, dynamic> json) =>
      DictionaryDelta(
        type: json['type'] as String,
        locale: json['locale'] as String,
        version: (json['version'] as num).toInt(),
        since: (json['since'] as num?)?.toInt(),
        isFull: json['isFull'] as bool,
        items: (json['items'] as List<dynamic>)
            .map((e) => DictionaryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        removed: (json['removed'] as List<dynamic>)
            .map((e) => (e as Map<String, dynamic>)['id'] as String)
            .toList(),
      );

  final String type;

  /// **The canonical locale the server resolved**, which is not necessarily
  /// what was sent: `uz` and `oz` are accepted aliases for `uz-Latn`. Key the
  /// cache off this, never off the value in the request — otherwise the same
  /// payload is stored twice and one copy never revalidates.
  final String locale;

  /// Pass back as `since` on the next request. Comes from the server; a local
  /// counter would drift the moment a response is dropped.
  final int version;

  final int? since;

  /// True when this response is the whole set and any cached items for
  /// `(type, locale)` should be replaced rather than merged.
  final bool isFull;

  final List<DictionaryItem> items;

  /// Ids to drop from pickers — retired or merged (§10.3). They still resolve
  /// through `GET /dictionaries/items` forever, which is how a historical
  /// record keeps rendering a label.
  final List<String> removed;

  @override
  String toString() =>
      'DictionaryDelta($type/$locale v$version, '
      '${isFull ? 'full' : 'since $since'}, '
      '${items.length} items, ${removed.length} removed)';
}
