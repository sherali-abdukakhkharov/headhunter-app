# headhunter-app - TODO

Working checklist. Milestone definitions and ordering are in [PLAN.md](PLAN.md);
design rationale in [ARCHITECTURE.md](ARCHITECTURE.md).

Convention: `[ ]` open · `[x]` done · `[~]` in progress · `[?]` blocked on a
decision or on the backend.

---

## The 1.4.1 QA audit (2026-08-23)

A full QA, UX, business-logic, API, accessibility and localization audit of the
**1.4.1** APK against the DEV database, delivered as
[mobile-test-audit.md](mobile-test-audit.md): 3 Critical, 5 High, 10 Medium, 1
Low, verdict **NO-GO for 1.4.1**. Findings are `MT-nnn` and each carries
evidence, a root cause and acceptance criteria — read those before starting a
fix rather than working from the summary table.

**It audited 1.4.1, and two releases have landed since.** Read every row below
against that: one Critical was already fixed before the audit was written up.

| ID | Sev | State |
|---|---|---|
| MT-001 | Critical | **Fixed 1.7.0** — candidate Home is a real screen |
| MT-002 | Critical | **Fixed 1.5.0**, before the audit was delivered — §10.4's user management, search and BR-10 actions |
| MT-003 | Critical | **Backend/deployment**, and confirmed as such by the audit itself: `MODERATION_ENABLED=false` in the tested `.env`. The client already renders whatever status the API returns; the ask is the flag and a deployment smoke test |
| MT-004 | High | **Fixed 1.9.0** — §10.3 ships, and the shell has no placeholders left. Label *editing* waits on a contract change; see the ask |
| MT-005 | High | **Half fixed 1.10.0** — §9.2's in-app centre ships: the list, the unread badge, mark-read, the per-category switches and the routing from a row to what it is about. **Push does not**, and it is not a code gap: `android/app/google-services.json` still names the pre-rename package, so Firebase cannot initialise under `com.jobbridge.app` |
| MT-006 | High | Open — M13, blocked on client-supplied merchant credentials, not on code |
| MT-007 | High | **Fixed 1.8.0** — no default type, and the first save is held to §6.1 |
| MT-008 | High | **Fixed 1.7.0** — the account screen is on the administrator's dashboard |
| MT-009 | Medium | Open — CV purpose code sent to a uuid dictionary endpoint |
| MT-010 | Medium | **Half fixed 1.8.0** — an incomplete employer never sees "Nothing is waiting on you" again; the two BR-03 gates (New vacancy, Candidates) still answer with a snackbar and a global error rather than a corrective CTA |
| MT-011 | Medium | **Fixed 1.8.0** — a save invalidates verification |
| MT-012 | Medium | Open — raw wire codes and unformatted salary reach the UI |
| MT-013 | Medium | Open — OTP submits before it can succeed; errors are global rather than inline |
| MT-014 | Medium | Open — the offline message names the backend and the base URL |
| MT-015 | Medium | Open — duplicate semantics and unlabelled pickers. **Design-system change, so it needs a device run** |
| MT-016 | Medium | Open — landscape clips the vacancy card's actions |
| MT-017 | Medium | Open, and it is a **backend ask**: `GET /admin/complaints` returns complaints, not what they are about, and resolving a target is a per-kind query the detail route does one at a time. Recorded as such since the queue shipped |
| MT-018 | Medium | **Fixed 1.7.0** — the recipient's invitation reads "Awaiting your answer" |
| MT-019 | Low | **Fixed 1.7.0** — no match score without a match breakdown behind it |

Two things the audit asked for that are now standing guarantees rather than
fixes:

- **A release-shell gate.** `app_router_test.dart` walks every tab of every
  role and asserts the placeholders are **exactly** `[/admin/dictionaries]`. It
  fails when a tab regresses into a placeholder *and* on the day §10.3 lands —
  which is the point: a test that merely allowed placeholders would have gone on
  passing through all three of 1.4.1's.
- **The DEV static code is a master key.** `OTP_STATIC_CODE=666666` on a public
  host admits anybody to any phone number. It was already recorded as blocking
  production; the audit adds that it must be cleared before *any* real data goes
  behind that deployment, not just before release.

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
- [x] ~~**Dictionary contract**~~ — **delivered.** `GET /dictionaries/:type` and
      `/dictionaries/items` are consumed by `dictionary_repository.dart` and every
      picker in the app runs on them. The marker was left stale here long after
      M2 shipped; nothing has been blocked on this for weeks.
- [x] ~~**Category field-schema contract**~~ — **delivered.**
      `/schemas/candidate-profile` and `/schemas/vacancy` drive the schema-driven
      forms (ARCHITECTURE.md §6), consumed by `profile_repository.dart`. Also
      stale.
- [-] ~~**Push provider** (FCM vs FCM+APNs)~~ - **no longer blocking.** Client
      deferred notifications to the last feature milestone (2026-08-04), so this
      decision is not needed until M9 opens. Backend recommends FCM-only with an
      APNs key in Firebase; still needs an Apple Developer account when we get
      there.
- [x] ~~**Time zone policy** for interview display (§8.3)~~ — **answered, and
      the answer is in code.** Single platform zone `Asia/Tashkent`; every
      timestamp carries an explicit numeric offset resolved for that instant and
      never `Z` (API_CONTRACTS.md §2, frozen). `ZonedTimestamp` renders the
      carried wall clock and never `.toLocal()`, and `Interview` consumes it.
      Stale marker — M8's interview half shipped against this on 2026-08-20.
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
- [x] **§8.2's four invitation badges, 2026-08-19** — the round-1 rule named
      invitation state as one of the object types `HhBadge` stands behind, and
      the constructors did not exist, so every invitation surface would have
      hand-rolled one. Now **sent · details requested · accepted · declined**,
      registered in the gallery and held to both halves of the glyph rule by the
      same tests as the other twenty. Two decisions worth keeping:
      **a declined invitation is neutral, not error.** The tone table defines
      error as "resolved badly *for the person reading it*", and this badge has
      two readers — the employer, for whom it is a no, and the candidate who
      chose it, for whom red is the app disapproving of a decision it asked them
      to make. `applicationWithdrawn` settled the same trade-off the same way
      and appears on both of its surfaces too, so this follows it rather than
      inventing a rule: neutral tone, and the same `arrowLeft` glyph, because it
      is the same fact.
      And **`helpCircle` is the one glyph in the set the designer did not
      draw** — "request details" needs a *question* glyph, and `infoCircle`
      means "here is information", so reusing it would break the rule that a
      shared glyph means the same thing everywhere. Same 9-radius circle and
      stroke as its three siblings. Raised in docs/design-feedback.md round 4
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
- [x] ~~**Role switch does not tell the server**~~ — it does, and has for a
      while: `SessionController._publishActiveRole` calls
      `AuthRepository.switchActiveRole` on every switch and stores the access
      token it returns. The note below is kept because the failure it describes is
      the reason the call exists.
- [-] ~~**Role switch does not tell the server** — `POST /auth/active-role`~~
      returns an access token carrying the new role, and the app does not call
      it. Harmless today because nothing is role-authorized yet; **it becomes a
      403 the moment M2+ adds an endpoint that checks the acting role**
- [x] **Role selection, finished 2026-08-20** (§2.3). It calls `POST /auth/roles`
      and adopts the set the **server** returns rather than the one it sent (an
      administrator may have granted more, §10), and administrator is not
      offered, since §10 grants it. What was missing was the whole of the
      presentation: the screen carried an `HhNotice.pending` reading *"Role
      selection arrives in M1"* — on the first screen a new account ever sees.
      **This screen is where registering ends**, which is what set the copy.
      There is no sign-up step: `POST /auth/otp/verify` creates the account when
      the phone is new and a new account deliberately holds no role, so the
      redirect chain lands here and `POST /auth/roles` finishes the job. That
      makes two words — "candidate", "employer" — the last thing between somebody
      and the product, and a word is not a choice. Each now carries one line of
      §2.2's capabilities.
      Three decisions worth keeping:
      **What a role can do is stated; what it costs is not.** The employer line
      says nothing about Coins or unlocks (§6.6), though they are real: a price
      quoted before anything has been offered reads as a paywall standing in
      front of registration, and the wallet explains itself once there is
      something to spend on. A test asserts no digit reaches the screen.
      **Choosing both is explained, not merely permitted.** §2.3 allows both and
      keeps the data separate; what stops people is the fear that a personal job
      search lands inside a company account. So the note about two separate
      spaces appears **on the second tick** — earlier it is advice nobody asked
      for, there it answers the question the tick just raised.
      **It is a caption, not an `HhNotice`.** The notices all carry a state
      (pending, restricted, expired); toning this one as a notice would make
      choosing both look like the risky option
- [ ] **Run the design gallery on a device for `description`.** `HhCheckboxRow`
      and `HhRadioRow` gained the optional second line `HhSwitchRow` already had,
      and with it the control aligns to the label instead of to the middle of the
      block. A specimen is in `/_design` beside the plain checkboxes. Tests cover
      that both lines render and the whole row stays one tap target, which is not
      the same as looking at the alignment — and MEMORY.md records three design
      bugs that a green analyze and a green suite both missed
- [~] Role switcher in the profile area — `switchRoleAndGo` is done and exercised
      from `/_dev`; it needs its product entry point once the profile area exists
