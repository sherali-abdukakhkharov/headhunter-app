import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// §6.6's prices, **as the server states them**.
///
/// Every field here is server-side business configuration, and §10.5 lets an
/// administrator change it while the app is installed. A `const unlockCost = 2`
/// in Dart would make a price change a store release, and would disagree with
/// the ledger from the moment it moved — the entry records the price it was
/// charged at, so a client that believes a different number renders history
/// wrongly rather than merely showing a stale price.
///
/// [candidateUnlockUzs] is sent rather than derived on purpose. It is
/// `candidateUnlockCoins * coinPriceUzs` *today*, and multiplying here would
/// work right up until the two stop agreeing — a bundle price, a promotion, or
/// a rounding rule are all pricing decisions §6.6 puts on the server.
/// §12.3.1 states the general rule: the client never computes an amount.
@immutable
class WalletPricing {
  const WalletPricing({
    required this.coinPriceUzs,
    required this.candidateUnlockCoins,
    required this.candidateUnlockUzs,
  });

  factory WalletPricing.fromJson(Map<String, dynamic> json) => WalletPricing(
    coinPriceUzs: json['coinPriceUzs'] as int,
    candidateUnlockCoins: json['candidateUnlockCoins'] as int,
    candidateUnlockUzs: json['candidateUnlockUzs'] as int,
  );

  /// UZS for one Coin. Never assume 10,000.
  final int coinPriceUzs;

  /// Coins one Candidate Unlock costs. Never assume 2.
  final int candidateUnlockCoins;

  /// What one unlock costs in UZS at the current price.
  final int candidateUnlockUzs;
}

/// `GET /wallet` — the employer's Coin balance and today's prices (§6.6).
///
/// Mirrors `WalletDto` in headhunter-backend — change both together.
///
/// **Always succeeds for an employer.** The wallet is created on first read, so
/// an employer who registered before the wallet existed sees a zero balance
/// rather than an error, and this screen has one code path instead of a
/// "no wallet yet" branch.
@immutable
class Wallet {
  const Wallet({
    required this.balanceCoins,
    required this.balanceValueUzs,
    required this.pricing,
    this.registrationBonusAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    balanceCoins: json['balanceCoins'] as int,
    balanceValueUzs: json['balanceValueUzs'] as int,
    pricing: WalletPricing.fromJson(
      json['pricing'] as Map<String, dynamic>,
    ),
    registrationBonusAt: switch (json['registrationBonusAt']) {
      final String s => ZonedTimestamp.parse(s),
      _ => null,
    },
  );

  final int balanceCoins;

  /// The balance in UZS **at today's price**, for display only.
  ///
  /// Read, never recomputed. The server does not store it, because §10.5's
  /// repricing must not restate history — and that is exactly why a client-side
  /// `balanceCoins * coinPriceUzs` is the wrong instinct here: it would be a
  /// second, disagreeing answer to a question the response already answers.
  final int balanceValueUzs;

  final WalletPricing pricing;

  /// When the one-time 10-Coin registration bonus was granted (BR-15), or null.
  ///
  /// Null is a normal state, not an error: an employer created before the
  /// wallet shipped has no bonus row, and §6.6 allows an instance that grants
  /// no free Coins at all.
  final ZonedTimestamp? registrationBonusAt;
}
