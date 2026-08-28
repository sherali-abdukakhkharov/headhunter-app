# JobBridge

Mobile-only recruitment platform for Uzbekistan. Two repositories, developed
together.

**The product was renamed from "Universal HeadHunter" to JobBridge on
2026-08-19, and the rename is deliberately partial.** Renamed: the launcher name
and in-app title, the Android application id (`com.jobbridge.app` + flavor
suffixes), the Android namespace and Kotlin package, and the Dart package
(`jobbridge_app`). **Not renamed, on purpose:** the repository folders, the
`headhunter-backend` references in doc comments (that repo really is called that),
`docs/SPEC.md` and the design document (both are client deliverables carrying the
old name), and the `hh.qitmir.uz` API host. So a `headhunter` in a path or a
backend reference is correct; a `headhunter` in an application id or an import is
a leftover.

`android/app/google-services.json` now lists **six** apps: the three pre-rename
ids and the three `com.jobbridge.app*` ones, registered in the Firebase console
on 2026-08-24. That unblocked push. The old three are kept because one download
returns every app in the project and deleting them buys nothing — see
[docs/NOTIFICATIONS_SETUP.md](docs/NOTIFICATIONS_SETUP.md).

**The file is gitignored and supplied per machine**, alongside the keystore
(`android/.gitignore`). Google does not treat the key inside it as a secret, but
GitHub's scanner flagged it on 2026-08-07 and this repository keeps
credential-shaped files out. So a fresh clone **cannot build Android** until you
fetch it from the Firebase console, and CI restores it from the
`GOOGLE_SERVICES_JSON_BASE64` repository secret.

**A flavor with no entry now fails the build**, not the device — the
`com.google.gms.google-services` plugin refuses with "No matching client found
for package name". `test/features/notifications/push_test.dart` derives the
three ids from `build.gradle.kts` and fails sooner still, where the file is
present.

| Repo | Path | Stack |
|---|---|---|
| `headhunter-app` (this repo) | `d:\Dev\tgbots\headhunter-app` | Flutter 3.44.8 / Dart 3.12.2, Riverpod 3, go_router, dio |
| `headhunter-backend` | `d:\Dev\tgbots\headhunter-backend` | NestJS 11, Kysely, PostgreSQL 18, SWC, Biome + ESLint |

The backend is reachable from a Claude Code session rooted here via
`permissions.additionalDirectories` in [.claude/settings.json](.claude/settings.json).
Open both at once in one editor window with
[headhunter.code-workspace](headhunter.code-workspace).

**That means the backend is editable from here, not merely readable — so a
missing endpoint is work, not a blocker.** Owner direction, 2026-08-26: stop
filing an ask for something you could implement. Write the endpoint, its test
and both sides of the contract in one change; `docs/BACKEND_ASKS.md` is for
questions that need a *decision* (a policy, a price, a rule the client may not
choose), not for gaps that need typing. The two repos commit separately.

## Which document to read

| File | Contents |
|---|---|
| [docs/SPEC.md](docs/SPEC.md) | The client specification. **Cite it** as §n, BR-nn, UAT-nn. |
| [docs/SPEC_CHANGELOG.md](docs/SPEC_CHANGELOG.md) | What each client revision changed, and which delivered code it contradicts. Read before assuming a section still says what you remember. |
| [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md) | History only. Telegram login was deprecated 2026-08-05 and its client code **deleted 2026-08-19**. Read only if someone proposes reviving it. |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Design decisions: role shell, localization, forms, offline. Read before adding a feature. |
| [PLAN.md](PLAN.md) | Milestones in dependency order, mapped to BR/UAT. |
| [TODO.md](TODO.md) | Working checklist and what is blocked on whom. |
| [MEMORY.md](MEMORY.md) | Why decisions were made; traps already paid for. |
| [README.md](README.md) | Prerequisites, commands, run instructions. |
| [CHANGELOG.md](CHANGELOG.md) | What each release shipped, and **how a release is cut** — the version in `pubspec.yaml` is what a device reports, so a tag alone is not a release. |

Before implementing anything from the spec, check ARCHITECTURE.md - several
requirements have already been designed against, and the reasoning is not
re-derivable from the spec text.

## The design system

The client's design is implemented under [lib/src/core/design/](lib/src/core/design/) —
import the `design.dart` barrel and build screens from the `Hh*` components. Do
not hand-roll a `Container` where a component exists, and do not introduce a
colour, radius or elevation that is not a token.

