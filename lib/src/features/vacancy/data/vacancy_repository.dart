import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/features/profile/data/profile_repository.dart';
import 'package:headhunter_app/src/features/vacancy/domain/vacancy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vacancy_repository.g.dart';

/// Vacancies (§6.3, §6.4).
class VacancyRepository {
  const VacancyRepository(this._dio);

  final Dio _dio;

  /// `POST /vacancies` — creates an empty draft.
  ///
  /// BR-03 is checked here as well as at submit, so an employer who cannot
  /// publish is told before filling in a form rather than after.
  Future<Vacancy> create() => _one(() => _dio.post('/vacancies'));

  /// `GET /vacancies/mine` — every status.
  ///
  /// Closed ones included: BR-11 removes a closed vacancy from discovery and
  /// keeps it in the employer's history, so filtering it out here would hide
  /// something the contract deliberately preserves.
  Future<List<Vacancy>> listMine() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/vacancies/mine',
      );
      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) Vacancy.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Vacancy> read(String id) => _one(() => _dio.get('/vacancies/$id'));

  /// `PATCH /vacancies/:id` — partial, by field code.
  ///
  /// Throws [FieldValidationException] on a 422 so rejections land on the
  /// fields that caused them, exactly as the candidate profile does — the
  /// contract is the same §4.6 shape.
  Future<Vacancy> patch(String id, Map<String, dynamic> fields) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/vacancies/$id',
        data: {'fields': fields},
      );

      return _parse(response.data);
    } on DioException catch (e) {
      final parsed = fieldErrorsFrom(e);
      if (parsed != null) throw parsed;
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /vacancies/:id/submit`
  ///
  /// Also a 422 carrier: the server answers one `required` violation per
  /// unfilled field so each can be focused, which is the same treatment a
  /// field rejection gets.
  Future<Vacancy> submit(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/vacancies/$id/submit',
      );

      return _parse(response.data);
    } on DioException catch (e) {
      final parsed = fieldErrorsFrom(e);
      if (parsed != null) throw parsed;
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /vacancies/:id/status` — pause, resume or close (§6.4).
  ///
  /// [reason] is the employer's own words on closing, which BR-08 audits.
  Future<Vacancy> changeStatus(
    String id,
    String status, {
    String? reason,
  }) => _one(
    () => _dio.put(
      '/vacancies/$id/status',
      data: {'status': status, 'reason': ?reason},
    ),
  );

  Future<Vacancy> _one(
    Future<Response<Map<String, dynamic>>> Function() send,
  ) async {
    try {
      return _parse((await send()).data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Vacancy _parse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('The server returned an empty response.');
    }

    return Vacancy.fromJson(data);
  }
}

@riverpod
VacancyRepository vacancyRepository(Ref ref) =>
    VacancyRepository(ref.watch(dioProvider));

/// The employer's own vacancies, every status.
@riverpod
Future<List<Vacancy>> myVacancies(Ref ref) =>
    ref.watch(vacancyRepositoryProvider).listMine();
