import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/network/upload_cancelled.dart';
import 'package:jobbridge_app/src/shared/domain/attachment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'evidence_repository.g.dart';

/// The employer's verification documents (§6.1).
///
/// ## Why the generic `/files`, not an employer-specific route
///
/// `/candidates/me/attachments` exists because a candidate's files sit in
/// schema-declared *slots* with their own `maxCount` and accepted extensions,
/// and something has to enforce that. Verification evidence has no slots:
/// `GET /employers/me/verification` already says which purposes are wanted, and
/// `POST /employers/me/verification` decides whether what was uploaded is
/// enough. A second attachments controller would only restate that.
///
/// So this uploads against the owner-scoped `POST /files` and hands the
/// resulting ids to the submission. The server checks each id belongs to the
/// caller, which is what stops one employer submitting another's certificate.
///
/// ## The list is filtered by purpose, server-side
///
/// `GET /files` with no filter returns everything the account owns, and for an
/// employer that is exactly the evidence. It is still requested per purpose:
/// the card draws one row per required document, and asking for what that row
/// needs keeps the row from having to know about the others.
class EvidenceRepository {
  const EvidenceRepository(this._dio);

  final Dio _dio;

  /// `GET /files`, optionally narrowed to one `file_purpose` code.
  Future<List<Attachment>> list({String? purposeCode}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/files',
        // Null-aware, so an unfiltered call sends no `purpose` at all. An
        // empty one would filter on the empty code and return nothing.
        queryParameters: {'purpose': ?purposeCode},
      );

      final files = response.data?['files'];
      if (files is! List) return const [];

      return [
        for (final file in files)
          if (file is Map<String, dynamic>) Attachment.fromJson(file),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /files` as multipart.
  ///
  /// Progress, cancel and a stated reason for the same reasons UAT-03 asks for
  /// them on a CV: a registration certificate is a scan, scans are large, and
  /// an indeterminate spinner over a slow connection reads as a hang.
  ///
  /// [purposeCode] is the **code** the required-evidence row named, not a
  /// dictionary id — `POST /files` takes it that way so nothing has to resolve
  /// the dictionary before it can upload.
  Future<Attachment> upload({
    required String purposeCode,
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final form = FormData.fromMap({
        'purpose': purposeCode,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/files',
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return Attachment.fromJson(data);
    } on DioException catch (e) {
      // A cancel is a thing the user did, not a thing that went wrong.
      if (CancelToken.isCancel(e)) throw const UploadCancelled();
      throw ApiException.fromDioException(e);
    }
  }

  /// `DELETE /files/:id`
  Future<void> remove(String id) async {
    try {
      await _dio.delete<void>('/files/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
EvidenceRepository evidenceRepository(Ref ref) =>
    EvidenceRepository(ref.watch(dioProvider));

/// Every file the employer has uploaded, newest first.
///
/// One request for all purposes rather than one per row: the endpoint returns
/// them together and the card draws every row at once, so filtering per purpose
/// would be several round trips to paint one card.
@riverpod
Future<List<Attachment>> evidenceFiles(Ref ref) =>
    ref.watch(evidenceRepositoryProvider).list();
