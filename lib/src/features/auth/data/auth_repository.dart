import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:headhunter_app/src/features/auth/domain/auth_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Exchanges credentials for a session.
class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  /// `POST /auth/telegram` — trades a Telegram OIDC ID token for a session.
  ///
  /// The token is a bearer credential with a very short life: the backend
  /// accepts it for five minutes from its `iat`, not until `exp`, so it must be
  /// posted immediately and **never cached**.
  ///
  /// The account's locale comes from the `x-lang` header the interceptor stack
  /// already sets, so there is nothing to pass for language.
  ///
  /// Throws [ApiException]. A 4xx here is meaningful rather than generic: the
  /// backend refuses a login that carries no Telegram-verified phone number
  /// (BR-01), and its message arrives already localized.
  Future<AuthSession> signInWithTelegram(String idToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/telegram',
        data: {'idToken': idToken, ..._deviceInfo()},
        options: Options(
          // No session exists yet, so a 401 here means Telegram's token was
          // rejected - not that an access token expired. Without this flag the
          // auth interceptor would try to refresh a session that does not
          // exist, and on failure would clear tokens and report an auth
          // failure, turning a bad-credentials message into a spurious
          // "signed out".
          extra: {AuthInterceptor.skipAuthFlag: true},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return AuthSession.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Device fields the backend records against the session, so the sessions
  /// screen (§4.2) can name devices.
  ///
  /// `platform` is validated server-side against `['android', 'ios']`, so it is
  /// omitted rather than guessed anywhere else - a wrong value is a 400 on the
  /// login itself.
  Map<String, String> _deviceInfo() => {
    if (Platform.isAndroid) 'platform': 'android',
    if (Platform.isIOS) 'platform': 'ios',
  };
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(dioProvider));
