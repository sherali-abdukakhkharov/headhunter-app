// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localeSync)
final localeSyncProvider = LocaleSyncProvider._();

final class LocaleSyncProvider
    extends $FunctionalProvider<LocaleSync, LocaleSync, LocaleSync>
    with $Provider<LocaleSync> {
  LocaleSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeSyncHash();

  @$internal
  @override
  $ProviderElement<LocaleSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocaleSync create(Ref ref) {
    return localeSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocaleSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocaleSync>(value),
    );
  }
}

String _$localeSyncHash() => r'e8132ca5747faa0bd51ca5a882778dcebc6587db';
