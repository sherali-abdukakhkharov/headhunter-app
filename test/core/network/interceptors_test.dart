import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:jobbridge_app/src/core/network/interceptors/lang_interceptor.dart';

/// Captures the outgoing request and returns an empty 200.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CapturingAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = _CapturingAdapter();
    dio = Dio()..httpClientAdapter = adapter;
  });

  group('LangInterceptor', () {
    test('sends the canonical tag, script code intact', () async {
      dio.interceptors.add(LangInterceptor(() => AppLocale.uzCyrl));

      await dio.get<dynamic>('/anything');

      expect(adapter.lastRequest!.headers['x-lang'], 'uz-Cyrl');
    });

    // The whole point of reading the locale per request. A captured value would
    // keep sending the old language until the app restarted.
    test('follows a language change mid-session', () async {
      var current = AppLocale.ru;
      dio.interceptors.add(LangInterceptor(() => current));

      await dio.get<dynamic>('/first');
      expect(adapter.lastRequest!.headers['x-lang'], 'ru');

      current = AppLocale.uzLatn;
      await dio.get<dynamic>('/second');
      expect(adapter.lastRequest!.headers['x-lang'], 'uz-Latn');
    });

    test('never collapses the two Uzbek scripts', () async {
      dio.interceptors.add(LangInterceptor(() => AppLocale.uzLatn));
      await dio.get<dynamic>('/a');
      final latn = adapter.lastRequest!.headers['x-lang'];

      dio = Dio()..httpClientAdapter = adapter;
      dio.interceptors.add(LangInterceptor(() => AppLocale.uzCyrl));
      await dio.get<dynamic>('/a');
      final cyrl = adapter.lastRequest!.headers['x-lang'];

      expect(latn, isNot(cyrl));
      expect(latn, 'uz-Latn');
      expect(cyrl, 'uz-Cyrl');
    });
  });

  group('IdempotencyInterceptor', () {
    setUp(() => dio.interceptors.add(const IdempotencyInterceptor()));

    test('attaches a key to mutating requests', () async {
      await dio.post<dynamic>('/applications');

      final key =
          adapter.lastRequest!.headers[IdempotencyInterceptor.headerName];
      expect(key, isA<String>());
      expect(key as String, isNotEmpty);
    });

    test('leaves reads alone', () async {
      await dio.get<dynamic>('/vacancies');

      expect(
        adapter.lastRequest!.headers,
        isNot(contains(IdempotencyInterceptor.headerName)),
      );
    });

    // The behaviour that actually provides the protection: a key the repository
    // persisted alongside the pending action is used verbatim, so a retry after
    // a crash is recognised as the same request rather than creating a second
    // application (BR-07).
    test('uses a caller-supplied persisted key verbatim', () async {
      await dio.post<dynamic>(
        '/applications',
        options: Options(
          extra: {IdempotencyInterceptor.keyExtra: 'persisted-key-1'},
        ),
      );

      expect(
        adapter.lastRequest!.headers[IdempotencyInterceptor.headerName],
        'persisted-key-1',
      );
    });

    test('mints a different key per fresh action', () async {
      await dio.post<dynamic>('/a');
      final first =
          adapter.lastRequest!.headers[IdempotencyInterceptor.headerName];

      await dio.post<dynamic>('/a');
      final second =
          adapter.lastRequest!.headers[IdempotencyInterceptor.headerName];

      expect(first, isNot(second));
    });

    // A minted key is written back into `extra`, so replaying the same
    // RequestOptions - which is exactly what the auth interceptor does after a
    // refresh - reuses it instead of minting a second one.
    test('a replay of the same options reuses the minted key', () async {
      await dio.post<dynamic>('/applications');

      final options = adapter.lastRequest!;
      final minted = options.headers[IdempotencyInterceptor.headerName];

      await dio.fetch<dynamic>(options);

      expect(
        adapter.lastRequest!.headers[IdempotencyInterceptor.headerName],
        minted,
      );
    });
  });
}
