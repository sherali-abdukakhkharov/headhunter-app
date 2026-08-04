# headhunter-app - Decision and context log

Durable context that is **not** recoverable from the code: decisions and their
reasons, traps already paid for, and facts about this environment. Append new
entries at the top of the relevant section; supersede rather than delete, so the
reasoning stays readable.

Not for: things the code already says, or the milestone checklist (that is
[TODO.md](TODO.md)).

---

## Project facts

- **Product**: Universal HeadHunter - a mobile-only recruitment platform for
  Uzbekistan covering professional, service, physical, seasonal/agricultural and
  temporary/shift work. Client specification: [docs/SPEC.md](docs/SPEC.md)
  (converted from the client's approval-version .docx, Tashkent 2026).
- **Repo pair**: this Flutter client plus `d:\Dev\tgbots\headhunter-backend`
  (NestJS). Separate GitHub repos under `sherali-abdukakhkharov`. A Claude Code
  session rooted here can edit both (`.claude/settings.json`).
- **One app, three roles.** Candidates, employers **and administrators** all use
  this app; the admin panel is a role inside it. §2.4 explicitly excludes any web
  admin panel, so "we'll build the admin screens on the web later" is not an
  option available to us.
- **Four interface variants, three languages**: Uzbek Latin, Uzbek Cyrillic,
  Russian, English. Uzbek ships in two scripts - that is why the count is four.
- **Hard out-of-scope list** (§2.4): public website, desktop client, web admin
  panel, payroll/tax/HR records, in-app payments, built-in video calling,
  automatic translation of user content. Treat requests for these as scope changes.
- **Design deliverable is the client's** (§13.2: Figma source, components,
  prototypes, icons, handoff). Until it arrives, the design system is provisional.

## Architectural decisions

### 2026-08-04 - Role-aware navigation shell, one shell per role
`go_router` with a `StatefulShellRoute` selected by the active role, plus a
redirect chain for unauthenticated / no-role / blocked / ungranted-role.
*Why:* §2.2 and §10 give the three roles genuinely different information
architectures, and §2.3 requires switching roles at runtime without a second
account. Sharing one shell and hiding tabs leaks navigation state across a role
switch.
*Consequence:* deep links from notifications may need to **activate a role before
navigating**. That belongs in the router in one place, not in each notification
handler.

### 2026-08-04 - Locales carry a scriptCode; never key on languageCode alone
`Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn' | 'Cyrl')`, plus `ru`
and `en`.
*Why:* the two Uzbek variants are the same language. Anything keyed on
`locale.languageCode` silently collapses them, and the bug surfaces as "Cyrillic
users see Latin text" long after the code was written. The full tag is used for
ARB lookup, the `x-lang` header, dictionary cache keys and analytics dimensions.

### 2026-08-04 - Missing translation is a build failure, not a runtime fallback
CI asserts all four ARB files share exactly one key set, in addition to the
runtime fallback chain `uz-Cyrl → uz-Latn → en`.
*Why:* §3.2 states a missing translation must never display a technical key. A
runtime fallback alone hides the omission until a user in the least-tested locale
finds it.

### 2026-08-04 - Pickers bind dictionary IDs, display labels
Selected values in app state are always dictionary IDs.
*Why:* BR-13 and §3.3 require identical search results regardless of interface
language. Binding a label anywhere breaks that, and the failure is silent - the
search simply returns nothing.
*Consequence:* labels for deactivated or historical items must be resolvable by ID
from cache, because such items are absent from the active picker list.

### 2026-08-04 - Dictionary cache starts as versioned JSON, not sqlite
Cached per `(type, fullLocaleTag)` and refetched only when the server's dictionary
version changes.
*Why:* dictionaries are large but read-only and rarely change; pickers need list
access, not queries. sqlite is justified only when a screen must *query* them
(type-ahead over very large sets) - record that as a new decision if it happens.

### 2026-08-04 - Forms are schema-driven, not one widget tree per category
A small engine in `core/forms/` maps a server-supplied field schema to widgets.
*Why:* §5.2 and §6.3 make the field set depend on the occupation/vacancy category,
and admins can add work types at runtime (§10.3). Hand-writing a form per category
means a release every time the dictionary grows.
*Boundary, deliberately:* the engine stays small. Bespoke sections (experience
entries) are ordinary widgets. A fully generic form builder is a known trap.

