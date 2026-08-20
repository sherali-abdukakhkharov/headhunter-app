import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/profile/domain/attachment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attachments_repository.g.dart';

/// Profile files (§5.4, UAT-03).
///
/// ## Upload is the only call here that is not ordinary
///
/// UAT-03 asks for progress, cancel, a stated failure reason and retry, and all
/// four are properties of *this* call rather than of the screen:
///
/// - **Progress** comes from dio's `onSendProgress`, which is why the byte
///   counts are surfaced rather than a spinner. A CV over a slow connection is
///   exactly where an indeterminate spinner reads as a hang.
/// - **Cancel** needs the [CancelToken] to belong to the caller, so the widget
///   that started the upload is the one that can stop it.
/// - **The reason** is whatever the server said. A cancelled upload is *not* a
///   failure and must not be reported as one, which is why it throws
///   [UploadCancelled] rather than an [ApiException].
/// - **Retry** is just calling this again; nothing here holds failed state.
///
/// Replacement is the server's business: uploading past a purpose's `maxCount`
/// retires the oldest file of that purpose, and the new bytes are stored first,
/// so a failed replacement never leaves the candidate without a CV.
class AttachmentsRepository {
  const AttachmentsRepository(this._dio);

  final Dio _dio;

  /// `GET /candidates/me/attachments`
  Future<List<Attachment>> list() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/candidates/me/attachments',
      );
      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) Attachment.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /candidates/me/attachments` as multipart.
  ///
  /// [purposeCode] is the code, not the id: the contract takes it that way so a
  /// client can upload without having resolved the dictionary first.
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
        '/candidates/me/attachments',
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
      // A cancel is a thing the user did, not a thing that went wrong. Mapping
      // it to ApiException would put "the request failed" on screen after they
      // pressed Cancel, which reads as the cancel itself having broken.
      if (CancelToken.isCancel(e)) throw const UploadCancelled();
      throw ApiException.fromDioException(e);
    }
  }

  /// `DELETE /candidates/me/attachments/:id`
  Future<void> remove(String id) async {
    try {
      await _dio.delete<void>('/candidates/me/attachments/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

/// Thrown when the user cancelled an upload. Not an error to report.
class UploadCancelled implements Exception {
  const UploadCancelled();
}

@riverpod
AttachmentsRepository attachmentsRepository(Ref ref) =>
    AttachmentsRepository(ref.watch(dioProvider));

/// Every file on the profile, newest first, as the server orders them.
///
/// One provider for all purposes rather than one per slot: the endpoint returns
/// them together, and splitting the fetch would mean four round trips to draw
/// one screen.
@riverpod
Future<List<Attachment>> attachments(Ref ref) =>
    ref.watch(attachmentsRepositoryProvider).list();
