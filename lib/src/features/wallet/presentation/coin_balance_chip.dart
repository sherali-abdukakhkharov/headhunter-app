import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/wallet/data/wallet_repository.dart';
import 'package:headhunter_app/src/features/wallet/presentation/wallet_screen.dart';

/// The Coin balance, in an employer app bar, opening the wallet (§06, E-42).
///
/// ## Why this exists rather than a sixth tab
///
/// The wallet TZ lists Wallet as an employer bottom-nav destination, which
/// would be a **sixth** tab — and the design keeps five (Bosh sahifa ·
/// Vakansiyalar · Nomzodlar · Xabarlar · Kompaniya) with a constant 70pt bar.
/// The designer resolved it by making the balance itself the entry point: it
/// rides in the app bar of the surfaces where Coins get spent, so the wallet is
/// always one tap away from the decision to spend, and never a tab nobody
/// visits.
///
/// That is also why it shows a **number rather than a label**. The chip is not
/// navigation furniture; it is the figure an employer needs before they tap a
/// priced button, and tapping it is the way to change that figure.
///
/// Silent until the balance is known. A chip that said "—" or spun would draw
/// the eye to the least important thing in the bar.
class CoinBalanceChip extends ConsumerWidget {
  const CoinBalanceChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final balance = ref.watch(walletProvider).value?.balanceCoins;

    if (balance == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Semantics(
        button: true,
        label: l10n.walletCoins(balance),
        child: InkWell(
          onTap: () => showWallet(context),
          borderRadius: HhRadius.pillAll,
          child: Container(
            height: 34,
            // Asymmetric on purpose, from the design: the glyph needs less
            // breathing room on its side than the number does on its.
            padding: const EdgeInsets.only(left: 8, right: 11),
            decoration: const BoxDecoration(
              color: HhColors.brand50,
              borderRadius: HhRadius.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HhIcon(
                  HhIconPath.coin,
                  size: 16,
                  color: HhColors.brand600,
                  strokeWidth: 2,
                ),
                const SizedBox(width: 6),
                Text(
                  '$balance',
                  style: HhTypography.badge.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: HhColors.brand600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
