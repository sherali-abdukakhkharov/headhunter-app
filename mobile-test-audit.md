# JobBridge Android 1.17.0 — Full QA, UX/UI, Business Logic & Technical Audit

## 1. Executive Summary

**Verdict: NO-GO for production.** APK 1.17.0 is materially better than the
previously audited 1.11.0 build: notification read actions, form validation,
dictionary labels, offline recovery, compact/large-text layout, new-role
activation, admin audit names, and the new chat-attachment happy path all passed.
The isolated source suite also passed all **1,090 tests**.

Production release is still blocked by seven open findings:

| Severity | Count | Finding IDs |
|---|---:|---|
| Critical | 1 | MT-003 |
| High | 2 | MT-006, MT-022 |
| Medium | 4 | MT-015, MT-017, MT-023, MT-024 |

The most important new defect is **MT-022**. A fresh install signing into an
existing multi-role account whose server session has no active role is routed
to Employer Home without first publishing a role. Role-scoped requests then
return 403 and the screen says “No active role is selected.” This violates the
multi-role requirement in §2.3 and makes a valid account appear broken.

One deployment issue was repaired inside the authorized DEV environment so the
version could be tested fairly: the running API image pre-dated the 1.17 chat
route. Rebuilding backend commit `80905b7` and running the idempotent seed made
attachment upload work. This proves APK 1.17.0, that backend commit, and its
dictionary seed form one deployment unit.

No mobile or backend product source code was changed during this audit. Only
this report, evidence artifacts, DEV test data, and the authorized DEV deployment
were touched.

## 2. Application / Build Information

| Item | Audited value |
|---|---|
| APK | `C:\Users\Developer-7\Downloads\headhunter (1).apk` |
| Package | `com.jobbridge.app` |
| Version | `1.17.0` |
| Version code | `27` |
| APK size | 64,497,051 bytes |
| APK SHA-256 | `07707F4C6857D5FEB0E87E599C938AA11BA945B493BF72D1F4D7BEEBCD7510DF` |
| Min / target SDK | 24 / 36 |
| Signer | Universal HeadHunter / Uniconsoft |
| Source tag | `v1.17.0` (`dc75f589`) |
| Current app HEAD | `06bfd83`; code-identical to tag, only `TODO.md` differs |
| Backend contract | `80905b7` after matched DEV redeploy |
| Emulator | Pixel 8, Android 16 / API 36, 1080×2400, density 420 |
| Default font scale | 1.0 |
| Authentication used | Authorized DEV static OTP `666666` |

Fresh uninstall/install passed. Package Manager reported 1.17.0+27. The first
measured launch after install completed in 3,991 ms.

Evidence: [APK baseline](evidence/v1.17.0/apk-baseline.txt) and
[backend runtime](evidence/v1.17.0/backend-runtime.txt).

## 3. Overall Quality Assessment

| Area | Assessment | Summary |
|---|---|---|
| Installation / startup | Good | Fresh install, repeated cold/warm launch, no crash or ANR |
| Candidate core flows | Good | Home, discovery, applications, messaging, attachment receive/open |
| Employer core flows | Mixed | Home/search/wallet/chat work; top-up absent; multi-role login can break |
| Admin mobile flows | Good with gaps | Dashboard, moderation, users, wallets and audit work; complaint cards remain ambiguous |
| Business-rule enforcement | Not releasable | Deployed moderation remains disabled |
| API contract | Mixed | Matched 1.17 contract works; APK-only rollout failed on attachment route |
| Accessibility | Mixed | Shared nav/action improvements landed; several duplicate semantics remain |
| Responsive layout | Good | MT-016 fixed at 360×640 dp equivalent and 200% text |
| Offline / retry | Good | Session preserved; localized friendly state; recovery passed |
| Push | Good | Fresh FCM token registered and background notification delivered |
| Automated tests | Good | 1,090/1,090 passed when process-isolated |
| Static quality gate | Failing | `flutter analyze` exits 1 with 32 test-code findings |

Release priorities:

1. Enforce mandatory moderation and add a fail-closed deployment check (MT-003).
2. Repair fresh-login role activation for existing multi-role accounts (MT-022).
3. Decide and deliver a real Coin purchase channel or remove the active promise (MT-006).
4. Close complaint identity, abandoned upload retention, and remaining semantics gaps.
5. Restore a deterministic clean `flutter analyze` gate.

