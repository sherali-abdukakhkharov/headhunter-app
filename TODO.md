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
- [?] **Payme and CLICK merchant credentials** for the providers' *test*
      environments (§12.6). Nothing in M13 can be finished without them, and
      UAT-22 — the duplicated callback — has to be demonstrated rather than
      argued. *Blocks M13.*
- [?] **Storefront billing decision** (§12.7, BR-23) — whether Coin purchases
      ship through Payme/CLICK or must go through Apple IAP / Google Play
      Billing. The ledger stays provider-agnostic either way, which is what
      makes this deferrable; the checkout surface in the app does not. *Shapes
      M13 and gates release.*
- [x] ~~**Wallet API contract**~~ — **published 2026-08-18.** The backend built
      it (`a88d185`): `GET /wallet` carries the balance, its UZS value and the
      prices; `GET /wallet/transactions` is the paged append-only ledger;
      `GET /wallet/unlocks/:candidateUserId` answers locked-or-not without
      attempting a purchase, and `POST /wallet/unlocks` is the atomic debit,
      answering **402** with `required` and `balance` when the balance is short.
      There is deliberately **no `Idempotency-Key` on the unlock** — the
      (employer, candidate) pair is a primary key, so a retry returns the
      existing entitlement with `charged: false` and one key per tap would be
      two keys for one intent.
- [x] ~~**Contact exposure is not gated on the entitlement**~~ — **merged
      2026-08-19** (backend `c5e7a97`, 970 tests). `expose()` reads the unlock,
      `no_interaction` became **`unlock_required`**, `candidate_unlock` joined
      the granting codes, `between()` gained an `unlocks` kind, and there is a
      third download route at `/unlocks/{candidateUserId}/files/{fileId}`. All
      seven codes are now an enum on the DTO rather than prose. The client's
      reason-code gate needed no change to activate — which was the point of it.
      Two corrections worth keeping:
      **`hidden_by_candidate` did *not* become reachable** as the brief
      predicted — the readability gate 404s before `expose()` is consulted, so
      keep it mapped as defence in depth but do not design a screen around it.
      And **`not_verified_employer` is reachable with a 200**, a readable
      profile and `phone: null`, so it belongs in the page rather than in an
      error state; it now routes to verification.
- [x] **The purchase has four refusals, and they do not share a destination.**
      402 `wallet.insufficient_coins` → top-up; **403 `employer.not_verified` /
      `employer.profile_incomplete` → verification, never top-up** (BR-03 is a
      precondition an employer cannot buy past, so selling Coins there sells
      access §7 is about to refuse); 404 and 409 have no destination at all.
      All four land before any Coins move. The 403 reuses the codes every other
      §7-gated route already returns rather than minting a wallet-specific one

## M0 - Foundations *(done)*

- [x] Flutter 3.44.8, Riverpod 3 + go_router + dio, `com.jobbridge.app` (was `com.headhunter.app` until the 2026-08-19 rename)
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
- [x] **§06 (wallet) round applied 2026-08-19** — imported from the designer's
      project via the Claude Design MCP. Added: `HhNoticeTone.success` with a
      `HhNotice.done` constructor and an optional dismiss control (the first
      success-toned *notice* in the product — badges carry no border, so the
      ramp had no `successBorder` until one was drawn); the `coin`, `phone` and
      `mail` glyphs, transcribed from the designer's own paths; `surfaceMuted`.
      All registered in the gallery, and the two chevrons — which the catalogue
      had been missing since round 1 — now render there beside each other
- [!] **The employer nav question resolved itself in the design's favour.** The
      wallet TZ §5.2 lists Wallet as an employer bottom-nav destination, which
      would be a **sixth** tab against `HhBottomNav`'s five-tab cap and round
      1's constant 70pt bar. The design keeps five (Bosh sahifa · Vakansiyalar ·
      Nomzodlar · Xabarlar · Kompaniya) and makes the **balance chip** the entry
      point instead, in the app bar of surfaces where Coins get spent. So no
      cap to renegotiate and no tab to add — `CoinBalanceChip` is that widget
