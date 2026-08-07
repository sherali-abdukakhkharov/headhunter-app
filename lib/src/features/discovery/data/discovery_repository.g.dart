// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoveryRepository)
final discoveryRepositoryProvider = DiscoveryRepositoryProvider._();

final class DiscoveryRepositoryProvider
    extends
        $FunctionalProvider<
          DiscoveryRepository,
          DiscoveryRepository,
          DiscoveryRepository
        >
    with $Provider<DiscoveryRepository> {
  DiscoveryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoveryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoveryRepository create(Ref ref) {
    return discoveryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryRepository>(value),
    );
  }
}

String _$discoveryRepositoryHash() =>
    r'4efd0cfdf65e95e7ecc27233081dd410d9bcb366';

/// One feed's contents.

@ProviderFor(vacancyFeed)
final vacancyFeedProvider = VacancyFeedFamily._();

/// One feed's contents.

final class VacancyFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VacancyCard>>,
          List<VacancyCard>,
          FutureOr<List<VacancyCard>>
        >
    with
        $FutureModifier<List<VacancyCard>>,
        $FutureProvider<List<VacancyCard>> {
  /// One feed's contents.
  VacancyFeedProvider._({
    required VacancyFeedFamily super.from,
    required Feed super.argument,
  }) : super(
         retry: null,
         name: r'vacancyFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyFeedHash();

  @override
  String toString() {
    return r'vacancyFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VacancyCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VacancyCard>> create(Ref ref) {
    final argument = this.argument as Feed;
    return vacancyFeed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyFeedHash() => r'ff02685e577256f788b11ba99fc62040b84ec517';

/// One feed's contents.

final class VacancyFeedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VacancyCard>>, Feed> {
  VacancyFeedFamily._()
    : super(
        retry: null,
        name: r'vacancyFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One feed's contents.

  VacancyFeedProvider call(Feed feed) =>
      VacancyFeedProvider._(argument: feed, from: this);

  @override
  String toString() => r'vacancyFeedProvider';
}
