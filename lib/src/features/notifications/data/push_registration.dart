import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_messaging.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_platform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_registration.g.dart';

/// Which device token the server currently knows about, or null.
///
/// ## The session drives this, and not the other way round
///
/// `SessionController` calls [register] once a session is adopted and
/// [unregister] before it clears the tokens. It reads like an inversion — a
/// listener on the session state would be the obvious shape — and there are
/// two reasons it is not one:
///
/// - **Ordering.** `DELETE /notifications/devices/:token` needs the access
///   token that is about to be thrown away. A listener would observe the
///   sign-out *after* the credentials were gone and get a 401 every time.
/// - **Cycles.** `SessionController` would then read this while this watched
///   `SessionController`, which Riverpod refuses outright.
///
/// So this provider knows nothing about sessions. It is told.
///
/// ## Nothing here is allowed to fail loudly
///
/// Every path swallows its failure and logs. A device that cannot register is
/// a device that does not receive push, and §9.2's in-app centre is the record
/// either way — a sign-in that failed because a notification token could not be
/// stored would be trading the product for a copy of it.
@Riverpod(keepAlive: true)
class PushRegistration extends _$PushRegistration {
  /// True once the provider has been torn down, so an in-flight registration
  /// cannot touch `ref` afterwards.
  ///
  /// The same guard `SessionController` carries, for the same reason: this is
  /// started with `unawaited` from a sign-in, so a scope disposed while a token
  /// request is outstanding surfaces as an unrelated test failing with a
  /// Riverpod error.
  var _disposed = false;

  @override
  String? build() {
    ref.onDispose(() => _disposed = true);

    // FCM rotates a token on reinstall, on a restore to a new device, and
    // periodically of its own accord. The server has no other way to learn the
    // new one, so re-registering is the app's job.
    final refreshes = ref
        .watch(pushMessagingProvider)
        .tokenRefreshes()
        .listen(_onTokenRotated);
    ref.onDispose(refreshes.cancel);

    return null;
  }

  /// Registers this installation for push (§9.2).
  ///
  /// Called after a session is adopted — at sign-in and at every cold start
  /// that restores one — because the server's row carries `last_seen_at` and
  /// because a token that rotated while the app was closed is not announced.
  /// The route is idempotent, so repeating it costs one request.
  ///
  /// **Registration does not depend on the permission answer.** Notifications
  /// may be turned on later in system settings, and a user who does that
  /// should not have to sign out and back in for push to start working. The
  /// permission is asked for because it decides whether a banner is *shown*;
  /// it does not decide whether the device is addressable.
  Future<void> register() async {
    final messaging = ref.read(pushMessagingProvider);

    // Asked here rather than at first launch: this is the point where somebody
    // has committed to the product, so the dialog has a reason a user can see.
    // Android shows it once and answers from the stored decision afterwards,
    // so repeating this at every launch is not a repeated prompt.
    await messaging.requestPermission();
    if (_disposed) return;

    final token = await messaging.token();
    if (_disposed || token == null) return;

    final appVersion = await ref.read(pushPlatformProvider).appVersion();
    if (_disposed) return;

    try {
      await ref
          .read(notificationRepositoryProvider)
          .registerDevice(token: token, appVersion: appVersion);
      if (_disposed) return;
      state = token;
    } on ApiException catch (e) {
      debugPrint('[push] device not registered: ${e.message}');
    }
  }

  /// Stops push to this device, at the user's request.
  ///
  /// Called by `SessionController.signOut` **before** the tokens are cleared.
  /// A session that ends any other way — expiry, a refused refresh — cannot
  /// reach the endpoint, and leaves the row: the next person to sign in on the
  /// phone re-registers the same token, which moves it to them.
  ///
  /// Local state is dropped before the request rather than after. The session
  /// is ending whatever the server says, and a token this app still believed
  /// it held would be re-sent by the next [register] as though nothing had
  /// happened.
  Future<void> unregister() async {
    final token = state;
    if (token == null) return;
    state = null;

    try {
      await ref.read(notificationRepositoryProvider).unregisterDevice(token);
    } on ApiException catch (e) {
      debugPrint('[push] device not unregistered: ${e.message}');
    }
  }

  /// FCM replaced the token.
  ///
  /// Only re-registers when this device was registered to begin with —
  /// otherwise there is no session and the request would be a guaranteed 401.
  ///
  /// The **old** token is deliberately not deleted. A rotated token is one FCM
  /// itself will answer `UNREGISTERED` for, and the backend's dispatcher
  /// disables such a row the first time it tries it. Racing that with a delete
  /// would only add a request that can fail.
  Future<void> _onTokenRotated(String token) async {
    if (state == null || state == token) return;

    final appVersion = await ref.read(pushPlatformProvider).appVersion();
    if (_disposed) return;

    try {
      await ref
          .read(notificationRepositoryProvider)
          .registerDevice(token: token, appVersion: appVersion);
      if (_disposed) return;
      state = token;
    } on ApiException catch (e) {
      debugPrint('[push] rotated token not registered: ${e.message}');
    }
  }
}
