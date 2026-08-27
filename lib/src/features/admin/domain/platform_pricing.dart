import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_pricing.g.dart';

/// The three numbers §10.5 lets an administrator set.
@JsonSerializable(createToJson: false)
@immutable
class PricingValues {
  const PricingValues({
    required this.coinPriceUzs,
    required this.candidateUnlockCoins,
    required this.registrationBonusCoins,
  });

  factory PricingValues.fromJson(Map<String, dynamic> json) =>
      _$PricingValuesFromJson(json);

  /// What one Coin costs, in whole so'm.
  final int coinPriceUzs;

  /// What a Candidate Unlock costs, in Coins (§6.6, BR-16).
  final int candidateUnlockCoins;

  /// Coins a new employer is granted once (§6.6, BR-15).
  final int registrationBonusCoins;

  /// What an unlock costs in money, at these prices.
  ///
  /// Derived rather than sent: it is the product of two numbers on this screen,
  /// and a server-sent third value could disagree with them mid-edit.
  int get candidateUnlockUzs => candidateUnlockCoins * coinPriceUzs;

  @override
  bool operator ==(Object other) =>
      other is PricingValues &&
      other.coinPriceUzs == coinPriceUzs &&
      other.candidateUnlockCoins == candidateUnlockCoins &&
      other.registrationBonusCoins == registrationBonusCoins;

  @override
  int get hashCode => Object.hash(
    coinPriceUzs,
    candidateUnlockCoins,
    registrationBonusCoins,
  );
}

/// §10.5's pricing screen: what is in force, and what a reset would give.
///
/// **Both halves matter.** [declared] is what the environment says, so the
/// screen can offer to revert a setting and can show which numbers have been
/// moved from the default at all — neither of which is answerable from
/// [current] alone.
@JsonSerializable(createToJson: false)
@immutable
class PlatformPricing {
  const PlatformPricing({required this.current, required this.declared});

  factory PlatformPricing.fromJson(Map<String, dynamic> json) =>
      _$PlatformPricingFromJson(json);

  final PricingValues current;
  final PricingValues declared;

  /// Whether this setting has been changed from what the deployment declared.
  bool isOverridden(PricingField field) =>
      field.read(current) != field.read(declared);
}

/// One editable setting: its wire name, its floor, and how to read it.
///
/// An enum rather than three copies of the same form row — the three differ
/// only in name, floor and which number they are, and the floors are the
/// server's own, restated so a control is disabled before a request rather
/// than after a refusal.
enum PricingField {
  coinPrice(wire: 'coinPriceUzs', minimum: 1),

  /// **At least one Coin.** A free unlock makes BR-16's entitlement
  /// meaningless, which is the whole reason §6.6 charges for it, and the server
  /// refuses zero here for that reason rather than out of tidiness.
  unlockCost(wire: 'candidateUnlockCoins', minimum: 1),

  /// Zero is legitimate: a deployment may simply not grant one.
  registrationBonus(wire: 'registrationBonusCoins', minimum: 0);

  const PricingField({required this.wire, required this.minimum});

  final String wire;
  final int minimum;

  int read(PricingValues values) => switch (this) {
    PricingField.coinPrice => values.coinPriceUzs,
    PricingField.unlockCost => values.candidateUnlockCoins,
    PricingField.registrationBonus => values.registrationBonusCoins,
  };
}