- [x] **Account and security screen, 2026-08-20.** §4.2's session list with
      per-device revoke and terminate-all, BR-14's deletion request, and — the
      part that turned out to matter most — **a sign-out an ordinary user can
      reach.** It existed only in the dev-tools screen and the blocked-account
      screen, so a signed-in user had no way out of the app at all.
      Four decisions worth keeping:
      **Revoking the current device is offered rather than hidden.** It is the
      same thing as signing out, and hiding the row would leave somebody looking
      at a list of their devices unable to act on the one in their hand. The
      confirmation is worded as signing out, and the tokens are cleared locally
      afterwards so the redirect chain moves rather than waiting for the next
      request to fail.
      **Terminate-all says "including this one".** "Every device" is a phrase
      most people read as "every *other* device", and the surprise would arrive
      after the action.
      **Deletion is a request, and no date is printed.** The server returns
      `purgeAfter: null` while the retention period is an open client question,
      so the screen points at support instead — a made-up date is the kind of
      promise that ends up in a complaint.
      **The sign-out button survives a failed list.** A screen that can only
      fail traps whoever came here to leave, and signing out of this device needs
      no list.
      Reached from a row at the end of *both* profile screens, because §2.3 makes
      the role a runtime switch and whichever shell somebody is in has to reach
      the account. A row rather than an icon: neither profile screen has an app
      bar, and the glyph set has no gear — `lock` already means "restricted" in
      five places and `shieldCheck` means verification
- [x] Blocked-account notice explaining the restriction (BR-10) — reason shown
      verbatim, sign-out available; verified on device
- [x] ~~Account deletion request with confirmation~~ — done 2026-08-20, on the
      account screen above. Worth noting *why* it moved up the list: an app that
      lets people create an account has to let them delete it from inside the
      app, which makes it a store-review gate rather than a feature
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
- [x] **Employer dashboard (§6.2, E-07/E-08), 2026-08-20.** The Home tab was a
      placeholder; it is now the dashboard, and five of §6.2's seven widgets are
      live: active vacancies and open positions, new applications, candidates to
      review, hiring progress, and the wallet tile — which had been built since
      M12 with nowhere to live.
      **Pending work comes before the metrics**, because the design says why: "a
      recruiter opens this app to act, not to read numbers." The rows are ordered
      by how stuck the employer is — BR-03 verification first, since nothing else
      works without it; then a vacancy a moderator sent back, the only item whose
      timing the employer does not control; then unread applicants; then saved
      candidates, which is a nudge.
      Three figures are computed rather than fetched, and each has a trap:
      **open positions** sums `worker_count` and a vacancy that states none
      contributes nothing rather than one; **new applications** is absent (an em
      dash) until *every* per-vacancy count has arrived, because a zero that
      becomes 34 was wrong rather than stale; **invited** on the meter counts
      only non-terminal invitations, since the three segments add up to the
      openings and somebody already hired must not appear twice.
      New design-system component: `HhMeter`, a segmented bar whose legend is not
      optional — a stacked bar is colour alone by construction, so each segment
      carries a swatch, a word **and** its figure

## M6 - Discovery and applications *(candidate half done; §5.5's home 2026-08-24)*

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
- [x] ~~Vacancy **detail** screen~~ — **built 2026-08-20**; see the entry
      further down this list, which records what it renders. Left checked-off
      here rather than deleted because two open boxes in this section had
      already been answered lower down, and a list that contradicts itself gets
      read as the pessimistic half being current
- [x] **Vacancy filters (§5.5), 2026-08-20.** The repository had taken filters
      since M6 and nothing ever sent any. Six of §5.5's nine now work —
      occupation, region/district, employment type, work format, shift and
      publication date — plus the lower half of the pay range, persisted between
      sessions the way the employer's search config is.
      Four decisions worth keeping:
      **Saved is never filtered.** The other two feeds are the server choosing
      what to show; saved is a list the candidate curated, and an occupation
      filter making a saved vacancy vanish from it reads as data loss. The tab
      says so while filters are set, because otherwise it reads as the filters
      having stopped working.
      **A filtered empty feed says something different** from an empty one: one
      is fixed by widening the filters, the other by waiting for employers to
      publish, and telling somebody with four filters set that there are no
      vacancies would simply be false.
      **The pay note is on screen**: a negotiable vacancy *passes* a pay floor,
      which is the server's rule and would otherwise read as a broken filter.
      **The feed watches the filters rather than keying on them**, so all eight
      existing `invalidate` call sites keep working — none of them would know
      which filter set to name. That needs [FeedFilters] to have a deep `==`,
      which is tested.
      One thing found while building it: `FeedFilters.fromJson` reads **locally
      stored** data, not a server response, so a field of the wrong type is an
      older build's format rather than a contract violation. Every field is read
      defensively; a cast would have lost the whole set over one renamed key
- [!] **Backend ask: three of §5.5's nine vacancy filters have no query
      parameter.** `FeedQueryDto` accepts `occupationIds`, `category`,
      `regionId`, `districtId`, `employmentTypeIds`, `workFormatIds`,
      `shiftIds`, `salaryFrom` and `publishedFrom` — and nothing for
      **experience**, **language**, or the pay range's **upper bound**, all three
      of which §5.5 lists by name.
      They are deliberately not modelled and not offered: a filter a candidate
      can set and the server ignores is worse than one that was never there,
      because the result list looks like an answer. The filter screen says which
      three are missing rather than leaving somebody hunting for a control, and
      that notice is deleted the day the parameters exist.
      Worth pairing with the employer side, which already filters candidates on
      experience and language (§7.1) — so the shapes exist, on the other
      resource
- [x] ~~Deadline-expired / closed vacancy rendering (UAT-15)~~ — **built
      2026-08-20**, and the entry below says why it distinguishes only "gone"
      from "broken": the server answers `vacancy.not_found` for unknown, closed,
      expired and moderated-away alike, deliberately
- [x] Employer: applications per vacancy, stage moves and §6.5's
      hired-vs-required counts. **Stage moves are forward only, skipping
      allowed** (§8.1) — real hiring skips, and backwards is refused by the
      server, so only the legal targets are rendered. `withdrawn` is never
      offered: it is the candidate's alone
- [x] **BR-09 on the applicant view** — the phone is whatever the server sent
      and nothing reconstructs one it withheld. Null is a normal answer, so
      the absence is stated rather than left blank, and `canViewFiles` false
      means the server sent no files at all
- [x] **Employer application filters and the private-note UI, 2026-08-20.** Both
      halves had been sitting in the repository unused: `forVacancy` never sent
      the `status` the endpoint accepts, and `notes`/`addNote` had no screen at
      all.
      **The stage filter is the server's**, so a filtered list is complete rather
      than filtered-over-what-was-loaded — the same distinction the invitation
      sent list draws against the Coin ledger's client-side one. Eight stages
      plus "all" are chips rather than `HhSegmented`, which at 360pt would give
      each of nine about 37pt.
      `ApplicationStage.all` is new and drives the chips, so a ninth status
      needs a label and nothing else. It includes the **exits**, `withdrawn`
      among them: that one is the candidate's alone to set and still the thing an
      employer wants to filter out. §8.1 also names a "vacancy-closed" stage and
      the database has no such status — a vacancy closing does not rewrite its
      applications — so it is deliberately absent.
      **An empty stage reads differently from an empty vacancy**: one is fixed by
      clearing the filter, the other by waiting, and telling an employer looking
      at "Hired" that nobody has applied would be false.
      A stage move invalidates the **filtered** list by name as well as the
      unfiltered one, because moving somebody out of "Submitted" while that
      filter is on removes a row from what is on screen.
      The note sheet is **append-only**, matching an API that offers GET and POST
      and no edit: a dated observation silently rewritten later is worse than two
      notes, because the first one is what the employer acted on. It says the
      candidate never sees it, because a recruiter who is not certain of that
      writes nothing useful
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
- [~] Invitations + response tracking (UAT-07); general invitations.
      **The candidate half shipped 2026-08-19**; the employer half is next.
      The 2026-08-10 re-scope said this could not finish before M12, and M12
      landing showed the blocker was narrower than recorded: **the server does
      not require an unlock to send an invitation.** `invitations.service.ts`
      checks BR-03 and BR-02 and nothing else, and a merely `sent` invitation
      answers `exposureReason: unlock_required` — so it carries no contact
      context until the candidate **accepts**, at which point the code becomes
      `accepted_invitation` and contact opens. The gate is acceptance, not
      payment. §8.2's prose disagrees; see the item below it
- [x] ~~**§8.2 says unlock *then* invite, and the server does not**~~ —
      **answered by the client 2026-08-19: sending is free.** What settled it was
      not the server but the specification arguing with itself. §7.3 lists "Send
      invitation" beside "View profile" and "Save" — two explicitly free actions —
      in the sentence right after the one saying phone, e-mail and CV are locked.
      And §7.4, the client's own worked example, fills **20 openings** by sending
      invitations in step 6; filling 20 takes far more than 20 invitations, and at
      2 Coins each the employer would spend over a million som before a single
      reply, with the 10-Coin registration bonus covering five people. §8.2's
      "then" is one word against two sections and a running server. Recorded for
      the client as a spec correction, not a code change. The original note is
      kept below because the reasoning generalises.
- [-] ~~**§8.2 as revised says unlock *then* invite, and the server does not.**~~
      The sentence reads "To initiate direct contact … the employer must have a
      Candidate Unlock entitlement for that candidate. An invitation **may then**
      be attached to an active vacancy or sent as a general work invitation." The
      word "then" makes the unlock a precondition of *sending*. The backend has
      no such check, and its own integration tests assert the looser behaviour.
      **Not resolved in the client, deliberately.** Enforcing it here would be
      the client deciding when money must be spent, which §12.3.1 puts on the
      server — and if the client gated while the server did not, an employer
      would be told to pay for something the API would have accepted free.
      Needs a one-line answer, and it is the same shape as the §11.1 question
      that was already emailed: is an invitation a *contact* action (pay first)
      or a *request* to make contact (pay when they say yes)? The second reading
      is what the server implements and it is the more defensible one — an
      employer should not pay to be declined. *Blocks nothing today: the
      candidate inbox is unaffected either way, and the employer's send screen
      is the one that would carry the gate.*
