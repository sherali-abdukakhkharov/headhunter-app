import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/account/domain/user_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_repository.g.dart';

/// The account's own operations: which devices are signed in (§4.2), and asking
/// for the account to be deleted (BR-14).
///
/// Separate from `AuthRepository`, which owns getting *in*. This owns what an
/// account holder does about an account they already have, and the split
/// matters once: `AuthRepository.logout` is deliberately `@Public` and
/// unauthenticated, so it can succeed with an expired token. Everything here
/// requires a live session by design — revoking somebody else's device must not
/// be possible from a token the server has already stopped honouring.
class AccountRepository {
  const AccountRepository(this._dio);

  final Dio _dio;

  /// `GET /auth/sessions` — every device currently signed in (§4.2).
  Future<List<UserSession>> sessions() async {
    try {
      final response = await _dio.get<List<dynamic>>('/auth/sessions');

      return [
        for (final item in response.data ?? const [])
          if (item is Map<String, dynamic>) UserSession.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `DELETE /auth/sessions/:id` — revoke one device (§4.2).
  ///
  /// A 404 means the id is not this account's. The server answers 404 rather
  /// than 403 on purpose — "confirming that an id exists but belongs to another
  /// account is information we do not owe" — so this must **not** be re-worded
  /// into "no such session", which would leak the same thing the status was
  /// chosen to hide.
  Future<void> revokeSession(String id) async {
    try {
      await _dio.delete<void>('/auth/sessions/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /auth/logout-all` — revoke every session, including this one (§4.2).
  Future<void> revokeAll() async {
    try {
      await _dio.post<void>('/auth/logout-all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /users/me` — the account's stored interface language (§3.2).
  ///
  /// Only the locale is read here. The rest of the response is identity and
  /// roles, which the session already holds from the token exchange; taking a
  /// second copy would give two answers to the same question.
  Future<String?> accountLocale() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/me');
      final locale = response.data?['locale'];

      return locale is String ? locale : null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PATCH /users/me/locale` — stores the choice on the account (§3.2).
  ///
  /// So the language follows the user to every signed-in device rather than
  /// staying on the install that changed it.
  Future<void> updateLocale(String tag) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/users/me/locale',
        data: {'locale': tag},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /users/me/deletion-request` — BR-14's request, not a deletion.
  ///
  /// The account moves to `deletion_requested` and a status-history row is
  /// written; nothing is purged synchronously. **The server returns
  /// `purgeAfter: null`** because the retention period is still an open client
  /// question, so the client must not print a date — a made-up one is the kind
  /// of promise that ends up in a complaint.
  ///
  /// [reason] is the account holder's own words and is optional.
  Future<ZonedTimestamp> requestDeletion({String? reason}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users/me/deletion-request',
        data: {'reason': ?reason},
      );

      final requestedAt = response.data?['requestedAt'];
      if (requestedAt is! String) {
        throw const ApiException('The server returned an empty response.');
      }

      return ZonedTimestamp.parse(requestedAt);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

@riverpod
AccountRepository accountRepository(Ref ref) =>
    AccountRepository(ref.watch(dioProvider));

/// The devices signed in to this account (§4.2).
@riverpod
Future<List<UserSession>> userSessions(Ref ref) =>
    ref.watch(accountRepositoryProvider).sessions();
