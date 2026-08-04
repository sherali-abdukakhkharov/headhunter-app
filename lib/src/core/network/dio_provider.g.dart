// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured. Auth token injection
/// belongs here as an interceptor once the auth feature lands.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured. Auth token injection
/// belongs here as an interceptor once the auth feature lands.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The app-wide [Dio] instance.
  ///
  /// This is the single place HTTP behaviour is configured. Auth token injection
  /// belongs here as an interceptor once the auth feature lands.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'7322cea6db71ab4c6b0670ef10be3a89e3b43485';
