# headhunter-app - TODO

Working checklist. Milestone definitions and ordering are in [PLAN.md](PLAN.md);
design rationale in [ARCHITECTURE.md](ARCHITECTURE.md).

Convention: `[ ]` open · `[x]` done · `[~]` in progress · `[?]` blocked on a
decision or on the backend.

---

## Blocked on someone else

- [x] ~~**Design files**~~ - **shipped 2026-08-04** as a Claude Design project
      (`Universal HeadHunter.dc.html`). Tokens, the component library and the 11
      required UI states are now implemented under `lib/src/core/design/`; see
      the Design system section below for what is done and what the design does
      not yet answer.
- [?] **Auth spec change needs client sign-off** — BR-01 and UAT-01 name "phone
      and OTP"; the MVP signs in with Telegram, which satisfies the *intent* (a
      verified phone) by another route. Both need re-wording in writing, or the
      UAT-01 walk-through fails on a technicality.
      See [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md) §9 for the three
      questions to put to them.
- [?] **Dictionary contract** - backend M2 must publish the dictionary endpoints
      and version/ETag scheme. *Blocks every picker.*
- [?] **Category field-schema contract** - the shape the server returns to drive
      dynamic forms (ARCHITECTURE.md §6). Agree it with the backend before M3.
- [-] ~~**Push provider** (FCM vs FCM+APNs)~~ - **no longer blocking.** Client
      deferred notifications to the last feature milestone (2026-08-04), so this
      decision is not needed until M9 opens. Backend recommends FCM-only with an
      APNs key in Firebase; still needs an Apple Developer account when we get
      there.
- [?] **Time zone policy** for interview display (§8.3). *Blocks M8.*
- [?] **App icons and launch screen** - still Flutter defaults.

## M0 - Foundations *(done)*

- [x] Flutter 3.44.8, Riverpod 3 + go_router + dio, `com.headhunter.app`
- [x] Feature-first `lib/src/{core,features,shared}` layout
- [x] `ApiException` mapping; repositories never leak `DioException`
- [x] Riverpod auto-retry disabled (endless-spinner fix) + error-first rendering
- [x] `INTERNET` permission in the main manifest for release builds
- [x] Health slice verified on an emulator against the live API
- [x] CI: analyze + test + debug APK; iOS `--no-codesign` build

## Design system *(done - implemented from the shipped design)*

Lives in `lib/src/core/design/`; import the `design.dart` barrel. Verified on an
emulator against the design document, with 18 tests pinning the rules.

- [x] Tokens: `HhColors`, `HhTypography`, `HhSpace`/`HhRadius`/`HhSize`/
      `HhElevation`/`HhDuration`/`HhBorders`
- [x] Golos Text bundled (`assets/fonts/`, OFL included) - one family covering
      latin, latin-ext, cyrillic and cyrillic-ext
- [x] `HhTheme.light` - and deliberately **no dark theme**, see MEMORY.md
- [x] Icon set: 36 glyphs transcribed as SVG paths, rendered via `flutter_svg`
- [x] Buttons (5 variants + loading + disabled), text fields (5 states),
      chips, segmented control, checkbox/radio/switch rows
- [x] Badges (5 tones, icon + word), step indicator, completeness ring,
      stage timeline
- [x] Vacancy / candidate / application cards, bottom nav (3 role sets)
- [x] All 11 required UI states
- [x] `DesignGalleryScreen` at `/_design`, reached from the developer-tools
      screen at `/_dev`. Both are absent from production builds entirely
- [x] Design round-1 answers applied: the twenty-state vocabulary with its glyph
      rule, always-on category band, conditional-field rail, two-line nav at a
      constant 70pt, min-52 control height, 2.0x text-scale clamp, derived
      skeletons
- [x] Verified at the design's QA case — 320pt at 2.0x, no overflow anywhere
- [ ] **Category photography** - five 3:2 masters (1620x1080), one per §2.1
      category, subject inside the middle 60% vertically so one file survives
      both the 4.15:1 card crop and the 2.6:1 hero crop. Stock, art-directed by
      the designer. The tint fallback ships until then.