- [x] **The app was painting the canvas colour as its screen background** —
      **corrected 2026-08-19.** `scaffoldBackgroundColor` was `sand100`
      (`#EFEBE4`), which the design's foundations page *does* swatch as sand-100 —
      and which is also `body{background:#EFEBE4}`, the paper the artboards are
      laid out on. That double role is why it looked defensible. Every phone frame
      in the document draws its screen on `#F7F8FA`: 30 uses against 4, and of
      those 4 the only one *inside* an artboard is the swatch itself.
      Now `HhColors.surfaceMuted`, with a test asserting it against the literal
      value as well as the token, so repointing the token cannot satisfy it. Two
      `HhCompletenessRing` call sites moved with it — the ring paints its own hole
      rather than leaving it transparent, so a ring sitting on a screen has to be
      told the screen's colour. **Not yet seen on a device**, which is the one
      check this change really wants
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
- [x] **Match-all / match-any** on multi-select where §7.1 needs it — landed in
      the M7 filter builder rather than the picker, which is where the concern
      actually is. Shown only once its group has values: a mode with no group
      asks a question with no subject, and `toJson` drops it anyway
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
- [x] **Vacancy detail (§5.6)** — the candidate could browse a feed and apply
      but never open a vacancy to read it. Tapping a card opens it: employer
      and verification badge, pay, openings, deadline, the work window,
      location, the description **exactly as entered** (§2.4), the structured
      requirements grouped by field, and Apply / Save / Report
- [x] **UAT-15: a vacancy that is gone reads as gone, not as a fault.** The
      server answers `vacancy.not_found` for unknown, closed, expired and
      moderated-away alike — deliberately, since saying which would leak the
      existence of vacancies the candidate may not see. So the client
      distinguishes only "gone" from "broken", which is the distinction that
      matters to the person holding the phone: 404 gets its own notice with a
      Back action and **no retry**, everything else keeps the error state
- [x] **Required is not the same as preferred** (§6.3) — badged, never told
      apart by order or colour alone. A preference that looked like a
      requirement would stop people applying, which is the opposite of what a
      preference is for. Mandatory rows also sort first within their group
- [x] A levelled requirement renders **both halves** — the row carries an item
      *and* a level, so testing the item slot first and stopping would silently
      drop the "C1" that is the whole requirement. Pinned by a test

## M7 - Candidate search *(§7.1–§7.3 done; invitations and the profile view open)*

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
- [x] Filter builder for all §7.1 groups — every field on
      `CandidateSearchFiltersDto`, in eleven sections. Two of the server's
      refusals are re-made in the client so they are read *before* the request
      rather than as a 403 after it: **BR-12** blocks Apply until an age or
      gender filter has a declared reason, and `search.occupation_required` is
      made unreachable by disabling "years in this occupation" until an
      occupation is chosen
- [x] **Level floors bind a `rank`, not a dictionary id** — the one deliberate
      exception to BR-13 in this app, because "B2 or better" is a comparison
      and ids are unordered. Pinned by a test whose fixture gives `rank` and
      `sortOrder` *different* values, so a field reading `sortOrder` fails
      here rather than the day an administrator inserts a level (§7.4, §10.3)
- [x] Removable filter chips; reset all; edit one. **Removing a group takes its
      dependents with it** — occupation → occupation-experience, region →
      districts, justification → age/gender — so a chip can never leave a set
      the server refuses for a filter the employer did not touch
- [x] §7.3 sorts, all five
- [x] Persist last search configuration locally, restrictions included. Safe
      because a restriction is never invisible: it is always a chip, and it
      cannot survive without the justification it was declared with
- [x] UAT-06 prefill from a vacancy — "Find candidates" on a non-draft vacancy
      fetches `/candidate-search/prefill/:id` *before* navigating, so the tab is
      never entered showing the previous search and then reshuffled
