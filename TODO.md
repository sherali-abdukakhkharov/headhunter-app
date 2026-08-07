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
- [x] ~~**Auth spec change needs client sign-off**~~ — **moot 2026-08-05.**
      Telegram login was deprecated the same day it was adopted and sign-in is
      phone + OTP again, which is what BR-01 and UAT-01 already say. Nothing to
      re-word and nothing to sign.
- [?] **SMS provider** — none is connected, so the backend issues a fixed
      `OTP_STATIC_CODE=666666` and no message is actually sent. Needs a provider
      (or Telegram Gateway at ~$0.01/code, see
      [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md) §2C) chosen and paid for.
      *Blocks UAT-01 on a real device with a real number, and blocks any
      production deploy — the backend refuses to boot with the static code set
      when `NODE_ENV=production`.*
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

**Sign-in is phone + OTP** (§4.1, UAT-01). Telegram login was adopted and then
deprecated on 2026-08-05; [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md) has the
reversal note and what of it still exists. Verifying a code makes the number
verified, so BR-01 needs no separate step.

Three of these landed early with the shell, because the redirect chain needed
working destinations rather than dead ends.

- [x] Language picker shown **before** registration — live on the onboarding
      screen, all four variants, persisted locally
- [x] Terms/privacy acceptance, shown **before** the send call — gates the
      button rather than being collected afterwards
- [x] **Phone entry** — `+998` prefix, nine digits, `UzPhone` owns the wire
      format so one number cannot reach the API in two spellings
- [x] **Code entry** — resend countdown driven by the server's
      `resendAvailableAt`, change-number, single-use code, server's localized
      refusal rendered directly
- [x] Client half of `/auth/otp/send`, `/resend` and `/verify` — returns the
      **existing** `AuthTokensResponseDto`, so session handling and `isNewUser`
      routing needed no change
- [ ] **Attempt feedback** — the server locks a code out after `OTP_MAX_ATTEMPTS`
      and says so, but the screen does not count down remaining attempts. Needs
      the count in the response before the client can show it
- [-] ~~Telegram bot registration per flavor~~ — moot with Telegram login
      deprecated. TELEGRAM_LOGIN.md §7 has it if that ever reverses.
- [-] ~~iOS deployment target 13.0 → 15.0 for the Telegram iOS SDK~~ — moot,
      **iOS is out of scope** *and* Telegram login is deprecated.
- [x] **Session survives a cold start** — `restore` exchanges the stored refresh
      token for a real session, so roles and account status come from the server
      rather than being guessed. Verified on device: force-stop, relaunch, land
      in the shell
- [x] **`AuthInterceptor` installed** — single-flight refresh on a 401, replay,
      and a separate bare client so the refresh call cannot re-enter it
- [x] Sign-out revokes the session server-side (`POST /auth/logout`),
      best-effort so a failed call still ends the local session
- [ ] **Offline cold start shows onboarding** — a refresh that cannot complete
      keeps the tokens (correct) but there is no "we cannot reach the server,
      retry" state, so the user sees sign-in and has no way to say *try again*.
      Needs a `SessionState` case; §12.4 asks for explicit offline state
- [ ] **Role switch does not tell the server** — `POST /auth/active-role`
      returns an access token carrying the new role, and the app does not call
      it. Harmless today because nothing is role-authorized yet; **it becomes a
      403 the moment M2+ adds an endpoint that checks the acting role**
- [~] Role selection (candidate / employer / both) → correct onboarding — now
      calls `POST /auth/roles` and adopts the set the **server** returns, not
      the one it sent (an administrator may have granted more, §10).
      Administrator deliberately not offered, since §10 grants it. The copy and
      the per-role explanations are still M1's
- [~] Role switcher in the profile area — `switchRoleAndGo` is done and exercised
      from `/_dev`; it needs its product entry point once the profile area exists
- [ ] Sessions screen: list, sign out, terminate all
- [x] Blocked-account notice explaining the restriction (BR-10) — reason shown
      verbatim, sign-out available; verified on device
- [ ] Account deletion request with confirmation
- [x] ~~Real session acquisition, replacing `signInAsDevelopmentRole`~~ — done.
      `signInAsDevelopmentRole` stays, gated on the flavor: it is how the
      redirect chain is exercised without a network
