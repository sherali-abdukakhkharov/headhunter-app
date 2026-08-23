# Mobile Application Test & UX Audit

## 1. Executive Summary

This audit assessed the user-supplied JobBridge Android APK, version 1.4.1
(version code 9), and a development build produced from the matching `v1.4.1`
tag. Testing was performed as a first-time and returning candidate, employer,
and administrator against the DEV PostgreSQL database and API. Product source
code was not changed.

The audit identified:

- 3 Critical issues
- 5 High issues
- 10 Medium issues
- 1 Low issue
- 19 total findings

**Release verdict: NO-GO.** Version 1.4.1 is not ready for ordinary users. The
candidate's default Home tab and two core administrator tabs visibly ship as
milestone placeholders. The currently deployed DEV configuration also publishes
a newly submitted vacancy without administrator moderation. Push and in-app
notifications, Coin top-up, administrator sign-out, and administrator dictionary
management are unavailable.

Major risks:

1. Candidates land on an unfinished placeholder after login and every restart.
2. Administrators cannot manage/block users from the 1.4.1 UI, so UAT-14 cannot
   be completed.
3. With the tested backend configuration, employer content reaches candidate
   discovery without the human moderation required by §6.4, BR-04, and UAT-05.
4. Important hiring changes have no in-app notification center or push delivery.
5. Employers can spend Coins but cannot replenish them.
6. A blank employer profile can be saved and permanently commits the employer
   type while leaving the account unusable.

The strongest areas were server-side duplicate protection and hiring-state
integrity. Double taps did not duplicate vacancy drafts, applications, unlock
charges, invitation sends, application transitions, or interviews. Candidate
Unlock atomically changed the wallet from 10 to 8 Coins and exposed protected
contact data once. Candidate visibility, invitation response, application
history, interview confirmation, two-way chat, session restoration, and all four
interface variants also worked in the tested paths.

## 2. Application / Build Information

| Item | Tested value |
|---|---|
| Product | JobBridge |
| User APK | `C:\Users\Developer-7\Downloads\jobbridge.apk` |
| Package | `com.jobbridge.app` |
| Version | 1.4.1 (version code 9) |
| APK size | 62,750,935 bytes |
| APK SHA-256 | `D1B31FB1D665B11F2ECD378BF3A9F9F9FFEF8060FAA68C2CC0A8AD5B47A1CE1C` |
| Signer | `CN=Universal HeadHunter, OU=Mobile, O=Uniconsoft, L=Tashkent, C=UZ` |
| Signer SHA-256 | `7c1cc81cfc5564f6563ebab3fe714e0e2ac32f18173f3609f786a09dffc5421f` |
| Matching source tag | `v1.4.1`, commit `c3be70a…` |
| Development test package | `com.jobbridge.app.dev`, built from a clean tag archive |
| Platform | Android emulator |
| Device / AVD | Pixel 8 / `headhunter_pixel` |
| OS | Android 16, API 36 |
| Normal viewport | 1080 × 2400, density 420 |
| Additional viewports | 720 × 1280; 2400 × 1080 landscape |
| Text scale | 100% and 200% |
| Backend | NestJS API + PostgreSQL 18 |
| Public API | `https://hh.qitmir.uz` |
| Local QA API | `http://127.0.0.1:3002` through `adb reverse` during exploratory testing |
| Test date / zone | 2026-08-23, Asia/Tashkent |
| Locales | Uzbek Latin, Uzbek Cyrillic, Russian, English |
| Roles | Candidate, employer, administrator |

The release APK was launched directly and authenticated against the public DEV
endpoint using `+998941779737` and the user-authorized static code `666666`.
Evidence: [release launch](evidence/MT-ENV-002-release-launch.png) and
[release authentication](evidence/MT-ENV-003-release-authenticated.png).

To enable that exact test, the backend `.env` was changed from
`NODE_ENV=production` to `NODE_ENV=development`,
`OTP_STATIC_CODE=666666` was added, and `pnpm api:up` rebuilt/redeployed the API.
`OTP_ECHO_IN_RESPONSE=false` remains set. The public health endpoint returned
200 after deployment. This is acceptable only for the owner's stated empty DEV
environment: the static code is a master key to every phone-number account and
must be removed before any real data or external users are admitted.

The development build used the same 1.4.1 tag with
`API_BASE_URL=http://127.0.0.1:3002`. A separate QA API process used the existing
DEV database with runtime-only overrides; it was stopped after testing. Its logs
are [stdout](evidence/qa-api-3002.stdout.log) and
[stderr](evidence/qa-api-3002.stderr.log).

## 3. Overall Quality Assessment

| Dimension | Score | Short justification |
|---|---:|---|
| Functional Reliability | 5/10 | Several complex E2E flows work, but core release tabs are unfinished and monetization/notifications are absent. |
| UX / Usability | 5/10 | Main actions are generally readable, but blocked states, validation, internal codes, and placeholders create major friction. |
| UI Consistency | 6/10 | The design system is visually coherent in portrait, but error presentation and landscape behavior are inconsistent. |
| Business Logic Reliability | 5/10 | Unlock, duplicates, and hiring histories are strong; moderation configuration and incomplete-profile handling are release risks. |
| Frontend Quality | 5/10 | State guards and localization are good, but routing placeholders, stale providers, missing modules, and accessibility defects remain. |
| Backend/API Quality | 7/10 | Transactions, uniqueness, authorization gates, and histories behaved well; configuration and one dictionary contract mismatch caused visible defects. |
| Performance | 7/10 | Release cold start was about 1.03 seconds and normal lists were responsive; sustained load and low-end hardware were not assessed. |
| Accessibility | 4/10 | 200% text remained scrollable, but duplicate semantics and unlabeled interactive controls materially affect screen-reader use. |
| Localization | 7/10 | Four variants switch and render well, but several raw internal codes bypass localization. |
| Overall Mobile Product Quality | 5/10 | A promising DEV build with good foundations, but not a shippable 1.4.1 product. |

### Top 10 Problems to Fix First

1. MT-001 — replace the candidate Home placeholder.
2. MT-002 — ship administrator user management and BR-10 actions.
3. MT-003 — enable and verify mandatory vacancy moderation for the release environment.
4. MT-005 — implement in-app and push notifications.
5. MT-006 — complete a compliant Coin top-up path.
6. MT-007 — prevent saving an empty employer profile or irreversibly choosing its type.
7. MT-008 — give production administrators account/security and sign-out controls.
8. MT-004 — implement administrator dictionary management.
9. MT-009 — fix the CV file-purpose dictionary contract.
10. MT-016 — make vacancy cards/actions usable in landscape.

### User Experience Verdict

**Would an average first-time user understand the application?** Partly. Login,
vacancy discovery, application, unlock, invitation, and interview screens are
mostly understandable. A candidate who lands on “This screen arrives in M6” and
an administrator who lands on M10 placeholders will immediately perceive the
app as unfinished.

**Can the main task be completed without assistance?** Candidate vacancy search
and apply, employer search/unlock/invite, and employer/candidate interview flows
can. New-employer onboarding, admin user/dictionary tasks, top-up, and reliable
notification-driven return journeys cannot.

**Most friction:** candidate Home; blank employer onboarding; administrator
Users/Dictionaries; employer verification; offline failures; landscape vacancy
cards.

**Most confusing actions:** saving an empty company profile, seeing “100% match”
with no criteria, seeing raw codes such as `company_registration`, and tapping a
Top up action that only announces a future feature.

**Trust decreases most** when unfinished milestone text is visible, moderation is
skipped, and a paid unlock leads to “Unavailable value” metadata.

The three highest-impact changes are: complete the release shell routes, enforce
the production moderation/notification lifecycle, and make onboarding plus Coin
funding complete and recoverable.

## 4. Critical Findings

| ID | Finding | Release impact |
|---|---|---|
| MT-001 | Candidate Home is an M6 placeholder | Default candidate destination is visibly unfinished. |
| MT-002 | Administrator Users is an M10 placeholder | User lookup, restriction, block/unblock, and UAT-14 are impossible in 1.4.1. |
| MT-003 | Tested deployment publishes vacancy without moderation | Unreviewed employer content becomes candidate-visible immediately. |

## 5. High-Priority Findings

| ID | Finding | Impact |
|---|---|---|
| MT-004 | Administrator Dictionaries is a placeholder | BR-13 dictionary operations cannot be managed from the mobile admin product. |
| MT-005 | In-app and push notifications are absent | Users must manually revisit/refresh to discover important hiring events. |
| MT-006 | Coin Top up is unavailable | An employer below the unlock price has no recovery or purchase path. |
| MT-007 | Empty employer profile can be saved and locks type | A normal premature tap creates a persistent unusable state. |
| MT-008 | Production administrator has no sign-out/account route | Admin accounts cannot safely end/switch sessions from the release UI. |

## 6. UX / Usability Assessment

The app's strongest UX pattern is confirmation before consequential operations:
Candidate Unlock clearly shows cost, current balance, and remaining balance;
invitation acceptance explains contact exposure; session termination and
administrator moderation actions use confirmation. Error recovery through “Try
again” also worked after restoring connectivity.

The weakest pattern is prerequisite handling. The employer dashboard can say
“Nothing is waiting on you” while verification/profile work blocks the primary
actions. New vacancy and candidate search then fail with a snackbar or global
error rather than a direct “Complete company profile” action. Blank employer
onboarding permits commitment before the user understands its consequence.

Empty states are generally visually calm, but some copy is misleading or
developer-oriented. The offline message discusses the backend and base URL. The
wallet describes a product roadmap. The candidate invitation says “Sent” from the
recipient's perspective. Administrator complaint cards omit the identity of the
reported target, increasing review effort and error risk.

## 7. UI Consistency Assessment