## 4. Critical Findings

| ID | Finding | Status |
|---|---|---|
| MT-003 | Mandatory vacancy moderation is disabled in the deployed runtime | Open |

MT-001 and MT-002 remain verified fixed from earlier releases.

## 5. High-Priority Findings

| ID | Finding | Status |
|---|---|---|
| MT-006 | Coin top-up remains a non-functional promise | Open |
| MT-022 | Existing multi-role account can enter a shell without an active role | New / Open |

MT-020 is verified fixed: single-item and mark-all actions now use the backend’s
`PUT` routes and unread counts changed 7 → 6 → 0.

## 6. UX / Usability Assessment

Improvements observed in 1.17.0:

- Partial phone and empty OTP submissions stay disabled with local guidance.
- Offline cold start clearly says the user remains signed in.
- Candidate-search filters now explain their behavior, including minimum total
  experience, occupation experience, language, and salary ceiling.
- Wallet amounts use grouped currency formatting.
- Chat distinguishes upload from send, accepts attachment-only messages, and
  retains a failed selection for retry.
- Admin wallet adjustments explain immutability and require both amount and reason.
- Compact and 200% text layouts keep employer quick actions fully reachable.

Remaining usability problems:

- A multi-role user is shown a technical role-state failure instead of a role
  choice or automatically completed role activation (MT-022).
- “Top up” remains tappable but only announces that Payme/CLICK are not available
  (MT-006).
- Complaint queue rows repeat only “Vacancy” or “Person”, waiting time, and
  complaint text, so similar reports cannot be distinguished (MT-017).
- A received attachment is called `cv.pdf` in chat, but the external viewer title
  uses a generated UUID filename. Opening succeeds, but original-name continuity
  should be improved.

## 7. UI Consistency Assessment

The visual language is consistent across candidate, employer, and admin shells:
status badges include words, navigation uses the same five-tab pattern, currency
is grouped, and primary/secondary actions are visually predictable. The new
attachment state uses the existing upload/document icon vocabulary.

The largest remaining consistency defect is semantic rather than visual. Bottom
tabs and shared Save buttons now expose one name, while radio buttons, checkboxes,
switches, and several admin period buttons still expose duplicated names. The
same component family therefore behaves differently to TalkBack (MT-015).

## 8. Functional Testing Results

| Scenario | Result | Evidence / note |
|---|---|---|
| Fresh uninstall and install | Pass | [Baseline](evidence/v1.17.0/apk-baseline.txt) |
| Partial phone validation | Pass / MT-013 fixed | [Screen](evidence/v1.17.0/MT-013-fixed-partial-phone.png) |
| Empty OTP validation | Pass / MT-013 fixed | [Screen](evidence/v1.17.0/MT-013-fixed-empty-otp.png) |
| Existing candidate OTP login | Pass | [Candidate Home](evidence/v1.17.0/candidate-home-login.png) |
| Existing single-role employer login | Pass | Employer Home and data loaded |
| Existing admin login | Pass | [Admin dashboard](evidence/v1.17.0/admin-home.png) |
| New employer role selection, immediate Next | Pass / MT-021 fixed | [Employer Home](evidence/v1.17.0/MT-021-fixed-immediate-next.png) |
| Existing multi-role clean login | Fail | [Broken shell](evidence/v1.17.0/MT-022-multirole-clean-login-redeploy.png) |
| Candidate vacancy discovery | Pass | Salary and dictionary labels rendered |
| Employer candidate search | Pass | Filters, free preview, candidate detail |
| Candidate CV label | Pass / MT-009 fixed | [Attachment label](evidence/v1.17.0/MT-009-fixed-cv-label.png) |
| Notification mark one read | Pass / MT-020 fixed | Correct `PUT`, unread decremented |
| Notification mark all read | Pass / MT-020 fixed | Correct `PUT`, unread became zero |
| Candidate-search expanded filters | Pass | [Filters](evidence/v1.17.0/candidate-filters-v1.15.png) |
| Chat attachment upload | Pass after matched deploy | [Ready state](evidence/v1.17.0/chat-pdf-upload-success.png) |
| Attachment-only message | Pass | [Sent state](evidence/v1.17.0/chat-file-only-sent.png) |
| Rapid double Send | Pass | Exactly one message row |
| Candidate receive/open PDF | Pass | [Chat](evidence/v1.17.0/candidate-chat-attachment.png), [viewer](evidence/v1.17.0/candidate-chat-attachment-open.png) |
| Remove selected upload | Functional UI, lifecycle fail | MT-023 |
| FCM background delivery | Pass | [Notification shade](evidence/v1.17.0/push-notification-shade.png) |
| Offline cold start and recovery | Pass / MT-014 fixed | [Offline](evidence/v1.17.0/offline-cold-start.png) |
| Admin employer moderation | Pass | Localized evidence purpose |
| Admin vacancy moderation detail | Pass / MT-012 fixed | [Detail](evidence/v1.17.0/MT-012-admin-vacancy-detail-fixed.png) |
| Admin complaint list | Fail usability | [Queue](evidence/v1.17.0/MT-017-admin-complaints.png) |
| Admin wallet list/detail | Pass | [Wallets](evidence/v1.17.0/admin-wallets.png) |
| Admin adjustment form validation | Pass | [Form](evidence/v1.17.0/admin-wallet-adjust-form.png) |
| Admin audit actor/target names | Pass for new records | [Audit](evidence/v1.17.0/admin-audit-log.png) |
| Four auth locale variants | Pass smoke | `locale-*.png/xml` evidence |
| Compact 360×640 dp equivalent | Pass / MT-016 fixed | [After scroll](evidence/v1.17.0/MT-016-compact-after-scroll.png) |
| Compact layout at 200% text | Pass / MT-016 fixed | [Screen](evidence/v1.17.0/MT-016-font200-compact.png) |

