import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/profile/domain/candidate_profile.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

/// One rejected field from a 422 (§4.6).
class FieldError {
  const FieldError({required this.code, required this.rule, this.message});

  final String code;
  final String rule;
  final String? message;
}

/// A write the server refused field by field.
///
/// Separate from a plain [ApiException] because the errors have to land **on
/// the fields that caused them**. A form that answers a 422 with one banner
/// makes the user hunt for which of twenty inputs was wrong.
class FieldValidationException extends ApiException {
  const FieldValidationException(super.message, this.errors, {super.cause})
    : super(statusCode: 422);

  final List<FieldError> errors;

  /// Errors keyed by the field they belong to.
  ///
  /// A composite field reports on its parts — `skills.levelId`, not `skills` —
  /// so the prefix before the first dot is what maps a rejection back to the
  /// widget that can fix it. Without this, a 422 on a leveled row attaches to
  /// nothing and the form shows a banner with no indication of where to look.
  Map<String, String> get byCode {
    final byField = <String, String>{};
    for (final e in errors) {
      final field = e.code.split('.').first;
      // First one wins: a composite field can report several parts, and one
      // message under the field beats a last-write-wins scramble.
      byField.putIfAbsent(field, () => e.message ?? e.rule);
    }
    return byField;
  }
}

/// The candidate profile and the form that describes it (§5).
class ProfileRepository {
  const ProfileRepository(this._dio);

  final Dio _dio;

  /// `GET /schemas/candidate-profile?category=…`
  ///
  /// The form is fetched, not shipped: §5.2 makes the field set depend on the
  /// work category, and the server re-validates writes against this same
  /// declaration.
  Future<FieldSchema> fetchSchema(String category) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/schemas/candidate-profile',
        queryParameters: {'category': category},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return FieldSchema.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /schemas/vacancy?category=…`
  ///
  /// The same shape as [fetchSchema], deliberately: one form engine draws both
  /// the candidate profile and the vacancy, and one declaration validates
  /// both. `requiredForSearchable` here means "required before the vacancy may
  /// be submitted for publication".
  Future<FieldSchema> fetchVacancySchema(String category) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/schemas/vacancy',
        queryParameters: {'category': category},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return FieldSchema.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /candidates/me/profile`
  Future<CandidateProfile> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/candidates/me/profile',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return CandidateProfile.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PATCH /candidates/me/profile` — partial, by field code.
  ///
  /// Sends **only the codes that changed**. A full-document write would clobber
  /// a field another device edited between this screen loading and saving, and
  /// the contract is explicitly partial so there is no reason to.
  ///
  /// A key present with a null or empty value means "clear this", which is a
  /// legitimate write: requiredness gates searchability (BR-02), never the
  /// save.
  ///
  /// Returns the recomputed profile — completeness and the derived category are
  /// calculated server-side in the same transaction, so the response is the
  /// only trustworthy source for both.
  ///
  /// Throws [FieldValidationException] on a 422 so errors can be attached to
  /// individual fields.
  Future<CandidateProfile> patchProfile(Map<String, dynamic> fields) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/candidates/me/profile',
        data: {'fields': fields},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return CandidateProfile.fromJson(data);
    } on DioException catch (e) {
      final parsed = _asFieldErrors(e);
      if (parsed != null) throw parsed;
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /candidates/me/visibility` (UAT-12).
  Future<CandidateProfile> setVisibility(String visibility) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/candidates/me/visibility',
        data: {'visibility': visibility},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return CandidateProfile.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Moved out of this class: vacancy writes answer with the same §4.6 shape,
  // and a second parser would be a second thing to keep in step with it.
  static FieldValidationException? _asFieldErrors(DioException e) =>
      fieldErrorsFrom(e);
}

/// Turns a 422 body into per-field errors, or null when it is not one.
///
/// Shared by every write that can be refused field by field (§4.6) — the
/// candidate profile and vacancies both answer in this shape.
FieldValidationException? fieldErrorsFrom(DioException e) {
    if (e.response?.statusCode != 422) return null;

    final data = e.response?.data;
    if (data is! Map) return null;

    final raw = data['errors'];
    if (raw is! List) return null;

    final errors = <FieldError>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final code = entry['code'];
      final rule = entry['rule'];
      if (code is! String || rule is! String) continue;
      errors.add(
        FieldError(
          code: code,
          rule: rule,
          message: entry['message'] as String?,
        ),
      );
    }

    if (errors.isEmpty) return null;

    return FieldValidationException(
      data['message'] as String? ?? 'Some of the submitted data was not valid.',
      errors,
      cause: e,
  );
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(dioProvider));
