# Universal HeadHunter

Mobile-only recruitment platform for Uzbekistan. Two repositories, developed
together.

| Repo | Path | Stack |
|---|---|---|
| `headhunter-app` (this repo) | `d:\Dev\tgbots\headhunter-app` | Flutter 3.44.8 / Dart 3.12.2, Riverpod 3, go_router, dio |
| `headhunter-backend` | `d:\Dev\tgbots\headhunter-backend` | NestJS 11, Kysely, PostgreSQL 18, SWC, Biome + ESLint |

The backend is reachable from a Claude Code session rooted here via
`permissions.additionalDirectories` in [.claude/settings.json](.claude/settings.json).
Open both at once in one editor window with
[headhunter.code-workspace](headhunter.code-workspace).

## Which document to read

| File | Contents |
|---|---|
| [docs/SPEC.md](docs/SPEC.md) | The client specification. **Cite it** as §n, BR-nn, UAT-nn. |
| [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md) | MVP sign-in is **Log in with Telegram**, not OTP. Read before touching auth. |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Design decisions: role shell, localization, forms, offline. Read before adding a feature. |
| [PLAN.md](PLAN.md) | Milestones in dependency order, mapped to BR/UAT. |
| [TODO.md](TODO.md) | Working checklist and what is blocked on whom. |
| [MEMORY.md](MEMORY.md) | Why decisions were made; traps already paid for. |
| [README.md](README.md) | Prerequisites, commands, run instructions. |

Before implementing anything from the spec, check ARCHITECTURE.md - several
requirements have already been designed against, and the reasoning is not
re-derivable from the spec text.

## The design system

The client's design is implemented under [lib/src/core/design/](lib/src/core/design/) —
import the `design.dart` barrel and build screens from the `Hh*` components. Do
not hand-roll a `Container` where a component exists, and do not introduce a
colour, radius or elevation that is not a token.

Three rules the components encode:

- **One control size for everyone** — every control is 52px with a persistent
  label. There is no dense/simple mode; only the *fields* differ by work category.
- **Status is never colour alone** — always `HhBadge` (icon + word), for vacancy,
  application, verification, invitation and complaint state alike.
- **One elevation level.** `HhElevation.card` or `HhElevation.sheet`, nothing else.

`/_design` renders the whole catalogue; reach it from the debug-only action in the
health screen's app bar. **After changing anything in the design system, run the
gallery on a device** — see MEMORY.md for three bugs that a green `flutter analyze`
and a green test suite both missed.

## Domain rules that are easy to get wrong

- **Four interface variants, three languages.** Uzbek ships in Latin *and*
  Cyrillic. Never key on `locale.languageCode` alone - it collapses the two.
- **Pickers display labels but bind dictionary IDs** (BR-13, §3.3). Binding a
  label breaks cross-language search, and it fails silently.
- **Structured profile fields are what search uses**; the CV is an attachment.
  There is no CV parsing in this product (§1, §5.4).
- **Three roles in one app, switchable at runtime** (§2.3), and **admin is one of
  them** (§10) - there is no web admin panel, ever (§2.4).
- **Forms are schema-driven** because the field set depends on work category and
  admins add categories at runtime (§5.2, §6.3, §10.3).
- **Never show a candidate's phone on a search card** (BR-09, §11.1).
- **Sign-in is phone + OTP** (§4.1, UAT-01), which satisfies BR-01 by
  construction: verifying the code is what makes the number verified. Telegram
  login was tried and **deprecated 2026-08-05** — the code is kept and still
  works, but nothing calls it ([docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md)).
- **There is no SMS provider yet.** The backend issues a fixed code set by
  `OTP_STATIC_CODE` (currently `666666`), substituted at the point a random code
  would be generated and nowhere else — so TTL, resend delay, attempt limits and
  single-use consumption all still apply. **Removing the backdoor is clearing one
  environment variable**; do not add a second code path that would have to be
  removed with it. Refused at boot when `NODE_ENV=production`.
- **Idempotency keys are persisted, not regenerated per attempt** (§12.4, BR-07).
- **User-entered content is never translated** (§2.4).

## Local ports

These are not the defaults, and the reason matters:

| Service | Port | Why not the default |
|---|---|---|
| Backend API | **3001** | The `sahih-bot` container permanently publishes host port 3000 |
| Postgres | **5435** | This machine already runs Postgres on 5432/5433/5434 for other projects |

## Running the whole thing

**This is a Windows project and every command here is PowerShell.** Three bash
habits break in Windows PowerShell 5.1: `&&` is a **parser error** (use `;` or
`if ($?)`), `<` input redirection is **unsupported** (pipe instead), and line
continuation is a backtick `` ` ``, not `\`. `base64`, `rm`, `cat`, `which` and
`head` are not commands. The bash inside `.github/workflows/` is correct as bash —
that runs on Linux runners.

```powershell
# 1. Backend (from d:\Dev\tgbots\headhunter-backend)
pnpm db:up              # Postgres 18 in Docker on 5435
pnpm migrate:latest     # apply migrations
pnpm start:dev          # API on http://localhost:3001

# 2. App (from this repo)
flutter emulators --launch headhunter_pixel
flutter run --flavor development    # defaults to http://10.0.2.2:3001
```

**`--flavor` is required.** With product flavors defined there is no plain
`assembleDebug`, so a bare `flutter run` cannot resolve one APK.

`10.0.2.2` is the Android emulator's alias for the host loopback interface.
`localhost` inside the emulator means the emulator itself, so it will never
find the API. On a **physical device**, pass your machine's LAN IP:

```powershell
flutter run --flavor development `
  --dart-define=API_BASE_URL=http://192.168.1.42:3001
```