- [ ] Test: UAT-01 in each of the four variants; locale retained after registration

## M2 - Dictionary cache and pickers

- [x] Versioned cache keyed by `(type, canonical locale)`, delta-aware, with
      `If-None-Match` revalidation. Keyed on the locale the **server** echoed,
      not the one requested — `uz` and `oz` both resolve to `uz-Latn`
- [x] Cache in `shared_preferences` as JSON per key — not a file or sqlite.
      Largest type is a few hundred items; the seam is `DictionaryCache`, so
      moving it later changes nothing above
- [x] Searchable single-select picker (`HhDictionaryPicker`)
- [x] Multi-select picker (`HhDictionaryMultiPicker`)
- [x] Cascading region → district
- [x] Resolve labels by id, including retired and merged items (§10.3)
- [x] Verified on device against the live API: labels switch uz-Latn → ru while
      the bound ids stay byte-identical — the client half of UAT-13
- [ ] **Match-all / match-any** on multi-select where §7.1 needs it — a search
      concern, so it belongs with the search UI rather than the picker
- [x] **Level pickers** (skill × skill_level, language × language_level) —
      `LeveledFieldEditor`, built as M3's `dictionary_leveled` field. It reuses
      the picker sheet via `pickDictionaryItem` rather than growing a second
      searchable list, so retired items and the empty state behave identically
- [ ] Warm-up call site — `warmDictionaries` exists but nothing invokes it yet;
      it wants to run once after sign-in
- [x] Widget test for the pickers — 17 cases in
      `test/features/dictionaries/dictionary_picker_test.dart` covering BR-13
      (label shown, id bound), §10.3 (retired and merged not offered but still
      resolved), the §5.1 parent scoping, search, and the error-not-spinner
      rule. Only `dictionaryProvider` is faked, so the selectable filter, the
      cascade and label resolution all run for real.
      **It immediately found a third bug**: both pickers fell through to the
      loading arm on a resolution *failure*, and with retry disabled that
      ellipsis is terminal. The rule now lives once, in `resolveLabel`

## M3 - Candidate profile *(done bar one test)*

The candidate Profile tab is a **real screen**: it renders from
`GET /schemas/candidate-profile`, writes through `PATCH /candidates/me/profile`,
and shows the completeness the server computed.

Walked end to end on an emulator against the live API on 2026-08-07 — the form,
the leveled skill rows, work history, education, the file slots and the privacy
control, all against real endpoints. Running it found four bugs the suite had
not: see MEMORY.md. Every one now has a test.

The only item left is the second-category comparison test, which needs a second
category to compare against.

- [x] Form engine: text, long text, int, decimal, url, phone, bool, date,
      money range, dictionary single/multi. **An unknown `kind` is skipped and
      logged, never thrown** — that is what lets the server add a field type
      without a lockstep app release
- [x] Required-ness comes from the schema, never from the widget — and it gates
      *searchability* (BR-02), never the save
- [x] The region → district cascade is declared by the schema's
      `parentFieldCode`; the engine knows nothing about regions. Changing a
      parent clears its children, so a district cannot be left in the wrong
      province
- [x] Completeness ring + blocking-field count (§5.3)
- [x] 422s land on the fields that caused them, by code (§4.6)
- [x] `POST /auth/active-role` — profile endpoints read the acting role from
      the token, so this stopped being optional
- [x] **`dictionary_leveled`** (skills × level, languages × CEFR) — a row per
      item with its proficiency. **Adding an item opens the level picker
      immediately**, so a row without a level is never created; the server
      rejects one, and matching its invariant makes that 422 unreachable
      rather than merely unlikely. 9 widget tests drive the two sheets in
      `test/features/profile/leveled_field_editor_test.dart`, and the 422
      field-mapping split has 5 more in `field_validation_exception_test.dart`
