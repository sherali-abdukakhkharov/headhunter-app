plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.headhunter.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.headhunter.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
            manifestPlaceholders["appName"] = "HeadHunter Dev"
        }
        // §12.1 calls this environment "testing". It is named `staging` because
        // AGP rejects any flavor name starting with `test` - it would collide
        // with the `test` and `androidTest` source sets. AppFlavor.staging
        // carries the same note; the two names must not diverge.
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            manifestPlaceholders["appName"] = "HeadHunter Staging"
        }
        create("production") {
            dimension = "env"
            // No suffix: this is the id the store record is bound to. Changing
            // it after the first upload orphans every installed copy.
            manifestPlaceholders["appName"] = "HeadHunter"
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
