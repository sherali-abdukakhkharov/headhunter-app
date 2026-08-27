import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/platform_pricing.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_pricing_screen.dart';

import 'admin_fake.dart';

/// §10.5's pricing editor.
///
/// The property worth testing is not that a number reaches a text field. It is
/// that **only what changed is sent** — the server writes one audit row per
/// setting that actually moves, so a form posting all three when one was
/// edited puts two decisions in the log that nobody took.
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({required this.view, this.failure});

  PlatformPricing view;
  ApiException? failure;

  /// Every write, as the map the repository would put on the wire.
  final writes = <({Map<PricingField, int> changes, String? reason})>[];

  @override
  Future<PlatformPricing> pricing() async => view;

  @override
  Future<PlatformPricing> setPricing(
    Map<PricingField, int> changes, {
    String? reason,
  }) async {
    if (failure case final error?) throw error;
    writes.add((changes: changes, reason: reason));
    return view;
  }
}

PlatformPricing _pricing({
  int coinPrice = 10000,
  int unlock = 2,
  int bonus = 10,
  int declaredCoinPrice = 10000,
  int declaredUnlock = 2,
  int declaredBonus = 10,
}) => PlatformPricing(
  current: PricingValues(
    coinPriceUzs: coinPrice,
    candidateUnlockCoins: unlock,
    registrationBonusCoins: bonus,
  ),
  declared: PricingValues(
    coinPriceUzs: declaredCoinPrice,
    candidateUnlockCoins: declaredUnlock,
    registrationBonusCoins: declaredBonus,
  ),
);

Future<_FakeAdmin> _pump(WidgetTester tester, {_FakeAdmin? repository}) async {
  // Tall enough that the whole form is laid out: a ListView builds only the
  // children inside its viewport, so on a phone-sized surface the save button
  // does not exist in the tree and every assertion about it finds nothing.
  tester.view.physicalSize = const Size(1080, 4800);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final fake = repository ?? _FakeAdmin(view: _pricing());

  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [adminRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp(
        theme: HhTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: const AdminPricingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return fake;
}

/// The order the editor lays its fields out in.
///
/// By position rather than by label, because `HhTextField` renders its label
/// as a sibling of the `TextField` rather than inside it, so an ancestor
/// lookup finds nothing. Named here so a reordering breaks one line.
const _coinPrice = 0;
const _unlockCost = 1;
const _bonus = 2;
const _reason = 3;

/// Types [value] into the nth field, replacing what is there.
Future<void> type(WidgetTester tester, int index, String value) async {
  await tester.enterText(find.byType(HhTextField).at(index), value);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sends only the settings that moved', (tester) async {
    final fake = await _pump(tester);

    await type(tester, _coinPrice, '12000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The unlock cost and the bonus were on screen at their current values and
    // must not be written: the server records one audit row per setting that
    // moves, so posting all three would log two decisions nobody took.
    expect(fake.writes, hasLength(1));
    expect(fake.writes.single.changes, {PricingField.coinPrice: 12000});
  });

  testWidgets('cannot be saved while nothing has moved', (tester) async {
    await _pump(tester);

    expect(find.text('Nothing to save'), findsOneWidget);

    final save = tester.widget<HhButton>(
      find.widgetWithText(HhButton, 'Save'),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('refuses a free unlock in words, not as a bound', (
    tester,
  ) async {
    final fake = await _pump(tester);

    await type(tester, _unlockCost, '0');

    // BR-16: a free unlock makes the entitlement §6.6 charges for meaningless.
    // "At least 1" would be true and would explain nothing.
    expect(
      find.textContaining('An unlock cannot be free'),
      findsOneWidget,
    );

    final save = tester.widget<HhButton>(
      find.widgetWithText(HhButton, 'Save'),
    );
    expect(save.onPressed, isNull);
    expect(fake.writes, isEmpty);
  });

  testWidgets('a zero registration bonus is legitimate', (tester) async {
    final fake = await _pump(tester);

    // A deployment may simply not grant one, which is why the server's floor
    // here is zero and not one.
    await type(tester, _bonus, '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fake.writes.single.changes, {PricingField.registrationBonus: 0});
  });

  testWidgets('marks a setting that differs from the deployment default', (
    tester,
  ) async {
    await _pump(
      tester,
      repository: _FakeAdmin(
        view: _pricing(coinPrice: 15000),
      ),
    );

    // Both are just numbers; without this nothing on screen says which one the
    // deployment chose or that anybody has moved it.
    expect(find.text('Changed'), findsOneWidget);
    expect(find.text('Restore default'), findsOneWidget);
    expect(find.textContaining('Deployment default:'), findsNWidgets(3));
  });

  testWidgets('restoring the default writes the declared value back', (
    tester,
  ) async {
    final fake = await _pump(
      tester,
      repository: _FakeAdmin(
        view: _pricing(coinPrice: 15000),
      ),
    );

    await tester.tap(find.text('Restore default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The server drops an override when the value equals the default, so
    // sending the declared number *is* the reset.
    expect(fake.writes.single.changes, {PricingField.coinPrice: 10000});
  });

  testWidgets('carries the reason when one is given', (tester) async {
    final fake = await _pump(tester);

    await type(tester, _coinPrice, '11000');
    await type(tester, _reason, 'Client raised it for Q4');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fake.writes.single.reason, 'Client raised it for Q4');
  });

  testWidgets('an empty reason is sent as absent, not as an empty string', (
    tester,
  ) async {
    final fake = await _pump(tester);

    await type(tester, _coinPrice, '11000');
    await type(tester, _reason, '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // An audit row whose reason is a space reads as a reason that was given.
    expect(fake.writes.single.reason, isNull);
  });

  testWidgets('shows what an unlock would cost at the values on screen', (
    tester,
  ) async {
    await _pump(tester);

    await type(tester, _coinPrice, '1000');
    await type(tester, _unlockCost, '3');

    // Not a quote and never sent — a preview of what is being set. Without it
    // an administrator sets a Coin price with no idea what it does to the only
    // thing Coins buy.
    // The English variant groups with a comma; the separator comes from the
    // ARB's decimalPattern rather than a rule written in Dart.
    expect(find.textContaining('3,000 UZS'), findsOneWidget);
  });

  testWidgets('a refusal is shown in the server’s words', (tester) async {
    final fake = await _pump(
      tester,
      repository: _FakeAdmin(
        view: _pricing(),
        failure: const ApiException('A Coin cannot be free.'),
      ),
    );

    await type(tester, _coinPrice, '11000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('A Coin cannot be free.'), findsOneWidget);
    // Local to the form: the page error heading says "Something went wrong",
    // which is a claim about the system rather than about this request.
    expect(find.text('Something went wrong'), findsNothing);
    expect(fake.writes, isEmpty);
  });
}