- [x] Candidate profile view from a result card (§7.3 "View profile") — the
      place where **BR-09 does open**. The client holds no copy of the rule to
      disagree with: `phone` is either in the response or it is not. What the
      screen adds is the *reason* — `exposureReason` becomes a sentence saying
      what would change it, mapped exhaustively over the six codes in
      `contact-exposure.ts` rather than defaulted, because "hidden their
      profile" and "nobody has applied yet" are undone by different things.
      The applicants screen now shows the same specific reason instead of a
      generic line, from the same one function
- [x] Saved candidates screen (§7.3) — still behind BR-02's gate, so the empty
      state says "nothing here" rather than "you have saved nobody": a
      candidate who hides their profile leaves the list without having been
      un-saved
- [~] Invitations + response tracking (UAT-07); general invitations. **Re-scoped
      2026-08-10**: §8.2 now requires a Candidate Unlock entitlement before an
      invitation can carry contact context, so this cannot finish before M12
- [ ] Vacancy shortlist screen — the repository covers it; it needs a vacancy
      to hang off, which is `GET /vacancies/:id/shortlist`

### Re-opened by the 2026-08-10 spec revision

The search itself is unaffected — cards carried no contact detail and still
don't. What changed is what a card leads to.

- [x] ~~**The shipped contact-exposure copy is now wrong**~~ — **resolved
      2026-08-19, and not the way this item expected.** It assumed the copy had
      to be replaced. It did not: the client answered the client question in the
      lenient direction (an application still opens contact), so the original
      `no_interaction` sentence is *still true wherever it is still sent*, and
      the new `unlock_required` code got a sentence of its own beside it. Nothing
      was swapped and no mutation test was lost. The lesson is worth keeping —
      a code that changes meaning wants a **new** code, not new copy on the old
      one, and that is what made a single build correct against two servers
- [x] ~~Locked state on the candidate profile~~ — **built 2026-08-19** under
      M12. The label carries the server's price rather than §7.3's literal
      "2 Coins", since §10.5 can change it without a store release
- [ ] UAT-03's wording changed too: the CV is protected "until the employer has
      Candidate Unlock access", not merely until an interaction exists. Nothing
      to build on the candidate side; it changes what the *employer* side must
      show
- [ ] **Download a candidate's files.** The list renders with the purpose
      resolved as a word, but tapping does nothing: saving bytes to disk and
      opening them needs `path_provider` and an opener, and adding packages
      here has to be weighed against pubspec.yaml's load-bearing pins. Same
      decision blocks a `tel:` link on the phone, which is why the contact
      block offers **copy** instead — no new dependency, and the platform
      dialler takes it from the clipboard

## M12 - Employer wallet, Coins and Candidate Unlock *(client complete; the server has one change left)*

**§6.6 · BR-15 – BR-18, BR-21, BR-24 · UAT-16 – UAT-19.** Delivered **before
M8**, because §9.1 puts employer-initiated chat behind the same entitlement.
Needs no payment provider — the ten free Coins are enough to build and accept
the whole flow, which is why it is split from M13.

**The client side is finished. The server has one change left**, and it is
specified: `expose()` must read the entitlement and gain a reason code for it
(the task handed over on 2026-08-19 spells out all six changes, including the
third file-download route and the two gaps in the purchase itself).

**How both halves shipped in one build without shipping a paywall that charges
for nothing.** The wallet — balance, prices, ledger — never depended on the gate
and went first. The unlock did, and rather than a flag it is gated on
`exposureReason == 'unlock_required'`: a code only a server that reads the
entitlement can send. So the purchase path exists, is tested, and is unreachable
until the server can honour it. A flag would have been a code path that takes
money and is enabled by a constant somebody has to remember.

- [x] ~~Wallet API contract~~ — published 2026-08-18, see "Blocked on someone
      else" for the four routes
