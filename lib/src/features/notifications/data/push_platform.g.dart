// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_platform.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pushPlatform)
final pushPlatformProvider = PushPlatformProvider._();

final class PushPlatformProvider
    extends $FunctionalProvider<PushPlatform, PushPlatform, PushPlatform>
    with $Provider<PushPlatform> {
  PushPlatformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushPlatformProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushPlatformHash();

  @$internal
  @override
  $ProviderElement<PushPlatform> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushPlatform create(Ref ref) {
    return pushPlatform(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushPlatform value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushPlatform>(value),
    );
  }
}

String _$pushPlatformHash() => r'4752f140a91dcda499e2e2b430cbd9cd901003df';
