import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/time/zoned_timestamp.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet.dart';

/// A Candidate Unlock this employer holds (§6.6, BR-16).
///
/// Mirrors `UnlockDto` in headhunter-backend — change both together.
@immutable
class Unlock {
  const Unlock({
    required this.candidateUserId,
    required this.costCoins,
    required this.createdAt,
    required this.charged,
  });

  factory Unlock.fromJson(Map<String, dynamic> json) => Unlock(
    candidateUserId: json['candidateUserId'] as String,
    costCoins: json['costCoins'] as int,
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    charged: json['charged'] as bool? ?? false,
  );

  final String candidateUserId;

  /// What it cost **when it was bought**, not what one costs today. §10.5 may
  /// reprice an unlock, and this entitlement was paid for at the old price.
  final int costCoins;

  final ZonedTimestamp createdAt;

  /// Whether *this* call created the entitlement and debited Coins.
  ///
  /// **False when it already existed**, which is BR-16 and UAT-18: one
  /// employer-candidate pair is charged once, enforced by that pair being a
  /// primary key rather than by a check. A double tap, a retry after a timeout,
  /// or a revisit next month all return the original with `charged: false` —
  /// which is why the unlock needs no idempotency key, unlike apply (§12.4).
  /// Two applications to one vacancy after a withdrawal are legitimately
  /// different rows; two unlocks of one candidate never are.
  final bool charged;
}

/// `GET /wallet/unlocks/:candidateUserId` — whether this candidate is already
/// unlocked, and what one costs.
///
/// Exists so the client can render either the locked or the unlocked state
/// **without attempting a purchase to find out**.
@immutable
class UnlockState {
  const UnlockState({
    required this.unlocked,
    required this.pricing,
    this.unlock,
  });

  factory UnlockState.fromJson(Map<String, dynamic> json) => UnlockState(
    unlocked: json['unlocked'] as bool? ?? false,
    unlock: switch (json['unlock']) {
      final Map<String, dynamic> u => Unlock.fromJson(u),
      _ => null,
    },
    pricing: WalletPricing.fromJson(
      json['pricing'] as Map<String, dynamic>,
    ),
  );

  final bool unlocked;

  /// The entitlement itself when [unlocked], otherwise null.
  final Unlock? unlock;

  /// Today's prices, so the §6.6 confirmation sheet can be built without a
  /// second request for them.
  final WalletPricing pricing;
}

/// What `POST /wallet/unlocks` answered.
///
/// "Not enough Coins" is a **normal outcome, not a failure**, and modelling it
/// as one keeps the status code out of the widget: §6.6 routes a short balance
/// to top-up rather than showing an error, so a caller that had to catch an
/// exception and inspect `statusCode == 402` would be reading a transport
/// detail to make a product decision.
///
/// The backend reasons the same way one layer down — its unlock returns an
/// outcome rather than throwing, because throwing inside the transaction would
/// roll back the write and then report "insufficient balance" having taken the
/// money. Everything genuinely broken still arrives as an `ApiException`.
sealed class UnlockResult {
  const UnlockResult();
}

/// The entitlement exists. Coins were debited only if [Unlock.charged].
class UnlockGranted extends UnlockResult {
  const UnlockGranted(this.unlock);

  final Unlock unlock;
}

/// Fewer Coins than an unlock costs (§6.6, UAT-19).
///
/// [message] is the server's own sentence, already translated into the caller's
/// `x-lang` and already carrying the two numbers — so it is rendered rather
/// than rebuilt here. Reconstructing "2 needed, 1 available" in Dart would be a
/// second, disagreeing answer about money (§12.3.1).
class UnlockUnaffordable extends UnlockResult {
  const UnlockUnaffordable(this.message);

  final String message;
}
