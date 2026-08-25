# Mobile Application Test & UX Audit

## 1. Executive Summary

This is a full regression audit of the user-supplied JobBridge Android APK
1.11.0 (version code 16). The APK was freshly installed and exercised on the
Android emulator against the deployed DEV API and PostgreSQL database. Candidate,
employer, newly registered employer, and administrator journeys were tested. The
mobile and backend product source was not changed.

Version 1.11.0 is a substantial improvement over 1.4.1. Ten previously reported
findings are resolved: Candidate Home, Admin Users, Admin Dictionaries, in-app
notifications/push delivery, first-employer validation, admin/employer sign-out,
dashboard/profile state refresh, incoming invitation wording, and unfiltered
candidate-search match scoring. File download now also works, though its purpose
label remains broken.

Regression status:

- 21 stable findings tracked across both audits.
- 10 previous findings verified fixed.
- 11 findings remain open: 1 Critical, 2 High, and 8 Medium.
- 2 new findings were added: MT-020 and MT-021.
- No source-code change was made by the auditor.

**Production release verdict: NO-GO.** Mandatory vacancy moderation is disabled
in the deployed environment, Coin top-up remains unavailable, and the new
notification center cannot mark one or all notifications read because the APK
uses `POST` while the backend exposes `PUT`. These are release blockers against
§6.4, §6.7, §9.2, BR-04, and UAT-20/21.

**DEV continuation verdict: GO WITH KNOWN ISSUES.** Core hiring flows are useful
for continued internal development. Rapid repeated taps created exactly one chat
message, saved vacancy, application, invitation, invitation response, and
employer profile. Background FCM delivery and deep-link opening worked.

## 2. Application / Build Information

| Item | Tested value |
|---|---|
| Product | JobBridge |
| APK | `C:\Users\Developer-7\Downloads\jobbridge (1).apk` |
| Package | `com.jobbridge.app` |
| Version | 1.11.0 (version code 16) |
| Size | 64,202,135 bytes |
| APK SHA-256 | `EE7E3B55FDC6C5E778CBA0BEAD92870C7770E6058364D1AA9624F219D6CC8FB0` |
| Signer | `CN=Universal HeadHunter, OU=Mobile, O=Uniconsoft, L=Tashkent, C=UZ` |
| Signer SHA-256 | `7c1cc81cfc5564f6563ebab3fe714e0e2ac32f18173f3609f786a09dffc5421f` |
| Mobile repository inspected | `86b8f6f` (`v1.11.0-1-g86b8f6f`) |
| Device / AVD | Pixel 8 / `headhunter_pixel` |
| OS | Android 16, API 36 |
| Normal viewport | 1080 × 2400, density 420 |
| Additional layouts | 2400 × 1080 landscape; 360 × 640 dp compact |
| Text scale | 100% and 200% |
| Backend | NestJS API + PostgreSQL 18 |
| API | `https://hh.qitmir.uz`; `/health` returned 200 and DB up |
| Runtime | `NODE_ENV=development`, static OTP `666666`, OTP echo off |
| Moderation runtime | `MODERATION_ENABLED=false` |
| Test date | 2026-08-25, Asia/Tashkent |
| Locales exercised | Uzbek Latin, Uzbek Cyrillic, Russian, English |
| Roles exercised | Candidate, employer, new employer, administrator |

Full build/runtime fingerprint: [build-and-environment.txt](evidence/v1.11.0/build-and-environment.txt).

The public DEV endpoint and user-authorized static OTP were used. This code is a
master key to phone-number accounts and is acceptable only in the owner's
explicitly non-production, synthetic-data environment. It must not exist in a
production runtime.

## 3. Overall Quality Assessment

| Dimension | Score | Assessment |
|---|---:|---|
| Functional reliability | 7/10 | Three-role E2E flows work; notification read and top-up do not. |
| UX / usability | 6/10 | Better dashboards and labels, but technical errors and hidden CTAs remain. |
| UI consistency | 7/10 | Coherent portrait design; raw codes and compact-layout clipping remain. |
| Business logic | 7/10 | Duplicate/idempotency guards are strong; moderation runtime is unsafe for release. |
| Frontend quality | 6/10 | Major modules shipped, but two API/dictionary contract mistakes are visible. |
| Backend/API quality | 7/10 | Authorization and transaction behavior are sound; deployment flag is a blocker. |
| Performance | 8/10 | Cold median 1.013 s; warm median 31 ms on emulator. |
| Accessibility | 4/10 | Duplicate semantics, unlabeled controls, and 200% text overflow remain. |
| Localization | 7/10 | Four variants switch; raw codes and one unresolved dictionary label remain. |
| Overall product quality | 6/10 | Strong DEV build, not a production release candidate yet. |

Highest-priority work:

1. MT-003 — enforce release moderation and verify a full approval path.
2. MT-020 — change notification read calls to the backend's `PUT` contract.
3. MT-006 — implement or intentionally remove/feature-gate Coin top-up UI.
4. MT-013 — stop premature authentication submits and global error noise.
5. MT-015/016 — repair semantics and compact/large-text layouts.

## 4. Critical Findings

| ID | Finding | Status |
|---|---|---|
| MT-003 | Mandatory vacancy moderation is disabled in the deployed runtime | Open |

Previously Critical MT-001 and MT-002 are verified fixed in 1.11.0.

## 5. High-Priority Findings

| ID | Finding | Status |
|---|---|---|
| MT-006 | Coin top-up is still a non-functional promise | Open |
| MT-020 | Notification read actions call the wrong HTTP method | New / Open |

