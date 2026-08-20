// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'650a82832e60b8609ae3f2bf3068e089aa99cdac';

/// The devices signed in to this account (§4.2).

@ProviderFor(userSessions)
final userSessionsProvider = UserSessionsProvider._();

/// The devices signed in to this account (§4.2).

final class UserSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserSession>>,
          List<UserSession>,
          FutureOr<List<UserSession>>
        >
    with
        $FutureModifier<List<UserSession>>,
        $FutureProvider<List<UserSession>> {
  /// The devices signed in to this account (§4.2).
  UserSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<UserSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserSession>> create(Ref ref) {
    return userSessions(ref);
  }
}

String _$userSessionsHash() => r'57b72e5391203cf0f18cea8069be3b4d5ba4cfbb';