Portrait screens use a consistent navy/turquoise visual language, 52 px controls,
badges, cards, spacing, and persistent field labels. Selected bottom-navigation
states and confirmation sheets are clear. Status is usually communicated with
text and icon, not color alone.

Inconsistencies remain:

- OTP and prerequisite failures use a large global error block while vacancy
  forms use useful inline field errors.
- Internal wire codes appear beside otherwise localized labels.
- Candidate landscape cards keep portrait-height content under a fixed bottom
  navigation area, reducing Apply/Save controls to a clipped strip.
- At 200% font scale, bottom-navigation labels have uneven wrapping/truncation.
- Repeated semantic labels cause a screen reader to announce visible labels
  twice.

## 8. Functional Testing Results

| Journey | Result | Notes / evidence |
|---|---|---|
| Release launch and login | Passed | Exact APK authenticated with the static DEV code; [evidence](evidence/MT-ENV-003-release-authenticated.png). |
| Invalid/empty OTP | Failed UX | Confirm remains actionable and produces a global generic error; [empty](evidence/MT-AUTH-002-empty-code.png), [wrong](evidence/MT-AUTH-003b-wrong-code-result.png). |
| Employer profile prerequisite | Failed | Blank save creates a 0% company profile; [evidence](evidence/MT-EMP-003-empty-profile-submit.png). |
| Employer candidate search | Passed with UX defect | Search returned one candidate; no-filter result displayed 100% match. |
| Candidate Unlock | Passed | One 2-Coin debit, contact revealed, double tap did not double-charge; [evidence](evidence/MT-EMPV-005-contact-unlocked.png). |
| Invitation send/duplicate | Passed | First send succeeded; duplicate returned a clear 409-derived inline state; [evidence](evidence/MT-EMPV-007-duplicate-invitation.png). |
| Vacancy create/save/submit | Passed technically | One draft and one submit despite double taps, but deployment auto-published without moderation. |
| Candidate save/apply | Passed | Exactly one saved record/application; [evidence](evidence/MT-CANDV-006-applications.png). |
| Candidate visibility | Passed | Hidden removed global visibility; searchable was restored and confirmed in DB. |
| Application status/history | Passed | Employer moved Submitted → Viewed; one history transition was created. |
| Interview scheduling/response | Passed | One phone interview created and candidate confirmed it; [evidence](evidence/MT-CANDV-018-interview-confirmed.png). |
| Two-way chat | Passed | Employer opened chat after unlock; candidate received unread and replied; [employer](evidence/MT-CHAT-001-employer-message.png), [candidate](evidence/MT-CHAT-003-candidate-reply.png). |
| Admin dashboard/moderation/complaints | Passed in covered paths | Queues, details, confirmation, stats, and complaint detail loaded. Decisions that alter shared fixture data were cancelled. |
| Admin Users/Dictionaries | Failed | Both are release placeholders. |
| Wallet top-up | Failed / unavailable | UI explicitly states it is not available yet. |
| Session restart | Passed | Auth persisted after force-stop/relaunch; [evidence](evidence/MT-RES-001-session-restart.png). |
| Offline/recovery | Partially passed | Cached saved content remained; explicit retry recovered, but error copy is unsuitable. |
| Four interface variants | Passed representative coverage | Authenticated admin dashboard rendered in all variants. |

## 9. Business Logic Findings

Confirmed strengths:

- BR-07 duplicate application protection held.
- BR-16/BR-18 Candidate Unlock charged exactly once and atomically exposed
  contact; wallet changed 10 → 8 Coins.
- Duplicate invitation returned conflict without consuming another quota unit.
- Vacancy draft, vacancy submit, application status, interview create, interview
  response, and message send were not duplicated by rapid repeated taps.
- Candidate visibility changed server-side and survived refresh.
- Application and interview histories were consistent with the visible state.
- Contact/CV data was masked before unlock and contact appeared only afterward in
  the tested UI/API flow, supporting BR-17.

Primary risks are MT-003's disabled moderation, MT-007's invalid incomplete
employer state, the missing top-up recovery required by UAT-19 through UAT-23,
and the notification gap affecting UAT-07/UAT-11.

Test-created DEV records are intentionally retained for developer inspection:

- `QA Audit Test Vacancy`, one worker, active, owned by `+998924823823`.
- One candidate application by `+998901130022`, currently `interview`.
- One confirmed phone interview scheduled for 2026-08-24 10:00 Asia/Tashkent.
- One unlock entitlement; employer wallet balance 8 Coins.
- One accepted invitation and its question/response history.
- One conversation with two QA messages.
- `+998941779737` now has an incomplete 0% company profile and a 10-Coin wallet.

## 10. Frontend Findings

Static review followed device testing and used the clean 1.4.1 tag, not the
developers' later working tree.

- `shell_tabs.dart` labels Candidate Home as M6 and Admin Users/Dictionaries as
  M10. `app_router.dart` sends unimplemented tab routes to
  `ShellPlaceholderScreen` (MT-001, MT-002, MT-004).
- `candidate_detail_screen.dart` passes a file `purposeCode` such as `cv` into a
  `DictionaryLabel` that expects an item UUID, causing the observed 422 and
  fallback text (MT-009).
- No Firebase Messaging dependency, notification screen/provider, or notification
  route exists in the 1.4.1 mobile source. The release manifest declares no
  Android notification permission or FCM service/receiver (MT-005).
- Employer profile, verification, and account provider invalidation paths do not
  consistently refresh after mutations (MT-007, MT-011).
- Semantic composition creates repeated labels and unlabeled picker chevrons
  (MT-015).

The checked-out app working tree changed while this audit was running because
other developers were active. It was not modified or treated as the release
baseline. Build claims in this report apply to the clean tag archive and the
user-supplied APK only.

## 11. Backend / API Findings

The backend generally returned domain-specific HTTP statuses and maintained
strong data integrity. Observed examples include 409 for a duplicate invitation,
422 for the incorrect dictionary ID, and atomic wallet/unlock behavior. Server
histories and final database state matched UI results.

Key API/configuration issues:

- `MODERATION_ENABLED=false` makes vacancy submission publish directly in the
  tested deployment. Backend UAT source explicitly tests UAT-05 with the flag on,
  showing this is a deployment gate rather than an unknown code path (MT-003).
- `GET /dictionaries/items?ids=cv` receives a code where it requires UUIDs and
  returns 422. The mobile caller is wrong; the API contract could be made harder
  to misuse (MT-009).
- Complaint list data does not provide enough target identity for efficient admin
  cards, although detail data does (MT-017).
- No configured payment provider is available, so the app cannot create a usable
  checkout (MT-006).

Backend notification storage/routes exist, but the 1.4.1 client does not consume
the in-app list or register a device push token. This is primarily a frontend
delivery gap, with FCM configuration also required.

## 12. Authentication & Authorization

Phone + OTP authentication passed for candidate, employer, and administrator.
Correct code consumption, session persistence after restart, current-device sign
out, all-session termination confirmation, and server-side prerequisite gates
were observed. Protected candidate contact remained hidden before unlock.

Validation UX is weaker than the authentication security model: five entered
digits can enable “Get a code,” and empty/wrong OTPs present the same global error
(MT-013). Production administrators have no release UI to sign out (MT-008).

The public DEV deployment now accepts the owner-authorized static code `666666`
for any phone number. `OTP_ECHO_IN_RESPONSE=false`, but knowledge of the code and
a phone number is sufficient to authenticate. This is an intentional test-only
state, not acceptable protection for real accounts.

No exhaustive IDOR/penetration campaign was performed. Covered role-bound routes
and mutations rejected missing prerequisites and exposed only expected data.

## 13. Validation & Forms

The vacancy form provides the best pattern: an empty Submit shows specific inline
errors, preserves entries, and prevents creation. The invitation and interview
forms also provide clear required fields and confirmations.

The employer profile and OTP forms do not follow that pattern. Save is enabled on
an entirely blank employer profile and commits a persistent type. OTP actions can
be initiated with invalid length and errors appear in a global block rather than
at the field. Verification Submit is enabled with 0% completeness and no evidence,
then fails by snackbar. See MT-007 and MT-013.

Numeric worker count, date/time picker, phone input, chat keyboard, empty values,
duplicate taps, and several server conflicts were tested. Exhaustive maximum
length, emoji, whitespace, negative-number, paste, every dynamic schema field,
and file-size/type matrix testing was not completed and is listed in Section 26.

## 14. Navigation

Bottom navigation, detail back navigation, pushed screens, role-specific shells,
and force-stop/resume were stable in covered paths. Candidate restart returned to
the expected default route—but that route is the M6 placeholder (MT-001).

Administrator navigation is incomplete: Users and Dictionaries resolve to
placeholders and there is no Account/Settings/Sign-out destination. Development
builds expose a floating Developer Tools button, but production flavor correctly
removes it, leaving no admin session exit (MT-008).

The release manifest contains only the launcher intent filter; no app/deep-link
intent filters were found. Notification taps and shared vacancy links therefore
cannot currently enter a destination. This is included in MT-005's delivery gap
and should be verified when notifications land.

## 15. Loading / Empty / Error States

Loading states were brief on normal Wi-Fi/local transport and mutations generally
guarded repeat taps. Useful empty states exist for vacancies, applicants,
applications, messages, and complaints.

Problems:

- OTP and incomplete-employer errors replace substantial page content and use
  generic “Something went wrong” framing (MT-010, MT-013).
- Offline copy discusses server/base-URL configuration (MT-014).
- Wallet Top up uses roadmap copy instead of a disabled/configuration state
  (MT-006).
- Candidate Messages correctly remained empty until the employer explicitly
  opened a permitted conversation. Once opened, unread count and two-way messages
  worked; this was not a defect.
