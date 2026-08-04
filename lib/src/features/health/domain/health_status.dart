import 'package:json_annotation/json_annotation.dart';

part 'health_status.g.dart';

/// Result of `GET /health` on headhunter-backend.
///
/// Mirrors the response shape produced by `HealthController` in the backend
/// repo; keep the two in sync when the endpoint changes.
@JsonSerializable(createToJson: false)
class HealthStatus {
  const HealthStatus({
    required this.status,
    required this.database,
    required this.version,
    required this.timestamp,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthStatusFromJson(json);

  /// Overall service state, e.g. `ok` or `degraded`.
  final String status;

  /// Database connectivity as seen by the backend: `up` or `down`.
  final String database;

  /// Backend application version.
  final String version;

  /// When the backend produced this response.
  final DateTime timestamp;

  /// Whether every dependency the backend checked is healthy.
  bool get isHealthy => status == 'ok' && database == 'up';
}