- [x] **A daily invitation cap, server-owned, 2026-08-19.** With sending free
      and uncapped, a verified employer could send an unbounded number — no limit
      existed in the service or in the specification. The client asked for a daily
      cap and said extra invitations may become **purchasable** later, which is
      what settled ownership: the moment a quota can be bought it is a balance,
      and §12.3.1 puts balances on the server. So the client holds **no number**
      and refuses no send on its own authority.
      The backend shipped it the same day: `GET /invitations/quota` returning
      `{remaining, limit, resetsAt}`, `EMPLOYER_DAILY_INVITATION_LIMIT` defaulting
      to **30**, and a 409 `invitation.daily_limit_reached`. Two shapes worth
      keeping: `limit` is the **effective** total rather than free-plus-purchased,
      so the client models no tiers and a future purchase raises the number with no
      client release; and the day is a **calendar** day in `PLATFORM_TIME_ZONE`,
      because "it resets at midnight" is something an employer can plan around and
      "one more in 7 hours 22 minutes" is not.
      **An absent quota blocks nothing.** A 404 or an unreadable body means "this
      server has no cap" — no counter, nothing disabled — because a form disabled
      by a counter that failed to load would refuse sends the API accepts. Pinned
      and mutation-verified both ways: hard-coding 30 fails the fixture whose limit
      is 47, and treating an absent quota as blocked fails the no-quota test.
      **The 409's figures are in a nested `details` object, not at the top level**
      — caught before shipping by reading `localized.exception.ts`, which spreads
      nothing on purpose so a key cannot collide with `statusCode`, `code` or
      `message`
