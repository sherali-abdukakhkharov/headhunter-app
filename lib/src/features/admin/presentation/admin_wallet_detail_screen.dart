import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_wallet.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_transaction_row.dart';

/// One employer's wallet and its immutable ledger (§10.5, BR-24).
class AdminWalletDetailScreen extends ConsumerWidget {
  const AdminWalletDetailScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final wallet = ref.watch(adminWalletProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminWalletTitle)),
      body: switch (wallet) {
        // 404 first and separately: a user who never became an employer has no
        // wallet, and that is an answer rather than a fault. Same treatment
        // UAT-15 gives a vacancy that is gone — its own notice, a way back,
        // and **no retry**, because retrying would fail identically.
        AsyncValue(hasError: true, error: final ApiException e)
            when e.statusCode == 404 =>
          ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhNotice(
                title: l10n.adminWalletGone,
                message: l10n.adminWalletGoneBody,
                iconPath: HhIconPath.infoCircle,
              ),
              const SizedBox(height: HhSpace.lg),
              HhButton.secondary(
                label: l10n.commonBack,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        AsyncValue(hasError: true, :final error?) => ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            HhErrorState(
              title: failureTitle(error, l10n),
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(adminWalletProvider(userId)),
            ),
          ],
        ),
        AsyncData(:final value) => _Body(wallet: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.wallet});

  final AdminWalletDetail wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        Text(
          wallet.name ?? wallet.phone ?? l10n.adminWalletUnnamed,
          style: HhTypography.title,
        ),
        if (wallet.name != null && wallet.phone != null) ...[
          const SizedBox(height: HhSpace.xs),
          Text(wallet.phone!, style: HhTypography.caption),
        ],

        const SizedBox(height: HhSpace.lg),
        HhCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.walletCoins(wallet.balanceCoins),
                style: HhTypography.title,
              ),
              const SizedBox(height: HhSpace.xs),
              Text(
                l10n.adminWalletUnlocks(wallet.unlockCount),
                style: HhTypography.caption,
              ),
              const SizedBox(height: 2),
              Text(
                wallet.registrationBonusAt == null
                    ? l10n.adminWalletNoBonus
                    : l10n.adminWalletBonusOn(
                        walletStamp(wallet.registrationBonusAt!.wallClock),
                      ),
                style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: HhSpace.md),
        HhButton.secondary(
          label: l10n.adminAdjustAction,
          iconPath: HhIconPath.coin,
          onPressed: () => _adjust(context, ref),
        ),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminWalletLedger, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.sm),
        // BR-24 said on the screen. An administrator looking at a mistaken
        // adjustment will otherwise go hunting for a way to remove it, and
        // there is none — three database triggers refuse UPDATE, DELETE and
        // TRUNCATE on this table.
        Text(l10n.adminWalletImmutable, style: HhTypography.caption),
        const SizedBox(height: HhSpace.md),

        if (wallet.transactions.isEmpty)
          HhEmptyState(
            title: l10n.adminWalletNoTransactions,
            message: l10n.stateEmptyBody,
          )
        else
          for (final entry in wallet.transactions) ...[
            // The same row the employer's own wallet renders. One widget
            // rather than an admin copy: the two are looking at the same
            // ledger, and a second rendering is how the administrator's
            // account of a transaction comes to disagree with the employer's.
            WalletTransactionRow(entry: entry),
            const SizedBox(height: HhSpace.sm),
          ],
      ],
    );
  }

  Future<void> _adjust(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final result = await showModalBottomSheet<_Adjustment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AdjustSheet(),
    );

    if (result == null) return;

    try {
      final entry = await ref
          .read(adminRepositoryProvider)
          .adjustWallet(
            wallet.userId,
            amountCoins: result.amountCoins,
            reason: result.reason,
          );

      // Refetched rather than patched locally: the new balance and the new
      // entry are both the server's, and a client that spliced its own row in
      // would be writing the ledger — the one thing BR-24 leaves to the server.
      ref
        ..invalidate(adminWalletProvider(wallet.userId))
        // The list shows balances, so it is stale the moment one moves.
        ..invalidate(adminWalletsProvider);

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminAdjustDone(entry.balanceAfter))),
      );
    } on ApiException catch (e) {
      // A 409 here is "the adjustment would take the balance below zero",
      // which the server words itself. Rendered as given, like every other
      // refusal in this module.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// What the sheet returns. A record would do, but naming it keeps the two
/// fields from being swapped at the call site — they are both "the thing the
/// administrator typed".
class _Adjustment {
  const _Adjustment({required this.amountCoins, required this.reason});

  final int amountCoins;
  final String reason;
}

/// §10.5's manual adjustment: a signed Coin amount and a **mandatory** reason.
///
/// The reason is required by the DTO *and* by the database, so this could have
/// let the server refuse. It does not, for the reason every other form in this
/// app gives: an enabled control is a promise that pressing it will do
/// something (MT-013).
class _AdjustSheet extends StatefulWidget {
  const _AdjustSheet();

  @override
  State<_AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<_AdjustSheet> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount.addListener(_onChanged);
    _reason.addListener(_onChanged);
  }

  @override
  void dispose() {
    _amount
      ..removeListener(_onChanged)
      ..dispose();
    _reason
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  /// Null unless the field holds a whole number other than zero.
  ///
  /// Zero is refused by the server — an entry that changes nothing is a ledger
  /// row with no meaning — so it is refused here too, before the request.
  int? get _parsedAmount {
    final value = int.tryParse(_amount.text.trim());
    return value == null || value == 0 ? null : value;
  }

  bool get _canSubmit =>
      _parsedAmount != null && _reason.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // The same shell `AdminDecisionSheet` uses — there is still no `HhSheet`
    // component (it is the one design-system primitive outstanding), so the
    // two are hand-built and worth keeping identical until there is one.
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          // Lifts the sheet clear of the keyboard, which the reason field
          // raises.
          padding: EdgeInsets.only(
            left: HhSpace.gutter,
            right: HhSpace.gutter,
            top: HhSpace.gutter,
            bottom: HhSpace.gutter + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
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
                Text(l10n.adminAdjustAction, style: HhTypography.subtitle),
                const SizedBox(height: HhSpace.md),

                HhTextField(
                  label: l10n.adminAdjustAmount,
                  controller: _amount,
                  hintText: l10n.adminAdjustAmountHint,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  // Digits and a leading minus. A phone keyboard is a hint
                  // rather than a restriction — every platform allows a paste.
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  errorText:
                      _amount.text.trim().isEmpty || _parsedAmount != null
                      ? null
                      : l10n.adminAdjustZero,
                ),
                const SizedBox(height: HhSpace.lg),

                HhTextField(
                  label: l10n.adminAdjustReason,
                  controller: _reason,
                  hintText: l10n.adminAdjustReasonHint,
                  maxLines: 3,
                ),
                const SizedBox(height: HhSpace.lg),

                // BR-24 before the action rather than after it. `restricted`
                // tone because this genuinely is a one-way door: the entry
                // is permanent and it carries the administrator's name.
                HhNotice.restricted(
                  title: l10n.adminAdjustAction,
                  message: l10n.adminAdjustNote,
                ),
                const SizedBox(height: HhSpace.lg),

                HhButton(
                  label: l10n.adminAdjustSubmit,
                  onPressed: _canSubmit
                      ? () => Navigator.of(context).pop(
                          _Adjustment(
                            amountCoins: _parsedAmount!,
                            reason: _reason.text.trim(),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: HhSpace.sm),
                HhButton.text(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