- Verification initially rendered a stale not-found state after employer profile
  creation until manual retry (MT-011).

## 16. Offline & Network Reliability

With the API route removed, already cached Saved vacancies remained visible.
Refreshing Recommended showed an explicit failure and Retry. Restoring the route
and tapping Retry recovered without restart or duplicated data. Evidence:
[cached offline content](evidence/MT-RES-002-offline-vacancies.png),
[failure](evidence/MT-RES-003-offline-error.png), and
[recovery](evidence/MT-RES-004-offline-recovered.png).

The recovery mechanism works, but MT-014's text is developer-facing. Slow 2G,
packet loss, timeout during a financial mutation, network loss during upload, and
backgrounding during a write were not instrumented; these remain mandatory
pre-release tests.

## 17. Performance

The user release APK cold launch reported approximately 1,020 ms total/1,026 ms
wait time on the warmed emulator environment. Evidence:
[release cold launch](evidence/MT-PERF-001-release-cold-launch.png). The debug
development build took about 3.1 seconds cold and is not used as a release score.

Primary lists and details responded within the specification's three-second target
under this single-user normal-network test. No visible jank, crash, ANR, or endless
spinner occurred. Sustained soak, memory/battery profiling, API load percentiles,
cold database caches, low-end physical hardware, and large datasets were not
measured.

## 18. Accessibility

At 200% system text scale, the portrait vacancy feed remained scrollable and core
content was reachable, but bottom-navigation labels wrapped/truncated unevenly.
Evidence: [200% text](evidence/MT-A11Y-001-font-scale-200.png).

UI Automator semantics dumps confirmed repeated announcements such as
“Home\nHome,” “Vacancies\nVacancies,” and “Get a code\nGet a code.” On the
candidate profile, four clickable picker-chevron buttons had no text or content
description and were marked `NAF=true`. Evidence:
[shell hierarchy](evidence/MT-A11Y-002-ui-hierarchy.xml) and
[profile hierarchy](evidence/MT-A11Y-003-profile-hierarchy.xml). See MT-015.

Touch targets were generally large. Color-only status was not a systemic issue.
TalkBack gesture navigation, external keyboard, switch access, contrast
instrumentation, and a blind end-to-end task were not completed.

## 19. Localization

Representative authenticated screens were exercised in all four interface
variants. Major system labels and dictionary values changed, user-entered content
remained unchanged, and locale selection persisted. Evidence:
[Uzbek Latin](evidence/MT-I18N-002-uz-latn-admin.png),
[Uzbek Cyrillic](evidence/MT-I18N-003-uz-cyrl-admin.png), and
[Russian](evidence/MT-I18N-004-ru-admin.png); English is represented throughout
the evidence set.

Raw backend/internal values bypass localization on several screens:
`company_registration`, `evidence`, and
`restriction_changed_requires_review`. Salary also appeared as `150000` in an
admin review without currency/period context. These are grouped under MT-012.

No catastrophic overflow was found in the representative Cyrillic/Russian
screens. Linguistic accuracy was not independently reviewed by a professional
translator.

## 20. Device Compatibility

Normal portrait and a simulated 720 × 1280 small phone were usable. Evidence:
[small phone](evidence/MT-RESP-001-small-phone.png). System font scaling was
covered separately.

Landscape is materially broken on the candidate vacancy feed. The fixed bottom
navigation consumes the lower area while vacancy card actions are laid out below
it; UI hierarchy reduced Apply and Save to an approximately 8-pixel-high strip,
and scrolling did not expose a usable button. Evidence:
[landscape](evidence/MT-RESP-002-landscape.png) and
[landscape after scroll](evidence/MT-RESP-003-landscape-scrolled.png). See MT-016.

No tablet, foldable, physical low-end device, Android 7/API 24 minimum device, or
OEM-specific keyboard/navigation environment was available.

## 21. Detailed Findings

### MT-001 — Candidate Home ships as an M6 milestone placeholder

**Severity:** CRITICAL  
**Priority:** P0  
**Category:** Functional, UX, Frontend, Navigation  
**Owner:** Frontend + Product  
**Affected screen:** Candidate → Home  
**Affected API:** N/A  
**Reproducibility:** Always

#### Problem

The default candidate destination displays: “This screen arrives in M6. The
shell, navigation and redirects around it are done.” This is visible product UI,
not a debug-only diagnostic.

#### Why this matters to the user

Every candidate sees an unfinished implementation statement immediately after
login and after restart. It provides none of §5.5's recommended/recent/saved
vacancy home content and immediately damages trust.

#### Preconditions

- Sign in to an account with the candidate role.

#### Steps to reproduce

1. Open the app or tap Candidate → Home.
2. Observe the only page content.

#### Expected result

Candidate Home presents recommended vacancies, recent activity, useful profile
completion guidance, and clear discovery actions as defined in §5.5.

#### Actual result

An internal milestone placeholder is shown.

#### Evidence

- [Candidate Home](evidence/MT-CANDV-001-home.png)
- [Restart returns to placeholder](evidence/MT-RES-001-session-restart.png)

#### Technical analysis

Confirmed in the 1.4.1 tag: `shell_tabs.dart` marks Candidate Home `milestone:
'M6'`; `app_router.dart` falls back to `ShellPlaceholderScreen` for this route.

#### Likely root cause

Confirmed: the shell route was released before its real screen was mapped.

#### Frontend recommendation

Map `/candidate/home` to a production screen using the existing discovery/profile
providers. Add a release assertion/test that no production shell route resolves
to `ShellPlaceholderScreen`.

#### Backend recommendation

No backend change required; existing discovery/profile endpoints can support the
screen.

#### Suggested UX solution

Lead with recommended work, profile completeness when actionable, and recent
application/invitation changes. If Home is not ready, route candidates to the
working Vacancies tab rather than exposing milestone copy.

#### Acceptance criteria

- [ ] Candidate Home contains no milestone/developer copy in production.
- [ ] Fresh login and cold restart land on useful candidate content.
- [ ] Recommended, recent, and saved entry points required by §5.5 are reachable.
- [ ] A production-route test fails if any candidate tab is a placeholder.

### MT-002 — Administrator Users ships as an M10 placeholder

**Severity:** CRITICAL  
**Priority:** P0  
**Category:** Functional, Authorization, Frontend, Product  
**Owner:** Frontend  
**Affected screen:** Administrator → Users  
**Affected API:** `GET /admin/users`, `GET /admin/users/:id`, `PUT /admin/users/:id/status`  
**Reproducibility:** Always

#### Problem

The Users tab displays the M10 placeholder instead of user search, history, warn,
restrict, block, or unblock controls.

#### Why this matters to the user

Administrators cannot perform §10.4 or UAT-14 from the only allowed mobile admin
product. Unsafe or abusive accounts cannot be acted on through version 1.4.1.

#### Preconditions

- Sign in with the administrator role.

#### Steps to reproduce

1. Tap Administrator → Users.
2. Observe the placeholder.

#### Expected result

Search users by phone/name/role/status/date, view moderation history, and perform
audited status actions with a reason.

#### Actual result

The tab says the screen arrives in M10 and offers no task.

#### Evidence

- [Admin Users placeholder](evidence/MT-ADMIN-009-users.png)

#### Technical analysis

The backend routes exist and were present in redeploy logs. In the 1.4.1 app tag,
`ShellTabs.admin` marks Users M10 and the router sends it to the generic
placeholder.

#### Likely root cause

Confirmed frontend release sequencing gap; backend capability is already present.

#### Frontend recommendation

Wire the completed user list/detail/status screens to `/admin/users`; cover role
guarding, filters, mandatory reasons, stale-state conflict, and self-action
refusal.

#### Backend recommendation

Keep permission enforcement, immutable status history, and the self-targeting
guard. Add/retain API integration coverage matching UAT-14.

#### Suggested UX solution

Make the list searchable first, show status and role on each card, and place
consequential actions in a confirmation sheet with duration/reason.

#### Acceptance criteria

- [ ] Admin can find the four test users by phone and role.
- [ ] Restrict/block/unblock requires and records a reason.
- [ ] A restricted operation fails with a localized actionable reason.
- [ ] Non-admin and self-targeting attempts are rejected server-side.
- [ ] UAT-14 passes end to end from the production mobile UI.

### MT-003 — Current deployment publishes a submitted vacancy without moderation

**Severity:** CRITICAL  
**Priority:** P0  
**Category:** Business Logic, Backend, Configuration, Safety  
**Owner:** Backend + DevOps + Product  
**Affected screen:** Employer vacancy submit; Candidate discovery; Admin moderation  
**Affected API:** `POST /vacancies/:id/submit`  
**Reproducibility:** Always in the tested configuration

#### Problem

A verified employer submitted `QA Audit Test Vacancy`; it became `active`
immediately and was visible/applicable to candidates without an administrator
decision.

#### Why this matters to the user

Fraudulent, discriminatory, misleading, or unsafe vacancy content can reach job
seekers before review. This contradicts the visible admin moderation product and
UAT-05's explicit sequence.

#### Preconditions

- Verified employer with a complete vacancy.
- Tested backend has `MODERATION_ENABLED=false`.

#### Steps to reproduce

1. Create and save a valid vacancy.
2. Tap Submit (rapid double tap was also tested).
3. Observe employer status and candidate discovery.

#### Expected result

Status becomes Under moderation; the vacancy enters the admin queue; only an
admin approval changes it to Active (§6.4, BR-04, UAT-05).

#### Actual result

One vacancy was created, but it became Active with `published_at` immediately.

#### Evidence

- [Employer sees submitted/active vacancy](evidence/MT-EMPV-011-vacancy-submitted.png)
- [Candidate vacancy detail/application](evidence/MT-CANDV-004-vacancy-detail.png)
- Database record: `d69fb5f2-c2da-4ea3-92fa-5d681a541ca3`, status `active`,
  published 2026-08-23 19:31 Tashkent.