The broad notification-module finding MT-005 is resolved: in-app lists,
preferences, foreground persistence, background FCM, tap deep-linking, and device
token deletion on sign-out were observed. MT-020 is the specific remaining
contract defect.

## 6. UX / Usability Assessment

The new Candidate Home is useful and immediately exposes notifications,
applications in progress, and recommendations. Employer Home correctly calls
out incomplete profile/verification state. Admin user search accepts a partial
phone number and exposes warning/restriction actions.

User friction remains in four places:

- Authentication enables actions before input is valid, then displays both a
  generic global error and field validation.
- Offline copy tells a normal user to check whether “the backend” and “base URL”
  are correct.
- Admin complaint cards do not identify what or whom the complaint targets.
- On compact and 200% text layouts, the main employer CTA is partially hidden
  behind bottom navigation.

## 7. UI Consistency Assessment

Portrait visual hierarchy, card styling, badges, navigation, and confirmation
states are consistent across roles. Status terms such as “Awaiting your answer”
and employer completion guidance are notably clearer than 1.4.1.

Consistency defects remain: monetary values are sometimes bare numbers, admin
verification views expose internal codes (`company_registration`, `evidence`,
`restriction_changed_requires_review`), and an employer-facing CV card shows
“Unavailable value” instead of “CV.” Bottom-navigation text also wraps heavily
at 200% text scale.

## 8. Functional Testing Results

| Area | Result | Notes / evidence |
|---|---|---|
| Fresh install / launch | Pass | Exact 1.11.0+16 installed and launched. |
| Candidate Home | Pass | [MT-001 fixed](evidence/v1.11.0/MT-001-fixed-candidate-home.png) |
| Vacancy discovery/detail | Pass | Recommended/recent/saved, filter entry, detail. |
| Save/apply double tap | Pass | One row each; [integrity log](evidence/v1.11.0/transaction-integrity.txt) |
| Candidate applications | Pass | Submitted, interview, hired, withdraw/response controls visible. |
| Invitation send/respond | Pass | Duplicate send rejected; pending label fixed; accept transitioned one row. |
| Chat | Pass | Two-way history and exactly one row after rapid Send taps. |
| Employer profile onboarding | Pass with UX note | Blank save blocked; full save created one profile and refreshed status. |
| Employer candidate search | Pass | Unfiltered result no longer claims 100% match. |
| CV download | Pass with label defect | HTTP 200 PDF; card label unresolved. |
| Employer verification gate | Pass | Unverified employer cannot create a vacancy. |
| Admin dashboard/users | Pass | Search, detail, warn, histories available. |
| Admin dictionaries | Pass | Types, items, localized add form available. |
| Admin moderation lists | Pass with config blocker | UI exists; runtime bypasses vacancy moderation. |
| Admin complaints | Partial | Queue exists; cards omit target identity. |
| In-app notifications | Partial | List/preferences work; read mutations fail. |
| Background push | Pass | [push received](evidence/v1.11.0/push-notification-background.png), [tap opened center](evidence/v1.11.0/push-tap-result.png) |
| Sign-out / token cleanup | Pass | Admin/employer/candidate exit; FCM token removed. |
| Offline retry | Pass with bad copy | Recovery works once connectivity returns. |
| Four locale selectors | Pass | [Uzbek Latin](evidence/v1.11.0/locale-uz-latn.png), [Cyrillic](evidence/v1.11.0/locale-uz-cyrl.png), [Russian](evidence/v1.11.0/locale-ru.png), [English](evidence/v1.11.0/locale-en.png) |

## 9. Business Logic Findings

Positive controls were strong:

- BR-07 behavior held: repeated application taps created one active application.
- Invitation duplication was rejected with “Already invited.”
- Candidate acceptance updated one invitation from `sent` to `accepted`.
- Chat double tapping created exactly one message.
- A blank new-employer save created no employer row; a valid rapid repeated save
  created one employer and one company row.
- An unverified employer was correctly blocked from vacancy creation (BR-03).
- Candidate file access was rechecked server-side and returned the entitled PDF
  through the application-scoped route (BR-09/BR-17).

The material logic exception is environmental: BR-04 cannot hold while
`MODERATION_ENABLED=false`. Wallet debit/unlock integrity was already proven in
the prior cycle and was not destructively repeated against the same entitlement;
the current UI showed the expected 8-Coin balance.

## 10. Frontend Findings

Confirmed frontend defects:

- Notification `markRead` and `markAllRead` use `Dio.post` while the API contract
  is `PUT`.
- `DictionaryLabel`, which explicitly expects a dictionary item UUID, receives
  `CandidateFile.purposeCode` (`cv`).
- Authentication button state is not coupled to complete input validity.
- Reused semantic wrappers cause labels such as `Home\nHome`, `Save\nSave`, and
  `Verified employer\nVerified employer`; picker chevrons remain unnamed.
- Content does not reserve enough safe bottom space on compact/large-text
  employer Home.
- The role-selection flow can navigate before active-role state is ready.

Repository check: all 961 Flutter tests passed, but `flutter analyze` reported
28 findings in test code, so the documented “analyze clean” gate is not met.

## 11. Backend / API Findings

The backend correctly enforced candidate file entitlement, pending-invitation
uniqueness, role-scoped data, and notification/device-token persistence. The
notification controller consistently declares `PUT /notifications/:id/read`
and `PUT /notifications/read`; the 404s are caused by the APK's method mismatch,
not by missing backend routes.

