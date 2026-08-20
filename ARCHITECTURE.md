# headhunter-app - Architecture

Design decisions for the Universal HeadHunter Flutter client, derived from
[docs/SPEC.md](docs/SPEC.md). Read this before adding a feature; it explains the
decisions the rest of the app depends on.

Companion API: `d:\Dev\tgbots\headhunter-backend` (NestJS). Its
`ARCHITECTURE.md` is the other half of this design - read both when touching the
contract between them.

---

## 1. What the specification forces

| Requirement | Source | Architectural consequence |
|---|---|---|
| One app serves candidates, employers **and administrators** | §2.2, §10 | A **role-aware navigation shell**: the whole tab structure and menu change with the active role. Not three apps, and not a web admin panel. |
| One account may hold several roles, switchable without a second account | §2.3 | Active role is app-wide state that rebuilds the router. Role-specific data must not leak across a switch. |
| Four interface variants, three languages | §3.1 | Uzbek needs **two script locales**, so `Locale('uz')` is insufficient - locales carry a `scriptCode`. |
| Search must return identical results in any language | §3.3, BR-13 | The client sends **dictionary IDs**, never labels. Pickers display labels, bind IDs. |
| Profile and vacancy forms adapt to work category | §5.2, §6.3 | Forms are **driven by a server-supplied field schema**, not one hand-written widget tree per category. |
| Retry must not create duplicates | §12.4 | Client-generated, **persisted** idempotency keys on every non-idempotent write. |
| Missing translations must never show technical keys | §3.2 | Fallback chain plus a lint/CI check that all four ARB files have the same keys. |

Out of scope (§2.4) - refuse as scope changes: any web or desktop surface,
payroll, in-app payments, a built-in video engine, automatic translation of
user-entered content.

---

## 2. Layering and structure

Feature-first. A feature owns its data, domain and presentation; `core/` and
`shared/` hold only what a second feature actually needs.

```
lib/
  main.dart                       ProviderScope (retry disabled) + bootstrap
  src/
    app.dart                      MaterialApp.router, locale + theme wiring
    core/
      config/                     flavors, API base URL, timeouts
      network/                    dio, interceptors (auth, locale, idempotency), error mapping
      auth/                       token storage, session state, active role
      localization/               locale controller, ARB-generated l10n, fallback
      dictionaries/               cached dictionary access + pickers' data source
      forms/                      dynamic form engine (schema -> widgets)
      router/                     go_router, role-aware shell and redirects
      theme/                      design system
      widgets/                    primitives used across features
    features/
      onboarding/                 language choice, phone + OTP, role selection
      candidate_profile/          profile sections, completeness, privacy, CV
      candidate_discovery/        vacancy feed, filters, vacancy details, apply
      candidate_applications/     application list and stage tracking
      employer_profile/           company / individual profile, verification state
      employer_vacancies/         vacancy create/edit, statuses, moderation feedback
      employer_applications/      applications per vacancy, stage moves, notes
      candidate_search/           structured search, results, saves, shortlists, invites
      chat/                       conversations and messages
      interviews/                 scheduling and responses
      notifications/              list, unread count, preferences
      admin/                      dashboard, verification, moderation, users, dictionaries
      settings/                   language, sessions, account, privacy
```

Each feature: `data/` (repositories, DTO mapping) → `domain/` (models, enums) →
`presentation/` (screens, widgets, controllers). Repositories throw
`ApiException`; widgets never see a `DioException`.

---

## 3. Role-aware navigation

The single most structural decision. Three roles with genuinely different
information architectures, plus runtime switching (§2.3).

- `go_router` with a **`StatefulShellRoute` per role**, chosen by the active role.
  Switching role swaps the shell, so each role keeps its own navigation stack and
  a candidate tab cannot appear under the employer shell.
- A `redirect` guards on: unauthenticated → onboarding; authenticated but no role
  chosen → role selection; blocked account → a blocking notice screen (BR-10, so
  the client explains rather than failing mysteriously); role not granted → back
  to the default shell.
- Route paths are constants in one place, never inline strings, and a shell path
  starts with its role's prefix (`/candidate`, `/employer`, `/admin`). The prefix
  is load-bearing: it is how a path states which role it needs.
- **Deep links must survive a role switch**: a notification opening an employer
  screen has to activate the employer role first, or the redirect will bounce it.
  Handle this in one place in the router, not per notification type.
