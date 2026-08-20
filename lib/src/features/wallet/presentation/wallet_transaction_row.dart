import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';

/// One ledger entry, shared by §06's E-42 wallet and E-52 history.
///
/// Extracted so the two screens cannot drift. They show the same rows in the
/// same order and only differ in what surrounds them, and a ledger that read
/// one way on the wallet and another way in the history would be two accounts
/// of the same money.
///
/// The signed amount is what separates a credit from a debit, so `+2` and `−2`
/// stay distinguishable with the colour removed — the same rule that stops any
/// status badge relying on its tone.
class WalletTransactionRow extends StatelessWidget {
  const WalletTransactionRow({required this.entry, super.key, this.onTap});

  final WalletTransaction entry;

  /// Opens E-53. Absent on the wallet's recent list, where the row is a summary
  /// rather than a way in — the wallet already offers "all activity" for that.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final credit = entry.isCredit;

    return HhCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: HhIcon(
              glyphFor(entry.kind),
              size: 16,
              color: HhColors.inkMuted,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: HhSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kindLabel(entry.kind, l10n), style: HhTypography.label),
                const SizedBox(height: 2),
                Text(
                  walletStamp(entry.createdAt.wallClock),
                  style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                ),
                if (entry.isCorrection) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.walletCorrection,
                    style: HhTypography.meta.copyWith(
                      color: HhColors.warningFg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                // Mandatory on an administrator adjustment (§10.5), and the one
                // thing that makes one accountable rather than mysterious.
                if (entry.reason case final reason?) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: HhTypography.meta.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: HhSpace.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                credit
                    ? l10n.walletAmountCredit(entry.amountCoins)
                    : l10n.walletAmountDebit(entry.amountCoins.abs()),
                style: HhTypography.bodyStrong.copyWith(
                  color: credit ? HhColors.successFg : HhColors.ink,
                ),
              ),
              Text(
                l10n.walletBalanceAfter(entry.balanceAfter),
                style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
              ),
              // The UZS this entry actually carried, never re-derived from
              // today's price — which is what "never restate history" means on
              // screen (§10.5).
              if (entry.amountUzs case final uzs?)
                Text(
                  l10n.walletUzs(uzs),
                  style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                ),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: HhIcon(
                    HhIconPath.chevronRight,
                    size: 14,
                    color: HhColors.inkSubtle,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A glyph per kind, so a row is scannable without reading the word.
///
/// Deliberately not an `HhBadge`: a badge's tone answers "whose turn is it, and
/// did it end well?", and a ledger entry is an event with neither. Inventing
/// five badges for it would dilute a vocabulary the design keeps small on
/// purpose.
String glyphFor(String kind) => switch (kind) {
  WalletTransactionKind.registrationBonus => HhIconPath.checkCircle,
  WalletTransactionKind.topUp => HhIconPath.plus,
  WalletTransactionKind.candidateUnlock => HhIconPath.lock,
  WalletTransactionKind.adminAdjustment => HhIconPath.edit,
  WalletTransactionKind.reversal => HhIconPath.refresh,
  _ => HhIconPath.wallet,
};

/// Exhaustive over the five kinds, with a fallback that still says something
/// true. A newer server's sixth kind keeps its amount and its balance, which is
/// the part an employer is checking.
String kindLabel(String kind, AppL10n l10n) => switch (kind) {
  WalletTransactionKind.registrationBonus => l10n.walletKindRegistrationBonus,
  WalletTransactionKind.topUp => l10n.walletKindTopUp,
  WalletTransactionKind.candidateUnlock => l10n.walletKindCandidateUnlock,
  WalletTransactionKind.adminAdjustment => l10n.walletKindAdminAdjustment,
  WalletTransactionKind.reversal => l10n.walletKindReversal,
  _ => l10n.walletKindOther,
};

/// `YYYY-MM-DD HH:MM`, from the **wall clock the server resolved**.
///
/// Deliberately not a `DateFormat`: §8.3's display policy is still an open
/// decision, and the rest of the app renders an ISO date for the same reason. A
/// ledger needs the time as well — two entries a minute apart are otherwise
/// indistinguishable — and the wall-clock fields need no policy to be right.
///
/// Never `.toLocal()`: that re-renders in the *device* zone and quietly moves
/// every timestamp for anyone outside Uzbekistan.
String walletStamp(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';
