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
- [?] **Dictionary contract** - backend M2 must publish the dictionary endpoints
      and version/ETag scheme. *Blocks every picker.*
- [?] **Category field-schema contract** - the shape the server returns to drive
      dynamic forms (ARCHITECTURE.md §6). Agree it with the backend before M3.
- [?] **Push provider** (FCM vs FCM+APNs) - shared decision with the backend.
      *Blocks M9.*
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
- [x] `DesignGalleryScreen` at `/_design`, reachable from a debug-only app-bar
      action on the health screen
- [ ] Category illustrations and empty-state artwork - the design marks these as
      image slots; real assets still needed from the client
- [ ] App icon and launch screen
- [ ] Re-check every component at large system font scale (M11)

## M0.5 - App shell *(next)*

### Localization
- [ ] Add `flutter_localizations` + `intl`; enable `gen-l10n` in `pubspec.yaml`
- [ ] `l10n/app_uz_Latn.arb`, `app_uz_Cyrl.arb`, `app_ru.arb`, `app_en.arb`
- [ ] `supportedLocales` using `Locale.fromSubtags` with `scriptCode` for Uzbek
- [ ] **Never key on `locale.languageCode` alone** - it collapses the two Uzbek
      scripts. Use the full tag for ARB lookup, `x-lang`, and cache keys.
- [ ] Locale controller: local persistence pre-auth, server sync post-auth
- [ ] `x-lang` dio interceptor
- [ ] Fallback chain `uz-Cyrl → uz-Latn → en`; a missing key must never render
- [ ] CI check: all four ARB files share exactly one key set

### Flavors and config
- [ ] development / testing / production flavors
- [ ] Per-flavor API base URL, app id suffix, display name
- [ ] Verify no secrets are compiled in (§12.5)

### Auth plumbing
- [ ] `flutter_secure_storage` for tokens - **not** `shared_preferences`
- [ ] Auth interceptor attaching the access token
- [ ] **Single-flight refresh**: concurrent 401s wait on one refresh, then replay.
      Write the test - this is the classic bug, and the backend rotates refresh
      tokens with reuse detection, so a double refresh logs the user out.
- [ ] Idempotency-key interceptor with **persisted** keys (regenerating per
      attempt provides no protection)

### Shell and design system
- [ ] `StatefulShellRoute` skeleton, one shell per role
- [ ] Redirect chain: unauthenticated → onboarding; no role → role selection;
      blocked → notice screen; ungranted role → default shell
- [ ] Route path constants in one place
- [ ] Colours, typography, spacing; loading / empty / error state primitives
- [ ] Buttons, text fields, chips, bottom sheets
- [ ] Font-scale tolerance check on the primitives

## M1 - Onboarding and session

- [ ] Language picker shown **before** registration
- [ ] Phone entry + terms/privacy acceptance
- [ ] OTP screen: resend timer, attempt feedback from server config
- [ ] Role selection (candidate / employer / both) → correct onboarding
- [ ] Role switcher in the profile area
- [ ] Sessions screen: list, sign out, terminate all
- [ ] Blocked-account notice explaining the restriction (BR-10)
- [ ] Account deletion request with confirmation
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

## M9 - Notifications

- [ ] In-app list, unread badge, mark read
- [ ] Push registration and foreground/background handling
- [ ] **Deep links switch role before navigating** where required
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
- [ ] **Android release signing config** (currently debug keys - must change
      before any store upload)
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