- **The location is authoritative, so a role switch states its destination.**
  Call `switchRoleAndGo`, never `SessionController.switchRole` alone. The two
  rules collide otherwise: after a bare `switchRole` the location is still the old
  role's shell, and the deep-link rule above reads that location and re-activates
  the old role, undoing the switch. `(location, session)` cannot tell "the user
  asked for another role" from "the user opened another role's link", and
  resolving that inside the guard means a mode bit in the guard. See MEMORY.md -
  this was a real bug, invisible to a green analyze and a green suite.
- **Underscore-prefixed paths are development surfaces** (`/_dev`, `/_design`,
  `/_health`): outside the redirect chain, never linked from product UI, and not
  registered at all in the production flavor.

Admin is a role, therefore a shell - not a hidden debug menu (§10).

---

## 4. Localization

### 4.1 Four variants, two Uzbek scripts

```dart
const supportedLocales = [
  Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'), // O'zbekcha (Lotin)
  Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'), // Ўзбекча (Кирилл)
  Locale('ru'),
  Locale('en'),
];
```

`flutter_localizations` + `gen-l10n` with ARB files `app_uz_Latn.arb`,
`app_uz_Cyrl.arb`, `app_ru.arb`, `app_en.arb`.

Rules from §3.2:

- Language is selectable **before registration**, then persisted to the user
  profile so it restores on other signed-in devices. So: local storage is the
  source of truth pre-auth; after sign-in the server value wins on fresh install,
  and a local change is pushed to the server.
- Every request sends the active locale in the **`x-lang` header** so
  server-produced text (dictionary labels, validation messages, notifications)
  matches the UI. This is an interceptor, not a per-call parameter.
- **Missing key must never render as a key** (§3.2). Fallback
  `uz-Cyrl → uz-Latn → en`, plus a CI check that all four ARB files share one key
  set. A missing translation is a build failure, not a runtime surprise.
- Dates, numbers, currency and plurals follow the locale via `intl`. All four
  variants are left-to-right, so no RTL work is required.
- **User-entered content is never translated** (§2.4) and never passed through a
  localization helper.

### 4.2 Uzbek script pitfalls

`uz-Cyrl` and `uz-Latn` are the same language, so anything keyed on
`locale.languageCode` alone silently collapses them. Always key on the full
locale tag. This applies to ARB lookup, the `x-lang` header, dictionary cache
keys, and any analytics dimension.

---

## 5. Dictionaries and pickers

Dictionaries are the backbone of every filter and picker (BR-13). They are large
(occupations, skills, regions/districts) and change rarely.

- Fetch per locale, **cache locally with the server's dictionary version/ETag**,
  refetch only when the version changes.
- Cache key is `(dictionaryType, fullLocaleTag)`.
- **Start with a versioned JSON file cache** in app support storage. It is enough
  for pickers and offline display. Move to sqlite only if a screen needs to
  *query* dictionaries (e.g. type-ahead over tens of thousands of rows) - and
  record that as a decision when it happens.
- Pickers are searchable lists that **display the label and bind the ID**. A
  selected value in app state is always an ID.
- Deactivated items must still render for historical records, so resolve labels by
  ID from cache rather than assuming an item is in the active picker list.

---

## 6. Dynamic forms

§5.2 requires the candidate profile form to adapt to occupation category, and
§6.3 the same for vacancies. Hand-writing a form per category multiplies with
every new work type the admin adds.

Design: a small **schema-driven form engine** in `core/forms/`. The server returns
a field schema (field key, widget kind, dictionary type, required flag,
validation) for the chosen category; the engine maps kinds to widgets and
produces a typed value map.

- Widget kinds needed by the spec: text, number, money range, date, date range,
  single-select dictionary, multi-select dictionary, dictionary + level (skills,
  languages), boolean switch, file attachment.
- Irrelevant fields must **not be mandatory** (§5.2) - the required flag comes
  from the schema, never from the widget.
- Keep the engine deliberately small. If a section needs bespoke layout
  (experience entries, for instance), write it as a normal widget and let the
  engine handle the generic remainder. A fully generic form builder is a trap.

---

## 7. Networking, auth and offline safety

### 7.0 Sign-in is phone + OTP

§4.1 and UAT-01, restored by client direction 2026-08-05 after a same-day
excursion into Telegram login. Two screens under `/onboarding`: phone entry, then
code entry. `POST /auth/otp/send` issues the code, `POST /auth/otp/verify` returns
the session.

Three rules that constrain everything downstream:

- **BR-01 is satisfied by construction.** Verifying a code sent to a number *is*
  verifying the number, so no account can reach a session without one. This is
  the reason Telegram login was reversed: its `phone` scope can be declined,
  which produces an authenticated account that cannot act — a state the client
  would have to model, route around and explain.
