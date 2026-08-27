// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_pricing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricingValues _$PricingValuesFromJson(Map<String, dynamic> json) =>
    PricingValues(
      coinPriceUzs: (json['coinPriceUzs'] as num).toInt(),
      candidateUnlockCoins: (json['candidateUnlockCoins'] as num).toInt(),
      registrationBonusCoins: (json['registrationBonusCoins'] as num).toInt(),
    );

PlatformPricing _$PlatformPricingFromJson(Map<String, dynamic> json) =>
    PlatformPricing(
      current: PricingValues.fromJson(json['current'] as Map<String, dynamic>),
      declared: PricingValues.fromJson(
        json['declared'] as Map<String, dynamic>,
      ),
    );
