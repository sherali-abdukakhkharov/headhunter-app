import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_cache.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_delta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The merge rules decide what a picker offers, and every way of getting them
/// wrong is silent: a resurrected item looks like a normal option, and a
/// cross-locale collision still binds correct ids, so every filter keeps
/// working.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DictionaryCache cache;

  Map<String, dynamic> item(
    String id, {
    String label = 'Label',
    int sortOrder = 0,
    String? parentId,
    bool isActive = true,
    String? mergedIntoId,
  }) => {
    'id': id,
    'code': 'code_$id',
    'label': label,
    'category': null,
    'group': null,
    'parentId': parentId,
    'sortOrder': sortOrder,
    'rank': null,
    'isActive': isActive,
    'mergedIntoId': mergedIntoId,
  };

  DictionaryDelta delta({
    required int version,
    required bool isFull,
    String type = 'region',
    String locale = 'uz-Latn',
    List<Map<String, dynamic>> items = const [],
    List<String> removed = const [],
    int? since,
  }) => DictionaryDelta.fromJson({
    'type': type,
    'locale': locale,
    'version': version,
    'since': since,
    'isFull': isFull,
    'items': items,
    'removed': [for (final id in removed) {'id': id}],
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = DictionaryCache(await SharedPreferences.getInstance());
  });

  test('a cold read is null rather than an empty list', () async {
    // The difference matters: empty means "the server says there is nothing",
    // null means "ask the server". Collapsing them makes a picker render zero
    // options forever.
    expect(cache.read('region', 'uz-Latn'), isNull);
  });

  test('a full response is stored and read back', () async {
    await cache.merge(
      delta(
        version: 10,
        isFull: true,
        items: [item('a', label: 'Andijon'), item('b', label: 'Buxoro')],
      ),
      etag: 'W/"region:10:uz-Latn"',
    );

    final stored = cache.read('region', 'uz-Latn')!;

    expect(stored.version, 10);
    expect(stored.etag, 'W/"region:10:uz-Latn"');
    expect(stored.items.map((i) => i.label), ['Andijon', 'Buxoro']);
  });

  test('a delta upserts by id instead of appending', () async {
    await cache.merge(
      delta(version: 10, isFull: true, items: [item('a', label: 'Andijon')]),
    );

    // An administrator corrected the label (§10.3).
    final merged = await cache.merge(
      delta(
        version: 11,
        isFull: false,
        since: 10,
        items: [item('a', label: 'Andijon viloyati')],
      ),
    );

    expect(merged.items, hasLength(1));
    expect(merged.items.single.label, 'Andijon viloyati');
    expect(merged.version, 11);
  });

  test('a full response replaces, so an omitted item does not survive',
      () async {
    await cache.merge(
      delta(version: 10, isFull: true, items: [item('a'), item('b')]),
    );

    final merged = await cache.merge(
      delta(version: 20, isFull: true, items: [item('a')]),
    );

    // A full response is the server saying "this is the set". Merging into the
    // old one instead would resurrect `b` permanently - it is never mentioned
    // again, so nothing would ever remove it.
    expect(merged.items.map((i) => i.id), ['a']);
  });

  test('removals are applied after upserts, so a merge cannot resurrect an id',
      () async {
    await cache.merge(
      delta(version: 10, isFull: true, items: [item('old'), item('keep')]),
    );

    // The shape of a merge (§10.3): the surviving item arrives in `items` and
    // the merged-away one in `removed`. Dropping first and adding second would
    // put `old` back into every picker.
    final merged = await cache.merge(
      delta(
        version: 11,
        isFull: false,
        since: 10,
        items: [item('old'), item('survivor')],
        removed: ['old'],
      ),
    );

    expect(
      merged.items.map((i) => i.id),
      unorderedEquals(['keep', 'survivor']),
    );
  });

  test('items come back sorted by sortOrder', () async {
    // Sorted on write, because a picker re-filters on every keystroke.
    final merged = await cache.merge(
      delta(
        version: 1,
        isFull: true,
        items: [
          item('c', label: 'C', sortOrder: 3),
          item('a', label: 'A', sortOrder: 1),
          item('b', label: 'B', sortOrder: 2),
        ],
      ),
    );

    expect(merged.items.map((i) => i.label), ['A', 'B', 'C']);
  });

  test('locales are stored separately', () async {
    // Keying on type alone would serve Russian labels to an Uzbek user after a
    // language switch - and because the ids stay correct, every filter keeps
    // working and nobody notices.
    await cache.merge(
      delta(version: 5, isFull: true, items: [item('a', label: 'Andijon')]),
    );
    await cache.merge(
      delta(
        locale: 'ru',
        version: 5,
        isFull: true,
        items: [item('a', label: 'Андижан')],
      ),
    );

    expect(cache.read('region', 'uz-Latn')!.items.single.label, 'Andijon');
    expect(cache.read('region', 'ru')!.items.single.label, 'Андижан');
  });

  test('a 304 refreshes the tag without touching the items', () async {
    await cache.merge(
      delta(version: 10, isFull: true, items: [item('a')]),
      etag: 'W/"old"',
    );

    await cache.touchEtag('region', 'uz-Latn', 'W/"new"');

    final stored = cache.read('region', 'uz-Latn')!;
    expect(stored.etag, 'W/"new"');
    expect(stored.version, 10);
    expect(stored.items, hasLength(1));
  });

  test('a merge with no tag clears the previous one', () async {
    // Leaving a stale tag behind would revalidate against a version that is no
    // longer stored; the resulting 304 would freeze the cache at stale content
    // indefinitely.
    await cache.merge(
      delta(version: 10, isFull: true, items: [item('a')]),
      etag: 'W/"ten"',
    );
    await cache.merge(delta(version: 11, isFull: true, items: [item('a')]));

    expect(cache.read('region', 'uz-Latn')!.etag, isNull);
  });

  test('clear drops every locale of every type', () async {
    await cache.merge(delta(version: 1, isFull: true, items: [item('a')]));
    await cache.merge(
      delta(locale: 'ru', version: 1, isFull: true, items: [item('a')]),
    );

    await cache.clear();

    expect(cache.read('region', 'uz-Latn'), isNull);
    expect(cache.read('region', 'ru'), isNull);
  });

  group('isSelectable', () {
    test('excludes retired and merged items', () async {
      final merged = await cache.merge(
        delta(
          version: 1,
          isFull: true,
          items: [
            item('live'),
            item('retired', isActive: false),
            item('merged', mergedIntoId: 'live'),
          ],
        ),
      );

      final selectable = merged.items.where((i) => i.isSelectable);

      // Both stay cached - a historical record referencing them must still
      // render a label - but neither is offered to someone choosing afresh.
      expect(merged.items, hasLength(3));
      expect(selectable.map((i) => i.id), ['live']);
    });
  });
}
