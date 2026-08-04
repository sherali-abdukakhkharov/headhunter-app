# headhunter-app

Flutter mobile app (Android + iOS) for the Headhunter job search and
recruitment platform.

Companion backend: `headhunter-backend` — `d:\Dev\tgbots\headhunter-backend`.

## Stack

| Concern | Choice |
|---|---|
| SDK | Flutter 3.44.8 (stable), Dart 3.12.2 |
| State / DI | Riverpod 3 with `@riverpod` codegen |
| Navigation | go_router 17 |
| HTTP | dio 5 |
| Models | json_serializable |
| Lints | very_good_analysis + riverpod_lint |
| App id | `com.headhunter.app` (Android `applicationId`, iOS bundle id) |

## Prerequisites

Already installed on this machine:

- Flutter SDK at `D:\Dev\sdk\flutter` (on `PATH`)
- Android SDK at `%LOCALAPPDATA%\Android\Sdk` (`ANDROID_HOME` set): platform 36,
  build-tools 36.0.0, platform-tools, emulator
- Android Studio at `C:\Program Files\Android\Android Studio` — its bundled JBR
  is the JDK Flutter builds with
- AVD `headhunter_pixel` (Pixel 8, Android 36, Play Store image); WHPX
  acceleration verified

Verify any time with `flutter doctor -v`. Expected non-issues on Windows: Xcode
(macOS-only) and Visual Studio (the Windows desktop target is disabled).

## Run

```sh
# Start the backend first - see ../headhunter-backend/README.md
flutter emulators --launch headhunter_pixel
flutter run
```

The default API base URL is `http://10.0.2.2:3001` — the Android emulator's
alias for your host machine's loopback interface. `localhost` inside the
emulator refers to the emulator itself. For a physical device:

```sh
flutter run --dart-define=API_BASE_URL=http://<your-lan-ip>:3001
```

## Commands

```sh
flutter analyze                  # lint; must be clean before committing
flutter test                     # tests
dart run build_runner build      # regenerate *.g.dart
dart run build_runner watch      # continuous codegen while developing
flutter build apk --debug        # debug APK
```

## Before shipping

- **Release signing.** `android/app/build.gradle.kts` signs release builds with
  the debug keystore so `flutter run --release` works out of the box. Create a
  real keystore and signing config before any store upload.
- **App icons and launch screen** are still Flutter's defaults.
- **iOS** requires a Mac; CI compiles it with `--no-codesign` as a check.

## Docs

`CLAUDE.md` covers the layout, conventions, the cross-repo setup, local ports,
and the dependency pinning constraints — read it before upgrading packages.
