import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';

/// Opens the Coin wallet (§6.6).
///
/// A pushed route rather than a shell tab: the employer shell is full at the
/// design's five destinations, and §6.2 puts the wallet on the dashboard as a
/// widget rather than in the navigation bar.
Future<void> showWallet(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => const WalletScreen()),
    );

/// The employer's Coin wallet: balance, today's prices, and the ledger.
///
/// ## Every figure on this screen comes from the server
///
/// §6.6 makes the Coin price and the unlock cost business configuration, and
/// §12.3.1 forbids the client computing an amount. So the balance in UZS is
/// read from the response rather than multiplied here, and each ledger entry
/// shows the balance the server recorded after it rather than a total this list
/// accumulates. Both would agree today and diverge the first time §10.5
/// reprices a Coin — and the divergence would surface as the app disagreeing
/// with the receipt.
///
/// ## The ledger is append-only, and it has to look it (BR-24)
///
/// A refund, a reversal and an administrator adjustment are separate entries,
/// never edits to the entry they correct. Rendering a "corrected" balance that
/// had absorbed one would be exactly the rewriting BR-24 exists to prevent, so
/// corrections are marked as such and shown in line with everything else.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(walletProvider)
              ..invalidate(walletLedgerProvider);
          },
          // hasError first, so a Riverpod retry that carries an error as
          // AsyncLoading can never mask the failure behind a spinner.
          child: switch (wallet) {
            AsyncValue(hasError: true, :final error?) => _Scrollable(
              child: Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(walletProvider),
                ),
              ),
            ),
            AsyncData(:final value) => _WalletBody(wallet: value),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _WalletBody extends ConsumerWidget {
  const _WalletBody({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final ledger = ref.watch(walletLedgerProvider);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        _BalanceCard(wallet: wallet),
        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.walletActivity, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        switch (ledger) {
          AsyncValue(hasError: true, :final error?) => HhErrorState(
            title: l10n.stateErrorTitle,
            message: error is ApiException
                ? error.message
                : l10n.stateErrorBody,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(walletLedgerProvider),
          ),
          AsyncData(:final value) when value.entries.isEmpty => HhEmptyState(
            title: l10n.stateEmptyTitle,
            message: l10n.walletActivityEmpty,
          ),
          AsyncData(:final value) => _Ledger(page: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

/// Balance, its approximate UZS value, today's prices, and Top up.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.walletBalanceLabel,
            style: HhTypography.overline.copyWith(color: HhColors.inkMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const HhIcon(
                HhIconPath.wallet,
                size: 22,
                color: HhColors.brand600,
                strokeWidth: 2,
              ),
              const SizedBox(width: HhSpace.sm),
              Expanded(
                child: Text(
                  l10n.walletCoins(wallet.balanceCoins),
                  style: HhTypography.display.copyWith(fontSize: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            // The server's figure. Never balanceCoins * coinPriceUzs.
            l10n.walletApproxUzs(wallet.balanceValueUzs),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
          if (wallet.registrationBonusAt case final at?) ...[
            const SizedBox(height: HhSpace.md),
            Row(
              children: [
                const HhIcon(
                  HhIconPath.checkCircle,
                  size: 14,
                  color: HhColors.successFg,
                  strokeWidth: 2.2,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.walletRegistrationBonusOn(_stamp(at.wallClock)),
                    style: HhTypography.meta.copyWith(
                      color: HhColors.successFg,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: HhSpace.lg),
          const Divider(height: 1, color: HhColors.border),
          const SizedBox(height: HhSpace.md),
          Text(
            l10n.walletPrices,
            style: HhTypography.overline.copyWith(color: HhColors.inkMuted),
          ),
          const SizedBox(height: HhSpace.sm),
          _PriceRow(
            label: l10n.walletCoinPriceLabel,
            value: l10n.walletUzs(wallet.pricing.coinPriceUzs),
          ),
          const SizedBox(height: 6),
          _PriceRow(
            label: l10n.walletUnlockPriceLabel,
            value: l10n.walletCoins(wallet.pricing.candidateUnlockCoins),
            // **No UZS figure here, deliberately.** §06's first principle is
            // that this is a service balance rather than a wallet, and that the
            // UZS value appears only where money actually changes hands — the
            // top-up screen, the payment screen, the receipt. An unlock is
            // priced in Coins and paid for in Coins; som beside it turns a
            // service action back into a financial transaction, which is the
            // finance chrome the design spends its restraint avoiding.
            //
            // `pricing.candidateUnlockUzs` is still read from the server rather
            // than derived, and M13's top-up screens are where it belongs.
          ),
          const SizedBox(height: HhSpace.lg),
          HhButton.secondary(
            label: l10n.walletTopUp,
            iconPath: HhIconPath.plus,
            onPressed: () => _topUp(context, l10n),
          ),
        ],
      ),
    );
  }

  /// §6.7's checkout is M13, and needs merchant credentials nobody has yet.
  ///
  /// Says so rather than doing nothing. A control that silently fails reads as
  /// a broken app, and with ten free Coins in every new wallet nobody is
  /// actually stuck behind this.
  void _topUp(BuildContext context, AppL10n l10n) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.walletTopUpUnavailable)),
      );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label, style: HhTypography.body)),
      const SizedBox(width: HhSpace.sm),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value, style: HhTypography.bodyStrong),
        ],
      ),
    ],
  );
}

