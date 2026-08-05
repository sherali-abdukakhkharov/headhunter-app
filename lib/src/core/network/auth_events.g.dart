// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authEvents)
final authEventsProvider = AuthEventsProvider._();

final class AuthEventsProvider
    extends $FunctionalProvider<AuthEvents, AuthEvents, AuthEvents>
    with $Provider<AuthEvents> {
  AuthEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authEventsHash();

  @$internal
  @override
  $ProviderElement<AuthEvents> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthEvents create(Ref ref) {
    return authEvents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthEvents value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthEvents>(value),
    );
  }
}

String _$authEventsHash() => r'69826f28c010bef837672f24901439e4dc4eca9e';
