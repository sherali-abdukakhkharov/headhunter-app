import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/transaction_detail_screen.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_transaction_row.dart';
import 'package:jobbridge_app/src/shared/widgets/refreshable_fill.dart';

/// Opens the full Coin ledger (§06, E-52).
Future<void> showTransactionHistory(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
    );

/// Which entries a filter admits.
enum _Filter {
  all,
  /// Coins arriving: the registration bonus, a top-up, a credit adjustment.
  incoming,
  /// Coins leaving: an unlock, a debit adjustment.
  outgoing;

  bool admits(WalletTransaction e) => switch (this) {
    _Filter.all => true,
    _Filter.incoming => e.isCredit,
    _Filter.outgoing => !e.isCredit,
  };
}

/// The whole ledger, filtered and grouped by month (§06, E-52).
///
/// ## The filter reads the sign, not the kind
///
/// "Topped up" and "spent" look like they name kinds, and they do not: an
/// `admin_adjustment` can be either, and a `reversal` is a credit that undoes a
/// debit. Filtering on [WalletTransaction.isCredit] therefore puts every entry
/// on exactly one side and needs no update when the server adds a sixth kind —
/// whereas a list of kind codes would silently drop the new one from both
/// filters.
///
/// ## The filter is client-side, and that has a visible edge
///
/// `GET /wallet/transactions` takes only `limit` and `offset`, so filtering
/// happens over what has been loaded. Choosing "spent" on a first page of
/// twenty shows the spends *in those twenty*, not all spends ever. That is why
/// "show more" stays offered whenever the server may hold more, even when the
/// filtered list looks short: the alternative is a list that looks complete and
/// is not. Server-side filtering is recorded in TODO.md as a backend ask.
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final ledger = ref.watch(walletLedgerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletHistoryTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(walletLedgerProvider),
          child: switch (ledger) {
            AsyncValue(hasError: true, :final error?) => RefreshableFill(
              child: Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(walletLedgerProvider),
                ),
              ),
            ),
            AsyncData(:final value) => _Body(
              page: value,
              filter: _filter,
              onFilter: (f) => setState(() => _filter = f),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.page,
    required this.filter,
    required this.onFilter,
  });

  final LedgerPage page;
  final _Filter filter;
  final ValueChanged<_Filter> onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final shown = page.entries.where(filter.admits).toList();

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        Wrap(
          spacing: HhSpace.sm,
          runSpacing: HhSpace.sm,
          children: [
            for (final f in _Filter.values)
              HhFilterChip(
                label: _label(f, l10n),
                selected: f == filter,
                onTap: () => onFilter(f),
              ),
          ],
        ),
        const SizedBox(height: HhSpace.lg),

        if (shown.isEmpty)
          HhEmptyState(
            title: l10n.stateEmptyTitle,
            // A filter that matched nothing is a different state from a wallet
            // that has never moved, and §11's state table wants them told
            // apart: one is resolved by clearing the filter, the other by using
            // the app.
            message: filter == _Filter.all
                ? l10n.walletActivityEmpty
                : l10n.walletHistoryNoMatch,
            actionLabel: filter == _Filter.all ? null : l10n.filtersReset,
            onAction: filter == _Filter.all
                ? null
                : () => onFilter(_Filter.all),
          )
        else
          ..._grouped(context, shown),

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

  /// Month headers, in the order the entries already arrive in (newest first).
  ///
  /// Grouped by walking the list rather than by bucketing into a map, because
  /// the server's ordering *is* the intended order and a map would need it
  /// sorted back. One header per change of month.
  List<Widget> _grouped(BuildContext context, List<WalletTransaction> entries) {
    final month = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    );
    final out = <Widget>[];
    String? current;

    for (final e in entries) {
      final label = month.format(e.createdAt.wallClock);
      if (label != current) {
        current = label;
        out.add(
          Padding(
            padding: EdgeInsets.only(
              top: out.isEmpty ? 0 : HhSpace.lg,
              bottom: HhSpace.sm,
            ),
            child: Text(
              label,
              style: HhTypography.overline.copyWith(
                color: HhColors.inkMuted,
              ),
            ),
          ),
        );
      }
      out
        ..add(
          WalletTransactionRow(
            entry: e,
            onTap: () => showTransactionDetail(context, entry: e),
          ),
        )
        ..add(const SizedBox(height: HhSpace.sm));
    }

    return out;
  }

  String _label(_Filter f, AppL10n l10n) => switch (f) {
    _Filter.all => l10n.walletHistoryAll,
    _Filter.incoming => l10n.walletHistoryIncoming,
    _Filter.outgoing => l10n.walletHistoryOutgoing,
  };

  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(walletLedgerProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
