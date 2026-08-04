// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthRepository)
final healthRepositoryProvider = HealthRepositoryProvider._();

final class HealthRepositoryProvider
    extends
        $FunctionalProvider<
          HealthRepository,
          HealthRepository,
          HealthRepository
        >
    with $Provider<HealthRepository> {
  HealthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthRepositoryHash();

  @$internal
  @override
  $ProviderElement<HealthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HealthRepository create(Ref ref) {
    return healthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthRepository>(value),
    );
  }
}

String _$healthRepositoryHash() => r'5855b307f3e8f9622de67123627d11acb228ae32';

/// Current backend health. Watch this to render status; refresh to re-check.

@ProviderFor(healthStatus)
final healthStatusProvider = HealthStatusProvider._();

/// Current backend health. Watch this to render status; refresh to re-check.

final class HealthStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthStatus>,
          HealthStatus,
          FutureOr<HealthStatus>
        >
    with $FutureModifier<HealthStatus>, $FutureProvider<HealthStatus> {
  /// Current backend health. Watch this to render status; refresh to re-check.
  HealthStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthStatusHash();

  @$internal
  @override
  $FutureProviderElement<HealthStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthStatus> create(Ref ref) {
    return healthStatus(ref);
  }
}

String _$healthStatusHash() => r'86407d598880e1ffc7054b4a34b0b0978cdaaba9';
