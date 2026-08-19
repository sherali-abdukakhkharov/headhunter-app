import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:jobbridge_app/src/features/applications/domain/application.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'application_repository.g.dart';

/// Applications (§8.1, BR-07).
class ApplicationRepository {
  const ApplicationRepository(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _keyPrefix = 'apply.idempotency.';

  /// `POST /vacancies/:id/applications` (§5.6, BR-07).
  ///
  /// ## The idempotency key is persisted, not minted per attempt
  ///
  /// BR-07 allows one active application per vacancy, and the failure this
  /// guards is not a double tap — it is a retry after the process died with
  /// the first request in flight. A key regenerated on the second attempt
  /// looks like a brand-new request and the server creates a second
  /// application, which is exactly what §12.4 says not to do.
  ///
  /// So the key is written down against the vacancy id *before* the request
  /// and only cleared once the server has answered. A retry finds the same key
  /// and the server recognises the replay.
  Future<Application> apply(String vacancyId, {String? coverNote}) async {
    final storageKey = '$_keyPrefix$vacancyId';
    final key = _prefs.getString(storageKey) ?? const Uuid().v4();
    await _prefs.setString(storageKey, key);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/vacancies/$vacancyId/applications',
        data: {'coverNote': ?coverNote},
        options: Options(
          extra: {IdempotencyInterceptor.keyExtra: key},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      // Cleared only once the server has answered: while it might still be
      // processing, the key has to stay so a retry replays rather than
      // duplicates.
      await _prefs.remove(storageKey);

      return Application.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /applications/mine`
  Future<List<Application>> mine() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/applications/mine',
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

  /// `POST /applications/:id/withdraw` — the candidate's own stage, and theirs
  /// alone (§8.1).
  Future<Application> withdraw(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/applications/$id/withdraw',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return Application.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
Future<ApplicationRepository> applicationRepository(Ref ref) async =>
    ApplicationRepository(
      ref.watch(dioProvider),
      await SharedPreferences.getInstance(),
    );

/// The candidate's own applications, every stage (§8.1).
@riverpod
Future<List<Application>> myApplications(Ref ref) async =>
    (await ref.watch(applicationRepositoryProvider.future)).mine();