- **Registration and login are one call.** With a phone-only identity they are
  the same act; `isNewUser` in the response is what routes into role selection.
  Letting the client name the purpose would be a way to probe which numbers are
  registered.
- **The delay, TTL and attempt limits are server configuration** (§4.2). The
  resend countdown is driven by `resendAvailableAt` from the send response, never
  a constant in the app.

**No SMS provider is connected yet.** `OTP_STATIC_CODE` makes the backend issue a
fixed code, substituted where a random code would be generated and nowhere else,
so every other property of the flow is the real one. Removing the backdoor is
clearing one variable.

Telegram login is deprecated and uncalled, but the code and endpoint remain —
[docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md) has the header explaining what
is still true.

- **Two `dio` instances** (`core/network/dio_provider.dart`): the app-wide one
  carrying `AuthInterceptor`, and a **bare** one for the two jobs that must not
  re-enter it — the refresh call and the post-refresh replay. One client for
  both means a 401 on the refresh endpoint triggering another refresh, forever.
- **Log lines are redacted** (`core/network/log_redaction.dart`). `LogInterceptor`
  prints headers and both bodies, which is the bearer token on every request and
  the token pair on every sign-in. Note that a *request* body is logged as an
  unquoted Dart `Map` and a *response* as JSON — a rule that handles only one
  spelling silently misses half of them.
- **Token storage** in `flutter_secure_storage` - never `shared_preferences`
  (§12.5: no secrets in the app, secure token storage).
- **Refresh is single-flight**: concurrent 401s wait on one refresh and then
  replay, otherwise the rotating refresh token (backend side) trips its own reuse
  detection and logs the user out. This is the classic bug in this design, and it
  has a test.
- **A refused refresh and an unreachable server are different things.** 401/403
  means the session is over — clear the tokens. Anything else keeps them: the
  session is probably fine, and clearing signs people out for losing signal.
- **The session survives a cold start** by exchanging the stored refresh token,
  never by trusting its presence: roles and account status must come from the
  server, since a role may have been revoked or the account blocked (BR-10)
  while the app was closed.
- **Idempotency keys** are generated client-side, **persisted with the pending
  action**, and reused on retry (§12.4, BR-07). A key regenerated per attempt
  provides no protection at all.
- **Offline state is explicit** (§12.4): show it, allow safe retry, and never
  silently queue a write that the user believes succeeded.
- Errors are mapped once in `ApiException` and rendered from `.message`. Server
  messages arrive already localized thanks to `x-lang`.
- **Riverpod's automatic retry is disabled app-wide** in `main.dart`. See
  [CLAUDE.md](CLAUDE.md) - re-enabling it hides failures behind spinners.

---

## 8. State management

Riverpod 3 with `@riverpod` codegen.

- Server data: `FutureProvider`-shaped generated providers per repository call.
- Screen/session state: `Notifier` / `AsyncNotifier`.
- App-wide: auth session, active role, locale, dictionary version. These are
  `keepAlive`.
- **Invalidate deliberately.** Applying to a vacancy must invalidate the
  application list and the vacancy detail; a status move must invalidate both
  parties' views. List the invalidations next to the mutation instead of
  scattering `ref.invalidate` calls.
- Search filter state is a single immutable model so "reset all" and "remove one
  chip" (§7.2) are ordinary copies, and the last configuration can be persisted
  locally (§7.2 allows local retention).

---

## 9. Files and uploads

§5.4 requires upload/replace/download/delete for CV (PDF/DOC/DOCX) plus optional
certificates, with **progress, success, failure and retry** states.

- Upload via `dio` with an `onSendProgress` callback surfaced into state; support
  cancellation via `CancelToken` where the platform allows (§12.4).
- Validate type and size client-side for fast feedback, but treat the server as
  authoritative (§12.5).

### Download is a path on this API, not a signed URL

This section used to say "short-lived signed URLs". **It is not what shipped**,
and the difference matters: every file DTO carries a `downloadPath` — a path on
this API — and there is no storage URL anywhere in the contract (§11.1).

**Follow it verbatim. Never construct it.** The path is scoped to whatever
entitles the caller to the file, so the same CV is
`/applications/…/files/…/content` for an employer holding an application,
`/invitations/…` for one whose invitation was accepted, and `/unlocks/…` for one
who paid. Three routes for one file: a client that built the path would be right
a third of the time.

