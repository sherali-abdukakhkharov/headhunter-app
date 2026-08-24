import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_platform.g.dart';

/// The two things push needs from Android that `firebase_messaging` does not
/// provide: a notification channel, and what this build calls itself.
///
/// ## Why this is a channel and not a plugin
///
/// The rule ARCHITECTURE.md §9 states for the attachment hand-off applies
/// unchanged. `flutter_local_notifications` is the usual way to create a
/// channel and it **applies the Kotlin Gradle Plugin** — the build warning this
/// project emptied on 2026-08-19 by removing `telegram_login`, and one future
/// Flutter versions will refuse outright. `package_info_plus` is the usual way
/// to read a version and does the same.
///
/// `firebase_core` and `firebase_messaging` were checked against that rule
/// before they were added and are clean: both are `com.android.library` with
/// Java sources. So the list stays empty, and the cost is the two methods
/// below in `MainActivity.kt`.
class PushPlatform {
  const PushPlatform({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  final MethodChannel _channel;

  /// Must match the name `MainActivity.kt` registers.
  static const channelName = 'com.jobbridge.app/push';

  /// Must match `default_notification_channel_id` in AndroidManifest.xml and
  /// `NOTIFICATION_CHANNEL` in `MainActivity.kt`.
  ///
  /// Not sent over the channel — the native side owns the id and this constant
  /// exists so a test can assert the three agree. A push naming a channel that
  /// does not exist lands in FCM's fallback channel, which is a silent
  /// downgrade to no banner rather than a failure anybody would notice.
  static const notificationChannelId = 'jobbridge_notifications';

  /// Creates — or renames — the channel FCM posts to (§9.2).
  ///
  /// [name] and [description] come from the active interface variant, because
  /// §2.4's four variants are chosen *inside the app* and Android string
  /// resources would follow the phone's locale instead. Creating a channel is
  /// idempotent and updates the name, so this runs at every launch and a
  /// language change is picked up on the next one — while importance, sound
  /// and vibration the user has since changed are left alone.
  ///
  /// Never throws. A device that cannot create a channel still receives
  /// notifications, through FCM's fallback channel and without a banner.
  Future<void> configureChannel({
    required String name,
    required String description,
  }) async {
    try {
      await _channel.invokeMethod<void>('configureChannel', {
        'name': name,
        'description': description,
      });
    } on PlatformException catch (e) {
      debugPrint('[push] notification channel not configured: ${e.message}');
    } on MissingPluginException {
      // A test, or a platform with no handler registered. Not a condition to
      // report: the caller asked for a nicety and the product works without it.
    }
  }

  /// `versionName (versionCode)`, for `POST /notifications/devices`.
  ///
  /// Read from the package manager rather than kept as a Dart constant so it
  /// cannot drift: Gradle derives both from `pubspec.yaml`, which is the one
  /// place a release is numbered. Null when the platform cannot say, which the
  /// wire allows — `appVersion` is optional, and a device that cannot name
  /// itself must still be able to register.
  Future<String?> appVersion() async {
    try {
      return await _channel.invokeMethod<String>('appVersion');
    } on PlatformException catch (e) {
      debugPrint('[push] app version unavailable: ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
PushPlatform pushPlatform(Ref ref) => const PushPlatform();