Backend/deployment work remains:

- Make the production deployment fail closed unless moderation is enabled.
- Complete Payme/CLICK Payment Order flows before exposing top-up as available.
- Consider returning a display-ready complaint target summary if current list
  DTOs cannot identify the reported object.
- Keep the current notification contract documented/generated so mobile code
  cannot drift from it again.

## 12. Authentication & Authorization

Static OTP `666666` authenticated existing candidate, employer, and admin
accounts and created a new user in DEV. Android notification permission could be
denied without blocking app access. Session restoration survived force-stop and
cold restart. Sign-out returned to authentication and removed the registered
device token.

Authorization spot checks passed: an employer could download a CV only through
an existing allowed application, and a new unverified employer was blocked from
vacancy creation. Admin warning action created an audited notification.

Open authentication issues are MT-013 (premature submit/global error) and
MT-021 (active-role race). The static OTP and `NODE_ENV=development` must be
removed/changed before any real environment is exposed.

## 13. Validation & Forms

Employer onboarding is materially safer. Employer type is not preselected, the
blank form reports named missing fields, and no empty DB row is created. A full
save created one complete employer profile and immediately displayed “Not
submitted,” resolving the stale verification state regression.

Authentication remains inconsistent: two phone digits are enough to enable
“Get a code,” and empty OTP still enables “Confirm.” Submitting produces a
generic global failure in addition to the precise field error. Long employer
forms also scroll when the keyboard is open, but their shifting field positions
make automation and likely one-handed completion more demanding.

## 14. Navigation

Bottom navigation, nested back navigation, push deep links, candidate vacancy
detail, application/invitation tabs, and account/security routes worked. Candidate
and employer role shells retained session state after restart. Admin now exposes
account/security and sign-out.

One transient navigation/state defect remains: selecting Employer and immediately
tapping Next can enter the employer shell before an active role is locally
selected. A restart recovers, but the first screen is an error state (MT-021).
Admin Notifications is also placed at the bottom of a long dashboard rather than
at the top as the release note implies.

## 15. Loading / Empty / Error States

Useful empty states were present for no vacancies, no attention items, no
complaints, and no uploads. Loading completed without duplicate list mutations.
“Already invited” is specific and actionable.

Weak states are the technical offline message, the authentication-wide
“Something went wrong,” notification read 404 rendered as “The requested data
was not found,” and “Unavailable value” for a known CV purpose. Error states
generally preserve the current page and Retry recovered after network return.

## 16. Offline & Network Reliability

With airplane mode/wifi/data disabled, a fresh Recent-vacancy load failed without
a crash or data corruption. The screen preserved navigation and offered Retry.
After connectivity returned, Retry repopulated results.

The copy is not user-ready: “Cannot reach the server. Is the backend running,
and is the base URL correct for this device?” exposes development concepts.
Evidence: [offline state](evidence/v1.11.0/MT-014-offline-copy.png) and
[recovery dump](evidence/v1.11.0/offline-recovery.xml).

No packet-loss shaping, high latency, mid-upload interruption, or prolonged
background network soak was performed.

## 17. Performance

Five measured cold starts were 955, 1013, 1062, 1031, and 978 ms: median
1.013 s and approximate p95 1.056 s. Five warm task resumes were 31, 60, 19,
27, and 48 ms: median 31 ms and maximum 60 ms. Normal list scrolling and route
transitions were responsive on the emulator.

The first launch after installation took 3.759 s and is reported separately as
installation/warm-up overhead. Measurements are in
[performance-and-quality-gates.txt](evidence/v1.11.0/performance-and-quality-gates.txt).
No low-end physical hardware, profiler frame trace, memory leak soak, API load,
or battery test was run.

## 18. Accessibility

At 200% text, core content remains scrollable but important dashboard text clips,
bottom-navigation labels wrap into awkward fragments, and the “New vacancy” CTA
is mostly hidden. The UI hierarchy also repeats accessible names (`Home\nHome`,
`Applications\nApplications`, `Send\nSend`) and exposes unnamed interactive
picker chevrons with `NAF=true`.

Touch targets are generally generous and contrast appears acceptable in the
observed light theme. No TalkBack audio session, switch access, keyboard-only
navigation, formal contrast measurement, or reduced-motion test was performed.
Evidence: [200% text](evidence/v1.11.0/accessibility-font-scale-2.png) and
[semantics sample](evidence/v1.11.0/current-window.xml).

## 19. Localization

Uzbek Latin, Uzbek Cyrillic, Russian, and English selectors immediately changed
authentication UI, satisfying the interface-switching portion of §3.1 and
UAT-13/24. User-entered content remained as entered during role flows.

Localization is incomplete where internal values bypass the dictionary layer:
admin views show raw verification/audit codes, salary has no localized currency
format, and candidate file purpose resolution supplies `cv` to a component that
expects a UUID. These are covered by MT-009 and MT-012.

## 20. Device Compatibility

Tested layouts:

- Pixel 8 portrait: 1080 × 2400 at density 420.
- Landscape: 2400 × 1080; candidate vacancy details scroll to Apply/Save.
- Compact portrait: 720 × 1280 at density 320 (360 × 640 dp).
- Font scale: 1.0 and 2.0.

The original landscape Apply/Save defect is fixed, but compact portrait and
200% font reveal a related bottom-safe-area defect on employer Home. Evidence:
[landscape detail](evidence/v1.11.0/MT-016-landscape-vacancy-detail.png) and
[compact layout](evidence/v1.11.0/responsive-small-360x640dp.png).

