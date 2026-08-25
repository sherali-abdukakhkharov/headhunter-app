/// The verbs and the paths `NotificationRepository` actually puts on the wire.
///
/// **This file exists because of MT-020.** `markRead` and `markAllRead`
/// shipped as `POST` in 1.10.0 and again in 1.11.0 against a server that
/// declares both as `@Put`. Every read action in §9.2's notification centre —
/// opening a row, "mark all read", and the mark that follows a push tap —
/// answered 404 for two releases, so the badge never cleared and handled
/// events kept presenting themselves as new.
///
/// Three things let it through, and each one is answered here:
///
/// - **the tests faked the repository, not the transport.** Every notification
///   test until now supplied a `_FakeNotifications`, so the one property that
///   was wrong — the method — was the one property nothing asserted. The cases
///   below drive the real repository through a recording adapter.
/// - **404 is a legitimate answer on that route.** `notification.not_found`
///   is deliberately returned for somebody else's notification, so the wrong
///   verb was indistinguishable from the refusal the route is designed to
///   give. Reading the failure told you nothing.
/// - **nothing compared the two sides.** The client contract is handwritten
///   from the controller, and a handwritten copy drifts. The last case reads
///   the backend's own decorators and fails when they disagree.
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/domain/app_notification.dart';

/// Distinctive stand-ins, so a concrete path can be turned back into the
/// template the backend declares.
const _id = 'a0000000-0000-4000-8000-000000000000';
const _token = 'fcm-token-sentinel';

/// Records every request and answers the way the real routes do.
///
/// The status codes matter: `markRead` is 204 with no body and `markAllRead`
/// is 200 with `{marked}`, so a repository that mixed them up would be caught
/// here rather than on a device.
class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final carriesBody =
        options.method == 'GET' || options.path == '/notifications/read';

    if (!carriesBody) return ResponseBody.fromString('', 204);

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

/// Drives **every** method on the repository once, in a fixed order.
///
/// One helper rather than a request per test, so the route table below and the
/// backend comparison are derived from the same run: a method that stops being
/// exercised disappears from both at once instead of leaving one of them
/// quietly asserting nothing.
Future<List<RequestOptions>> _exerciseEveryRoute() async {
  final adapter = _Adapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  final repository = NotificationRepository(dio);

  await repository.list();
  await repository.unreadCount();
  await repository.markRead(_id);
  await repository.markAllRead();
  await repository.preferences();
  await repository.setPreference(
    NotificationCategory.applications,
    enabled: false,
  );
  await repository.registerDevice(token: _token, appVersion: '1.11.0 (16)');
  await repository.unregisterDevice(_token);

  return adapter.requests;
}

/// A concrete path with its arguments put back as the server's placeholders.
String _template(RequestOptions request) => request.path
    .replaceAll('/$_id/', '/:id/')
    .replaceAll('/devices/$_token', '/devices/:token')
    .replaceAll(
      '/preferences/${NotificationCategory.applications.wire}',
      '/preferences/:category',
    );

/// `VERB /path`, which is the whole of what has to agree between the repos.
String _route(RequestOptions request) =>
    '${request.method} ${_template(request)}';

/// Every `@Get`/`@Post`/`@Put`/`@Patch`/`@Delete` in a Nest controller, as
/// `VERB /full/path`.
Set<String> _declaredRoutes(String source) {
  final base = RegExp(r"@Controller\('([^']*)'\)").firstMatch(source);
  expect(base, isNotNull, reason: 'no @Controller() in the backend source');

  return RegExp(
        r"^\s*@(Get|Post|Put|Patch|Delete)\((?:'([^']*)')?\)",
        multiLine: true,
      )
      .allMatches(source)
      .map((match) {
        final verb = match.group(1)!.toUpperCase();
        final path = match.group(2) ?? '';
        return '$verb /${base!.group(1)}${path.isEmpty ? '' : '/$path'}';
      })
      .toSet();
}

void main() {
  group('the wire contract', () {
    test('every route uses the verb and path the server declares', () async {
      final requests = await _exerciseEveryRoute();

      // Written out rather than derived, because this list *is* the claim.
      // Deriving it from the repository would make it agree with whatever the
      // repository does, which is exactly the check that was missing.
      expect(requests.map(_route), [
        'GET /notifications',
        'GET /notifications/unread-count',
        'PUT /notifications/:id/read',
        'PUT /notifications/read',
        'GET /notifications/preferences',
        'PUT /notifications/preferences/:category',
        'POST /notifications/devices',
        'DELETE /notifications/devices/:token',
      ]);
    });

    // Named on their own as well, because these are the two that were wrong
    // and a failure message naming MT-020 is worth more than a diff of eight
    // strings to whoever changes this next.
    test('MT-020: marking one read is a PUT, never a POST', () async {
      final requests = await _exerciseEveryRoute();
      final markRead = requests.singleWhere(
        (request) => request.path.endsWith('/$_id/read'),
      );

      expect(
        markRead.method,
        'PUT',
        reason: 'POST 404s here, and 404 is also what somebody else’s '
            'notification returns, so the mistake is invisible in the log',
      );
    });

    test('MT-020: marking everything read is a PUT, never a POST', () async {
      final requests = await _exerciseEveryRoute();
      final markAll = requests.singleWhere(
        (request) => request.path == '/notifications/read',
      );

      expect(markAll.method, 'PUT');
    });

    test('the page size and offset are the ones the server pages by', () async {
      final requests = await _exerciseEveryRoute();

      expect(requests.first.queryParameters, {
        'limit': notificationPageSize,
        'offset': 0,
      });
    });

    test('a device registration names the platform it is', () async {
      final requests = await _exerciseEveryRoute();
      final register = requests.singleWhere(
        (request) => request.path == '/notifications/devices',
      );

      expect(register.data, {
        'token': _token,
        'platform': 'android',
        'appVersion': '1.11.0 (16)',
      });
    });
  });

  // The backend is a sibling checkout, reachable from a session rooted here
  // through permissions.additionalDirectories. It is **not** on CI, so this is
  // skipped there rather than failing a runner that has one repo.
  //
  // That makes it a developer-machine check, and it is still the only test
  // that can catch this class of bug at its source: everything else in this
  // file pins the client against a table a human transcribed, and MT-020 is
  // what happens when the transcription is wrong.
  final controller = File(
    '../headhunter-backend/src/modules/notifications/'
    'notifications.controller.ts',
  );
  final absent = !controller.existsSync()
      ? 'headhunter-backend is not checked out beside this repo, so the '
            'controller cannot be read. See CLAUDE.md for the layout.'
      : null;

  group('against the backend controller', () {
    test('the client calls nothing the controller does not declare', () async {
      final declared = _declaredRoutes(controller.readAsStringSync());
      final called = (await _exerciseEveryRoute()).map(_route).toSet();

      final table = (declared.toList()..sort()).join('\n  ');

      expect(
        called.difference(declared),
        isEmpty,
        reason: 'the controller declares:\n  $table',
      );
    });
  }, skip: absent);
}