- [x] **Candidate invitation inbox (§8.2, UAT-07's second half), 2026-08-19.**
      Three actions rendered from the status rather than as a fixed row of three,
      so an answered invitation offers nothing and one already at
      `details_requested` no longer offers to ask again — the server refuses
      both, and offering a refusal is worse than offering nothing.
      **Accepting is a disclosure and the sheet says so before the button**: it
      names the phone, e-mail and CV by name rather than saying "your contact
      details", because a candidate cannot weigh a category, and it states that
      the status is final. That is the most consequential tap in the product and
      §8.2 gives it no way back.
      **"Request details" requires its question**, though the server takes the
      note as optional: "the candidate asked for details" with nothing attached
      is a message the employer cannot answer. Same idiom as the leveled field
      editor opening its level picker immediately. Declining takes an optional
      note, marked optional in the label, because a decline owes no reason.
      **No price, balance or unlock appears anywhere on the screen** — swept by a
      test, because the way this regresses is a well-meaning "top up to reply"
      landing on the wrong person's screen. §8.2's entitlement is the employer's.
      A **vacancy** invitation fetches and shows its posting, and 404 renders as
      "no longer available" rather than as a fault: the inbox is deliberately not
      filtered by whether the vacancy is still visible. A **general** one shows
      its own occupation, place, pay and schedule, every id resolved (BR-13).
      **Running the tests found a real overflow**: the card header was a row with
      the timestamp pushed right, and "Details requested" beside a timestamp
      needs 330 of a 360pt card's 298. It is a `Wrap` now — a badge is icon plus
      word, so truncating it would put the state back on colour alone. Pinned at
      the design's own QA case, 320pt at 2.0x, and mutation-verified
- [x] **Employer send, 2026-08-19.** `POST /invitations` behind a compose
      screen with §8.2's two shapes on a segmented control, reached from §7.3's
      candidate profile. **No price and no unlock on the screen**, swept by a test
      for "coin", "unlock", "uzs" and "top up" — and it says sending is free,
      because an employer who thinks inviting costs Coins will not invite.
      Only **open** vacancies are offered (BR-06): the server refuses the rest
      with `invitation.vacancy_not_open`, and an employer with none gets a notice
      rather than an error, because the general shape needs nothing published.
      Switching shape clears the other shape's binding, so `shape_invalid` is
      unreachable rather than merely unlikely; negotiable pay discards a typed
      range rather than qualifying it.
      Two of the server's refusals are **outcomes rather than exceptions**, since
      they change what the screen offers: the quota 409 and `already_invited`.
      Both share status 409 and are told apart by `code`, not by status — reading
      the status alone would conflate "not today" with "you already did this", two
      states with different remedies.
      Not offered where a send would *fail* rather than merely be declined:
      `not_verified_employer` (BR-03, and the exposure notice already routes there)
      and `hidden_by_candidate` (BR-02 — the server will not accept an invitation
      to somebody the employer could not have found)
- [x] **Employer sent list + §7.4 counts, 2026-08-20.** `GET /invitations/sent`
      behind a screen reached two ways: unscoped from the Candidates tab, and
      scoped to one vacancy from the §7.4 counts card. Both filters are the
      **server's** — unlike the ledger's, these are real server-side filters, so
      a filtered list is complete rather than filtered-over-what-was-loaded, and
      "Accepted" means every acceptance rather than the acceptances on the first
      page. That is also why there is no "showing some of possibly more" caveat
      here and there is one on the ledger.
      Five statuses are **chips and not `HhSegmented`**: segments divide the
      width equally and clip to one line, which at 360pt gives each about 66pt,
      and "Details requested" does not fit that in any of the four variants.
      **An acceptance is announced rather than badged.** BR-09's `expose()`
      grants contact details *and* files on an accepted invitation, at the same
      strength as an application and with no Coin — and it survives the candidate
      hiding their profile, because that branch only fires when there is no
      application, no invitation and no unlock. The notice says the unlock is not
      needed, because an employer shown a paid unlock on every other candidate
      screen has every reason to assume one is.
      §7.4 step 7's four counts are joined from **two** endpoints in the
      applicants card, and "invited" is the **sum of every status** rather than
      `byStatus.sent`: a candidate who answered was still invited, so reading
      `sent` would have looked right until the first reply and then counted
      downwards. Both halves are watched independently, so a vacancy whose
      invitation counts 404 still shows its hiring progress
- [!] **Backend ask: two routes §6.2's dashboard needs.** Neither blocks the
      screen, which ships without them, and both are one request each:
      1. **`GET /employers/me/dashboard`** — a summary. The dashboard currently
         fans out **two requests per active vacancy**
         (`/vacancies/{id}/applications/counts` and `/invitations/counts/{id}`)
         because there is no aggregate anywhere. Fine for the handful an employer
         runs at once, wrong in principle, and it is the client doing arithmetic
         that a single query would do better. When it lands the screen loses the
         fan-out and nothing else about it changes.
      2. **An employer's interview list.** `GET /interviews/mine` carries
         `@RequireRole('candidate')`, so there is no route an employer may call —
         which means the design's third header metric ("5 Suhbat") cannot be
         built at all. **Not a client gap, a contract gap**, and §6.2 lists
         Interviews as one of its seven widgets. Until it exists the header shows
         the three counts that *are* answerable rather than a placeholder where a
         number should be
- [!] **Backend ask, one request covering three gaps in `/invitations`.** All
      three are the same shape — the employer's side of §8.2 can say *what* was
      sent and not *to whom*:
      1. **`candidateName` on `InvitationDto`.** A sent list has
         `candidateUserId` and no name, and the client-side substitute is the
         wrong one: `GET /candidate-search/candidates/:id` logs a protected-data
         access per call (§11.1) and its own contract says it "is never called
         speculatively", so resolving thirty rows would write thirty audit
         entries nobody asked for — into the log BR-09 exists to make meaningful.
         **The client already parses the field** (`Invitation.candidateName`,
         null everywhere today), so the name appears the day it is sent with no
         client release. §7.3's "permitted name", and null where a name may not
         be shown.
      2. **A `candidateUserId` filter on `GET /invitations/sent`**, so a card
         can ask "did I invite this person?" without pulling an employer's whole
         history — the endpoint is unpaged.
      3. **Or the invitation status on `CandidateCard`**, which is what (2) would
         be used for. The vacancy card carries `applicationStatus` so Apply is
         offered exactly when valid (BR-07); `CandidateCard` has `isSaved` and
         `isShortlisted` and nothing about invitations, so a search result cannot
         show "already invited" and the employer learns it from a 409. Handled
         honestly meanwhile — that refusal reads as a fact, not a failure
- [x] **Vacancy shortlist screen (§7.3), 2026-08-20** — the last M7 item, and
      the note above was wrong about the state of it: the repository had the
      `PUT` and the `DELETE` and **no `GET`**, so `isShortlisted` was parsed on
      every card and rendered nowhere, and `setShortlisted` was called from
      nowhere at all. The whole feature was dead code with a screen missing at
      each end.
      **A shortlist is per-vacancy, so the vacancy is part of the list's
      identity rather than a filter over one.** The screen hangs off the vacancy
      (`/employer/vacancies/:id/shortlist`, beside `applicants`), and the
      provider is keyed by vacancy — an employer filling two roles keeps two,
      and the same candidate can be on both, one or neither.
      **The card's shortlist action exists only where a vacancy does.** Absent,
      not disabled: `isShortlisted` is false for everybody in a list fetched
      without a vacancy — *including* people who are shortlisted somewhere — so
      a control there could only lie. That is what makes the search screen pass
      the vacancy the **results** were fetched under rather than the one
      currently configured.
      Three things found while building it:
      1. **The match badge was claiming a number nobody computed.** With no
         filters the server has nothing to have matched and scores every card
         **100** — so the shipped saved-candidates list has been telling
         employers that every person on it is a 100% match. `showMatch: false`
         in both lists; the search screen keeps it.
      2. **Both toggles reverted their own labels.** The card renders a value
         from a list its parent loaded, and a successful write left that value
         alone — so "Save" stayed "Save" and read as a failure. A local override
         per card, rather than re-fetching a list and reordering the rows under
         the finger that tapped.
      3. **A prefill could leave stale results on screen.** UAT-06 writes the
         configuration from the vacancy editor and navigates, which does not go
         through the path that clears results, and this screen keeps its state
         across tab switches — so the previous search's cards could sit under
         somebody else's requirements, the one state the screen's own doc says
         must never happen. Results are painted only while they answer the
         configuration on screen, the vacancy included
- [x] **The brand mark, its lockups and the Android launcher icon, 2026-08-20.**
      §01 of the design document, delivered by the designer and implemented as
      `HhBrandMark` / `HhBrandWordmark` / `HhBrandLockup` /
      `HhBrandLaunchPlate`, plus the adaptive and legacy launcher icons and a
      navy platform launch window.
      Two API shapes are load-bearing. The mark takes a **ground, not colours**,
      because "turquoise on white" and "both figures turquoise" are two of the
      four documented misuses and selecting by ground makes them unwritable. And
      it **switches to the single figure below 20pt** on its own, because the
      pair fuses there — a rule a caller has to remember is a rule that breaks at
      the fourteenth call site. The consequence to know is that the crop changes
      from 23 : 19.8 to 10.7 : 19.8, so the mark is taller than wide under the
      floor.
      The launcher icon is **vector, not PNG**: there is no rasteriser on this
      machine, and one file beats five that can drift. `mipmap-anydpi` serves
      API 24/25 and `mipmap-anydpi-v26` serves the rest, which is the same
      resource-precedence mechanism every adaptive-icon setup already uses, one
      level further down. Flutter's default logo mipmaps are deleted rather than
      left as dead weight in the APK
- [x] **The Android build was run and passed, 2026-08-20.** `flutter build apk
      --debug --flavor development` built `app-development-debug.apk` in 56s, so
      AAPT2 accepted both vector drawables and the resource precedence resolves.
      The KGP warning still names **only `file_picker`**, which is what it named
      before the brand work — nothing new was added to it. The note below is kept
      because the reason it could not be run here will recur.
- [-] ~~**The Android build could not be run in this session, so run it once.**~~
      Gradle failed at startup with `java.io.IOException: Unable to establish
      loopback connection` — an environment restriction, not a code problem, and
      it failed identically for `flutter build apk`, a direct `gradlew` call and
      a resource-only task. So **AAPT2 has never seen the new vector drawables.**
      Their geometry is checked by `test/core/design/brand_test.dart` (centring,
      the 48% and 56% ratios, the locked aspect, the safe-zone diagonal, the path
      data against the design) and every file is well-formed XML, but neither of
      those is the compiler:
      ```powershell
      flutter build apk --debug --flavor development
      ```
- [x] **Candidate attachments open, with no plugin, 2026-08-20.** The client
      chose the platform-channel route: `AttachmentOpener` fetches the bytes over
      the file's own `downloadPath` into an app-private cache directory, and
      thirty lines in `MainActivity.kt` hand it to the OS through a
      `FileProvider` and `ACTION_VIEW`.
      **The point of doing it this way is the KGP list.** Every pub package that
      opens a file is written in Kotlin and applies the Kotlin Gradle Plugin — the
      warning this project emptied on 2026-08-19 by removing `telegram_login`, and
      one future Flutter versions refuse outright. The app module's *own* Kotlin
      is not a plugin and does not appear on that list, so the feature costs zero
      entries. `path_provider` was promoted from transitive (already 2.1.6 via
      `file_picker`) and `androidx.core` needed no Gradle change: it is already on
      the compile classpath at 1.15.0 through the Flutter embedding.
      Four things are load-bearing and tested:
      1. **The path is followed verbatim.** It is scoped to whichever interaction
         entitles this employer, so the test asserts the string was passed through
         untouched rather than that a request happened.
      2. **Every tap re-downloads.** BR-09 is re-evaluated per download, so a copy
         on disk must never answer the next tap — a candidate who withdraws has
         to stop being readable mid-session.
      3. **The local name comes from the server's file id**, never from
         `fileName`, which is content a candidate typed: only a validated
         extension is carried over, so `../../shared_prefs/x` cannot become a
         path. Pinned with eight hostile names.
      4. **The provider authority is `\${applicationId}.fileprovider`.** Two
         installed apps cannot declare the same authority, so a literal would make
         §12.1's three side-by-side flavors fail at *install* time — which is
         later and stranger than a build failure
- [!] **`MainActivity.kt` has never been compiled.** Gradle would not start in
      the session that wrote it (see the note below), so the Kotlin is unverified
      in a way the XML is not: it has no well-formedness check and no test that
      runs it. `attachment_opener_test.dart` asserts the *contract* across the
      language boundary — the channel name, the authority, the read-only flag, the
      cache scope — but a typo in the Kotlin fails at the tap, not at the build.
      Build once and open a CV:
      ```powershell
      flutter build apk --debug --flavor development
      ```
- [-] ~~**Opening a candidate attachment needs a plugin decision — yours, not
      ours.**~~ Answered 2026-08-20: platform channel. BR-09 grants the file, the
      server serves it, and the client could not open it.
      What is already right: `CandidateFile.downloadPath` is parsed, and the
      **client has never constructed a file route** — the backend's guess that we
      had hard-coded the application-scoped one was wrong in our favour. There is
      simply no download anywhere in the app: `downloadPath` and
      `Attachment.downloadPath` are both read from JSON and used nowhere.
      What is missing is only the last step. `path_provider` is **already a
      transitive dependency** (2.1.6, via `file_picker`), so fetching the bytes
      to a cache directory costs nothing. *Opening* them needs a viewer plugin —
      `open_filex` or equivalent — and every candidate is written in Kotlin, so
      it would **apply the Kotlin Gradle Plugin**. That is the second name on a
      warning list the team deliberately emptied on 2026-08-19 by removing
      `telegram_login`, and future Flutter versions will refuse a build that has
      one. So this is not a decision to slip in.
      Three ways out, in ascending cost:
      1. **Live with the current behaviour.** The row says opening is not
         available yet, the way §6.7's top-up does. Phone and e-mail — the two
         things an employer needs to make contact — already work.
      2. **Show images in-app only.** `Image.memory` needs no plugin, so a photo
         attachment could open and a PDF could not. Half of the list behaving
         differently from the other half, for a reason no employer can deduce.
      3. **Add a viewer plugin and accept a second KGP entry.** The only option
         that actually opens a CV, which is the attachment that matters.
      Nothing is blocked on the backend: **follow `downloadPath` verbatim, never
      construct it.** It is scoped to whichever interaction currently entitles the
      employer — application, accepted invitation or unlock — and BR-09 is
      re-evaluated per download, so holding a path is not holding permission
- [!] **Check the launcher icon on an API 24 or 25 device.** It is the one file
      in `res/` that a modern launcher never exercises, and a vector launcher
      icon on Android 7 is the only part of this that rests on documented
      behaviour rather than on something already shipping in this app

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
- [x] ~~**Download a candidate's files.**~~ — **done 2026-08-20**, and the item
      above ("Candidate attachments open, with no plugin") is the record of how:
      `AttachmentOpener` plus thirty lines of the app's own Kotlin, no new
      package and no second KGP entry. This entry was already stale when it was
      read, which is the checklist rot MEMORY.md has an entry about.
      The `tel:` half is **answered rather than open**: the contact block offers
      **copy**, because the platform dialler takes a number from the clipboard
      and no dependency is needed for that

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
- [x] ~~**The §6.2 dashboard tile has no dashboard yet.**~~ — it does now, as
      of 2026-08-20. Kept below because the reasoning about *where* it lives still
      applies.
- [-] ~~**The §6.2 dashboard tile has no dashboard yet.**~~ `WalletTile` is built
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

## M8 - Chat and interviews *(§9.1 chat done 2026-08-20; interviews and deep links open)*

§9.1 changed on 2026-08-10: employer-initiated chat is enabled only once that
employer holds a Candidate Unlock for the candidate. **The candidate's side is
not gated** — someone who applied can still write, and must never be shown a
paywall that is not theirs.

- [x] **Conversation list + thread, 2026-08-20.** The Messages tab in **both**
      shells from one screen: `GET /conversations` is scoped by the caller's
      active role on the server, so the screen has no role branch at all. Its
      empty state is role-neutral for the same reason — two sentences chosen by
      role would need this screen to hold an opinion §9.1's gate already holds
      better.
      The thread is a **child of whichever tab rendered the list**, so it keeps
      the shell's nav bar and the back gesture. The path comes from the route
      that built the screen rather than from the active role: the role and the
      location can disagree for one frame during a switch, and a path built from
      the role in that frame lands in the other shell.
      Three things are load-bearing:
      1. **"Mine" is derived from the counterpart, not a stored user id.** A
         conversation has two participants and the server names the other one
         per caller, so `senderUserId != counterpartUserId` is "mine".
         `SessionActive` carries roles and a status and no id, and adding one so
         a bubble could pick a side would put a second answer to "who am I" in
         the app.
      2. **The preview line has three cases, not two.** The server sends the
         last message's *body*, and a message that carried only an attachment
         has none — so "active but nothing to quote" is a real state and it is
         not the same fact as a thread nobody has written in.
      3. **The header and the messages are two providers.** Sending appends a
         message and changes nothing in the header; blocking changes the header
         and appends nothing. One provider would re-fetch both on either, and
         the visible cost is the thread jumping to the newest message every time
         somebody blocks
- [x] **Sent / read indicators, 2026-08-20 — and no `delivered`.** §9.1 asks for
      three and the server sends two, deliberately: delivery is a property of
      push (M9), and a field set in the same statement as `createdAt` would be a
      fabricated answer. So a message shows **sent** or **read** and never a
      middle tick it cannot substantiate. Shown on **outgoing** messages only —
      on an incoming one `isReadByRecipient` answers whether the reader has read
      it, which they can see for themselves
- [x] **Report and block; read-only closed conversations, 2026-08-20.** Blocking
      states the consequence *before* the button: §9.1 makes it read-only for
      both sides whoever set it, and somebody reaching for this control is often
      reaching for a mute. Unblock is offered **only where `blockedByMe`** — the
      route cannot lift the other side's, and a control that looks like it can
      is worse than none.
      Three closed states over two badges, because the remedy differs: an ended
      interaction, a block by them, a block by you. A **live** thread carries no
      badge at all — badging the default would make the exception invisible
      among the rule.
      Reporting is on **incoming messages only** (a complaint about your own
      message is not what §9.1's queue is for), the reason is required because
      the row has to be actionable by a moderator, and the sheet says that
      nothing on screen changes — a report is filed, not applied
- [x] **Idempotency key on message send, 2026-08-20**, and the scope of it is
      the finding: **the key belongs to the draft, not to the conversation.**
      The server answers the same key carrying a different body with 409
      `idempotency.key_reused`, so a key held per conversation would survive a
      send that died in flight and then refuse the *next* message the user
      typed, permanently, naming nothing they did. The slot holds the draft
      beside its key; the same text retried reuses it and different text mints a
      new one. Cleared on success, so the same text typed twice is two messages
      — a retry is only a retry while the first attempt was never confirmed.
      Both halves are mutation-verified
- [x] **Employer entry points gated on the entitlement (§9.1); candidate entry
      points deliberately not** — 2026-08-20, and **the client holds no copy of
      the gate.** §9.1's rule is `HiringInteractionService` on the server, the
      same service that answers BR-09, so an employer who may read a phone
      number and one who may send a message are the same employer by
      construction. "Send a message" sits in the contact block of §7.3's
      candidate profile, where that entitlement has already been evaluated; a
      403 renders as the server's own sentence. Swept by a test in both screens
      for "coin", "unlock", "UZS" and "top up": the way this regresses is a
      well-meaning "top up to reply" landing on the candidate's screen
- [!] **§9.1's revised gate and the server disagree, and it is the same question
      already answered.** The 2026-08-10 revision says employer-initiated chat
      needs a Candidate Unlock; `HiringInteractionService` treats a live
      application as sufficient, exactly as it does for BR-09's contact
      exposure. The client answered *that* in the lenient direction on
      2026-08-19, and this is one question, not two — so chat follows it.
      Gating harder than the API would tell an employer to pay for something the
      server would have given them free. **Recorded for the client as the second
      instance of the §8.2 "then" pattern**, not as a code change
- [!] **Backend ask: a `file_purpose` code for a message attachment.** §9.1's
      "approved attachments" work in one direction only. *Receiving* one is done
      — a message's `downloadPath` is scoped to its conversation and
      `AttachmentOpener` follows it verbatim. *Sending* one needs an upload to
      `POST /files` with a `purpose`, and the dictionary has `cv`, `photo`,
      `certificate` and `evidence`. None is a message attachment, and the
      purpose is a dictionary row an admin edits at runtime (§10.3) — so
      inventing a code here would be the client inventing server data. One row
      and the composer grows a paperclip; the parsing and the bubble are already
      built and tested
- [ ] **The thread does not update itself.** No poll, on purpose: M9's push is
      what makes it live, and a timer asking every few seconds would drain a
      battery to answer "nothing yet" on a product whose users are often on
      prepaid data. The app bar carries an explicit refresh meanwhile, and a
      notification tap will reuse this route rather than introducing one
- [x] **Interview display by type + confirm / request another time, 2026-08-20**
      — §8.3's candidate half (UAT-09).
      **It lives on the application, not in a list of its own.** §8.3 hangs an
      interview off an application and that is where a candidate looks: the
      stage badge already says "Interview", and the card says *when*, *what
      kind* and *where*. A destination of its own would need a sixth bottom-nav
      tab (the design caps it at five) or a third segment on the applications
      tab — and "Собеседования" does not fit a third of 360pt on one line, the
      same measurement that kept §8.2's status filter off `HhSegmented`.
      **One request for a list of any length.** `GET /interviews/mine` returns
      every interview across every application, grouped by `applicationId` in
      Dart; an application with no interview — the common case — costs no
      request and renders nothing.
      Four things are load-bearing:
      1. **`hasPassed` compares instants, never wall clocks.** The wall clock
         carries the platform's +05:00, so comparing it to `now` is five hours
         out for a candidate abroad — in the direction that *hides* an interview
         they have already missed. Pinned by a fixture whose instant is in the
         past while its wall clock is still in the future, and
         mutation-verified.
      2. **A passed time is said, not hidden, and stays answerable.** The record
         of what was arranged is what a candidate who missed one needs to see,
         and the server still accepts a response — refusing here would be the
         client deciding on the employer's behalf that it is too late.
      3. **The phone type needed a sentence of its own**, because it is the one
         type with no detail field: the number is the candidate's own and
         already verified (BR-01), which is exactly why the employer was never
         asked to retype it, and without the line the card would be a time and a
         word.
      4. **A meeting link is copied, not opened.** `url_launcher` would be a new
         dependency against pubspec.yaml's load-bearing bounds, and the browser
         takes a URL from the clipboard exactly as the dialler takes a number —
         the same answer the contact block already gives.
      Asking for another time **requires saying which time**, though the server
      takes the note as optional: "the candidate wants another time" with nothing
      attached is a message the employer cannot act on, so the interview stalls
      with each side waiting for the other. Same judgement as §8.2's "Request
      details". Confirming takes an optional note and says the answer is
      changeable, because §8.3's only ending is the employer cancelling
- [x] **The candidate's application row now says which job it is, 2026-08-20** —
      found while placing the interview card. `Application` carries a
      `vacancyId` and no title, so the row had been rendering a stage badge and
      *nothing else*: a list of bare badges, and an interview card reading
      "Tuesday 14:00, in person, at this address" underneath one would have been
      unusable. The posting is fetched per row, the same treatment an §8.2
      invitation's subject gets, and a 404 reads as "no longer available" rather
      than as a fault
- [x] **The employer's half of §8.3, 2026-08-20** — schedule, move, call off,
      on the applicant row of §6.5's screen. One form for scheduling *and*
      rescheduling, because `PUT /interviews/:id` takes the whole DTO rather
      than a patch: the type decides which of the location and the link may
      exist at all, so a partial update would let a phone interview keep the
      address of the in-person one it used to be.
      **The picked time is the *platform's* wall clock, and the offset comes
      from the server.** This is the one place the app runs
      `ZonedTimestamp`'s conversion backwards, and `instantForPlatformWallClock`
      is where it happens. The offset is parsed out of a timestamp the server
      sent about that very application — a `+05:00` in Dart would be a second
      source of truth for the platform zone, wrong the day Uzbekistan
      reintroduces daylight saving and wrong by an hour for every interview.
      If that timestamp is unreadable the scheduling control is **absent**
      rather than falling back to the device's zone: booking an interview an
      hour off is worse than not booking one from this screen. Both halves
      mutation-verified.
      Three smaller decisions: switching the type **clears** the other type's
      detail, so `interview.detail_required` is unreachable rather than merely
      unlikely; the reschedule form says the candidate will be asked to confirm
      again, because the server resets the status on every edit and an employer
      nudging the time by ten minutes should not have to discover that; and the
      cancellation reason's label says **the candidate sees it**, since an
      employer writing "found someone closer" for their own records would be
      writing it to the person it is about.
      Still missing, and still only a metric: the **aggregate** list.
      `GET /interviews/mine` is candidate-only, so §6.2's dashboard shows the
      three counts it can answer rather than a placeholder where "5 interviews"
      would go
- [x] **Private notes were unreachable on a finished application** — found while
      placing the schedule button. The notes control sat inside the
      stage-move guard, and a hired or rejected application has no move left, so
      the one application an employer is most likely to want a note about was
      the one that offered none. Now outside the guard
- [ ] **Deep links switch role before navigating** where required *(moved here
      from M9 - routing infrastructure, not a notification feature)*
- [x] **The chat screens and the new badges have been looked at, 2026-08-20** —
      not on a device, but rendered from the real widget tree with the app's own
      bundled font and inspected as images. MEMORY.md has the recipe; it is the
      standing substitute while Gradle is down, and it is cheap enough to be
      worth doing *before* a device run rather than instead of one.
      **It found two bugs that every assertion passed through**, both the same
      root cause — a `Wrap` inside a `crossAxisAlignment: start` Column
      shrink-wraps, so its `alignment` has no free space to distribute:
      1. the conversation rows' timestamps came out **ragged** instead of
         right-aligned, which reads as a rendering fault rather than a layout;
      2. an outgoing bubble put its time and read receipt on the **left**, so
         the two sides of the conversation were told apart by colour alone.
      Fixed, and the fixes are noted where the trap is: `SizedBox(width:
      double.infinity)` for the row, the Column's own cross-axis alignment for
      the bubble
- [!] **Gradle cannot start on this machine, and it is not the sandbox.**
      `flutter build apk` fails in a second with `Unable to establish loopback
      connection`, with the sandbox off, from a plain shell, and on three JVMs.
      The cause is the JDK: since JDK 21 the selector's internal pipe on Windows
      is an **AF_UNIX socket pair**, and AF_UNIX `connect` on this machine
      answers `EINVAL` while `bind` succeeds and TCP loopback works fine.
      Reproduced in six lines of Java — see MEMORY.md, which also lists the seven
      flags that *cannot* help and why.
      **Android Studio hits the same wall**, since it runs the same Gradle on the
      same bundled JBR. The emulator is fine — `headhunter_pixel` boots and `adb`
      sees it; there is simply nothing to install on it.
      Two fixes: a **reboot** (it built in 56s earlier the same day, so the state
      changed rather than the project), or install a **JDK 17** — where the pipe
      is still TCP — and `flutter config --jdk-dir "<path>"`
- [ ] **Ask the designer about the composer's height** *(observation, not a
      bug)*. §9.1 is one of the surfaces the design document never drew, and the
      chat composer uses `HhTextField`'s multiline treatment: a persistent label
      plus a `1.6 × 52pt` minimum box, so an empty composer is about 110pt tall.
      That is the design system used exactly as written — every other multiline
      field in the app looks the same — and a chat-specific control size would be
      the one thing the "one control size for everyone" rule forbids. Worth a
      drawn answer rather than a unilateral shrink

## M9 - Notifications *(in-app done 2026-08-24; push blocked)*

- [x] **§9.2's in-app centre, 2026-08-24** — the audit reopened this (MT-005,
      High) and the contract had been waiting: `/notifications`,
      `/notifications/unread-count`, `/notifications/read` and the per-category
      preferences were all built server-side.
      **The sentence is the server's.** A row stores a message key and its
      parameters, and the text is rendered in the language of *this* request —
      so a user who switches language reads their whole history in the new one.
      The client shows it verbatim and branches on `event` and `targetType`
      instead. A client-side message table would be a second translation of one
      event, and it would be the one that goes stale.
      **Where a row leads depends on who is reading it.** A conversation opens
      in whichever shell has a Messages tab; an application opens the
      *candidate's* list, because an employer reaches applicants through a
      vacancy this notification does not name and guessing that id is a request
      the client has no business making. Where there is no honest destination
      the row is still drawn — BR-10's restriction notice **is** the
      explanation — and simply has no chevron.
      **The badge is its own request.** `unread-count` is one indexed count
      over a partial index because it is polled far more often than the list is
      opened; counting the page instead would under-report the moment there are
      more than twenty.
      **The entry point is a row, not a tab.** All three shells are full at
      five destinations — the same cap that keeps the wallet off the employer's
      bar and the audit log off the administrator's — so the row sits at the
      top of each role's first tab, carrying the count. A badge nobody can see
      is not a badge.
      **`account` is shown greyed out rather than omitted** (§9.2): a user who
      cannot find a switch assumes it is off. And the settings sheet says what
      switching a category off actually does — a disabled category stores
      nothing at all, so what is missed is missed rather than hidden.
