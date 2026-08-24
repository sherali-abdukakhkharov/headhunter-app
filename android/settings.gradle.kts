pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    // Reads app/google-services.json at build time and turns the entry matching
    // the id being built into resources the Firebase SDK reads at startup.
    //
    // **It fails the build when the applicationId has no entry** - "No matching
    // client found for package name" - which is the behaviour that matters
    // here: that mismatch is precisely what blocked push from 2026-08-19 until
    // now, and it used to surface at runtime as a token that never arrived.
    // A rename that outruns Firebase again is a red build instead.
    //
    // 4.5.0 rather than the more commonly cited 4.4.x: this project is on
    // AGP 9, and the plugin reaches into AGP's variant API.
    id("com.google.gms.google-services") version "4.5.0" apply false
}

include(":app")
