/// §10.5 — the last section of the admin module.
///
/// Two of its four parts are here and two are not, and the tests say which:
/// the wallet, its immutable ledger and BR-24's manual adjustment are built;
/// Payment Order search and editing the prices have no server route, and the
/// screen states that rather than leaving a blank somebody reports as a bug.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_wallet.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_wallet_detail_screen.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_wallets_screen.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet_transaction.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/wallet_transaction_row.dart';

import 'admin_fake.dart';

AdminWallet _wallet({
  String userId = 'emp-1',
  String? name = 'Qitmir MChJ',
  String? phone = '+998901234567',
  int balanceCoins = 8,
  int unlockCount = 1,
  String? registrationBonusAt = '2026-08-01T09:00:00+05:00',
}) => AdminWallet.fromJson({
  'userId': userId,
  'name': name,
  'phone': phone,
  'balanceCoins': balanceCoins,
  'unlockCount': unlockCount,
  'registrationBonusAt': registrationBonusAt,
});

AdminWalletDetail _detail({
  int balanceCoins = 8,
  List<Map<String, dynamic>> transactions = const [
    {
      'id': 'txn-1',
      'kind': 'unlock',
      'amountCoins': -2,
      'balanceAfter': 8,
      'amountUzs': null,
      'referenceId': 'cand-1',
      'reason': null,
      'createdAt': '2026-08-20T11:00:00+05:00',
    },
  ],
}) => AdminWalletDetail.fromJson({
  'userId': 'emp-1',
  'name': 'Qitmir MChJ',
  'phone': '+998901234567',
  'balanceCoins': balanceCoins,
  'unlockCount': 1,
  'registrationBonusAt': '2026-08-01T09:00:00+05:00',
  'transactions': transactions,
});

class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({
    this.pages = const [],
    this.detail,
    this.listFailure,
    this.detailFailure,
    this.adjustFailure,
  });

  List<List<AdminWallet>> pages;
  AdminWalletDetail? detail;
  ApiException? listFailure;
  ApiException? detailFailure;
  ApiException? adjustFailure;

  final offsets = <int>[];
  final adjustments = <({String userId, int amountCoins, String reason})>[];

  @override
  Future<List<AdminWallet>> wallets({int offset = 0}) async {
    if (listFailure case final error?) throw error;
    offsets.add(offset);

    final index = offsets.length - 1;
    return index < pages.length ? pages[index] : const [];
  }

  @override
  Future<AdminWalletDetail> wallet(String userId) async {
    if (detailFailure case final error?) throw error;
    return detail ?? _detail();
  }

  @override
  Future<WalletTransaction> adjustWallet(
    String userId, {
    required int amountCoins,
    required String reason,
  }) async {
    adjustments.add((
      userId: userId,
      amountCoins: amountCoins,
      reason: reason,
    ));
    if (adjustFailure case final error?) throw error;

    return WalletTransaction.fromJson({
      'id': 'txn-adj',
      'kind': 'admin_adjustment',
      'amountCoins': amountCoins,
      'balanceAfter': 8 + amountCoins,
      'amountUzs': null,
      'referenceId': null,
      'reason': reason,
      'createdAt': '2026-08-25T12:00:00+05:00',
    });
  }
}

