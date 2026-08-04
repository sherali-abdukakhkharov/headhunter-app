// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) => HealthStatus(
  status: json['status'] as String,
  database: json['database'] as String,
  version: json['version'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);