Four rules the components encode:

- **One control size for everyone** — every control is 52px with a persistent
  label. There is no dense/simple mode; only the *fields* differ by work category.
- **Status is never colour alone** — always `HhBadge` (icon + word), for vacancy,
  application, verification, invitation and complaint state alike.
- **One elevation level.** `HhElevation.card` or `HhElevation.sheet`, nothing else.
- **The brand mark takes a ground, not colours.** `HhBrandMark(ground: …)` — navy
  is two-tone with the *right* figure turquoise, light and turquoise are mono navy.
  "Turquoise on white" and "both figures turquoise" are documented misuses, and
  selecting by ground makes them unwritable. It also drops to a single figure
  below 20pt on its own, which **changes its aspect** from 23 : 19.8 to 10.7 : 19.8.

`/_design` renders the whole catalogue; reach it from the debug-only action in the
health screen's app bar. **After changing anything in the design system, run the
gallery on a device** — see MEMORY.md for three bugs that a green `flutter analyze`
and a green test suite both missed.

**A device run is not a gate on shipping the change**, though. Gradle will not
start in a Claude session, and every release is re-tested end to end by a QA
pass that delivers a fresh `mobile-test-audit.md` — so make the change, pin what
*can* be pinned in a test, and let the audit confirm the rest. Say plainly in the
commit what was verified here and what was not.

**Accessibility is one of the things that can be pinned here.** Semantics render
headlessly: `tester.getSemantics` and `find.bySemanticsLabel` reproduce a
TalkBack announcement exactly, which is how MT-015 was found and fixed without a
device. See `test/core/design/semantics_test.dart`.

## Domain rules that are easy to get wrong

- **Four interface variants, three languages.** Uzbek ships in Latin *and*
  Cyrillic. Never key on `locale.languageCode` alone - it collapses the two.
- **Pickers display labels but bind dictionary IDs** (BR-13, §3.3). Binding a
  label breaks cross-language search, and it fails silently.
  **A few DTOs deliberately carry the `code` instead** — `purposeCode` on a
  file, on required evidence, on a moderation queue's attachment — because the
  upload endpoint takes a purpose code. Both are `String`, so handing a code to
  `DictionaryLabel(id:)` compiles, runs, and renders *"Unavailable value"*
  forever: that shipped, in every language, for as long as the employer's
  candidate view had existed (MT-009). Use **`DictionaryCodeLabel(code:)`** for
  a code and `DictionaryLabel(id:)` for an id, and let the parameter name be
  the check.
- **A machine value must never reach a screen.** Not a `snake_case` code, and
  not a bare integer where money belongs — `150000` gives a reader nothing to
  count against. Money goes through `formatPay` (`core/format/`), a purpose
  code through `DictionaryCodeLabel`, and the two **server-written** moderation
  reasons through `moderationReasonText`. §2.4's "show the reason verbatim" is
  a rule about *human* text; a code the server generated was never that.
- **Structured profile fields are what search uses**; the CV is an attachment.
  There is no CV parsing in this product (§1, §5.4).
- **Three roles in one app, switchable at runtime** (§2.3), and **admin is one of
  them** (§10) - there is no web admin panel, ever (§2.4).
- **Forms are schema-driven** because the field set depends on work category and
  admins add categories at runtime (§5.2, §6.3, §10.3).
- **Never show a candidate's phone on a search card** (BR-09, §11.1). Since the
  2026-08-10 spec revision the rule reaches further: phone, e-mail and CV are
  released to an employer **only after a paid Candidate Unlock** (§6.6, §11.1).
  An application no longer entitles an employer to contact on its own.
- **Money is the server's.** Coin price, unlock cost and the registration bonus
  are server configuration (§6.6) — a constant in Dart makes a price change a
  store release and disagrees with the ledger the moment it moves. The client
  never computes a total, a balance or an amount payable (§12.3.1).
- **Top up says it is not available yet, and that is the answer, not a defect.**
  §6.7's checkout needs Payme and CLICK *test merchant credentials*, which the
  client has not supplied; nothing in M13 can be built or demonstrated without
  them. **Owner direction, 2026-08-28: leave the control exactly as it is until
  the keys arrive.** Not hidden, not removed, not reworded — an employer who
  taps it is told plainly that top-up arrives with Payme and CLICK, and that is
  a truthful answer to a question they were right to ask.
  So **a QA pass should stop filing this**. It has been MT-006 in four
  consecutive audits, each time recommending either "implement it" or "remove
  it": the first is blocked on somebody outside this repository and the second
  was considered and declined. Report it as a known state if it must be
  mentioned at all. What *would* be a finding is the control doing something
  else — failing silently, charging anything, or claiming a balance changed.