class _Ledger extends ConsumerWidget {
  const _Ledger({required this.page});

  final LedgerPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return Column(
      children: [
        for (final entry in page.entries) ...[
          _LedgerRow(entry: entry),
          const SizedBox(height: HhSpace.sm),
        ],
        if (page.isLoadingMore)
          HhLoadingMore(label: l10n.walletLoadingMore)
        else if (page.hasMore)
          Padding(
            padding: const EdgeInsets.only(top: HhSpace.sm),
            child: HhButton.text(
              label: l10n.walletShowMore,
              onPressed: () => _loadMore(context, ref),
            ),
          ),
      ],
    );
  }

  /// The append is allowed to fail without taking the ledger with it — the
  /// entries already on screen are still exactly what the server sent.
  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(walletLedgerProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// One ledger entry.
///
/// The signed amount is what separates a credit from a debit, so `+2` and `−2`
/// stay distinguishable with the colour removed — the same rule that stops any
/// status badge relying on its tone.
class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final WalletTransaction entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final credit = entry.isCredit;

    return HhCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: HhIcon(
              _glyph(entry.kind),
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
                Text(_kindLabel(entry.kind, l10n), style: HhTypography.label),
                const SizedBox(height: 2),
                Text(
                  _stamp(entry.createdAt.wallClock),
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
            ],
          ),
        ],
      ),
    );
  }

  /// A glyph per kind, so a row is scannable without reading the word.
  ///
  /// Deliberately not an `HhBadge`: a badge's tone answers "whose turn is it,
  /// and did it end well?", and a ledger entry is an event with neither.
  /// Inventing five badges for it would dilute a vocabulary the design keeps
  /// small on purpose.
  static String _glyph(String kind) => switch (kind) {
    WalletTransactionKind.registrationBonus => HhIconPath.checkCircle,
    WalletTransactionKind.topUp => HhIconPath.plus,
    WalletTransactionKind.candidateUnlock => HhIconPath.lock,
    WalletTransactionKind.adminAdjustment => HhIconPath.edit,
    WalletTransactionKind.reversal => HhIconPath.refresh,
    _ => HhIconPath.wallet,
  };

  /// Exhaustive over the five kinds, with a fallback that still says something
  /// true. A newer server's sixth kind keeps its amount and its balance, which
  /// is the part an employer is checking.
  static String _kindLabel(String kind, AppL10n l10n) => switch (kind) {
    WalletTransactionKind.registrationBonus =>
      l10n.walletKindRegistrationBonus,
    WalletTransactionKind.topUp => l10n.walletKindTopUp,
    WalletTransactionKind.candidateUnlock => l10n.walletKindCandidateUnlock,
    WalletTransactionKind.adminAdjustment => l10n.walletKindAdminAdjustment,
    WalletTransactionKind.reversal => l10n.walletKindReversal,
    _ => l10n.walletKindOther,
  };
}

/// `RefreshIndicator` only fires on a scrollable child, and the error state is
/// not one — so pull-to-refresh would be dead on the screen where a user most
/// wants to retry.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}

/// `YYYY-MM-DD HH:MM`, from the **wall clock the server resolved**.
///
/// Deliberately not a `DateFormat`: §8.3's display policy is still an open
/// decision, and the rest of the app renders an ISO date for the same reason.
/// A ledger needs the time as well — two entries a minute apart are otherwise
/// indistinguishable — and the wall-clock fields need no policy to be right.
///
/// Never `.toLocal()`: that re-renders in the *device* zone and quietly moves
/// every timestamp for anyone outside Uzbekistan.
String _stamp(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';
