import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/features/health/domain/health_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_repository.g.dart';

/// Reads the backend's health endpoint.
class HealthRepository {
  const HealthRepository(this._dio);

  final Dio _dio;

  /// Fetches `GET /health`.
  ///
  /// Throws [ApiException] on any transport or server failure.
  Future<HealthStatus> fetchHealth({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/health',
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return HealthStatus.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
HealthRepository healthRepository(Ref ref) =>
    HealthRepository(ref.watch(dioProvider));

/// Current backend health. Watch this to render status; refresh to re-check.
@riverpod
Future<HealthStatus> healthStatus(Ref ref) {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  return ref
      .watch(healthRepositoryProvider)
      .fetchHealth(cancelToken: cancelToken);
}