And **every open re-downloads**. BR-09 is re-evaluated per download, which is the
whole reason the path is server-built: holding a path is not holding permission,
so a candidate who withdraws stops being readable mid-session. A cached copy that
answered the next tap would defeat the only check that notices.

### The app's own Kotlin is the platform layer, and there is no plugin

Handing a downloaded file to the OS needs `FileProvider` and an intent, and every
pub package that wraps them is written in Kotlin and therefore **applies the
Kotlin Gradle Plugin** — the build warning this project deliberately emptied on
2026-08-19 by removing `telegram_login`, and one that future Flutter versions
will refuse outright.

The app module's Kotlin is **not** a plugin and does not appear on that list:
`android/app/build.gradle.kts` has no `kotlin("android")` id and still carries a
working `kotlin { compilerOptions { } }` block, because Flutter's built-in support
provides it. So the whole feature is thirty lines in `MainActivity.kt` behind a
`MethodChannel`, and `AttachmentOpener` is the Dart side.

**Before accepting any dependency that exists to reach the platform, check
whether the app's own Kotlin can do it, and check what is already resolved.**
`path_provider` turned out to be transitive already, and `androidx.core` was
already on the compile classpath at 1.15.0 through the Flutter embedding — so
`build.gradle.kts` was never touched. Both answers were in the repo and neither
needed a build.

Three things the same channel could carry and does not yet: `ACTION_DIAL` for the
phone number (the contact block offers **copy** only because `url_launcher` looked
expensive, which it no longer is), `mailto:`, and `ACTION_SEND` to share a
vacancy. The last needs a deep-link scheme first — sharing today would send a
title with no way back into the app.

The cost to be honest about: **native code written on this machine cannot be
compiled on it.** Gradle will not start (see §11), so `MainActivity.kt` ships
unverified until somebody builds. The mitigation is
`test/core/files/attachment_opener_test.dart`, which asserts the *contract across
the boundary* — channel name, provider authority, the read-only flag, the cache
scope — because those four fail silently at a tap rather than loudly at a build.

### What the provider may share

`res/xml/file_paths.xml` exposes **one cache subdirectory and nothing else**, and
the Kotlin re-checks containment with `canonicalPath` on top of that. The
directory next door holds the `flutter_secure_storage` token pair, so a channel
that could be talked into naming an arbitrary path would be the one way this app
hands out a file nobody was entitled to. Never `<external-path>`: a candidate's CV
on shared storage is readable by other apps and survives an uninstall.

---

## 10. Notifications

- Push plus in-app list (§9.2). The in-app list is the record; push is
  best-effort, so never treat a push as the only delivery.
- Tapping a notification deep-links, which may require a role switch first (§3).
- Preferences may disable non-critical categories, but **security and account
  notices stay on** - the UI must not offer to turn those off.

---

## 11. Build configuration

- **Three flavors**: development, testing, production (§12.1), differing in API
  base URL, app id suffix, display name and crash-reporting environment.
- Configuration via `--dart-define`; no secrets compiled into the app (§12.5).
- **Crash reporting and structured logging without sensitive data** (§12.1):
  never log tokens, OTP codes, or full phone numbers.
- Adaptive layouts for common phone sizes, system font scaling, safe areas, and
  platform-correct navigation behaviour (§12.1). Test at large font scale - the
  dense candidate and vacancy cards are where that breaks first.

### iOS reality

iOS cannot be built on the Windows development machine. `ios/` is generated and
the Dart code is cross-platform; CI compiles it with `--no-codesign`. An
installable build needs a Mac and an Apple Developer account. See
[CLAUDE.md](CLAUDE.md).

---

## 12. Testing strategy

| Level | What |
|---|---|
| Unit | Repositories against a stubbed `HttpClientAdapter` (pattern already in `test/features/health/`); form-schema mapping; completeness display; filter-model reducers |
| Widget | Role shells render the right navigation; error and offline states render; large-font-scale smoke tests |
| Golden *(optional)* | Candidate and vacancy cards in all four locales - cheap protection against Cyrillic/Latin overflow |
| Integration | Auth → onboarding → profile → apply happy path against a test backend |

The UAT scenarios in §13.1 are the acceptance checklist; keep a test or a
documented manual script for each.

---

## 13. Deliberately deferred

Not in v1: offline-first write queue beyond idempotent retry, background sync,
biometric unlock, in-app CV editing/generation, saved-search alerts, and any
client-side matching or ranking logic - ranking is the server's job (§7.3) so the
two sides cannot disagree about it.
