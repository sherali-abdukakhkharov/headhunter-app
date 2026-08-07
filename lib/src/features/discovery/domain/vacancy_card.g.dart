// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancy_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedEmployer _$FeedEmployerFromJson(Map<String, dynamic> json) => FeedEmployer(
  isVerified: json['isVerified'] as bool,
  name: json['name'] as String?,
);

VacancyCard _$VacancyCardFromJson(Map<String, dynamic> json) => VacancyCard(
  id: json['id'] as String,
  employer: FeedEmployer.fromJson(json['employer'] as Map<String, dynamic>),
  isSaved: json['isSaved'] as bool,
  salaryIsNegotiable: json['salaryIsNegotiable'] as bool,
  title: json['title'] as String?,
  category: json['category'] as String?,
  occupationId: json['occupationId'] as String?,
  regionId: json['regionId'] as String?,
  districtId: json['districtId'] as String?,
  workerCount: (json['workerCount'] as num?)?.toInt(),
  salaryFrom: (json['salaryFrom'] as num?)?.toInt(),
  salaryTo: (json['salaryTo'] as num?)?.toInt(),
  salaryPeriodId: json['salaryPeriodId'] as String?,
  deadlineOn: json['deadlineOn'] as String?,
  publishedAt: json['publishedAt'] as String?,
  applicationStatus: json['applicationStatus'] as String?,
);