Not tested: tablets, foldables, physical devices, OEM skins/keyboards, Android
7/API 24 minimum, iOS, screen cutouts other than the emulator profile, and RTL.

## 21. Detailed Findings

### MT-003 — Mandatory vacancy moderation is disabled

**Severity:** CRITICAL
**Priority:** P0
**Category:** Business Logic, Backend, Configuration, Safety
**Owner:** Backend + DevOps + Product
**Affected screen:** Employer vacancy submit; Admin moderation
**Affected API:** Vacancy submission/public discovery
**Reproducibility:** Always in the tested runtime

#### Problem

The deployed API runs with `MODERATION_ENABLED=false`, so the release environment
cannot enforce §6.4 and BR-04.

#### Why this matters to the user

Unreviewed, misleading, illegal, or discriminatory vacancies can become visible
without the mobile administrator approval required by the product.

#### Preconditions

- Use the deployed DEV API.
- Have a complete/verified employer and a valid vacancy.

#### Steps to reproduce

1. Inspect the deployed API runtime configuration.
2. Observe `MODERATION_ENABLED=false`.
3. Submit a publishable vacancy and inspect status/discovery.

#### Expected result

A submission requiring moderation becomes `under_moderation` and is invisible
until an administrator approves it.

#### Actual result

Moderation is bypassed by configuration.

#### Evidence

- [Runtime evidence](evidence/v1.11.0/MT-003-moderation-runtime.txt)
- [Admin moderation list](evidence/v1.11.0/admin-vacancy-moderation.png)

#### Technical analysis

This is a runtime configuration decision, not a missing admin UI. The admin
moderation screens now exist, but a false feature flag prevents the required
state transition from being exercised.

#### Likely root cause

Confirmed: the DEV deployment intentionally disables moderation and has no
release-mode fail-closed guard.

#### Frontend recommendation

Show the actual server-returned state and keep submit copy neutral; do not assume
that a submitted vacancy is active.

#### Backend recommendation

Require moderation in release configuration. Refuse production startup when the
flag is false, and add an environment smoke test covering submit → queue → approve
→ discovery.

#### Suggested UX solution

After submit, show “Sent for review” with a clear pending badge and notification
on approval/rejection.

#### Acceptance criteria

- [ ] Production cannot start with moderation disabled.
- [ ] Submitted vacancies remain absent from discovery before approval.
- [ ] Admin approval is audited and makes the vacancy discoverable.
- [ ] Rejection keeps it hidden and notifies the employer.

### MT-006 — Coin top-up is still unavailable

**Severity:** HIGH
**Priority:** P1
**Category:** Functional, Monetization, UX, Frontend, Backend
**Owner:** Product + Frontend + Backend
**Affected screen:** Employer Wallet
**Affected API:** Payment Orders / Payme / CLICK
**Reproducibility:** Always

#### Problem

Wallet exposes an active “Top up” action, but tapping it only states that top-up
is not available yet and will arrive with Payme/CLICK.

#### Why this matters to the user

An employer who spends the free Coins cannot replenish them and therefore loses
access to paid candidate discovery, despite the UI advertising the action.

#### Preconditions

- Sign in as an employer.
- Open Wallet.

#### Steps to reproduce

1. Tap “Top up.”
2. Observe the informational message.

#### Expected result

The user can create a Payment Order, complete Payme or CLICK payment, and receive
Coins exactly once under §6.7 and BR-19/20.

#### Actual result

No purchase can start.

#### Evidence

- [Wallet](evidence/v1.11.0/MT-006-wallet.png)
- [Top-up result](evidence/v1.11.0/wallet-topup-result.png)

#### Technical analysis

The UI explicitly describes the feature as future work. This is a known product
gap rather than a transient API failure.

#### Likely root cause

Confirmed: provider/payment-order integration is not released in this build.

#### Frontend recommendation

Implement the provider flow only after storefront-policy review. Until then,
feature-gate or label the control “Coming soon” before the tap.

#### Backend recommendation

Implement signed provider callbacks, idempotent Payment Orders, audit history,
and no-credit behavior for failed/cancelled payments.

#### Suggested UX solution

Show amount, Coin quantity, provider, final status, retry/cancel behavior, and a
receipt/ledger entry. Never imply Coins were credited before verification.

#### Acceptance criteria

- [ ] UAT-20 and UAT-21 pass end to end.
- [ ] Duplicate callbacks credit exactly once (UAT-22).
- [ ] Failed/cancelled payments credit zero Coins (UAT-23).
- [ ] Storefront billing compliance is signed off before release.

### MT-009 — CV purpose label resolves as “Unavailable value”

**Severity:** MEDIUM
**Priority:** P2
**Category:** Frontend, Localization, API Contract
**Owner:** Frontend
**Affected screen:** Employer → Candidate detail → Attachments
**Affected API:** Candidate detail/file DTO
**Reproducibility:** Always for the tested CV

#### Problem

The PDF now downloads successfully, but its subtitle is “Unavailable value”
instead of the localized “CV.”

#### Why this matters to the user

Employers cannot confidently identify attachment type, especially when several
supporting documents exist.

#### Preconditions

- Employer has file access through an allowed application/invitation/unlock.
- Candidate has a CV attachment.

#### Steps to reproduce

1. Open candidate search and the entitled candidate.
2. Inspect Attachments.
3. Tap `mycv.pdf`.

#### Expected result

The card shows localized “CV” and opens the entitled file.

#### Actual result

