# JobBridge Android 1.29.0 — Full QA, UX/UI, Business Logic & Technical Audit

Audit date: 2026-08-28 (Asia/Tashkent)

## 1. Executive summary

**Verdict: NO-GO for production.** Version 1.29.0 is stable in most candidate,
employer, admin, offline, and moderation flows, and it is a substantial
improvement over 1.17.0. The mobile quality gates are clean and all 1,210 Flutter
tests pass. However, four High findings remain release-blocking:

| Severity | Count | Finding IDs |
|---|---:|---|
| Critical | 0 | — |
| High | 4 | MT-006, MT-025, MT-026, MT-027 |
| Medium | 3 | MT-028, MT-029, MT-030 |

The most important new regressions are:

1. Language changes update the current screen but are not saved to the account;
   the account language also is not restored on a clean device (MT-025).
2. The Messages list starts under the Android status bar, obscuring the first
   conversation (MT-026).
3. Runtime role switching can race two `/auth/active-role` requests, enter the
   new shell with the wrong token, and show a 403 until Retry (MT-027).
4. The wallet advertises Top up but explicitly says it is unavailable; Payme and
   CLICK purchase UATs remain impossible (MT-006).

The deployed moderation flag is now correctly enabled, fresh multi-role login
works, complaint targets are understandable, abandoned upload retention is
implemented, semantics are materially cleaner, and `flutter analyze` is clean.
Those earlier blockers are verified fixed.

No mobile or backend product source code was changed during this audit. The
authorized static OTP was enabled only for testing, then removed; the backend
was rebuilt and verified healthy in its original production configuration.

## 2. Audited build and environment

| Item | Audited value |
|---|---|
| APK | `C:\Users\Developer-7\Downloads\jobbridge-1.29.0.apk` |
| Package | `com.jobbridge.app` |
| Version | `1.29.0` (`versionCode 39`) |
| APK size | 64,726,427 bytes |
| SHA-256 | `FF8A838B9ADF3717E5A395C995C6A3ABFE61883255621A9D00807EBE9FF4C8EF` |
| SDK | min 24 / target 36 / compile 36 |
| Signing | Existing Universal HeadHunter certificate; APK Signature v2 verified |
| Mobile source | exact tag `v1.29.0`, commit `3bdaf3e` |
| Backend source | commit `0cd1712` |
| Device | Pixel 8 emulator, Android 16 / API 36 |
| Display | 1080×2400, density 420; compact/large-text case also tested |
| Authentication | authorized DEV static OTP `666666`, removed after testing |

Fresh uninstall/install passed. The first cold launch after install completed in
5,644 ms. APK metadata and source tag match.

Evidence: [APK baseline](evidence/v1.29.0/apk-baseline.txt).

## 3. Release findings

### MT-006 — Coin top-up is still a non-functional promise

**Severity: High · Status: Open from earlier audit**

Employer Home → Wallet → Top up shows:

> Top-up is not available yet. It arrives with Payme and CLICK support.

The user can see a balance and UZS conversion but cannot purchase Coins. This
blocks the recovery path for an employer with fewer than two Coins and prevents
SPEC §6.7 and UAT-19 through UAT-23 from being accepted.

Recommendation: either deliver Payment Order + Payme/CLICK checkout and
idempotent crediting as specified, or remove/disable the active Top up promise
and clearly mark the entire Coin purchase capability as pre-release.

Evidence: [Wallet](evidence/v1.29.0/37-employer-wallet.png) and
[unavailable top-up](evidence/v1.29.0/38-top-up.png).

### MT-025 — Account locale persistence and clean-device restore are broken

**Severity: High · Status: New**

Two independent paths failed:

- Changing English to Russian immediately translated the current UI, but no
  locale PATCH was sent and the database value remained unchanged.
- After a clean sign-in, an account whose server locale was `uz-Latn` opened in
  English instead of restoring the account preference.

The Flutter runtime reported:

`Cannot use the Ref of localeSyncProvider after it has been disposed.`

Read-only source correlation points to an auto-dispose lifecycle error:
`LocaleSync.select` awaits the local locale change, which rebuilds/disposes the
provider, then attempts the server push through its stale `Ref`. Sign-in
reconciliation is also launched from an unretained provider.

