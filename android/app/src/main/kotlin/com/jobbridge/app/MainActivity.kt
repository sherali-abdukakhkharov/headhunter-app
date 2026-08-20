package com.jobbridge.app

import android.content.ActivityNotFoundException
import android.content.Intent
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
 * the Kotlin Gradle Plugin** — the build warning this project deliberately
 * emptied on 2026-08-19 by removing `telegram_login`, and one that future Flutter
 * versions will refuse outright. The app module's own Kotlin is not a plugin and
 * does not appear on that list, so the whole feature is the thirty lines below.
 *
 * `androidx.core` needs no Gradle entry: it is already on the app's compile
 * classpath at 1.15.0 through the Flutter embedding, which the last build's
 * manifest-merger report confirms.
 */
class MainActivity : FlutterActivity() {
    private companion object {
        /** Must match `AttachmentOpener.channelName`. */
        const val CHANNEL = "com.jobbridge.app/attachments"

        /**
         * The one cache subdirectory `res/xml/file_paths.xml` exposes.
         *
         * Kept as a constant here as well so the containment check below reads
         * against a literal rather than against whatever Dart happened to send.
         */
        const val ATTACHMENTS = "attachments"
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
