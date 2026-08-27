import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';
import 'package:jobbridge_app/src/features/wallet/domain/ledger_sign.dart';
import 'package:jobbridge_app/src/features/wallet/domain/unlock.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/transaction_history_screen.dart';

/// §06's E-52 history and E-53 detail.
class _FakeWallet implements WalletRepository {
  _FakeWallet({this.pages = const []});

  List<List<WalletTransaction>> pages;

  /// Every request, so a test can assert what the *screen* asked for rather
  /// than what it did with the answer.
  final requests = <({int offset, LedgerSign? sign})>[];

  List<int> get requestedOffsets =>
      requests.map((r) => r.offset).toList();

  @override
  Future<Wallet> fetch() async => Wallet.fromJson(const {
    'balanceCoins': 8,
    'balanceValueUzs': 80000,
    'pricing': <String, int>{
      'coinPriceUzs': 10000,
      'candidateUnlockCoins': 2,
      'candidateUnlockUzs': 20000,
    },
    'registrationBonusAt': null,
  });

  @override
  Future<List<WalletTransaction>> transactions({
    int limit = walletPageSize,
    int offset = 0,
    LedgerSign? sign,
  }) async {
    requests.add((offset: offset, sign: sign));

    // Answered from the offset, not from how many times it has been called.
    // A filter is its own provider instance now, and switching back and forth
    // re-requests page zero — a call counter would serve page two instead and
    // the screen would look like it had lost the ledger.
    var start = 0;
    var page = const <WalletTransaction>[];
    for (final candidate in pages) {
      if (start == offset) {
        page = candidate;
        break;
      }
      start += candidate.length;
    }

    // **The server filters, not the screen.** A fake that ignored `sign` would
    // let the screen go back to filtering what it had loaded and every case
    // below would still pass — which is exactly how the old behaviour hid.
    if (sign == null) return page;

    return page
        .where((e) => e.isCredit == (sign == LedgerSign.credit))
        .toList();
  }

  @override
  Future<UnlockState> unlockState(String candidateUserId) =>
      throw UnsupportedError('history must not read an unlock');

  @override
  Future<UnlockResult> unlock(String candidateUserId) =>
      throw UnsupportedError('history must not buy an unlock');
}

WalletTransaction _entry({
  required String id,
  required String kind,
  required int amountCoins,
  required int balanceAfter,
  String createdAt = '2026-08-10T13:51:00+05:00',
  int? amountUzs,
  String? reason,
  String? referenceId,
}) => WalletTransaction.fromJson({
  'id': id,
  'kind': kind,
  'amountCoins': amountCoins,
  'balanceAfter': balanceAfter,
  'amountUzs': amountUzs,
  'referenceId': referenceId,
  'reason': reason,
  'createdAt': createdAt,
});