## 9. Business Logic Findings

- **Moderation:** Runtime `MODERATION_ENABLED=false` contradicts §6.4, BR-04,
  UAT-05, and UAT-11. The admin queue exists, but the release cannot rely on a
  queue while publication policy is disabled (MT-003).
- **Multi-role:** §2.3 requires roles to be switchable in one account. The client
  must not select a visual shell before the token carries that active role
  (MT-022).
- **Wallet:** The one-time 10-Coin employer bonus worked for the newly created
  employer, satisfying BR-15/UAT-16. Candidate Unlock and immutable transaction
  display also remained coherent. Coin purchase itself is not delivered (MT-006).
- **Chat:** §9.1 attachment send/receive works after matched deployment. File-only
  messages store body `NULL`; double submit was idempotent. Draft upload removal
  lacks a lifecycle endpoint or retention rule (MT-023, BR-14).
- **Notifications:** In-app read state and real FCM delivery both passed §9.2.
- **Admin audit:** A new warning showed “Dilnoza Yusupova” and “QA Retest Admin”.
  Older rows may still fall back to UUID when identity data is unavailable, which
  matches the 1.16 fallback design.

## 10. Frontend Findings

Resolved frontend regressions:

- MT-009: purpose codes use a code-aware dictionary label.
- MT-012: machine moderation/payment values are formatted for users.
- MT-013: submit enablement now shares complete local validation.
- MT-014: offline/timeout copy is localized and user-facing.
- MT-016: shell scrollables reserve sufficient bottom space.
- MT-020: notification repository uses correct verbs.
- MT-021: new-role selection awaits role publication before shell navigation.

Open frontend work:

- Existing multi-role login treats a non-empty role set as enough to enter a
  shell even when `activeRole` is null (MT-022).
- Remaining duplicated semantics exist in auth choices, filter switches, and
  admin period buttons (MT-015).
- “Remove attachment” forgets the uploaded ID without coordinating deletion or
  a recoverable draft (MT-023, shared ownership with backend).
- Test fixtures/providers violate the configured analyzer rules (MT-024).

## 11. Backend / API Findings

The current backend built successfully: 183 TypeScript files, zero compile
issues. Health and PostgreSQL checks passed. Authorization returned 403 when a
role-scoped endpoint received a token with no active role, which is correct
server behavior and helped expose MT-022.

The new chat route and `file_purpose/message_attachment` seed were absent from
the initially running image. After the authorized matched redeploy and seed,
upload/send/download passed. Deployment automation should prevent a mobile
version from being activated before its required API route and seed exist.

The backend currently persists an uploaded chat file before a message exists.
No delete/draft-cancel operation or demonstrated cleanup job removes a file the
composer abandons. Ownership prevents cross-user access, but unreachable active
rows can accumulate (MT-023).

