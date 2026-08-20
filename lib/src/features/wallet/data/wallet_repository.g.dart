// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletRepository)
final walletRepositoryProvider = WalletRepositoryProvider._();

final class WalletRepositoryProvider
    extends
        $FunctionalProvider<
          WalletRepository,
          WalletRepository,
          WalletRepository
        >
    with $Provider<WalletRepository> {
  WalletRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletRepositoryHash();

  @$internal
  @override
  $ProviderElement<WalletRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WalletRepository create(Ref ref) {
    return walletRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletRepository>(value),
    );
  }
}

String _$walletRepositoryHash() => r'42311e1401112252a69a609e993323544c71e0ff';

/// The balance and today's prices.

@ProviderFor(wallet)
final walletProvider = WalletProvider._();

/// The balance and today's prices.

final class WalletProvider
    extends $FunctionalProvider<AsyncValue<Wallet>, Wallet, FutureOr<Wallet>>
    with $FutureModifier<Wallet>, $FutureProvider<Wallet> {
  /// The balance and today's prices.
  WalletProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletHash();

  @$internal
  @override
  $FutureProviderElement<Wallet> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Wallet> create(Ref ref) {
    return wallet(ref);
  }
}

String _$walletHash() => r'179992eaf2b5a4684aa177954b11f61b596ff234';

/// Whether this employer already holds an unlock for [candidateUserId] (§6.6).
///
/// A family rather than one provider per screen: the candidate profile and the
/// confirmation sheet must not be able to disagree about whether a purchase is
/// still needed, and two fetches of the same question could.

@ProviderFor(unlockState)
final unlockStateProvider = UnlockStateFamily._();

/// Whether this employer already holds an unlock for [candidateUserId] (§6.6).
///
/// A family rather than one provider per screen: the candidate profile and the
/// confirmation sheet must not be able to disagree about whether a purchase is
/// still needed, and two fetches of the same question could.

final class UnlockStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<UnlockState>,
          UnlockState,
          FutureOr<UnlockState>
        >
    with $FutureModifier<UnlockState>, $FutureProvider<UnlockState> {
  /// Whether this employer already holds an unlock for [candidateUserId] (§6.6).
  ///
  /// A family rather than one provider per screen: the candidate profile and the
  /// confirmation sheet must not be able to disagree about whether a purchase is
  /// still needed, and two fetches of the same question could.
  UnlockStateProvider._({
    required UnlockStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'unlockStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unlockStateHash();

  @override
  String toString() {
    return r'unlockStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UnlockState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UnlockState> create(Ref ref) {
    final argument = this.argument as String;
    return unlockState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnlockStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unlockStateHash() => r'dbec8bd7208167761a44ad0984a04260263071d6';

/// Whether this employer already holds an unlock for [candidateUserId] (§6.6).
///
/// A family rather than one provider per screen: the candidate profile and the
/// confirmation sheet must not be able to disagree about whether a purchase is
/// still needed, and two fetches of the same question could.

final class UnlockStateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UnlockState>, String> {
  UnlockStateFamily._()
    : super(
        retry: null,
        name: r'unlockStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether this employer already holds an unlock for [candidateUserId] (§6.6).
  ///
  /// A family rather than one provider per screen: the candidate profile and the
  /// confirmation sheet must not be able to disagree about whether a purchase is
  /// still needed, and two fetches of the same question could.

  UnlockStateProvider call(String candidateUserId) =>
      UnlockStateProvider._(argument: candidateUserId, from: this);

  @override
  String toString() => r'unlockStateProvider';
}

/// The append-only Coin ledger (§6.6, BR-24), newest first.
///
/// A notifier rather than a family so "show more" *appends* instead of
/// replacing: an employer checking what a Coin went on reads downwards, and a
/// page that swapped itself out would lose the entry they were looking at.
///
/// Nothing here adds anything up. Each entry carries the balance the server
/// recorded after it, so the list is a record rather than a calculation.

@ProviderFor(WalletLedger)
final walletLedgerProvider = WalletLedgerProvider._();

/// The append-only Coin ledger (§6.6, BR-24), newest first.
///
/// A notifier rather than a family so "show more" *appends* instead of
/// replacing: an employer checking what a Coin went on reads downwards, and a
/// page that swapped itself out would lose the entry they were looking at.
///
/// Nothing here adds anything up. Each entry carries the balance the server
/// recorded after it, so the list is a record rather than a calculation.
final class WalletLedgerProvider
    extends $AsyncNotifierProvider<WalletLedger, LedgerPage> {
  /// The append-only Coin ledger (§6.6, BR-24), newest first.
  ///
  /// A notifier rather than a family so "show more" *appends* instead of
  /// replacing: an employer checking what a Coin went on reads downwards, and a
  /// page that swapped itself out would lose the entry they were looking at.
  ///
  /// Nothing here adds anything up. Each entry carries the balance the server
  /// recorded after it, so the list is a record rather than a calculation.
  WalletLedgerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletLedgerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletLedgerHash();

  @$internal
  @override
  WalletLedger create() => WalletLedger();
}

String _$walletLedgerHash() => r'893fc770c011146f7efe8bc4e99202e0275835e7';

/// The append-only Coin ledger (§6.6, BR-24), newest first.
///
/// A notifier rather than a family so "show more" *appends* instead of
/// replacing: an employer checking what a Coin went on reads downwards, and a
/// page that swapped itself out would lose the entry they were looking at.
///
/// Nothing here adds anything up. Each entry carries the balance the server
/// recorded after it, so the list is a record rather than a calculation.

abstract class _$WalletLedger extends $AsyncNotifier<LedgerPage> {
  FutureOr<LedgerPage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LedgerPage>, LedgerPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LedgerPage>, LedgerPage>,
              AsyncValue<LedgerPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