- [ ] **Three empty-state illustrations** - two-colour line work, navy +
      turquoise; the designer produces these
- [ ] **App icon and launch screen** - spec is agreed (navy ground, mark at 56%,
      Android adaptive at the 66% keyline, inverted plate on the launch screen)
      but the mark itself is placeholder-grade and **blocked on the client logo**
- [ ] Nav label at 320pt x 2.0x: `Bosh sahifa` cannot fit two lines across five
      tabs. Per the design, the remedy is a shorter string or a soft hyphen
      (`hhSoftHyphenate`), which is the designer's call - raised in
      docs/design-feedback.md
- [ ] Re-check every component at large system font scale as screens land (M11)

## M0.5 - App shell *(done bar two carried items)*

Everything below is implemented and verified on an emulator. Two items are
carried forward and neither blocks M1: **bottom sheets** (design-system gap,
first needed by the M2 pickers) and **iOS flavor schemes** (needs a Mac).
Installing `AuthInterceptor` stays blocked on the backend's auth contract.

### Localization *(done)*
- [x] Add `flutter_localizations` + `intl`; enable `gen-l10n` in `pubspec.yaml`
      — note `intl` is now pinned to **exactly 0.20.2**, see the pubspec comment
- [x] `lib/l10n/app_uz_Latn.arb`, `app_uz_Cyrl.arb`, `app_ru.arb`, `app_en.arb`
      — **plus `app_uz.arb`**, which gen-l10n requires as a base whenever
      script-coded locales exist. It mirrors Latin; a test pins them together.
- [x] `supportedLocales` using `Locale.fromSubtags` with `scriptCode` for Uzbek
      — in `AppLocale`, **not** the generated list, which drops script codes
- [x] **Never key on `locale.languageCode` alone** - it collapses the two Uzbek
      scripts. Use the full tag for ARB lookup, `x-lang`, and cache keys.
- [~] Locale controller: local persistence pre-auth, server sync post-auth
      — local half done; the server push is a marked seam in `select()` waiting
      on the M1 profile endpoint
- [x] `x-lang` dio interceptor — reads the locale per request, installed in
      `dio_provider.dart`
- [x] Fallback chain `uz-Cyrl → uz-Latn → en`; a missing key must never render
- [x] CI check: all ARB files share exactly one key set —
      `test/core/l10n/arb_parity_test.dart`

### Flavors and config *(done)*
- [x] development / **staging** / production flavors — `core/config/app_flavor.dart`
      plus `productFlavors` in `android/app/build.gradle.kts`. §12.1 calls the
      middle one "testing"; AGP rejects any flavor name starting with `test`, so
      both sides say `staging` — see MEMORY.md for that and two more Android
      flavor traps
- [x] Per-flavor API base URL, app id suffix, display name — all three install
      side by side (`.dev` / `.staging` / no suffix). `app_flavor_test.dart` reads
      the Gradle file and the manifest and asserts they agree with `AppFlavor`
- [x] `--flavor` is now **required** on every run/build command; README and
      CLAUDE.md updated
- [x] Verify no secrets are compiled in (§12.5) — `AppConfig` carries only
      hostnames and switches, and says why in a comment: `--dart-define` values
      are recoverable from an APK with `strings`
- [-] ~~**iOS flavors**~~ — **iOS is out of scope** (owner direction 2026-08-05).
      Android only until asked otherwise; the iOS CI job is now
      `workflow_dispatch`-only. See MEMORY.md.

### Auth plumbing
- [x] `flutter_secure_storage` for tokens - **not** `shared_preferences`
      — `core/auth/token_store.dart`; iOS uses `first_unlock` accessibility so a
      locked device can still refresh
- [x] Auth interceptor attaching the access token
- [x] **Single-flight refresh**: concurrent 401s wait on one refresh, then replay.
      Write the test - this is the classic bug, and the backend rotates refresh
      tokens with reuse detection, so a double refresh logs the user out.
      — 8 tests in `test/core/network/auth_interceptor_test.dart`. The backend
      confirmed the server half: reuse revokes the **whole session family**.