#### Technical analysis

Confirmed configuration cause: backend `.env` has `MODERATION_ENABLED=false`.
Backend `uat.int.spec.ts` runs UAT-05 with moderation enabled and expects
`under_moderation`, so the guarded path exists but is disabled in this deployment.

#### Likely root cause

Confirmed deployment configuration, not an inferred frontend defect.

#### Frontend recommendation

Render the status returned by the API and make the success copy explicit:
“Submitted for moderation.” Never optimistically label a submit as published.

#### Backend recommendation

Set `MODERATION_ENABLED=true` in every release/staging environment, seed at least
one administrator, redeploy, and add a deployment smoke test that submits a
vacancy and asserts it is not discoverable before moderation.

#### Suggested UX solution

Show the expected review state/time and a route to the vacancy status. After admin
approval, notify the employer.

#### Acceptance criteria

- [ ] Submission returns `under_moderation` in the release environment.
- [ ] Candidate discovery cannot return the vacancy before approval.
- [ ] The admin moderation queue contains the submitted vacancy.
- [ ] Approval creates an audited history row and activates it once.
- [ ] Rejection/change reason is visible to the employer.

### MT-004 — Administrator Dictionaries ships as an M10 placeholder

**Severity:** HIGH  
**Priority:** P1  
**Category:** Functional, Frontend, Localization, Administration  
**Owner:** Frontend  
**Affected screen:** Administrator → Dictionaries  
**Affected API:** `/admin/dictionaries/*`  
**Reproducibility:** Always

#### Problem

Dictionary management is a milestone placeholder although the backend exposes
create, update, activate, and merge routes.

#### Why this matters to the user

Admins cannot maintain occupations, skills, regions, employment attributes, or
four localized labels from the only admin product. Controlled form/search data
will become stale and BR-13 operations cannot be completed.

#### Preconditions

- Administrator session.

#### Steps to reproduce

1. Tap Dictionaries in the admin bottom navigation.
2. Observe the M10 placeholder.

#### Expected result

A mobile-optimized type/item list supports create/edit/activate/merge and all
localized labels defined by §10.3.

#### Actual result

No dictionary operation is available.

#### Evidence

- [Admin Dictionaries placeholder](evidence/MT-ADMIN-010-dictionaries.png)

#### Technical analysis

Confirmed frontend routing gap in 1.4.1; backend routes are mapped.

#### Likely root cause

The M10 shell tab shipped before the associated screen was connected.

#### Frontend recommendation

Wire type list, item list, edit/create, activation, hierarchy, and merge flows.
Require all four labels and show stable code/ID only in an explicit technical
detail area, not as the user label.

#### Backend recommendation

Retain immutable IDs, hierarchy validation, merge audit, localized label
requirements, and conflict protection.

#### Suggested UX solution

Use type → searchable item list → edit detail; surface missing translations and
inactive status prominently.

#### Acceptance criteria

- [ ] Every §10.3 dictionary is reachable from the production admin UI.
- [ ] Create/edit supports Uzbek Latin/Cyrillic, Russian, and English.
- [ ] Activate/deactivate and merge require confirmation and audit.
- [ ] Candidate/employer pickers refresh without binding translated text as IDs.

### MT-005 — In-app notification center and push delivery are absent

**Severity:** HIGH  
**Priority:** P1  
**Category:** Functional, Frontend, Backend Integration, Reliability  
**Owner:** Frontend + Backend/DevOps  
**Affected screen:** All roles; hiring events  
**Affected API:** `/notifications`, device-token registration, FCM delivery  
**Reproducibility:** Always

#### Problem

Version 1.4.1 has no notification list, unread badge, push registration, or
notification/deep-link handler. Hiring events are visible only after manually
opening and refreshing their owning screen.

#### Why this matters to the user

Candidates can miss invitations, interview changes, offers, and application
updates; employers can miss applications and invitation responses. This breaks
the return loop of a recruitment product and the requirement in §9.2.

#### Preconditions

- Create an application, invitation response, interview, moderation result, or
  chat message between two test users.

#### Steps to reproduce

1. Complete an event on account A.
2. Return to account B.
3. Inspect navigation and Android notification shade.

#### Expected result

An in-app notification appears with unread state; configured push alerts the
recipient and opens the correct role/screen (§9.2, UAT-07, UAT-11).

#### Actual result

No notification destination or push appears. Data is found only in the relevant
feature after navigation/refresh.

#### Evidence

- [Candidate invitation exists without notification surface](evidence/MT-CANDV-007-invitations.png)
- [Candidate interview exists in Applications](evidence/MT-CANDV-017-interview-visible.png)
- Release manifest inspection: only `INTERNET` plus a self-signature permission;
  no `POST_NOTIFICATIONS`, FCM service, or FCM receiver.

#### Technical analysis

Confirmed in the 1.4.1 tag: there is no `firebase_messaging` dependency or mobile
notifications feature. Project TODO marks M9 Notifications open. Backend stores
notifications, but the client does not consume/register them.

#### Likely root cause

Confirmed deferred feature milestone plus incomplete Firebase app configuration
after package rename.

#### Frontend recommendation

Implement notification repository/list/unread count/preferences, Android 13+
permission education/request, FCM token lifecycle, foreground/background tap
handling, role-aware deep links, and invalid-token recovery.

#### Backend recommendation

Configure FCM credentials for the DEV/staging environment, expose/register token
lifecycle, preserve in-app records when push is unavailable, and monitor delivery
failures.

#### Suggested UX solution

Add a role-aware notification bell with unread badge. A tap should switch role if
needed and open the exact application/invitation/interview/thread.

#### Acceptance criteria

- [ ] Every §9.2 event creates an in-app notification for the correct recipient.
- [ ] Android 13+ permission is requested contextually and denial remains recoverable.
- [ ] Foreground, background, killed-app, and token-refresh push paths work.
- [ ] A tap opens the correct role and record without exposing another user's data.
- [ ] Push failure never removes the in-app notification.

### MT-006 — Coin Top up is unavailable despite being a core recovery path

**Severity:** HIGH  
**Priority:** P1  
**Category:** Functional, Payments, Product, Backend Integration  
**Owner:** Frontend + Backend + Product/Payments  
**Affected screen:** Employer → Wallet  
**Affected API:** `GET /payments/providers`, `POST /payments/orders`, provider callbacks  
**Reproducibility:** Always in the tested environment

#### Problem

The Wallet presents an active Top up action; tapping it only says the feature is
not available yet and “arrives with Payme and CLICK support.”

#### Why this matters to the user

Once the 10-Coin bonus is exhausted or balance drops below two, the employer
cannot unlock another candidate. The product has a paywall without a funding
path, and UAT-19's recovery cannot lead to UAT-20/UAT-21.

#### Preconditions

- Employer with a wallet.

#### Steps to reproduce

1. Open Wallet.
2. Tap Top up.

#### Expected result

Show configured provider/coin choices or a clearly disabled wallet state that
does not promise an actionable checkout (§6.7, UAT-19–UAT-23).

#### Actual result

A roadmap snackbar is shown; no purchase can be initiated.

#### Evidence

- [Wallet](evidence/MT-WALLET-001-overview.png)
- [Unavailable Top up](evidence/MT-WALLET-002-topup-unavailable.png)

#### Technical analysis

The backend contract treats an empty provider list as valid when no merchant
account is configured. The 1.4.1 client exposes an action but has no complete
checkout flow for this state.

#### Likely root cause

Confirmed external/provider configuration and unfinished frontend milestone;
not a failed transaction.

#### Frontend recommendation

Build the provider-driven top-up/order/status/history UI. When providers are
empty, disable purchase with user-facing availability/help copy, not roadmap
language.

#### Backend recommendation

Configure approved sandbox merchant/store billing provider(s), verify callbacks,
and run UAT-20 through UAT-23 including duplicate callbacks and failed/cancelled
orders.

#### Suggested UX solution

Route insufficient-balance unlocks directly to Wallet, retain the chosen
candidate, and resume unlock after a verified credit.

#### Acceptance criteria

- [ ] An employer below 2 Coins receives a usable Top up route.
- [ ] Amount is calculated server-side from requested Coins.
- [ ] Duplicate verified callbacks credit exactly once.
- [ ] Failed/cancelled orders credit zero and show retry/final state.
- [ ] Returning from successful funding can resume the candidate unlock.

### MT-007 — Blank employer profile can be saved and irreversibly commits company type

**Severity:** HIGH  
**Priority:** P1  
**Category:** Validation, UX, Frontend, Business Logic  
**Owner:** Frontend + Backend  
**Affected screen:** Employer → Company profile  
**Affected API:** Employer profile create/update endpoint  
**Reproducibility:** Always

#### Problem

The company/individual choice defaults to Company. Save is enabled with every
field empty. One tap creates a 0% incomplete company profile and removes the type
chooser; the user cannot return to choose Individual.

#### Why this matters to the user

A first-time employer can make a lasting account decision before entering or
understanding any information. The resulting profile blocks vacancy creation,
candidate search, and verification without offering a reset.

#### Preconditions

- Employer role with no employer profile.

#### Steps to reproduce

1. Open Company.
2. Leave the default Company selection and all fields empty.
3. Tap Save.
4. Reopen the screen and try to choose Individual.

#### Expected result

No profile is committed until required fields are valid, or an incomplete draft
retains an explicit, reversible employer-type choice.

#### Actual result

A company row is created with 0% completeness; the type selector disappears and
core actions remain blocked.

#### Evidence