## Flavors

Three targets (§12.1), each with its own application id so all three install side
by side: `development` (`.dev`), `staging` (`.staging`), `production` (no suffix).

`--flavor` picks the **Gradle** variant and `--dart-define=FLAVOR=` picks the
**Dart** config - separate mechanisms that must name the same flavor.
`AppFlavor.current` defaults to `development`, so only that one may omit the
define.

**`staging` is §12.1's "testing" environment.** AGP rejects any product flavor
whose name starts with `test`, so both sides say `staging`. Two more Android
flavor traps are recorded in MEMORY.md - read them before touching
`android/app/build.gradle.kts`.

Gate anything that must not ship on `AppFlavor.current.allowsDevelopmentTools`,
**not `kDebugMode`**: a release build of the development flavor is what gets
demonstrated to the client, and a profile build of production is still production.

## Routes

Paths are constants in [lib/src/core/router/routes.dart](lib/src/core/router/routes.dart) —
never inline a path string. Two rules the router depends on:

- **A shell route begins with its role's `AppRole.pathPrefix`** (`/candidate`,
  `/employer`, `/admin`). That prefix is how a deep link says which role it needs.
- **A leading underscore marks a development surface** (`/_dev`, `/_design`,
  `/_health`). Those sit outside the redirect chain and are **not registered at
  all** in production, so no deep link can reach them there.

`/_dev` is the developer-tools screen: sign-in scenarios for every branch of the
redirect chain, the role switcher, and live interface-variant switching. Reach it
from the onboarding screen or the floating button in any role shell.

**A role switch must name its destination** — call `switchRoleAndGo`, never
`SessionController.switchRole` alone. The reason is not obvious and it is in
MEMORY.md: the redirect chain's deep-link rule reads the *location*, so after a
bare `switchRole` it re-activates the role that owns the current path and silently
undoes the switch.

## App commands

```powershell
flutter analyze                     # lint (very_good_analysis + riverpod_lint)
flutter test                        # unit/widget tests
dart run build_runner build         # regenerate *.g.dart after editing providers/models
dart run build_runner watch         # continuous codegen while developing
flutter gen-l10n                    # regenerate localizations after editing an ARB
flutter build apk --debug --flavor development   # verify the Android toolchain
```

## Structure

```
lib/
  main.dart                     ProviderScope + HeadhunterApp
  src/
    app.dart                    MaterialApp.router wiring
    core/
      auth/app_role.dart        the three roles; path prefix, wire value
      auth/session_state.dart   sealed session states the redirect chain switches on
      auth/session_controller.dart granted roles, active role, account status
      auth/token_store.dart     flutter_secure_storage token pair
      config/app_config.dart    --dart-define config (API base URL, timeouts)
      config/app_flavor.dart    development / staging / production
      design/design.dart        the design system barrel - build screens from Hh*
      l10n/app_locale.dart      the four interface variants; never languageCode alone
      network/dio_provider.dart the single Dio instance; add auth interceptor here
      network/api_exception.dart DioException -> user-presentable failure
      router/routes.dart        every path, in one place
      router/shell_tabs.dart    one table driving routes, nav bar and titles
      router/app_router.dart    the three role shells + the redirect chain
      router/role_navigation.dart switchRoleAndGo - read it before switching roles
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

## iOS - out of scope

**Owner direction 2026-08-05: do no iOS work, and do not raise iOS as a
consideration, until asked.** Android only.

- Do not edit anything under `ios/`, and do not touch
  `IPHONEOS_DEPLOYMENT_TARGET`.
- `ios-build.yml` is **`workflow_dispatch`-only** — it no longer runs on push. It
  would fail anyway: `telegram_login` needs iOS 15 and the project stays at 13.
- **Nothing catches iOS compile breakage now.** That is accepted.
- Keep Dart cross-platform regardless. No Android-only concessions in `lib/` —
  they cost more to undo than they save.

Background, if this ever reverses: iOS cannot be built on this Windows machine
(Xcode is macOS-only), an installable `.ipa` needs a Mac and an Apple Developer
account, and Telegram login additionally needs a bundle id + Apple Team ID
registered with BotFather (docs/TELEGRAM_LOGIN.md).

## Backend contract

Auth (§4.1). All three are `@Public` and rate limited:

| Call | Returns |
|---|---|
| `POST /auth/otp/send` `{phone}` | `{expiresAt, resendAvailableAt, devCode?}` |
| `POST /auth/otp/resend` `{phone}` | same |
| `POST /auth/otp/verify` `{phone, code, …device}` | `AuthTokensResponseDto` |

`phone` is E.164 (`+998…`) — build it with `UzPhone.wire`, never by hand. The
account's language comes from the `x-lang` header, not a body field. `devCode` is
present only while `OTP_ECHO_IN_RESPONSE` is on, which the backend refuses in
production.

`POST /auth/telegram` returns the same `AuthTokensResponseDto` and still works,
but is deprecated and uncalled.

The app also consumes `GET /health`:

```json
{ "status": "ok", "database": "up", "version": "0.0.1", "timestamp": "2026-08-04T06:33:46.530Z" }
```

`HealthStatus` in `lib/src/features/health/domain/health_status.dart` mirrors
`HealthResponseDto` in the backend. **Change both together.** Swagger is at
http://localhost:3001/docs and a Scalar reference at /reference.

The health screen is scaffolding that proves app -> API -> Postgres works. It
should be replaced by the first real feature, not built on.
