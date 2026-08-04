# Headhunter

Job search and recruitment platform. Two repositories, developed together.

| Repo | Path | Stack |
|---|---|---|
| `headhunter-app` (this repo) | `d:\Dev\tgbots\headhunter-app` | Flutter 3.44.8 / Dart 3.12.2, Riverpod 3, go_router, dio |
| `headhunter-backend` | `d:\Dev\tgbots\headhunter-backend` | NestJS 11, Kysely, PostgreSQL 18, SWC, Biome + ESLint |

The backend is reachable from a Claude Code session rooted here via
`permissions.additionalDirectories` in [.claude/settings.json](.claude/settings.json).
Open both at once in one editor window with
[headhunter.code-workspace](headhunter.code-workspace).

## Local ports

These are not the defaults, and the reason matters:

| Service | Port | Why not the default |
|---|---|---|
| Backend API | **3001** | The `sahih-bot` container permanently publishes host port 3000 |
| Postgres | **5435** | This machine already runs Postgres on 5432/5433/5434 for other projects |

## Running the whole thing

```sh
# 1. Backend (from d:\Dev\tgbots\headhunter-backend)
pnpm db:up              # Postgres 18 in Docker on 5435
pnpm migrate:latest     # apply migrations
pnpm start:dev          # API on http://localhost:3001

# 2. App (from this repo)
flutter emulators --launch headhunter_pixel
flutter run             # defaults to http://10.0.2.2:3001
```

`10.0.2.2` is the Android emulator's alias for the host loopback interface.
`localhost` inside the emulator means the emulator itself, so it will never
find the API. On a **physical device**, pass your machine's LAN IP:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:3001
```

## App commands

```sh
flutter analyze                     # lint (very_good_analysis + riverpod_lint)
flutter test                        # unit/widget tests
dart run build_runner build         # regenerate *.g.dart after editing providers/models
dart run build_runner watch         # continuous codegen while developing
flutter build apk --debug           # verify the Android toolchain end to end
```

## Structure

```
lib/
  main.dart                     ProviderScope + HeadhunterApp
  src/
    app.dart                    MaterialApp.router wiring
    core/
      config/app_config.dart    --dart-define config (API base URL, timeouts)
      network/dio_provider.dart the single Dio instance; add auth interceptor here
      network/api_exception.dart DioException -> user-presentable failure
      router/app_router.dart    go_router routes; add auth redirect here
      theme/app_theme.dart      Material 3 light/dark from one seed colour
    features/<feature>/
      data/                     repositories, API calls
      domain/                   models (json_serializable)
      presentation/             screens and widgets
    shared/widgets/             cross-feature widgets
```

Feature-first: a feature owns its data, domain and presentation. Only put
things in `core/` or `shared/` when a second feature actually needs them.

## Gotcha: Riverpod 3 retries failing providers by default

This one cost real debugging time, so do not undo it.

Riverpod 3 automatically retries a provider that throws, with exponential
backoff. While retrying, the provider's state is **`AsyncLoading` that merely
carries the error** — not `AsyncError`. Two consequences:

1. A UI that pattern-matches `AsyncLoading` before checking `hasError` shows an
   endless spinner instead of the failure.
2. The failing request is re-sent forever.

Both are handled deliberately:

- `main.dart` passes `retry: (retryCount, error) => null` to `ProviderScope`,
  making an error a terminal state the UI can render. Users retry explicitly via
  pull-to-refresh or the refresh button.
- `health_screen.dart` matches `AsyncValue(hasError: true, :final error?)`
  **first**, so a spinner can never mask a failure even if retry is re-enabled
  for some screen later.

If you ever want automatic backoff on a specific provider, return a `Duration`
from a per-provider `retry` rather than re-enabling it globally.

## Conventions

- **Errors never reach widgets raw.** Repositories catch `DioException` and
  throw `ApiException` (via `ApiException.fromDioException`). Screens render
  `AsyncValue` states and show `ApiException.message` directly.
- **Log with `debugPrint`, not `developer.log`.** `developer.log` writes only to
  the VM service, so it is invisible in `flutter run`, `flutter logs` and
  logcat — precisely where you look when a request misbehaves. The dio
  `LogInterceptor` uses `debugPrint` for this reason.
- **Providers are generated.** Annotate with `@riverpod` and run build_runner;
  do not hand-write provider boilerplate.
- **Generated files are committed** (`*.g.dart`), so CI needs no codegen step.
- Line length 80. `flutter analyze` must be clean before committing.

## Dependency pinning - read before upgrading

`pubspec.yaml` has load-bearing upper bounds. The chain:

```
flutter_test (Flutter 3.44.8) pins meta to exactly 1.18.0
  -> build_runner >=2.15.2 needs analyzer >=13.3 (needs meta ^1.18.3)  => capped <2.15.2
  -> which caps analyzer at 12.x
  -> so riverpod_generator must stay <4.0.6 (4.0.6+ needs analyzer ^13)
  -> so riverpod_annotation is 4.0.3 exactly (required by riverpod_generator 4.0.4)
  -> which holds flutter_riverpod at 3.3.2 rather than 3.4.2
  -> so riverpod_lint is pinned to 3.1.4 in analysis_options.yaml (not a caret)
```

Everything sits on **analyzer 12.1.0**. `flutter pub outdated` will show 18
packages "available" - they are genuinely incompatible, not neglected.
Revisit the whole block together when a Flutter release unpins `meta`.

**freezed is intentionally absent**: no stable release supports analyzer 12
(3.2.5 caps at <11; the analyzer-12 build is the 3.2.6-dev.1 prerelease). Add
it when a stable release lands and migrate models then.

## iOS

`ios/` is generated and the Dart code is fully cross-platform, but **iOS cannot
be built on Windows** - Xcode is macOS-only. Compile breakage is caught by the
`ios-build.yml` GitHub Actions workflow (macOS runner, `--no-codesign`, no
certificates needed). Producing a real `.ipa` needs a Mac and an Apple
Developer account.

## Backend contract

The app currently consumes one endpoint, `GET /health`:

```json
{ "status": "ok", "database": "up", "version": "0.0.1", "timestamp": "2026-08-04T06:33:46.530Z" }
```

`HealthStatus` in `lib/src/features/health/domain/health_status.dart` mirrors
`HealthResponseDto` in the backend. **Change both together.** Swagger is at
http://localhost:3001/docs and a Scalar reference at /reference.

The health screen is scaffolding that proves app -> API -> Postgres works. It
should be replaced by the first real feature, not built on.
