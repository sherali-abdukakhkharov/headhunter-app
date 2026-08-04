// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured.
///
/// `AuthInterceptor` is deliberately **not** installed yet. It is written and
/// tested (`test/core/network/auth_interceptor_test.dart`), but it needs a
/// refresh callback, and the auth endpoints are not in the backend's
/// `docs/API_CONTRACTS.md` - that file covers locale, timestamps, dictionaries
/// and schemas only. Installing it now would mean inventing a request and
/// response shape and shipping the guess into the request path. Nothing in the
/// app calls an authenticated endpoint yet, so waiting costs nothing; adding it
/// is one `interceptors.add` once M1 publishes the contract.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured.
///
/// `AuthInterceptor` is deliberately **not** installed yet. It is written and
/// tested (`test/core/network/auth_interceptor_test.dart`), but it needs a
/// refresh callback, and the auth endpoints are not in the backend's
/// `docs/API_CONTRACTS.md` - that file covers locale, timestamps, dictionaries
/// and schemas only. Installing it now would mean inventing a request and
/// response shape and shipping the guess into the request path. Nothing in the
/// app calls an authenticated endpoint yet, so waiting costs nothing; adding it
/// is one `interceptors.add` once M1 publishes the contract.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The app-wide [Dio] instance.
  ///
  /// This is the single place HTTP behaviour is configured.
  ///
  /// `AuthInterceptor` is deliberately **not** installed yet. It is written and
  /// tested (`test/core/network/auth_interceptor_test.dart`), but it needs a
  /// refresh callback, and the auth endpoints are not in the backend's
  /// `docs/API_CONTRACTS.md` - that file covers locale, timestamps, dictionaries
  /// and schemas only. Installing it now would mean inventing a request and
  /// response shape and shipping the guess into the request path. Nothing in the
  /// app calls an authenticated endpoint yet, so waiting costs nothing; adding it
  /// is one `interceptors.add` once M1 publishes the contract.
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

String _$dioHash() => r'f321c7c88e1a374197268f57d11c0b5d6eef6085';
