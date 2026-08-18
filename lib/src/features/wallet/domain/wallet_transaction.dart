import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/time/zoned_timestamp.dart';

/// §6.6's five ledger entry kinds.
///
/// Plain codes rather than a Dart enum, the same rule as `ApplicationStage` and
/// as an unknown schema field kind: an entry from a newer server is carried and
/// shown with its amount intact instead of crashing the ledger. Getting money
/// on screen matters more than naming it — an unrecognised kind still has a
/// signed amount and a resulting balance, which is the part a person is
/// checking.
abstract final class WalletTransactionKind {
  /// BR-15's one-time 10 Coins. Credit.
  static const registrationBonus = 'registration_bonus';

  /// §6.7's Payme / CLICK purchase. Credit. Carries `amountUzs`.
  static const topUp = 'top_up';

  /// §6.6's Candidate Unlock. Debit; `referenceId` is the candidate.
  static const candidateUnlock = 'candidate_unlock';

  /// §10.5's manual administrator correction. Signed, and `reason` is
  /// mandatory — the server refuses one without it.
  static const adminAdjustment = 'admin_adjustment';

  /// A refund or a reversal of an earlier entry. Signed.
  static const reversal = 'reversal';

  /// The kinds that exist to **correct** an earlier entry rather than to record
  /// something the employer did.
  ///
  /// BR-24 forbids fixing a mistake by rewriting the entry that caused it, so
  /// these two are how every correction reaches the ledger. The UI marks them
  /// for exactly that reason: an adjustment rendered like a purchase leaves an
  /// employer unable to tell "you spent Coins" from "we gave some back", and a
  /// balance that silently absorbed one would be the rewriting BR-24 forbids.
  static const Set<String> corrections = {adminAdjustment, reversal};

  static bool isCorrection(String kind) => corrections.contains(kind);
}

/// One entry in the append-only Coin ledger (§6.6, BR-24).
///
/// Mirrors `WalletTransactionDto` in headhunter-backend — change both together.
///
/// ## Nothing here is ever recomputed
///
/// Three database triggers refuse `UPDATE`, `DELETE` and `TRUNCATE` on this
/// table, so what the server sends is what happened. The client's side of that
/// bargain is to render the fields as given: [balanceAfter] is the balance the
/// server recorded, not a running total this list adds up, and [amountUzs] is
/// the UZS value **at the time of the transaction**. Re-deriving either against
/// today's price would restate history the moment §10.5 reprices a Coin, which
/// is the one thing an append-only ledger exists to prevent.
@immutable
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.kind,
    required this.amountCoins,
    required this.balanceAfter,
    required this.createdAt,
    this.amountUzs,
    this.referenceId,
    this.reason,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        kind: json['kind'] as String,
        amountCoins: json['amountCoins'] as int,
        balanceAfter: json['balanceAfter'] as int,
        createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
        amountUzs: json['amountUzs'] as int?,
        referenceId: json['referenceId'] as String?,
        reason: json['reason'] as String?,
      );

  final String id;

  /// One of [WalletTransactionKind]'s codes, or something newer.
  final String kind;

  /// **Signed**: a debit is negative, so the ledger sums to the balance.
  ///
  /// The sign is the whole reason this screen never needs to know which kinds
  /// are debits. It is also what keeps the credit/debit distinction off colour
  /// alone — `+10` and `−2` read identically in greyscale.
  final int amountCoins;

  /// The balance the server recorded **after** this entry.
  final int balanceAfter;

  final ZonedTimestamp createdAt;

  /// UZS value at the time of the transaction, or null when the entry never had
  /// one — a bonus and an unlock are priced in Coins, not money.
  final int? amountUzs;

  /// What it was for: the candidate on an unlock, the payment order on a
  /// top-up.
  final String? referenceId;

  /// Mandatory on an administrator adjustment (§10.5), null on the rest.
  final String? reason;

  /// True when Coins arrived, false when they left.
  ///
  /// Zero cannot occur: the server refuses an adjustment of zero, since an
  /// entry that changes nothing is a ledger row with no meaning.
  bool get isCredit => amountCoins > 0;

  /// True when this entry corrects an earlier one (BR-24).
  bool get isCorrection => WalletTransactionKind.isCorrection(kind);
}
