/// The sign-in prefetch (§3.3), and the reason it did nothing.
///
/// **Nothing listens to a prefetch.** The composition root starts it and drops
/// the future — a warm cache is the point, not a value anybody renders — so an
/// auto-disposing provider was collected at its first `await` and every
/// `ref.watch` afterwards threw on a dead `Ref`. The loop catches per type, so
/// the whole failure appeared as seventeen skipped lines in the log and a first
/// form that still paid for six cold round trips (MT-028).
///
/// The claim worth pinning is therefore not "it fetches" but **"it reaches the
/// last one"**: the bug let the first through and lost the rest.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';

void main() {
  /// Three types is enough: the failure was "everything after the first".
  const types = ['occupation', 'region', 'language'];

  /// Overrides each type with a fetch that costs a real turn of the event loop,
  /// which is what a request costs and what the collector needs in order to
  /// run. A synchronous fake would pass either way.
  ProviderContainer containerRecording(List<String> visited) {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        for (final type in types)
          dictionaryProvider(type).overrideWith((ref) async {
            await Future<void>.delayed(Duration.zero);
            visited.add(type);

            return const <DictionaryItem>[];
          }),
      ],
    );
    addTearDown(container.dispose);

    return container;
  }

  test('the warm-up reaches every type, not just the first', () async {
    final visited = <String>[];
    final container = containerRecording(visited);

    await container.read(warmDictionariesProvider(types).future);

    expect(visited, types);
  });

  test('and it does so when nobody is holding it open', () async {
    // The production call site exactly: started from a session listener and
    // dropped on the floor. Awaiting `.future` does not add a listener either,
    // so the case above is already this one — but stating it as its own test is
    // what stops a future refactor from "fixing" it by making the caller retain
    // the future, which would leave every other caller broken.
    final visited = <String>[];
    final container = containerRecording(visited);

    container.read(warmDictionariesProvider(types).future).ignore();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(visited, types);
  });

  test('a type that fails does not take the rest with it', () async {
    final visited = <String>[];
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        dictionaryProvider(types[0]).overrideWith((ref) async {
          await Future<void>.delayed(Duration.zero);

          throw Exception('no network');
        }),
        for (final type in types.skip(1))
          dictionaryProvider(type).overrideWith((ref) async {
            await Future<void>.delayed(Duration.zero);
            visited.add(type);

            return const <DictionaryItem>[];
          }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(warmDictionariesProvider(types).future);

    // A prefetch is best-effort by design: each picker still resolves its own
    // type on demand, so one dead type must not cost the other sixteen.
    expect(visited, types.skip(1));
  });
}
