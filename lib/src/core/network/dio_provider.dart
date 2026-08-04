import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// The app-wide [Dio] instance.
///
/// This is the single place HTTP behaviour is configured. Auth token injection
/// belongs here as an interceptor once the auth feature lands.
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