- [?] **Push (FCM), and it is not blocked on code.**
      **See [docs/NOTIFICATIONS_SETUP.md](docs/NOTIFICATIONS_SETUP.md)** for
      what has to happen in the Firebase console and on the server.
      `POST /notifications/devices` takes a token and there is no token to
      give it: `android/app/google-services.json` still lists the **old**
      package names, deliberately, so Firebase refuses to initialise under
      `com.jobbridge.app`. Regenerating it in the Firebase console for the
      three flavor ids is the whole of the blocker; the in-app half above needs
      none of it, because the records exist server-side whether or not a push
      was ever delivered.

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

## M10 - Admin module *(§10.1 done 2026-08-21; §10.2 complete 2026-08-22;
§10.4 complete 2026-08-23)*

**The whole admin API was already built** — `src/modules/admin` on the backend
covers §10.1 through §10.5, audit log and retention included. So nothing in this
milestone is blocked on a contract except the one gap recorded below, and every
remaining item is a screen.

- [x] **Admin shell behind the admin role** — structurally it already was: all
      three shells are registered at once and the redirect chain has always
      activated the role a path names. What was missing was any screen behind the
      five tabs, so an administrator signed in and landed on a placeholder
- [x] **Dashboard counters (§10.1), 2026-08-21.** `GET /admin/dashboard`, and the
      screen splits what §10.1 writes as one paragraph, because it is two kinds of
      fact. Four counters are bounded by the period; five are **current state**,
      which is the backend's own distinction — what matters about a queue is how
      long it is *now*. "7 awaiting verification" under a date range would say
      seven employers waited during July, which is false and gets more false as
      the period ages.
      Four decisions worth keeping:
      **The client never invents "today".** The first load sends no dates at all
      and renders `period.from`/`period.to` from the response, because the
      server's default thirty days is thirty days in `PLATFORM_TIME_ZONE` and the
      device cannot compute that. The presets then count back from the **`to` the
      server echoed**, so the only arithmetic in Dart is subtraction from a date
      the server chose. Pinned by a fixture whose period ends on a date that is
      not today on any machine, and mutation-verified: `DateTime.now()` fails it.
      **A counter is a way in, or it has no chevron.** Verification navigates;
      moderation and complaints do not, because their screens do not exist yet,
      and a number that leads to a placeholder is worse than one that leads
      nowhere. The next slice passes a destination and nothing else changes.
      **Restricted and blocked are two figures.** §10.1 says "restricted users"
      and the DTO carries both; summing them would hide the more serious state
      inside the milder one, which have different remedies (§4.2 versus BR-10).
      **The header is not the employer's navy panel.** §6.2 inverts to navy so
      the two roles are instantly distinguishable, and §2.3 makes the switch a
      runtime one — so reusing that panel here would defeat exactly the thing it
      exists for. The administrator's surface is a work queue on the app's own
      ground