- [No profile/type choice](evidence/MT-EMP-002-missing-profile.png)
- [Empty profile saved](evidence/MT-EMP-003-empty-profile-submit.png)
- DB: `+998941779737`, type `company`, completeness 0, `is_complete=false`.

#### Technical analysis

The frontend treats Save as draft persistence but the information architecture
treats the first persisted type as final. Required-field validation is deferred
to downstream gates rather than the profile action itself.

#### Likely root cause

Likely combined cause: no client form-validity gate and no supported server
transition/reset for an unused incomplete employer profile.

#### Frontend recommendation

Require an explicit type selection and validate required fields inline before
creating the profile. If drafts are required, keep “Change employer type” until
verification or vacancy/invitation data makes the type consequential.

#### Backend recommendation

Define a safe type-change/reset rule for incomplete profiles with no dependent
business records; reject empty create payloads if draft persistence is not a
specified feature.

#### Suggested UX solution

Use a short first step: “Who is hiring?” with no preselection, then the correct
schema. Explain when the choice becomes locked.

#### Acceptance criteria

- [ ] Save cannot create an all-empty employer profile.
- [ ] Required errors are inline and focus/scroll to the first invalid field.
- [ ] A mistaken unused incomplete type can be changed or reset safely.
- [ ] A valid profile refreshes dashboard, verification, and gates immediately.

### MT-008 — Production administrator has no account/security or sign-out action

**Severity:** HIGH  
**Priority:** P1  
**Category:** Authentication, Navigation, Security UX, Frontend  
**Owner:** Frontend  
**Affected screen:** Administrator shell  
**Affected API:** Auth sign-out/session endpoints  
**Reproducibility:** Always in production flavor

#### Problem

The admin shell exposes Dashboard, Moderation, Complaints, Users, and
Dictionaries, but no Account/Settings destination or sign-out action. The only
convenient switch in the development build is Developer Tools, which production
correctly removes.

#### Why this matters to the user

An administrator on a shared or lost device cannot deliberately end the session
or switch account. Closing the app does not sign out because the session persists.

#### Preconditions

- Authenticate as administrator in `com.jobbridge.app` production flavor.

#### Steps to reproduce

1. Inspect every admin tab and dashboard bottom.
2. Look for Account, Security, or Sign out.
3. Force-stop/reopen; the authenticated session persists.

#### Expected result

Admin can sign out current device, terminate all sessions, and access account
security as required by §4.2.

#### Actual result

No production admin route/action exists.

#### Evidence

- [Admin dashboard bottom](evidence/MT-ADMIN-011-dashboard-bottom.png)
- [Admin shell](evidence/MT-ADMIN-001-home.png)

#### Technical analysis

The common account screen is reachable from candidate/employer profile areas but
is not exposed by the five-tab admin shell. Development tools mask the omission
during debug use.

#### Likely root cause

Confirmed navigation/information-architecture omission.

#### Frontend recommendation

Add an admin avatar/overflow or protected Account route reusing the existing
session/security screen. Do not add a sixth bottom tab merely for sign-out.

#### Backend recommendation

No backend change required; reuse existing sign-out and session-termination APIs.

#### Suggested UX solution

Place Account in the dashboard app bar with administrator identity, language,
session management, and sign-out.

#### Acceptance criteria

- [ ] Production admin can sign out the current device in at most three taps.
- [ ] “Terminate all sessions” remains confirmed and invalidates other sessions.
- [ ] Back navigation after sign-out cannot reveal admin content.
- [ ] Candidate/employer/admin account-security behavior is consistent.

### MT-009 — CV purpose code is sent to a UUID dictionary endpoint

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Frontend, API Contract, Localization  
**Owner:** Frontend  
**Affected screen:** Employer → Candidate detail → Attachments  
**Affected API:** `GET /dictionaries/items?ids=…`  
**Reproducibility:** Always for the tested `cv` attachment

#### Problem

After a paid Candidate Unlock, the attachment `mycv.pdf` shows “Unavailable
value.” The client requests dictionary item ID `cv`; the API expects UUIDs and
returns 422.

#### Why this matters to the user

A paid access screen looks partially broken and does not explain the attachment's
purpose, reducing confidence that the CV itself is usable.

#### Preconditions

- Verified employer has unlocked a candidate with a CV attachment.

#### Steps to reproduce

1. Open the unlocked candidate profile.
2. Scroll to Attachments.
3. Observe the purpose label/API log.

#### Expected result

The localized purpose label (for example, “CV”) is displayed without an invalid
request.

#### Actual result

“Unavailable value” is shown and the API logs a 422 for `ids=cv`.

#### Evidence

- [Unlocked candidate detail](evidence/MT-EMPV-005-contact-unlocked.png)
- [QA API log](evidence/qa-api-3002.stdout.log)

#### Technical analysis

Confirmed source cause in `candidate_detail_screen.dart`: `file.purposeCode` is
passed as `DictionaryLabel.id`. Purpose codes and dictionary UUIDs are distinct
contracts under BR-13.

#### Likely root cause

Confirmed frontend type/model confusion, made possible because both values are
represented as strings.

#### Frontend recommendation

Resolve purpose codes through a code-keyed label map/schema or have the file model
carry the correct dictionary item ID. Use value types to distinguish UUID IDs
from stable codes.

#### Backend recommendation

No backend behavior change is required. Consider documenting/generating distinct
types for code and UUID fields to prevent client misuse.

#### Suggested UX solution

Show “CV · PDF” and an explicit View/Download action. If metadata resolution
fails, retain the filename and action without alarming fallback text.

#### Acceptance criteria

- [ ] No `ids=cv` request is made.
- [ ] File-purpose label is localized in all four variants.
- [ ] Paid CV view/download remains authorized and usable.

### MT-010 — Employer dashboard and prerequisite failures contradict each other

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** UX, Navigation, Error State, Frontend  
**Owner:** Frontend + Product  
**Affected screen:** Employer Home, New vacancy, Candidates  
**Affected API:** Employer profile/count/search endpoints  
**Reproducibility:** Always for an incomplete employer

#### Problem

Home says “Nothing is waiting on you” while the account has no complete profile
or verification. New vacancy returns to Home with a snackbar; Candidates shows a
global “Something went wrong.” Neither provides a direct corrective action.

#### Why this matters to the user

The app first says everything is fine, then rejects the user's main goals without
showing where or how to resolve the prerequisite.

#### Preconditions

- Employer profile missing/incomplete.

#### Steps to reproduce

1. Open Employer Home.
2. Tap New vacancy.
3. Tap Candidates.

#### Expected result

Home lists profile/verification as the highest-priority task and every gate offers
“Complete company profile” or “Submit verification.”

#### Actual result

Contradictory empty state plus snackbar/global errors without destination.

#### Evidence

- [Home/gate](evidence/MT-EMP-001-new-vacancy-gate.png)
- [Candidate-search gate](evidence/MT-EMP-005-candidate-search-gate.png)

#### Technical analysis

Backend correctly enforces BR-03. Frontend maps the refusal to generic error
surfaces instead of a domain prerequisite state and does not include it in
dashboard attention items.

#### Likely root cause

Likely missing domain-specific routing/error mapping across dashboard and shell
tabs.

#### Frontend recommendation

Model profile/verification prerequisites explicitly; render a dashboard task and
CTA, and route blocked actions directly to the relevant form.

#### Backend recommendation

No business-rule change required. Preserve stable reason codes so clients can map
to corrective destinations.

#### Suggested UX solution

Replace “Nothing is waiting” with a setup checklist and progress: Company details
→ Evidence → Review.

#### Acceptance criteria

- [ ] Incomplete employer never sees “Nothing is waiting on you.”
- [ ] Every BR-03 gate includes a one-tap corrective CTA.
- [ ] Generic “Something went wrong” is not used for a known prerequisite.

### MT-011 — Verification state remains stale after employer profile creation

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Frontend State, Data Consistency, Error Recovery  
**Owner:** Frontend  
**Affected screen:** Employer → Company / Verification  
**Affected API:** Employer profile and verification-state endpoints  
**Reproducibility:** Always in the reproduced sequence

#### Problem

After the first profile Save, the verification area retained its prior not-found
error until the user manually tapped Try again.

#### Why this matters to the user

A successful profile action appears not to have unlocked its next step, creating
doubt and unnecessary recovery work.

#### Preconditions

- Employer starts without a profile.

#### Steps to reproduce

1. Open Company and save the initial profile.
2. Scroll to verification.
3. Observe stale error; tap Try again.

#### Expected result

Profile and verification providers refresh together and immediately show Not
submitted/required evidence.

#### Actual result

Old 404-derived state remains until manual retry.

#### Evidence

- [Stale state](evidence/MT-EMP-007-profile-bottom.png)
- [After retry](evidence/MT-EMP-008-verification-retry.png)

#### Technical analysis

The mutation invalidates/updates the profile state but not all dependent
verification providers.

#### Likely root cause

Likely incomplete Riverpod cache invalidation after profile creation.

#### Frontend recommendation

Invalidate profile, dashboard, verification, wallet, and prerequisite-derived
providers after first create; add an integration test for the no-profile → saved
transition.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

After valid Save, show success and smoothly reveal the verification checklist
without requiring Retry.

#### Acceptance criteria

- [ ] Verification updates immediately after profile creation/edit.
- [ ] No stale 404/error remains after a successful mutation.
- [ ] Dashboard attention state updates in the same session.

### MT-012 — Raw internal codes and incomplete numeric context leak into UI

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Localization, UX Writing, Frontend, API Contract  
**Owner:** Frontend + Backend  
**Affected screen:** Employer Verification; Admin vacancy review  
**Affected API:** Verification requirements; admin moderation detail  
**Reproducibility:** Always for affected records

#### Problem

The UI displays `company_registration`, `evidence`, and
`restriction_changed_requires_review` as user-facing text. Admin salary appears
as `150000` without currency or period context.

