// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's router: one navigation shell per role, plus the redirect chain.
///
/// ## All three shells are registered at once
///
/// Not "the shell for the active role, rebuilt on switch". Each role owns a
/// path namespace ([AppRole.pathPrefix]) and its own `StatefulShellRoute`, so:
///
/// - **navigation stacks cannot leak across a role switch** - leaving
///   `/candidate/...` for `/employer/...` pops the candidate shell off the
///   router's stack entirely and disposes its branch navigators, which is
///   exactly the isolation §2.3 needs;
/// - **a deep link is self-describing** - the path says which role it needs, so
///   "activate the role, then navigate" is one rule in [_redirect] rather than
///   a branch in every caller that might produce a link;
/// - the router is not rebuilt on a role switch, so switching does not tear
///   down and re-create the whole widget tree.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's router: one navigation shell per role, plus the redirect chain.
///
/// ## All three shells are registered at once
///
/// Not "the shell for the active role, rebuilt on switch". Each role owns a
/// path namespace ([AppRole.pathPrefix]) and its own `StatefulShellRoute`, so:
///
/// - **navigation stacks cannot leak across a role switch** - leaving
///   `/candidate/...` for `/employer/...` pops the candidate shell off the
///   router's stack entirely and disposes its branch navigators, which is
///   exactly the isolation §2.3 needs;
/// - **a deep link is self-describing** - the path says which role it needs, so
///   "activate the role, then navigate" is one rule in [_redirect] rather than
///   a branch in every caller that might produce a link;
/// - the router is not rebuilt on a role switch, so switching does not tear
///   down and re-create the whole widget tree.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's router: one navigation shell per role, plus the redirect chain.
  ///
  /// ## All three shells are registered at once
  ///
  /// Not "the shell for the active role, rebuilt on switch". Each role owns a
  /// path namespace ([AppRole.pathPrefix]) and its own `StatefulShellRoute`, so:
  ///
  /// - **navigation stacks cannot leak across a role switch** - leaving
  ///   `/candidate/...` for `/employer/...` pops the candidate shell off the
  ///   router's stack entirely and disposes its branch navigators, which is
  ///   exactly the isolation §2.3 needs;
  /// - **a deep link is self-describing** - the path says which role it needs, so
  ///   "activate the role, then navigate" is one rule in [_redirect] rather than
  ///   a branch in every caller that might produce a link;
  /// - the router is not rebuilt on a role switch, so switching does not tear
  ///   down and re-create the whole widget tree.
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

String _$appRouterHash() => r'741368b6f84e8306c5cc382a6c9a86b89d543fc2';
