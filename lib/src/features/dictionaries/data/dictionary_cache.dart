import 'dart:convert';

import 'package:headhunter_app/src/core/storage/preferences_provider.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_delta.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'dictionary_cache.g.dart';

/// One cached dictionary: the items, the revision they are at, and the tag to
/// revalidate with.
class CachedDictionary {
  const CachedDictionary({
    required this.version,
    required this.items,
    this.etag,
  });

  final int version;
  final List<DictionaryItem> items;

  /// The server's `ETag`, replayed as `If-None-Match`. Null on a cache written
  /// before the tag was stored, which simply costs one full refetch.
  final String? etag;
}

/// Persistent store for dictionary payloads, keyed by **(type, canonical
/// locale)**.
///
/// ## Why the locale is part of the key
///
/// Labels are locale-specific, so `region` in `ru` and `region` in `uz-Latn`
/// are different payloads at the same version. Keying on type alone would serve
/// Russian labels to an Uzbek user after a language switch — and because the
/// ids would still be right, every filter would keep working and nobody would
/// notice until a screenshot.
///
/// The key uses the **canonical** locale the server echoed, not the tag that
/// was sent: `uz` and `oz` both resolve to `uz-Latn`, and treating them as
/// three keys means two copies that never revalidate.
///
/// ## Storage choice
///
/// `shared_preferences`, holding one JSON string per key. Not secret data, so
/// §12.5 does not apply. It is the right size for this: the largest type is a
/// few hundred items, tens of kilobytes. If a dictionary ever grows past a
/// megabyte this should become a file or a database — the seam is this class,
/// and nothing above it knows the difference.
class DictionaryCache {
  const DictionaryCache(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'dict';

  static String _itemsKey(String type, String locale) =>
      '$_prefix.$type.$locale.items';

  static String _versionKey(String type, String locale) =>
      '$_prefix.$type.$locale.version';

  static String _etagKey(String type, String locale) =>
      '$_prefix.$type.$locale.etag';

  /// What is stored for `(type, locale)`, or null if nothing is.
  CachedDictionary? read(String type, String locale) {
    final raw = _prefs.getString(_itemsKey(type, locale));
    if (raw == null) return null;

    final version = _prefs.getInt(_versionKey(type, locale));
    if (version == null) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return CachedDictionary(
        version: version,
        etag: _prefs.getString(_etagKey(type, locale)),
        items: decoded
            .map((e) => DictionaryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on FormatException {
      // A payload written by an older app version whose model has since
      // changed. Dropping it costs one refetch; throwing would make the app
      // unusable until reinstall, which is a much worse trade for a cache.
      return null;
    }
  }

  /// Applies [delta] to what is stored and returns the merged result.
  ///
  /// Three rules, and the order matters:
  ///
  /// 1. A **full** response replaces everything. It is the server saying "this
  ///    is the set", so keeping anything it omitted would resurrect items.
  /// 2. Otherwise the delta's items are **upserted by id** — an edited label
  ///    replaces the old one in place.
  /// 3. Then `removed` ids are dropped.
  ///
  /// Removals are applied *after* upserts because an id can appear in both
  /// when an item is merged: the surviving item arrives in `items` and the
  /// merged-away one in `removed`. Dropping first and adding second would put
  /// the retired id back into pickers.
  Future<CachedDictionary> merge(DictionaryDelta delta, {String? etag}) async {
    final existing = delta.isFull
        ? const <DictionaryItem>[]
        : (read(delta.type, delta.locale)?.items ?? const []);

    final byId = {for (final item in existing) item.id: item};
    for (final item in delta.items) {
      byId[item.id] = item;
    }
    delta.removed.forEach(byId.remove);

    final merged = byId.values.toList()
      // Sorted once here rather than at every read: a picker rebuilds on each
      // keystroke of its search field.
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.label.compareTo(b.label);
      });

    await _write(delta.type, delta.locale, delta.version, merged, etag);

    return CachedDictionary(
      version: delta.version,
      items: merged,
      etag: etag,
    );
  }

  /// Records a revalidation that came back 304: nothing changed, but the server
  /// may have reissued the tag.
  Future<void> touchEtag(String type, String locale, String? etag) async {
    if (etag == null) return;
    await _prefs.setString(_etagKey(type, locale), etag);
  }

  Future<void> _write(
    String type,
    String locale,
    int version,
    List<DictionaryItem> items,
    String? etag,
  ) async {
    await _prefs.setString(
      _itemsKey(type, locale),
      jsonEncode([for (final i in items) _toJson(i)]),
    );

    if (etag != null) {
      await _prefs.setString(_etagKey(type, locale), etag);
    } else {
      // An unset tag must not leave the *previous* one behind: it would
      // revalidate against a version that is no longer what is stored, and the
      // resulting 304 would freeze the cache at stale content indefinitely.
      await _prefs.remove(_etagKey(type, locale));
    }

    // Written last. If the process dies partway, a missing version makes `read`
    // return null and everything is refetched - whereas a version without
    // matching items would claim to be current while serving nothing.
    await _prefs.setInt(_versionKey(type, locale), version);
  }

  /// Hand-written because the model is read-only (`createToJson: false`): it is
  /// deserialized from the API, and this is the only place it goes back out.
  static Map<String, dynamic> _toJson(DictionaryItem i) => {
    'id': i.id,
    'code': i.code,
    'label': i.label,
    'category': i.category,
    'group': i.group,
    'parentId': i.parentId,
    'sortOrder': i.sortOrder,
    'rank': i.rank,
    'isActive': i.isActive,
    'mergedIntoId': i.mergedIntoId,
  };

  /// Drops every cached dictionary, in every locale.
  ///
  /// For the developer tools and for a sign-out that changes accounts — not
  /// part of normal operation, because the version handshake already keeps the
  /// cache honest.
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('$_prefix.'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

@Riverpod(keepAlive: true)
Future<DictionaryCache> dictionaryCache(Ref ref) async =>
    DictionaryCache(await ref.watch(sharedPreferencesProvider.future));