#### Why this matters to the user

Non-technical users cannot reliably interpret wire codes. Admins can misread a
salary or moderation history, and all four localization promises are broken for
these values (§3.2, BR-13).

#### Preconditions

- Open employer verification or a previously returned vacancy review.

#### Steps to reproduce

1. Scroll the verification requirements.
2. Open an admin vacancy review with a returned/restriction history.

#### Expected result

Localized labels and fully formatted money/status context.

#### Actual result

Raw stable codes and bare number are shown.

#### Evidence

- [Verification codes](evidence/MT-EMP-009-empty-verification-submit.png)
- [Admin review](evidence/MT-ADMIN-006-vacancy-review-bottom.png)

#### Technical analysis

Some code paths render API values directly rather than resolving code → localized
label. Salary composition omits associated period/currency metadata.

#### Likely root cause

Likely incomplete presentation mapping; verify whether list/detail DTOs always
include the context needed to format historical values.

#### Frontend recommendation

Centralize enum/code localization and money formatting. Unknown codes should use
a safe localized fallback and structured diagnostic logging, not raw UI.

#### Backend recommendation

Ensure admin detail/history responses carry salary currency/period and stable
reason codes; do not send English display strings as contract values.

#### Suggested UX solution

Use “Company registration document,” “Supporting evidence,” and “Returned because
restricted requirements changed,” with `150,000 UZS / month` style formatting.

#### Acceptance criteria

- [ ] No raw wire code is visible in any supported locale.
- [ ] Salary always includes localized number, currency, and period/negotiable state.
- [ ] Unknown new codes degrade to a localized neutral label and are logged.

### MT-013 — Phone and OTP validation allows premature submission and uses generic global errors

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Validation, UX, Authentication, Frontend  
**Owner:** Frontend + Backend  
**Affected screen:** Sign in; OTP verification  
**Affected API:** `POST /auth/otp/send`, `POST /auth/otp/verify`  
**Reproducibility:** Always

#### Problem

Five phone digits plus accepted terms can enable Get a code. OTP Confirm is
actionable when empty. Empty and incorrect code both create a large global
“Something went wrong” block rather than a stable inline correction.

#### Why this matters to the user

The app allows predictable mistakes, then shifts the page and gives weak guidance
instead of preventing/correcting them at the field.

#### Preconditions

- Signed out.

#### Steps to reproduce

1. Enter five phone digits, accept terms, tap Get a code.
2. On OTP, tap Confirm empty.
3. Enter a wrong six-digit code and confirm.

#### Expected result

Actions remain disabled until locally valid; field-level text explains length or
incorrect/expired code while keeping input and layout stable.

#### Actual result

Requests/global errors occur for obviously invalid input; empty and wrong OTP
look nearly identical.

#### Evidence

- [Short phone enabled](evidence/MT-VAL-001-short-phone.png)
- [Phone error](evidence/MT-VAL-002-phone-error.png)
- [Empty OTP](evidence/MT-AUTH-002-empty-code.png)
- [Wrong OTP](evidence/MT-AUTH-003b-wrong-code-result.png)

#### Technical analysis

Server validation correctly rejects invalid input. Client button enablement and
error mapping are not aligned with the known fixed-length Uzbek phone/OTP format.

#### Likely root cause

Likely form-validity state checks presence rather than full local validity; API
errors are routed through a generic page-error component.

#### Frontend recommendation

Validate nine national digits and six OTP digits locally, attach errors to the
field, preserve entered values, and distinguish invalid/expired/too-many-attempts
states.

#### Backend recommendation

Retain rate limits, TTL, attempt limits, single-use behavior, and stable localized
reason codes. No relaxation is required.

#### Suggested UX solution

Use concise inline copy and focus the first invalid field; reserve the global
error state for transport/service failure.

#### Acceptance criteria

- [ ] Get a code requires exactly nine national digits and accepted terms.
- [ ] Confirm requires exactly six digits.
- [ ] Empty, incorrect, expired, resend-too-soon, and rate-limited states are distinct.
- [ ] No page-level layout jump occurs for a field validation error.

### MT-014 — Offline error exposes backend/base-URL developer terminology

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Offline, UX Writing, Error Handling, Frontend  
**Owner:** Frontend  
**Affected screen:** Network-backed lists, reproduced on Candidate Vacancies  
**Affected API:** Any unreachable API request  
**Reproducibility:** Always when endpoint is unreachable

#### Problem

The user sees: “Cannot reach the server. Is the backend running, and is the base
URL correct for this device?”

#### Why this matters to the user

Ordinary users cannot run a backend or configure a base URL. The message implies
they are responsible for developer configuration and does not tell them whether
cached content is safe.

#### Preconditions

- Authenticated session; disconnect API route.

#### Steps to reproduce

1. Open a network-backed vacancy tab offline.
2. Trigger refresh.

#### Expected result

Localized offline/service-unavailable copy, cached content where safe, and Retry.

#### Actual result

Developer diagnostic copy is shown. Retry itself works after reconnection.

#### Evidence

- [Offline error](evidence/MT-RES-003-offline-error.png)
- [Recovered](evidence/MT-RES-004-offline-recovered.png)

#### Technical analysis

The common network exception mapper exposes a development troubleshooting string
to production UI.

#### Likely root cause

Confirmed copy/configuration boundary issue.

#### Frontend recommendation

Map connection, timeout, maintenance, and server failure to user-facing localized
messages; log base URL diagnostics only in development logs.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

“You're offline. Check your connection and try again.” Keep safe cached content
visible with a subtle stale indicator.

#### Acceptance criteria

- [ ] Production errors never mention backend, host, base URL, stack, or configuration.
- [ ] Retry recovers without restart or duplicate mutation.
- [ ] Offline empty state is distinguishable from true no-results state.

### MT-015 — Duplicate semantics and unlabeled picker controls impair screen-reader use

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Accessibility, Frontend, Design System  
**Owner:** Frontend  
**Affected screen:** App shell, authentication, candidate profile, forms  
**Affected API:** N/A  
**Reproducibility:** Always

#### Problem

Interactive labels are announced twice (for example, “Home, Home”), while profile
picker chevrons are separate clickable buttons with no name. Four visible profile
controls were `NAF=true` in one viewport.

#### Why this matters to the user

TalkBack users hear noisy navigation and encounter unnamed “Button” controls,
making form completion slow or ambiguous.

#### Preconditions

- Candidate profile or any shell screen; accessibility tree inspection/TalkBack.

#### Steps to reproduce

1. Inspect shell/field semantics.
2. Navigate bottom tabs and date/gender/region/district pickers.

#### Expected result

Each logical control has one concise accessible name, state/value, role, and a
minimum target.

#### Actual result

Labels are duplicated; chevron buttons have no description.

#### Evidence

- [Shell semantics XML](evidence/MT-A11Y-002-ui-hierarchy.xml)
- [Profile semantics XML](evidence/MT-A11Y-003-profile-hierarchy.xml)
- [Profile screen](evidence/MT-CANDV-012-profile.png)

#### Technical analysis

Parent controls and child text/icon semantics are not consistently merged or
excluded. The picker action is exposed separately from its labeled field.

#### Likely root cause

Likely shared design-component semantics composition, so one fix can cover many
screens.

#### Frontend recommendation

Audit `HhButton`, bottom navigation, select/date fields, checkboxes, and badges.
Use merged semantics or exclude decorative child semantics; label picker actions
with field name/current value.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

TalkBack should announce, for example, “Region, Tashkent City, button” once.

#### Acceptance criteria

- [ ] No primary control repeats the same label in TalkBack.
- [ ] Every actionable node has an accessible name and role.
- [ ] Full login, candidate profile, apply, and unlock journeys pass manual TalkBack QA.
- [ ] 200% text retains reachable actions without overlap.

### MT-016 — Vacancy Apply/Save controls are clipped and unusable in landscape

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Responsive UI, Mobile Compatibility, Frontend  
**Owner:** Frontend  
**Affected screen:** Candidate → Vacancies  
**Affected API:** N/A  
**Reproducibility:** Always on tested Pixel 8 landscape

#### Problem

In 2400 × 1080 landscape, the vacancy card extends under the fixed bottom
navigation. Apply and Save are reduced to an approximately 8-pixel visible/hit
strip. Scrolling moves between cards but does not expose a usable action row.

#### Why this matters to the user

The primary candidate action is effectively impossible after rotation, despite
the app allowing orientation changes.

#### Preconditions

- Candidate vacancy feed with results; rotate device to landscape.

#### Steps to reproduce

1. Open Candidate → Vacancies.
2. Rotate 90 degrees.
3. Try to tap Apply or Save; scroll the list.

#### Expected result

Card content/actions remain visible and tappable, or the app deliberately locks a
supported orientation.

#### Actual result

Actions are clipped by the viewport/navigation layout.

#### Evidence

- [Landscape initial](evidence/MT-RESP-002-landscape.png)
- [Landscape after scroll](evidence/MT-RESP-003-landscape-scrolled.png)

#### Technical analysis

Portrait-oriented card height/action placement is combined with a fixed shell
bottom area and insufficient landscape constraints/insets.

#### Likely root cause

Likely missing responsive breakpoint and incorrect available-height calculation.

#### Frontend recommendation

Use compact horizontal/card detail layout in landscape, ensure list bottom
padding equals navigation inset, and test action visibility via widget golden and
device integration tests.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

Keep title/metadata and Apply/Save in a compact row, with details accessible by
tapping the card.

#### Acceptance criteria

- [ ] Apply and Save retain at least 48 × 48 logical-pixel targets in landscape.
- [ ] No content/action is obscured by system or bottom navigation insets.
- [ ] Rotating back preserves selected tab and scroll position.