Runtime remains development with static OTP and moderation disabled. This audit
uses static OTP by explicit owner authorization; a production deployment must
fail closed on unsafe settings.

## 12. Authentication & Authorization

Passed:

- Phone/terms button gating and OTP button gating.
- Server-provided six-digit challenge UI.
- Existing candidate, employer, and admin login.
- New-account role grant followed by active-role publication.
- Role-protected API refusal when the access token lacks an active role.
- Offline cold start retains tokens and does not flash unauthenticated UI.
- Fresh FCM token registration after login.

Failed:

- Existing multi-role account + fresh install + `activeRole=null` (MT-022).

The key distinction is between **granted roles** and **acting role**. A granted
role set may choose which home is a sensible default, but the client must first
obtain and persist an access token for that role. A shell cannot be considered
ready before that response arrives.

## 13. Validation & Forms

MT-013 is fixed. A two-digit phone keeps “Get a code” disabled and displays the
nine-digit requirement locally. Empty OTP keeps Confirm disabled. Local input
does not trigger a page-level “Something went wrong” state.

Admin balance adjustment also behaved correctly: amount and mandatory audit
reason were empty initially, Adjust stayed disabled, and immutable-ledger copy
was explicit. Employer and candidate dictionary pickers expose named “Choose …”
controls.

Not destructively exercised: a real wallet adjustment, account restriction,
vacancy rejection, complaint resolution, or employer verification decision.
Their forms and disabled states were inspected without changing those records.

## 14. Navigation

All five-tab candidate, employer, and admin shells navigated without crash. Deep
screens retained back navigation. Android’s file picker and external PDF viewer
returned safely to the conversation.

New-account role navigation passed. Existing multi-role fresh-login navigation
failed because router fallback selected Employer Home before a role token was
published (MT-022). Restart does not resolve it because no active role was saved.

Push notification tap brought the app safely to Candidate Home. A more specific
Notifications destination would improve context, but no broken/dead route was
observed.

## 15. Loading / Empty / Error States

Positive states:

- Offline state distinguishes no network from signed-out status.
- Chat separately indicates upload readiness and failed send.
- Search clearly says when no filters are active.
- Admin lists explain oldest/newest ordering and empty search behavior.
- Wallet clearly discloses unavailable top-up rather than pretending success.

Negative states:

- MT-022 renders a generic “Something went wrong” while providing no direct role
  chooser or recovery action.
- Before the matched backend redeploy, the new attachment action surfaced “The
  requested data was not found.” The UI handled the error, but the release pair
  was incompatible.

## 16. Offline & Network Reliability

MT-014 and the 1.13 cold-start change both passed:

1. Candidate session established.
2. Network disabled.
3. App force-stopped and cold-started.
4. “No connection” appeared with a statement that the user was still signed in.
5. Network restored and Try again tapped.
6. Candidate Home returned without OTP or token loss.

Chat double-submit also passed the no-duplicate part of §12.4: two immediate taps
created one message. File upload failure remained retryable in the composer.

Evidence: [offline/recovery](evidence/v1.17.0/push-and-offline.txt).

## 17. Performance

Pixel 8 emulator launch measurements:

| Metric | Samples (ms) | Average |
|---|---|---:|
| Cold `TotalTime` | 1527, 4228, 1349, 1475, 1301 | 1,976 ms |
| Warm task `WaitTime` | 25, 79, 13, 112, 66 | 59 ms |

The 4,228 ms cold outlier occurred once; the other four cold starts were 1.30–1.53
seconds. Normal screens showed explicit loading and no repeated request loop. No
crash or ANR was observed. This is an emulator sample, not a production-load API
benchmark and not a substitute for §12.4 p95 monitoring.

Evidence: [quality/performance](evidence/v1.17.0/quality-gates-and-performance.txt).

## 18. Accessibility

Fixed since 1.11.0:

- Bottom navigation exposes “Tab n of 5, label” once.
- Save, Send invitation, Attach a file, Remove attachment, and picker chevrons
  have explicit accessible names.
- Compact and 200% text content is reachable above navigation.

Still failing MT-015:

- Auth radios: `English\nEnglish` and equivalent variants.
- Terms checkbox repeats the entire acceptance sentence.
- Role-selection cards repeat `Candidate` / `Employer`.
- Candidate-search switches repeat labels such as “Ready to travel”.
- Admin 7/30/90-day buttons repeat their labels.

