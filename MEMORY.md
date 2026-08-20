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

### 2026-08-20 - §9.1's chat gate is the server's, and the revision is §8.2's "then" again
The 2026-08-10 revision says employer-initiated chat is enabled only once the
employer holds a Candidate Unlock. `HiringInteractionService` on the server
disagrees: a live application is sufficient, exactly as it is for BR-09's contact
exposure — same service, same three sources (application, accepted invitation,
unlock).

**Treated as one question already answered, not as a new one.** On 2026-08-19 the
client answered the §8.2 version of this — is an invitation a *contact* action or
a *request* to make contact? — in the lenient direction: an application still
opens contact, sending an invitation is free. Chat is the same shape and follows
the same answer. Filed for the client as the **second instance of one spec
contradiction** rather than a second question to sit on.

The reasoning that decides it, and the reason it is not close: gating in the
client while the server does not would tell an employer to pay for something the
API would have given them free. §12.3.1 puts money on the server, and this is a
money decision wearing a feature's clothes.

So `chat_repository.dart` keeps **no copy of the rule**: it calls the route and
renders the 403 as `ChatNotPermitted`, carrying the server's own localized
sentence. Where a screen offers the action only in places contact is already open
(the contact block of §7.3's profile), that is a choice about **placement** — put
the control where it will work rather than where it would mostly fail — and the
authority is still the refusal.

The generalisable rule, now on its second use: **when the specification argues
with a running server about who may do something, the client renders the server
and reports the contradiction.** A client that re-derives the rule is a second
answer to it, and the wrong one is the one nobody can see failing.

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

### 2026-08-20 - An idempotency key held per screen refuses the next message forever
§12.4 says persist the key across retries, and MEMORY.md has said so since
2026-08-04. What it did not say is what the key is a key *to*, and for chat the
obvious answer is wrong in a way that only shows up after a failure.

The backend answers the same key carrying a **different body** with 409
`idempotency.key_reused` — deliberately, because two different operations under
one key means the client's key generation is broken and saying so beats guessing.
Now hold the key per conversation. A send dies with the request in flight, so the
key is still on disk, correctly. The user shrugs and types something *else*. That
request carries the stale key with a new body, earns `key_reused`, and keeps
earning it — the conversation is permanently unsendable, over an error naming
nothing the user did, and clearing app data is the only way out.

So the persisted slot holds **the draft beside its key**: the same text retried
reuses the key and the server replays the original message; different text mints a
new one. And the slot is cleared **on success**, which is the other half — after a
confirmed send, the same text typed again is a *second message*, not a retry. A
retry is only a retry while the first attempt was never confirmed.

The rule generalises: **a key belongs to an operation, so the slot must hold
enough of the request to tell "the same thing again" from "something new."** An
invitation's key is scoped to `(candidate, vacancy-or-occupation)` for exactly
this reason; the unlock has no key at all, because `(employer, candidate)` is a
primary key there and a retry is answered by the existing entitlement.

Both halves are mutation-verified: keying on the conversation alone fails
"different text after a failure mints a new key", and keeping the key past success
fails "the same text sends twice".

### 2026-08-20 - Two more overflows at 320pt / 2.0x, and a test found them this time
MEMORY.md already records that a rule tested on one variant is tested nowhere, and
that the design gallery needs a device. §9.1's chat added two more instances of
the same class — and both were caught by a widget test at the design's own QA
case, which is worth writing down because it is the cheaper half of that lesson.

1. **The conversation row overflowed by 138pt.** A `Row` of `Expanded(name)` plus
   a timestamp. `Expanded` looks like the fix and is the wrong child to shrink:
   the stamp is a full ISO date *and* time, which at 2.0x is wider than the whole
   card on its own, so the name shrank to nothing and the stamp still did not fit.
2. **The message bubble's read receipt overflowed by 18pt.** `HH:MM` plus a glyph
   plus "Read", inside a bubble capped at 78% of the width.

Both fixes are the same one the §8.2 inbox card already paid for: **a `Wrap`, so
the piece that cannot be truncated drops to its own line.** And the reason
truncation is not on the table differs per case in a way worth keeping — a badge
is icon *plus word*, so clipping the word puts the state back on colour alone; a
clipped date is unreadable, and §8.3's display policy is open precisely so a
wrong-*looking* date beats a plausible wrong one.

The generalisable part: **any horizontal row whose children are all
intrinsically-sized text will overflow at 2.0x on a 320pt screen, and `Expanded`
on one of them does not save it.** Test the narrowest case with the longest
plausible content and let the layout tell you; do not reason about it. The
fixture matters — 960 physical pixels at devicePixelRatio 3 is 320 logical, and
getting that wrong (640) makes the test fail at a width no phone has.

### 2026-08-20 - A checklist rots faster than the code it describes
Continuing after a merge, six TODO.md entries described work that was already
done, and two of them were **wrong in a way that changes decisions**:

- `Dictionary contract` and `Category field-schema contract` sat under "blocked
  on someone else" long after the endpoints shipped, so the list said we were
  waiting on the backend for things M2, M3 and M5 are already built on.
- `Role switch does not tell the server` was listed as an M1 gap.
  `SessionController._publishActiveRole` has been calling
  `POST /auth/active-role` on every switch for some time.
- The app icon appeared **three times** — under blocked, under the design system
  and under M11 — because it blocked at three levels, and one entry being struck
  left the other two lying.

Two of them also *closed something off*: the file-download entry said the
dependency cost had to be "weighed against pubspec.yaml's load-bearing pins", and
in the same breath noted that the same decision blocked a `tel:` link. When the
answer turned out to be "the app's own Kotlin is not a plugin", the `tel:` link
was unblocked too — and nothing would have gone looking for it, because the note
recording the blockage was inside the entry that got struck.

**The habit: before answering "what is left", re-read the list against the code
rather than reciting it.** Grep for the endpoint, open the screen. Six of
sixty-nine entries were stale after two days of heavy work, and the two that
mattered were the ones that made the project look more blocked than it was.

### 2026-08-20 - A test asserting a token is *absent* must strip comments first
Three times in one day, in three different files:

- `expect(xml.contains('<monochrome'), isFalse)` failed because the file's own
  comment explains why the element is absent.
- `expect(paths.contains('external'), isFalse)` failed because the comment says
  "deliberately not `<external-path>`".
- `expect(kotlin.contains('FLAG_GRANT_WRITE_URI_PERMISSION'), isFalse)` failed
  because the code above it says "never FLAG_GRANT_WRITE_URI_PERMISSION".

The pattern is structural, not careless: **the better the file documents why
something is missing, the more certainly a naive absence check fails.** And the
failure is the confusing kind — the assertion is correct, the file is correct, and
the test is red.

`_code(path)` in `attachment_opener_test.dart` strips `<!-- -->`, `/* */` and
`//` before matching, and every absence assertion goes through it. Presence
assertions do not need it, which is why the mistake keeps hiding: half the
assertions in the same test are fine without it.

### 2026-08-20 - Two brand rules that interact, and the one that lost silently
The design's mark has a **20pt floor for the pair** (below it the 1.6-unit gap
closes and the two figures fuse) and, separately, "in the horizontal lockup the
mark's height equals the wordmark's cap height". Both are reasonable. Together
they are a trap: Golos Text's cap height is about 0.72em, so a 23pt wordmark - the
design's own default - derives a **19.2pt mark**, which is under the floor. The
lockup rendered a single figure and looked entirely plausible doing it.