### MT-017 — Admin complaint cards omit the reported target identity

**Severity:** MEDIUM  
**Priority:** P2  
**Category:** Admin UX, Backend Contract, Efficiency  
**Owner:** Frontend + Backend  
**Affected screen:** Administrator → Complaints  
**Affected API:** Admin complaints list endpoint  
**Reproducibility:** Always for tested list

#### Problem

Complaint cards show target type (“Vacancy”/“Person”), waiting status, and reason,
but not the vacancy title or person's/company's name/phone.

#### Why this matters to the user

Multiple cards look identical. Moderators must open each detail to understand the
case, increasing time and the risk of acting on the wrong item.

#### Preconditions

- Administrator with multiple open complaints.

#### Steps to reproduce

1. Open Complaints.
2. Compare list cards without opening detail.

#### Expected result

Each card identifies the reported target and enough context to prioritize safely.

#### Actual result

Target identity is absent until detail.

#### Evidence

- [Complaint list](evidence/MT-ADMIN-007-complaints.png)
- [Complaint detail](evidence/MT-ADMIN-008-complaint-detail.png)

#### Technical analysis

Detail resolution has target data, but list presentation/DTO does not surface a
display identity.

#### Likely root cause

Requires contract verification: either list DTO omits target summary or frontend
does not render the available field.

#### Frontend recommendation

Render target title/name plus masked phone/ID secondary context where authorized.

#### Backend recommendation

Add a safe `targetDisplayName`/summary to list items if absent, respecting deleted
targets and admin authorization.

#### Suggested UX solution

Show “Vacancy · QA Engineer — Uzum” or “User · Dilnoza Yusupova,” then reason and
age/status.

#### Acceptance criteria

- [ ] Every complaint card is distinguishable without opening detail.
- [ ] Deleted/anonymized targets use an explicit safe fallback.
- [ ] List and detail identify the same target.

### MT-018 — Incoming candidate invitation is labelled “Sent”

**Severity:** MEDIUM  
**Priority:** P3  
**Category:** UX Writing, Status Model, Frontend  
**Owner:** Frontend + Product  
**Affected screen:** Candidate → Applications → Invitations  
**Affected API:** Invitation list/status  
**Reproducibility:** Always for a new incoming invitation

#### Problem

The candidate's incoming invitation card displays status “Sent,” an employer-side
event verb, before the candidate responds.

#### Why this matters to the user

It can sound as if the candidate sent something. The required action/urgency is
less clear than “New,” “Awaiting your response,” or “Received.”

#### Preconditions

- Candidate has an unanswered employer invitation.

#### Steps to reproduce

1. Open Applications → Invitations as the recipient.
2. Inspect the status badge.

#### Expected result

Recipient-perspective localized status that makes the pending action clear.

#### Actual result

“Sent” is displayed.

#### Evidence

- [Incoming invitation](evidence/MT-CANDV-007-invitations.png)

#### Technical analysis

The same wire status is likely mapped to one label for both employer and candidate
surfaces.

#### Likely root cause

Likely role-agnostic presentation mapping, not incorrect server state.

#### Frontend recommendation

Keep the wire status unchanged but map display text by viewer perspective.

#### Backend recommendation

No backend change required.

#### Suggested UX solution

Use “Awaiting your response” and keep Accept/Ask a question visually primary.

#### Acceptance criteria

- [ ] Candidate and employer labels reflect their respective perspective.
- [ ] All invitation states are localized in four variants.

### MT-019 — Unfiltered candidate search displays a misleading “100% match”

**Severity:** LOW  
**Priority:** P3  
**Category:** UX, Search, Backend Contract  
**Owner:** Frontend + Product  
**Affected screen:** Employer → Candidates  
**Affected API:** Candidate search  
**Reproducibility:** Always with no filters

#### Problem

With “No filters — every searchable candidate,” the sole result displays “100%
match,” despite no employer requirements being supplied.

#### Why this matters to the user

The score appears to recommend a perfect candidate and can distort hiring
judgment. Mathematically matching an empty criterion set is not useful product
information.

#### Preconditions

- Verified employer; searchable candidates; no filters.

#### Steps to reproduce

1. Open Candidates.
2. Leave all filters empty and tap Search.

#### Expected result

Hide the score or display “No match criteria” and sort by a transparent fallback.

#### Actual result

Every unfiltered candidate receives 100%.

#### Evidence

- [Unfiltered results](evidence/MT-EMPV-003-candidate-results.png)

#### Technical analysis

Confirmed backend design: zero active score groups return 100 and tests assert
it. The algorithm is internally consistent but the UI label is misleading.

#### Likely root cause

Product semantics were optimized for numeric consistency rather than user
interpretation.

#### Frontend recommendation

Hide the percentage when `matchBreakdown` is empty and label the ordering (for
example, recently updated).

#### Backend recommendation

Optionally return nullable score or an explicit `hasMatchCriteria` flag; do not
force clients to infer meaning from an empty breakdown.

#### Suggested UX solution

Display “Add filters to calculate fit” above results.

#### Acceptance criteria

- [ ] No 100% claim is shown with zero criteria.
- [ ] Filtered searches retain accurate score and breakdown.

## 22. Frontend Developer Action List

| ID | Severity | Screen | Problem | Frontend Action |
|---|---|---|---|---|
| MT-001 | CRITICAL | Candidate Home | Release placeholder | Map a real Home screen; add production-route placeholder test. |
| MT-002 | CRITICAL | Admin Users | User management unavailable | Wire list/detail/status flows to existing admin APIs. |
| MT-003 | CRITICAL | Vacancy Submit | UI accepts immediately active result | Render explicit Under moderation state; add environment E2E assertion. |
| MT-004 | HIGH | Admin Dictionaries | Dictionary management unavailable | Ship mobile type/item CRUD, activation, hierarchy, and merge UI. |
| MT-005 | HIGH | All roles | No notification center/push/deep links | Implement list, badges, token lifecycle, permission, preferences, and routing. |
| MT-006 | HIGH | Wallet | Top up is roadmap snackbar | Implement provider-driven checkout/status/history and empty-provider state. |
| MT-007 | HIGH | Company profile | Blank save locks employer type | Require explicit type and valid fields; support safe reset/change. |
| MT-008 | HIGH | Admin shell | No sign-out/account route | Expose common Account/Security from admin app bar. |
| MT-009 | MEDIUM | Candidate attachment | Purpose code treated as UUID | Resolve code correctly and introduce distinct client value types. |
| MT-010 | MEDIUM | Employer shell | Prerequisite failures lack CTA | Model domain prerequisites and route directly to correction. |
| MT-011 | MEDIUM | Company/Verification | Dependent state stale after save | Invalidate all dependent providers after create/update. |
| MT-012 | MEDIUM | Verification/Admin review | Raw codes and bare salary | Centralize code localization and money formatting. |
| MT-013 | MEDIUM | Auth | Premature submit/global errors | Align button validity and inline error mapping with known formats. |
| MT-014 | MEDIUM | Network states | Developer error copy | Separate production copy from diagnostic logs. |
| MT-015 | MEDIUM | Shared components | Duplicate/unlabelled semantics | Fix semantics in design-system controls and run TalkBack regression. |
| MT-016 | MEDIUM | Vacancy feed | Landscape actions clipped | Add responsive layout/insets and rotation tests. |
| MT-017 | MEDIUM | Admin Complaints | Cards omit identity | Render safe target summary on each card. |
| MT-018 | MEDIUM | Candidate Invitations | Recipient sees “Sent” | Use role-perspective status labels. |
| MT-019 | LOW | Candidate Search | 100% with no criteria | Hide score when breakdown is empty. |

## 23. Backend Developer Action List

| ID | Severity | Endpoint/Module | Problem | Backend Action |
|---|---|---|---|---|
| MT-003 | CRITICAL | Vacancy submit / deployment | Moderation flag disabled | Enable in release/staging and add deployment smoke gate for non-discoverability before approval. |
| MT-005 | HIGH | Notifications/FCM | Client delivery path not operational | Configure DEV/staging FCM, token lifecycle, monitoring; retain in-app records on push failure. |
| MT-006 | HIGH | Payments | No configured checkout provider | Configure approved sandbox/store provider and run UAT-20–23 callback/idempotency matrix. |
| MT-007 | HIGH | Employer profile | Empty, wrong-type draft can persist | Define/reject empty create and support safe unused-incomplete type reset. |
| MT-009 | MEDIUM | Dictionaries contract | String code can be misused as UUID | Strengthen generated contract/docs/types; existing UUID validation should remain. |
| MT-010 | MEDIUM | Domain error codes | Known prerequisite rendered generically | Preserve stable reason/action codes; no rule relaxation. |
| MT-012 | MEDIUM | Admin/verification DTOs | Presentation context may be incomplete | Ensure history/detail includes period/currency and stable localization codes. |
| MT-013 | MEDIUM | Auth | Client validation weak | Retain server TTL/attempt/rate limits and distinct stable error reasons. |
| MT-017 | MEDIUM | Admin complaint list | Target summary insufficient | Add authorized target display summary with deleted-target fallback if absent. |
| MT-019 | LOW | Candidate score | Empty criteria returns 100 | Consider nullable score or explicit `hasMatchCriteria`. |

Before real users: revert the temporary DEV master-key state by clearing
`OTP_STATIC_CODE`, use an actual OTP provider, and return `NODE_ENV=production`.
Do not place real data behind the current public static-code deployment.

## 24. UX / Product Improvement List