This violates SPEC §3.2, UAT-01, UAT-13, and UAT-24. The wording on the Account
screen — “Stored on your account, so it follows you to your other devices” — is
currently false.

Evidence: [Russian UI after selection](evidence/v1.29.0/43-account-russian-repro.png)
and [reproduction trace](evidence/v1.29.0/MT-025-locale-sync.txt).

### MT-026 — Messages list violates the top safe area

**Severity: High · Status: New**

The first conversation begins at display coordinate `y=0`, underneath the
Android status bar. The participant name collides with the time and system
icons, and there is no page title to establish hierarchy. The issue affects the
shared Candidate and Employer Messages screen.

Read-only source inspection confirms the list/error/empty bodies are returned
directly without `SafeArea` or an app bar. This violates SPEC §12.1 and makes the
first conversation difficult to read and tap reliably.

Recommendation: give the tab a normal safe top inset and localized Messages
heading. Apply the same wrapper to loading, empty, error, and populated states.

Evidence: [Messages safe-area failure](evidence/v1.29.0/26-candidate-messages.png).

### MT-027 — Role switching races the router and access-token rotation

**Severity: High · Status: New**

Switching an existing multi-role account from Employer to Admin initially
opened Admin Dashboard with “This action requires admin.” Retry then worked.
Backend logs prove the race:

1. `/auth/active-role` for Admin returned 201.
2. An overlapping `/auth/active-role` for Employer returned 201.
3. `/admin/dashboard` returned 403.
4. Admin was published again; retry returned 200.

The client publishes local `activeRole` before token rotation. Router refresh
then sees the old Employer path and schedules a switch back to Employer. The two
token rotations overlap. This violates the reliable runtime role switch required
by SPEC §2.3.

Recommendation: make role switch one serialized transition. Do not expose the
new role to routing until the server has returned and the token store contains
the matching access token; suppress the old-path deep-link rule during that
explicit transition. Add an integration test that asserts one role publish and
the first protected request returns 200.

Evidence: [initial 403](evidence/v1.29.0/11-admin-home.png),
[successful retry](evidence/v1.29.0/11b-admin-retry.png), and
[API sequence](evidence/v1.29.0/MT-027-role-switch-race.txt).

### MT-028 — Sign-in dictionary warm-up is disposed before completion

**Severity: Medium · Status: New**

Every clean sign-in logged provider-disposal failures for all 17 warmed
dictionary types. The app remains usable because forms fetch on demand, but the
intended prefetch does not finish and first form entry pays avoidable latency.

Recommendation: retain the warm-up provider until its future completes, or move
the session-triggered prefetch into a non-auto-dispose lifecycle owner. Test the
network request count after sign-in and verify a subsequent form is served from
cache.

Evidence: [provider log](evidence/v1.29.0/async-provider-log.txt).

### MT-029 — Under-review Employer Home makes a guaranteed forbidden request

**Severity: Medium · Status: New**

Employer Home watches `savedCandidatesProvider` even while company verification
is Under review. The backend correctly protects `/candidate-search/saved` and
returns 403, while the dashboard silently hides the failed optional row. This
produces an error on every dashboard load for an account that is in a valid
pre-verification state.

Recommendation: do not request saved candidates until the employer satisfies
the server gate, or use a dashboard summary endpoint that returns only data the
current state may access. The UI should not rely on swallowing a predictable
authorization failure.

Evidence: backend request trace: `GET /candidate-search/saved → 403` while
Employer Home and verification endpoints returned 200.

### MT-030 — Backend lint release gate fails

**Severity: Medium · Status: New**

Backend typecheck and 543 tests pass, but `pnpm lint:check` exits non-zero for
three unused imports in the admin and wallet modules. This is not a runtime
failure, but it leaves the stated release gate red.

Evidence: [quality gates](evidence/v1.29.0/quality-gates.txt).

## 4. Functional and business-logic coverage

