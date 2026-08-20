// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  id: json['id'] as String,
  vacancyId: json['vacancyId'] as String,
  candidateUserId: json['candidateUserId'] as String,
  status: json['status'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  coverNote: json['coverNote'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
);