- [x] **Employer verification (§10.2), 2026-08-21 — and it unblocks the whole
      employer side.** BR-03 gates every employer action: no vacancy may be
      submitted and no invitation sent until the profile is verified, and there
      was **no path through the product to grant that**. An employer could
      register, complete a profile, upload documents and wait forever; the only
      remedy was a hand-written API call. That is why this queue went first.
      **The list is the review.** Every field §10.2 asks for arrives in the queue
      response, evidence included, so there is no detail route: one would spend a
      round trip re-fetching what is in hand and cost the administrator their
      place in the queue.
      **The order is the server's and nothing re-sorts it** — oldest first,
      because a queue that is not FIFO is a queue somebody waits in
      indefinitely. The card says how long its submission has *waited*, which is
      the fact the ordering is for and which a timestamp does not give; computed
      from the **instant**, never the wall clock, since the platform's +05:00
      would understate the wait for an administrator abroad. Mutation-verified.
      **The reason is required for anything but an approval.** The server refuses
      with 403 `employer.verification_reason_required`; re-making that here turns
      a refusal into a disabled button, and §6.1 shows the text to the employer
      **verbatim** — a rejection with no reason is a screen saying the documents
      were refused and not saying what to fix. So the label says the employer
      reads it word for word.
      **A 409 is an outcome, not a failure.** Two administrators working one FIFO
      queue produce `employer.verification_not_pending` normally, and the work
      *is* done — so the row leaves the queue exactly as it would on success and
      only the confirmation differs. Told apart by `code`, not by status.
      **A decided row leaves without a refetch**: everything above it is older,
      so a reload would reorder nothing, cost a request, and shift the list under
      the finger of somebody working down a page. Only §10.1's counter is
      invalidated, because that figure did move.
      Evidence opens through the existing `AttachmentOpener` — the server's own
      `path`, followed verbatim, and **nothing prefetches**, because §11.1 logs
      every read of protected data and a speculative fetch would write audit
      entries nobody asked for
- [x] **Vacancy moderation (§10.2, BR-04), 2026-08-21 — the mirror of BR-03, and
      the other half of making the product work end to end.** No vacancy reaches
      a candidate until a moderator passes it, and for a **BR-12 restricted**
      vacancy this queue is the *only* route to publication there is. With the
      verification queue beside it, both gates are now answerable from a phone.
      **The queue tab holds both of §10.2's queues behind two segments**, because
      §10.2 is one section and the shell is capped at five tabs — the same cap
      that kept Wallet off the employer's bar. Two segments at 360pt give each
      about 175pt, which fits both labels in all four variants; the filters that
      were kept off `HhSegmented` had five and nine.
      **Which queue is showing lives in the *location*, not in state.** The shell
      keeps a branch across tab switches, so a segment held in a `State` would
      ignore a later `go` — and §10.1 has a counter per queue, so both counters
      would land on whichever was last looked at. That is the class of bug
      `switchRoleAndGo` exists to prevent one level up, so `?queue=` is a query
      parameter and tapping a segment navigates. Pinned three ways, including an
      unrecognised value landing somewhere real.
      **Unlike verification, the row is not the review.** §10.2 asks for the
      details, the requirements and the contact information by name, and
      approving a job posting on its title is not reviewing it — so the row opens
      `/admin/queue/vacancies/:id`, a child of the tab so back returns to the
      queue. What the row *does* carry is the thing that decides how urgently it
      needs opening: whether there is a BR-12 restriction to judge.
      **The restriction comes first on the review, above the title**, because it
      is why the vacancy is on that screen rather than published already — with
      the bound, the justification the employer picked, and their own words
      verbatim (§2.4). And it states the *task*: a limit is allowed only where
      the reason requires it, so judge the reason. Four labels and no question
      would have been a card nobody knows what to do with.
      **Approving is publishing**, so the confirmation says both halves: it goes
      live now, and for a restricted vacancy approving the vacancy approves the
      restriction with it. There is no approve-without-publishing, and §10.2's
      pause-or-remove is a different route on a *published* vacancy — see below.
      The requirements render through the **same widget §5.6 uses**, extracted
      for this: a moderator shown a *preference* drawn as a requirement would
      reject a vacancy for a condition it never imposed, and that rule is the
      first thing a second copy would lose