- [x] **Wallet screen: balance, approximate UZS value, append-only ledger**
      (BR-24). Reversals and admin adjustments render as their own entries and
      are marked as corrections; each row shows **the balance the server
      recorded after it**, never a total accumulated down the list — the client
      only ever holds one page of a ledger, so accumulating is wrong by
      construction. Paged with "show more", and an append that fails leaves the
      entries on screen instead of replacing a correct ledger with an error page
- [x] **Prices come from the server** (§6.6), and a test enforces it: the
      fixture's `balanceValueUzs` deliberately **disagrees** with
      `balanceCoins × coinPriceUzs`, and the same for the unlock price, so any
      client-side multiplication fails here rather than the day a bundle price
      or a rounding rule lands. Verified by mutation — computing the value
      instead of reading it fails exactly that test. Same idiom as the
      level-floor test's mismatched `rank`/`sortOrder`
- [x] **A ledger kind is not a badge.** `HhBadge`'s tone answers "whose turn is
      it, and did it end well?" and a ledger entry is an event with neither, so
      the kind is a word plus a glyph. What *is* held to the badge rule is the
      amount: `+5` and `−2` carry the sign, so credit and debit never rest on
      green versus grey
- [ ] **The §6.2 dashboard tile has no dashboard yet.** `WalletTile` is built
      and lives in the wallet feature, but the employer home tab is still M5's
      placeholder, so it currently sits on the company tab. The dashboard places
      the same widget rather than growing a second copy
- [x] **E-52 activity history and E-53 activity detail, 2026-08-19.** The wallet
      now shows *recent* activity with an "All" link, as §06 splits them: the
      wallet answers "what just happened", the history answers "what has ever
      happened" and needs the filters and month headers the first one does not.
      The filter reads the amount's **sign, not the kind** — an
      `admin_adjustment` can be either and a `reversal` is a credit that undoes a
      debit, so a list of kind codes would have to guess, and would silently drop
      a sixth kind from *both* filters. Pinned by a test that files a reversal
      under "topped up" and an unknown kind under it too.
      E-53 takes the entry rather than refetching it: there is no
      `GET /wallet/transactions/{id}` and none is needed, because BR-24's
      triggers make an entry immutable, so the copy in hand cannot be stale.
      Its reference number is the payment order where one exists and the entry id
      otherwise — **never an unlock's `referenceId`**, which is a candidate's user
      id and would hand somebody's identifier to support for no reason. Pinned.
- [x] **The balance card lost its price table**, per §06's first principle. The
      UZS value and the Coin price share one line under the balance, and what a
      Coin is *for* is a sentence where the table was — including that search and
      preview are free, because an employer who thinks browsing costs Coins will
      not browse
- [ ] **Server-side ledger filtering.** `GET /wallet/transactions` takes only
      `limit` and `offset`, so E-52's filter runs over what has been loaded:
      choosing "spent" on a first page of twenty shows the spends *in those
      twenty*. Handled honestly rather than hidden — "show more" stays offered
      whenever the server may hold more, even when the filtered list looks short,
      because the alternative is a list that looks complete and is not. A `kind`
      or `sign` query parameter would fix it properly. *Not blocking; the wallet
      of a real employer is unlikely to exceed one page for a long time.*
- [x] **The unlock flow is built, and it cannot fire against today's server.**
      The whole thing turns on one signal: the control is offered only where
      `exposureReason` is `unlock_required`, and that code exists **only on a
      server that actually reads the entitlement**. Today's server answers
      `no_interaction`, so the control is absent and nobody can be charged for
      access that would not change — which is what made it safe to merge ahead
      of the backend. The day the gate deploys, the control appears with no
      client release and no flag anyone has to remember. Pinned by a test that
      funds a wallet with 500 Coins against `no_interaction` and asserts both no
      button and no request; verified by mutation, since loosening the gate to
      include `no_interaction` fails exactly that test