- [x] **Bespoke sections**: work history and education. Each renders its
      records, adds, edits and deletes through its own sub-resource, and
      **takes the path from the schema's `endpoint`** rather than hardcoding
      it — that field is published precisely so a server-side move is not a
      client release. An unrecognised bespoke section still renders the
      notice, the same rule as an unknown field kind.
      Every mutation refreshes two things: the list, and the profile's
      completeness (§5.3). The second is `ProfileEditor.refreshProfile`, not
      an invalidate — invalidating would refetch the schema *and* discard
      unsaved form edits, so adding a job would silently eat a half-typed name.
      **Verified on an emulator against the live API**: add took completeness
      5% → 10%, delete took it back, and the form's unsaved state survived
      both. Running it found a bug the suite missed — see MEMORY.md
- [x] Simplified experience entry for informal/seasonal work — satisfied by
      construction rather than by a second mode, which the design system
      forbids. Only `roleTitle` and `startedOn` are required, so a seasonal
      worker with no employer to name can still file a complete record
- [x] Missing-field list with **direct edit links** — each blocking field is a
      chip that scrolls to the widget that fixes it. The label comes from the
      schema, so a field name is translated once rather than twice.
      **This is why the form is a `SingleChildScrollView`, not a `ListView`**:
      a lazy list never mounts the fields below the fold, so every key the
      chips needed was null and the feature silently did nothing
- [x] Privacy control: searchable / hidden / visible-after-apply (UAT-12) —
      `VisibilitySection`, applied immediately rather than through the save
      bar, and deliberately not a schema field: §4.2 has no `enum` kind and
      this is the one write that must not refresh `lastMeaningfulUpdateAt`.
      Verified on device: the setting changes while `isSearchable` stays false
      on an incomplete profile, which is BR-02 computed server-side
- [x] Last-meaningful-update display — in the completeness card, ISO because
      §8.3's display policy is still open
- [x] CV upload with progress, cancel, failure reason, retry (UAT-03) —
      `AttachmentsSection`, with the slots taken from the schema's own
      `attachments` block rather than listed here, so CV, photo, certificates
      and supporting documents all arrive at once and a fifth purpose would
      need no client change. Verified on device: a PDF uploaded (201), the
      button flipped to Replace on the full one-file slot, and completeness
      refreshed. **Adding `file_picker` cost three toolchain fixes** — AGP 9,
      built-in Kotlin and JVM targets; all three are in MEMORY.md
- [x] Optional certificates / work evidence — the same schema-driven slots.
      `certificate` carries `maxCount: 10`, so it accumulates rather than
      replacing, which the one shared widget already handles
- [ ] Test: form adapts by category and irrelevant fields are not mandatory —
      needs a second category to compare against

## M4 - Employer profile *(done bar evidence upload)*

The employer Company tab is a real screen. Walked end to end on an emulator
against the live API on 2026-08-07 with a freshly registered employer account.

- [x] Company and individual employer forms — one screen, and **`type` decides
      which fields exist**. There is no neutral empty employer, so a 404 before
      the first write is "not created yet" and renders the type question, not
      an error. The type is fixed after creation (`employer.type_immutable`),
      so the chooser disappears rather than offering a control that always
      fails, and the `PUT` carries only the chosen type's fields
- [~] Verification submission + evidence upload — state, the served
      `requiredEvidence` list and submission are wired; **the evidence files
      are not.** They go through `POST /files` and want the attachments widget
      generalised, which is the next slice. The server refuses a submission
      that lacks a required document and says so, so the gap is visible rather
      than silent
- [x] Status display with admin reason and changes-required path — the five
      §6.1 states through the design system's own badge constructors, and the
      administrator's reason shown **verbatim** (§2.4). An unrecognised status
      falls back rather than throwing, the same rule as an unknown field kind
- [x] BR-03: explain what blocks invitations / vacancy submission — `canPublish`
      is computed server-side and rendered as given; the sentence names both
      conditions, because an employer who is complete but unverified needs to
      know which half is missing

## M5 - Vacancy management *(core done)*

The employer Vacancies tab lists the employer's own vacancies and opens a
schema-driven editor. Walked on an emulator against the live API 2026-08-07.

- [x] Vacancy create/edit across all six §6.3 categories via the form engine —
      `GET /schemas/vacancy` returns the **same `FieldSchema`** the candidate
      profile renders, so `SchemaFieldWidget` draws it unchanged and a sixth
      category costs no client work. Adding a vacancy field is a backend change