| ID | Screen | UX Problem | Proposed Improvement | Impact |
|---|---|---|---|---|
| MT-001 | Candidate Home | Internal milestone instead of value | Recommended jobs + profile/action summary | Very high: fixes default candidate impression. |
| MT-007 | Employer onboarding | Irreversible default type | Explicit no-default “Who is hiring?” step | Very high: prevents trapped accounts. |
| MT-010 | Employer Home | Contradictory readiness message | Setup checklist with direct CTAs | High: makes activation self-service. |
| MT-005 | All roles | No event return loop | Notification inbox/badge/deep links | Very high: prevents missed hiring events. |
| MT-006 | Wallet | Dead-end paywall | Provider-aware funding and resume unlock | Very high: restores monetization/task completion. |
| MT-013 | Auth | Avoidable invalid submissions | Inline, actionable, stable validation | High frequency, low complexity. |
| MT-012 | Admin/Verification | Internal terminology | User-language labels and complete formatting | Medium: comprehension/trust. |
| MT-017 | Complaints | Indistinguishable cards | Add target identity/context | Medium: faster, safer moderation. |
| MT-018 | Invitations | Wrong perspective label | “Awaiting your response” | Medium: clearer primary action. |
| MT-019 | Search | False precision | Hide score until criteria exist | Medium: improves hiring trust. |

### Quick Wins

- Replace the offline backend/base-URL sentence with localized connection copy.
- Hide “100% match” when `matchBreakdown` is empty.
- Map candidate invitation `sent` to “Awaiting your response.”
- Localize `company_registration`, `evidence`, and moderation reason codes.
- Format admin salary with grouping, UZS, and pay period.
- Add profile/verification CTAs to known prerequisite errors.
- Disable OTP actions until fixed-length input is present.
- Invalidate verification/dashboard providers after employer profile Save.
- Add target identity to complaint cards if already present in the response.
- Route candidate login to Vacancies until the real Home screen ships.

## 25. Suggested Regression Tests

### Release-shell gate — Widget + integration + E2E

- Enumerate every production `ShellTab`; fail if it resolves to
  `ShellPlaceholderScreen` or contains “arrives in M…”.
- Cold-start each candidate/employer/admin role and exercise every bottom tab.
- Assert development-only controls are absent while sign-out remains reachable.

### Employer onboarding — Widget + API + E2E

- No type preselection; empty/whitespace/overlong input; back/resume.
- Wrong type then change/reset before dependent records.
- Save valid company and individual profiles; verify dependent providers refresh.
- Double Save, timeout retry, background during Save, stale response order.

### Vacancy moderation — API + deployment smoke + E2E

- Submit once/double tap/retry; exactly one status transition.
- Assert `under_moderation`, queue membership, candidate non-discoverability.
- Approve/reject/request changes and verify audit + employer notification.
- Run the same smoke against the actual release environment configuration.

### Wallet and unlock — Unit + API + E2E

- 10 → 8 first unlock; revisit/double tap/network retry remains 8.
- Concurrent unlock requests; debit/entitlement atomicity.
- Balance 0/1 routes to Top up and resumes candidate context.
- Payme/CLICK/store success, duplicate callback, invalid amount/account,
  cancelled/failed/refunded, and reconciliation.

### Notifications — API + integration + manual device

- Every §9.2 event creates exactly the right recipient record.
- Permission allowed/denied/later enabled; foreground/background/killed app.
- Token refresh, logout token removal, invalid token, multiple devices.
- Deep link switches role and opens only authorized target.

### Hiring interactions — API + E2E

- Duplicate invitation/application/interview/message under double tap and retry.
- All application/interview legal and illegal transitions with history actor/time.
- Employer starts chat only after unlock; candidate receives unread, replies, marks
  read, blocks/reports, and sees read-only closed interaction.

### Accessibility/responsive — Widget golden + manual

- Semantics assertions for one label/action node per shared component.
- TalkBack login, profile, search/apply, unlock, invitation, admin moderation.
- 100%, 130%, 200% font; 720p, 1080p, API-24 minimum, landscape, tablet/foldable.
- Assert primary action rectangles are at least 48 logical pixels and not
  intersecting navigation/system insets.

### Error/reliability — Integration + manual

- Offline, DNS failure, timeout, 500/502/503, 401 refresh, 403 blocked, 409 stale,
  422 field errors, and 429 with countdown.
- Network loss during each critical mutation; retry must not duplicate.
- Cached content distinguishes stale/offline from genuine empty results.

## 26. Test Coverage / Not Tested Areas

### Coverage Matrix

| Feature | Happy | Invalid | Offline | Double action | Resume/back | UX | Permission/business |
|---|---|---|---|---|---|---|---|
| Launch/session | Tested | Partly | N/A | N/A | Tested | Tested | Partly |
| Phone/OTP | Tested | Tested | Not tested during submit | Partly | Tested | Tested | Rate-limit depth not tested |
| Employer profile | Partly | Tested empty | Not tested | Tested Save tap | Tested | Tested | Gate tested |
| Verification | Partly | Tested incomplete | Not tested | Partly | Tested | Tested | Admin decision cancelled |
| Candidate search | Tested no-filter | Partly | Tested failure/retry | N/A | Tested | Tested | Protected data tested |
| Candidate Unlock | Tested | Duplicate/revisit tested | Not during debit | Tested | Tested | Tested | Atomic DB result tested |
| Invitations | Tested send/respond | Duplicate 409 tested | Not tested | Tested | Tested | Tested | Role response tested |
| Vacancy create/submit | Tested | Empty form tested | Not during write | Tested | Tested | Tested | Moderation config failed |
| Discovery/save/apply | Tested | Duplicate tested | Cached Saved tested | Tested | Tested | Tested | BR-07 tested |
| Applications/status | Tested | Partly | Not tested | Tested | Tested | Tested | History checked |
| Interviews | Tested | Required fields partly | Not tested | Tested | Tested | Tested | History/response checked |
| Chat | Tested two-way | Empty message partly | Not tested | Send guard partly | Tested | Tested | Unlock gate tested |
| Wallet top-up | Unavailable | Unavailable | Unavailable | Unavailable | Unavailable | Tested dead end | UAT-19–23 incomplete |
| Admin dashboard | Tested | N/A | Not tested | N/A | Tested | Tested | Admin-only session |
| Admin moderation | Read/confirm tested | Decision validation partly | Not tested | Mutation cancelled | Tested | Tested | Actual decision not changed |
| Admin complaints | List/detail tested | Not tested | Not tested | Mutation not run | Tested | Tested | Admin-only session |
| Admin Users | Not available | Not available | Not available | Not available | Not available | Tested placeholder | UAT-14 blocked |
| Admin Dictionaries | Not available | Not available | Not available | Not available | Not available | Tested placeholder | BR-13 admin blocked |
| Localization | Representative tested | Raw-code cases found | N/A | N/A | Persistence tested | Tested | Four variants |
| Accessibility | Partial | N/A | N/A | N/A | Partial | Semantics/text scale | TalkBack E2E not run |
| Device layout | Portrait/small/landscape | Landscape failed | N/A | N/A | Rotation partly | Tested | Physical/tablet absent |

### Explicitly Not Tested / Unavailable

- Real SMS delivery; authentication used the owner-authorized static DEV code.
- Payme, CLICK, Google Play Billing, Payment Orders, callbacks, refunds, and
  reconciliation because no provider is available.
- Push notification delivery, permission, device token, and notification deep
  links because the 1.4.1 client does not implement them.
- Exhaustive admin user/dictionary/audit/wallet/payment functions because the
  release UI routes are missing; direct destructive API mutation was not used as
  a substitute for absent UI.
- Real file upload/download/cancel/progress and malware scan. Local QA API storage
  had an external Telegram connectivity limitation; no product result is claimed.
- Account deletion execution/retention purge; only account/security surface and
  confirmations were reviewed.
- Forced access-token expiry/refresh race, simultaneous multi-device session, and
  exhaustive IDOR/security exploitation.
- Blocked/restricted account mutation from the mobile admin UI (blocked by MT-002).
- Vacancy deadline expiry, pause/close/reopen, offer/hired/rejected/withdrawn full
  matrix, age/gender restriction approval, and seasonal UAT-10 data matrix.
- Exhaustive search/filter combinations, pagination under large datasets, Unicode,
  emoji, whitespace, and sorting edge values.
- Slow 2G/packet loss, timeout during write/payment, background during mutation,
  hours-long soak, memory, battery, thermal, and server load testing.
- Physical phones, API-24 minimum device, tablet, foldable, OEM skins/keyboards,
  camera/location flows, and iOS (project scope is Android on this Windows host).
- Professional translation review, instrumented contrast measurement, full
  TalkBack/switch-access journey, and external keyboard.

## 27. Final Assessment

If version 1.4.1 were released to thousands of ordinary users tomorrow, the first
support complaints would be “the Home screen says it arrives later,” “I cannot
block a user as admin,” “my vacancy appeared without review,” “I did not receive
an update,” “I cannot buy more Coins,” and “I chose the wrong employer type and
cannot undo it.” Those are prominent release blockers, not polish.

The product is nevertheless beyond a throwaway prototype. Its API/domain
foundations showed good integrity: server-side uniqueness, wallet atomicity,
protected contact, role gates, histories, visibility, localization, and two-way
hiring workflows worked in meaningful DEV data. The correct strategy is not a
rewrite; it is to finish the missing release surfaces, align deployment flags
with the specification, and harden the shared UX/accessibility components.

**Minimum release gate:** close MT-001 through MT-008, enable moderation, remove
the static OTP master key/connect real authentication delivery, complete push and
top-up, then execute the regression suite in Section 25 on the exact signed APK
and actual release backend configuration. MT-009 through MT-018 should be fixed
before broad beta because they affect paid trust, onboarding recovery,
accessibility, localization, and landscape task completion.

**Final verdict: not ready for production; suitable for continued controlled DEV
testing after acknowledging the public static-code risk.**