- [~] **Install `AuthInterceptor` into `dio_provider`** — **unblocked.** The
      backend's `src/modules/auth` already implements `POST /auth/refresh` with
      rotation and reuse detection, returning `AuthTokensResponseDto`. It was
      never in `docs/API_CONTRACTS.md`, which is why this was recorded as blocked;
      the code is the contract. Remaining work is the refresh callback plus
      `interceptors.add`, and `SessionController.expire()` is already the
      destination for `onAuthFailure`.
- [x] Idempotency-key interceptor with **persisted** keys (regenerating per
      attempt provides no protection) — installed; header name
      `Idempotency-Key` still needs confirming with the backend before M3 ships
      a write path
- [x] Session state and controller — `core/auth/session_state.dart`,
      `session_controller.dart`. The **role model is real** (granted set, active
      choice, fallback when a role is revoked, persisted active role);
      **acquiring** a session is the M1 seam, and until then
      `signInAsDevelopmentRole` provides one, gated on the flavor
- [x] `SessionController.expire()` is the destination for
      `AuthInterceptor.onAuthFailure`, so that callback now has a home for when
      the interceptor is installed

### Shell and design system
- [x] `StatefulShellRoute` skeleton, one shell per role — all three registered at
      once, each owning a path namespace (`/candidate`, `/employer`, `/admin`), so
      leaving one shell disposes its branch navigators and navigation state cannot
      leak across a role switch
- [x] Redirect chain: unrestored → splash; unauthenticated → onboarding; blocked →
      notice (BR-10, **ahead of** role selection); no role → role selection;
      ungranted role → own shell; granted-but-inactive role → **activate it**
      (the deep-link rule of ARCHITECTURE.md §3)
- [x] Route path constants in one place — `core/router/routes.dart`;
      `routes_test.dart` asserts every shell path matches its role's prefix,
      because the constants are literals and nothing else connects them
- [x] Role switching — `switchRoleAndGo`. **`switchRole` alone does not
      navigate**, and that is deliberate: see MEMORY.md, it was a real bug found
      on a device with a green analyze and 129 passing tests
- [x] Session state: granted roles, active role, account status
      (active / restricted / blocked). `restricted` deliberately does **not**
      redirect — it gates individual actions
- [x] Blocked-account screen with the admin's reason shown verbatim (BR-10)
- [x] Developer-tools screen at `/_dev` with sign-in scenarios for every branch of
      the chain, the role switcher and live variant switching. Underscore routes
      are absent entirely from production builds
- [x] Colours, typography, spacing; loading / empty / error state primitives
      *(shipped with the design system)*
- [x] Buttons, text fields, chips *(shipped with the design system)*
- [x] Font-scale tolerance check on the primitives *(design system, 2.0x clamp)*
- [ ] **Bottom sheets** — the only design-system primitive still missing.
      `HhRadius.sheetTop` and `HhElevation.sheet` exist and the theme styles
      `BottomSheetTheme`, but there is no `HhSheet` component. First needed by the
      M2 pickers and the M6 filter sheets
- [ ] Verified on the emulator: onboarding → dev tools → all three shells, live
      uz-Cyrl switch, BR-10 notice, session restored across a cold start, and
      `Foydalanuvchilar` / `Фойдаланувчилар` wrapping at its soft hyphen without growing the 70pt bar

## M1 - Onboarding and session

**Sign-in is Telegram, not OTP** — client direction 2026-08-05. Research and the
full implementation plan: [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md). OTP is
**deferred, not dropped**: BR-01 requires a verified phone number, so OTP remains
the fallback for a user who declines to share theirs with Telegram. The backend's
OTP module stays as it is.

Three of these landed early with the shell, because the redirect chain needed
working destinations rather than dead ends.

- [x] Language picker shown **before** registration — live on the onboarding
      screen, all four variants, persisted locally