The card shows “Unavailable value”; tapping still downloads a PDF with HTTP 200.

#### Evidence

- [Attachment card](evidence/v1.11.0/MT-009-employer-candidate-attachments.png)
- [UI hierarchy](evidence/v1.11.0/MT-009-attachment-open.xml)

#### Technical analysis

`CandidateFile.purposeCode` contains `cv`. `DictionaryLabel` explicitly accepts a
stored item UUID, but candidate detail passes the code into its `id` argument.

#### Likely root cause

Confirmed frontend code/id contract mismatch.

#### Frontend recommendation

Resolve by `(type_code, code)`, add a code-aware label component, or change the
DTO/domain model to carry the dictionary item UUID and code separately.

#### Backend recommendation

No backend change required; the API accurately returns `purposeCode: cv` and a
server-built download path.

#### Suggested UX solution

Show “CV · PDF · 46 B” (or a sensible localized size) under the filename.

#### Acceptance criteria

- [ ] `cv` renders as the localized CV label in all four variants.
- [ ] Retired/unknown purposes have a safe human-readable fallback.
- [ ] Download entitlement remains server-enforced.

### MT-012 — Internal codes and unformatted values leak into UI

**Severity:** MEDIUM
**Priority:** P2
**Category:** UX, Localization, Frontend
**Owner:** Frontend + Product
**Affected screen:** Employer verification; Admin moderation/audit; vacancy salary
**Affected API:** Dictionary/audit DTOs
**Reproducibility:** Always on affected rows

#### Problem

Screens expose `company_registration`, `evidence`,
`restriction_changed_requires_review`, bare `150000`, and the unresolved
attachment subtitle.

#### Why this matters to the user

Internal identifiers and ambiguous money values are hard to understand and make
the product feel unfinished.

#### Preconditions

- Open an employer verification profile or admin moderation detail.

#### Steps to reproduce

1. Scroll to required verification documents.
2. Open admin vacancy/audit detail.
3. Inspect document and salary labels.

#### Expected result

Every system code and amount has a localized, formatted display value.

#### Actual result

Raw codes and bare values are rendered.

#### Evidence

- [Employer raw codes](evidence/v1.11.0/MT-012-raw-codes.png)
- [Admin vacancy detail](evidence/v1.11.0/MT-012-admin-vacancy-detail.png)

#### Technical analysis

Some DTO fields bypass the dictionary/display formatter and are printed directly.

#### Likely root cause

Confirmed on the file-purpose path; inferred to be the same direct-code rendering
pattern on verification and audit views.

#### Frontend recommendation

Centralize code-to-label and localized currency/number formatting. Unknown codes
should display a neutral fallback plus diagnostic logging, never snake_case.

#### Backend recommendation

Where a code is intentionally admin-editable, return stable code/ID separately;
optionally include a localized display label to reduce client drift.

#### Suggested UX solution

Use “Company registration document,” “Supporting evidence,” “Requires review
after restriction change,” and salary with currency/period.

#### Acceptance criteria

- [ ] No raw snake_case code is visible in ordinary/admin UI.
- [ ] Salary includes locale-aware separators, currency, and period.
- [ ] Unknown values use a meaningful fallback.

### MT-013 — Authentication submits incomplete input

**Severity:** MEDIUM
**Priority:** P2
**Category:** Validation, UX, Frontend
**Owner:** Frontend
**Affected screen:** Sign in; OTP confirmation
**Affected API:** OTP request/verify
**Reproducibility:** Always

#### Problem

“Get a code” enables after only two phone digits, and “Confirm” enables with an
empty OTP. Submission adds a global “Something went wrong” above precise field
validation.

#### Why this matters to the user

The interface invites an impossible action and then blames an unspecified system
failure, obscuring what must be corrected.

#### Preconditions

- Be signed out.

#### Steps to reproduce

1. Enter `94`, accept terms, and tap “Get a code.”
2. On OTP, leave code empty and tap “Confirm.”

#### Expected result

Buttons remain disabled until locally valid; inline guidance is the only error.

#### Actual result

Both actions submit and show generic plus field errors.

#### Evidence

- [Partial phone](evidence/v1.11.0/MT-013-partial-phone.png)
- [Empty OTP](evidence/v1.11.0/MT-013-empty-otp.png)

#### Technical analysis

Button enablement appears tied to non-empty/terms state instead of the same
validators used after submit.

#### Likely root cause

Inferred frontend validation-state divergence.

#### Frontend recommendation

Use one validation model for button state and submit. Do not populate a global
API error for local validation failures.

#### Backend recommendation

No backend change required; continue rejecting invalid input with stable errors.

#### Suggested UX solution

Format `+998 XX XXX XX XX` progressively and explain the remaining digit count.

#### Acceptance criteria

- [ ] Phone submit requires exactly nine national digits and accepted terms.
- [ ] OTP confirm requires the complete code.
- [ ] Local validation never produces “Something went wrong.”

### MT-014 — Offline error copy exposes developer concepts

**Severity:** MEDIUM
**Priority:** P2
**Category:** UX, Offline, Frontend, Localization
**Owner:** Frontend + UX
**Affected screen:** Network-backed error states
**Affected API:** Any unavailable endpoint
**Reproducibility:** Always when offline

#### Problem

The app asks whether “the backend” is running and whether the “base URL” is
correct for the device.

#### Why this matters to the user

Normal users cannot act on backend/base-URL advice and may think they misconfigured
the app.

#### Preconditions

- Disable emulator network connectivity.

#### Steps to reproduce

