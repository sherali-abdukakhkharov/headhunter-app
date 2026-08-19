import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_card.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_detail.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_repository.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
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

  /// `GET /discovery/vacancies/:id` — §5.6's vacancy detail.
  ///
  /// **404 is an ordinary outcome here, not a fault.** A vacancy is visible
  /// only while it is (BR-04, BR-11), so one that has been moderated away,
  /// closed or expired since the feed was drawn answers `vacancy.not_found` —
  /// which is exactly the state UAT-15 asks the app to render.
  Future<VacancyDetail> detail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/discovery/vacancies/$id',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return VacancyDetail.fromJson(data);
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

/// One vacancy in full (§5.6).
@riverpod
Future<VacancyDetail> vacancyDetail(Ref ref, String id) =>
    ref.watch(discoveryRepositoryProvider).detail(id);

/// The vacancy form declaration for one work category, used **read-only** here
/// to name a requirement's field (§6.3, §10.3).
///
/// A requirement arrives as `fieldCode` — `employment_type_ids` — and the human
/// wording for that code lives in the schema, already localized by the server.
/// Rendering the code instead was the first version of this screen and it read
/// as a bug on a device; mapping codes to strings in Dart would be worse, since
/// administrators add fields at runtime and a client-side table would go stale
/// silently.
///
/// One request per category, cached by the family key, so a candidate scrolling
/// ten call-centre vacancies fetches it once.
@riverpod
Future<FieldSchema> vacancyFieldSchema(Ref ref, String category) =>
    ref.watch(profileRepositoryProvider).fetchVacancySchema(category);
