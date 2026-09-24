// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_opener.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkOpener)
final linkOpenerProvider = LinkOpenerProvider._();

final class LinkOpenerProvider
    extends $FunctionalProvider<LinkOpener, LinkOpener, LinkOpener>
    with $Provider<LinkOpener> {
  LinkOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkOpenerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkOpenerHash();

  @$internal
  @override
  $ProviderElement<LinkOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkOpener create(Ref ref) {
    return linkOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkOpener>(value),
    );
  }
}

String _$linkOpenerHash() => r'2ece08a2823c6786323a40cecaedeba0073eaeeb';
