import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/auth/token_store.dart';
import 'package:headhunter_app/src/core/config/app_config.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/core/network/auth_events.dart';
import 'package:headhunter_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:headhunter_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:headhunter_app/src/core/network/interceptors/lang_interceptor.dart';
import 'package:headhunter_app/src/core/network/log_redaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured.
///
/// ## Two clients, and why
///
/// The returned client carries [AuthInterceptor]. A **second, bare** client is
/// built alongside it for the two jobs that must not re-enter that interceptor:
/// the refresh call itself, and replaying a request after a refresh. Sharing
/// one client for both would mean a 401 on the refresh endpoint triggering
/// another refresh, forever.
///
/// The bare client is otherwise identical — it still sends `x-lang`, so a
/// refused refresh comes back in the user's language.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final bare = _client(ref);
  final client = _client(ref);

  // Inserted at the front so the token is attached before anything else looks
  // at the request. The log interceptor therefore sees the real outgoing
  // headers, which is why redaction is not optional — see [_logger].
  client.interceptors.insert(
    0,
    AuthInterceptor(
      tokenStore: ref.watch(tokenStoreProvider),
      refresh: (refreshToken) => _refresh(bare, refreshToken),
      retryClient: bare,
      // Not a direct call into SessionController: that would close a provider
      // cycle, because the controller reads the repository which reads this.
      // See AuthEvents.
      onAuthFailure: ref.watch(authEventsProvider).reportSessionLost,
    ),
  );

  ref
    ..onDispose(bare.close)
    ..onDispose(client.close);

  return client;
}

/// Everything both clients share.
Dio _client(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.requestTimeout,
      receiveTimeout: AppConfig.requestTimeout,
      // sendTimeout is deliberately not set: it only applies to requests with a
      // body, and setting it on bodyless GETs is a known source of confusion.
      contentType: Headers.jsonContentType,
      // Let every non-2xx surface as a DioException so error handling has
      // exactly one path.
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.addAll([
    // Reads the locale per request rather than capturing it, so a language
    // change mid-session applies to the very next call.
    LangInterceptor(() => ref.read(activeLocaleProvider)),
    const IdempotencyInterceptor(),
  ]);

  if (AppConfig.isNetworkLoggingEnabled) {
    dio.interceptors.add(_logger());
  }

  return dio;
}

LogInterceptor _logger() => LogInterceptor(
  requestBody: true,
  responseBody: true,
  // debugPrint, not developer.log: developer.log writes only to the VM
  // service, so it is invisible in `flutter run`, `flutter logs` and logcat -
  // exactly where you look when a request misbehaves.
  //
  // Every line goes through redactSensitive first. Without it this prints the
  // bearer token on every request and the whole token pair on every sign-in
  // and every refresh (§12.1).
  logPrint: (o) => debugPrint('[dio] ${redactSensitive(o.toString())}'),
);

/// `POST /auth/refresh`, for [AuthInterceptor].
///
/// Returns the rotated pair, or **null when the server refused it** — which is
/// the interceptor's signal that the session is gone.
///
/// Telling the two failure kinds apart is the whole job here, and getting it
/// backwards signs people out for being on a train:
///
/// - **401/403** — the refresh token is dead, revoked, or was already used.
///   Return null; the session really is over.
/// - **anything else** — offline, DNS, a 500, a timeout. Rethrow. The tokens
///   are very probably still valid, so the interceptor keeps them and surfaces
///   the original error instead.
Future<TokenPair?> _refresh(Dio bare, String refreshToken) async {
  try {
    final response = await bare.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {AuthInterceptor.skipAuthFlag: true}),
    );

    final data = response.data;
    if (data == null) return null;

    return TokenPair(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) return null;
    rethrow;
  }
}