void main() {
  final en = lookupAppL10n(const Locale('en'));

  Future<_FakeAdmin> pumpList(
    WidgetTester tester, {
    List<List<AdminWallet>> pages = const [],
    ApiException? failure,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(pages: pages, listFailure: failure);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [adminRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const AdminWalletsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return fake;
  }

  Future<_FakeAdmin> pumpDetail(
    WidgetTester tester, {
    AdminWalletDetail? detail,
    ApiException? failure,
    ApiException? adjustFailure,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(
      detail: detail,
      detailFailure: failure,
      adjustFailure: adjustFailure,
    );

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [adminRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const AdminWalletDetailScreen(userId: 'emp-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return fake;
  }

  group('the wallet list', () {
    testWidgets('says what is still waiting, and links to what is not', (
      tester,
    ) async {
      // §10.5 asks for four things. Three are here as of 2026-08-28; the
      // payment order search is still empty, and that is stated on the screen
      // rather than left as a gap — the same choice §10.3 made about label
      // editing, and otherwise the next audit files it as a missing screen.
      await pumpList(tester, pages: [
        [_wallet()],
      ]);

      expect(find.text(en.adminPaymentsPending), findsOneWidget);

      // The prices are no longer a notice about a missing route: they are a
      // screen, one tap from where the money is read.
      expect(find.text(en.adminPricingTitle), findsOneWidget);
      expect(find.textContaining('future transactions only'), findsNothing);
    });

    testWidgets('says how it is ordered, so nobody hunts for a sort', (
      tester,
    ) async {
      await pumpList(tester, pages: [
        [_wallet()],
      ]);

      expect(find.text(en.adminWalletsOrder), findsOneWidget);
    });

    testWidgets('a wallet whose owner was erased still reads as something', (
      tester,
    ) async {
      // BR-14 erases the person and keeps the id, because §6.7 keeps payment
      // records and BR-24 forbids rewriting the ledger. The absence is said
      // rather than left blank, so a thin row is not read as broken data.
      await pumpList(tester, pages: [
        [_wallet(name: null, phone: null)],
      ]);

      expect(find.text(en.adminWalletUnnamed), findsOneWidget);
    });

    testWidgets('a wallet with no registration bonus says so', (tester) async {
      // The absence is the diagnostic part: BR-15 grants the bonus exactly
      // once, and no date is what a grant that never happened looks like.
      await pumpList(tester, pages: [
        [_wallet(registrationBonusAt: null)],
      ]);

      expect(find.text(en.adminWalletNoBonus), findsOneWidget);
    });

    testWidgets('an empty list is not a fault', (tester) async {
      await pumpList(tester);

      expect(find.text(en.adminWalletsEmpty), findsOneWidget);
    });

    testWidgets('a failure is terminal and offers a retry', (tester) async {
      // Retry is disabled app-wide, so a failing provider is a terminal state
      // rather than a spinner that never resolves.
      await pumpList(tester, failure: const ApiException('Nope'));

      expect(find.byType(HhErrorState), findsOneWidget);
      expect(find.text('Nope'), findsOneWidget);
    });

    testWidgets('paging asks for the next offset, not the same one', (
      tester,
    ) async {
      final fake = await pumpList(tester, pages: [
        List.generate(adminPageSize, (i) => _wallet(userId: 'emp-$i')),
        [_wallet(userId: 'emp-last')],
      ]);

      // Twenty rows put the control below the fold of a lazy list.
      await tester.scrollUntilVisible(
        find.text(en.commonShowMore),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      // The prices card pushed this below the fold on a 360x800 surface.
      await tester.ensureVisible(find.text(en.commonShowMore));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.commonShowMore));
      await tester.pumpAndSettle();

      // The second page, not the first again — an offset that did not move is
      // an infinite list of the same twenty wallets.
      expect(fake.offsets, [0, adminPageSize]);
    });
  });

  group('the wallet detail', () {
    testWidgets('states that the ledger cannot be edited (BR-24)', (
      tester,
    ) async {
      // An administrator looking at a mistaken adjustment will otherwise go
      // hunting for a way to remove it, and there is none — three database
      // triggers refuse UPDATE, DELETE and TRUNCATE on that table.
      await pumpDetail(tester);

      expect(find.text(en.adminWalletImmutable), findsOneWidget);
    });

    testWidgets('renders the ledger with the employer’s own row widget', (
      tester,
    ) async {
      await pumpDetail(tester);

      // One widget rather than an admin copy: the two screens are looking at
      // the same rows, and a second rendering is how the administrator's
      // account of a transaction comes to disagree with the employer's.
      expect(find.byType(WalletTransactionRow), findsOneWidget);
    });

    testWidgets('an account with no wallet is an outcome, not a failure', (
      tester,
    ) async {
      // BR-15 creates a wallet at first *employer* registration, so a 404 here
      // means the account never became one. Its own notice, a way back, and
      // **no retry** — retrying would fail identically.
      await pumpDetail(
        tester,
        failure: const ApiException('gone', statusCode: 404),
      );

      expect(find.text(en.adminWalletGone), findsOneWidget);
      expect(find.byType(HhErrorState), findsNothing);
      expect(find.text(en.commonRetry), findsNothing);
    });
  });

  group('BR-24: the manual adjustment', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(HhButton, en.adminAdjustAction));
      await tester.pumpAndSettle();
    }

    Future<void> fill(
      WidgetTester tester, {
      required String amount,
      required String reason,
    }) async {
      final fields = find.byType(HhTextField);
      await tester.enterText(fields.at(0), amount);
      await tester.enterText(fields.at(1), reason);
      await tester.pump();
    }

    testWidgets('says it cannot be undone, before it is made', (tester) async {
      await pumpDetail(tester);
      await openSheet(tester);

      expect(find.text(en.adminAdjustNote), findsOneWidget);
    });

    testWidgets('cannot be submitted without a reason', (tester) async {
      // Mandatory in the DTO *and* in the database, so the server would refuse
      // it. Refused here too, because an enabled control is a promise that
      // pressing it will do something (MT-013).
      final fake = await pumpDetail(tester);
      await openSheet(tester);
      await fill(tester, amount: '5', reason: '');

      final submit = find.widgetWithText(HhButton, en.adminAdjustSubmit);
      expect(tester.widget<HhButton>(submit).onPressed, isNull);
      expect(fake.adjustments, isEmpty);
    });

    testWidgets('cannot be submitted for zero', (tester) async {
      // An entry that changes nothing is a ledger row with no meaning, which
      // is why the server refuses it. Said on the field rather than as a 422.
      await pumpDetail(tester);
      await openSheet(tester);
      await fill(tester, amount: '0', reason: 'Refund');

      expect(find.text(en.adminAdjustZero), findsOneWidget);
      expect(
        tester
            .widget<HhButton>(
              find.widgetWithText(HhButton, en.adminAdjustSubmit),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('sends the signed amount and the reason', (tester) async {
      final fake = await pumpDetail(tester);
      await openSheet(tester);
      await fill(tester, amount: '-3', reason: 'Refund for order 4821');

      await tester.tap(find.widgetWithText(HhButton, en.adminAdjustSubmit));
      await tester.pumpAndSettle();

      // Negative takes Coins away. A screen that sent the magnitude and a
      // direction flag would be one refactor away from crediting a refund.
      expect(fake.adjustments, [
        (userId: 'emp-1', amountCoins: -3, reason: 'Refund for order 4821'),
      ]);
    });

    testWidgets('names the new balance rather than leaving it to be found', (
      tester,
    ) async {
      await pumpDetail(tester);
      await openSheet(tester);
      await fill(tester, amount: '5', reason: 'Goodwill');

      await tester.tap(find.widgetWithText(HhButton, en.adminAdjustSubmit));
      await tester.pumpAndSettle();

      expect(find.text(en.adminAdjustDone(13)), findsOneWidget);
    });

    testWidgets('a refusal is the server’s own words', (tester) async {
      // The 409 here is "this would take the balance below zero", which the
      // server words itself — the client holds no copy of that rule.
      await pumpDetail(
        tester,
        adjustFailure: const ApiException(
          'That would take the balance below zero.',
          statusCode: 409,
        ),
      );
      await openSheet(tester);
      await fill(tester, amount: '-99', reason: 'Mistake');

      await tester.tap(find.widgetWithText(HhButton, en.adminAdjustSubmit));
      await tester.pumpAndSettle();

      expect(
        find.text('That would take the balance below zero.'),
        findsOneWidget,
      );
    });
  });
}
