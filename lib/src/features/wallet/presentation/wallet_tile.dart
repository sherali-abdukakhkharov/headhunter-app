import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_screen.dart';

/// §6.2's Wallet widget: balance, approximate UZS value, and a way in.
///
/// Lives in the wallet feature rather than in whatever screen hosts it, because
/// §6.2 puts it on the employer dashboard and the dashboard is M5's unfinished
/// half. Until that lands the tile sits on the company tab, which is the built
/// employer-account surface — one widget, moved later rather than written
/// twice.
///
/// **A failure here is quiet on purpose.** The tile is a summary beside an
/// employer's profile, so an unreachable wallet must not turn that screen into
/// an error page. It says the balance is unavailable and still opens
/// [WalletScreen], which renders the failure properly and offers the retry.
class WalletTile extends ConsumerWidget {
  const WalletTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final wallet = ref.watch(walletProvider);

    return HhCard(
      onTap: () => showWallet(context),
      child: Row(
        children: [
          const HhIcon(
            HhIconPath.wallet,
            size: 20,
            color: HhColors.brand600,
            strokeWidth: 2,
          ),
          const SizedBox(width: HhSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.walletTitle, style: HhTypography.label),
                const SizedBox(height: 2),
                Text(
                  switch (wallet) {
                    AsyncValue(hasError: true) => l10n.walletBalanceUnavailable,
                    // The server's UZS figure, never coins x price computed
                    // here (§6.6, §12.3.1).
                    AsyncData(:final value) =>
                      '${l10n.walletCoins(value.balanceCoins)}'
                          ' · ${l10n.walletApproxUzs(value.balanceValueUzs)}',
                    _ => l10n.stateLoading,
                  },
                  style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                ),
              ],
            ),
          ),
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkMuted,
            strokeWidth: 2,
          ),
        ],
      ),
    );
  }
}