- **Sign-in is phone + OTP** (§4.1, UAT-01), which satisfies BR-01 by
  construction: verifying the code is what makes the number verified. Telegram
  login was tried, **deprecated 2026-08-05**, and its client code **removed
  2026-08-19** — it applied the Kotlin Gradle Plugin, which future Flutter
  versions will refuse, and pulled a community fork of Telegram's SDK onto the
  path that guards every account, for a feature nothing called. The backend's
  `POST /auth/telegram` still exists and still works; the client can no longer
  reach it ([docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md)).
- **SMS is real, and codes are random.** Eskiz.uz has delivered since
  2026-08-20 and real numbers are signing in through it — confirmed by the owner
  on 2026-08-26. `OTP_STATIC_CODE` and `OTP_ECHO_IN_RESPONSE` are both cleared,
  `NODE_ENV=production` is set, and the env schema *refuses* both at boot rather
  than trusting an `.env` file to stay correct. So there is no fixed code any
  more, and no `devCode` in a send response: **a test account needs a phone that
  can receive a message**, and the emulator flow needs one too. About 160 UZS a
  login, which is a real reason not to loop a resend in a test.
  This paragraph said the opposite until 2026-08-26 — see
  `headhunter-backend/docs/SMS_PROVIDER.md` for what was actually done, including
  the outage that connecting the provider caused.
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
by side: `development` (`com.jobbridge.app.dev`), `staging`
(`com.jobbridge.app.staging`), `production` (`com.jobbridge.app`, no suffix).

**`com.jobbridge.app` is a store identity.** It has never been published, which is
the only reason the 2026-08-19 rename was possible at all — after the first upload
the id is fixed, and changing it means a new listing with no upgrade path for
anyone who already installed the app.

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

# Take in a revised client specification. Run it for BOTH repos with the same
# source - the two SPEC.md files are required to be byte-identical, and two
# runs agreeing is what makes the conversion checkable.
node tool/spec_from_docx.js <source.docx>
node tool/spec_from_docx.js <source.docx> ..\headhunter-backend\docs\SPEC.md
```

## Structure

```
lib/
  main.dart                     ProviderScope + JobBridgeApp
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

## The native code is two MethodChannels, and neither is a plugin

`android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt` carries both:

- **`/attachments`** hands a downloaded file to the OS through a `FileProvider`;
- **`/push`** creates the notification channel FCM posts to, and reads
  `versionName` for the device registration.

Every pub package that does either applies the Kotlin Gradle Plugin — a warning
future Flutter versions refuse — and the app module's *own* Kotlin does not
appear on that list. `flutter_local_notifications` and `package_info_plus` are
the usual answers and both are on it.

**The list already has one name on it: `file_picker`**, since 2026-08-07. CI
prints it on every build. Removing `telegram_login` on 2026-08-19 took the list
from two to one rather than emptying it, and several comments in this repo said
"emptied" until 2026-08-25. So the rule is **do not make it longer** — and check
before adding, because one entry is already spending the budget.

So **before adding a dependency that exists to reach the platform, check whether
the channel can carry it**, and check what is already resolved: `path_provider` was
already transitive and `androidx.core` was already on the compile classpath, so
`build.gradle.kts` was never touched for the attachment channel. ARCHITECTURE.md
§9 has the details, including what the provider may share and why every download
re-requests.

`firebase_core` and `firebase_messaging` **were** checked against that rule
before being added on 2026-08-24, and are clean: both are `com.android.library`
with Java sources. The only Gradle change they needed was the
`com.google.gms.google-services` plugin, which reads `google-services.json`.

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
  Most of those messages are **the server's**, already translated by `x-lang`.
  The ones the server could not send — offline, timeout, a proxy's HTML error
  page — come from the ARB through `ApiException.localizations`, a static
  installed by `JobBridgeApp` because a repository has no `BuildContext` and
  there are 117 construction sites. They were hardcoded English until
  2026-08-25, in a product with four interface variants (MT-014).
  `ApiException.kind` is what a screen should branch on when it must *behave*
  differently rather than only say something different; matching on the message
  breaks the first time the copy is edited.
