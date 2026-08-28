import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_wallet.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_transaction_row.dart';

/// §10.5's employer wallets — the last screen of the admin module.
///
/// ## Three of §10.5's four parts are here, and one is not
///
/// The wallet half is built: balance, the immutable ledger, and the manual
/// adjustment BR-24 governs. **The prices are now editable too** — the route
/// exists as of 2026-08-28, and [Routes.adminPricing] is one tap from here.
///
/// The **payment order search is still empty**, and that is not a missing
/// route any more: `GET /admin/payments` exists with §10.5's six filters. It
/// is that top-up is not live on the client (M13, waiting on merchant
/// credentials), so there are no orders to search for. That is **stated on
/// this screen** rather than left as a blank somebody reports as a bug, which
/// is the same choice §10.3 made about label editing.
///
/// ## The order is the server's
///
/// Largest balance first, which is where both the money and the risk are.
/// Nothing here re-sorts, and the screen says so — otherwise the first question
/// is where the sort control went.
///
/// ## Nothing is prefetched
///
/// Every read of a wallet is audited (§11.1): a balance and a payment history
/// are financial records about an identifiable business. A screen that warmed
/// the next page would write audit entries for wallets nobody looked at.
class AdminWalletsScreen extends ConsumerWidget {
  const AdminWalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final wallets = ref.watch(adminWalletsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminWalletsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminWalletsProvider),
        child: switch (wallets) {
          // Error first: retry is disabled app-wide, so a failure is terminal
          // and matching the loading arm first spins over it.
          AsyncValue(hasError: true, :final error?) => ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhErrorState(
                title: failureTitle(error, l10n),
                message: error is ApiException
                    ? error.message
                    : l10n.stateErrorBody,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(adminWalletsProvider),
              ),
            ],
          ),
          AsyncData(:final value) => _List(page: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.page});

  final AdminQueuePage<AdminWallet> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        // The half of §10.5 that is still waiting on a live provider, said
        // before the list rather than discovered by looking for it.
        HhNotice(
          title: l10n.adminPaymentsPending,
          message: l10n.adminPaymentsPendingBody,
          iconPath: HhIconPath.infoCircle,
        ),
        const SizedBox(height: HhSpace.md),

        // The prices live beside the wallets because this is where the money is
        // read, and a wallet balance means nothing without what a Coin costs.
        HhCard(
          onTap: () => context.push(Routes.adminPricing),
          child: Row(
            children: [
              const HhIcon(
                HhIconPath.coin,
                size: 20,
                color: HhColors.inkMuted,
                strokeWidth: 2,
              ),
              const SizedBox(width: HhSpace.md),
              Expanded(
                child: Text(
                  l10n.adminPricingTitle,
                  style: HhTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const HhIcon(
                HhIconPath.chevronRight,
                size: 18,
                color: HhColors.inkDisabled,
              ),
            ],
          ),
        ),
        const SizedBox(height: HhSpace.sectionGap),

        if (page.items.isEmpty)
          HhEmptyState(
            title: l10n.adminWalletsEmpty,
            message: l10n.adminWalletsEmptyBody,
          )
        else ...[
          Text(l10n.adminWalletsOrder, style: HhTypography.caption),
          const SizedBox(height: HhSpace.lg),
          for (final wallet in page.items) ...[
            _WalletRow(wallet: wallet),
            const SizedBox(height: HhSpace.md),
          ],
        ],

        if (page.isLoadingMore)
          HhLoadingMore(label: l10n.commonLoadingMore)
        else if (page.hasMore)
          Padding(
            padding: const EdgeInsets.only(top: HhSpace.sm),
            child: HhButton.text(
              label: l10n.commonShowMore,
              onPressed: () => _loadMore(context, ref),
            ),
          ),
      ],
    );
  }

  /// A failed append leaves the list on screen and says so, rather than
  /// replacing rows that are still correct with an error page.
  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(adminWalletsProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({required this.wallet});

  final AdminWallet wallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () =>
          GoRouter.of(context).go(Routes.adminWalletFor(wallet.userId)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // The employer's own words (§2.4), and **null is a real
                  // state**: BR-14 erases the person while §6.7 keeps the
                  // payment record, so a wallet can outlive its owner. Said
                  // rather than left blank, so a thin row is not read as
                  // broken data.
                  wallet.name ?? wallet.phone ?? l10n.adminWalletUnnamed,
                  style: HhTypography.subtitle,
                ),
                if (wallet.name != null && wallet.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(wallet.phone!, style: HhTypography.caption),
                ],
                const SizedBox(height: HhSpace.xs),
                Text(
                  wallet.registrationBonusAt == null
                      // The absence is the diagnostic part: BR-15 grants the
                      // bonus exactly once, and a wallet with no date is what
                      // a grant that never happened looks like.
                      ? l10n.adminWalletNoBonus
                      : l10n.adminWalletBonusOn(
                          walletStamp(wallet.registrationBonusAt!.wallClock),
                        ),
                  style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: HhSpace.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.walletCoins(wallet.balanceCoins),
                style: HhTypography.subtitle,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.adminWalletUnlocks(wallet.unlockCount),
                style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(width: HhSpace.sm),
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkDisabled,
          ),
        ],
      ),
    );
  }
}
