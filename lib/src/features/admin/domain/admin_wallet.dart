import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';

/// One employer's wallet as an administrator sees it (§10.5).
///
/// Mirrors `AdminWalletDto` in headhunter-backend — change both together.
///
/// ## This is a financial record about an identifiable business
///
/// Every read of it is audited server-side (§11.1), which is why nothing here
/// is prefetched: the list is opened deliberately and a detail is opened by
/// tapping a row. A screen that warmed the next page would write audit entries
/// for wallets nobody looked at.
class AdminWallet {
  const AdminWallet({
    required this.userId,
    required this.balanceCoins,
    required this.unlockCount,
    this.phone,
    this.name,
    this.registrationBonusAt,
  });

  factory AdminWallet.fromJson(Map<String, dynamic> json) => AdminWallet(
    userId: json['userId'] as String,
    balanceCoins: json['balanceCoins'] as int,
    unlockCount: json['unlockCount'] as int,
    phone: json['phone'] as String?,
    name: json['name'] as String?,
    registrationBonusAt: switch (json['registrationBonusAt']) {
      final String value => ZonedTimestamp.parse(value),
      _ => null,
    },
  );

  final String userId;

  /// Null on an anonymized account. BR-14 erases the person and keeps the id,
  /// because §6.7 keeps payment records for reconciliation and BR-24 forbids
  /// rewriting the ledger — so a wallet can outlive the employer behind it.
  final String? phone;
  final String? name;

  final int balanceCoins;

  /// When BR-15's ten Coins were granted, or null if they never were.
  ///
  /// Worth showing rather than deriving from the ledger: "exactly once" is the
  /// rule, and a wallet with no bonus date is the shape a double grant would
  /// *not* have — it is the absence that is diagnostic.
  final ZonedTimestamp? registrationBonusAt;

  /// How many candidates this employer has unlocked (BR-16).
  final int unlockCount;
}

/// A wallet with the ledger behind it (§10.5).
///
/// **Append-only, and the server enforces it**: three database triggers refuse
/// `UPDATE`, `DELETE` and `TRUNCATE` on the ledger, so a correction is a
/// further entry rather than an edit (BR-24). The screen says so, because an
/// administrator looking at a mistaken adjustment will otherwise go looking
/// for a way to remove it.
class AdminWalletDetail extends AdminWallet {
  const AdminWalletDetail({
    required super.userId,
    required super.balanceCoins,
    required super.unlockCount,
    required this.transactions,
    super.phone,
    super.name,
    super.registrationBonusAt,
  });

  factory AdminWalletDetail.fromJson(Map<String, dynamic> json) {
    final wallet = AdminWallet.fromJson(json);
    final rows = json['transactions'];

    return AdminWalletDetail(
      userId: wallet.userId,
      balanceCoins: wallet.balanceCoins,
      unlockCount: wallet.unlockCount,
      phone: wallet.phone,
      name: wallet.name,
      registrationBonusAt: wallet.registrationBonusAt,
      transactions: rows is! List
          ? const []
          : rows
                .whereType<Map<String, dynamic>>()
                .map(WalletTransaction.fromJson)
                .toList(),
    );
  }

  /// Newest first, and **the same type the employer's own wallet renders**.
  ///
  /// One model rather than an admin copy: the two screens are looking at the
  /// same rows, and a second model is how the administrator's view of a
  /// transaction comes to disagree with the employer's about what it was.
  final List<WalletTransaction> transactions;
}