The issue is consistently a merged parent label whose visible child remains in
the semantics tree. TalkBack traversal was assessed through Android’s
accessibility hierarchy; a full human listening session was not performed.

## 19. Localization

Fresh auth selector smoke-tested all four variants:

- Uzbek Latin: `Til`, `Kirish`, `Telefon raqami`.
- Uzbek Cyrillic: corresponding Cyrillic system labels.
- Russian: `Язык`, `Вход`, `Номер телефона`.
- English: `Language`, `Sign in`, `Phone number`.

The selected system copy changed without reinstall. English end-to-end screens
used localized dictionary labels and formatted money. MT-009 and MT-012 are
therefore verified fixed in the exercised paths, consistent with §3.2–§3.3 and
BR-13.

Limit: the entire candidate/employer/admin E2E matrix was not repeated in every
locale. User-entered content preservation was not mutated during this audit.

Evidence: `evidence/v1.17.0/locale-{uz-latn,uz-cyrl,ru,en}.png` and XML files.

## 20. Device Compatibility

Tested:

- Android 16 / API 36 on Pixel 8 emulator.
- Native 1080×2400 viewport at density 420.
- 360×640 dp-equivalent custom viewport.
- 200% system font scale on the compact viewport.
- Android DocumentsUI file selection.
- Google Drive/Docs PDF viewer handoff.
- Android notification shade / FCM.

MT-016 is fixed: after scrolling to the bottom, New vacancy and Find candidates
were fully visible, tappable, and separated from the bottom navigation at both
compact and 200% text settings.

Not tested: physical-device OEM skins, low-RAM hardware, tablets/foldables,
Android 7–15, camera/gallery upload providers, or interrupted process restore
during file picker. Android is the authorized platform scope for this audit.

## 21. Detailed Findings

### MT-003 — Mandatory vacancy moderation is disabled

**Severity:** CRITICAL

**Priority:** P0

**Owner:** Backend + DevOps + Product
**Status:** Open

**Problem:** The healthy deployed API runs with `MODERATION_ENABLED=false`.

**Impact:** A release can make vacancies active outside the administrator review
workflow. This contradicts §6.4, BR-04, BR-12, UAT-05, and UAT-11. The existence
of a moderation screen does not enforce the publication rule.

**Reproduction:** Inspect the running API environment, then create/submit a
vacancy that normally requires review and compare its state to the queue.

**Expected:** A moderation-required vacancy remains Under moderation and absent
from discovery until an authorized decision.

**Actual:** Runtime policy switch is disabled.

**Recommendation:** Make release/staging deployment fail to start when mandatory
moderation is off. Add a deployment smoke that submits a controlled vacancy,
asserts non-discoverability, approves it, then asserts discoverability.

**Acceptance criteria:**

- [ ] Release runtime reports moderation enabled.
- [ ] Required-review vacancies cannot become discoverable before approval.
- [ ] Approval/rejection creates an audit record and notification.
- [ ] CI/deploy blocks unsafe configuration.

Evidence: [runtime](evidence/v1.17.0/MT-003-moderation-runtime.txt).

### MT-006 — Coin top-up is still unavailable

**Severity:** HIGH

**Priority:** P1

**Owner:** Backend + Mobile + Product/Compliance
**Status:** Open

**Problem:** Employer Wallet offers an enabled Top up action, but tapping it only
shows “Top-up is not available yet. It arrives with Payme and CLICK support.”
Admin Wallets likewise says payment-order search is unavailable.

**Impact:** An employer who exhausts the one-time bonus cannot buy more access,
blocking the revenue loop and protected candidate contact workflow in §6.6–§6.7.

**Expected:** A policy-compliant provider/store purchase creates a Payment Order,
credits exactly once after verified success, and appears in reconciliation.

**Actual:** No purchase or payment-order flow is available.

**Recommendation:** Either deliver the approved channel end-to-end with BR-19–24
idempotency/compliance, or feature-gate/remove the active top-up promise until it
exists. Do not embed card credentials in the app.

**Acceptance criteria:**

- [ ] User can initiate an approved purchase channel.
- [ ] Backend is authoritative for amount and payment status.
- [ ] Duplicate callbacks/retries cannot double-credit.
- [ ] Failed/cancelled payments never change balance.
- [ ] Admin can search and inspect Payment Orders.