- **A control is enabled only when pressing it would do something**, and local
  validation belongs on the field, never in the page's error state — whose
  heading says "Something went wrong" and is a claim about the system, not
  about what the user is still typing (MT-013). Derive the enabled state from
  the same value the submit path checks; if they can disagree, they will.
- **Log with `debugPrint`, not `developer.log`.** `developer.log` writes only to
  the VM service, so it is invisible in `flutter run`, `flutter logs` and
  logcat — precisely where you look when a request misbehaves. The dio
  `LogInterceptor` uses `debugPrint` for this reason.
- **Providers are generated.** Annotate with `@riverpod` and run build_runner;
  do not hand-write provider boilerplate.
- **Generated files are committed** (`*.g.dart`), and CI re-runs codegen and
  fails on any diff. **Re-run `dart run build_runner build` as the *last* step
  before committing**, after the final round of lint fixes — not before it.
  riverpod_generator copies a provider's **doc comment** into the generated file
  (three times), so merely re-wrapping a comment to satisfy the 80-column rule
  makes `*.g.dart` stale. `flutter analyze` and `flutter test` both stay green
  when this happens; only CI catches it.
- **A repository's HTTP verb and path need a transport-level test.** Faking the
  repository tests everything above it and nothing about the wire, and the wire
  is where a handwritten contract drifts: §9.2's two mark-read routes shipped as
  `POST` against `@Put` and 404'd for two whole releases with nothing red
  (MEMORY.md, 2026-08-25). Drive the real repository through a recording
  `HttpClientAdapter` — `notification_repository_test.dart` is the pattern, and
  it also cross-checks the backend's own decorators when that repo is checked
  out beside this one.
- Line length 80, and **`flutter analyze` is a real gate again** (MT-024,
  2026-08-27) — because **riverpod_lint is deliberately not enabled**. It ran
  through the analysis server's plugin system on about one invocation in four:
  the same unchanged tree reported 32, 35, 3 and 0 findings on consecutive runs,
  and the runs that reported everything were the slow ones (95s against 5s).
  Every finding it ever produced here was in `test/` and wrong there.
  **Suppressing them was tried first and could not be verified** — a plugin
  diagnostic named in an options file is reported as an unrecognised code
  whenever the plugin has not loaded, and the plugin's state cannot be forced,
  so three clean runs proved only that those runs had no plugin. The next one
  that did have it reported all 32 again. The reasoning, and what to check
  before re-enabling it, are in `analysis_options.yaml`.
  Core Dart lints are unaffected and still reach the test tree — proven by
  breaking one deliberately rather than assumed.

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
- `ios-build.yml` is **`workflow_dispatch`-only** — it no longer runs on push.
  The reason it would have failed anyway is gone: `telegram_login` needed iOS 15
  against the project's 13, and it was removed on 2026-08-19. Whether the iOS
  build now passes is **untested**, and testing it is not worth doing while iOS is
  out of scope.
- **Nothing catches iOS compile breakage now.** That is accepted.
- Keep Dart cross-platform regardless. No Android-only concessions in `lib/` —
  they cost more to undo than they save.

Background, if this ever reverses: iOS cannot be built on this Windows machine
(Xcode is macOS-only), an installable `.ipa` needs a Mac and an Apple Developer
account. (Telegram login also needed a bundle id + Apple Team ID registered with
BotFather, but that dependency is gone — see docs/TELEGRAM_LOGIN.md.)

## Backend contract

Auth (§4.1). All three are `@Public` and rate limited:

| Call | Returns |
|---|---|
| `POST /auth/otp/send` `{phone}` | `{expiresAt, resendAvailableAt, codeLength, maxAttempts, devCode?}` |
| `POST /auth/otp/resend` `{phone}` | same |
| `POST /auth/otp/verify` `{phone, code, …device}` | `AuthTokensResponseDto` |

`codeLength` and `maxAttempts` are §4.2 configuration and the challenge carries
them so the client stops guessing (added 2026-08-26). **`maxAttempts` is the
limit, never the number remaining** — `verify` answers `auth.otp_invalid`
identically for "no code", "expired" and "wrong code" so that probing a number
cannot reveal whether one is pending, and a remaining count on that refusal
would be exactly that oracle. The countdown on the code screen is therefore the
client's own tally against the limit.

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
