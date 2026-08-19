import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing, loaded from android/key.properties when that file exists.
//
// One code path for laptops and for CI: the release workflow writes the same
// key.properties and decodes the keystore from a repo secret, so nothing special
// happens on either side. Neither the keystore nor this file is ever committed -
// android/.gitignore covers `key.properties` and `**/*.jks`.
//
// When it is absent (a fresh clone, or anyone building debug) the release build
// falls back to debug signing so `flutter run --release` still works. That
// fallback is deliberately loud in the build log, because a release APK signed
// with a debug key has a different SHA-256 - and Telegram login only works for a
// fingerprint registered with BotFather, so a silently debug-signed release APK
// would install fine and then fail to log anyone in.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.containsKey("storeFile")

android {
    namespace = "com.jobbridge.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.jobbridge.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING: no android/key.properties - signing this RELEASE " +
                    "build with the DEBUG key. It will install, but Telegram " +
                    "login will fail: the fingerprint is not the one registered " +
                    "with BotFather. See docs/RELEASE.md."
                )
                signingConfigs.getByName("debug")
            }
        }
    }

    // The three build targets of §12.1. Each gets its own application id, so
    // development, testing and production install side by side on one device -
    // without the suffix, installing the production build silently replaces the
    // one a tester was working with, and takes its data with it.
    //
    // The Dart side of this pairing is AppFlavor in
    // lib/src/core/config/app_flavor.dart, and the two must agree: Gradle owns
    // the id and the launcher label, Dart owns the API base URL. A test asserts
    // the suffixes match, because a drift here is invisible until a device ends
    // up with two builds claiming the same id.
    //
    // The label goes through a manifestPlaceholder rather than resValue: AGP 9
    // ships with buildFeatures.resValues *disabled*, so a resValue here fails
    // configuration outright with "contains custom resource values, but the
    // feature is disabled". A placeholder needs no feature flag, and the
    // launcher name is deliberately never localized anyway (§2.4).
    flavorDimensions += "env"

    productFlavors {
        create("development") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "JobBridge Dev"
        }
        // §12.1 calls this environment "testing". It is named `staging` because
        // AGP rejects any flavor name starting with `test` - it would collide
        // with the `test` and `androidTest` source sets. AppFlavor.staging
        // carries the same note; the two names must not diverge.
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            manifestPlaceholders["appName"] = "JobBridge Staging"
        }
        create("production") {
            dimension = "env"
            // No suffix: this is the id the store record is bound to. Changing
            // it after the first upload orphans every installed copy.
            manifestPlaceholders["appName"] = "JobBridge"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