- [ ] Terms/privacy acceptance, shown **before** the login call — Telegram does
      not collect consent for us
- [ ] **Log in with Telegram** — OIDC via the official native SDKs; `phone` scope
      returns a Telegram-verified number and so satisfies BR-01 with no SMS cost.
      Three sub-decisions are called out in TELEGRAM_LOGIN.md §4.1, §4.2 and §9
- [ ] Client half of `POST /auth/telegram` — returns the **existing**
      `AuthTokensResponseDto`, so session handling and `isNewUser` routing need no
      change
- [-] ~~OTP screen: resend timer, attempt feedback from server config~~ —
      **deferred** to the no-verified-phone fallback path. Backend endpoints exist
      (`/auth/otp/send`, `/resend`, `/verify`); only the client screens are unbuilt
- [?] **Telegram bot registration per flavor** — each of the three application
      ids needs its own BotFather registration, with every signing SHA-256 we use
      (debug, upload, Play App Signing). Separate bots per environment. Fails at
      runtime in one environment only, so it is easy to miss —
      TELEGRAM_LOGIN.md §7
- [-] ~~iOS deployment target 13.0 → 15.0 for the Telegram iOS SDK~~ — moot,
      **iOS is out of scope**. Recorded because it is the first thing that will
      need doing if that reverses.
- [~] Role selection (candidate / employer / both) → correct onboarding — the
      **mechanism** is done (grants the roles, router enters that shell;
      administrator deliberately not offered, since §10 grants it). The copy and
      the per-role explanations are M1's
- [~] Role switcher in the profile area — `switchRoleAndGo` is done and exercised
      from `/_dev`; it needs its product entry point once the profile area exists
- [ ] Sessions screen: list, sign out, terminate all
- [x] Blocked-account notice explaining the restriction (BR-10) — reason shown
      verbatim, sign-out available; verified on device
