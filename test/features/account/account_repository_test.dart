/// The verbs and paths `AccountRepository` puts on the wire.
///
/// **This file exists because of the deletion request.** BR-14's "request
/// account deletion" called `POST /users/deletion-request` from the day it
/// shipped. The server declares `@Controller('users/me')` +
/// `@Post('deletion-request')`, so the route is `/users/me/deletion-request`
/// and the client's call answered 404 — confirmed against the running API on
/// 2026-08-28, where the wrong path returns 404 and the right one 401.
///
/// Nothing was red. Every test in the account slice faked the repository, so
/// the one property that was wrong was the one property nothing asserted —
/// the same shape as MT-020, in a different feature, two months later.
///
/// `test/core/network/wire_contract_test.dart` is what found it, and covers
/// every repository. This file covers what a source sweep cannot see: the body
/// a request carries, and the fact that a 404 here is *not* a normal answer.
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/account/data/account_repository.dart';

const _id = 'a0000000-0000-4000-8000-000000000000';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final body = switch (options.path) {
      '/auth/sessions' => '[]',
      '/users/me/deletion-request' =>
        '{"requestedAt":"2026-08-28T10:00:00+05:00","purgeAfter":null}',
      _ => '',
    };

    if (body.isEmpty) return ResponseBody.fromString('', 204);

    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<List<RequestOptions>> _exerciseEveryRoute() async {
  final adapter = _Adapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  final repository = AccountRepository(dio);

  await repository.sessions();
  await repository.revokeSession(_id);
  await repository.revokeAll();
  await repository.requestDeletion(reason: 'Moving abroad');

  return adapter.requests;
}

String _route(RequestOptions request) =>
    '${request.method} ${request.path.replaceAll('/$_id', '/:id')}';

void main() {
  test('every route uses the verb and path the server declares', () async {
    final requests = await _exerciseEveryRoute();

    // Written out rather than derived: this list *is* the claim, and deriving
    // it from the repository would only make it agree with itself.
    expect(requests.map(_route), [
      'GET /auth/sessions',
      'DELETE /auth/sessions/:id',
      'POST /auth/logout-all',
      'POST /users/me/deletion-request',
    ]);
  });

  test('the deletion request is under /users/me, not /users', () async {
    final requests = await _exerciseEveryRoute();
    final deletion = requests.singleWhere((r) => r.path.contains('deletion'));

    expect(
      deletion.path,
      '/users/me/deletion-request',
      reason: '/users/deletion-request is a 404, and 404 on this route reads '
          'as "nothing to delete" rather than as a wrong path',
    );
  });

  test('an omitted reason is absent, not an empty string', () async {
    final adapter = _Adapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;

    await AccountRepository(dio).requestDeletion();

    // The reason is the account holder's own words and is optional. An empty
    // string is a reason they did not give.
    expect(adapter.requests.single.data, isEmpty);
  });

  test('a response without a timestamp is a failure, not a null', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();

    // §12.4: the request either was recorded or was not, and a screen that
    // said "requested" against an empty body would be claiming the first
    // without evidence.
    await expectLater(
      AccountRepository(dio).requestDeletion(),
      throwsA(isA<ApiException>()),
    );
  });

  // The backend is a sibling checkout, reachable through
  // permissions.additionalDirectories. Not on CI, so this skips there.
  final controller = File(
    '../headhunter-backend/src/modules/users/users.controller.ts',
  );
  final absent = !controller.existsSync()
      ? 'headhunter-backend is not checked out beside this repo.'
      : null;

  test('the users controller is still mounted at users/me', () {
    final source = controller.readAsStringSync();

    // The half the client cannot see from its own path: if the controller is
    // ever remounted, this fails here rather than in production.
    expect(source, contains("@Controller('users/me')"));
    expect(source, contains("@Post('deletion-request')"));
  }, skip: absent);
}

class _EmptyAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