| Area | Result | Notes |
|---|---|---|
| Fresh install / upgrade identity | Pass | Correct package, version, signer continuity and source tag |
| Phone + OTP authentication | Pass | `+998941779737` + authorized `666666`; validation and phone edit path checked |
| New-user role selection | Pass | Candidate, Employer, and both-role selection behaved correctly |
| Existing multi-role fresh login | Pass | Earlier MT-022 is fixed; valid role is published before entering a shell |
| Runtime role switch | Fail | Intermittent wrong-token 403, MT-027 |
| Candidate Home / discovery / detail | Pass with UX notes | Category band is present; vacancy detail and apply entry open |
| Candidate applications | Pass | Active/interview/hired sections render correctly |
| Candidate invitations | Pass | Invitation list and status content render |
| Candidate profile | Pass with UX notes | Data sections work; account entry is excessively buried |
| Employer Home / company profile | Pass with technical note | Verification status and required/optional upload slots work; MT-029 |
| Employer verification document | Pass | Existing required document visible; replace/delete controls present |
| Employer wallet ledger | Partial | Balance and exactly-once bonus correct; top-up unavailable |
| Admin dashboard | Pass after role retry | Counts and navigation work; initial role race can block it |
| Vacancy moderation | Pass | Real moderation queue shown; deployed flag is enabled |
| Complaints | Pass | Target titles are shown; deleted objects fall back to references |
| Admin users / dictionaries | Pass | Lists, search/navigation and localized labels render |
| Admin wallets / pricing | Pass with gaps | Records and controls render; payment-order history is empty by design until provider integration |
| Chat list | Fail layout | First card under status bar, MT-026 |
| Chat thread / attachment | Pass with UX notes | Existing thread and attachment affordance render; composer is oversized |
| Offline cold start / recovery | Pass | Session retained, Russian offline copy clear, Retry recovered after network return |
| Push registration | Pass | Device registration returned 204 after login |
| Push delivery | Not re-triggered | No destructive admin notification action was used in this pass |
| Four locale variants | Partial | All options render and UI changes live; persistence/restore fail |
| 10-Coin registration bonus | Pass | New dual-role employer received one wallet and one bonus transaction |
| Payme / CLICK | Fail / not implemented | UAT-20 through UAT-23 cannot run |

Authorized DEV database integrity check:

`+998901130129 | uz-Latn | candidate,employer | 10 Coins | 1 registration bonus`

This passes BR-15 and UAT-16. Evidence:
[database check](evidence/v1.29.0/db-new-user-integrity.txt).

## 5. UX/UI audit and designer feedback

### 5.1 Language and phone number on one screen

**Direct answer: the current composition is not the best UX.** Keeping language
and phone on one page can work when language is a compact control, but this page
uses four full-width radio rows plus logo before the actual sign-in task. On the
normal Pixel screen the phone form is pushed into the lower half. At the audit's
320×568 dp-equivalent / 200% text case, the first viewport contains only logo,
languages, and the Sign in heading; the phone field is entirely off-screen.

This also weakens the sequence in SPEC §4.1: language choice and authentication
are two separate decisions, visually presented as one long form.

Recommended first-run flow:

1. **Language screen, first installation only.** Preselect the system-language
   match, show the four native names, one clear Continue action, and lightweight
   brand artwork.
2. **Phone screen.** Logo/short value statement, phone field, legal consent and
   Get code. Keep the language as a small top-right chip so it remains editable.
3. **OTP screen.** Six-digit input, phone edit, resend timer and assistance.
4. **Role selection.** Keep the current clear multi-select cards.

For returning signed-out users, do not force an extra language page every time:
open the phone screen directly and expose the saved language through the compact
top control. The full picker remains in Account settings. This gets the focused
Telegram-style progressive flow without creating permanent extra friction.

Evidence: [normal first screen](evidence/v1.29.0/01-fresh-auth.png),
[Uzbek selection](evidence/v1.29.0/03-auth-uz-latn.png),
[compact large-text first viewport](evidence/v1.29.0/34-auth-320-font200.png),
and [phone after scrolling](evidence/v1.29.0/35-auth-320-font200-signin.png).

### 5.2 Prioritized design recommendations

