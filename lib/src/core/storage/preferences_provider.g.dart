// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Non-secret key/value storage.
///
/// Use this for things that are merely *state*: the selected interface language
/// before sign-in, the last search configuration (§7.2), onboarding progress.
///
/// **Never for tokens or anything else secret.** §12.5 requires secrets in
/// platform-backed secure storage; `shared_preferences` is a plain XML file on
/// Android and readable on a rooted device. Tokens go through
/// `core/auth/token_store.dart`.
///
/// Overridden with `SharedPreferences.setMockInitialValues({})` in tests, which
/// is why this is a provider rather than a direct call at each use site.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Non-secret key/value storage.
///
/// Use this for things that are merely *state*: the selected interface language
/// before sign-in, the last search configuration (§7.2), onboarding progress.
///
/// **Never for tokens or anything else secret.** §12.5 requires secrets in
/// platform-backed secure storage; `shared_preferences` is a plain XML file on
/// Android and readable on a rooted device. Tokens go through
/// `core/auth/token_store.dart`.
///
/// Overridden with `SharedPreferences.setMockInitialValues({})` in tests, which
/// is why this is a provider rather than a direct call at each use site.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Non-secret key/value storage.
  ///
  /// Use this for things that are merely *state*: the selected interface language
  /// before sign-in, the last search configuration (§7.2), onboarding progress.
  ///
  /// **Never for tokens or anything else secret.** §12.5 requires secrets in
  /// platform-backed secure storage; `shared_preferences` is a plain XML file on
  /// Android and readable on a rooted device. Tokens go through
  /// `core/auth/token_store.dart`.
  ///
  /// Overridden with `SharedPreferences.setMockInitialValues({})` in tests, which
  /// is why this is a provider rather than a direct call at each use site.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'ad13470fe866595ad0f58a3e26f11048d94ef22e';
