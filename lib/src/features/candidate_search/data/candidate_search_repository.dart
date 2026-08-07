import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'candidate_search_repository.g.dart';

/// Employer candidate search (§7.1–§7.3, BR-09).
class CandidateSearchRepository {
  const CandidateSearchRepository(this._dio);

  final Dio _dio;

  /// `POST /candidate-search`
  ///
  /// Verified employers only, and every result is already a searchable,
  /// complete profile (BR-02) — the client filters nothing further.
  Future<List<CandidateCard>> search(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/candidate-search',
        data: request,
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) CandidateCard.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /candidate-search/count` — §7.2's count before results.
  ///
  /// Separate from [search] because the point is to answer "how many" before
  /// anyone pays for a page of results, which is what makes a filter builder
  /// usable.
  Future<CandidateCount> count(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/candidate-search/count',
        data: request,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return CandidateCount.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /candidate-search/prefill/:vacancyId` (UAT-06).
  ///
  /// Returns a filter set derived from the vacancy's requirements. It is a
  /// starting point, not a lock — the caller edits it before searching.
  Future<Map<String, dynamic>> prefill(String vacancyId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/candidate-search/prefill/$vacancyId',
      );

      return response.data ?? const {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /candidate-search/saved`
  Future<List<CandidateCard>> saved() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/candidate-search/saved',
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) CandidateCard.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT`/`DELETE /candidate-search/saved/:candidateUserId`
  Future<void> setSaved(String candidateUserId, {required bool saved}) async {
    try {
      final path = '/candidate-search/saved/$candidateUserId';
      if (saved) {
        await _dio.put<void>(path);
      } else {
        await _dio.delete<void>(path);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /candidate-search/saved/:candidateUserId/note` — private (§7.3).
  Future<void> setNote(String candidateUserId, String note) async {
    try {
      await _dio.put<void>(
        '/candidate-search/saved/$candidateUserId/note',
        data: {'note': note},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT`/`DELETE /vacancies/:vacancyId/shortlist/:candidateUserId`
  Future<void> setShortlisted(
    String vacancyId,
    String candidateUserId, {
    required bool shortlisted,
  }) async {
    try {
      final path = '/vacancies/$vacancyId/shortlist/$candidateUserId';
      if (shortlisted) {
        await _dio.put<void>(path);
      } else {
        await _dio.delete<void>(path);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
CandidateSearchRepository candidateSearchRepository(Ref ref) =>
    CandidateSearchRepository(ref.watch(dioProvider));

/// Candidates this employer saved (§7.3).
@riverpod
Future<List<CandidateCard>> savedCandidates(Ref ref) =>
    ref.watch(candidateSearchRepositoryProvider).saved();