- [x] **Complaint queue (§10.2), 2026-08-22 — and it closes §10.2.** The third
      and last of the section's queues, and the one that gives
      `PUT /admin/vacancies/:vacancyId/status` the entry point it never had (see
      the item below, now closed). All three dashboard counters navigate.
      **One queue over four target kinds, and no filter.** The server made
      `complaints` a single generic table so §10.2 is one queue rather than four,
      and a moderator works a queue — the oldest open complaint is the oldest
      open complaint whatever it is about. The `targetType` filter is on the
      route and has no control: four kinds plus "all" is five segments, and
      `HhSegmented` was already ruled out at five for the vacancy status
      filters. The kind is on every row instead, as a **meta chip rather than a
      badge** — every complaint in this queue has the same *status*, `open`, and
      spending the badge vocabulary on a classification is how that vocabulary
      stops being learnable.
      **The remedy comes before the outcome, and the ordering is the design.** A
      review is *two* requests: `POST /admin/complaints/:id/review` records what
      was decided, and pausing the vacancy or warning the person is its own route
      with its own audit row. They are not one transaction and the client cannot
      make them one — so the screen does not hide that behind a single "uphold"
      button. Hiding it would leave a complaint marked `actioned` with nothing
      done, or a vacancy paused with the complaint still open, and nothing on
      screen to say which. Pinned by a geometry assertion, and mutation-verified.
      **The resolution is mandatory on both outcomes**, unlike the other two
      queues where only a refusal needs a reason: nothing else records a
      complaint review — there is no BR-08 status row standing behind it — so the
      audit entry is the whole account of it, and a *dismissal* is the half
      somebody asks about later. It also gets its own field label: the default
      one promises the employer reads the text verbatim, which is true of a
      verification refusal and false here
