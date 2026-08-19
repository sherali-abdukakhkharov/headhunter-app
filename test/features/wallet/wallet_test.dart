import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';
import 'package:jobbridge_app/src/features/wallet/domain/unlock.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_screen.dart';

/// The Coin wallet (§6.6, BR-15, BR-24, UAT-16).
class _FakeWallet implements WalletRepository {
  _FakeWallet({required this.wallet, this.pages = const []});

  Wallet wallet;

  /// One entry per page, served in order. An empty list answers every request
  /// with no entries.
  List<List<WalletTransaction>> pages;

  /// Set to fail the *next* `transactions` call, so an append can be made to
  /// fail without the first page having failed.
  ApiException? failNextPage;

  final requestedOffsets = <int>[];

  @override
  Future<Wallet> fetch() async => wallet;

  @override
  Future<List<WalletTransaction>> transactions({
    int limit = walletPageSize,
    int offset = 0,
  }) async {
    requestedOffsets.add(offset);

    if (failNextPage case final failure?) {
      failNextPage = null;
      throw failure;
    }

    final index = requestedOffsets.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  // The wallet *screen* has no business touching an entitlement, so these throw
  // rather than returning something harmless: a screen that started buying
  // unlocks should fail this file loudly. The unlock flow has its own fake, in
  // `candidate_search/unlock_gating_test.dart`.
  @override
  Future<UnlockState> unlockState(String candidateUserId) =>
      throw UnsupportedError('The wallet screen must not read an unlock.');

  @override
  Future<UnlockResult> unlock(String candidateUserId) =>
      throw UnsupportedError('The wallet screen must not buy an unlock.');
}

/// A wallet whose UZS value is **not** `balanceCoins * coinPriceUzs`.
///
/// The fixture disagrees on purpose, the same trick the level-floor test uses
/// on `rank` and `sortOrder`: if any of this ever multiplies Coins by the price
/// instead of reading the server's figure, these numbers are what make it fail
/// here rather than the day a bundle price or a rounding rule lands. §6.6 puts
/// pricing on the server and §12.3.1 forbids the client computing an amount, so
/// the two agreeing is a coincidence of today's configuration, not a rule.
Wallet _wallet({
  int balanceCoins = 8,
  int balanceValueUzs = 75000,
  int coinPriceUzs = 10000,
  int unlockCoins = 2,
  int unlockUzs = 17000,
  String? registrationBonusAt,
}) => Wallet.fromJson({
  'balanceCoins': balanceCoins,
  'balanceValueUzs': balanceValueUzs,
  'pricing': {
    'coinPriceUzs': coinPriceUzs,
    'candidateUnlockCoins': unlockCoins,
    'candidateUnlockUzs': unlockUzs,
  },
  'registrationBonusAt': registrationBonusAt,
});

WalletTransaction _entry({
  required String kind,
  required int amountCoins,
  required int balanceAfter,
  String id = 'tx-1',
  int? amountUzs,
  String? reason,
  String createdAt = '2026-08-10T13:51:00+05:00',
}) => WalletTransaction.fromJson({
  'id': id,
  'kind': kind,
  'amountCoins': amountCoins,
  'balanceAfter': balanceAfter,
  'amountUzs': amountUzs,
  'referenceId': null,
  'reason': reason,
  'createdAt': createdAt,
});

void main() {
  Future<_FakeWallet> pump(WidgetTester tester, _FakeWallet fake) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // The same setting main.dart uses: an error is a terminal state the UI
        // renders, not a retry loop hidden behind a spinner.
        retry: (retryCount, error) => null,
        overrides: [walletRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const WalletScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  group("the balance and the prices are the server's (§6.6, §12.3.1)", () {
    testWidgets('the UZS value is read, never multiplied here', (tester) async {
      // 8 Coins at 10,000 would be 80,000 if this screen did the sum. The
      // server said 75,000, and the server is the only authority on money.
      await pump(tester, _FakeWallet(wallet: _wallet()));

      // §06 puts the value and the price on one line under the balance.
      expect(
        find.text('≈ 75,000 UZS · 1 Coin = 10,000 UZS'),
        findsOneWidget,
      );
      expect(find.textContaining('80,000'), findsNothing);
    });

    testWidgets('the unlock price carries no UZS at all', (tester) async {
      // §06's first principle: a service balance, not a wallet. The UZS figure
      // appears only where money actually changes hands — top-up, payment,
      // receipt — and an unlock is priced in Coins and paid for in Coins.
      //
      // The fixture's unlock UZS (17,000) deliberately disagrees with coins x
      // price (20,000), so this fails loudly if either number reappears here:
      // the server's, or one computed from the Coin price.
      await pump(tester, _FakeWallet(wallet: _wallet()));

      // The cost is named in the rule sentence rather than a price row —
      // §06 replaced the price table with "what a Coin is for".
      expect(
        find.textContaining('2 Coins unlocks one new candidate'),
        findsOneWidget,
      );
      expect(find.textContaining('17,000'), findsNothing);
      expect(find.textContaining('20,000'), findsNothing);
    });

    testWidgets('a reprice moves what is on screen, with no code change', (
      tester,
    ) async {
      // §10.5 lets an administrator change both. Nothing here is compiled in,
      // so the screen follows.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(
            balanceValueUzs: 96000,
            coinPriceUzs: 12000,
            unlockCoins: 3,
            unlockUzs: 36000,
          ),
        ),
      );

      expect(
        find.text('≈ 96,000 UZS · 1 Coin = 12,000 UZS'),
        findsOneWidget,
      );
      expect(
        find.textContaining('3 Coins unlocks one new candidate'),
        findsOneWidget,
      );
    });

    testWidgets('the balance is the wallet response, not the ledger', (
      tester,
    ) async {
      // The headline must not be recovered by summing entries: this ledger's
      // one visible entry says 10, the wallet says 8, and 8 is the balance.
      // Anything that added up the page would show the wrong number the moment
      // the ledger is paged - which it always is.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.registrationBonus,
                amountCoins: 10,
                balanceAfter: 10,
              ),
            ],
          ],
        ),
      );

      expect(find.text('8 Coins'), findsOneWidget);
    });
  });

  group('UAT-16: the registration bonus', () {
    testWidgets('reads as one credit of ten Coins with its own balance', (
      tester,
    ) async {
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(
            balanceCoins: 10,
            balanceValueUzs: 100000,
            registrationBonusAt: '2026-08-10T13:51:00+05:00',
          ),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.registrationBonus,
                amountCoins: 10,
                balanceAfter: 10,
              ),
            ],
          ],
        ),
      );

      expect(find.text('Registration bonus'), findsWidgets);
      expect(find.text('+10 Coins'), findsOneWidget);
      expect(find.text('Balance 10'), findsOneWidget);
    });

    testWidgets('is dated, because "granted once" needs evidence', (
      tester,
    ) async {
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(
            registrationBonusAt: '2026-08-10T13:51:00+05:00',
          ),
        ),
      );

      expect(
        find.text('Registration bonus granted 2026-08-10 13:51'),
        findsOneWidget,
      );
    });

    testWidgets('is absent, not zero, when no bonus was granted', (
      tester,
    ) async {
      // §6.6 allows an instance that grants no free Coins, and an employer who
      // registered before the wallet shipped has no bonus row either. Null is a
      // normal answer, so the line is simply not drawn.
      await pump(tester, _FakeWallet(wallet: _wallet()));

      expect(find.textContaining('Registration bonus granted'), findsNothing);
    });

    testWidgets('renders the wall clock the server sent, not the device zone', (
      tester,
    ) async {
      // +05:00 is Tashkent. A `.toLocal()` anywhere in this path would print
      // 08:51 on a UTC test machine - and would move every timestamp for a user
      // outside Uzbekistan.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.topUp,
                amountCoins: 5,
                balanceAfter: 13,
                createdAt: '2026-08-12T09:05:00+05:00',
              ),
            ],
          ],
        ),
      );

      expect(find.text('2026-08-12 09:05'), findsOneWidget);
    });
  });

  group('BR-24: the ledger is append-only and looks it', () {
    testWidgets('a reversal is its own entry beside what it corrects', (
      tester,
    ) async {
      // The unlock stays. A screen that showed only the net effect, or replaced
      // the debit with a corrected one, would be the rewriting BR-24 forbids -
      // and the database refuses it anyway, so the two would disagree.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                id: 'tx-reversal',
                kind: WalletTransactionKind.reversal,
                amountCoins: 2,
                balanceAfter: 8,
              ),
              _entry(
                id: 'tx-unlock',
                kind: WalletTransactionKind.candidateUnlock,
                amountCoins: -2,
                balanceAfter: 6,
              ),
            ],
          ],
        ),
      );

      expect(find.text('Reversal'), findsOneWidget);
      expect(find.text('+2 Coins'), findsOneWidget);
      expect(find.text('−2 Coins'), findsOneWidget);

      // Two entries, two balances, both on screen. This is the assertion BR-24
      // actually needs: a net figure, or a debit rewritten to its corrected
      // value, would leave only one of these.
      expect(find.text('Balance 6'), findsOneWidget);
      expect(find.text('Balance 8'), findsOneWidget);

      // Once, now. It used to appear twice — the prices block labelled the
      // unlock's cost with the same words the ledger row uses — and §06 removed
      // that block, so the ledger is the only place the phrase appears.
      expect(find.text('Candidate unlock'), findsOneWidget);
    });

    testWidgets('a correction says that it is one', (tester) async {
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.adminAdjustment,
                amountCoins: 5,
                balanceAfter: 13,
                reason: 'Goodwill after the failed top-up on 9 August',
              ),
            ],
          ],
        ),
      );

      expect(find.text('Correction'), findsOneWidget);
      expect(find.text('Administrator adjustment'), findsOneWidget);
    });

    testWidgets('an administrator adjustment shows its reason (§10.5)', (
      tester,
    ) async {
      // The server refuses an adjustment without one, and a reason nobody can
      // read is indistinguishable from a mistake.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.adminAdjustment,
                amountCoins: -3,
                balanceAfter: 5,
                reason: 'Reversing a duplicated top-up',
              ),
            ],
          ],
        ),
      );

      expect(find.text('Reversing a duplicated top-up'), findsOneWidget);
      expect(find.text('−3 Coins'), findsOneWidget);
    });

    testWidgets('an ordinary purchase is not marked as a correction', (
      tester,
    ) async {
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.candidateUnlock,
                amountCoins: -2,
                balanceAfter: 6,
              ),
            ],
          ],
        ),
      );

      expect(find.text('Correction'), findsNothing);
    });

    testWidgets('each row shows the balance the server recorded', (
      tester,
    ) async {
      // These balances are deliberately not a running total of the amounts
      // above them: paging means the client only ever holds a window of the
      // ledger, so accumulating down the list is wrong by construction. Read
      // the field.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                id: 'a',
                kind: WalletTransactionKind.candidateUnlock,
                amountCoins: -2,
                balanceAfter: 41,
              ),
              _entry(
                id: 'b',
                kind: WalletTransactionKind.candidateUnlock,
                amountCoins: -2,
                balanceAfter: 43,
              ),
            ],
          ],
        ),
      );

      expect(find.text('Balance 41'), findsOneWidget);
      expect(find.text('Balance 43'), findsOneWidget);
    });

    testWidgets('a top-up keeps the UZS it was bought at', (tester) async {
      // Never re-derived from today's price: that is what "repricing must not
      // restate history" means once it reaches a screen (§10.5).
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(coinPriceUzs: 12000),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.topUp,
                amountCoins: 5,
                balanceAfter: 13,
                amountUzs: 50000,
              ),
            ],
          ],
        ),
      );

      expect(find.text('50,000 UZS'), findsOneWidget);
      expect(find.text('60,000 UZS'), findsNothing);
    });
  });

  group('credit and debit are not told apart by colour', () {
    testWidgets('a credit carries a plus and a debit a minus sign', (
      tester,
    ) async {
      // The same rule every status badge is held to. Greyscale, colour
      // blindness and a screen reader all get the sign; none of them get the
      // green.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                id: 'credit',
                kind: WalletTransactionKind.topUp,
                amountCoins: 5,
                balanceAfter: 13,
              ),
              _entry(
                id: 'debit',
                kind: WalletTransactionKind.candidateUnlock,
                amountCoins: -2,
                balanceAfter: 8,
              ),
            ],
          ],
        ),
      );

      expect(find.text('+5 Coins'), findsOneWidget);
      expect(find.text('−2 Coins'), findsOneWidget);
    });

    testWidgets('a debit never renders a double negative', (tester) async {
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.candidateUnlock,
                amountCoins: -1,
                balanceAfter: 7,
              ),
            ],
          ],
        ),
      );

      expect(find.text('−1 Coin'), findsOneWidget);
      expect(find.textContaining('−-'), findsNothing);
    });
  });

  group('a newer server', () {
    testWidgets('keeps an unknown kind visible with its amount', (
      tester,
    ) async {
      // §6.7 and §10.5 will both add entry kinds. An employer checking where a
      // Coin went needs the amount and the balance; the word is the part this
      // build can afford not to know.
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: 'promotional_grant',
                amountCoins: 4,
                balanceAfter: 12,
              ),
            ],
          ],
        ),
      );

      expect(find.text('Wallet activity'), findsOneWidget);
      expect(find.text('+4 Coins'), findsOneWidget);
      expect(find.text('Balance 12'), findsOneWidget);
    });
  });

  group('the empty and failed states', () {
    testWidgets('an empty ledger says how it fills up', (tester) async {
      await pump(tester, _FakeWallet(wallet: _wallet()));

      expect(
        find.textContaining('Credits and unlocks both appear here'),
        findsOneWidget,
      );
    });

    testWidgets('the balance still shows when the ledger fails', (
      tester,
    ) async {
      final fake = _FakeWallet(wallet: _wallet())
        ..failNextPage = const ApiException('Ledger unavailable.');

      await pump(tester, fake);

      expect(find.text('8 Coins'), findsOneWidget);
      expect(find.text('Ledger unavailable.'), findsOneWidget);
    });
  });

  group('paging the ledger', () {
    /// Scrolls the control into view before tapping it.
    ///
    /// `scrollUntilVisible` is no use here: the ledger is a plain `ListView`,
    /// so every row exists from the first frame and the finder matches
    /// immediately — it stops before scrolling anything, and the tap then lands
    /// off-screen. `ensureVisible` has to be pumped for the scroll to happen.
    Future<void> tapShowMore(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Show more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    /// A full page, so `hasMore` is true and "show more" is offered.
    List<WalletTransaction> fullPage(String prefix, int balanceBase) => [
      for (var i = 0; i < walletPageSize; i++)
        _entry(
          id: '$prefix-$i',
          kind: WalletTransactionKind.candidateUnlock,
          amountCoins: -2,
          balanceAfter: balanceBase - i,
        ),
    ];

    testWidgets('show more appends rather than replaces', (tester) async {
      // An employer reading downwards must not lose the entry they were looking
      // at, which is what a page that swapped itself out would do.
      final fake = _FakeWallet(
        wallet: _wallet(),
        pages: [
          fullPage('first', 500),
          [
            _entry(
              id: 'second-0',
              kind: WalletTransactionKind.registrationBonus,
              amountCoins: 10,
              balanceAfter: 10,
            ),
          ],
        ],
      );

      await pump(tester, fake);
      expect(find.text('Balance 500'), findsOneWidget);

      // A full page pushes the control below the fold, which is exactly where
      // it lives in practice.
      await tapShowMore(tester);

      expect(fake.requestedOffsets, [0, walletPageSize]);
      // The first page is still there, and the second has joined it.
      expect(find.text('Balance 500'), findsOneWidget);
      expect(find.text('Registration bonus'), findsOneWidget);
    });

    testWidgets('a short page offers no show more', (tester) async {
      await pump(
        tester,
        _FakeWallet(
          wallet: _wallet(),
          pages: [
            [
              _entry(
                kind: WalletTransactionKind.registrationBonus,
                amountCoins: 10,
                balanceAfter: 10,
              ),
            ],
          ],
        ),
      );

      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('a failed append keeps the entries already on screen', (
      tester,
    ) async {
      // The ledger on screen is still exactly what the server sent; only the
      // next page is missing. Replacing it with an error page would lose a
      // correct answer to report a partial failure.
      final fake = _FakeWallet(
        wallet: _wallet(),
        pages: [fullPage('first', 500)],
      );

      await pump(tester, fake);
      fake.failNextPage = const ApiException('The connection dropped.');

      await tapShowMore(tester);

      expect(find.text('Balance 500'), findsOneWidget);
      expect(find.text('The connection dropped.'), findsOneWidget);
      // Offered again, because retrying is the reasonable next move.
      expect(find.text('Show more'), findsOneWidget);
    });
  });

  group('top up before M13 (§6.7)', () {
    testWidgets('says it is not available yet rather than doing nothing', (
      tester,
    ) async {
      // A dead control reads as a broken app. With ten free Coins in every new
      // wallet, nobody is actually blocked by this.
      await pump(tester, _FakeWallet(wallet: _wallet()));

      await tester.tap(find.text('Top up'));
      await tester.pump();

      expect(
        find.textContaining('Top-up is not available yet'),
        findsOneWidget,
      );
    });
  });

  group('the domain', () {
    test('a debit is negative and a credit positive', () {
      expect(
        _entry(
          kind: WalletTransactionKind.candidateUnlock,
          amountCoins: -2,
          balanceAfter: 8,
        ).isCredit,
        isFalse,
      );
      expect(
        _entry(
          kind: WalletTransactionKind.topUp,
          amountCoins: 5,
          balanceAfter: 13,
        ).isCredit,
        isTrue,
      );
    });

    test('only adjustments and reversals are corrections', () {
      expect(WalletTransactionKind.isCorrection('admin_adjustment'), isTrue);
      expect(WalletTransactionKind.isCorrection('reversal'), isTrue);
      expect(WalletTransactionKind.isCorrection('top_up'), isFalse);
      expect(
        WalletTransactionKind.isCorrection('registration_bonus'),
        isFalse,
      );
      expect(WalletTransactionKind.isCorrection('candidate_unlock'), isFalse);
    });

    test('a timestamp without an offset is refused at the boundary', () {
      // The backend froze "every timestamp carries an explicit numeric offset,
      // never Z" as a contract clause. A loud failure here beats a plausible
      // wrong time on a ledger entry.
      expect(
        () => _entry(
          kind: WalletTransactionKind.topUp,
          amountCoins: 5,
          balanceAfter: 13,
          createdAt: '2026-08-10T13:51:00Z',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