1. Open Candidate → Vacancies → Recent.
2. Observe the error.
3. Restore network and tap Retry.

#### Expected result

Clear offline copy and a working Retry.

#### Actual result

Retry works after recovery, but the message is developer-facing.

#### Evidence

- [Offline copy](evidence/v1.11.0/MT-014-offline-copy.png)
- [Recovered state](evidence/v1.11.0/offline-recovery.xml)

#### Technical analysis

A shared development connection exception string is exposed in release UI.

#### Likely root cause

Confirmed generic error mapping/copy reuse.

#### Frontend recommendation

Map offline, timeout, DNS, 5xx, and authorization failures to separate localized
messages. Keep diagnostic details in logs only.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

“You’re offline. Check your connection and try again.” Preserve cached content
where safe.

#### Acceptance criteria

- [ ] Release UI never mentions backend/base URL.
- [ ] Retry succeeds after connectivity returns.
- [ ] Existing content is not discarded by a transient failure.

### MT-015 — Screen-reader semantics are duplicated or missing

**Severity:** MEDIUM
**Priority:** P2
**Category:** Accessibility, Frontend, Design System
**Owner:** Frontend
**Affected screen:** Bottom navigation, buttons, pickers, cards
**Affected API:** N/A
**Reproducibility:** Always

#### Problem

UI hierarchy exposes duplicate names such as `Home\nHome`, `Save\nSave`, and
`Verified employer\nVerified employer`; picker chevrons are interactive but have
no label (`NAF=true`).

#### Why this matters to the user

TalkBack users hear redundant announcements and cannot identify some controls.

#### Preconditions

- Inspect the Android accessibility hierarchy or enable TalkBack.

#### Steps to reproduce

1. Navigate candidate/employer tabs and a dictionary picker.
2. Inspect accessible names/focus targets.

#### Expected result

Each logical action is one focus target with one concise name, role, state, and
hint where needed.

#### Actual result

Names are duplicated and some actionable chevrons are unnamed.

#### Evidence

- [Candidate hierarchy](evidence/v1.11.0/current-window.xml)
- [Vacancy hierarchy](evidence/v1.11.0/candidate-vacancies.xml)

#### Technical analysis

Parent semantic labels appear to wrap children that retain their own semantics;
icon-only picker buttons lack explicit semantic labels.

#### Likely root cause

Inferred design-system semantics composition error.

#### Frontend recommendation

Use `excludeSemantics`/merged semantics deliberately, name icon buttons, and add
widget semantics tests for shared components.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

Announce “Home, tab, 1 of 5, selected” once and “Choose industry, button.”

#### Acceptance criteria

- [ ] Shared controls produce one accessible name.
- [ ] Every interactive element is named and focusable.
- [ ] TalkBack traversal follows visual/logical order.

### MT-016 — Primary CTA is clipped on compact and large-text layouts

**Severity:** MEDIUM
**Priority:** P2
**Category:** Responsive UI, Accessibility, Frontend
**Owner:** Frontend + Design System
**Affected screen:** Employer Home; previously Candidate vacancy detail
**Affected API:** N/A
**Reproducibility:** Always at tested compact/200% layouts

#### Problem

The original landscape vacancy-detail issue is fixed by scrolling, but employer
Home's “New vacancy” button is reduced to a thin blue strip behind bottom
navigation at 360 × 640 dp and 200% text.

#### Why this matters to the user

Small-screen and low-vision users cannot reliably discover or tap the primary
employer action.

#### Preconditions

- Sign in as an employer.
- Use 360 × 640 dp or 200% font scale.

#### Steps to reproduce

1. Open Employer Home.
2. Scroll to the bottom.
3. Observe the CTA above bottom navigation.

#### Expected result

All content and CTAs remain fully visible, scrollable, and tappable above system
and app navigation.

#### Actual result

The CTA is visually and interactively clipped.

#### Evidence

- [Compact layout](evidence/v1.11.0/responsive-small-360x640dp.png)
- [200% text](evidence/v1.11.0/accessibility-font-scale-2.png)
- [Landscape fix](evidence/v1.11.0/MT-016-landscape-after-scroll.xml)

#### Technical analysis

Scrollable content does not reserve sufficient bottom inset for the persistent
navigation bar; large text also increases upstream card heights.

#### Likely root cause

Inferred missing safe-area/navigation-height padding in the role shell.

#### Frontend recommendation

Apply calculated bottom padding to all shell scrollables and test shared layouts
at minimum viewport and 200% text.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

Keep the primary CTA fully visible with at least one spacing token above the nav.

#### Acceptance criteria

- [ ] CTA is fully visible/tappable at 360 × 640 dp.
- [ ] CTA remains reachable at 200% text and landscape.
- [ ] No bottom-nav label/content overlaps at supported scales.

### MT-017 — Complaint cards omit target identity

**Severity:** MEDIUM
**Priority:** P2
**Category:** Admin UX, Functional, Frontend, Backend
**Owner:** Frontend + Backend
**Affected screen:** Admin → Complaints
**Affected API:** Admin complaint list
**Reproducibility:** Always for tested records

#### Problem

Cards show only target type (“Vacancy” or “Person”), age, and reason; no target
name/title or usable identifier appears.

#### Why this matters to the user

Moderators cannot triage similar reports or know what they are opening.

#### Preconditions

- Sign in as admin with complaint records present.

#### Steps to reproduce

1. Open Admin → Complaints.
2. Compare multiple cards.

#### Expected result

Each card identifies the reported person/vacancy and provides priority/status.

