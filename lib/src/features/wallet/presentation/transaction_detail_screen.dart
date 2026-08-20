import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_transaction_row.dart';

/// Opens one ledger entry (§06, E-53).
Future<void> showTransactionDetail(
  BuildContext context, {
  required WalletTransaction entry,
}) => Navigator.of(context, rootNavigator: true).push<void>(
  MaterialPageRoute(builder: (_) => TransactionDetailScreen(entry: entry)),
);

/// One ledger entry in full (§06, E-53).
///
/// ## Takes the entry rather than fetching it
///
/// There is no `GET /wallet/transactions/{id}`, and none is needed: the list
/// already carries every field this screen shows, and a ledger entry is
/// **immutable by construction** — three database triggers refuse `UPDATE` on
/// that table (BR-24). So the copy in hand cannot be stale, which is the only
/// reason a detail screen normally refetches at all.
///
/// ## What it is for
///
/// A support call. §06's own footnote says to quote the reference number, so
/// the screen's job is to make the entry quotable: what it was, when, how much,
/// what it did to the balance, and an identifier a human can hand over.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({required this.entry, super.key});

  final WalletTransaction entry;

  /// What support can look this up by.
  ///
  /// `referenceId` where the server set one — the payment order behind a top-up
  /// is the number a provider dispute is about. Otherwise the entry's own id,
  /// because an unlock's reference is a candidate's user id, which identifies a
  /// person rather than a transaction and is not something to read down a
  /// phone.
  String get _reference => switch (entry.referenceId) {
    final String r when r.isNotEmpty && entry.kind != WalletTransactionKind
        .candidateUnlock => r,
    _ => entry.id,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final credit = entry.isCredit;
    final amount = credit
        ? l10n.walletAmountCredit(entry.amountCoins)
        : l10n.walletAmountDebit(entry.amountCoins.abs());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletDetailTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            HhCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HhIcon(
                        glyphFor(entry.kind),
                        size: 20,
                        color: HhColors.inkMuted,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: HhSpace.sm),
                      Expanded(
                        child: Text(
                          kindLabel(entry.kind, l10n),
                          style: HhTypography.subtitle.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HhSpace.md),
                  Text(
                    amount,
                    style: HhTypography.display.copyWith(
                      fontSize: 30,
                      color: credit ? HhColors.successFg : HhColors.ink,
                    ),
                  ),
                  if (entry.isCorrection) ...[
                    const SizedBox(height: HhSpace.sm),
                    Text(
                      l10n.walletCorrectionExplained,
                      style: HhTypography.meta.copyWith(
                        color: HhColors.warningFg,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: HhSpace.sectionGap),
            Text(l10n.walletDetailSection, style: HhTypography.subtitle),
            const SizedBox(height: HhSpace.md),

            HhCard(
              child: Column(
                children: [
                  // Mandatory on an administrator adjustment (§10.5).
                  if (entry.reason case final reason?) ...[
                    _Row(label: l10n.walletDetailReason, value: reason),
                    const _Gap(),
                  ],
                  _Row(
                    label: l10n.walletDetailWhen,
                    value: walletStamp(entry.createdAt.wallClock),
                  ),
                  const _Gap(),
                  // The UZS this entry carried at the time, never recomputed
                  // from today's price (§10.5). Absent on an unlock or a bonus,
                  // which are priced in Coins and never touched money.
                  if (entry.amountUzs case final uzs?) ...[
                    _Row(
                      label: l10n.walletDetailAmountUzs,
                      value: l10n.walletUzs(uzs),
                    ),
                    const _Gap(),
                  ],
                  _Row(
                    label: l10n.walletDetailEffect,
                    value: amount,
                    strong: true,
                  ),
                  const _Gap(),
                  _Row(
                    label: l10n.walletDetailBalanceAfter,
                    value: l10n.walletCoins(entry.balanceAfter),
                  ),
                  const _Gap(),
                  _Row(
                    label: l10n.walletDetailReference,
                    value: _reference,
                    // Copyable because the support line asks the employer to
                    // quote it, and it is a UUID — nobody reads one of those
                    // down a phone correctly.
                    onCopy: () => _copy(context, _reference, l10n),
                  ),
                ],
              ),
            ),

            const SizedBox(height: HhSpace.lg),
            HhNotice(
              title: l10n.walletDetailSupportTitle,
              message: l10n.walletDetailSupport,
              iconPath: HhIconPath.infoCircle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    String value,
    AppL10n l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(l10n.commonCopied)));
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 11);
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.strong = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool strong;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: HhTypography.body.copyWith(color: HhColors.inkMuted),
          ),
        ),
        const SizedBox(width: HhSpace.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: strong
                ? HhTypography.bodyStrong
                : HhTypography.body.copyWith(color: HhColors.ink),
          ),
        ),
        if (onCopy case final onCopy?) ...[
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: '${l10n.commonCopy} $label',
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: Text(
                  l10n.commonCopy,
                  style: HhTypography.meta.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HhColors.brand600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
