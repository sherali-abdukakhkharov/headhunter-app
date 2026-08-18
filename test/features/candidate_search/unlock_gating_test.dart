import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:headhunter_app/src/features/applications/presentation/exposure_explanation.dart';
import 'package:headhunter_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:headhunter_app/src/features/candidate_search/presentation/candidate_detail_screen.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:headhunter_app/src/features/wallet/data/wallet_repository.dart';
import 'package:headhunter_app/src/features/wallet/domain/unlock.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet_transaction.dart';

/// Candidate Unlock on the profile screen (§6.6, §7.3, UAT-17 – UAT-19).
///
/// ## What this file is really for
///
/// The unlock ships **before** the backend gates contact exposure on the
/// entitlement. The server can already sell an unlock; it does not yet read
/// one. So the control is gated on `exposureReason == 'unlock_required'` — a
/// code only a server that honours entitlements sends — and the first group
/// below is the load-bearing one: against today's `no_interaction`, with a
/// funded wallet and everything else in place, **no control appears and nothing
/// can be charged.**
///
/// If that group ever goes green while the gate is loosened, this build starts
/// taking two Coins for access that does not change.
class _FakeWallet implements WalletRepository {
  _FakeWallet({this.balanceCoins = 10, this.unlockCoins = 2});

  int balanceCoins;
  int unlockCoins;

  /// Set to make the purchase answer 402, as it would if the balance moved
  /// between the sheet opening and the tap.
  String? insufficientMessage;

  /// True on the second and later purchases of the same pair (BR-16, UAT-18).
  bool alreadyHeld = false;

  final unlockRequests = <String>[];
  final stateRequests = <String>[];

  @override
  Future<Wallet> fetch() async => Wallet.fromJson({
    'balanceCoins': balanceCoins,
    'balanceValueUzs': balanceCoins * 10000,
    'pricing': {
      'coinPriceUzs': 10000,
      'candidateUnlockCoins': unlockCoins,
      'candidateUnlockUzs': unlockCoins * 10000,
    },
    'registrationBonusAt': null,
  });

  @override
  Future<List<WalletTransaction>> transactions({
    int limit = walletPageSize,
    int offset = 0,
  }) async => const [];

  @override
  Future<UnlockState> unlockState(String candidateUserId) async {
    stateRequests.add(candidateUserId);

    return UnlockState.fromJson({
      'unlocked': alreadyHeld,
      'unlock': alreadyHeld
          ? {
              'candidateUserId': candidateUserId,
              'costCoins': unlockCoins,
              'createdAt': '2026-08-19T11:30:00+05:00',
              'charged': false,
            }
          : null,
      'pricing': {
        'coinPriceUzs': 10000,
        'candidateUnlockCoins': unlockCoins,
        'candidateUnlockUzs': unlockCoins * 10000,
      },
    });
  }

  @override
  Future<UnlockResult> unlock(String candidateUserId) async {
    unlockRequests.add(candidateUserId);

    if (insufficientMessage case final message?) {
      return UnlockUnaffordable(message);
    }

    final charged = !alreadyHeld;
    alreadyHeld = true;

    return UnlockGranted(
      Unlock.fromJson({
        'candidateUserId': candidateUserId,
        'costCoins': unlockCoins,
        'createdAt': '2026-08-19T11:30:00+05:00',
        'charged': charged,
      }),
    );
  }
}