#### Actual result

Cards are anonymous except for type and reason.

#### Evidence

- [Complaint list](evidence/v1.11.0/MT-017-admin-complaints.png)

#### Technical analysis

The list presentation lacks a target summary; it is unclear whether the DTO
omits it or the client ignores it.

#### Likely root cause

Assumption: complaint list contract was designed around identifiers without a
denormalized moderator-facing summary.

#### Frontend recommendation

Render target title/name plus a shortened stable ID and status.

#### Backend recommendation

If absent, add role-safe `targetSummary` and `targetStatus` fields to list DTOs to
avoid an N+1 detail fetch.

#### Suggested UX solution

“Vacancy · Call-centre operator · …0d13” with waiting age and severity badge.

#### Acceptance criteria

- [ ] Every complaint card uniquely identifies its target.
- [ ] Deleted/unavailable targets have an explicit fallback.
- [ ] Opening a card reaches the matching target context.

### MT-020 — Notification read actions use POST instead of PUT

**Severity:** HIGH
**Priority:** P1
**Category:** Functional, Frontend, API Contract, Notifications
**Owner:** Frontend
**Affected screen:** Notifications center; unread badges; push tap
**Affected API:** `PUT /notifications/:id/read`, `PUT /notifications/read`
**Reproducibility:** Always

#### Problem

Opening one notification and “Mark all read” both call nonexistent `POST` routes,
receive 404, and leave `read_at` null.

#### Why this matters to the user

Unread badges never clear and the new notification center repeatedly presents
handled events as new.

#### Preconditions

- Sign in with at least one unread notification.

#### Steps to reproduce

1. Open Notifications and tap an unread item.
2. Observe “The requested data was not found.”
3. Tap “Mark all read.”
4. Inspect requests and DB unread state.

#### Expected result

One/all rows become read and badges update without an error.

#### Actual result

APK sends `POST`; API requires `PUT`; both requests return 404 and rows remain
unread.

#### Evidence

- [Notification center](evidence/v1.11.0/notifications-center-admin.png)
- [Mark-all error](evidence/v1.11.0/notifications-mark-all-read.png)
- [Contract trace](evidence/v1.11.0/MT-020-notification-method-mismatch.txt)

#### Technical analysis

`notification_repository.dart` uses `_dio.post` for both calls. Backend
`notifications.controller.ts` declares `@Put(':id/read')` and `@Put('read')`.

#### Likely root cause

Confirmed stale/incorrect handwritten client contract.

#### Frontend recommendation

Use `PUT` for both methods, update comments/tests, optimistically update only with
safe rollback, and invalidate list/unread-count providers after success.

#### Backend recommendation

No behavior change required. Publish/generate the API contract and add contract
tests so client methods cannot drift.

#### Suggested UX solution

Tapping a notification should mark it read silently and navigate. Mark-all should
show a brief success only when rows changed.

#### Acceptance criteria

- [ ] One-item read sends PUT and receives 204.
- [ ] Mark-all sends PUT and consumes `{marked}`.
- [ ] DB `read_at`, list styling, and all role badges update immediately.
- [ ] Push deep-link marking does not surface an error.

### MT-021 — Fast role selection enters shell before active role is ready

**Severity:** MEDIUM
**Priority:** P2
**Category:** State Management, Navigation, Onboarding, Frontend
**Owner:** Frontend
**Affected screen:** New user role selection → Employer shell
**Affected API:** Role grant/session response
**Reproducibility:** Reproduced once with immediate consecutive taps

#### Problem

Selecting Employer and immediately tapping Next opened the employer shell with
“No active role is selected. Choose a role first.” The DB already contained the
employer role; cold restart recovered to Employer Home.

#### Why this matters to the user

A new user can believe registration failed at the most important onboarding
transition.

#### Preconditions

- Fresh phone account with no roles.

#### Steps to reproduce

1. Complete OTP.
2. Tap Employer.
3. Immediately tap Next before selection state settles.

#### Expected result

Next waits for role grant/active-role persistence and enters a valid employer
onboarding screen once.

#### Actual result

The shell briefly has no active role and displays a global error; restart heals
the state.

#### Evidence

- [Broken shell](evidence/v1.11.0/MT-021-role-selection-race.png)
- [Recovered after restart](evidence/v1.11.0/MT-021-after-restart.xml)

#### Technical analysis

Server role creation completed, but navigation/local active-role state was not
atomic with the selection action.

#### Likely root cause

Inferred asynchronous state race: Next remains actionable while role mutation or
secure local persistence is still in flight.

#### Frontend recommendation

Await role mutation and active-role persistence, disable selection/Next while
busy, then navigate from the authoritative refreshed session state.

#### Backend recommendation

Keep role grant idempotent and return the authoritative active/available role set
in the mutation response. No schema change appears necessary.

#### Suggested UX solution

Show a short progress state on Next and never expose the role shell until it has
a valid active role.

#### Acceptance criteria

- [ ] Rapid Employer→Next cannot enter a role-less shell.
- [ ] Repeated Next taps create/grant one role and one transition.
- [ ] Network failure stays on role selection with a retryable message.

## 22. Frontend Developer Action List

