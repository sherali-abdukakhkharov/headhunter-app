import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_cache.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_repository.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_providers.g.dart';

/// The items of one dictionary type, in the active interface language.
///
/// ## Cache-first, then revalidate
///
/// 1. Serve what is cached for `(type, canonical locale)` immediately.
/// 2. Ask the server for anything newer, sending `If-None-Match` and `since`.
/// 3. On 304 — the common case — nothing else happens.
/// 4. On a delta, merge and emit again.
///
/// A cold cache waits for the network; a warm one never does. That matters
/// because these feed pickers: a form that cannot render its options until a
/// round trip completes is a form that looks broken on a slow connection.
///
/// **Keyed on the locale**, so switching language re-resolves every label while
/// the bound ids are untouched — which is the client half of UAT-13. The
/// dependency is `activeLocaleProvider`, watched rather than read, so the
/// provider rebuilds on a language change on its own.
///
/// ## What happens when the network fails
///
/// A cached copy wins: the error is swallowed and the stale-but-usable list is
/// served. Dictionaries change rarely, and refusing to render a picker because
/// a revalidation failed would break form editing offline for no benefit
/// (§12.4). With no cache there is nothing to serve, so the failure surfaces
/// and the UI shows it.
@riverpod
Future<List<DictionaryItem>> dictionary(Ref ref, String type) async {
  // Watched, not read: this is what makes a language switch rebuild the list.
  final locale = ref.watch(activeLocaleProvider);
  final cache = await ref.watch(dictionaryCacheProvider.future);
  final repository = ref.watch(dictionaryRepositoryProvider);

  // The server's canonical tag, which is what the cache is keyed on. Using the
  // app's own tag would split `uz` and `uz-Latn` into two entries.
  final localeKey = locale.tag;
  final cached = cache.read(type, localeKey);

  try {
    final fetched = await repository.fetch(
      type,
      since: cached?.version,
      etag: cached?.etag,
    );

    if (fetched.isUnchanged) {
      await cache.touchEtag(type, localeKey, fetched.etag);
      return cached?.items ?? const [];
    }

    final delta = fetched.delta!;
    // Keyed on the locale the *server* resolved, not the one requested.
    final merged = await cache.merge(delta, etag: fetched.etag);
    return merged.items;
  } on Object catch (error) {
    if (cached != null) {
      debugPrint('[dictionary] $type/$localeKey served from cache: $error');
      return cached.items;
    }
    rethrow;
  }
}

/// Only the items a picker should offer: active, not merged away (§10.3).
///
/// Separate from [dictionary] rather than filtered at each call site, because
/// the two audiences are genuinely different — a picker wants this, and label
/// resolution for a historical record wants the unfiltered set.
@riverpod
Future<List<DictionaryItem>> selectableDictionary(
  Ref ref,
  String type,
) async {
  final items = await ref.watch(dictionaryProvider(type).future);
  return items.where((i) => i.isSelectable).toList();
}

/// The children of [parentId] within [type] — districts of a region (§5.1).
///
/// Returns everything with no parent when [parentId] is null, which is the
/// top-level list a region picker shows.
@riverpod
Future<List<DictionaryItem>> dictionaryChildren(
  Ref ref,
  String type,
  String? parentId,
) async {
  final items = await ref.watch(selectableDictionaryProvider(type).future);
  return items.where((i) => i.parentId == parentId).toList();
}

/// Resolves ids to labels, **including ids no picker would offer**.
///
/// Looks in the cache first and asks the server only for what is missing. That
/// second step is the point: a record created last year can reference an
/// occupation an administrator has since retired, and it must render as words
/// rather than a UUID (§10.3).
///
/// Returns a map so a caller with several ids does one lookup. Ids the server
/// cannot resolve either are simply absent — the caller decides what to show,
/// because "deleted" reads differently in a profile than in an audit log.
///
/// **The key is a comma-joined string, not a `List`**, and that is
/// load-bearing.
///
/// Riverpod families compare their arguments with `==`, and a Dart `List` has
/// identity equality. A caller writing `resolvedLabelsProvider(type, [id])`
/// builds a *new* list on every rebuild, so every rebuild is a new family
/// member: a fresh fetch, a fresh cache entry, and neither is ever collected.
/// The screen still renders correctly, which is what makes it hard to spot.
///
/// Build the key with [labelKey], which also sorts — so the same set of ids in
/// a different order is the same provider.
@riverpod
Future<Map<String, DictionaryItem>> resolvedLabels(
  Ref ref,
  String type,
  String idKey,
) async {
  final ids = idKey.isEmpty ? const <String>[] : idKey.split(',');
  if (ids.isEmpty) return const {};

  final known = await ref.watch(dictionaryProvider(type).future);
  final byId = {
    for (final item in known)
      if (ids.contains(item.id)) item.id: item,
  };

  final missing = ids.where((id) => !byId.containsKey(id)).toList();
  if (missing.isEmpty) return byId;

  final resolved = await ref
      .watch(dictionaryRepositoryProvider)
      .resolveIds(missing);

  return {...byId, for (final item in resolved) item.id: item};
}

/// Builds the family key for [resolvedLabels].
///
/// Sorted, so `[a, b]` and `[b, a]` resolve to one provider rather than two
/// holding identical data.
String labelKey(Iterable<String> ids) => (List.of(ids)..sort()).join(',');

/// Warms every dictionary this app version knows about.
///
/// Called once after sign-in rather than lazily per picker: the first form a
/// candidate opens needs six of them at once, and six cold round trips in
/// sequence is the difference between a form that appears and one that
/// assembles itself while the user watches.
///
/// Failures are deliberately not propagated — this is a prefetch, and each
/// picker still resolves its own type on demand.
@riverpod
Future<void> warmDictionaries(Ref ref, List<String> types) async {
  for (final type in types) {
    try {
      await ref.watch(dictionaryProvider(type).future);
    } on Object catch (error) {
      debugPrint('[dictionary] warm-up skipped $type: $error');
    }
  }
}