- [x] **§10.2's pause-or-remove, 2026-08-22.** `PUT /admin/vacancies/:vacancyId/status`
      applies to a vacancy that is **already published**, and nothing in the app
      could reach one — the moderation queue only ever holds `under_moderation`,
      and there is no admin vacancy list. A complaint about a live vacancy is the
      honest way in: it is the case §10.2 describes ("a complaint upheld, a
      policy breach"), and it arrives with the mandatory reason already written
      down by somebody else.
      **The offered transitions come from the server's table**, not from the two
      values the DTO accepts: `active → paused | closed`, `paused → closed`,
      `closed` terminal (BR-11). A closed vacancy offers neither and the section
      says so, because a button that answers 409 every time it is pressed is
      worse than an absent one. Restating a server rule is safe in this
      direction — the client is the stricter of the two — and the cost if the
      table moves is a hidden action rather than a broken one.
      Its 409 is `vacancy.transition_not_allowed` and is **deliberately not**
      `AdminDecisionConflict`: that one means "somebody decided this and the work
      is done", and this one means the vacancy is not in a state the action
      applies to. Telling an administrator otherwise sends them looking for a
      decision nobody made
- [x] **Warn a user (§10.4), 2026-08-22** — reachable from a complaint because it
      is what an upheld complaint about a person most often deserves, and because
      a reported **message** is answered through its *sender*: nothing edits or
      removes a message, since §7's chat history is evidence. A warning changes no
      account status — the audit row **is** the record. Restrict, block and
      unblock stay with §10.4's own screen, because a temporary restriction needs
      an until-date and a warning does not
- [x] **The three backend asks are settled, 2026-08-22 — see
      [docs/BACKEND_ASKS.md](docs/BACKEND_ASKS.md)** for the full accounting.
      Two implemented and deployed the same day they were written up, one
      declined with an argument good enough to close it.
      **The employer is on the review now.** `employer_name`, `employer_phone`
      (the account/login number, and §10.4's search key) and
      `employer_contact_phone` (the number published for the company, §6.1
      mandatory). The card leads with the published one because that is what a
      moderator would dial, labels both, and draws one when they agree.
      Two things came back different from the guess and cost a client release:
      **there is no e-mail anywhere in this product** — login is phone + OTP
      (§4.1) and every contact field is a phone number, so the `employerEmail`
      getter written on the 21st was removed on the 22nd — and there is a *third*
      field nobody had asked for. The idiom still paid: name and phone were
      already parsed, so the card lit up **on the next fetch with no release**,
      and only the refinement needed one.
      **The `Z` timestamp was a real contract break, and its class had two more
      members.** `VacancyReviewDto.vacancy` carried four unformatted timestamps
      in the *same response* — invisible only because nothing here reads a
      timestamp off that row — and the audit log's `details` bag stored one via
      `toISOString()`, which a `jsonb` bag admits no read-side fix for. All
      formatted server-side.
      **One consequence for a screen not built yet:** the audit log's `details`
      is an opaque key/value bag. Render it as text; do not parse values
- [x] **Every route in the API now declares a response schema, 2026-08-22.**
      `/docs-json` has answered 404 since 2026-08-20, so the checked-in
      `docs/openapi.json` is the only contract document there is — and six admin
      GETs had **no `responses.200` content at all**, not a partial description.
      All six now do (asked for three, got all six), so from here **a route
      missing from that file is a bug rather than a gap** — say so rather than
      working around it. The only deliberate exclusions are the two payment
      callbacks, whose audience is Payme and CLICK.
      **Read the checked-in file, not the running server.**
- [x] **User search + warn/restrict/block/unblock with reason (UAT-14),
      2026-08-23 — and §10.1's last two dead-end counters now lead somewhere.**
      The five decisions worth keeping:
      **The tab does not search on open.** Every other §10 tab loads its list on
      arrival; this one waits, because `GET /admin/users` answers with phone
      numbers and §11.1 logs every read of protected data — so a tab that
      searched on open would write a log line every time somebody passed through
      it. That is the same rule that keeps the verification queue from
      prefetching evidence. The one exception is arriving from a dashboard
      counter, which *is* an administrator asking.
      **Which status the list is filtered to lives in the location**, and only
      that one of the six filters does. §10.1's "restricted users" and "blocked
      users" are places; "phone contains 9012" is a question somebody typed. Both
      figures had carried a number and no chevron since the dashboard shipped,
      and turning them on was passing a destination — `_Figure` grew the same
      optional `onTap` `_QueueRow` already had. In the *location* rather than in
      state for the reason `?queue=` is: the shell keeps a branch across tab
      switches, so two counters writing screen state would both land on
      whichever was tapped first. Pinned, and mutation-verified: adopting the
      parameter once instead of on every arrival fails two tests.
      **The phone is normalised at the point it leaves.** The match is a raw
      `LIKE` against an E.164 column, so `+998 90 123 45 67` pasted out of a chat
      matches **nothing** — the spaces are in the pattern. Every character but
      digits and a leading `+` is dropped in `toQuery()`, and the field goes on
      showing what was typed.
      **The offered actions come from the status**, not from the three values
      the route accepts — and unlike the vacancy transition table there is a
      second reason: `admin.status_unchanged` covers *two* unrelated situations
      on the server. "Already in that state" is the ordinary race and the work is
      done; "awaiting deletion" is BR-14's state, which no action may overwrite
      and no retry will resolve. Never offering an action on a
      `deletion_requested` account is what leaves the 409 meaning one thing, so
      it can be mapped to `AdminDecisionConflict` honestly.
      **The restriction's end date is an instant, not a day.** The server parses
      `restrictedUntil` with `new Date(...)`, which reads a bare `2026-09-01` as
      **UTC** midnight — 05:00 in Tashkent, so a restriction ended on the 1st
      would run five hours into it. The client sends `2026-09-01T00:00:00+05:00`,
      with the offset read from **the account's own `createdAt`** the way §8.3's
      scheduling reads one, never a `+05:00` written into Dart. Mutation-verified
      against a `+03:00` fixture. The sheet's caption says which end of the day
      it is and what leaving it empty means.
      Two smaller things: `showAdminDecisionSheet` grew an optional **date**
      field rather than a second sheet — the one thing a second copy would drift
      on is the 409 handling, which is the branch nobody exercises by hand — and
      `admin.cannot_target_self` is left to the server, because **nothing in the
      session carries the signed-in account's user id** and adding one to grey
      out a button on one screen is a wider change than the problem.
      *Not built here:* extending a live restriction. There is no
      `restricted → restricted` on the server, so changing an end date means
      lifting and re-restricting — two audit rows and a gap where the account is
      active. Worth asking about if an administrator ever hits it; it is not
      worth a contract change on a guess.
      **The filter semantics, confirmed at the contract 2026-08-22 and now in
      `docs/openapi.json`** — they are not guessable and two of them change the
      UI:
      - `phone` — a **substring**, not a prefix, minimum 3 characters. A number
        is remembered by its last digits, so the field must not say "starts
        with".
      - `name` — case-insensitive **substring**, minimum 2, matched against
        **five** columns: candidate profile name, individual employer's own name,
        company public name, company legal name, and the account's own
        `full_name`. The response's `name` resolves by the same order of
        preference, so a list and a detail cannot disagree. (Only seeded
        administrators have `full_name` — it is what lets an administrator find a
        colleague.)
      - `role` — a user who **holds** this role, not one whose only role it is.
        §2.3 lets an account hold several, so a candidate who also employs
        matches either. The label must not read as "is a".
      - `status` — exact.
      - `registeredFrom` / `registeredTo` — **both inclusive**, calendar dates in
        `Asia/Tashkent`. Same day for both means that one day.
      - **Paging will bite before the filters do.** Results are ordered *newest
        registration first*, then `limit`/`offset`. So an old account matching a
        broad filter sits **past the page rather than outside the filter**, and
        from the client those look identical. The empty state must not say "no
        such user" when it means "not on this page" — narrow filters beat large
        pages, and the screen should say so rather than leaving an administrator
        to conclude somebody does not exist
      Three more facts, same date:
      1. **`AdminUserDetailDto` carries no audit entries.** It is `AdminUserDto`
         + `statusHistory` (`StatusHistoryEntryDto`, BR-08) + `complaints`
         (`UserComplaintDto`). Audit rows are a **different endpoint and a
         separate fetch** — `GET /admin/audit` → `AuditLogDto`. Design the user
         screen around the two lists it actually gets.
      2. **It is emitted flat, not as an `allOf`.** The generator merged the
         inherited `AdminUserDto` properties into one schema, so expect ten on
         the object: `userId`, `phone`, `name`, `roles`, `status`,
         `restrictedUntil`, `createdAt`, `lastLoginAt`, `statusHistory`,
         `complaints`.
      3. `phone` is present because §11.1 releases contact data to this role and
         logs the read — BR-09's admin branch, and it is also the search key
- [x] **§10.4's audit log, 2026-08-23 — and §10.4 is closed.**
      `GET /admin/audit` → `AuditLogDto`.
      `AuditEntryDto.details` is an **opaque key/value bag**: its keys differ per
      `action`, are enumerated nowhere, and a client that guesses at them is
      wrong for the next action added. **Render it as text; do not parse
      values.** Any timestamp inside carries §2's offset — formatted at the write
      site, because a `jsonb` bag admits no read-side fix (see MEMORY.md).
      Four decisions worth keeping:
      **A uuid is a way in, not a name.** The DTO carries `actorUserId` and
      `targetId` and no names, and resolving one means `GET /admin/users/:id`
      per distinct id — a request that returns a phone number, a status history
      and a complaint list to obtain a string, and writes a §11.1 access log
      line each time. Twenty rows would buy a page of names with a page of
      logged reads of other people's contact details, on a screen nobody opened
      to read contact details. So the id is shown as it is and the row *opens*
      that account instead. Raised as an ask — one `actorName` field, resolved
      by the expression `GET /admin/users` already uses; see
      [docs/BACKEND_ASKS.md](docs/BACKEND_ASKS.md). The navigation is worth
      keeping either way: a name is not an account.
      **Only a `user` target links.** A vacancy id has no screen that would
      accept it — the moderation review holds only `under_moderation` ones —
      and a complaint id would open the review with its decide buttons live,
      which is how a complaint somebody already closed gets decided a second
      time. Same reasoning as §10.4's complaint list.
      **The action code is a string, and an unknown one renders as itself.**
      The set grows server-side (§10.3's dictionary edits and §10.5's wallet
      adjustment are already in it), so a build that has not heard of an action
      must still draw its row: a dotted code is a stable identifier somebody
      can search the backend for, and "unknown action" is not. Fourteen have
      sentences today.
      **It lives under the users tab, at `/admin/users/audit`, registered
      *before* `:id`.** §10.4 is "user management **and** audit" and both of
      the log's questions are asked about somebody an administrator is already
      reading, so a tab of its own would make following a trail switch branches
      and send the back gesture to the wrong place. The registration order is
      load-bearing — `:id` matches the literal `audit` as readily as a uuid —
      and is asserted against the **real** router rather than a hand-built one,
      because a test router would be asserting its own order. Mutation-verified
      by swapping the two.
      Reached three ways: the whole log from the users tab header, "everything
      done to this account" from any user screen, and "everything this
      administrator has done" from one that holds the admin role — offered only
      there, because only an administrator ever writes an audit row and an
      empty answer would read as a bug
- [x] **Dictionary management (§10.3), 2026-08-24 — and the release shell has
      no placeholder left in it.** Three screens deep rather than a table: the
      types, one type's items, one item's actions. A table with columns is the
      web panel §2.4 rules out.
      **The types come from the manifest, not from `DictionaryType.all`.** That
      constant says of itself that it is the prefetch list and "not for
      validation: the server remains the authority on what exists" — so an
      administrator's list built from it would be missing any type added after
      the build shipped, on the one screen whose job is to manage what the
      server has. A type with no name in this build shows its code, the same
      rule §10.4's audit actions follow.
      **The list is the unfiltered set.** `dictionaryProvider`, not
      `selectableDictionary`: BR-13 never deletes anything, so the questions
      "what did we retire" and "what did we merge into what" are exactly the
      ones a picker's list cannot answer. Retired and merged are two different
      chips, because they are two different facts.
      **A write is a delta.** Every dictionary write bumps the global revision
      through a trigger, so invalidating the provider re-reads with `since=`
      and merges what the client already knows how to merge. No admin read
      route was needed and none was asked for.
      **The 422 on activation is a translation, not a fault.** The database
      refuses to activate an item missing any of §3.2's four labels; the sheet
      says "it has no name in all four languages yet" rather than a status
      line. The 409 `dictionary.state_unchanged` is the ordinary race and
      closes the sheet as a success would.
      **Creating collects all four labels and never activates.** The client
      cannot know the set is complete until the database accepts or refuses an
      activation, so it creates inactive and asks separately — and a partial
      set is a legitimate draft, which the form says out loud rather than
      refusing.
      *Not built:* **editing an existing item's labels.** The only read is
      fallback-resolved, so a missing `ru` label arrives as the Uzbek one and
      writing it back would turn a fallback into a translation nobody made. The
      ask is in [docs/BACKEND_ASKS.md](docs/BACKEND_ASKS.md) and the screen says
      so rather than offering a field that would quietly do the wrong thing
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
- [ ] **`HhMetaChip` does not shrink its label** — its `Row` is
      `MainAxisSize.min` around an unconstrained `Text`, so a label wider than
      its card overflows rather than truncating. `HhRemovableChip` already
      solves this ("the label shrinks before the chip does") and the meta chip
      never got the same treatment, because everything using it until §10.4 was
      one word. Found by a widget test at 360pt, and **Russian would have
      shipped it broken** while English fitted (MEMORY.md, 2026-08-23). §10.4
      works around it by making dated facts captions; the component fix belongs
      with this pass, and changing the design system means **running the gallery
      on a device**
- [ ] Cached primary screens open without blocking; loading states complete
- [ ] Offline state explicit; retry safe; no duplicate writes
- [ ] Crash reporting + structured logging, no sensitive data
- [x] **Android release signing config** — `android/upload-keystore.jks` (RSA
      2048, valid to 2053, gitignored) read via `android/key.properties`; falls
      back to debug signing with a loud warning when absent, so a fresh clone
      still builds. Verified: the release APK is signed with SHA-256 `7C:1C:…`,
      not the debug key. See [docs/RELEASE.md](docs/RELEASE.md)
- [-] ~~**Register the release SHA-256 with BotFather** and fill
      `AppFlavor.production.telegramRedirectUri`~~ — **dead 2026-08-20.** The
      field it names was deleted with the rest of the Telegram client code on
      2026-08-19, so this was an instruction to edit something that no longer
      exists. Phone + OTP binds to no signing certificate; a release key needs
      registering nowhere. RELEASE.md §4 now says what a downloaded build
      actually needs — an SMS provider — and the fingerprint mechanics moved to
      docs/TELEGRAM_LOGIN.md, where they belong if the feature is ever revived
- [x] ~~App icons and launch screen~~ — **shipped 2026-08-20** with §01 of the
      design document: a vector adaptive launcher icon, the legacy round/square
      mipmaps, and a navy platform launch window. The one part still unverified
      is API 24/25, which is tracked in M7 above
- [ ] **Drop the `headhunter.apk` release alias.** The asset was renamed to
      `jobbridge.apk` on 2026-08-20 and the old name is uploaded beside it,
      byte-identical, because `latest/download/headhunter.apk` was already in
      the README, in RELEASE.md and in whatever chat it had been pasted into —
      renaming alone would have turned every one of those into a 404 against
      the *newest* release, which reads as a broken build rather than a moved
      file. Both names ship until the links that matter are updated; then delete
      the `cp` and the second `files:` entry in `release-apk.yml`. **Not before
      one release has carried both**, or the alias buys nothing
- [x] **A tag that disagrees with `pubspec.yaml` now fails the release run,
      2026-08-20.** v1.1.1 was tagged without the version bump and published an
      APK reporting **1.1.0+3** — the third time in four releases (v1.0.1 and
      v1.0.2 both shipped as `1.0.0+1`). The rule was already written in
      `CHANGELOG.md`, in `pubspec.yaml` and in `README.md`; what it was missing
      was a reader at the moment of tagging. `release-apk.yml` compares
      `GITHUB_REF_NAME` with the pubspec version as its **first** step, so a
      mismatch costs twenty seconds and publishes nothing. **1.1.2+4 is staged
      in `pubspec.yaml` and `CHANGELOG.md` for exactly this reason**: 1.1.1
      reuses build number 3, so a phone holding 1.1.0 refuses it as an upgrade
- [ ] **Also check the build number moved**, which the guard deliberately does
      not. It would need `fetch-depth: 0` and a `git show <prev-tag>:pubspec.yaml`
      to know the last released number, and the failure it would catch —
      bumping the name but not the build — has not happened yet. Worth adding
      the day it does
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
