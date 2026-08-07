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

### 2026-08-05 - iOS is out of scope. Do not work on it until asked
Owner direction, explicit: **"never consider [iOS] until I ask it, because I don't
want to support iOS for now."**

What that means in practice:

- **Android only.** Do not add, change or "fix" anything under `ios/`, do not
  touch `IPHONEOS_DEPLOYMENT_TARGET`, and do not add iOS setup steps to a plan or
  a checklist.
- `.github/workflows/ios-build.yml` is **triggered by `workflow_dispatch` only** —
  no longer on push or pull request. It was not deleted: the configuration is
  correct and rewriting it later would be waste.
- The trigger change was not tidiness. `telegram_login` requires **iOS 15** and
  the project stays at Flutter's default 13.0, so that job would fail on every
  push — and fixing it is precisely the out-of-scope work.
- Dart stays cross-platform anyway; nothing in `lib/` needs an Android-only
  concession, and adding one would cost more later than it saves now.

*Consequence for iOS knowledge already gathered:* it is kept, marked out of scope,
not deleted — docs/TELEGRAM_LOGIN.md still records the Apple Team ID requirement
and the iOS 15 floor, because that research is correct and will be needed if the
decision reverses.

*Superseded by this:* earlier notes that treat the iOS CI job as a live safety net
(the M0/M0.5 entries below, and the iOS-flavors item in TODO.md). iOS compile
breakage is now **not** caught by anything.

### 2026-08-05 (later the same day) - Telegram login deprecated; sign-in is phone + OTP
Client direction, reversing the entry below after it had shipped. §4.1 and UAT-01
always said phone + OTP; that is what ships.

*The reason is the thing worth keeping.* Telegram's `phone` scope **can be
declined**, and the spike never established whether it returns a number at all
(TELEGRAM_LOGIN.md §7a was still open). BR-01 admits no account without a verified
phone, so the Telegram design had to carry a branch for "authenticated but cannot
act" — a state to model, route around and explain to a user who has just signed
in. Verifying an OTP makes the number verified *by construction*, so that state
cannot exist. **A cheaper login that sometimes produces an unusable account is not
cheaper.**

*Nothing was deleted.* `POST /auth/telegram` (22 integration tests), `TelegramSignIn`
and `signInWithTelegram` all still work and are marked deprecated; the sign-in
screen simply no longer offers the button. Reversing again is re-adding a button.

