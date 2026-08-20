// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vacancy _$VacancyFromJson(Map<String, dynamic> json) => Vacancy(
  id: json['id'] as String,
  status: json['status'] as String,
  fields: json['fields'] as Map<String, dynamic>,
  missingForSubmit: (json['missingForSubmit'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isOpenForApplications: json['isOpenForApplications'] as bool,
  hiredCount: (json['hiredCount'] as num).toInt(),
  category: json['category'] as String?,
  moderationReason: json['moderationReason'] as String?,
  publishedAt: json['publishedAt'] as String?,
  closedAt: json['closedAt'] as String?,
  closureReason: json['closureReason'] as String?,
  updatedAt: json['updatedAt'] as String?,
);
