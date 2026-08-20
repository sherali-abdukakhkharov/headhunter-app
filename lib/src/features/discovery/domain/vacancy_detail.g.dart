// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancy_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VacancyRequirement _$VacancyRequirementFromJson(Map<String, dynamic> json) =>
    VacancyRequirement(
      fieldCode: json['fieldCode'] as String,
      isMandatory: json['isMandatory'] as bool,
      itemId: json['itemId'] as String?,
      levelId: json['levelId'] as String?,
      valueBool: json['valueBool'] as bool?,
      valueInt: (json['valueInt'] as num?)?.toInt(),
      valueText: json['valueText'] as String?,
    );

VacancyDetail _$VacancyDetailFromJson(Map<String, dynamic> json) =>
    VacancyDetail(
      item: VacancyCard.fromJson(json['item'] as Map<String, dynamic>),
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => VacancyRequirement.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      address: json['address'] as String?,
      startsOn: json['startsOn'] as String?,
      endsOn: json['endsOn'] as String?,
    );