| Priority | Screen | Designer feedback |
|---|---|---|
| P0 | Messages | Add safe-area top inset and a real page heading; the first card currently collides with system UI. |
| P1 | First-run auth | Split language from phone on first installation; use a compact language chip on subsequent sign-ins. |
| P1 | Notification permission | Do not show the Android prompt immediately after OTP. First explain the value in-app, offer Later, and ask after onboarding or the first relevant notification setting. |
| P1 | OTP | Autofocus the code field, open the numeric keyboard automatically, support Android SMS autofill, and auto-submit after six digits while retaining resend/edit controls. |
| P1 | Chat | Replace the persistent label + tall textarea with a 52–56 dp composer: attachment left, one-line input that grows to four lines, send right. |
| P1 | Profile / Account | Do not require five or six swipes to find language, sign-out, sessions, role switch, and delete. Add a persistent top settings entry and split the long profile into clearer sections. |
| P1 | Bottom navigation | At 200% text, show labels only for the selected tab or use shorter localized labels. Preserve full semantic labels for accessibility. |
| P2 | Vacancy detail | The no-photo category hero is a large pale empty block. Use full hero height only with a photo; otherwise use a compact branded band or illustration/pattern. |
| P2 | Admin navigation | `Foydalanuvchilar` breaks awkwardly even at normal size. Consider a shorter approved label such as `Hisoblar`, or selected-label-only navigation. |
| P2 | Admin pricing | Shorten the app-bar title to `Narxlar` and put the complete heading in the body; the current title truncates at normal width. |
| P2 | Coin terminology | Use the protected product term `Coin` consistently. Uzbek admin pricing currently mixes `Coin` with `tanga`. |

### 5.3 Screen-level observations

- The role-selection cards are clear, comfortably tappable, and explain the
  effect of choosing both roles. Keep this pattern.
- Native language names are the correct choice; a user can recognize their
  option even when the current UI is unreadable to them.
- The notification OS dialog appeared immediately after OTP, including before a
  new user had selected a role. The interruption has no contextual rationale,
  and the OS copy may be in a different language than the app.
- Vacancy category bands improve scanning in discovery. On detail, the fallback
  occupies too much prime vertical space for the small amount of information.
- The chat thread itself respects safe areas, but its composer looks like a
  multi-field form and consumes too much of a conversation screen.
- Candidate and Employer profiles are technically complete but monolithic.
  High-frequency settings and exit controls should not depend on reaching the
  bottom of editable business/profile data.
- Admin `Foydalanuvchilar` and Russian labels fracture mid-word at large text.
  No Flutter overflow occurred, so this is a usability failure rather than a
  RenderFlex crash.
- The pricing preview formats UZS clearly, while the editable raw numeric field
  remains `10000`. Consider grouped input or a live formatting mask.

Evidence: [role selection](evidence/v1.29.0/19-role-selection.png),
[vacancy detail](evidence/v1.29.0/21-vacancy-detail.png),
[chat composer](evidence/v1.29.0/27-chat.png),
[profile bottom](evidence/v1.29.0/28-candidate-profile-bottom.png),
[Russian 200% navigation](evidence/v1.29.0/33-russian-320-font200.png), and
[admin pricing](evidence/v1.29.0/17-admin-pricing.png).

## 6. Accessibility, responsive layout, localization and offline behavior

### Accessibility

- Auth and role-selection UI dumps expose single combined semantic labels and
  no duplicate label groups; earlier MT-015 is materially fixed.
- Buttons and navigation destinations expose meaningful localized labels.
- Color is not the only indicator for selected roles/statuses.
- The Messages safe-area defect remains the primary accessibility/tap-target
  concern because system UI obscures content.

### Responsive and large text

- No RenderFlex overflow or app crash was observed at the compact 320×568
  dp-equivalent and 200% font case.
- The layout technically scrolls, but the combined language/auth page hides the
  primary field, and the bottom navigation consumes excessive height with
  mid-word wrapping. Passing an overflow test is not sufficient UX acceptance.

### Localization

- Uzbek Latin, Uzbek Cyrillic, Russian, and English options are present.
- Live UI translation works.
- Account persistence and cross-device restore fail (MT-025).
- `Coin`/`tanga` terminology and some long admin labels need editorial cleanup.

### Offline

Cold start with network disabled kept the signed-in session and showed a clear,
localized offline state. After connectivity was restored, Retry returned to the
real Home screen. This passes the expected graceful-degradation behavior in
SPEC §12.4.

