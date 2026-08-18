import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/features/wallet/domain/unlock.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet_transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_repository.g.dart';

/// How many ledger entries one page holds.
///
/// §6.2's dashboard tile asks for "recent wallet activity", and the server caps
/// a page at 100. Twenty fills a phone screen and leaves the rest to
/// [WalletRepository.transactions]'s offset.
const walletPageSize = 20;

/// The employer's Coin wallet (§6.6).
///
/// Employer-only on the server, and not reachable by an administrator: §10.5
/// has its own routes, so an administrator reading a wallet is logged as an
/// administrator rather than looking like the employer.
class WalletRepository {
  const WalletRepository(this._dio);

  final Dio _dio;

  /// `GET /wallet` — balance, its UZS value, and today's prices.
  ///
  /// No 404 branch, unlike the employer profile: the server creates the wallet
  /// on first read, so "this employer has no wallet" is not a state the client
  /// can observe.
  Future<Wallet> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/wallet');
      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return Wallet.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /wallet/transactions` — the append-only ledger, newest first.
  Future<List<WalletTransaction>> transactions({
    int limit = walletPageSize,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/wallet/transactions',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final items = response.data?['items'] as List? ?? const [];

      return items
          .map(
            (e) => WalletTransaction.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /wallet/unlocks/:candidateUserId` — locked or not, plus the prices.
  ///
  /// Asked rather than inferred. Whether an employer holds an entitlement is
  /// not derivable from anything on a candidate card, and the alternative —
  /// attempting the purchase to find out — is the one experiment that costs
  /// money to run.
  Future<UnlockState> unlockState(String candidateUserId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/wallet/unlocks/$candidateUserId',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return UnlockState.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /wallet/unlocks` — buy the entitlement (§6.6, BR-16, BR-18).
  ///
  /// **One call, and the client must not simulate any part of it.** The debit
  /// and the entitlement are one server transaction; an optimistic debit that
  /// then failed would show Coins gone with no access, which is the pair of
  /// outcomes BR-18 exists to make impossible.
  ///
  /// No `Idempotency-Key`, deliberately — see [Unlock.charged].
  ///
  /// A 402 comes back as [UnlockUnaffordable] rather than an exception, because
  /// §6.6 makes a short balance a route to top-up rather than a failure.
  Future<UnlockResult> unlock(String candidateUserId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/wallet/unlocks',
        data: {'candidateUserId': candidateUserId},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return UnlockGranted(Unlock.fromJson(data));
    } on DioException catch (e) {
      final failure = ApiException.fromDioException(e);

      // 402 is the status §6.6 names for this, and the body's sentence already
      // carries both numbers in the caller's language.
      if (failure.statusCode == 402) {
        return UnlockUnaffordable(failure.message);
      }

      throw failure;
    }
  }
}

@riverpod
WalletRepository walletRepository(Ref ref) =>
    WalletRepository(ref.watch(dioProvider));

/// The balance and today's prices.
@riverpod
Future<Wallet> wallet(Ref ref) => ref.watch(walletRepositoryProvider).fetch();

/// Whether this employer already holds an unlock for [candidateUserId] (§6.6).
///
/// A family rather than one provider per screen: the candidate profile and the
/// confirmation sheet must not be able to disagree about whether a purchase is
/// still needed, and two fetches of the same question could.
@riverpod
Future<UnlockState> unlockState(Ref ref, String candidateUserId) =>
    ref.watch(walletRepositoryProvider).unlockState(candidateUserId);

/// One loaded stretch of the ledger.
///
/// Paging state lives here rather than in the surrounding `AsyncValue` because
/// an append that fails leaves the entries already on screen perfectly valid —
/// only the *next* page is missing. Folding that into `AsyncError` would
/// replace a correct ledger with an error page, which is the one thing an
/// employer checking where their Coins went must not see.
@immutable
class LedgerPage {
  const LedgerPage({
    required this.entries,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<WalletTransaction> entries;

  /// Whether the last page came back **full**, which is the only evidence the
  /// client has that another one exists.
  ///
  /// The endpoint returns no total, and adding one to a table that only ever
  /// grows would mean counting on every read to answer a question a full page
  /// already answers. It errs in the safe direction: when the ledger holds
  /// exactly [walletPageSize] entries this is true once and "show more"
  /// spends a request to find nothing. The opposite mistake would hide entries.
  final bool hasMore;

  /// True while a further page is in flight, so the control can show progress
  /// without the list flashing empty.
  final bool isLoadingMore;

  LedgerPage copyWith({bool? isLoadingMore}) => LedgerPage(
    entries: entries,
    hasMore: hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// The append-only Coin ledger (§6.6, BR-24), newest first.
///
/// A notifier rather than a family so "show more" *appends* instead of
/// replacing: an employer checking what a Coin went on reads downwards, and a
/// page that swapped itself out would lose the entry they were looking at.
///
/// Nothing here adds anything up. Each entry carries the balance the server
/// recorded after it, so the list is a record rather than a calculation.
@riverpod
class WalletLedger extends _$WalletLedger {
  @override
  Future<LedgerPage> build() async {
    final entries = await ref.watch(walletRepositoryProvider).transactions();

    return LedgerPage(
      entries: entries,
      hasMore: entries.length == walletPageSize,
    );
  }

  /// Appends the next page, and **rethrows** so the caller can say so.
  ///
  /// The failure surfaces as a message over a ledger that is still on screen,
  /// rather than as an error state replacing it.
  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || page.isLoadingMore || !page.hasMore) return;

    state = AsyncData(page.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(walletRepositoryProvider)
          .transactions(offset: page.entries.length);

      state = AsyncData(
        LedgerPage(
          entries: [...page.entries, ...next],
          hasMore: next.length == walletPageSize,
        ),
      );
    } on ApiException {
      state = AsyncData(page.copyWith(isLoadingMore: false));
      rethrow;
    }
  }
}