void main() {
  Future<_FakeWallet> pump(
    WidgetTester tester, {
    required List<WalletTransaction> entries,
    List<List<WalletTransaction>>? pages,
  }) async {
    // Tall enough to lay out a full page of twenty rows and the control under
    // them: a `ListView` builds only what its viewport reaches, so on a
    // phone-sized surface `Show more` is not in the tree to be found.
    tester.view.physicalSize = const Size(1080, 9000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeWallet(pages: pages ?? [entries]);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [walletRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const TransactionHistoryScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  final bonus = _entry(
    id: 'bonus',
    kind: WalletTransactionKind.registrationBonus,
    amountCoins: 10,
    balanceAfter: 10,
    createdAt: '2026-07-02T09:00:00+05:00',
  );
  final unlock = _entry(
    id: 'unlock',
    kind: WalletTransactionKind.candidateUnlock,
    amountCoins: -2,
    balanceAfter: 8,
    referenceId: 'cand-1',
  );
  final topUp = _entry(
    id: 'topup',
    kind: WalletTransactionKind.topUp,
    amountCoins: 5,
    balanceAfter: 13,
    amountUzs: 50000,
    referenceId: 'ORD-88431',
    createdAt: '2026-08-12T10:00:00+05:00',
  );

  group('E-52: month headers', () {
    testWidgets('one header per month, in the order the server sent', (
      tester,
    ) async {
      // Grouped by walking the list rather than bucketing, because the server's
      // ordering is the intended one — newest first.
      await pump(tester, entries: [topUp, unlock, bonus]);

      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('July 2026'), findsOneWidget);
    });

    testWidgets('two entries in one month share a header', (tester) async {
      await pump(tester, entries: [topUp, unlock]);

      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('July 2026'), findsNothing);
    });
  });

  group('E-52: the filter reads the sign, not the kind', () {
    testWidgets('spent shows only debits', (tester) async {
      await pump(tester, entries: [topUp, unlock, bonus]);

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Candidate unlock'), findsOneWidget);
      expect(find.text('Top-up'), findsNothing);
      expect(find.text('Registration bonus'), findsNothing);
    });

    testWidgets('topped up shows only credits', (tester) async {
      await pump(tester, entries: [topUp, unlock, bonus]);

      await tester.tap(find.text('Topped up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Top-up'), findsOneWidget);
      expect(find.text('Registration bonus'), findsOneWidget);
      expect(find.text('Candidate unlock'), findsNothing);
    });

    testWidgets('a credit reversal counts as topped up, not spent', (
      tester,
    ) async {
      // The reason the filter reads `isCredit` rather than a list of kinds: a
      // reversal is a credit that undoes a debit, and an admin adjustment can
      // be either. A kind-based filter would have to guess.
      final reversal = _entry(
        id: 'rev',
        kind: WalletTransactionKind.reversal,
        amountCoins: 2,
        balanceAfter: 10,
      );

      await pump(tester, entries: [reversal, unlock]);

      await tester.tap(find.text('Topped up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Reversal'), findsOneWidget);

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Reversal'), findsNothing);
    });

    testWidgets('an unknown kind still lands on one side', (tester) async {
      // A sixth kind from a newer server must not vanish from both filters,
      // which is exactly what a hard-coded list of kinds would do to it.
      final newer = _entry(
        id: 'new',
        kind: 'promotional_grant',
        amountCoins: 4,
        balanceAfter: 12,
      );

      await pump(tester, entries: [newer]);

      await tester.tap(find.text('Topped up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Wallet activity'), findsOneWidget);
      expect(find.text('+4 Coins'), findsOneWidget);
    });

    testWidgets('an empty filter result is not an empty wallet', (
      tester,
    ) async {
      // §11 wants the two told apart: one is fixed by clearing the filter, the
      // other by using the app.
      await pump(tester, entries: [bonus]);

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('No activity of this kind yet'),
        findsOneWidget,
      );
      expect(find.text('Reset'), findsOneWidget);

      // Clearing the filter is a request too, not a re-render of what is
      // already held: the whole ledger is a different slice.
      await tester.tap(find.text('Reset'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Registration bonus'), findsOneWidget);
    });
  });

  group('E-53: one entry in full', () {
    Future<void> open(WidgetTester tester, WalletTransaction e) async {
      await pump(tester, entries: [e]);
      await tester.tap(find.text(kindLabelFor(e)));
      await tester.pumpAndSettle();
    }

    testWidgets('a top-up shows the som it was bought at, and its order', (
      tester,
    ) async {
      // Never recomputed from today's price (§10.5), and the reference is the
      // payment order — the number a provider dispute is actually about.
      await open(tester, topUp);

      expect(find.text('Amount paid'), findsOneWidget);
      expect(find.text('50,000 UZS'), findsOneWidget);
      expect(find.text('ORD-88431'), findsOneWidget);
      expect(find.text('+5 Coins'), findsWidgets);
      expect(find.text('Balance after'), findsOneWidget);
    });

    testWidgets("an unlock never shows the candidate's id as a reference", (
      tester,
    ) async {
      // `referenceId` on an unlock is a candidate's user id. It identifies a
      // person, not a transaction, and telling an employer to read it out to
      // support would be handing over somebody's identifier for no reason.
      await open(tester, unlock);

      expect(find.text('cand-1'), findsNothing);
      expect(find.text('unlock'), findsOneWidget);
    });

    testWidgets('a bonus shows no money row at all', (tester) async {
      // Priced in Coins and never touched som, so there is nothing to show.
      await open(tester, bonus);

      expect(find.text('Amount paid'), findsNothing);
      expect(find.text('+10 Coins'), findsWidgets);
    });

    testWidgets('a correction says why both entries exist (BR-24)', (
      tester,
    ) async {
      final adjustment = _entry(
        id: 'adj',
        kind: WalletTransactionKind.adminAdjustment,
        amountCoins: 5,
        balanceAfter: 13,
        reason: 'Goodwill after the failed top-up on 9 August',
      );

      await open(tester, adjustment);

      expect(find.textContaining('corrects an earlier one'), findsOneWidget);
      expect(find.text('Reason'), findsOneWidget);
      expect(
        find.text('Goodwill after the failed top-up on 9 August'),
        findsOneWidget,
      );
    });

    testWidgets('the support notice states the append-only guarantee', (
      tester,
    ) async {
      // An employer disputing a charge should know the ledger cannot have been
      // altered — which is the whole point of BR-24, said where it matters.
      await open(tester, topUp);

      expect(
        find.textContaining('Nothing in this history can be edited or deleted'),
        findsOneWidget,
      );
      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('paging is still honest under a filter', () {
    testWidgets('a filtered page that comes back short is the whole answer', (
      tester,
    ) async {
      // **This case reversed on 2026-08-28, and the reversal is the point.**
      // While the filter was client-side, a short filtered list was not
      // evidence of anything — it was "the spends among the twenty rows we
      // happen to hold" — so "show more" had to stay offered or an incomplete
      // list would look complete.
      //
      // The server filters now, so a short page *is* the end of that slice,
      // and still offering "show more" would invite a request that returns
      // nothing and reads as a bug.
      final full = [
        for (var i = 0; i < walletPageSize; i++)
          _entry(
            id: 'c$i',
            kind: WalletTransactionKind.topUp,
            amountCoins: 1,
            balanceAfter: 100 - i,
          ),
      ];

      await pump(tester, entries: full, pages: [full]);

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The server answered "no debits", so this is the whole answer and not a
      // window onto it. Offering "show more" would invite a request that comes
      // back empty, which reads as a bug rather than as an end.
      expect(
        find.textContaining('No activity of this kind yet'),
        findsOneWidget,
      );
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('a full filtered page still offers more', (tester) async {
      final debits = [
        for (var i = 0; i < walletPageSize; i++)
          _entry(
            id: 'd$i',
            kind: WalletTransactionKind.candidateUnlock,
            amountCoins: -2,
            balanceAfter: 100 - i,
          ),
      ];

      await pump(tester, entries: debits, pages: [debits]);

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // A full page is the only evidence there may be another, and it is now
      // evidence about the *filtered* ledger rather than the whole one.
      expect(find.text('Show more'), findsOneWidget);
    });

    testWidgets('show more pages the slice on screen, not the whole ledger', (
      tester,
    ) async {
      final debits = [
        for (var i = 0; i < walletPageSize; i++)
          _entry(
            id: 'd$i',
            kind: WalletTransactionKind.candidateUnlock,
            amountCoins: -2,
            balanceAfter: 100 - i,
          ),
      ];

      final fake = await pump(
        tester,
        entries: debits,
        pages: [debits, const []],
      );

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.text('Show more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The second request carries the filter. Without it the append would be
      // twenty rows of the *unfiltered* ledger landing under a heading that
      // says otherwise.
      final appended = fake.requests.last;
      expect(appended.sign, LedgerSign.debit);
      expect(appended.offset, walletPageSize);
    });
  });
}

/// The English label the row renders for [e], so a test can tap it.
String kindLabelFor(WalletTransaction e) => switch (e.kind) {
  WalletTransactionKind.registrationBonus => 'Registration bonus',
  WalletTransactionKind.topUp => 'Top-up',
  WalletTransactionKind.candidateUnlock => 'Candidate unlock',
  WalletTransactionKind.adminAdjustment => 'Administrator adjustment',
  WalletTransactionKind.reversal => 'Reversal',
  _ => 'Wallet activity',
};
