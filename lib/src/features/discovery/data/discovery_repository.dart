import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/features/discovery/domain/vacancy_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_repository.g.dart';

/// Which feed to show (§5.6). The paths differ; nothing else does.
enum Feed {
  recommended('/discovery/recommended'),
  recent('/discovery/recent'),
  saved('/discovery/saved');

  const Feed(this.path);
  final String path;
}

/// Vacancy discovery for candidates (§5.5, §5.6).
class DiscoveryRepository {
  const DiscoveryRepository(this._dio);

  final Dio _dio;

  /// `GET /discovery/{recommended,recent,saved}`
  ///
  /// [filters] are §5.5's, and id sets travel **comma-separated** because that
  /// is how the query DTO parses them — a repeated key would be dropped.
  Future<List<VacancyCard>> feed(
    Feed feed, {
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        feed.path,
        queryParameters: {
          for (final entry in filters.entries)
            if (entry.value case final value?)
              entry.key: value is List ? value.join(',') : value,
        },
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) VacancyCard.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT`/`DELETE /discovery/vacancies/:id/saved`
  Future<void> setSaved(String id, {required bool saved}) async {
    try {
      final path = '/discovery/vacancies/$id/saved';
      if (saved) {
        await _dio.put<void>(path);
      } else {
        await _dio.delete<void>(path);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /discovery/vacancies/:id/report`
  Future<void> report(String id, String reason) async {
    try {
      await _dio.post<void>(
        '/discovery/vacancies/$id/report',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
DiscoveryRepository discoveryRepository(Ref ref) =>
    DiscoveryRepository(ref.watch(dioProvider));

/// One feed's contents.
@riverpod
Future<List<VacancyCard>> vacancyFeed(Ref ref, Feed feed) =>
    ref.watch(discoveryRepositoryProvider).feed(feed);
