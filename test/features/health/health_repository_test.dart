import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/health/data/health_repository.dart';

/// Serves canned responses so the repository can be tested without a server.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => _respond(options);

  @override
  void close({bool force = false}) {}
}

Dio _dioReturning(ResponseBody Function(RequestOptions options) respond) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000',
      validateStatus: (s) => s != null && s >= 200 && s < 300,
    ),
  )..httpClientAdapter = _StubAdapter(respond);

  return dio;
}

void main() {
  group('HealthRepository', () {
    test('parses a healthy response', () async {
      final repo = HealthRepository(
        _dioReturning(
          (options) => ResponseBody.fromString(
            '{"status":"ok","database":"up","version":"0.0.1",'
            '"timestamp":"2026-08-04T10:00:00.000Z"}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ),
      );

      final status = await repo.fetchHealth();

      expect(status.status, 'ok');
      expect(status.database, 'up');
      expect(status.version, '0.0.1');
      expect(status.isHealthy, isTrue);
      expect(status.timestamp.toUtc().year, 2026);
    });

    test('isHealthy is false when the database is down', () async {
      final repo = HealthRepository(
        _dioReturning(
          (options) => ResponseBody.fromString(
            '{"status":"degraded","database":"down","version":"0.0.1",'
            '"timestamp":"2026-08-04T10:00:00.000Z"}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ),
      );

      final status = await repo.fetchHealth();

      expect(status.isHealthy, isFalse);
    });

    test('converts a 500 into an ApiException carrying the status', () async {
      // The server's own message wins over the generic text for the status.
      // Safe for a 500 specifically: the backend's exception filter answers
      // these with a translated `error.internal`, never the underlying fault.
      final repo = HealthRepository(
        _dioReturning(
          (options) => ResponseBody.fromString(
            '{"statusCode":500,"code":"error.internal",'
                '"message":"Kutilmagan xatolik yuz berdi."}',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ),
      );

      await expectLater(
        repo.fetchHealth(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having(
                (e) => e.message,
                'message',
                'Kutilmagan xatolik yuz berdi.',
              ),
        ),
      );
    });

    test('falls back to the status text when the body is not ours', () async {
      // A 502 from a proxy in front of the API: an HTML page, not the
      // backend's error envelope. None of that reaches the user.
      final repo = HealthRepository(
        _dioReturning(
          (options) => ResponseBody.fromString(
            '<html><body>502 Bad Gateway</body></html>',
            502,
            headers: {
              Headers.contentTypeHeader: ['text/html'],
            },
          ),
        ),
      );

      await expectLater(
        repo.fetchHealth(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('server ran into a problem'),
          ),
        ),
      );
    });

    test(
      'converts a connection failure into a friendly ApiException',
      () async {
        final repo = HealthRepository(
          _dioReturning(
            (options) => throw DioException.connectionError(
              requestOptions: options,
              reason: 'refused',
            ),
          ),
        );

        await expectLater(
          repo.fetchHealth(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              contains('Cannot reach the server'),
            ),
          ),
        );
      },
    );
  });
}
