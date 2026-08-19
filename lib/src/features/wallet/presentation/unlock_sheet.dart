import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/wallet/data/wallet_repository.dart';
import 'package:headhunter_app/src/features/wallet/domain/unlock.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet.dart';

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
  String? candidateName,
  String? candidateHeadline,
  VoidCallback? onVerify,
}) => showModalBottomSheet<Unlock>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _UnlockSheet(
    candidateUserId: candidateUserId,
    wallet: wallet,
    pricing: pricing,
    candidateName: candidateName,
    candidateHeadline: candidateHeadline,
    onVerify: onVerify,
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
    this.candidateName,
    this.candidateHeadline,
    this.onVerify,
  });

  final String candidateUserId;
  final Wallet wallet;
  final WalletPricing pricing;

  /// Who is being bought. §06's third principle — paying must never lose the
  /// candidate — starts here: the name travels into every screen the purchase
  /// opens, so nobody confirms a charge against an anonymous "this candidate".
  final String? candidateName;

  /// Their occupation line, shown under the name exactly as the design draws
  /// it.
  final String? candidateHeadline;

  /// Where BR-03 sends them. Null where the caller has nowhere to send them, in
  /// which case the refusal is still reported and simply carries no action.
  final VoidCallback? onVerify;

  @override
  ConsumerState<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends ConsumerState<_UnlockSheet> {
  bool _busy = false;

  /// The server's 402 sentence, once it has refused a purchase this sheet
  /// thought was affordable.
  ///
  /// Held rather than shown as a snackbar because it changes what the sheet
  /// *offers*: the confirm action becomes top-up, in place, with the candidate
  /// still named above it.
  String? _serverShortfall;

  /// The server's 403 sentence: BR-03 refused the purchase.
  ///
  /// Kept here for the same reason as the shortfall, and it matters more: a
  /// snackbar carrying this message *and* a verification action overflows a
  /// 360pt bar in English, and would be worse in Russian. In the sheet both
  /// fit, and the candidate stays named above them.
  String? _verificationRefusal;

  /// Whether the balance covers it, decided *before* the request.
  ///
  /// UAT-19 wants the unlock blocked and top-up offered, and asking the server
  /// first would mean routing on a refusal rather than on what is already
  /// known. The 402 is still handled below: the balance can move between this
  /// frame and the tap — another device, or an administrator adjustment — and a
  /// pre-check is an optimisation, not the authority.
  bool get _affordable =>
      _serverShortfall == null &&
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

              // The name, directly under the title, as drawn. An employer about
              // to spend Coins should see who on, without scrolling back.
              if (widget.candidateName case final name? when name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    switch (widget.candidateHeadline) {
                      final String h when h.isNotEmpty => '$name — $h',
                      _ => name,
                    },
                    style: HhTypography.caption.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ),

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

              // Shown only when the *server* refused a purchase this sheet had
              // judged affordable. Its own sentence, carrying its own numbers —
              // and it appears here rather than replacing the sheet, so the
              // candidate above it survives the refusal.
              if (_serverShortfall case final shortfall?) ...[
                HhNotice.restricted(
                  title: l10n.unlockInsufficient,
                  message: shortfall,
                ),
                const SizedBox(height: HhSpace.md),
              ],

              // BR-03, which Coins cannot buy past. Same treatment as the
              // shortfall and for the same reason: a refusal belongs beside
              // the candidate it was about.
              if (_verificationRefusal case final refusal?) ...[
                HhNotice.restricted(
                  title: l10n.unlockGoToVerification,
                  message: refusal,
                ),
                const SizedBox(height: HhSpace.md),
              ],

              if (_verificationRefusal != null)
                // Buying is pointless here, so the only action offered is
                // the one that would actually change the answer.
                HhButton(
                  label: l10n.unlockGoToVerification,
                  iconPath: HhIconPath.shieldCheck,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onVerify?.call();
                  },
                )
              else if (_affordable)
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

          // The outcome is reported by the caller, as §06 draws it: a banner on
          // the profile the purchase just changed, carrying the Coins spent and
          // the balance left. A snackbar here as well would say the same thing
          // twice and take the shorter-lived half of it with the sheet.
          navigator.pop(unlock);

        case UnlockUnaffordable(:final message):
          // The balance moved under us — another device, or an administrator
          // adjustment. The sheet stays open on the short-balance state rather
          // than closing: closing would be the redirect §06 forbids, one step
          // later.
          if (!mounted) return;
          setState(() {
            _busy = false;
            _serverShortfall = message;
          });
          ref.invalidate(walletProvider);

        case UnlockNeedsVerification(:final message):
          // BR-03, and **not** a route to top-up: Coins cannot buy past §7,
          // so the sheet swaps its action for the one that can.
          if (!mounted) return;
          setState(() {
            _busy = false;
            _verificationRefusal = message;
          });
      }
    } on ApiException catch (e) {
      // 404 and 409 land here. Neither has a destination — an absent candidate
      // and a multi-role account unlocking itself are both dead ends, so the
      // sheet says what happened and stays put.
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// **Never a redirect.** §06's third principle is that paying must not lose
  /// the candidate, so the top-up route opens *over* this sheet and returns to
  /// it; the candidate's name travels with it.
  ///
  /// Until M13 ships there is nothing to open — no payment-order endpoint
  /// exists — so this says so in place rather than navigating away to say it
  /// somewhere else. That is the same honest dead end the Wallet's own Top up
  /// gives, minus the trip.
  void _topUp() => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppL10n.of(context).walletTopUpUnavailable)),
  );
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