### 2026-08-05 - Role-scoped endpoints read the role from the *token*
`POST /auth/roles` grants a role but does **not** reissue the access token — the
backend says so plainly ("the new roles reach the token on the next refresh or
role switch"). So an account can hold `candidate`, the app can show the
candidate shell, and every candidate endpoint still answers **403
`role.none_active`**.

`POST /auth/active-role` is what closes it, and it is now called from two places:
after role selection, and on every `switchRole`. Only the access token rotates —
the refresh token is untouched, because this is not a new session and must not
disturb single-flight refresh.

Worth keeping because of *when* it surfaced: this was flagged as a harmless
deferral while nothing was role-authorized, and it became a hard blocker the
moment the first such endpoint was consumed. A gap in auth is invisible until a
feature stands on it.

### 2026-08-05 - The profile form is data; adding a field is a backend change
`GET /schemas/candidate-profile?category=…` returns the sections, fields, kinds,
requiredness, dictionary types and the parent/child cascade. The client renders
it and writes back a map keyed by field code — **no field code appears in the
Dart** except where a widget genuinely has to know one.

Three properties of the contract that are easy to break:

- **An unknown `kind` must be skipped and logged, not thrown.** It is what lets
  the server add a field type without a lockstep release; a client that throws
  turns a server-side addition into an outage for everyone who has not updated.
- **`required` gates searchability (BR-02), never the save.** A candidate must be
  able to clear a field they filled by mistake; the profile then simply stops
  being complete.
- **The profile's `fields` map is shaped exactly as `PATCH` accepts.** Read a
  value, hand it to a widget, send back what comes out — no translation layer,
  and therefore no place for the two directions to disagree.

Completeness and the derived category are computed server-side in the write's own
transaction, so the `PATCH` response is the only trustworthy source for both.
Choosing a primary occupation changes the category, which changes which fields
exist — so that save has to refetch the schema.

### 2026-08-05 - One dictionary type holds every level of a hierarchy
`region` contains regions **and** their districts, told apart only by
`parentId`. So "the region picker" is not "the whole type" — it is "the items
with no parent", and getting that wrong is invisible: the picker rendered all
twelve Tashkent districts alongside the fourteen regions, each one a plausible
option binding a real id.

`parentId` alone cannot express the distinction, because null there already
means "no parent chosen yet". Hence `parentScoped`, set on **both** halves of a
cascade — the top one included. The doc comment on the picker had named this
exact ambiguity before the code was written, and the code still got it wrong;
naming a trap is not the same as handling it.

Found in ten seconds on a device. Not findable in the test suite as written,
because the fake data had no hierarchy in it.

### 2026-08-05 - A Riverpod family keyed on a List refetches forever
`resolvedLabelsProvider(type, [id])` builds a **new list on every rebuild**, and
Dart lists have identity equality, so every rebuild is a different family member:
a new fetch, a new cache entry, nothing ever collected. The screen renders
correctly throughout, which is what makes it invisible.

The key is now a sorted comma-joined `String` (`labelKey`), which also makes
`[a, b]` and `[b, a]` the same provider. `riverpod_lint`'s `provider_parameters`
catches this — worth heeding rather than silencing, because the symptom is a
performance and memory problem, not a wrong pixel.

### 2026-08-05 - A redactor written against JSON missed every outgoing secret
The dio `LogInterceptor` prints a **response** body as raw JSON
(`{"accessToken":"eyJ..."}`) but a **request** body by calling `toString()` on
the Dart `Map` — so it comes out **unquoted**: `{phone: +998901234567, code:
666666}`.

`redactSensitive` was written against the JSON spelling, and its tests used the
JSON spelling, so it passed while the one-time code and the full phone number
went to logcat on every sign-in. Caught only by reading an actual device log
after wiring it up.

*Two lessons, and the second is the general one:* every rule now treats the
quotes as optional on both key and value; and **a test written from the same
mental model as the code cannot catch a wrong model.** The fixture has to come
from the real output.

Related: `"code"` is redacted only when its value is 4-8 digits, because `code`
is also the backend's error-key field (`"code":"auth.otp_invalid"`) and that one
is the most useful thing in the log when a call fails.

### 2026-08-05 - Cold-start restore exchanges the token; it never trusts it
`SessionController.restore` posts the stored refresh token to `/auth/refresh`
and takes roles and account status from the response. The presence of a token
cannot stand in for that: it says nothing about which roles the account holds or
whether an administrator blocked it while the app was closed (BR-10), and
guessing `{candidate}` would put a blocked employer into a working shell.

*The distinction that matters* is between a refresh **refused** and a refresh
that **could not complete**:

- 401/403 → the session really is over. Clear the tokens.
- offline, DNS, 500, timeout → **keep the tokens.** They are very probably fine
  and the next launch on a network restores the session. Clearing here signs
  people out for going through a tunnel, and they cannot get back in without
  signal *and* their phone.

Same rule inside `AuthInterceptor`'s refresh callback, for the same reason.

*Provider cycle worth knowing about:* the interceptor cannot call
`SessionController` to report a dead session, because the controller reads
`AuthRepository`, which reads the `Dio` that owns the interceptor. Riverpod
refuses the cycle. `AuthEvents` breaks it by depending on nothing — dio reports
into it, the controller listens.

### 2026-08-05 - The static OTP code goes where the random one was, and nowhere else
No SMS provider is connected, so `OTP_STATIC_CODE=666666` makes every issued code
fixed. **It is substituted at the single line that calls `generateOtpCode`.**

The tempting alternative — a special case inside `verify` that accepts `666666`
whatever the database says — is worse in a way that only shows up later: it is a
*second code path*, so every property the real flow has (TTL, supersession, the
resend delay, the attempt limit, single-use consumption) would be untested until
the day the backdoor is removed, which is exactly the day nobody is looking. With
the substitution where it is, **removing the backdoor is clearing one environment
variable and no code path changes.**

Boot refuses a non-empty value when `NODE_ENV=production`, and refuses one whose
length disagrees with `OTP_LENGTH` — a mismatch is otherwise silent and baffling,
since the client renders `OTP_LENGTH` boxes and the code that works does not fit.

### 2026-08-05 - `ApiException` ignored the server's message, and said the wrong thing
`ApiException.fromDioException` mapped **status code → hardcoded English**, never
reading the `message` the backend sends. Every comment in both repos claimed
"server messages arrive already localized thanks to `x-lang`"; none of them were
true at the point it mattered.

Found on the OTP screen: a wrong code is a 401, and the generic text for 401 is
*"Your session has expired. Please sign in again."* — shown to somebody in the
middle of signing in. Not merely unhelpful; it describes a different event.

Now the server's `message` wins whenever the body is an object carrying a non-empty
string one, falling back to the status text otherwise (a proxy's HTML error page
must never reach a user). Safe because the backend's exception filter translates
every message and is deliberately generic about internals. **This also fixed the
localization silently: those hardcoded strings were English in all four variants.**

### 2026-08-05 - MVP signs in with Telegram; OTP is deferred, not deleted
**Superseded the same day — see the entry above.** Kept because the research is
still correct and would be needed if Telegram login is revived.

Client direction. Full research, wire contract and open questions in
[docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md).

*Why it works at all*, which is the non-obvious part: **BR-01 requires a verified
phone number**, and a Telegram user id is not one. It works because the OIDC
`phone` scope returns `phone_number` + `phone_number_verified` inside a JWT
Telegram signed - and Telegram only ever holds a number it verified itself at
account registration. So the verification is genuine and costs no SMS. A design
that took only the Telegram identity would quietly fail BR-01.

*Why OTP survives:* the user can decline to share their phone. BR-01 admits no
account without one, so that branch needs a phone-verification step, and the
backend's OTP module already is one. Deleting it would mean rebuilding it. If SMS
cost becomes the objection, **Telegram Gateway** delivers the same codes at ~$0.01
each - a backend delivery-channel swap, no client change.

*Three things found in research that cost money or time if missed:*
- the official **Android SDK is on GitHub Packages behind a PAT**; the Maven
  Central artifact everyone reaches for (`io.khode:…`) is a **community fork** of
  the SDK that guards every account;
- the iOS SDK needs **iOS 15**, and this project is on 13;
- BotFather registration is **per application id and per signing certificate**, so
  the three flavors need three registrations - and it fails at runtime, in one
  environment only.

### 2026-08-05 - The backend auth contract exists; `API_CONTRACTS.md` did not say so
`headhunter-backend/src/modules/auth` already implements OTP send/resend/verify,
sessions, **rotating refresh with reuse detection**, logout, logout-all, session
listing/revocation, `POST /auth/roles` and `POST /auth/active-role`.

This repo recorded "install `AuthInterceptor`" as blocked on a missing contract,
because `docs/API_CONTRACTS.md` covers only locale, timestamps, dictionaries and
schemas. It was never blocked - the contract was in the code the whole time.
*Lesson worth keeping:* when a dependency is marked blocked on another repo, check
that repo's source, not only its docs.

The new Telegram endpoint returns the **same** `AuthTokensResponseDto` as the OTP
path, which is what lets the client's session handling, role-selection redirect and
`isNewUser` routing carry over untouched.

### 2026-08-04 - A role switch must state its destination; the location is authoritative
`SessionController.switchRole` changes state only. Navigation is paired with it in
exactly one place, `switchRoleAndGo` in `core/router/role_navigation.dart`.

*Why it cannot be state alone*, which is the opposite of what it looks like: the
redirect chain implements ARCHITECTURE.md §3's deep-link rule - a granted role
named by the **path** becomes the active one, so a notification can open an
employer screen without the guard bouncing it. After `switchRole(employer)` the
location is still `/candidate/home`, so that same rule reads the location and
re-activates **candidate**, undoing the switch. Both rules are right and they pull
opposite ways, because `(location, session)` cannot distinguish "the user asked
for another role" from "the user opened a link belonging to another role".

Fixing it inside the redirect needs a flag saying which of the two just happened -
a mode bit in a guard, which is where routing bugs live. So the location stays
authoritative and a switch names its destination. One rule, no ambiguity.

*Found on a device*, with `flutter analyze` green and 129 tests passing: the
switcher simply appeared to do nothing. Two tests now pin it, one asserting that
`switchRole` alone does **not** move shells.

### 2026-08-04 - Underscore-prefixed routes are development surfaces
`/_dev`, `/_design`, `/_health`. They are exempt from the redirect chain, never
linked from product UI, and **not registered at all** when
`AppFlavor.allowsDevelopmentTools` is false.
*Why exempt:* the tools have to work *because* the session is in an awkward
state - that is when they are needed. Guarding them behind the chain they exist to
debug locks the keys inside.
*Why unregistered rather than hidden in production:* a hidden screen is still
reachable by deep link; an absent route is not.
*Consequence:* the health screen moved off `/` to `/_health`, so the product's
entry point is the shell and nothing can link the M0 scaffolding into it by
accident.

### 2026-08-04 - Gate development surfaces on the flavor, not `kDebugMode`
`AppFlavor.allowsDevelopmentTools`, i.e. "not production".
*Why:* a **release** build of the development flavor is exactly what gets handed
to the client for a look, and the role switcher has to work there. Conversely a
*profile* build of production is still production, so `kDebugMode` is wrong in
both directions. Network logging uses the same gate.

### 2026-08-04 - Design round 1 answered; the status vocabulary is fixed
The designer answered the handoff questions in §08 of the design file (also
committed as their standalone note). Everything below is *their* decision, not
ours — do not "improve" any of it without going back to them.

- **Twenty states, one table.** Vacancy 6, application 9, verification 5. Each is
  a named constructor on `HhBadge`; the tone answers *whose turn is it and did it
  end well*, and the **glyph rule** does the rest: no glyph repeats within an
  object type, and the same glyph always means the same thing across types
  (shield = identity checked, check-circle = person accepted, clock = a reviewer
  holds it, pencil = yours to edit, lock = finished/read-only, eye =
  visible/seen, x-circle = negative outcome with a reason). That is why *hired*
  and *verified* can share green, and why *withdrawn / paused / closed* can all
  be neutral without becoming indistinguishable. Tests assert both halves of the
  rule.
- **Green is not reserved for verification.** An active vacancy is success-toned.
- **Two states never get a badge**: `Faol` is employer-list only (a live vacancy
  is the candidate's default and badging it adds noise to every card), and
  `Qoralama` is employer-only.
- **The category band never disappears.** Five bands, one per §2.1 category — no
  generic band, because the band is the fastest signal on a scanned list. With no
  photograph it keeps its full height and fills with the category tint, glyph and
  name. Omitting it is the single behaviour the design calls out as breaking list
  rhythm, so `HhVacancyCard` *requires* a category and always renders
  `HhCategoryBand`.
- **Turquoise has exactly three jobs**, and the load-bearing one is the
  **conditional-field rail** (`HhConditionalField`): a block that appeared
  because of a choice, with a caption naming the trigger. The others are the brand
  mark on navy, and progress/value on dark surfaces. Never a button fill, never a
  selected state, never a status tone, never text on white — selection stays blue
  so "selected" and "conditional" can never read as the same signal.
- **Bottom nav reserves two label lines**, constant 70pt across roles and
  languages, because a bar that changes height on role switch reads as a bug and
  moves the safe-area inset. Box model:
  `8 + 22 icon + 4 + 25 label + 10 + 1 hairline = 70`.
- **Text scale is clamped at 2.0x** app-wide: beyond it a sticky action bar eats
  the scroll area on a 320pt device.
- **Skeletons are ours to derive**, by a stated rule: one bar per text line at
  that line's real height, 5px radius, primary/secondary tints, widths 40-60% of
  the real string, same padding and gaps as the live card.
- Copy: the designer owns **uz-Latn + en**; **uz-Cyrl and ru need certified
  translation from the client** — machine translation of recruitment and consent
  strings is a liability. A string table with per-component longest-variant test
  strings is the next deliverable from them.

### 2026-08-04 - Design system implemented from the client's shipped design
The client shipped `Universal HeadHunter.dc.html` (Claude Design project
`33eea5d6-85d6-459c-a4ca-ce3c1efb752d`). It is now implemented under
`lib/src/core/design/`, and it — not our judgement — is the source of truth for
colour, type, spacing and elevation.

Three decisions the design says drive everything, restated because they erode one
screen at a time:
1. **Institutional trust, not startup energy** — Registan blue, one turquoise
   accent, flat surfaces, a single elevation level.
2. **One control size for everyone** — every control 52px with a persistent
   label. No "simple mode" for manual workers; a welder and a frontend developer
   use the same components and only the *fields* differ. Adding a second control
   height re-opens a decision the client already made.
3. **Status is never colour alone** — every badge is icon + word, and vacancy,
   application, verification, invitation and complaint state all use `HhBadge`.

Supporting decisions we made while implementing:

- **Icons are transcribed SVG paths rendered by `flutter_svg`**, not Material
  icons. The design ships a bespoke 24px/1.75-stroke outline family; Material
  icons are filled, sit on a different optical grid and have square joins, so
  mixing them in is immediately visible. `active: true` thickens the stroke to
  2.2 per the design's outline-vs-active rule.
- **Golos Text is bundled, not fetched at runtime.** The design chose it for
  complete Uzbek Cyrillic coverage (ў, қ, ғ, ҳ) alongside Latin and Russian, so
  one family renders all four interface variants with no vertical-rhythm drift.
  It is a **variable** font (wght 400-900), and `fontWeight` alone is not
  reliably applied to variable fonts — `HhTypography._style` also emits an
  explicit `FontVariation('wght', …)`. Build styles through that helper or
  weights silently collapse to Regular.
- **No dark theme.** The design specifies a single light scheme; inventing a dark
  one would be us making visual decisions the client has not approved. There is a
  test asserting this.
- **`accent500` (turquoise) is never a text colour on white** — surface/accent
  only. It does not meet contrast as text.

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

### 2026-08-04 - Notifications deferred to last; deep links split out of M9
Client direction: build the MVP first, notifications are the last thing to
implement and test. M9 moved from "after M6" to after M10 in
[PLAN.md](PLAN.md).
*Why it matters beyond the reorder:* M9 also owned **deep links**, which are
routing infrastructure rather than a notification feature - chat entry points and
share-a-vacancy both need them. Leaving them bundled would have stranded them
behind a deferred milestone, so they moved to M8. Notification taps reuse that
routing later instead of introducing it.
*Second consequence:* no Firebase package enters `pubspec.yaml` until M9 opens,
so the load-bearing pin chain stays untouched for the whole build. The push
provider decision (FCM-only) is recorded but not needed yet.
The in-app notification list has no push dependency and can be pulled forward at
no cost if the client wants notification history earlier.

## Traps already paid for

### 2026-08-04 - Three Android flavor traps, in the order they fire
Adding the three flavors of §12.1 hit three separate walls. All of them fail at
Gradle *configuration* time, so none of them is visible from Dart.

1. **`ProductFlavor names cannot start with 'test'.`** AGP reserves that prefix
   because it collides with the `test` and `androidTest` source sets - so §12.1's
   "testing" flavor cannot be called `testing`. It is `staging` on **both** sides
   rather than `testing` in Dart and something else in Gradle, because two names
   for one environment is a trap every time somebody pairs `--flavor` with
   `--dart-define=FLAVOR=`. A test asserts no flavor name starts with `test`.
2. **`Product Flavor development contains custom resource values, but the feature
   is disabled.`** AGP 9 ships with `buildFeatures.resValues` **off**, so the
   usual `resValue("string", "app_name", …)` per-flavor label fails outright. The
   label goes through a `manifestPlaceholders["appName"]` instead, which needs no
   feature flag - and the launcher name is deliberately never localized anyway
   (§2.4).
3. **`--flavor` becomes mandatory.** With product flavors defined there is no
   plain `assembleDebug`, so a bare `flutter run` can no longer resolve one APK.
   Every documented command now carries `--flavor`.

`app_flavor_test.dart` reads `build.gradle.kts` and the manifest and asserts they
agree with `AppFlavor` on the suffixes and display names. Nothing else connects
the two halves, and a drift stays invisible until a device ends up with two builds
claiming one application id - at which point installing one uninstalls the other
and takes its data.

### 2026-08-04 - Kotlin incremental compilation is broken on this toolchain
Every build failed at `:shared_preferences_android:compileDebugKotlin` with
`Could not close incremental caches … class-fq-name-to-source.tab` and, beneath
it, `Storage for [...] is already registered`. The sequence: the Kotlin daemon
compile fails, the Build Tools API falls back to in-process compilation, and the
fallback re-registers the storages the failed attempt left behind.

`android/gradle.properties` now sets **`kotlin.incremental=false`**, which fixes
it. The cost is nil - the only Kotlin in this repo is `MainActivity.kt`.

Worth recording what it is *not*, because each of these was tried:

- **not the product flavors** - the failing task belongs to a plugin subproject
  with no flavors, and the build fails identically with the pre-flavor `android/`
  config (verified by stashing it);
- **not stale state** - the cache directory is recreated from scratch each build
  and still fails; it survives `flutter clean`, deleting `android/.gradle`,
  `gradlew --stop`, and killing the Kotlin daemons;
- **not a JDK downgrade** - Flutter is using Android Studio's JBR 25 as intended.

Note that `gradlew --stop` does **not** stop Kotlin daemons; they are separate
`java.exe` processes identified by `KotlinCompileDaemon` in their command line.
Revisit when the Kotlin plugin or the bundled JBR moves.

### 2026-08-04 - `pumpAndSettle` cannot be used on any route reaching the splash
The splash screen carries a `CircularProgressIndicator`, which animates forever,
so `pumpAndSettle` times out - and the timeout looks exactly like a stuck
redirect. `test/core/router/app_router_test.dart` uses a bounded `_pumpRoute`
helper (`pump()` plus two 400ms pumps) instead. Two long pumps, not one: a deep
link into a non-active role converges over **two** redirect passes.

### 2026-08-04 - `gen-l10n` drops the script code from `supportedLocales`
It generates working `AppL10nUzLatn` and `AppL10nUzCyrl` classes and a
`lookupAppL10n` that dispatches correctly on `scriptCode` - and then emits
`supportedLocales = [Locale('en'), Locale('ru'), Locale('uz')]`.

Hand that list to `MaterialApp` and `basicLocaleListResolution` collapses a
`uz-Cyrl` preference onto plain `uz`, which resolves to Latin. **Cyrillic becomes
unreachable through the UI and nothing fails.** This is exactly the §4.2 collapse
the architecture warns about, delivered by the tooling itself.

`AppLocale.supportedLocales` restores the script codes and is what `app.dart`
passes. The delegate accepts them because its `isSupported` matches on
`languageCode` alone. Pinned by `test/core/l10n/app_locale_test.dart`, which
asserts the two scripts load *different* strings - the only assertion that
actually catches a regression here.

### 2026-08-04 - `gen-l10n` demands a base `app_uz.arb` it then never uses
Script-coded ARB files are rejected unless a bare-language base file exists
alongside them. So `app_uz.arb` duplicates the Latin content, and duplication
with nothing enforcing it is a drift hazard.

`test/core/l10n/arb_parity_test.dart` asserts `app_uz.arb` and `app_uz_Latn.arb`
agree on every value. Do not "tidy up" the apparent redundancy by deleting either
file.

### 2026-08-04 - `flutter_localizations` pins `intl` to exactly 0.20.2
The pubspec had `intl: ^0.20.3`; adding `flutter_localizations` failed version
solving outright, because the SDK package depends on `intl` **0.20.2 exactly**.
`intl` is now pinned exactly, and it belongs to the same load-bearing family as
the analyzer chain: it moves only when Flutter moves.

### 2026-08-04 - `DateTime.parse` discards the offset, and Tashkent hides it
`DateTime.parse('2026-08-12T14:00:00+05:00')` returns a **UTC** `DateTime`
(`isUtc: true`, `.hour == 9`). The offset is normalised away, not retained.
`.toLocal()` then renders in the **device** zone.

Verified on the repo toolchain. The trap: every machine on this project is on
UTC+5, so `.toLocal()` prints the correct wall clock and the bug is invisible
during development. A user who opens the app in Moscow sees an interview two
hours early - the one bug in this feature that costs someone a job.

The backend sends `scheduledAt` with the offset already resolved plus an explicit
`timeZone` name (`Asia/Tashkent`), and the platform zone is single-zone by
decision. So: **keep the wall-clock components from the string and label them
with `timeZone`; never call `.toLocal()` on an API timestamp.** No `timezone`
package and no ~1MB of tzdata - the server already did the zone resolution, and
this stays correct if Uzbekistan ever reintroduces DST.
Pin it with a test that fakes a non-UTC+5 device, because that is the only way
this stays fixed.

### 2026-08-04 - `Container.alignment` expands, twice over
The same trap bit twice in one day, in two different shapes, so it is worth
knowing as a rule: **a `Container` with an `alignment` grows to the largest size
its constraints allow.**

1. With a fixed `height`, it stretched auto-width buttons across the full width,
   silently defeating `expand: false`.
2. Once the fixed height became a `minHeight` (per the design's min-52 answer),
   the same `alignment` stretched buttons to the **full 600pt viewport**.

Fix in both cases: drop `alignment` and let the `Row` centre on both axes.

### 2026-08-04 - `DecoratedBox` borders do not occupy space
The nav bar measured 69pt instead of the specified 70. The design's box model
counts the 1pt hairline, but a `DecoratedBox` *paints* a border without laying it
out. `Container` insets its child by the border width; `DecoratedBox` does not.

### 2026-08-04 - Three UI bugs that `analyze` and unit tests both missed
All three were found only by building the APK and looking at it on an emulator.
Worth remembering as a pattern: **a green analyze plus green tests says nothing
about whether a widget actually paints.** Run the gallery on a device after
touching the design system.

1. **`Material` asserts if given both `shape` and `borderRadius`.** Every
   bordered button variant crashed with a red error box. The button tests only
   exercised `primary`, which has no border and therefore no `shape` — so the
   suite was green. There is now a test that builds *every* variant.
2. **`Container.alignment` forces maximum width**, which silently defeated
   `expand: false` and stretched auto-width buttons full-bleed. `alignment` is now
   only set when expanding.
3. **A hand-rolled `Stack` progress bar laid out to zero height** and was
   invisible on device. Replaced with a themed `LinearProgressIndicator`.

### 2026-08-07 - `google-services.json` was committed and tripped GitHub
It reached `origin` and GitHub's secret scanner mailed an alert within a
minute. Removed from history by collapsing the commit, force-pushed, and the
file is now in `android/.gitignore` next to the keystore.

**What made it a mistake was not the key's severity.** That key is an Android
client key: it ships inside every APK, anyone can extract it, and Google's own
documentation says it is not a secret. The mistake was ignoring this
repository's existing convention — `key.properties`, `*.jks` and `*.keystore`
are all ignored, so anything credential-shaped belongs with them. `git
check-ignore` was actually run, answered "not ignored", and that answer was
read as permission rather than as the warning it was.

Two things worth carrying:

- **A force-push is not the remedy.** GitHub can retain unreachable blobs and
  a commit stays reachable by its SHA for a while, so rewriting history only
  tidies the branch. The exposure closes when the key is **restricted** in the
  Google Cloud console to the three package names plus the debug and upload
  signing SHA-1s, or regenerated. That is an owner action, not a repo action.
- **One `google-services.json` covers all three flavors.** All three uploaded
  files were snapshots of the same project (`headhunter-app-b463f`); the
  largest carries `com.headhunter.app`, `.dev` and `.staging`, and the Gradle
  plugin selects the client matching the build's applicationId. There is no
  per-flavor file to place.

### 2026-08-07 - Adding one plugin cost three toolchain fixes
`file_picker` is the first plugin added since the toolchain moved to **AGP
9.0.1**, and it failed three different ways before building. Recorded because
the next plugin will hit the same wall.

1. **`file_picker` 11 does not compile its Kotlin under AGP 9.** Its
   `android/build.gradle` skips applying KGP when
   `isAgp9OrAbove`, expecting AGP's *built-in* Kotlin — but
   `android/gradle.properties` sets `android.builtInKotlin=false`. Neither
   compiler runs, the plugin class is never produced, and the failure surfaces
   as `GeneratedPluginRegistrant.java: cannot find symbol FilePickerPlugin`,
   which reads like a stale generated file. It is not; `flutter clean` does
   nothing.
2. **`android.builtInKotlin=true` is not the escape.** It makes
   `telegram_login` — which applies `kotlin-android` unconditionally — fail
   with "This results in a build failure when applying the kotlin-android
   plugin". So the flag cannot move while that dependency is present, and
   CLAUDE.md says to keep it.
   The resolution was **`file_picker` 10.3.3**, which applies KGP
   unconditionally and therefore matches how `telegram_login` already builds.
3. **Then the JVM targets disagreed**: the plugin declares Kotlin `1.8` while
   AGP compiles its Java at `11`, and Kotlin 2.x refuses the mismatch. Fixed in
   `android/build.gradle.kts` with a `subprojects` block pinning **both** sides
   to 17. Raising only Kotlin just flips the error to "11 vs 17", and setting
   `tasks.withType<JavaCompile>` does nothing because AGP configures javac from
   its own `compileOptions` extension — it has to be set there.

The pins in `pubspec.yaml` were unaffected: the lockfile diff was four added
packages and no version changes. That was checked, not assumed.

### 2026-08-07 - `HhButton` in a `Row` collapses the section to zero height
`expand` defaults to **true**, which sets `width: double.infinity`. A `Row`
gives its children unbounded width, and the combination throws
`RenderFlex children have non-zero flex but incoming width constraints are
unbounded` — but only into the layout phase. On the device nothing crashed:
the whole attachments section painted its heading, its label and its empty
state on top of each other at one offset, with the button missing entirely.

`HhButton.text` already defaults to `expand: false`; the other constructors do
not. **Pass `expand: false` on any `HhButton` inside a `Row`** — the button's
own doc comment says so, and this is the second time the design system's
expand-by-default has produced an invisible layout rather than an error
(see the `Container.alignment` entry above).

Worth noting how it was found: a widget test reproduced it in seconds with the
real exception, after two rounds of guessing from screenshots. A screenshot
shows that layout is wrong; only the test says why.

### 2026-08-07 - A card asserted "Present" over a record that denied it
Found by adding a work-experience record on a device, not by the suite.

`ExperienceRecord` has both `isCurrent` and `endedOn`, and the obvious reading is
that they are two ways of saying the same thing — so the first version of the
card collapsed them:

```dart
final end = record.isCurrent ? l10n.experiencePresent
                             : record.endedOn ?? l10n.experiencePresent;
```

The server accepts **three** combinations, not two. `isCurrent: false` with a
null `endedOn` is legitimate — a role that ended on a date the candidate did not
supply — and it is the combination the editor produces most easily, because
leaving the end date blank and not ticking the box is the path of least effort.
The card then printed "Present" over a record that explicitly says it is not
current.

The tests missed it because they covered `isCurrent: true` and
`isCurrent: false` *with* an end date — the two cases that come to mind when you
believe there are only two. **When two fields can express the same fact, count
the combinations the server accepts rather than the ones the feature is about.**

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

### 2026-08-05 - Commands in this repository are PowerShell, not bash
Owner direction: the machine and terminal are **Windows PowerShell**, so every
command in chat, docs and comments is written as PowerShell, in ```powershell
fences.

It matters because bash snippets here *fail* rather than degrade. Windows
PowerShell **5.1** specifically:

- `&&` and `||` are **parser errors** - use `;` or `if ($?) { … }`;
- **`<` input redirection is unsupported** - pipe instead;
- line continuation is a backtick `` ` ``, not `\`;
- no `base64`, `rm`, `cat`, `which`, `head`, `wc`. Base64 a file with
  `[Convert]::ToBase64String([IO.File]::ReadAllBytes('path'))`.

Caught after docs/RELEASE.md shipped `base64 -w0 … > f` followed by
`gh secret set NAME < f` - three separate failures in two lines.

**`gh` is not installed** either, so docs give the GitHub web UI first and `gh`
only as an optional alternative. `Set-Clipboard` is usually the neatest way to
hand over a long value with no temp file to clean up.

**Exception:** the bash inside `.github/workflows/*.yml` is correct as bash - it
runs on `ubuntu-latest` runners. Do not "fix" it.

- Flutter 3.44.8 at `D:\Dev\sdk\flutter`; Android SDK platform 36 /
  build-tools 36.0.0; AVD `headhunter_pixel` with WHPX acceleration.
- Gradle 9.1 + AGP 9.0.1 + Android Studio's bundled JBR (JDK 25) - this
  combination builds successfully; do not "helpfully" downgrade the JDK.
- **Live backend: `https://hh.qitmir.uz`** (Cloudflare-fronted), wired in as
  `AppFlavor.production.apiBaseUrl` on 2026-08-05. Verified that day: `/health`
  200 over HTTPS, `POST /auth/telegram` **401 rather than 404** - so that
  deployment carries the Telegram endpoint, unlike the local dev process, which
  404s because it was started before that module landed. **Restart the local API
  before blaming the client for a 404 on an auth route.**
  Two things worth knowing about that host: it also answers **plaintext HTTP**
  without redirecting to HTTPS, so a client misconfigured with `http://` would put
  bearer tokens on the wire in clear - the app only ever uses the `https://`
  constant; and `staging` deliberately points at a host that does not exist, so a
  staging build cannot silently write production data.
- **The long-running emulator cannot resolve `hh.qitmir.uz`** even though
  `google.com` resolves inside it and three public resolvers answer for the name.
  Chrome in the emulator fails on it too, so it is the emulator's DNS, not the
  app - most likely a stale resolver in an instance that has been up for hours.
  Relaunch with `flutter emulators --launch headhunter_pixel` (or
  `emulator -avd headhunter_pixel -dns-server 8.8.8.8`) before concluding the app
  cannot reach the API.
- Backend API on **3001** (`sahih-bot` owns 3000) and its Postgres on **5435**
  (5432/5433/5434 are taken by sibling projects). The app's default base URL is
  `http://10.0.2.2:3001` - `10.0.2.2` is the emulator's alias for the host
  loopback; `localhost` inside the emulator is the emulator itself.
- Physical device testing needs the machine's LAN IP via
  `--dart-define=API_BASE_URL=...`.
- Release builds sign with `android/upload-keystore.jks` (created 2026-08-05, RSA
  2048, alias `upload`, valid to 2053), loaded from a gitignored
  `android/key.properties`. **Neither file is in the repository** and the keystore
  is not recoverable - see [docs/RELEASE.md](docs/RELEASE.md) for the backup
  warning and the four CI secrets.
  *Consequence that is easy to miss:* this is a **different signing certificate**
  from the debug one, so Telegram login needs its SHA-256 registered with
  BotFather separately, or login fails in downloaded APKs only.
  When no `key.properties` exists the release build falls back to debug signing
  and says so loudly in the log, so a fresh clone still builds - both paths are
  verified.

## Open questions

Tracked as `[?]` items at the top of [TODO.md](TODO.md). Summary: the dictionary
and category-field-schema contracts from the backend (shapes now proposed, six
holes raised), the MVP milestone cut, and app icons.

Closed since: the design deliverable shipped; time-zone policy is single-zone
`Asia/Tashkent`; push provider is no longer blocking after the M9 deferral.
