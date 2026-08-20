import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employer_applications_repository.g.dart';

/// The employer's side of applications (§6.5, §8.1, §8.2, BR-09).
class EmployerApplicationsRepository {
  const EmployerApplicationsRepository(this._dio);

  final Dio _dio;

  /// `GET /vacancies/:id/applications`
  /// [status] is the **server's** filter (§6.5), so a filtered list is
  /// complete rather than filtered-over-what-was-loaded — the same distinction
  /// the invitation sent list draws against the Coin ledger's client-side one.
  Future<List<Application>> forVacancy(
    String vacancyId, {
    String? status,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/vacancies/$vacancyId/applications',
        queryParameters: {'status': ?status},
      );
      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) Application.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /vacancies/:id/applications/counts` — §6.5's hired-vs-required.
  Future<ApplicationCounts> counts(String vacancyId) =>
      _one('/vacancies/$vacancyId/applications/counts', ApplicationCounts.fromJson);

  /// `PUT /applications/:id/stage` (§8.1).
  ///
  /// [reason] is shown to the candidate on a rejection and recorded in the
  /// BR-08 history whatever the stage.
  Future<Application> moveStage(
    String id,
    String status, {
    String? reason,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/applications/$id/stage',
        data: {'status': status, 'reason': ?reason},
      );

      return _parse(response.data, Application.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /applications/:id/candidate` (BR-09).
  ///
  /// What comes back is already filtered by the server: no phone unless the
  /// candidate's privacy settings and this interaction both allow it, and no
  /// files unless `canViewFiles`. The client renders what arrived — it does
  /// not decide.
  Future<CandidateForEmployer> candidate(String id) =>
      _one('/applications/$id/candidate', CandidateForEmployer.fromJson);

  /// `GET /applications/:id/notes` — the employer's own, private (§8.2).
  Future<List<ApplicationNote>> notes(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/applications/$id/notes',
      );
      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) ApplicationNote.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /applications/:id/notes`
  Future<void> addNote(String id, String note) async {
    try {
      await _dio.post<void>(
        '/applications/$id/notes',
        data: {'note': note},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> _one<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      return _parse(response.data, parse);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  T _parse<T>(
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (data == null) {
      throw const ApiException('The server returned an empty response.');
    }

    return parse(data);
  }
}

@riverpod
EmployerApplicationsRepository employerApplicationsRepository(Ref ref) =>
    EmployerApplicationsRepository(ref.watch(dioProvider));

/// Applications on one vacancy, optionally narrowed server-side (§6.5).
///
/// `status` is a named argument rather than a second positional one so the
/// existing `vacancyApplicationsProvider(id)` call sites keep meaning "all of
/// them" — which is what they meant before the filter existed.
@riverpod
Future<List<Application>> vacancyApplications(
  Ref ref,
  String vacancyId, {
  String? status,
}) => ref
    .watch(employerApplicationsRepositoryProvider)
    .forVacancy(vacancyId, status: status);

/// The employer's own private notes on one application (§7.3).
///
/// Private to the employer: the candidate never sees these, which is why the
/// screen says so beside the field. A note is the one thing on the applicants
/// screen written *by* the employer rather than read from the candidate.
@riverpod
Future<List<ApplicationNote>> applicationNotes(Ref ref, String applicationId) =>
    ref.watch(employerApplicationsRepositoryProvider).notes(applicationId);

/// §6.5's counts for one vacancy.
@riverpod
Future<ApplicationCounts> vacancyApplicationCounts(
  Ref ref,
  String vacancyId,
) => ref.watch(employerApplicationsRepositoryProvider).counts(vacancyId);

/// One candidate, as BR-09 permits this employer to see them.
@riverpod
Future<CandidateForEmployer> applicationCandidate(
  Ref ref,
  String applicationId,
) => ref.watch(employerApplicationsRepositoryProvider).candidate(applicationId);
