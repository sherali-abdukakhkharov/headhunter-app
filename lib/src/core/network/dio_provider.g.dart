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
/// ## Two clients, and why
///
/// The returned client carries [AuthInterceptor]. A **second, bare** client is
/// built alongside it for the two jobs that must not re-enter that interceptor:
/// the refresh call itself, and replaying a request after a refresh. Sharing
/// one client for both would mean a 401 on the refresh endpoint triggering
/// another refresh, forever.
///
/// The bare client is otherwise identical — it still sends `x-lang`, so a
/// refused refresh comes back in the user's language.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured.
///
/// ## Two clients, and why
///
/// The returned client carries [AuthInterceptor]. A **second, bare** client is
/// built alongside it for the two jobs that must not re-enter that interceptor:
/// the refresh call itself, and replaying a request after a refresh. Sharing
/// one client for both would mean a 401 on the refresh endpoint triggering
/// another refresh, forever.
///
/// The bare client is otherwise identical — it still sends `x-lang`, so a
/// refused refresh comes back in the user's language.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The app-wide [Dio] instance.
  ///
  /// This is the single place HTTP behaviour is configured.
  ///
  /// ## Two clients, and why
  ///
  /// The returned client carries [AuthInterceptor]. A **second, bare** client is
  /// built alongside it for the two jobs that must not re-enter that interceptor:
  /// the refresh call itself, and replaying a request after a refresh. Sharing
  /// one client for both would mean a 401 on the refresh endpoint triggering
  /// another refresh, forever.
  ///
  /// The bare client is otherwise identical — it still sends `x-lang`, so a
  /// refused refresh comes back in the user's language.
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

String _$dioHash() => r'350634cc46634a6ee4ec12617a8b43cac4852db3';