Evidence: [wallet](evidence/v1.17.0/MT-006-wallet-retest.png) and
[top-up message](evidence/v1.17.0/MT-006-topup-dialog.png).

### MT-015 — Screen-reader semantics remain duplicated on several controls

**Severity:** MEDIUM

**Priority:** P2

**Owner:** Mobile / Design System
**Status:** Partially fixed, still open

**Problem:** Shared nav/actions and picker icons are fixed, but several radio,
checkbox, switch, and segmented-button labels are still announced twice.

**Examples:** `English\nEnglish`, duplicated terms text, `Candidate\nCandidate`,
`Ready to travel\nReady to travel`, and `30 days\n30 days`.

**Impact:** TalkBack output is noisy and slower to understand. It also indicates
inconsistent semantic composition across shared components.

**Recommendation:** Merge/exclude child semantics intentionally and add one
semantics assertion for each shared radio, checkbox, switch, and segmented
button implementation.

**Acceptance criteria:**

- [ ] Every logical control has exactly one concise name, role, and state.
- [ ] Visible child labels do not create duplicate focus/announcement content.
- [ ] Existing tab/action/picker fixes remain pinned.

Evidence: [auth hierarchy](evidence/v1.17.0/auth-initial.xml),
[filter hierarchy](evidence/v1.17.0/candidate-filters-v1.15.xml), and
[admin hierarchy](evidence/v1.17.0/admin-home.xml).

### MT-017 — Complaint cards omit target identity

**Severity:** MEDIUM

**Priority:** P2

**Owner:** Backend + Mobile
**Status:** Open

**Problem:** Admin complaint rows show target type (“Vacancy” or “Person”), age,
and complaint text, but no vacancy title, person/company name, or stable short ID.

**Impact:** Multiple seeded complaints are visually identical. An administrator
cannot prioritize or return to a specific target without opening cards one by one.

**Expected:** Each row identifies the target while preserving required privacy.

**Recommendation:** Add a localized `targetSummary` and stable `targetRef` to the
list DTO, then render both in the card. Keep the detail screen authoritative.

**Acceptance criteria:**

- [ ] Vacancy complaint names the vacancy and employer or a stable short ref.
- [ ] Person complaint names the account/profile or a stable short ref.
- [ ] Similar reports are distinguishable without opening each row.

Evidence: [complaint queue](evidence/v1.17.0/MT-017-admin-complaints.png).

### MT-022 — Existing multi-role fresh login enters a shell without active role

**Severity:** HIGH

**Priority:** P0

**Owner:** Mobile / Authentication
**Status:** New / Open

**Problem:** For `+998941779737` with Employer and Admin grants, a fresh install
receives `activeRole=null`. Because `roles` is non-empty, `needsRoleSelection`
is false; `effectiveRole` picks a preference-order fallback and the router enters
Employer Home. The access token still has no active role, so role-scoped calls
return `role.none_active`/403.

**Reproduction:**

1. Use an existing account with two granted roles and no server active role.
2. Clear app data or install on a new device.
3. Complete OTP login.
4. Observe Employer Home and the role error.
5. Force-stop/restart; the error remains.

**Expected:** Present a role chooser, or deterministically choose one, await
`POST /auth/active-role`, persist the returned token/choice, and only then enter
that role’s shell.

**Actual:** Shell navigation precedes role publication.

**Technical analysis:** `_adopt` preserves null active role; `needsRoleSelection`
checks only `roles.isEmpty`; `effectiveRole` returns the first preferred grant;
router fallback therefore has a destination before the authenticated token has
an acting role. The intended asynchronous deep-link switch did not converge on
this fresh-login path.

**Recommendation:** Model “grants exist but acting role unresolved” explicitly.
Resolve it in the authentication transition, not as a background side effect of
rendering a shell. Add an integration test for existing 2-role + no active role +
no local preference.

**Acceptance criteria:**

- [ ] No role shell renders with an access token whose active role is null.
- [ ] Existing multi-role fresh login offers/chooses a role deterministically.
- [ ] Active-role API completes and new token is saved before shell requests.
- [ ] Force-stop/restart restores the chosen role.
- [ ] Candidate/employer/admin combinations are covered.

Evidence: [screen](evidence/v1.17.0/MT-022-multirole-clean-login-redeploy.png)
and [trace](evidence/v1.17.0/MT-022-multirole-trace.txt).

