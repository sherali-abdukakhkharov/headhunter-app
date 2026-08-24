import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_messaging.g.dart';

/// The `data` block of one push, as `PushDispatcher.messageFor` sends it.
///
/// **String-to-string**, because that is all FCM's payload carries. The client
/// branches on these rather than on the sentence — which is also why the deep
/// link is not baked into the text, and why a push and its in-app row lead to
/// the same place through the one table in `notifications_screen.dart`.
@immutable
class PushPayload {
  const PushPayload({
    required this.event,
    this.notificationId,
    this.targetType,
    this.targetId,
  });

  /// Reads the map FCM delivers.
  ///
  /// Typed as `Map<String, dynamic>` because that is what `RemoteMessage.data`
  /// is declared as, even though every value is a string on the wire. Anything
  /// that is not a string is dropped rather than stringified: a value this
  /// build cannot read is a contract change, and `"null"` as a target id would
  /// send somebody to a 404 instead of nowhere.
  factory PushPayload.fromData(Map<String, dynamic> data) {
    String? read(String key) =>
        data[key] is String ? data[key] as String : null;

    return PushPayload(
      event: read('event') ?? '',
      notificationId: read('notificationId'),
      targetType: read('targetType'),
      targetId: read('targetId'),
    );
  }

  /// A stable §9.2 event code. Kept as a string for the same reason
  /// `AppNotification.event` is: the catalogue grows server-side.
  final String event;

  /// The row this push is a copy of. Used to mark it read when the tap is what
  /// opened it, so the badge does not still count something the user has just
  /// been looking at.
  final String? notificationId;

  /// `vacancy`, `application`, `conversation`, … or null where the event is
  /// about nothing addressable.
  final String? targetType;
  final String? targetId;
}

/// What the app needs from the push provider, and nothing else.
///
/// An interface rather than a direct dependency on `firebase_messaging`, for
/// the reason the backend's `PushSender` is one: the product has to be
/// testable without a Firebase project, and a widget test cannot initialise
/// one. Every implementation here is allowed to do nothing — see
/// [DisabledPushMessaging].
abstract class PushMessaging {
  /// Asks for permission to show notifications.
  ///
  /// Android 13+ shows the system dialog; below it the permission is granted
  /// by installing and this answers true without any UI. Returns whether
  /// notifications may be *displayed* — a false answer does not stop
  /// registration, because the record still arrives and the user may turn
  /// notifications on in system settings later without signing in again.
  Future<bool> requestPermission();

  /// This installation's FCM registration token, or null when the device
  /// cannot produce one — no Play services, no network at first launch, a
  /// Firebase project this build does not match.
  Future<String?> token();

  /// Emits when FCM rotates the token. Re-registration is the app's job; the
  /// server has no other way to learn the new one.
  Stream<String> tokenRefreshes();

  /// A notification the user tapped while the app was running or backgrounded.
  Stream<PushPayload> opened();

  /// The notification whose tap *launched* the app, if that is what happened.
  ///
  /// Separate from [opened] because the app was not alive to receive it: the
  /// tap is delivered once, as launch state, and asking twice yields null.
  Future<PushPayload?> initialMessage();

  /// A push that arrived while the app was open.
  ///
  /// Android does not display these — the app is already in front — so the
  /// value is the badge: §9.2's count is refreshed rather than left stale
  /// until something else invalidates it.
  Stream<PushPayload> foregroundMessages();
}

/// Push, over Firebase Cloud Messaging.
///
/// ## Initialisation is lazy, and failing it is not fatal
///
/// `Firebase.initializeApp()` runs on first use and its result is cached,
/// including the failure. Nothing above `main()` has to await it, and a device
/// that cannot initialise Firebase — no Play services, which is every Huawei
/// phone sold after 2019 — runs the whole product with this class answering
/// null and empty. §9.2's in-app centre is the record; push is a copy.
///
/// The one failure that *cannot* reach here any more is a
/// `google-services.json` with no entry for the running application id: since
/// 2026-08-24 the `com.google.gms.google-services` Gradle plugin fails the
/// build on it. That mismatch is what blocked push from the rename until then,
/// and it used to present as a token that simply never arrived.
class FirebasePushMessaging implements PushMessaging {
  Future<FirebaseMessaging?>? _pending;

  /// The messaging instance, or null if Firebase is unavailable on this device.
  ///
  /// Cached as the *future* rather than its value, so concurrent callers at
  /// startup share one initialisation instead of racing three.
  Future<FirebaseMessaging?> _messaging() => _pending ??= _initialize();

  Future<FirebaseMessaging?> _initialize() async {
    try {
      // No options and no generated firebase_options.dart: on Android the SDK
      // reads the resources the Gradle plugin produced from
      // android/app/google-services.json, which is the only place this app is
      // identified. A second source would be a second thing to keep in step.
      await Firebase.initializeApp();
      return FirebaseMessaging.instance;
    } on Object catch (error) {
      // Deliberately Object: this must survive anything, including a
      // MissingPluginException in a test binding, and the remedy is the same
      // for all of them — no push, everything else unchanged.
      debugPrint('[push] Firebase unavailable, push is off: $error');
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    final messaging = await _messaging();
    if (messaging == null) return false;

    try {
      final settings = await messaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } on Object catch (error) {
      debugPrint('[push] permission request failed: $error');
      return false;
    }
  }

  @override
  Future<String?> token() async {
    final messaging = await _messaging();
    if (messaging == null) return null;

    try {
      return await messaging.getToken();
    } on Object catch (error) {
      // Ordinary on a device with no Play services, and on any device with no
      // network at first launch. A token that cannot be obtained now may be
      // obtainable at the next sign-in, so nothing is recorded as broken.
      debugPrint('[push] no registration token: $error');
      return null;
    }
  }

  @override
  Stream<String> tokenRefreshes() async* {
    final messaging = await _messaging();
    if (messaging == null) return;
    yield* messaging.onTokenRefresh;
  }

  @override
  Stream<PushPayload> opened() async* {
    if (await _messaging() == null) return;
    yield* FirebaseMessaging.onMessageOpenedApp.map(
      (message) => PushPayload.fromData(message.data),
    );
  }

  @override
  Future<PushPayload?> initialMessage() async {
    final messaging = await _messaging();
    if (messaging == null) return null;

    try {
      final message = await messaging.getInitialMessage();
      return message == null ? null : PushPayload.fromData(message.data);
    } on Object catch (error) {
      debugPrint('[push] initial message unavailable: $error');
      return null;
    }
  }

  @override
  Stream<PushPayload> foregroundMessages() async* {
    if (await _messaging() == null) return;
    yield* FirebaseMessaging.onMessage.map(
      (message) => PushPayload.fromData(message.data),
    );
  }
}

/// Push that does nothing, for a build or a test with no provider.
///
/// The counterpart of the backend's `NoopPushSender`, and it exists for the
/// same reason: everything §9.2 shows has to keep working when push does not,
/// so "no push" must be a supported configuration rather than an outage.
class DisabledPushMessaging implements PushMessaging {
  const DisabledPushMessaging();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> tokenRefreshes() => const Stream.empty();

  @override
  Stream<PushPayload> opened() => const Stream.empty();

  @override
  Future<PushPayload?> initialMessage() async => null;

  @override
  Stream<PushPayload> foregroundMessages() => const Stream.empty();
}

@Riverpod(keepAlive: true)
PushMessaging pushMessaging(Ref ref) => FirebasePushMessaging();
