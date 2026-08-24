/// §9.2's push half — MT-005's other half, unblocked on 2026-08-24.
///
/// Three kinds of thing are checked here, and the first two are the ones that
/// go wrong silently:
///
/// - **the configuration that blocked push for five days.** Firebase knew the
///   app by its pre-rename package name, so the SDK found no entry for the id
///   it was running under and never produced a token. Nothing failed; a token
///   simply never arrived. The Gradle plugin now fails the build on that, and
///   the check below fails the *test suite* on it, which is sooner.
/// - **one routing table, not two.** A push carries `targetType`/`targetId` and
///   no sentence, so it cannot build an `AppNotification` to ask with. If the
///   table were copied, a push and the in-app row announcing it would lead to
///   different screens — and only on a real device, after a real send.
/// - **the lifecycle**, whose ordering claim is the whole reason registration
///   is driven by the session rather than observed from it.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/token_store.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/auth_session.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_messaging.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_platform.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_registration.dart';
import 'package:jobbridge_app/src/features/notifications/domain/app_notification.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A push provider under the test's control.
///
/// Every method the real one can answer with "no" answers with "no" here by
/// default, because that is the interesting configuration: a phone with no
/// Play services must run the whole product.
class _FakeMessaging implements PushMessaging {
  String? registrationToken;
  bool permitted = true;
  int permissionRequests = 0;

  final _refreshes = StreamController<String>.broadcast();
  final _opened = StreamController<PushPayload>.broadcast();
  final _foreground = StreamController<PushPayload>.broadcast();
  PushPayload? launchTap;

  void rotate(String token) => _refreshes.add(token);

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permitted;
  }

  @override
  Future<String?> token() async => registrationToken;

  @override
  Stream<String> tokenRefreshes() => _refreshes.stream;

  @override
  Stream<PushPayload> opened() => _opened.stream;

  @override
  Future<PushPayload?> initialMessage() async => launchTap;

  @override
  Stream<PushPayload> foregroundMessages() => _foreground.stream;

  Future<void> close() async {
    await _refreshes.close();
    await _opened.close();
    await _foreground.close();
  }
}

/// Only the device half is implemented; the rest throws, so a test that
/// wandered into the in-app endpoints fails here rather than passing on a
/// default.
class _FakeRepository implements NotificationRepository {
  ApiException? failure;

  /// Shared with the other fakes, so the *order* of sign-out steps is
  /// observable rather than inferred.
  List<String>? log;

  final registered = <({String token, String? appVersion})>[];
  final unregistered = <String>[];

  @override
  Future<void> registerDevice({
    required String token,
    String? appVersion,
  }) async {
    if (failure case final error?) throw error;
    registered.add((token: token, appVersion: appVersion));
  }

  @override
  Future<void> unregisterDevice(String token) async {
    log?.add('unregister');
    if (failure case final error?) throw error;
    unregistered.add(token);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not push');
}

class _FakeTokenStore extends TokenStore {
  _FakeTokenStore({this.log}) : super(const FlutterSecureStorage());

  List<String>? log;
  String? refreshToken = 'refresh-1';

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> save(TokenPair tokens) async =>
      refreshToken = tokens.refreshToken;

  @override
  Future<void> clear() async {
    log?.add('clear');
    refreshToken = null;
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.log}) : super(Dio());

  List<String>? log;

  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      AuthSession.fromJson({
        'accessToken': 'access-2',
        'refreshToken': 'refresh-2',
        'expiresInSeconds': 900,
        'roles': ['candidate'],
        'activeRole': 'candidate',
        'isNewUser': false,
      });

  @override
  Future<void> logout(String refreshToken) async => log?.add('logout');
}

AppNotification _notification({String? targetType, String? targetId}) =>
    AppNotification.fromJson({
      'id': 'ntf-1',
      'event': 'anything',
      'category': 'messages',
      'text': 'a sentence the client never parses',
      'targetType': targetType,
      'targetId': targetId,
      'isRead': false,
      'createdAt': '2026-08-24T09:00:00+05:00',
    });