### 2026-08-04 - Refresh must be single-flight
Concurrent 401s wait on one in-flight refresh, then replay.
*Why:* the backend rotates refresh tokens **with reuse detection**. Two parallel
refreshes look exactly like a stolen-token replay and will log the user out. This
is the classic bug in this design - the test is not optional.

### 2026-08-04 - Idempotency keys are generated once and persisted
Keys are stored with the pending action and reused across retries.
*Why:* §12.4 requires safe retry without duplicate applications, invitations or
messages. A key regenerated on each attempt provides no protection whatsoever -
it is the persistence that makes it work.

### 2026-08-04 - Ranking and matching stay on the server
The client renders the score and its per-group breakdown; it does not compute them.
*Why:* §7.3 defines ranking server-side. A client-side reimplementation would
disagree with the server's ordering and pagination.

## Traps already paid for

### 2026-08-04 - Riverpod 3 auto-retry produced an endless spinner
Riverpod 3 retries a failing provider with exponential backoff, and **while
retrying the state is `AsyncLoading` that merely carries the error**. The health
screen matched `AsyncLoading` before checking for an error, so an unreachable
backend showed a spinner forever while re-sending the request every few seconds.
*Fix, in two parts:* `ProviderScope(retry: (_, _) => null)` in `main.dart` makes
an error terminal; and screens match `AsyncValue(hasError: true, :final error?)`
**first** so a spinner can never mask a failure even if retry is re-enabled
somewhere later.
*Do not undo either half.* If a screen genuinely wants backoff, give that provider
its own `retry` returning a `Duration`.

### 2026-08-04 - `developer.log` is invisible where you actually look
`dart:developer`'s `log()` writes only to the VM service - not to `flutter run`,
`flutter logs`, or logcat. The dio `LogInterceptor` therefore uses `debugPrint`.
Diagnosing a network problem with `developer.log` wastes a lot of time before you
realise nothing is missing; the logs were never going anywhere visible.

### 2026-08-04 - Dependency pins in `pubspec.yaml` are load-bearing
`flutter_test` (Flutter 3.44.8) pins `meta` exactly → caps `build_runner` → caps
the analyzer at 12.x → caps `riverpod_generator` → fixes `riverpod_annotation`
at 4.0.3 → holds `flutter_riverpod` at 3.3.2 → pins `riverpod_lint` to 3.1.4 in
`analysis_options.yaml`. `flutter pub outdated` lists ~18 upgrades that are
genuinely incompatible. **freezed is absent for this reason** - no stable release
supports analyzer 12. Revisit the whole block together when a Flutter release
unpins `meta`. Full chain documented in `pubspec.yaml`.

### 2026-08-04 - iOS cannot be built on this machine
Xcode is macOS-only. `ios/` is generated and the Dart code is cross-platform; CI
compiles it with `--no-codesign`, which needs no certificates and catches
iOS-specific breakage. An installable `.ipa` requires a Mac and an Apple Developer
account.

## Local environment

- Flutter 3.44.8 at `D:\Dev\sdk\flutter`; Android SDK platform 36 /
  build-tools 36.0.0; AVD `headhunter_pixel` with WHPX acceleration.
- Gradle 9.1 + AGP 9.0.1 + Android Studio's bundled JBR (JDK 25) - this
  combination builds successfully; do not "helpfully" downgrade the JDK.
- Backend API on **3001** (`sahih-bot` owns 3000) and its Postgres on **5435**
  (5432/5433/5434 are taken by sibling projects). The app's default base URL is
  `http://10.0.2.2:3001` - `10.0.2.2` is the emulator's alias for the host
  loopback; `localhost` inside the emulator is the emulator itself.
- Physical device testing needs the machine's LAN IP via
  `--dart-define=API_BASE_URL=...`.
- Release builds currently sign with the **debug keystore** - must be replaced
  before any store upload.

## Open questions

Tracked as `[?]` items at the top of [TODO.md](TODO.md). Summary: Figma design
deliverable, the dictionary and category-field-schema contracts from the backend,
push provider, time-zone policy for interviews, and app icons.
