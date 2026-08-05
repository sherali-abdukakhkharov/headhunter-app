// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dictionaryCache)
final dictionaryCacheProvider = DictionaryCacheProvider._();

final class DictionaryCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryCache>,
          DictionaryCache,
          FutureOr<DictionaryCache>
        >
    with $FutureModifier<DictionaryCache>, $FutureProvider<DictionaryCache> {
  DictionaryCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryCacheHash();

  @$internal
  @override
  $FutureProviderElement<DictionaryCache> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DictionaryCache> create(Ref ref) {
    return dictionaryCache(ref);
  }
}

String _$dictionaryCacheHash() => r'5b3336e3299013b4f9c6534ec103665361ef1d93';