### MT-023 — Removed or abandoned chat uploads remain active and unreachable

**Severity:** MEDIUM

**Priority:** P2

**Owner:** Backend + Mobile
**Status:** New / Open

**Problem:** Chat uploads immediately create `stored_files`. “Remove the
attachment” only forgets the selection locally. The server row remains active,
is linked to no message, and the client exposes no recovery/delete path.

**Impact:** Repeated pick/remove, failed drafts, and abandoned conversations can
accumulate permanent unreachable file rows and backing objects. Ownership limits
exposure, but storage/data lifecycle remains undefined under BR-14.

**Expected:** One explicit policy: delete on remove, retain as a recoverable
draft, or expire unlinked uploads through a tested cleanup job.

**Actual:** The audited row kept `deleted_at=NULL` after removal and had no
message link.

**Recommendation:** Prefer a short-lived upload/draft state with scheduled
cleanup, because deleting synchronously on UI removal makes retry/re-attach less
resilient. Whichever policy is chosen, document retention and make cleanup
idempotent and ownership-safe.

**Acceptance criteria:**

- [ ] Every uploaded attachment becomes linked, recoverable, or expired.
- [ ] Unlinked chat uploads do not accumulate indefinitely.
- [ ] Cleanup cannot delete a file after a message links it.
- [ ] Audit/test proves ownership and retention behavior.

Evidence: [DB integrity trace](evidence/v1.17.0/chat-attachment-integrity.txt).

### MT-024 — Static analysis release gate exits with 32 findings

**Severity:** MEDIUM

**Priority:** P1

**Owner:** Mobile / CI
**Status:** New / Open

**Problem:** `flutter analyze` exits 1 with 32 findings in test code, mainly
`scoped_providers_should_specify_dependencies` and
`avoid_public_notifier_properties`. Several Riverpod plugin findings are emitted
twice.

**Impact:** The repository’s documented pre-commit gate is red on the release
source. Developers cannot distinguish new regressions from accepted noise, and
CI reproducibility is weakened.

**Control:** Product tests are not failing. Running all 73 test files in isolated
processes produced 1,090 passes and zero failures. Long single processes hit a
Windows Dart VM OOM while compiling `mustache_template`, an infrastructure issue
that should be handled separately from test assertions.

**Recommendation:** Fix the test providers/notifiers or narrowly configure the
rules with rationale. Deduplicate/stabilize Riverpod analyzer execution in CI,
and shard Windows tests so the VM memory failure does not mask assertions.

**Acceptance criteria:**

- [ ] `flutter analyze` exits 0 on a clean checkout and in CI.
- [ ] No broad lint suppression is added to production code.
- [ ] Test runner strategy completes all 1,090 tests without VM OOM.
- [ ] CI reports analyzer and test failures as separate gates.

Evidence: [quality gates](evidence/v1.17.0/quality-gates-and-performance.txt).

## 22. Frontend Developer Action List

| Order | ID | Action |
|---:|---|---|
| 1 | MT-022 | Resolve/publish active role during login before shell navigation; add fresh-install multi-role tests. |
| 2 | MT-024 | Fix analyzer findings and make CI’s Riverpod lint execution deterministic. |
| 3 | MT-015 | Finish shared radio/checkbox/switch/segmented semantics composition. |
| 4 | MT-023 | Coordinate attachment remove/draft policy with backend; expose cancel/delete or recoverable draft state. |
| 5 | MT-017 | Render target summary and stable ref in complaint cards. |
| 6 | MT-006 | Feature-gate Top up until a compliant purchase path is live, or complete the UI flow. |

Preserve regression tests for the verified fixes: MT-009, MT-012, MT-013,
MT-014, MT-016, MT-020, and MT-021.

## 23. Backend Developer Action List

| Order | ID | Action |
|---:|---|---|
| 1 | MT-003 | Enforce moderation in release runtime and add a fail-closed deployment check. |
| 2 | MT-022 | Keep role-scoped authorization strict; add auth contract coverage for multi-role/no-active-role sessions. |
| 3 | MT-006 | Implement compliant Payment Orders, provider/store verification, ledger credit, and admin reconciliation. |
| 4 | MT-023 | Define and implement unlinked attachment retention/cleanup with race-safe tests. |
| 5 | MT-017 | Add complaint target summary/ref to the queue DTO. |
| 6 | Deploy | Couple APK 1.17 activation to backend 80905b7 and the `message_attachment` seed. |

