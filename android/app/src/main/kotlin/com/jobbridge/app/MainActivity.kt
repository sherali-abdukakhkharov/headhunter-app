package com.jobbridge.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * The app's only native code, and it exists to avoid a plugin.
 *
 * Handing a downloaded file to the OS needs `FileProvider` and an intent, and
 * every pub package that wraps them is written in Kotlin and therefore **applies
 * the Kotlin Gradle Plugin** — the build warning future Flutter versions will
 * refuse outright. The app module's own Kotlin is not a plugin and does not
 * appear on that list, so the whole feature is the thirty lines below.
 *
 * **The list is not empty and never was.** `file_picker` has been on it since
 * 2026-08-07 and CI still prints its name; removing `telegram_login` on
 * 2026-08-19 took it from two entries to one. The rule is therefore "do not
 * make it longer", not "keep it at zero".
 *
 * `androidx.core` needs no Gradle entry: it is already on the app's compile
 * classpath at 1.15.0 through the Flutter embedding, which the last build's
 * manifest-merger report confirms.
 */
class MainActivity : FlutterActivity() {
    private companion object {
        /** Must match `AttachmentOpener.channelName`. */
        const val CHANNEL = "com.jobbridge.app/attachments"

        /** Must match `PushPlatform.channelName`. */
        const val PUSH_CHANNEL = "com.jobbridge.app/push"

        /**
         * The one cache subdirectory `res/xml/file_paths.xml` exposes.
         *
         * Kept as a constant here as well so the containment check below reads
         * against a literal rather than against whatever Dart happened to send.
         */
        const val ATTACHMENTS = "attachments"

        /**
         * Must match `default_notification_channel_id` in AndroidManifest.xml
         * and `PushPlatform.notificationChannelId`. Three places for one string
         * because the two ends are different languages and the manifest is a
         * third - the Dart constant is the one a test can reach.
         */
        const val NOTIFICATION_CHANNEL = "jobbridge_notifications"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "open" -> open(call, result)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PUSH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "configureChannel" -> configureChannel(call, result)
                    "appVersion" -> result.success(appVersion())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Creates - or renames - the notification channel FCM posts to (§9.2).
     *
     * *Why here and not a plugin.* The same rule the attachment hand-off
     * follows: `flutter_local_notifications` is the usual answer and it applies
     * the Kotlin Gradle Plugin. `firebase_messaging` itself does **not** - it is
     * a `com.android.library` with Java sources - so the whole cost of not
     * lengthening that list is the dozen lines below.
     *
     * *Why the name comes from Dart.* §2.4's four interface variants are chosen
     * inside the app, not by the phone's locale, so Android string resources
     * would show a Russian phone the Russian name to somebody reading Uzbek
     * Cyrillic. Dart knows which variant is active and passes it here.
     *
     * *Why calling it repeatedly is correct.* `createNotificationChannel` on an
     * existing id updates the name and description and leaves everything the
     * user has since changed - importance, sound, vibration - alone. So this
     * runs on every launch and a language change is picked up on the next one,
     * while a user who turned the sound off keeps it off.
     */
    private fun configureChannel(call: MethodCall, result: MethodChannel.Result) {
        // Channels arrived in Android 8. Below it importance is a property of
        // each notification and there is nothing to create, so reporting success
        // is honest: the caller asked for a working channel and got one.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(null)
            return
        }

        val name = call.argument<String>("name")
        if (name == null) {
            result.error("bad_argument", "name is required", null)
            return
        }

        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL,
            name,
            // HIGH, because the backend sends `priority: HIGH` for things a
            // person is waiting on - an interview time, a hire - and DEFAULT
            // makes a sound without ever showing a banner. The channel is the
            // ceiling: a payload cannot exceed what the channel allows.
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = call.argument<String>("description")
        }

        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
        result.success(null)
    }

    /**
     * What this build calls itself, for `POST /notifications/devices`.
     *
     * Read from the package manager rather than kept as a Dart constant, so it
     * cannot drift: Gradle derives `versionName`/`versionCode` from
     * `pubspec.yaml`, which is the one place a release is numbered.
     *
     * Trimmed to the DTO's 40 characters here rather than letting the server
     * reject the registration - a device that cannot register because its
     * version string is long would lose push for a reason nobody would guess.
     */
    private fun appVersion(): String? = try {
        val info = packageManager.getPackageInfo(packageName, 0)
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        "${info.versionName} ($code)".take(40)
    } catch (e: Exception) {
        // Optional on the wire. A device that cannot name itself still registers.
        null
    }

    private fun open(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("bad_argument", "path is required", null)
            return
        }

        val file = File(path)

        // Defence in depth. `FileProvider.getUriForFile` already refuses a path
        // outside the roots declared in file_paths.xml, so this check is a second
        // lock on the same door - and worth having, because the door leads to an
        // app-private directory that also holds the secure token store. A channel
        // that could be talked into sharing an arbitrary path would be the one way
        // this app hands out a file nobody was entitled to.
        val root = File(cacheDir, ATTACHMENTS).canonicalPath + File.separator
        if (!file.canonicalPath.startsWith(root)) {
            result.error("bad_argument", "path is outside the attachment cache", null)
            return
        }

        if (!file.isFile) {
            result.error("bad_argument", "no such file", null)
            return
        }

        // `${applicationId}.fileprovider`, resolved at runtime rather than
        // hard-coded: the three flavors have three application ids, and two apps
        // declaring the same provider authority cannot both be installed - which
        // would break the side-by-side installs §12.1 exists to give us.
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, call.argument<String>("mimeType") ?: "*/*")
            // Read only, and scoped to the activity we are starting. Never
            // FLAG_GRANT_WRITE_URI_PERMISSION: a viewer has no business editing a
            // candidate's CV.
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        try {
            startActivity(intent)
            result.success(null)
        } catch (e: ActivityNotFoundException) {
            // A real state on a bare device rather than a failure: the bytes
            // arrived and there is simply nothing installed that reads them. Dart
            // turns this code into its own exception type so the message does not
            // send anybody looking for a network problem.
            result.error("no_viewer", "No installed app can open this file.", null)
        }
    }
}