- [ ] Account deletion request with confirmation
- [ ] Real session acquisition, replacing `signInAsDevelopmentRole` *(blocked on
      the backend's auth contract — see Auth plumbing above)*
- [ ] Test: UAT-01 in each of the four variants; locale retained after registration

## M2 - Dictionary cache and pickers

- [ ] Versioned cache keyed by `(type, fullLocaleTag)`; refetch on version change
- [ ] JSON file cache in app support dir (sqlite only if a screen needs to *query*)
- [ ] Searchable single-select picker
- [ ] Multi-select picker with match-all / match-any where §7.1 needs it
- [ ] Cascading region → district picker
- [ ] Dictionary + level picker (skills, languages with A1–C2 / native)
- [ ] Resolve labels by ID so deactivated/historical items still render
- [ ] Test: selection survives a locale switch (IDs stable, labels change)

## M3 - Candidate profile

- [ ] Form engine: text, number, money range, date, date range, single/multi
      dictionary select, dictionary+level, switch, file
- [ ] Render required-ness from the server schema, never from the widget
- [ ] Profile sections of §5.1
- [ ] Simplified experience entry for informal/seasonal work
- [ ] Completeness percentage + missing-field list with direct edit links
- [ ] Privacy control: searchable / hidden / visible-after-apply (UAT-12)
- [ ] Last-meaningful-update display
- [ ] CV upload with progress, cancel, failure reason, retry (UAT-03)
- [ ] Optional certificates / work evidence
- [ ] Test: form adapts by category and irrelevant fields are not mandatory

## M4 - Employer profile

- [ ] Company and individual employer forms
- [ ] Verification submission + evidence upload
- [ ] Status display with admin reason and changes-required path
- [ ] BR-03: explain what blocks invitations / vacancy submission

## M5 - Vacancy management

- [ ] Vacancy create/edit across all six §6.3 categories via the form engine
- [ ] Structured requirements incl. mandatory-vs-preferred languages
- [ ] Status display + employer-available transitions (§6.4)
- [ ] Moderation rejection reason shown to the employer
- [ ] Worker count `>= 1` (BR-05)
- [ ] Age/gender fields warn about justification + moderation (BR-12)
- [ ] Seasonal/agricultural flow (UAT-10)
- [ ] Employer dashboard widgets (§6.2)

## M6 - Discovery and applications

- [ ] Candidate home: recommended, recent, saved, completion prompt
- [ ] Vacancy filters per §5.5
- [ ] Vacancy details + verification badge; Apply / Save / Share / Report
- [ ] Apply button reflects BR-07 (one active application per vacancy)
- [ ] Application list with all §8.1 stages; withdraw where permitted
- [ ] Deadline-expired / closed vacancy rendering (UAT-15)
- [ ] Employer: applications per vacancy, filters, stage moves, internal notes,
      hired-vs-required counts
- [ ] Idempotency key on apply

## M7 - Candidate search

- [ ] Filter builder for all §7.1 groups
- [ ] Count before results; render "200+" when inexact
- [ ] Removable filter chips; reset all; edit one
- [ ] Result list with §7.3 sorts and candidate cards
- [ ] **No phone numbers on candidate cards** (BR-09, §11.1) - assert in a test
- [ ] Prefill from vacancy, still editable (UAT-06)
- [ ] Save candidates, shortlists, private notes
- [ ] Invitations + response tracking (UAT-07); general invitations
- [ ] Persist last search configuration locally

## M8 - Chat and interviews

- [ ] Conversation list + thread; text and approved attachments
- [ ] Sent / delivered / read indicators
- [ ] Report and block; read-only closed conversations
- [ ] Interview display by type + confirm / request another time
- [ ] Idempotency key on message send
- [ ] **Deep links switch role before navigating** where required *(moved here
      from M9 - routing infrastructure, not a notification feature)*

## M9 - Notifications *(deferred to last - client direction 2026-08-04)*

Runs after M10, not after M6. No Firebase package enters `pubspec.yaml` before
this opens. Deep links moved to M8.

- [ ] In-app list, unread badge, mark read *(no push dependency; can be pulled
      forward at no cost if the client wants notification history earlier)*
- [ ] Push registration and foreground/background handling
- [ ] Preferences; security/account categories not offered as disableable

## M10 - Admin module

- [ ] Admin shell behind the admin role
- [ ] Dashboard counters (§10.1)
- [ ] Employer verification + vacancy moderation with mandatory reasons
- [ ] Complaint queues
- [ ] User search + warn/restrict/block/unblock with reason (UAT-14)
- [ ] Dictionary management with four localized labels + skill merge, designed for
      a phone (there is no web panel)

## M11 - Hardening

- [ ] Small-screen and large-font-scale pass over every screen
- [ ] Cached primary screens open without blocking; loading states complete
- [ ] Offline state explicit; retry safe; no duplicate writes
- [ ] Crash reporting + structured logging, no sensitive data
- [x] **Android release signing config** — `android/upload-keystore.jks` (RSA
      2048, valid to 2053, gitignored) read via `android/key.properties`; falls
      back to debug signing with a loud warning when absent, so a fresh clone
      still builds. Verified: the release APK is signed with SHA-256 `7C:1C:…`,
      not the debug key. See [docs/RELEASE.md](docs/RELEASE.md)
- [?] **Register the release SHA-256 with BotFather** and fill
      `AppFlavor.production.telegramRedirectUri` — until then Telegram login is
      unavailable in a downloaded APK, by design. RELEASE.md §4
- [ ] App icons and launch screen
- [ ] Walk all 15 UAT scenarios and keep the evidence

---

## Standing rules

Applies to every task above:

- New string → keys in **all four** ARB files, or CI fails.
- New picker → binds a dictionary **ID**, displays a label.
- New non-idempotent write → persisted idempotency key.
- New mutation → list its invalidations next to it.
- `flutter analyze` clean and `flutter test` passing before commit; commit the
  `build_runner` output.
- Do not bump packages casually - the pins in `pubspec.yaml` are load-bearing
  (see [CLAUDE.md](CLAUDE.md)).