- [x] **Unlock confirmation sheet**: cost, current balance and remaining
      balance, shown *before* anything is charged (UAT-17). Opening it and
      cancelling both charge nothing, and a test asserts no request is made by
      either. The remaining balance is the **one derived figure in this feature**
      — both inputs are server integers, a Coin count is not an amount payable,
      no endpoint returns it, and §6.6 asks for it by name. It is a preview and
      never a result: the balance after the charge is refetched
- [x] **The unlock is one server call and the client does not simulate it.**
      Debit and entitlement are atomic server-side (BR-18), and the response
      does not carry the new balance — so the wallet is *invalidated* rather
      than adjusted by the cost. An optimistic debit that then failed would
      show Coins gone with no access
- [x] ~~Persisted idempotency key on the unlock~~ — **not needed, and the
      backend explains why**: `(employer, candidate)` is a primary key, so BR-16
      charges the pair once by construction and any retry returns the existing
      entitlement with `charged: false`. A header key would answer the same
      question worse, since one key per tap is two keys for one intent. Apply
      still needs its persisted key (§12.4) because a second application on the
      same vacancy has no such natural key
- [x] **Locked candidate profile**: structured data free, contact locked, price
      on the button from the server rather than a constant (§10.5 can reprice
      it while the app is installed). Neither `not_verified_employer` nor
      `hidden_by_candidate` offers a purchase — BR-03 is a precondition an
      employer cannot buy past, and a candidate who left search is not for sale
- [x] **Under 2 Coins routes to top-up, not a failure** (UAT-19), decided
      *before* the request from figures the server already sent — and the 402 is
      still handled, because the balance can move between the sheet opening and
      the tap. The server's sentence carries both numbers in the user's language,
      so it is rendered rather than rebuilt in Dart
- [x] **`exposureExplanation` rewritten to tell the truth on both servers.**
      `candidate_unlock` joins the *allowing* group — an employer who paid and
      finds no number was not refused anything — and `unlock_required` gets the
      sentence that offers the purchase *and* names the free route, because
      §11.1 still treats an application as an entitlement of its own. The
      original six codes keep their meanings, so one build is correct before and
      after the gate lands. **This closes M7's `[!]` item**
- [x] **Built to the design (§06, E-42 – E-46), 2026-08-19.** The locked block is
      now the drawn card — `Himoyalangan ma'lumotlar` with three **named** rows,
      phone / e-mail / CV, each masked — rather than a sentence saying contact is
      unavailable. That is DA-14, and it is also the better answer to the
      question an employer is actually asking: what do the two Coins buy?
      The mask is a **fixed-width constant**, never derived from the value,
      because a mask that tracked the length would leak the length (§8.7); the
      masked value is excluded from semantics so a screen reader announces the
      label and not twelve bullets; and a test sweeps every `Text` on a locked
      profile for any run of three digits
- [x] **The priced action is a sticky bar** (§3.1), not a button inside a card —
      a price halfway down a long scroll stops being visible at the moment of
      the decision. The success outcome is an **inline dismissible banner**
      carrying Coins spent and the new balance, not a snackbar: those are
      figures somebody may want to read twice, and four seconds is the wrong
      container for money
- [x] **Insufficient balance no longer redirects** (§06's third principle:
      paying must never lose the candidate). It stays in the sheet, still naming
      them, and swaps the action for top-up. The same now applies to the 403 —
      which also fixed a real overflow, since a snackbar carrying the server's
      sentence *and* a verification action overflows a 360pt bar in English and
      would be worse in Russian
- [x] **"Coin" is the unit name in every language.** The design writes `2 Coin`
      in Uzbek Latin, and round 1 puts uz-Latn copy under design ownership. My
      `tanga` / `монета` were inventions — exactly the machine translation of a
      money string the handoff calls "a liability, not a shortcut". Still owed:
      the client's certified uz-Cyrl and ru translation to confirm it
- [ ] Files behind an unlock. The route now exists
      (`/unlocks/{candidateUserId}/files/{fileId}/content`), so what is left is
      the client half: saving bytes and opening them needs `path_provider` and an
      opener, weighed against pubspec.yaml's load-bearing pins. **Always use the
      `downloadPath` the server hands back** — an employer holding both an
      application and an unlock is served through `/applications/…`, because the
      application is the stronger claim