## 24. UX / Product Improvement List

- Decide whether existing multi-role users should always choose on a new device
  or receive a documented deterministic default.
- Do not expose Top up as a normal enabled promise until the purchase channel is
  approved and usable.
- Give complaint queue cards enough identity for real triage.
- Decide chat-draft retention duration and whether users should see uploaded but
  unsent files again.
- Preserve original attachment filenames in the external viewer when safe.
- Consider routing account-action push taps to Notifications rather than generic Home.
- Keep the improved explanatory copy in filters, wallet adjustment, and offline states.

## 25. Suggested Regression Tests

1. Existing multi-role account, `activeRole=null`, no local preference → no shell
   request before active-role response.
2. Existing multi-role account with remembered valid role → role published and
   restored atomically.
3. Remembered role revoked server-side → chooser/default resolves to an allowed role.
4. New-account rapid role selection → one roles request, one active-role request,
   no 403 (retain MT-021 coverage).
5. Attachment pick → remove → cleanup/expiry; verify no unlinked active row remains
   beyond policy.
6. Attachment upload racing message send and cleanup → linked file survives.
7. Attachment-only rapid double Send → one message and one file link.
8. APK 1.17 deployment smoke → attachment route and dictionary purpose available
   before rollout.
9. Moderated vacancy → invisible before approval, visible after approval, audit +
   notification present.
10. Notification single/all read → exact `PUT` verbs and unread counts.
11. Auth partial phone/empty OTP → no network request and no global error.
12. Every shared radio/checkbox/switch/tab/button → one semantics label and correct state.
13. Employer Home at 360×640 dp and 200% text → both quick actions fully reachable.
14. Offline cold start → token retained; retry recovers without login.
15. Four locale variants → no technical key/snake_case; user-entered text unchanged.
16. `flutter analyze` clean + test shards total exactly expected suite count.

## 26. Test Coverage / Not Tested Areas

Covered:

- Fresh APK install and package/signature/version verification.
- Candidate, single-role employer, new employer, existing multi-role, and admin login.
- Candidate/employer/admin shell navigation and representative data screens.
- Candidate search, CV label, notifications, wallet, moderation, complaints, audit.
- Chat attachment send, file-only body, double-submit, receive, and external open.
- PostgreSQL verification of notification counts, message/file link, and orphan upload.
- Real FCM background delivery with a fresh device token.
- Offline cold start/recovery.
- Four-locale auth smoke.
- Compact/200% responsive test.
- Repeated launch timing.
- Backend build and health.
- Flutter analysis and all 1,090 source tests via process isolation.

Not covered or intentionally non-destructive:

- Real Payme/CLICK/Google Play purchase, callback, refund, or reconciliation
  because the flow is not implemented.
- Destructive admin verification/rejection/restriction/block/adjustment/complaint
  decisions on shared seeded records.
- Full new candidate profile completion and every dynamic category schema.
- Full UAT matrix repeated in all four locales.
- Malware scanning and oversized/unsupported attachment limits beyond picker MIME
  filtering.
- Production-scale API p95/load, backup restore, crash reporting backend, and analytics.
- Physical devices, low-memory devices, OEM Android variants, tablets/foldables,
  and Android versions below API 36.

The DEV database contains synthetic/stress data, including malformed-looking
phone strings. These were treated as test-fixture hygiene, not proof that the
current mobile registration form accepts them.

## 27. Final Assessment

APK 1.17.0 is a strong functional increment and closes seven previously open
regressions: MT-009, MT-012, MT-013, MT-014, MT-016, MT-020, and MT-021. The new
chat attachment flow works both ways when the matching backend and seed are
deployed. Candidate, employer, and admin core screens are stable, push works,
offline recovery is clear, compact/large-text layout is usable, and all 1,090
isolated tests pass.

It is **not production-ready** while mandatory moderation is disabled and an
existing multi-role user can enter a role shell with no acting-role token. The
unavailable purchase path, complaint ambiguity, remaining semantics duplication,
unlinked attachment retention, and failing analysis gate should also be resolved
or explicitly accepted before release.

**Final decision: NO-GO. Re-audit after MT-003 and MT-022 are fixed and the
matched mobile/backend/seed release bundle is deployed.**
