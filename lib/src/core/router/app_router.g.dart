// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's router.
///
/// When auth lands, add a `redirect` here that watches the auth provider and
/// bounces unauthenticated users to the login route.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's router.
///
/// When auth lands, add a `redirect` here that watches the auth provider and
/// bounces unauthenticated users to the login route.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's router.
  ///
  /// When auth lands, add a `redirect` here that watches the auth provider and
  /// bounces unauthenticated users to the login route.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'ad4230552d4804dd728fe4c327326eac6417fb3a';