## M13 - Coin top-up: Payme and CLICK *(designed 2026-08-19; still blocked)*

**§6.7, §12.6, §12.7 · BR-19, BR-20, BR-22, BR-23 · UAT-20 – UAT-23.** Blocked
on client-supplied merchant credentials and the storefront billing decision.

**Now fully drawn, and still not buildable.** The designer's §06 covers
E-47 – E-53 in full — pack selector and free-entry amount, provider cards for
Payme / CLICK / store billing, the pending state with "Holatni tekshirish", the
receipt, the failure, the filtered history and the transaction detail. Copy and
geometry are in the design document; the section is imported and readable.

What is missing is not design. It is **a server**: there are no payment-order
endpoints at all, `wallet_transactions.reference_id` is reserved for this and
still unfilled, and the two client-owed items above (merchant credentials, the
storefront billing decision) are unchanged. Building a checkout against no
server is the trap the wallet and the unlock were each split to avoid, twice —
and this one is worse, because there is nothing to gate on either. No reason
code, no endpoint, nothing a running server could say that would make the screens
correct.

So the drawn screens are recorded here rather than half-built. Three things from
the design worth carrying into that work when it opens:

- **The UZS figure belongs here and almost nowhere else.** §06's first principle:
  the amount in som appears on the top-up screen, the payment screen and the
  receipt — the three places money actually changes hands. It has been removed
  from the unlock price row for this reason.
- **The receipt's primary action is "back to the candidate"**, not "go to the
  wallet". §06's third principle again: the name travels through every screen of
  the top-up flow, and the employer must never have to find their way back.
- **Card fields are never drawn** (BR-22, and §15.2 says so explicitly): the
  design hands off to provider checkout and annotates what is app-owned versus
  provider-owned. The store-billing card is a *third provider option* in the same
  list, which is what makes DA-16's configurability a layout that already works.

- [ ] Coin quantity chooser; **the server calculates the amount** and returns
      the Payment Order. A total computed in Dart is never the source of truth
      (§12.3.1) — show the server's figure or show nothing
- [ ] Provider choice and checkout through an approved link, deep link or SDK
- [ ] **No card data in the app, ever** (BR-22) — no PAN, no CVV, no provider
      credentials, and no "helpful" saved card field
- [ ] **A success redirect credits nothing** (§6.7). Returning from the provider
      leaves the order pending; Coins appear only when the backend says PAID
- [ ] Every Payment Order state rendered honestly, including the unwanted ones:
      CREATED, PENDING, PAID, FAILED, CANCELLED, REVERSED/REFUNDED. Failure and
      cancellation return to Wallet with a reason and a retry
- [ ] Order history showing the internal order ID, so a support call can start
      from something the user can read out
- [ ] UAT-22 — the duplicated callback — demonstrated in the provider test
      environment, not argued

## M8 - Chat and interviews *(now depends on M12)*

§9.1 changed on 2026-08-10: employer-initiated chat is enabled only once that
employer holds a Candidate Unlock for the candidate. **The candidate's side is
not gated** — someone who applied can still write, and must never be shown a
paywall that is not theirs.

- [ ] Conversation list + thread; text and approved attachments
- [ ] Sent / delivered / read indicators
- [ ] Report and block; read-only closed conversations
- [ ] Interview display by type + confirm / request another time
- [ ] Idempotency key on message send
- [ ] Employer entry points gated on the entitlement (§9.1); candidate entry
      points deliberately not
- [ ] **Deep links switch role before navigating** where required *(moved here
      from M9 - routing infrastructure, not a notification feature)*

## M9 - Notifications *(deferred to last - client direction 2026-08-04)*

Runs after M10, not after M6. No Firebase package enters `pubspec.yaml` before
this opens. Deep links moved to M8.