- [x] Structured requirements incl. mandatory-vs-preferred languages — carried
      by the schema, not written here, for the same reason
- [x] Status display + employer-available transitions (§6.4) — the six statuses
      through the design system's own badge constructors; only the transitions
      the current status allows are offered, and **closing is terminal (BR-11)**
      so nothing is ever offered from closed. Closing is confirmed first
- [x] Moderation rejection reason shown to the employer — verbatim (§2.4)
- [x] Age/gender fields warn about justification + moderation (BR-12) — said on
      the form rather than discovered at submit
- [x] `missingForSubmit` shown as a count **before** the refusal, turning one
      422-per-field into a checklist. Verified on device: submitting an empty
      draft outlined all eight required fields with their messages
- [ ] Worker count `>= 1` (BR-05) — the server enforces it; the schema's
      `validation.min` is not yet applied client-side, so it costs a round trip
- [ ] Seasonal/agricultural flow (UAT-10) — needs a seasonal category to walk
- [ ] Employer dashboard widgets (§6.2) — the Home tab is still a placeholder

## M6 - Discovery and applications *(candidate half done)*

- [x] Candidate feeds: recommended, recent, saved — three tabs over one list,
      because they differ only in endpoint. Ranking stays server-side
- [x] Vacancy card with the employer's **public** name and the §5.6
      verification badge. Verified on device against the live API
- [x] Apply button reflects BR-07 — the card carries `applicationStatus`, the
      caller's own stage, so Apply is offered exactly when there is no live
      application and no second request is needed to decide
- [x] **Idempotency key on apply, persisted** — written against the vacancy id
      before the request and cleared only once the server answers. A key minted
      per attempt gives no protection: the retry looks new and the server
      creates a second application (§12.4)
- [x] Application list with all §8.1 stages; withdraw offered only while the
      application is live
- [ ] Vacancy **detail** screen — the feed card is built, the full
      `GET /discovery/vacancies/:id` view with requirements, Share and Report
      is not
- [ ] Vacancy filters per §5.5 — the repository takes them, no filter UI yet
- [ ] Deadline-expired / closed vacancy rendering (UAT-15)
- [x] Employer: applications per vacancy, stage moves and §6.5's
      hired-vs-required counts. **Stage moves are forward only, skipping
      allowed** (§8.1) — real hiring skips, and backwards is refused by the
      server, so only the legal targets are rendered. `withdrawn` is never
      offered: it is the candidate's alone
- [x] **BR-09 on the applicant view** — the phone is whatever the server sent
      and nothing reconstructs one it withheld. Null is a normal answer, so
      the absence is stated rather than left blank, and `canViewFiles` false
      means the server sent no files at all
- [ ] Employer application filters, and the internal-notes UI — the repository
      has `notes`/`addNote`, no screen yet

## M7 - Candidate search *(core done)*

- [x] **No phone numbers on candidate cards** (BR-09, §11.1) — **asserted in a
      test**, and verified to fail against a card that renders one. The
      guarantee is structural on both sides: the server's DTO has no phone
      field and neither does `CandidateCard`, so there is nowhere to put one.
      The test also pins that §7.3's private note stays off the card
- [x] Count before results; **"200+" comes from `isExact`**, never from
      comparing the number — reading `count == 200` as capped would be wrong
      the day the server raises the cap, and wrong today for a search that
      genuinely returns two hundred
- [x] Result list with §7.3 candidate cards and the match score
- [x] Save candidates — the repository also covers shortlists, private notes
      and UAT-06's prefill-from-vacancy
- [ ] Filter builder for all §7.1 groups — the repository takes filters, there
      is no builder UI, so every search is currently unfiltered
- [ ] Removable filter chips; reset all; edit one
- [ ] §7.3 sorts
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
- [~] Push registration and foreground/background handling — **config in place**
      2026-08-07: `android/app/google-services.json` holds the Firebase project
      `headhunter-app-b463f` with all three package names, so one file covers
      every flavor. **No Firebase package is in `pubspec.yaml` and no Gradle
      plugin is applied** — the file is inert until this milestone opens, which
      is the owner's explicit ordering (wire it last). The backend side is
      ready as of 2026-08-07
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
