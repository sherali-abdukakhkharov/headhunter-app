# JobBridge (`headhunter-app`)

Flutter mobile app (**Android**) for the JobBridge job search and recruitment
platform. iOS is out of scope — see [CLAUDE.md](CLAUDE.md).

The product was renamed from *Universal HeadHunter* to **JobBridge** on
2026-08-19, and the rename is deliberately partial: the launcher name, the
in-app title, the application id and the Dart package are JobBridge, while the
repository, the `headhunter-backend` companion and the `hh.qitmir.uz` API host
keep the old name because that is genuinely what they are called. CLAUDE.md has
the full list of what did and did not move.

Companion backend: `headhunter-backend` — `d:\Dev\tgbots\headhunter-backend`.

## Download the latest APK

**[⬇ Download jobbridge.apk](https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest/download/jobbridge.apk)**

[![release-apk](https://github.com/sherali-abdukakhkharov/headhunter-app/actions/workflows/release-apk.yml/badge.svg)](https://github.com/sherali-abdukakhkharov/headhunter-app/actions/workflows/release-apk.yml)
[![latest release](https://img.shields.io/github/v/release/sherali-abdukakhkharov/headhunter-app?label=latest)](https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest)

That link always resolves to the newest release, so it never needs updating —
GitHub resolves `latest` on its side. Push a tag and a signed production APK is
built and attached:

```powershell
git tag v1.0.1
git push origin v1.0.1
```

Up to and including **v1.1.0** the asset was called `headhunter.apk`. Releases
after the rename carry both names — the same bytes — so a link shared earlier
keeps working; the alias will be dropped once nothing points at it. Prefer
`jobbridge.apk`.

**Installing over an older build.** The application id changed with the rename
(`com.headhunter.app` → `com.jobbridge.app`), so Android treats the new APK as a
different app: it installs *beside* an older one rather than updating it, and
the old icon keeps its own data. Uninstall the pre-rename build to avoid two
launcher entries. Nothing was ever published to a store under the old id, which
is the only reason a rename was possible at all.

Setup and signing are in [docs/RELEASE.md](docs/RELEASE.md).

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
| App id | `com.jobbridge.app` (Android `applicationId`; `.dev` / `.staging` per flavor) |

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
| `development` | `com.jobbridge.app.dev` | JobBridge Dev | `http://10.0.2.2:3001` (host loopback) |
| `staging` | `com.jobbridge.app.staging` | JobBridge Staging | *(no environment yet — see below)* |
| `production` | `com.jobbridge.app` | JobBridge | `https://hh.qitmir.uz` (live) |

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
  roles at once, no role yet, and blocked (BR-10). Real phone + OTP sign-in has
  shipped; these stay because a blocked account and a role-less one are states
  the redirect chain has to handle and neither is reachable by typing a code;
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

- **Release signing** is configured: `android/app/build.gradle.kts` reads
  `android/key.properties` when it exists — which is what CI writes from the
  repository secrets — and falls back to the debug key with a loud warning so a
  fresh clone can still run `flutter run --release`. A debug-signed release APK
  installs but cannot be *updated* by a properly signed one; Android refuses a
  signature change. [docs/RELEASE.md](docs/RELEASE.md) has the keystore steps.
- **The launcher icon and launch screen** are the designer's, as of 2026-08-20 —
  a vector adaptive icon plus a navy launch window. One thing is still
  unverified: a vector launcher icon on **API 24/25**, which is the one path no
  modern launcher exercises. See TODO.md.
- **iOS** requires a Mac and is out of scope; `ios-build.yml` is
  `workflow_dispatch`-only and nothing catches iOS breakage on push.

## Docs

`CLAUDE.md` covers the layout, conventions, the cross-repo setup, local ports,
and the dependency pinning constraints — read it before upgrading packages.