- [ ] In-app list, unread badge, mark read *(no push dependency; can be pulled
      forward at no cost if the client wants notification history earlier)*
- [~] Push registration and foreground/background handling — **config in place**
      2026-08-07: `android/app/google-services.json` holds the Firebase project
      `headhunter-app-b463f`, so one file covers every flavor. **No Firebase
      package is in `pubspec.yaml` and no Gradle plugin is applied** — the file is
      inert until this milestone opens, which is the owner's explicit ordering
      (wire it last). The backend side is ready as of 2026-08-07
- [?] **`google-services.json` now lists the OLD package names, and is left that
      way deliberately** (JobBridge rename, 2026-08-19). It cannot be fixed by
      editing the text: Firebase issues a `mobilesdk_app_id`, an `api_key` and a
      `client_id` per package name, so a hand-edited `package_name` yields a file
      the Gradle plugin accepts and that then fails at *runtime*, when a device
      registers a token against an app id that does not exist. That failure looks
      like "notifications just don't arrive", which is far worse than a build
      error.
      Left stale, it fails **loudly and at the right moment** instead: the moment
      this milestone applies the Google Services plugin, the build stops with
      `No matching client found for package name 'com.jobbridge.app.dev'`.
      *The fix is console work, not code*: add three Android apps
      (`com.jobbridge.app`, `.dev`, `.staging`) to the same Firebase project,
      re-add the debug and upload-keystore SHA fingerprints (they are stored per
      app, so new apps start with none), download the regenerated file — one
      download covers all three — and replace it. No new Firebase project, no
      server-side change, no signing-key change. *Blocks nothing until M9 opens.*
- [ ] Preferences; security/account categories not offered as disableable

## M10 - Admin module

- [ ] Admin shell behind the admin role
- [ ] Dashboard counters (§10.1)
- [ ] Employer verification + vacancy moderation with mandatory reasons
- [ ] Complaint queues
- [ ] User search + warn/restrict/block/unblock with reason (UAT-14)
- [ ] Dictionary management with four localized labels + skill merge, designed for
      a phone (there is no web panel)
- [ ] **§10.5 wallet and payment administration** *(new, 2026-08-10)* — employer
      balance and immutable history; Payment Order search on six axes (employer,
      provider, status, date, internal order ID, provider transaction ID,
      because the one support has is whichever the caller can read out); payment
      detail with status history and failure/reversal reason
- [ ] Manual wallet adjustment with a **mandatory reason**, audited (BR-24) — it
      writes a new ledger entry, and nothing on this screen may edit an existing
      one
- [ ] Registration bonus / Coin price / unlock price as editable server config,
      with the screen stating that a change **affects future transactions only**.
      The natural reading of "change the price" is that history follows, and it
      does not

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
- [ ] Walk **all 24** UAT scenarios and keep the evidence — the 2026-08-10
      revision added UAT-16 – UAT-24. UAT-20 – UAT-23 need the providers' test
      environments, so book those *before* the acceptance window, not inside it
- [ ] **Verify storefront billing rules immediately before release** (§12.7,
      BR-23). Listed here as well as in M13 because it is a gate that expires:
      rules checked two months out are not evidence
- [ ] Payment-integration documentation in the delivery package (§13.2) —
      callback endpoints, test/production configuration, reconciliation
      behaviour, secure credential setup

---

## Standing rules

Applies to every task above:

- New string → keys in **all four** ARB files, or CI fails.
- New picker → binds a dictionary **ID**, displays a label.
- New non-idempotent write → persisted idempotency key.
- New mutation → list its invalidations next to it.
- Anything showing a price, total or balance → **the server's figure**, never
  one computed in Dart (§6.6, §12.3.1).
- Nothing in the app ever holds card data or provider credentials (BR-22).
- `flutter analyze` clean and `flutter test` passing before commit; commit the
  `build_runner` output.
- Do not bump packages casually - the pins in `pubspec.yaml` are load-bearing
  (see [CLAUDE.md](CLAUDE.md)).
