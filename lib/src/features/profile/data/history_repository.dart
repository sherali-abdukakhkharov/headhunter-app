import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/profile/domain/history_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_repository.g.dart';

/// The repeating sections of the candidate profile (§5.1): work experience and
/// education.
///
/// ## The path comes from the schema, not from here
///
/// Every method takes the sub-resource path, because the schema publishes it as
/// the section's `endpoint`. Hardcoding `/candidates/me/experience` in the
/// client would make a server-side move a client release, which is the whole
/// reason the field is published. [experiencePath] and [educationPath] exist
/// only as the fallback for a schema that omits it.
///
/// ## Writes are full replacements
///
/// `PUT`, not `PATCH`: these records are small and a bespoke editor submits the
/// whole form, so a partial write would only add a way for the two to disagree.
/// The server says the same thing in its own words.
class HistoryRepository {
  const HistoryRepository(this._dio);

  /// Fallbacks for a schema section that publishes no `endpoint`.
  static const experiencePath = '/candidates/me/experience';
  static const educationPath = '/candidates/me/education';

  final Dio _dio;

  Future<List<ExperienceRecord>> listExperience(String path) =>
      _list(path, ExperienceRecord.fromJson);

  Future<List<EducationRecord>> listEducation(String path) =>
      _list(path, EducationRecord.fromJson);

  /// `POST <path>`
  Future<void> add(String path, Object draft) async {
    try {
      await _dio.post<Map<String, dynamic>>(path, data: draft);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT <path>/:id`
  Future<void> replace(String path, String id, Object draft) async {
    try {
      await _dio.put<Map<String, dynamic>>('$path/$id', data: draft);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `DELETE <path>/:id`
  Future<void> remove(String path, String id) async {
    try {
      await _dio.delete<void>('$path/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET <path>` — both list endpoints answer `{items: [...]}`.
  ///
  /// A missing or malformed `items` reads as an empty list rather than
  /// throwing: an empty section is a state this screen already renders, and a
  /// candidate with no work history should see "nothing yet", not an error.
  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) parse(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
HistoryRepository historyRepository(Ref ref) =>
    HistoryRepository(ref.watch(dioProvider));
