import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/config/app_config.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:headhunter_app/src/core/network/interceptors/lang_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured.
///
/// `AuthInterceptor` is deliberately **not** installed yet. It is written and
/// tested (`test/core/network/auth_interceptor_test.dart`), but it needs a
/// refresh callback, and the auth endpoints are not in the backend's
/// `docs/API_CONTRACTS.md` - that file covers locale, timestamps, dictionaries
/// and schemas only. Installing it now would mean inventing a request and
/// response shape and shipping the guess into the request path. Nothing in the
/// app calls an authenticated endpoint yet, so waiting costs nothing; adding it
/// is one `interceptors.add` once M1 publishes the contract.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
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
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // debugPrint, not developer.log: developer.log writes only to the VM
        // service, so it is invisible in `flutter run`, `flutter logs` and
        // logcat - exactly where you look when a request misbehaves.
        logPrint: (o) => debugPrint('[dio] $o'),
      ),
    );
  }

  ref.onDispose(dio.close);

  return dio;
}
