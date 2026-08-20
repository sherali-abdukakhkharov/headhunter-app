# headhunter-app

Flutter mobile app (**Android**) for the Headhunter job search and recruitment
platform. iOS is out of scope — see [CLAUDE.md](CLAUDE.md).

Companion backend: `headhunter-backend` — `d:\Dev\tgbots\headhunter-backend`.

## Download the latest APK

**[⬇ Download headhunter.apk](https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest/download/headhunter.apk)**

[![release-apk](https://github.com/sherali-abdukakhkharov/headhunter-app/actions/workflows/release-apk.yml/badge.svg)](https://github.com/sherali-abdukakhkharov/headhunter-app/actions/workflows/release-apk.yml)
[![latest release](https://img.shields.io/github/v/release/sherali-abdukakhkharov/headhunter-app?label=latest)](https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest)

That link always resolves to the newest release, so it never needs updating —
GitHub resolves `latest` on its side. Push a tag and a signed production APK is
built and attached:

```powershell
git tag v1.0.1
git push origin v1.0.1
```

Setup, signing and the BotFather step Telegram login needs are in
[docs/RELEASE.md](docs/RELEASE.md).

> Commands in this repository are **PowerShell** — this is a Windows project. Note
> that `&&` is a parser error in Windows PowerShell 5.1, `<` input redirection is
> unsupported, and line continuation is a backtick `` ` ``, not `\`. Use `;` or
> `if ($?)` to chain.

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

## Cutting a release

The version in `pubspec.yaml` is what the device reports — Gradle reads
`versionName` and `versionCode` from it — so **the tag is not the release**. Bump
the version and tag the merge commit on `main`:

```powershell
# 1. Bump version: and +buildNumber in pubspec.yaml, add a CHANGELOG.md entry
# 2. Merge to main, then from an updated main:
git tag -a v1.1.0 -m "1.1.0"
git push origin v1.1.0
```

The build number must increase every time. Android will not install an APK over
one with the same `versionCode`, so a release that reuses it cannot reach a
tester's phone as an update. [CHANGELOG.md](CHANGELOG.md) carries the rule and the
history.

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

```powershell
# Start the backend first - see ../headhunter-backend/README.md
flutter emulators --launch headhunter_pixel
flutter run --flavor development
```

**`--flavor` is required.** Once an Android project defines product flavors,
Gradle no longer has a plain `assembleDebug`, so a bare `flutter run` cannot
resolve a single APK.

The default API base URL is `http://10.0.2.2:3001` — the Android emulator's
alias for your host machine's loopback interface. `localhost` inside the
emulator refers to the emulator itself. For a physical device:

```powershell
flutter run --flavor development --dart-define=API_BASE_URL=http://<your-lan-ip>:3001
```

To wrap that across lines, the continuation character is a **backtick**, not `\`:

```powershell
flutter run --flavor development `
  --dart-define=API_BASE_URL=http://<your-lan-ip>:3001
```

## Flavors

Three build targets (§12.1). Each has its own application id, so all three
install **side by side** on one device — without that, installing one build
silently replaces another and takes its data.

| Flavor | Application id | Launcher name | Default API base URL |
|---|---|---|---|
| `development` | `com.headhunter.app.dev` | HeadHunter Dev | `http://10.0.2.2:3001` (host loopback) |
| `staging` | `com.headhunter.app.staging` | HeadHunter Staging | *(no environment yet — see below)* |
| `production` | `com.headhunter.app` | HeadHunter | `https://hh.qitmir.uz` (live) |

`staging`'s host does not exist, deliberately. There is one real backend today, and
pointing staging at it too would let a staging build write production data with
nothing to signal it — so a staging build reaches nothing until either a second
environment exists or someone passes `--dart-define=API_BASE_URL=…` on purpose.

```powershell
flutter run   --flavor development                                   # FLAVOR defaults to development
flutter build apk --flavor staging    --dart-define=FLAVOR=staging
flutter build apk --flavor production --dart-define=FLAVOR=production
```

Two things about that pairing:

- **`--flavor` selects the Gradle variant; `--dart-define=FLAVOR=` selects the
  Dart config.** They are separate mechanisms and must name the same flavor.
  `AppFlavor.current` defaults to `development`, so only development can omit
  the define — and the default is safe in the one direction that matters:
  forgetting it produces a build pointed at a *local* backend, never a
  development build wearing production's identity.
- **`staging` is §12.1's "testing" environment.** AGP rejects any product
  flavor whose name starts with `test`, so both sides say `staging`. See
  `AppFlavor` and MEMORY.md.

`--dart-define=API_BASE_URL=...` overrides the flavor's default. **No secrets go
through `--dart-define`** (§12.5) — the values are compiled in as plain strings
and recoverable from an APK with `strings`.

## Developer tools

Development and staging builds carry a tools screen at `/_dev`, reachable from
the button on the onboarding screen and from the floating button inside any role
shell. It offers:

- **sign-in scenarios** for every branch of the redirect chain — each role, both
  roles at once, no role yet, and blocked (BR-10) — because M1 has not shipped
  real auth yet;
- **the role switcher** (§2.3);
- **live interface-variant switching** across all four variants;
- links to the design catalogue (`/_design`) and the backend health probe
  (`/_health`).

Routes beginning `/_` are development surfaces: they sit outside the redirect
chain, are never linked from product UI, and are **not registered at all** in
the production flavor, so no deep link can reach them there.

## Commands

```powershell
flutter analyze                  # lint; must be clean before committing
flutter test                     # tests
dart run build_runner build      # regenerate *.g.dart
dart run build_runner watch      # continuous codegen while developing
flutter gen-l10n                 # regenerate localizations after editing an ARB
flutter build apk --debug --flavor development
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