void main() {
  CandidateForEmployer candidate({
    required String exposureReason,
    String? phone,
  }) => CandidateForEmployer.fromJson({
    'candidateUserId': 'cand-1',
    'fullName': 'Aziza Karimova',
    'completenessPercent': 90,
    'canViewFiles': false,
    'exposureReason': exposureReason,
    'files': const <dynamic>[],
    'phone': ?phone,
  });

  Future<_FakeWallet> pump(
    WidgetTester tester, {
    required String exposureReason,
    String? phone,
    _FakeWallet? wallet,
    bool walletReachable = true,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = wallet ?? _FakeWallet();

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          searchCandidateProvider('cand-1').overrideWith(
            (ref) => candidate(exposureReason: exposureReason, phone: phone),
          ),
          if (walletReachable)
            walletRepositoryProvider.overrideWithValue(fake)
          else
            walletProvider.overrideWith(
              (ref) => throw const ApiException('Wallet unreachable.'),
            ),
          dictionaryProvider(
            'region',
          ).overrideWith((ref) => const <DictionaryItem>[]),
          dictionaryProvider(
            'file_purpose',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const CandidateDetailScreen(candidateUserId: 'cand-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  const unlockAction = 'Unlock contact — 2 Coins';

  /// The server's own 402 sentence, already translated and already carrying
  /// both numbers — which is why the client renders it rather than rebuilds it.
  const shortBalance =
      'Not enough Coins: 2 needed, 1 available. Top up your wallet.';

  group('the gate: nothing can be charged against an ungated server', () {
    testWidgets('no_interaction offers no unlock, however funded the wallet', (
      tester,
    ) async {
      // Today's server. It will happily sell an unlock and then go on refusing
      // contact, so the only safe control is no control.
      final fake = await pump(
        tester,
        exposureReason: 'no_interaction',
        wallet: _FakeWallet(balanceCoins: 500),
      );

      expect(find.text(unlockAction), findsNothing);
      expect(fake.unlockRequests, isEmpty);
    });

    testWidgets('unlock_required offers it, priced by the server', (
      tester,
    ) async {
      // The code only a server that reads the entitlement sends. No client
      // release turned this on and no flag was switched.
      await pump(tester, exposureReason: 'unlock_required');

      expect(find.text(unlockAction), findsOneWidget);
    });

    testWidgets('the label carries the server price, not a constant', (
      tester,
    ) async {
      // §10.5 can reprice an unlock while the app is installed, so the button
      // must not say "2 Coins" of its own accord.
      await pump(
        tester,
        exposureReason: 'unlock_required',
        wallet: _FakeWallet(unlockCoins: 5),
      );

      expect(find.text('Unlock contact — 5 Coins'), findsOneWidget);
      expect(find.text(unlockAction), findsNothing);
    });

    testWidgets('an unverified employer is offered nothing to buy', (
      tester,
    ) async {
      // BR-03 is a precondition, not a paywall: §7 says only a verified
      // employer may see candidates at all, so a purchase here would sell
      // access the server is going to refuse.
      final fake = await pump(
        tester,
        exposureReason: 'not_verified_employer',
      );

      expect(find.text(unlockAction), findsNothing);
      expect(fake.unlockRequests, isEmpty);
    });

    testWidgets('a candidate who hid their profile cannot be bought', (
      tester,
    ) async {
      await pump(tester, exposureReason: 'hidden_by_candidate');

      expect(find.text(unlockAction), findsNothing);
    });

    testWidgets('an unreachable wallet offers no price and no button', (
      tester,
    ) async {
      // Rather than a button labelled with a guess. The contact block still
      // explains itself; only the purchase is withheld.
      await pump(
        tester,
        exposureReason: 'unlock_required',
        walletReachable: false,
      );

      expect(find.text(unlockAction), findsNothing);
      expect(find.textContaining('Unlock contact to reach'), findsOneWidget);
    });
  });

  group('UAT-17: the confirmation sheet', () {
    Future<_FakeWallet> openSheet(
      WidgetTester tester, {
      _FakeWallet? wallet,
    }) async {
      final fake = await pump(
        tester,
        exposureReason: 'unlock_required',
        wallet: wallet,
      );

      await tester.tap(find.text(unlockAction));
      await tester.pumpAndSettle();

      return fake;
    }

    testWidgets('shows cost, balance and what would be left', (tester) async {
      await openSheet(tester);

      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('2 Coins'), findsOneWidget);
      expect(find.text('Your balance'), findsOneWidget);
      expect(find.text('10 Coins'), findsOneWidget);
      expect(find.text('Balance after'), findsOneWidget);
      expect(find.text('8 Coins'), findsOneWidget);
    });

    testWidgets('charges nothing by being opened', (tester) async {
      // §6.6 puts the sheet *before* the debit, so reading the price must cost
      // nothing. An employer should be able to look and walk away.
      final fake = await openSheet(tester);

      expect(fake.unlockRequests, isEmpty);
    });

    testWidgets('cancelling charges nothing', (tester) async {
      final fake = await openSheet(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fake.unlockRequests, isEmpty);
    });

    testWidgets('confirming buys it exactly once', (tester) async {
      final fake = await openSheet(tester);

      await tester.tap(find.text('Unlock contact'));
      await tester.pumpAndSettle();

      expect(fake.unlockRequests, ['cand-1']);
      expect(find.text('Contact unlocked'), findsOneWidget);
    });
  });

  group('UAT-18: a pair is charged once', () {
    testWidgets('an existing entitlement says nothing was charged', (
      tester,
    ) async {
      // `charged: false` is the server saying "you already own this". Saying so
      // is better than succeeding silently: an employer who tapped twice should
      // learn the second tap was free rather than go and audit the ledger.
      final fake = _FakeWallet()..alreadyHeld = true;

      await pump(
        tester,
        exposureReason: 'unlock_required',
        wallet: fake,
      );
      await tester.tap(find.text(unlockAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock contact'));
      await tester.pumpAndSettle();

      expect(
        find.text('Already unlocked — nothing was charged'),
        findsOneWidget,
      );
      expect(find.text('Contact unlocked'), findsNothing);
    });
  });

  group('UAT-19: fewer Coins than an unlock costs', () {
    testWidgets('the sheet offers top-up instead of a purchase', (
      tester,
    ) async {
      // Blocked and routed, not failed. Decided before the request, from the
      // figures the server already sent.
      final fake = await pump(
        tester,
        exposureReason: 'unlock_required',
        wallet: _FakeWallet(balanceCoins: 1),
      );

      await tester.tap(find.text('Unlock contact — 2 Coins'));
      await tester.pumpAndSettle();

      expect(find.text('Top up to unlock'), findsOneWidget);
      expect(find.text('Unlock contact'), findsNothing);
      expect(fake.unlockRequests, isEmpty);
    });

    testWidgets('the balance after is never shown negative', (tester) async {
      await pump(
        tester,
        exposureReason: 'unlock_required',
        wallet: _FakeWallet(balanceCoins: 1),
      );

      await tester.tap(find.text('Unlock contact — 2 Coins'));
      await tester.pumpAndSettle();

      expect(find.text('-1 Coins'), findsNothing);
      expect(find.text('−1 Coins'), findsNothing);
    });

    testWidgets('a 402 at confirm time renders the server sentence', (
      tester,
    ) async {
      // The pre-check is an optimisation, not the authority: the balance can
      // move between the sheet opening and the tap — another device, or an
      // administrator adjustment. The server's message already carries both
      // numbers, in this user's language, so it is shown rather than rebuilt.
      final fake = _FakeWallet()..insufficientMessage = shortBalance;

      await pump(
        tester,
        exposureReason: 'unlock_required',
        wallet: fake,
      );
      await tester.tap(find.text(unlockAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock contact'));
      await tester.pumpAndSettle();

      expect(find.text(shortBalance), findsOneWidget);
      expect(find.text('Contact unlocked'), findsNothing);
    });
  });

  group('the copy tells the truth on both servers', () {
    test('unlock_required and no_interaction do not share a sentence', () {
      // They are both "no entitlement", and they differ in what fixes it. One
      // sentence for both would either offer a purchase on a server that cannot
      // honour it, or hide the purchase on one that can.
      final l10n = lookupAppL10n(const Locale('en'));

      expect(
        exposureExplanation('unlock_required', l10n),
        isNot(exposureExplanation('no_interaction', l10n)),
      );
    });

    test('unlock_required names the purchase and the free route', () {
      // §11.1 treats an application as an entitlement of its own, so an
      // employer happy to wait must not be told paying is the only way.
      final message = exposureExplanation(
        'unlock_required',
        lookupAppL10n(const Locale('en')),
      );

      expect(message, contains('Unlock contact'));
      expect(message, contains('free'));
    });

    test('candidate_unlock allows, so it reads as an absent number', () {
      // Reaching the explanation with a granting code means contact was
      // permitted and there is simply no number on file. "Withheld" would
      // accuse the platform of hiding something that does not exist.
      final l10n = lookupAppL10n(const Locale('en'));

      expect(
        exposureExplanation('candidate_unlock', l10n),
        exposureExplanation('application', l10n),
      );
    });

    test('only unlock_required opens a purchase', () {
      for (final reason in [
        'application',
        'accepted_invitation',
        'admin',
        'candidate_unlock',
        'not_verified_employer',
        'no_interaction',
        'hidden_by_candidate',
        'something_newer',
      ]) {
        expect(
          unlockWouldOpenContact(reason),
          isFalse,
          reason: '$reason must not offer a purchase',
        );
      }

      expect(unlockWouldOpenContact('unlock_required'), isTrue);
    });
  });

  group('a profile a purchase opened', () {
    testWidgets('says when it was unlocked', (tester) async {
      final fake = _FakeWallet()..alreadyHeld = true;

      await pump(
        tester,
        exposureReason: 'candidate_unlock',
        phone: '+998901234567',
        wallet: fake,
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unlocked 2026-08-19'), findsOneWidget);
      expect(fake.stateRequests, ['cand-1']);
    });

    testWidgets('asks nothing extra on a profile an application opened', (
      tester,
    ) async {
      // An employer opens many candidates and pays for few. Asking every
      // profile "did I unlock this?" would be a request each to answer what
      // the reason code already answered.
      final fake = await pump(
        tester,
        exposureReason: 'application',
        phone: '+998901234567',
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(fake.stateRequests, isEmpty);
      expect(find.textContaining('Unlocked'), findsNothing);
    });
  });
}
