import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/wallet/data/wallet_repository.dart';
import 'package:headhunter_app/src/features/wallet/domain/unlock.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet.dart';
import 'package:headhunter_app/src/features/wallet/presentation/wallet_screen.dart';

/// Offers the §6.6 confirmation sheet, and returns the entitlement if one was
/// obtained.
///
/// Returns null when the employer backed out, could not afford it, or the
/// purchase failed — the caller only needs to know whether contact is now open.
Future<Unlock?> showUnlockSheet(
  BuildContext context, {
  required String candidateUserId,
  required Wallet wallet,
  required WalletPricing pricing,
}) => showModalBottomSheet<Unlock>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _UnlockSheet(
    candidateUserId: candidateUserId,
    wallet: wallet,
    pricing: pricing,
  ),
);

/// §6.6's confirmation sheet: **cost, current balance and remaining balance,
/// shown before anything is charged.**
///
/// ## Why all three figures, before the button
///
/// §6.6 asks for them by name, and the reason is that a Coin balance is not
/// money an employer handles daily — "2 Coins" means nothing without "of 8, and
/// 6 left". Without the sheet the only way to learn what an unlock costs is to
/// have paid it.
///
/// ## The one derived figure on the screen, and why it is allowed
///
/// Everything else in this feature reads amounts from the server, because
/// §12.3.1 forbids the client computing one. The remaining balance is
/// subtracted here, and the distinction is worth stating: both inputs are
/// server integers, a Coin count is not an amount payable, no endpoint returns
/// it, and §6.6 requires it on this sheet.
///
/// **It is a preview, never a result.** After the charge the new balance comes
/// from refetching the wallet, in the confirm handler below. If this
/// subtraction and the server ever disagree, the server is right and the
/// ledger says so.
class _UnlockSheet extends ConsumerStatefulWidget {
  const _UnlockSheet({
    required this.candidateUserId,
    required this.wallet,
    required this.pricing,
  });

  final String candidateUserId;
  final Wallet wallet;
  final WalletPricing pricing;

  @override
  ConsumerState<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends ConsumerState<_UnlockSheet> {
  bool _busy = false;

  /// Whether the balance covers it, decided *before* the request.
  ///
  /// UAT-19 wants the unlock blocked and top-up offered, and asking the server
  /// first would mean routing on a refusal rather than on what is already
  /// known. The 402 is still handled below: the balance can move between this
  /// frame and the tap — another device, or an administrator adjustment — and a
  /// pre-check is an optimisation, not the authority.
  bool get _affordable =>
      widget.wallet.balanceCoins >= widget.pricing.candidateUnlockCoins;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final cost = widget.pricing.candidateUnlockCoins;
    final balance = widget.wallet.balanceCoins;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HhColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: HhSpace.lg),
              Text(l10n.unlockTitle, style: HhTypography.subtitle),
              const SizedBox(height: HhSpace.sm),
              Text(
                l10n.unlockWhatYouGet,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: HhSpace.lg),
              const Divider(height: 1, color: HhColors.border),
              const SizedBox(height: HhSpace.md),

              _Row(label: l10n.unlockCost, value: l10n.walletCoins(cost)),
              const SizedBox(height: 6),
              _Row(
                label: l10n.unlockBalanceNow,
                value: l10n.walletCoins(balance),
              ),
              const SizedBox(height: 6),
              _Row(
                label: l10n.unlockBalanceAfter,
                // Clamped at zero rather than shown negative: an unaffordable
                // unlock is refused, so "-1 Coins" would be describing a state
                // that cannot exist.
                value: l10n.walletCoins(
                  _affordable ? balance - cost : balance,
                ),
                muted: !_affordable,
              ),

              const SizedBox(height: HhSpace.md),
              const Divider(height: 1, color: HhColors.border),
              const SizedBox(height: HhSpace.lg),

              if (_affordable)
                HhButton(
                  label: l10n.unlockConfirm,
                  loading: _busy,
                  onPressed: _busy ? null : _confirm,
                )
              else
                // UAT-19: blocked, and the way out is top-up rather than an
                // error. Until M13 that route ends in an honest sentence.
                HhButton(
                  label: l10n.unlockTopUpNeeded,
                  iconPath: HhIconPath.wallet,
                  onPressed: _topUp,
                ),

              const SizedBox(height: HhSpace.sm),
              HhButton.text(
                label: l10n.commonCancel,
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Buys the entitlement. One server call, and nothing here simulates it.
  ///
  /// The response is the only truth about what happened, and it does not carry
  /// the new balance — so the wallet is invalidated rather than adjusted by the
  /// cost. An optimistic debit that then turned out to have failed would show
  /// Coins gone with no access, which is the pair BR-18 exists to prevent.
  Future<void> _confirm() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _busy = true);

    try {
      final result = await ref
          .read(walletRepositoryProvider)
          .unlock(widget.candidateUserId);

      switch (result) {
        case UnlockGranted(:final unlock):
          ref
            ..invalidate(walletProvider)
            ..invalidate(walletLedgerProvider)
            ..invalidate(unlockStateProvider(widget.candidateUserId));

          navigator.pop(unlock);
          messenger.showSnackBar(
            SnackBar(
              // UAT-18: a second tap is free, and saying so is better than
              // succeeding silently — an employer who tapped twice should learn
              // the second cost nothing rather than go check the ledger.
              content: Text(
                unlock.charged ? l10n.unlockDone : l10n.unlockAlready,
              ),
            ),
          );

        case UnlockUnaffordable(:final message):
          // The balance moved under us. The server's sentence already carries
          // both numbers, in this user's language.
          if (!mounted) return;
          setState(() => _busy = false);
          ref.invalidate(walletProvider);
          messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// §6.7's checkout is M13 and needs merchant credentials nobody has yet, so
  /// this opens the wallet — where the same honest sentence lives — rather than
  /// dead-ending here.
  Future<void> _topUp() async {
    Navigator.of(context).pop();
    await showWallet(context);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.muted = false});

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: HhTypography.body.copyWith(color: HhColors.inkMuted),
        ),
      ),
      Text(
        value,
        style: HhTypography.bodyStrong.copyWith(
          color: muted ? HhColors.inkMuted : HhColors.ink,
        ),
      ),
    ],
  );
}
