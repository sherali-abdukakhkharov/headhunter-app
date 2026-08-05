import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/network/dio_provider.dart';
import 'package:headhunter_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:headhunter_app/src/features/auth/domain/auth_session.dart';
import 'package:headhunter_app/src/features/auth/domain/otp_challenge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Exchanges credentials for a session.
class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  /// `POST /auth/otp/send` — asks the backend to issue a code for [phone]
  /// (§4.1).
  ///
  /// [phone] must already be in wire form (`+998…`); build it with
  /// `UzPhone.wire` rather than concatenating a dial code at the call site. The
  /// backend normalises again on its side, but the rate limiter keys on the
  /// normalised number, so two spellings of one phone must not reach it.
  ///
  /// No `purpose` is sent. Registration and login are the same act for a
  /// phone-only identity, and the server decides which happened — asking the
  /// client to choose would let anyone probe which numbers are registered.
  ///
  /// Throws [ApiException]. A **429** is expected traffic here, not a bug: it
  /// is how §4.2's resend delay and the per-phone rate limit are enforced.
  Future<OtpChallenge> sendOtp(String phone) => _requestCode('/send', phone);

  /// `POST /auth/otp/resend` — identical to [sendOtp], and identical on the
  /// server too.
  ///
  /// Kept as its own method rather than a flag because the two are separate
  /// rate-limit subjects and separate lines in a log; the call site reads
  /// better for saying which one it meant.
  Future<OtpChallenge> resendOtp(String phone) =>
      _requestCode('/resend', phone);

  Future<OtpChallenge> _requestCode(String suffix, String phone) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp$suffix',
        data: {'phone': phone},
        // No session exists yet; see signInWithTelegram for why this matters.
        options: Options(extra: {AuthInterceptor.skipAuthFlag: true}),
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return OtpChallenge.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /auth/otp/verify` — trades a code for a session (§4.1).
  ///
  /// **This is what makes the phone number verified**, so an account that
  /// reaches a session through here satisfies BR-01 by construction. That is
  /// the whole reason this path came back: Telegram login had to ask for a
  /// phone and could be refused it.
  ///
  /// Throws [ApiException]. A **401** here means the code was wrong, expired or
  /// already used — the server deliberately does not distinguish them, because
  /// doing so tells an attacker which numbers have a code pending.
  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {'phone': phone, 'code': code, ..._deviceInfo()},
        options: Options(extra: {AuthInterceptor.skipAuthFlag: true}),
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

  /// `POST /auth/telegram` — trades a Telegram OIDC ID token for a session.
  ///
  /// **Deprecated 2026-08-05**: the app signs in with phone + OTP (§4.1,
  /// UAT-01). Nothing calls this. It is kept, with its tests and the endpoint
  /// behind it, because the flow is correct and re-enabling it is cheaper than
  /// rebuilding it — see docs/TELEGRAM_LOGIN.md.
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