| Order | ID | Action |
|---:|---|---|
| 1 | MT-020 | Replace notification read `POST`s with `PUT`; add repository and integration tests. |
| 2 | MT-013 | Bind auth button enablement to complete validators and suppress global local-validation errors. |
| 3 | MT-009 | Resolve file purpose by code or carry dictionary UUID separately. |
| 4 | MT-016 | Add safe bottom padding and compact/200% golden tests to role-shell scrollables. |
| 5 | MT-015 | Fix shared semantic composition and label icon-only picker buttons. |
| 6 | MT-021 | Make role mutation/persistence/navigation one awaited state transition. |
| 7 | MT-012 | Centralize dictionary and currency display formatting. |
| 8 | MT-014 | Replace development network copy with user-facing localized states. |
| 9 | MT-017 | Render complaint target summary and stable short ID. |
| 10 | Quality gate | Resolve 28 analyzer findings so `flutter analyze` is clean. |

Do not change the now-working duplicate guards, server-built file download path,
push token cleanup, or invitation wording while addressing these items.

## 23. Backend Developer Action List

| Order | ID | Action |
|---:|---|---|
| 1 | MT-003 | Enforce moderation in release runtime and add a fail-closed deployment check. |
| 2 | MT-006 | Complete policy-compliant Payment Orders, callbacks, ledger, and idempotency. |
| 3 | MT-020 | Publish/generated-client contract tests for notification methods; retain PUT behavior. |
| 4 | MT-017 | Add target summary/status to complaint-list DTO if not already present. |
| 5 | MT-021 | Ensure role-grant response is authoritative/idempotent for client synchronization. |

Retain `OTP_ECHO_IN_RESPONSE=false`. Remove static OTP and development runtime
before any production deployment.

## 24. UX / Product Improvement List

Quick wins:

- Replace offline/backend wording (MT-014).
- Replace raw document/audit codes and “Unavailable value” (MT-009/012).
- Put Admin Notifications near the top of the dashboard.
- Identify complaint targets in list view (MT-017).
- Hide or clearly pre-label unavailable top-up instead of promising it after tap.

Larger improvements:

- Define a responsive/accessibility acceptance matrix for every role shell.
- Make payment/top-up availability a server capability, not a hard-coded promise.
- Add a visible, consistent “review pending” journey around moderation.
- Keep role onboarding transitions transactional from the user's perspective.

## 25. Suggested Regression Tests

Automate at minimum:

1. Notification repository contract: both read actions use PUT; unread count and
   row state update on 204/`{marked}` and roll back on failure.
2. Release environment smoke test: submit vacancy → under moderation → approve →
   discovery; fail startup if moderation is off.
3. Authentication widget tests for 0–8 phone digits and 0–5 OTP digits.
4. Role selection test with immediate/double Next and delayed API/storage writes.
5. Candidate file card test where `purposeCode=cv` renders localized CV and
   follows the server `downloadPath` verbatim.
6. Golden/semantics tests at 360 × 640 dp, landscape, font scale 2.0, and all
   five bottom-nav destinations.
7. Complaint list contract/render test with active, deleted, and unavailable
   targets.
8. Payment tests for duplicate callbacks, failed/cancelled payments, ledger
   append-only behavior, and exactly-once credit.
9. Existing idempotency E2E suite for apply/save/message/invite/accept/profile
   save under rapid repeated taps.
10. Production route test ensuring no placeholder/milestone screen is reachable.

## 26. Test Coverage / Not Tested Areas

Covered in 1.11.0:

- Fresh install, authentication, static OTP, role creation, session restart,
  sign-out, and notification permission allow/deny behavior.
- Candidate discovery, detail, save, apply, applications, invitations, chat,
  and attachment download.
- Existing/new employer dashboard, onboarding validation/save, verification gate,
  candidate search, invitation send, wallet/top-up surface, and account security.
- Admin dashboard, users/search/warn, dictionaries, complaints, moderation lists,
  notifications/preferences, sign-out, and FCM token deletion.
- Foreground notification persistence, background FCM, notification shade, and
  deep-link opening.
- Offline/recovery, portrait/landscape/compact layouts, 100%/200% text, four
  locale selectors, cold/warm launch timing, Flutter analyze/test.

Not tested or not completed in this cycle:

- Real SMS OTP delivery and abuse/rate-limit soak.
- Real Payme/CLICK/store billing, because top-up is not implemented.
- Full admin approve/reject notification cycle while moderation is disabled.
- Actual new attachment upload/file-picker interruption; download was tested.
- Physical Android devices, Android 7 minimum, low-end performance, tablets,
  foldables, OEM keyboards, iOS build/runtime, RTL, dark mode, TalkBack audio,
  contrast instrumentation, battery/memory soak, and backend load/security scan.
- Destructive account deletion and production retention jobs.

These gaps prevent claiming platform-wide or production acceptance even apart
from the open blockers.

## 27. Final Assessment

JobBridge 1.11.0 is a credible DEV product and a clear step forward. Candidate
Home, mobile admin management, dictionaries, employer onboarding, invitation
wording, search relevance display, account security, in-app notifications, and
background push are now real working features. Transaction/duplicate integrity
was the strongest observed quality: every rapid repeated core action left one
authoritative DB record.

It is not yet production-ready. Release must wait until:

- moderation is enforced and its full mobile approval path passes;
- notification read/mark-all calls match the backend and badges clear;
- Coin top-up is implemented and policy-approved, or paid functionality is
  explicitly out of scope and the unavailable action is removed;
- compact/large-text CTA clipping and critical semantics problems are fixed;
- authentication and role-selection races no longer lead users into avoidable
  global errors; and
- `flutter analyze` is clean alongside the already passing 961 tests.

**Final verdict: NO-GO for production; GO WITH KNOWN ISSUES for controlled DEV
testing only.**