Three things to carry:

1. **When two rules from a design constrain the same number, compute the boundary
   before trusting either.** Nothing announced the collision; the widget did what
   both rules said and produced a mark with one person in it.
2. **The specimen was the arbiter.** The document draws 21 x 18 beside 23pt type,
   which implies a cap height of 18.08/23 = 0.786em rather than the textbook 0.72.
   Reading the number off the drawing reproduced the drawing; deriving it from
   typographic convention did not.
3. **What caught it was a test about something else.** "On navy the word stays
   white while the mark goes turquoise" failed, because a solo mark has no
   turquoise figure - the two-tone assertion is what noticed the missing person.
   A test for the *colour rule* found a *size* bug, which is an argument for
   asserting the rule rather than the pixels.

The lockup now asserts `markWidth >= pairFloor` rather than degrading, because a
lockup is defined with the pair in both specimens.

### 2026-08-20 - An Android launcher icon needs no rasteriser, and no PNGs
There is no ImageMagick, Inkscape or rsvg on this machine (`convert` resolves to
Windows' filesystem converter, which is a fine trap of its own), so the launcher
icon is **vector all the way down**:

- `mipmap-anydpi-v26/ic_launcher.xml` - `<adaptive-icon>`, navy background layer,
  arch foreground layer.
- `mipmap-anydpi/ic_launcher.xml` - a plain `<vector>` for **API 24 and 25**,
  which predate adaptive icons. `anydpi` outranks the density qualifiers and
  `anydpi-v26` is excluded below 26, so each API level gets the right one. That is
  the same precedence rule every adaptive-icon setup already depends on, used one
  level further down.
- Flutter's five default `ic_launcher.png` files are **deleted**. Left in place
  they are unreachable and still ship, so any tool that bypasses `anydpi` shows
  the Flutter logo.

Two details that would have been silent bugs:

- **Android's `<vector>` viewport has no origin**, where the designer's export is
  cropped to the ink with `viewBox="4.5 6.2 23 19.8"`. The crop is carried as an
  inner `<group android:translateX="-4.5" android:translateY="-6.2">` so the path
  data stays **byte-identical to the design document** and can be diffed against
  it. Pre-multiplying the coordinates would have saved two lines and made the
  mark unverifiable.
- **`<vector>` has no `<circle>`.** The two heads are circles in the source and
  become two-arc paths here.

And the reason there is a test for all of it: `flutter analyze` does not read
Android XML, `flutter test` does not build it, and an off-centre icon looks
plausible until it is beside another app's on a home screen. So
`test/core/design/brand_test.dart` reads the drawables, applies the transforms and
asserts the centring, the 48%/56% ratios, the locked 23 : 19.8 aspect and the
safe-zone diagonal. **It is arithmetic nothing else in the toolchain checks.**

### 2026-08-20 - A rule tested on one variant is a rule tested nowhere
`HhButton.text` shipped without wrapping its label. Every filled variant puts the
label in a `Flexible`, which is what makes §08.2's "the box grows with the label,
it never clips it" true — the box grows in *height* because the text is allowed to
wrap. The text variant had a bare `Text`, so it took its intrinsic width and the
`Row` overflowed: **190pt at 320 wide and 2.0x text scale**, on a button reading
"View candidate" inside a card.

The part worth remembering is not the missing widget. It is that
`design_system_test.dart` **already had a test for exactly this rule** —
"a control grows with the text scale instead of clipping" — and it only ever built
the filled button. A green suite therefore said the rule held when it held for one
of six variants.

Two habits follow:

- **When a design rule is stated for a component, test it across the component's
  variants, not on the default one.** The neighbouring test in that file
  ("every button variant builds without asserting") was already written as a loop
  over all variants, for the same reason — it just checked a different thing.
  The rule test is now a loop too.
- **The 320pt x 2.0x case has now caught four defects**, and this is the first
  one the design-system tests could have caught themselves. Nothing about it is
  visible at 1.0x in English, which is the width and language a mockup is drawn
  at and the width a hand-written test defaults to. Keep pinning feature screens
  at 320pt with the longest label the screen can hold.

### 2026-08-20 - "Invited" is every status, and `byStatus.sent` is the plausible wrong answer
§7.4 step 7 tracks "invited, accepted, interviewed, and hired counts against the
target". `GET /invitations/counts/:vacancyId` answers with `byStatus`, and the
obvious reading of "invited" is `byStatus['sent']`. It is wrong: `sent` is the
count of invitations **nobody has answered yet**, so the number would have looked
correct until the first reply and then counted *downwards* as replies arrived.

A candidate who accepted was still invited. So invited is the **sum of every
status**, which has a second benefit: it counts a status this build has never
heard of, which is why `countsForVacancy` returns the server's map rather than a
typed pair of ints.

This is the failure mode to watch for in any status-bucketed count: the bucket
named like the whole is usually the bucket of *unresolved* members of it. The test
that pins it uses a fixture where the two readings differ (`{sent: 3, accepted: 5,
declined: 2}` — 10, not 3), because a fixture where nobody has answered passes
either way.

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

### 2026-08-10 - A fixture where two fields agree cannot say which one is read
`LevelFloorField` binds `DictionaryItem.rank`, not `sortOrder` - "B2 or better"
is a comparison, and `sortOrder` moves when an administrator inserts a level
between two others (§10.3), while `rank` does not.

The first test fixture built the scale with `sortOrder: rank`, because that is
what the seed data looks like. Mutating the widget to read `sortOrder` then
changed **nothing**: every test still passed. A realistic fixture had made the
distinction untestable, and the bug it was written to catch would have shipped
and then surfaced months later as a filter that silently drifted.

The rule, and it is general: **when a test exists to pin *which* of two fields
the code reads, the fixture must give them different values** - deliberately
unrealistic ones. Realism in a fixture is worth having only where it does not
collapse the thing under test. Same shape as the `isCurrent`/`endedOn` trap
above: count the combinations that can occur, not the ones that usually do.

Verified by mutation both ways - the fixed fixture fails on `sortOrder` and
passes on `rank`.

### 2026-08-18 - A purchase whose effect is not wired is worse than no button
The backend shipped the Coin wallet (`a88d185`) and M12 looked unblocked. It was
half unblocked. The wallet routes are complete — balance, prices, the paged
ledger, and an atomic unlock that really does debit two Coins — but
`contact-exposure.ts` was **not touched**, and `expose()` is what decides whether
an employer sees a phone number. Grepping for the entitlement settles it in one
command: `candidate_unlocks` appears only inside the backend's wallet module.

So an "Unlock contact — 2 Coins" button built that day would have taken the money
and left the profile still saying "nobody has applied yet". The purchase real,
the effect imaginary.

**What was built instead**: the half that depends on nothing else — balance,
server-supplied prices, and the append-only ledger — and the spending half was
left out with the reason written down. Two things follow that are worth keeping:

- **Check what the new endpoints are *read by*, not just that they exist.** A
  published contract says a feature can be called, not that calling it does
  anything. One `grep` for the new table outside its own module is the whole
  check.
- The same judgement M7 already recorded for its wrong exposure copy: when the
  copy or the control would have to be written twice — once against today's
  server and again against the one arriving — write it once, later, and say why
  in the checklist. **Both are now waiting on the same single backend change**,
  so they land together rather than as two half-corrections.

### 2026-08-20 - The app's own Kotlin is not a plugin, and that is a way out
Opening a downloaded file needs native code. Every pub package that does it is
written in Kotlin and therefore **applies the Kotlin Gradle Plugin**, which is the
warning this project emptied on 2026-08-19 by removing `telegram_login` and which
future Flutter versions will refuse outright. So the obvious dependency was the
one thing not to add.

**`MainActivity.kt` does not count against that.** The KGP warning names *plugins*
- pub packages that apply the plugin in their own build files. The app module's
Kotlin is compiled by Flutter's built-in support: `android/app/build.gradle.kts`
has no `kotlin("android")` id in its `plugins` block and yet carries a working
`kotlin { compilerOptions { } }` block. So thirty lines behind a `MethodChannel`
bought a feature that a dependency could not.

Two facts that made it cheap, both checkable before writing anything:

- **`androidx.core` is already on the app's compile classpath** at 1.15.0 through
  the Flutter embedding - the previous build's manifest-merger blame report names
  it. So `FileProvider` needed no Gradle change, and `build.gradle.kts` - a file
  CLAUDE.md warns about - stayed untouched.
- **`path_provider` was already transitive** at 2.1.6 via `file_picker`, so
  promoting it to a direct dependency pinned nothing new.

The generalisation: before accepting a dependency, check whether the app's own
platform code can do it, and check what is *already* resolved. Both answers are in
the repo and neither needs a build.

The cost to be honest about: **native code written here cannot be compiled here.**
Gradle would not start, so `MainActivity.kt` shipped unverified. The mitigation is
a test that asserts the *contract* across the boundary - channel name, provider
authority, the read-only flag, the cache scope - because those are the four things
that fail silently at a tap rather than loudly at a build.

### 2026-08-20 - Make a design's misuse cases unwritable, not documented
The brand mark has four documented misuses, and two of them are colour choices:
turquoise on white, and both figures turquoise. An API taking colours would leave
both expressible and rely on whoever writes the fifteenth call site having read
the guidelines.

So `HhBrandMark` takes a **ground** - navy, light or turquoise - and derives the
colours. There is no parameter to get wrong. The same reasoning made the 20pt
floor automatic rather than advisory: the mark switches to the single figure
itself, because a rule a caller has to remember is a rule that breaks eventually
and silently.

This is worth generalising. The design's own solution to "turquoise is banned on
white but the mark needs two colours" was to make the separation **structural** -
two heads and a 1.6-unit gap - so that colour became an enhancement rather than
the mechanism. Encoding the rules the same way, as structure instead of as
documentation, is the same move one layer down.

The cost to know about: the automatic switch **changes the widget's aspect**, from
23 : 19.8 to 10.7 : 19.8, because the solo crop is taller than wide. A rule that
enforces itself still has to say what it did.

### 2026-08-20 - Placeholder copy on a reachable screen is not scaffolding
`role_selection_screen.dart` carried an `HhNotice.pending` reading *"Role
selection arrives in M1"*, with a body explaining that the mechanism was live and
only the copy was temporary. Perfectly honest, and addressed to the wrong reader:
that screen is where **every new account** lands, because there is no sign-up step
— `POST /auth/otp/verify` creates the user and a new user holds no role, so the
redirect chain sends them straight here. The note had been on the second screen of
the product since M0.5 and survived four milestones, because the people who could
see it were the two people who knew what it meant.

**Test for it, not just remember it.** The screen's test now asserts no rendered
string contains "M1" and that no `HhNotice` is present at all — a placeholder is
easy to leave and hard to notice, and a test is the only reader guaranteed to look
again.

The copy decisions are worth keeping too, because they generalise past this
screen:

- **Say what a thing does; do not quote its price at the door.** The employer line
  lists §2.2's capabilities and says nothing about Coins or unlocks (§6.6), which
  are real and arrive two screens later. A cost stated before any value has been
  offered reads as a paywall in front of registration. A test asserts no digit
  reaches the screen at all.
- **Put reassurance where the doubt occurs.** §2.3 permits both roles on one
  account and keeps their data apart; the thing that stops people choosing both is
  the fear of a personal job search landing inside a company account. So the note
  is shown **on the second tick** rather than up front, where it would be advice
  nobody asked for.
- **A sentence is not a status.** It is a caption, not an `HhNotice`: every notice
  tone in this system means a *state* (pending, restricted, expired), and dressing
  an explanation as one would make choosing both look like the risky option.

### 2026-08-20 - A rule written in three documents is not enforced anywhere
"The version in `pubspec.yaml` is what a device reports, so a tag is not a
release" is stated in `CHANGELOG.md`, in a comment above `version:` in
`pubspec.yaml`, and in `README.md`'s release section. **Three of the first four
releases broke it**: v1.0.1 and v1.0.2 both shipped as `1.0.0+1`, and v1.1.1
shipped as `1.1.0+3` — reusing the previous release's build number, which is the
part that actually hurts, because a phone holding 1.1.0 then refuses it as an
upgrade and the tester keeps reporting bugs that were fixed.

The documents were not wrong and adding a fourth would not have helped. The
missing thing was a **reader at the moment of the mistake**: tagging is one
command typed from a terminal, and nothing in that moment opens a changelog. So
the check moved into `release-apk.yml` as its first step — a mismatch now costs
twenty seconds and publishes no artifact.

Generalises to any rule whose violation is invisible until later: **if the
consequence surfaces somewhere other than where the mistake is made, the rule
belongs in the machine, not in prose.** The corollary is worth keeping too — the
guard checks only the versionName, because the build-number check would need a
deeper checkout and the failure it catches has not happened yet. A guard that
covers the failure you have had beats one designed for the failure you imagine.

### 2026-08-20 - A score computed from nothing is still a number on screen
The saved-candidates list and the new vacancy shortlist both come back from the
same server helper, which runs the card query with **no filters and no scoring
groups** — and `scoreExpression([])` returns a literal 100, because with nothing
asked there is nothing to have failed. So every card in both lists carries
`matchScore: 100`, and the shipped saved list had been badging every person on it
as a 100% match since M7.

Nobody computed that. The fix is not a different number — 0 would be as wrong,
and picking one in Dart would be the client inventing a figure the server owns —
it is **not rendering the badge where no filter produced it**:
`CandidateResultCard(showMatch: false)` in both lists, true on the search screen.

The general shape, worth more than the instance: **a field that is technically
present in a response is not automatically an answer to a question somebody
asked.** Two lists using one endpoint means one of them may be reading a column
that only means something for the other. When a value's meaning depends on the
*request*, the widget that paints it needs to know which request it came from —
which is also why the same card takes `vacancyId` rather than reading
`isShortlisted` on its own: outside a vacancy that flag is false for everybody,
including people who are shortlisted somewhere.

### 2026-08-20 - A logged endpoint must never be fanned out per row
The employer's sent list has `candidateUserId` on every row and no name, and the
one route that would resolve a name is
`GET /candidate-search/candidates/:candidateUserId`. Its own contract rules the
obvious fix out: **every call is a logged access to protected data (§11.1)**, and
so it "is never called speculatively". Thirty rows would have written thirty audit
entries nobody asked for — into the very log BR-09 exists to make meaningful, and
diluting it is the actual harm, not the request count.

So the client renders no name, and `Invitation.candidateName` is **parsed but not
yet sent**: the field is a backend ask, null on every server today, and the name
appears the day it lands with no client release. Same discipline as the quota's
404 and `unlock_required` — render what the server can say, invent nothing.

Two related shapes settled at the same time, both worth keeping:

- **The vacancy on a row comes from `myVacanciesProvider`, not from discovery.**
  The candidate's inbox resolves a posting per row through
  `GET /discovery/vacancies/:id`, and that whole controller carries
  `@RequireRole('candidate')` — an employer calling it gets 403, not a title. The
  employer's side pulls its own list once and looks up locally, which is also one
  request instead of N.
- **A screen whose subject rendering is shared must share it in code.** The
  general-invitation subject is now one widget used by both sides
  (`invitation_subject.dart`), for the reason already recorded for
  `invitationStamp`: two views of one resource that describe it differently drift,
  and the drift is invisible until somebody reads both screens side by side. The
  **vacancy** subject is deliberately *not* shared, because the two roles reach it
  through different endpoints.

### 2026-08-19 - Filter a ledger by the amount's sign, never by a list of kinds
E-52's filters are "topped up" and "spent", which read like they name transaction
kinds. They do not, and building them that way would have been wrong twice over.

An `admin_adjustment` is a credit *or* a debit depending on its sign. A `reversal`
is a credit whose whole purpose is to undo a debit. So no mapping from kind to
side is even correct — and worse, a hard-coded list of kinds means a **sixth kind
from a newer server disappears from both filters**, which is a silent hole in the
one screen an employer opens to reconcile money.

`isCredit` — `amountCoins > 0` — puts every entry on exactly one side, forever,
including kinds that do not exist yet. Two tests pin it: a reversal files under
"topped up", and an unknown `promotional_grant` files under it as well.

The general shape: when a filter's two halves are really about a **property** of
the row, filter on the property. A list of type codes is a filter that needs
maintaining every time the server learns a new word.

### 2026-08-19 - A detail screen does not always need to refetch
E-53 takes the ledger entry as a constructor argument instead of fetching it by
id, and there is no `GET /wallet/transactions/{id}` to fetch from.

That is not a shortcut. The only reason a detail screen normally refetches is that
the copy in the list might be stale — and a ledger entry **cannot** be: three
database triggers refuse `UPDATE`, `DELETE` and `TRUNCATE` on that table (BR-24).
Immutability upstream removes the need for freshness downstream.

Worth checking for elsewhere before adding an endpoint: if the record is
append-only, the list already has the truth.

### 2026-08-19 - Renamed to JobBridge, and where the old name legitimately stays
The product is **JobBridge**. Renamed the same day: launcher name and in-app title,
Android `applicationId` (`com.jobbridge.app` + `.dev` / `.staging`), Android
`namespace`, the Kotlin package and its directory, and the Dart package
(`headhunter_app` → `jobbridge_app`, which rewrote imports in 136 files).

**Deliberately not renamed**, so nobody "finishes the job" later and breaks things:

- **Repository folders** — the owner's call, and they are not user-visible.
- **`headhunter-backend` in doc comments** — that repository really is called
  that. Every `Mirrors …Dto in headhunter-backend` comment is correct as written.
- **`docs/SPEC.md` and the design document** — client deliverables that carry the
  old name. Regenerating SPEC.md from a renamed .docx is the client's move, not
  ours, and the two repos' copies must stay byte-identical.
- **`hh.qitmir.uz`** and `api.staging.headhunter.uz` — infrastructure, and the
  staging host deliberately does not exist.

So: a `headhunter` in a path or a backend reference is **correct**. A `headhunter`
in an application id or a Dart import is a leftover.

The rename was only possible because **nothing has been published**. An
`applicationId` is a store identity: after the first Play upload it is fixed, and
changing it means a new listing with no upgrade path for installed users.

**How it was verified, because "it compiled" proves almost nothing here.** A
successful build does not prove the id changed, and the one failure mode that
matters — `namespace` and the Kotlin package disagreeing — surfaces as a runtime
`ClassNotFoundException` on launch, not as a build error. Two checks settle it
without installing anything:

```powershell
# the id Gradle actually stamped
Get-Content build\app\outputs\apk\development\debug\output-metadata.json

# the id, the launcher label and the resolved activity, from the APK itself
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.0.0\aapt2.exe" dump badging `
  build\app\outputs\flutter-apk\app-development-debug.apk
```

For this rename they reported `com.jobbridge.app.dev`, `application-label:
'JobBridge Dev'` and `launchable-activity: com.jobbridge.app.MainActivity` — the
third being the one that proves the namespace and the Kotlin package agree.

Note that Gradle cannot run inside this project's agent sandbox at all: it fails in
about a second with `java.io.IOException: Unable to establish loopback connection`,
before compiling anything. That is the environment, not the build — an Android
build has to be run from a normal shell.

### 2026-08-19 - A stale google-services.json is better than a hand-edited one
The rename left `android/app/google-services.json` listing the old package names.
The tempting fix — search-and-replace `package_name` — is the wrong one.

Firebase issues a `mobilesdk_app_id`, an `api_key` and a `client_id` **per package
name**. Editing only the package name produces a file the Gradle plugin happily
accepts, and which then fails on the device when it registers a token against an
app id that does not exist. The symptom is "notifications don't arrive" — a runtime
mystery instead of a build error.

Left stale, it fails at exactly the right moment and says exactly what is wrong:
the Google Services plugin refuses the build with `No matching client found for
package name 'com.jobbridge.app.dev'`. Since the plugin is not applied until M9,
nothing is broken in the meantime.

**The general rule: a generated credentials file is not text to be edited.**
Regenerate it from the console that issued it. And when a config will be wrong
later, prefer the form that fails loudly at the point of use over the form that
looks right.

Two things that surprised me and are worth remembering: SHA certificate
fingerprints are stored **per Android app**, so new apps start with none even in
the same project; and one `google-services.json` download contains **every** app in
the project, which is why a single file covers all three flavors.

### 2026-08-19 - The design document's canvas colour is not the app's background
`scaffoldBackgroundColor` is `sand100` = `#EFEBE4`. That colour is genuinely in
the palette — the foundations page swatches it as sand-100 — but in the design
*document* it is also `body{background:#EFEBE4}`, the paper the artboards sit on.

Every phone frame in the document draws its screen on `#F7F8FA` instead: 30 uses
against 4 for `#EFEBE4`, and of those 4 the only one inside an artboard is the
swatch itself. So the app looks to have adopted the canvas colour as its
background — warm beige where the design is cool grey.

**Not changed yet**, deliberately: it repaints every screen, so it wants its own
commit and a device check rather than a quiet edit inside a feature. Recorded in
TODO.md. The lesson generalises to any `.dc.html` import: **a colour's presence
in the file is not evidence of its role.** Check whether it appears inside an
artboard or around one, and count.

### 2026-08-19 - A designer's copy beats an invented translation, always
The wallet shipped with `walletCoins` reading "2 tanga" in Uzbek and "2 монеты"
in Russian. Both were mine. The design writes **"2 Coin"** — the unit name left
untranslated, as a service unit rather than a currency.

Round 1's handoff had already said who owns what: design owns the Uzbek Latin
source and the English reference, and **uz-Cyrl and ru need certified translation
from the client**, because "machine translation of recruitment and legal-consent
strings is a liability, not a shortcut". A money unit is squarely in that class,
and inventing `монета` was exactly the shortcut being warned against.

The rule: when a design document contains the string, use the design's string.
Where it does not, and the string is money, legal or consent copy, leave the
client's obligation visible rather than filling it in plausibly.

### 2026-08-19 - Reflowing comments by line orphans words; reflow paragraphs
Fixing 80-column lints with a per-line wrapper produced comments ending in single
words — "deciding", "price", "alone", "of". Wrapping a line in isolation cannot
know the next line continues the sentence.

Worse, the same script silently disabled a lint: `hh_icons.dart` opens with a
prose paragraph followed by `// ignore_for_file: lines_longer_than_80_chars`, and
the wrapper folded the directive into the prose. Analyze then reported four
*pre-existing* long lines as new — the file's SVG path data, which that directive
exempts on purpose.

Two rules if this is ever automated again: **reflow paragraphs, not lines**
(group consecutive same-marker comment lines, join, rewrap), and **never let a
comment reflow touch a line matching `ignore` or `ignore_for_file`** — those are
code wearing a comment's clothes. Markdown tables and lists need the same
exemption; they are structure, not prose.

### 2026-08-19 - Gate a feature on a code the old server cannot send, not a flag
The owner overruled the decision above and asked for the unlock to be merged now,
with the backend catching up. The concern was real — a button that debits two
Coins and reveals nothing — but it did not need a flag to solve.

`expose()` answers `no_interaction` today. Once it reads the entitlement it will
answer `unlock_required` instead. So the unlock control is offered on
`unlock_required` **and nothing else**: the purchase path is complete, tested and
merged, and it is unreachable until the server can honour it. It turns itself on
when the gate deploys, with no client release.

Why this beats the obvious alternative: a build-time flag is a code path that
takes money, enabled by a constant somebody has to remember to flip at the right
moment — and forgetting in either direction is a bug (dead feature, or a paywall
that charges for nothing). The reason code is not a switch at all. It is the
server telling the client what it is capable of, which is information the client
was already reading.

**The general shape**: when a client must ship ahead of its server, look for a
value the new server sends and the old one cannot. Gate on that. If no such value
exists, ask for one — it is a smaller request than a coordinated release, and it
is self-documenting.

Pinned by a test that funds a wallet with 500 Coins against `no_interaction` and
asserts both no button and no request. Verified by mutation: loosening the gate to
include `no_interaction` fails exactly that test and one other.

### 2026-08-19 - A code whose meaning changed wants a new code, not new copy
The plan had said M7's shipped exposure copy was "now wrong" and would have to be
rewritten when the wallet landed, losing the mutation tests pinning it. That
turned out to be the wrong frame.

`no_interaction` used to mean "wait for an application"; under a paid gate the
remedy becomes "pay". The instinct is to rewrite that code's sentence. But the
client answered the §11.1 question leniently — an application still opens contact
— so the old sentence is **still true wherever it is still sent**. Adding
`unlock_required` beside it left the original six codes untouched, kept every
existing test, and made one build correct against two servers at once.

The rule: if a reason code's *remedy* changes, that is a different reason, so give
it a different code. Rewriting the old one's copy destroys the ability to serve
both servers and quietly invalidates whatever pinned it.

### 2026-08-19 - A spec that argues with itself answers its own question
Follows the entry below, and is the part worth remembering: the §8.2 question was
settled not by the server but by **reading the rest of the specification.**

§8.2 said an employer must hold a Candidate Unlock and "an invitation **may then**
be attached to an active vacancy". Two other places disagree:

- **§7.3** lists the candidate card's actions as "View profile, Save, and Send
  invitation" — two of which are unambiguously free — in the sentence immediately
  after the one saying phone, e-mail and CV are locked. The section separates the
  locked *data* from the free *action*.
- **§7.4**, the client's own worked example, fills **20 openings** by sending
  invitations. Filling 20 takes far more than 20 invitations; at 2 Coins each that
  is over a million som before a single reply, and the 10-Coin registration bonus
  covers five people. The example the client wrote does not work under the strict
  reading of the sentence the client also wrote.

So the question stopped being "which document wins, spec or code" and became "one
word against two sections and a running server". The client confirmed the lenient
reading in a sentence.

**The habit worth keeping: before escalating a contradiction between the spec and
the code, look for the spec contradicting itself.** A revised document has new
prose stitched into old, and the seam is usually where a sentence lists four
things and quietly acquires a fifth. §8.2's sentence lists contact, CV, chat and
interview — all genuinely gated — and the invitation got swept in beside them.

The follow-on is also worth recording: **the answer created a new problem the spec
had no rule for at all.** Sending free and uncapped let a verified employer send
an unbounded number, and neither §8.2 nor the service had a limit. The remedy is a
cap, and the cap belongs to the server rather than to Dart — the client said extra
invitations may be purchasable later, and a quota that can be bought is a balance
(§12.3.1). So the client renders `{remaining, limit, resetsAt}` and holds no
number: `limit` is the *effective* total, deliberately not free-plus-purchased, so
a future purchase raises it with no client release and no arithmetic here.

**An absent quota must block nothing.** A 404 means "this server has no cap", and
a form disabled by a counter that failed to load would refuse sends the API
accepts — a false refusal, not a cautious one. Same discipline as gating the unlock
on a reason code: render what the server can say, invent nothing.

### 2026-08-19 - A structured error's figures are in `details`, not at the top
The backend's 409 for the invitation quota carries `limit` and `resetsAt` so a
screen can refresh its counter without a second request or a regular expression
over localized prose. The client's first attempt read them as `data['limit']` and
`data['resetsAt']`, which would have compiled, passed every test with a fixture
the client wrote itself, and silently produced nulls against the real server.

The body is `{statusCode, code, message, details: {...}}`, and the nesting is
deliberate: `localized.exception.ts` says a key spread beside `statusCode`,
`code` or `message` would eventually collide with one of them, and that `params`
stay out of the body entirely because they are written to read well inside a
sentence rather than to be consumed.

Two things to carry:

1. **Read the backend's exception filter, not the throw site**, when parsing an
   error body. The throw site shows *which* figures exist; only the filter shows
   *where* they land.
2. **A fixture the client author invents cannot catch this class of bug.** The
   test passes because the fake produces the shape the parser expects. This one
   was caught by reading the server, which is the only place the shape is decided.

### 2026-08-19 - When the spec and the server disagree about money, ask
§8.2 as revised reads "the employer must have a Candidate Unlock entitlement for
that candidate. An invitation **may then** be attached to an active vacancy or
sent as a general work invitation." The word "then" makes the unlock a
precondition of *sending an invitation*.

The backend does not implement that, and not by omission: its integration tests
assert the looser behaviour deliberately. A verified employer may invite any
search-visible candidate for free; a merely `sent` invitation answers
`exposureReason: unlock_required` and reveals nothing; **acceptance** is what
turns the code into `accepted_invitation` and opens the phone, e-mail and CV.

The tempting move is to implement the spec — it is the client's own document, and
the strict reading is the cautious one. **It is the wrong move here, twice over.**
A client that gates on the unlock while the server does not tells an employer to
pay for something the API would have accepted free: not a conservative failure, a
false one. And deciding *when money must be spent* is exactly what §12.3.1 puts on
the server, for the same reason it forbids computing a total — the rule has to
live in one place, and that place is the side that owns the ledger.

So the client built the half the two agree on (the candidate's inbox, which is
unaffected either way), left the employer's send screen for after the answer, and
recorded the question in PLAN.md next to the §11.1 one it resembles. The
underlying product question is real and worth the client's attention: **is an
invitation a contact action, or a request to make contact?** The server implements
the second, and it is the better answer — an employer should not pay to be
declined, and a candidate's consent is a better gate on their own phone number
than the employer's wallet is.

Generalises past this case: **a spec sentence and a running endpoint that
disagree are a question, not a bug to be fixed in the client.** Build what they
agree on, name the disagreement where the decision-maker will see it, and do not
resolve it by writing the stricter rule into Dart where it cannot be changed
without a store release.

### 2026-08-18 - Money on screen must never be arithmetic the client did
§6.6 makes the Coin price and the unlock cost server configuration, and today
`balanceValueUzs == balanceCoins * coinPriceUzs` exactly. That coincidence is a
trap: the obvious "simplification" is to drop the server's figure and multiply,
and it passes every test written against realistic data.

The fixture therefore makes them **disagree** — 8 Coins, 10,000 a Coin, and a
balance value of 75,000 — which is the `rank`/`sortOrder` rule above applied to
money. Verified by mutation: replacing the read with the multiplication fails
exactly one test, the one named for it.

The second half of the same rule is the ledger. Every entry carries the balance
the server recorded after it, and the temptation is to accumulate down the list
instead. That is wrong *by construction* rather than merely fragile: the client
only ever holds one page, so page two's running total would start from nowhere.
The test fixture gives balances that are not a running sum of their own amounts,
so an accumulating implementation cannot pass it.

### 2026-08-18 - `scrollUntilVisible` does nothing when the list is not lazy
Tapping "Show more" under a full page of ledger entries missed: the tap landed at
y=2453 in an 800-high viewport. `ensureVisible` did not help either, and the two
failures have different causes worth telling apart.

`ListView(children: [...])` builds **every** child immediately, unlike
`ListView.builder`. So the finder matches from the first frame — and
`scrollUntilVisible` stops as soon as the finder matches, which is before it has
scrolled anything. It is built for lazy lists, where "not found" *is* the signal.

`ensureVisible` is the right call here, but it only schedules the scroll; without
a `pumpAndSettle` the frame never advances and the tap still lands off-screen.
`ensureVisible` **then** `pumpAndSettle` is the working pair.

### 2026-08-10 - A `Text` in a `Row` overflows; it does not wrap
`HhRemovableChip` painted a striped overflow bar the first time a filter chip
carried a long label. `Row` gives an unconstrained child its natural width, and
`Text` has no reason to shrink - so the label ran past the chip and pushed the
remove control off screen, which is the one part of that component that must
never be lost. Fixed with `Flexible` + `TextOverflow.ellipsis`.

Worth knowing because **the same label is longer in Russian and Uzbek than in
English**, so this class of bug is invisible when a screen is built and read in
one language. A widget test found it in seconds; `flutter analyze` cannot.

Two consequences: prefer short chip labels (the group, not the form label - the
builder is where the exact wording belongs), and treat any `Text` inside a
`Row` as needing `Flexible` unless its width is provably bounded.

**2026-08-19, the same bug with a different answer.** The invitation card's header
was `Row(badge, Spacer, timestamp)` and overflowed by 32pt at 360 wide:
"Details requested" plus `2026-08-18 09:30` needs 330 of the card's 298. Here
`Flexible` + ellipsis is the *wrong* fix, because the only two candidates for
truncation are both unshrinkable in principle — a badge is icon **plus word**, so
a clipped word puts the state back on colour alone, and a truncated date is worse
than no date. So the header became a `Wrap`: both fit on one line when they fit,
and the timestamp drops to a second line when they do not.

The general rule: **when nothing in a `Row` may shrink, the row is the wrong
widget.** Reach for `Wrap` before deciding which piece of information to damage.
Pinned at 320pt × 2.0x — the design's own QA case — rather than at 360, because
the width that happened to fail is not the width worth guarding.

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
