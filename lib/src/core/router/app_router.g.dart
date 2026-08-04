// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's router.
///
/// When auth lands this gains the role-aware shell described in
/// ARCHITECTURE.md: a `StatefulShellRoute` per role plus a `redirect` chain for
/// unauthenticated / no-role-chosen / blocked / ungranted-role.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's router.
///
/// When auth lands this gains the role-aware shell described in
/// ARCHITECTURE.md: a `StatefulShellRoute` per role plus a `redirect` chain for
/// unauthenticated / no-role-chosen / blocked / ungranted-role.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's router.
  ///
  /// When auth lands this gains the role-aware shell described in
  /// ARCHITECTURE.md: a `StatefulShellRoute` per role plus a `redirect` chain for
  /// unauthenticated / no-role-chosen / blocked / ungranted-role.
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

String _$appRouterHash() => r'f45abe1f452762060c1835d14efb6f82d2998fce';