Evidence: [offline](evidence/v1.29.0/31-offline-cold.png) and
[recovered](evidence/v1.29.0/32-offline-recovered.png).

## 7. Technical quality and security observations

### Automated gates

| Gate | Result |
|---|---|
| `flutter analyze` | Pass — 0 issues |
| `flutter test` | Pass — 1,210 / 1,210 |
| Backend typecheck | Pass |
| Backend tests | Pass — 32 suites, 543 / 543 |
| Backend lint | Fail — 3 unused imports (MT-030) |

### Runtime and performance

- Five cold-start samples averaged 3,023 ms; two were above 4.5 seconds on the
  emulator. Profile startup on representative low/mid-tier physical hardware.
- Five warm resumes averaged 20 ms.
- No crash or ANR was observed in the measured launch series.
- Locale and dictionary lifecycle errors are caught/logged rather than process
  crashes, but they still cause functional and performance defects.

Evidence: [performance](evidence/v1.29.0/performance.txt) and
[quality gates](evidence/v1.29.0/quality-gates.txt).

### Static APK/security checks

- Release manifest is not debuggable and does not opt into cleartext traffic.
- Declared permissions are limited to network, notification/push, wake-lock and
  related Firebase requirements; no camera, contacts, storage, microphone, or
  location permission is requested by this build.
- Exported Firebase receivers are protected by Google messaging permissions;
  the launcher activity is expectedly exported.
- APK certificate continuity was verified and Signature Scheme v2 validation
  passed.
- Backend request logs redact Authorization headers.

This was not a penetration test or third-party dependency CVE audit.

## 8. Verified fixes since the earlier audit

| Earlier finding | 1.29.0 result |
|---|---|
| MT-003 mandatory moderation disabled | Fixed — runtime `MODERATION_ENABLED=true`, queue works |
| MT-015 duplicate semantics | Fixed materially in sampled auth/role/navigation screens |
| MT-017 ambiguous complaint target | Fixed — target title shown, deleted fallback available |
| MT-022 fresh multi-role login 403 | Fixed — valid active role published before shell |
| MT-023 abandoned upload retention | Fixed in backend with seven-day orphan TTL |
| MT-024 dirty Flutter analyzer gate | Fixed — analyzer exits clean |

MT-006 remains open.

## 9. Release recommendation and acceptance checklist

Do not publish 1.29.0 as the production release until the four High findings are
closed and re-tested. Minimum acceptance checklist:

1. Locale change sends exactly one successful account update and survives
   sign-out/clean-device sign-in in all four interface variants.
2. Explicit role switch sends one serialized active-role request; the first
   protected request in the new shell returns 200 with no Retry.
3. Candidate and Employer Messages lists respect the status/navigation safe
   areas in empty, error, loading, and populated states.
4. Payme and CLICK UAT-20 through UAT-23 pass, or Top up is removed from the
   release scope and UI.
5. Dictionary warm-up completes without disposed-provider logs.
6. Under-review Employer Home performs no guaranteed 403 request.
7. Backend typecheck, tests, and lint all pass.
8. Re-run compact/200% typography acceptance after navigation and onboarding
   design changes.
9. Run a real background push delivery test on the candidate and employer roles.

After those items, repeat a focused regression on auth, fresh/returning locale,
role switching, messaging, wallet, moderation, offline recovery, and notification
delivery.

## 10. Environment restoration and change scope

The authorized QA configuration was restored and redeployed:

- `NODE_ENV=production`
- `OTP_STATIC_CODE=` (empty; `666666` disabled)
- `OTP_ECHO_IN_RESPONSE=false`
- `MODERATION_ENABLED=true`
- API container: healthy
- Local `/health`: `ok`
- Public `https://hh.qitmir.uz/health`: `ok`

Evidence: [restoration check](evidence/v1.29.0/backend-runtime-restored.txt).

No application or backend source file was edited. The only tracked project file
changed by this audit is this report; screenshots/UI dumps and audit traces are
local ignored evidence. Existing user files `guide.docx`, `guide.pdf`, and the
other unrelated workspace content were not touched.