const _pushChannel = MethodChannel(PushPlatform.channelName);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeMessaging messaging;
  late _FakeRepository repository;
  final platformCalls = <MethodCall>[];

  setUp(() {
    messaging = _FakeMessaging();
    repository = _FakeRepository();
    platformCalls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pushChannel, (call) async {
          platformCalls.add(call);
          return call.method == 'appVersion' ? '1.11.0 (16)' : null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pushChannel, null);
    await messaging.close();
  });

  ProviderContainer containerWith() {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        pushMessagingProvider.overrideWithValue(messaging),
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('the configuration that was the whole blocker', () {
    // Firebase identifies an app by its package name and a package name cannot
    // be renamed there. From 2026-08-19 to 2026-08-24 this file listed only the
    // pre-rename ids, so the SDK found no entry for what it was running under
    // and refused to initialise - no token, nothing to register, no push, and
    // no error anywhere that said so.
    //
    // **The file is gitignored and supplied per machine** (android/.gitignore),
    // so these two cases are skipped where it is absent rather than failing a
    // fresh clone that has not fetched it yet. CI restores it from
    // GOOGLE_SERVICES_JSON_BASE64 before `flutter test`, which is where this
    // check earns its keep.
    final file = File('android/app/google-services.json');
    final absent = !file.existsSync()
        ? 'android/app/google-services.json is not on this machine. It is '
              'gitignored and fetched from the Firebase console — see '
              'docs/NOTIFICATIONS_SETUP.md. On CI it comes from the '
              'GOOGLE_SERVICES_JSON_BASE64 repository secret.'
        : null;

    Set<String> packages() =>
        ((jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['client']
                as List)
            .cast<Map<String, dynamic>>()
            .map(
              (client) =>
                  ((client['client_info']
                              as Map<String, dynamic>)['android_client_info']
                          as Map<String, dynamic>)['package_name']
                      as String,
            )
            .toSet();

    test('every flavor Gradle can build has a Firebase entry', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      // Derived from Gradle rather than restated, so adding a fourth flavor
      // fails here instead of shipping one that cannot receive push.
      final applicationId = RegExp('applicationId = "([^"]+)"')
          .firstMatch(gradle)!
          .group(1)!;
      final suffixes = RegExp('applicationIdSuffix = "([^"]+)"')
          .allMatches(gradle)
          .map((m) => m.group(1)!);

      final ids = [
        applicationId,
        ...suffixes.map((s) => '$applicationId$s'),
      ];

      for (final id in ids) {
        expect(
          packages(),
          contains(id),
          reason:
              '$id has no client entry in google-services.json. The '
              'google-services Gradle plugin fails the build on this, and '
              'before it was applied the symptom was a token that never '
              'arrived.',
        );
      }
    }, skip: absent);

    test('the pre-rename entries are kept, not replaced', () {
      // Downloading the file again after registering the new apps returns all
      // six. Deleting the old three would be tidier and would break nothing
      // here - which is exactly why it is worth saying that nobody chose to.
      expect(packages(), contains('com.headhunter.app'));
      expect(packages(), hasLength(6));
    }, skip: absent);

    test('the channel id is the same string in all three places', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      final activity = File(
        'android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt',
      ).readAsStringSync();

      // A payload naming a channel that does not exist is not an error: FCM
      // posts it to its own fallback channel, at DEFAULT importance and
      // therefore with no banner. A typo here costs the heads-up notification
      // and reports nothing.
      expect(manifest, contains(PushPlatform.notificationChannelId));
      expect(activity, contains(PushPlatform.notificationChannelId));
      expect(
        manifest,
        contains(
          'com.google.firebase.messaging.'
          'default_notification_channel_id',
        ),
      );
    });

    test('the runtime permission Android 13 needs is declared', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      // Without this the request is refused without ever showing a dialog, and
      // the app looks like a user who said no.
      expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    });
  });

  group('the payload is read as FCM delivers it', () {
    test('the four fields the dispatcher sends', () {
      final payload = PushPayload.fromData(const {
        'notificationId': 'ntf-9',
        'event': 'interview_changed',
        'targetType': 'interview',
        'targetId': 'int-3',
      });

      expect(payload.notificationId, 'ntf-9');
      expect(payload.event, 'interview_changed');
      expect(payload.targetType, 'interview');
      expect(payload.targetId, 'int-3');
    });

    test('a target with no id is a target with no id, not "null"', () {
      // RemoteMessage.data is Map<String, dynamic> even though the wire is
      // string-to-string. A value stringified rather than dropped would send
      // somebody to /candidate/messages/null.
      final payload = PushPayload.fromData(const {
        'event': 'x',
        'targetType': 'conversation',
        'targetId': 42,
      });

      expect(payload.targetId, isNull);
      expect(
        notificationTargetDestination(
          targetType: payload.targetType,
          targetId: payload.targetId,
          role: AppRole.candidate,
        ),
        isNull,
      );
    });

    test('a push from a newer server still has an event to branch on', () {
      final payload = PushPayload.fromData(const {});

      expect(payload.event, '');
      expect(payload.targetType, isNull);
    });
  });

  group('a push and the row announcing it lead to the same place', () {
    // The regression this exists for: `notificationTargetDestination` was
    // split out of `notificationDestination` so a push could reach the table
    // without an AppNotification. Two copies would agree on the day they were
    // written and diverge on the next target type.
    test('for every target type and role the product has', () {
      const targetTypes = [
        'conversation',
        'application',
        'invitation',
        'interview',
        'vacancy',
        'employer',
        'user',
        'something_this_build_predates',
        null,
      ];

      for (final targetType in targetTypes) {
        for (final id in ['tgt-1', null]) {
          for (final role in [...AppRole.values, null]) {
            expect(
              notificationTargetDestination(
                targetType: targetType,
                targetId: id,
                role: role,
              ),
              notificationDestination(
                _notification(targetType: targetType, targetId: id),
                role,
              ),
              reason: 'targetType=$targetType id=$id role=$role',
            );
          }
        }
      }
    });

    test('and the table itself resolves to these paths', () {
      // The delegation check above cannot fail while one function calls the
      // other, which is the point at which a table test stops testing
      // anything. These pin the answers, so re-inlining the table - or
      // renaming a route - fails here rather than on a device.
      String? push(String? type, String? id, AppRole? role) =>
          notificationTargetDestination(
            targetType: type,
            targetId: id,
            role: role,
          );

      expect(
        push('conversation', 'cnv-1', AppRole.candidate),
        '/candidate/messages/cnv-1',
      );
      expect(
        push('conversation', 'cnv-1', AppRole.employer),
        '/employer/messages/cnv-1',
      );
      expect(
        push('application', 'app-1', AppRole.candidate),
        '/candidate/applications',
      );
      expect(
        push('vacancy', 'vac-1', AppRole.employer),
        '/employer/vacancies/vac-1',
      );
      expect(push('employer', null, AppRole.employer), '/employer/company');
      expect(push('user', 'usr-1', AppRole.admin), '/admin/users/usr-1');

      // BR-09 in the routing table: an administrator has no Messages tab, so
      // an admin reading a conversation notification is offered nothing rather
      // than a path that would redirect somewhere unrelated.
      expect(push('conversation', 'cnv-1', AppRole.admin), isNull);
      // An employer reaches applicants *through a vacancy* this notification
      // does not name, so guessing an id is a request the client will not make.
      expect(push('application', 'app-1', AppRole.employer), isNull);
      // A `user` target for a candidate is themselves; the notice is the whole
      // of it (BR-10).
      expect(push('user', 'usr-1', AppRole.candidate), isNull);
    });

    test('a candidate reading about a vacancy gets the pushed screen', () {
      // The one destination that is not a path: a candidate's vacancy detail is
      // pushed onto the navigator, so PushHost has to branch on this sentinel
      // exactly as the in-app row does.
      expect(
        notificationTargetDestination(
          targetType: 'vacancy',
          targetId: 'vac-1',
          role: AppRole.candidate,
        ),
        pushVacancyDestination,
      );
    });
  });

  group('registering this device', () {
    test('sends the token and the version the platform reports', () async {
      messaging.registrationToken = 'fcm-token-1';
      final container = containerWith();

      await container.read(pushRegistrationProvider.notifier).register();

      expect(repository.registered, [
        (token: 'fcm-token-1', appVersion: '1.11.0 (16)'),
      ]);
      expect(container.read(pushRegistrationProvider), 'fcm-token-1');
      // Read from the package manager rather than a Dart constant, so it
      // cannot drift from the pubspec version a release is numbered by.
      expect(
        platformCalls.map((c) => c.method),
        contains('appVersion'),
      );
    });

    test('registers even when the user refused the permission', () async {
      messaging
        ..registrationToken = 'fcm-token-1'
        ..permitted = false;
      final container = containerWith();

      await container.read(pushRegistrationProvider.notifier).register();

      // Permission decides whether a banner is *shown*. Somebody who turns
      // notifications on later in system settings must not have to sign out
      // and back in for push to start working.
      expect(messaging.permissionRequests, 1);
      expect(repository.registered, hasLength(1));
    });

    test('a device that cannot produce a token registers nothing', () async {
      // Every Huawei phone sold after 2019, and any device with no network at
      // first launch. Ordinary, not an error.
      final container = containerWith();

      await container.read(pushRegistrationProvider.notifier).register();

      expect(repository.registered, isEmpty);
      expect(container.read(pushRegistrationProvider), isNull);
    });

    test('a refused registration does not fail the sign-in', () async {
      messaging.registrationToken = 'fcm-token-1';
      repository.failure = const ApiException('nope');
      final container = containerWith();

      await expectLater(
        container.read(pushRegistrationProvider.notifier).register(),
        completes,
      );
      // Nothing was registered, so nothing is remembered as registered - a
      // later sign-out must not delete a row the server never had.
      expect(container.read(pushRegistrationProvider), isNull);
    });
  });

  group('a rotated token', () {
    test('is re-registered when this device was registered', () async {
      messaging.registrationToken = 'fcm-token-1';
      final container = containerWith();
      await container.read(pushRegistrationProvider.notifier).register();

      messaging.rotate('fcm-token-2');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registered.last.token, 'fcm-token-2');
      expect(container.read(pushRegistrationProvider), 'fcm-token-2');
      // The old token is deliberately not deleted: FCM answers UNREGISTERED
      // for it and the backend's dispatcher disables the row itself.
      expect(repository.unregistered, isEmpty);
    });

    test('is ignored when there is no session to register against', () async {
      containerWith().read(pushRegistrationProvider);

      messaging.rotate('fcm-token-2');
      await Future<void>.delayed(Duration.zero);

      // Would be a guaranteed 401. The next sign-in registers whatever the
      // token is by then.
      expect(repository.registered, isEmpty);
    });
  });

  group('signing out', () {
    test('deletes the row and forgets the token', () async {
      messaging.registrationToken = 'fcm-token-1';
      final container = containerWith();
      await container.read(pushRegistrationProvider.notifier).register();

      await container.read(pushRegistrationProvider.notifier).unregister();

      expect(repository.unregistered, ['fcm-token-1']);
      expect(container.read(pushRegistrationProvider), isNull);
    });

    test('with nothing registered, sends nothing', () async {
      final container = containerWith();

      await container.read(pushRegistrationProvider.notifier).unregister();

      expect(repository.unregistered, isEmpty);
    });

    test('forgets the token even when the delete fails', () async {
      messaging.registrationToken = 'fcm-token-1';
      final container = containerWith();
      await container.read(pushRegistrationProvider.notifier).register();
      repository.failure = const ApiException('offline');

      await container.read(pushRegistrationProvider.notifier).unregister();

      // The session is ending whatever the server says. A token this app still
      // believed it held would be re-sent by the next register as though the
      // sign-out had not happened.
      expect(container.read(pushRegistrationProvider), isNull);
    });
  });

  group('the session drives all of it', () {
    late List<String> log;
    late _FakeTokenStore tokens;

    ProviderContainer sessionContainer() {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          pushMessagingProvider.overrideWithValue(messaging),
          notificationRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(log: log),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    setUp(() {
      log = <String>[];
      tokens = _FakeTokenStore(log: log);
      repository.log = log;
    });

    test('a restored session registers the device exactly once', () async {
      messaging.registrationToken = 'fcm-token-1';
      // Reading the provider is the whole trigger: `build` kicks off `restore`
      // fire-and-forget, and `_adopt` starts the registration the same way -
      // a sign-in must not be able to fail on a notification token. Driving
      // `restore` a second time here would register twice and prove nothing.
      sessionContainer().read(sessionControllerProvider);
      await pumpEventQueue();

      expect(repository.registered, [
        (token: 'fcm-token-1', appVersion: '1.11.0 (16)'),
      ]);
    });

    test('sign-out unregisters before the credentials are cleared', () async {
      messaging.registrationToken = 'fcm-token-1';
      final container = sessionContainer()..read(sessionControllerProvider);
      await pumpEventQueue();
      log.clear();

      await container.read(sessionControllerProvider.notifier).signOut();

      // The ordering claim in SessionController's doc, as a test: the DELETE
      // needs the access token sign-out is about to discard, and revoking the
      // session may invalidate it too. A listener on the session state would
      // observe this after the fact and 401 every time.
      expect(log, ['unregister', 'logout', 'clear']);
      expect(repository.unregistered, ['fcm-token-1']);
    });
  });
}
