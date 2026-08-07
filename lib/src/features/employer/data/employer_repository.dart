import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/features/employer/domain/employer_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employer_repository.g.dart';

/// The employer profile and its verification (§6.1, BR-03).
class EmployerRepository {
  const EmployerRepository(this._dio);

  final Dio _dio;

  /// `GET /employers/me`, or **null when nothing has been created yet**.
  ///
  /// A 404 here is not a failure. Unlike the candidate profile there is no
  /// neutral empty employer to render, because `type` decides which fields
  /// exist — so "no profile" is a real state the screen has a design for, and
  /// mapping it to an error would show a retry button for a first-run user.
  Future<EmployerProfile?> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/employers/me');
      final data = response.data;
      if (data == null) return null;

      return EmployerProfile.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /employers/me` — a full replacement.
  ///
  /// The form is one screen (§6.1) and submits whole, so a partial write would
  /// only add a way for the two to disagree. Completeness is recomputed in the
  /// same transaction because BR-03 reads it on every vacancy submission,
  /// which is why the response is adopted rather than the request echoed.
  Future<EmployerProfile> save(Map<String, dynamic> body) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/employers/me',
        data: body,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return EmployerProfile.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /employers/me/verification`
  Future<VerificationState> verification() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/employers/me/verification',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return VerificationState.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /employers/me/verification`
  ///
  /// [fileIds] are files already stored through `POST /files` against the
  /// purposes the verification state lists. Two steps rather than one
  /// multipart submission, because evidence is picked one document at a time
  /// and a half-finished set must survive the screen being closed.
  Future<void> submitVerification(List<String> fileIds) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/employers/me/verification',
        data: {'fileIds': fileIds},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
EmployerRepository employerRepository(Ref ref) =>
    EmployerRepository(ref.watch(dioProvider));
