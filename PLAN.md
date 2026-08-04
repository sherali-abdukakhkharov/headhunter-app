# headhunter-app - Delivery plan

Milestones in dependency order, mapped to the business rules (BR-nn) and
acceptance scenarios (UAT-nn) of [docs/SPEC.md](docs/SPEC.md). Design rationale is
in [ARCHITECTURE.md](ARCHITECTURE.md); the working checklist is
[TODO.md](TODO.md).

**Milestone numbers match the backend's `PLAN.md`.** The client is downstream: an
app milestone can start on UI and local state early, but cannot *finish* before
the matching backend milestone ships a contract. The dependencies that actually
bite:

| App milestone | Needs from backend |
|---|---|
| M1 onboarding | auth endpoints, role selection |
| M3 candidate profile | dictionaries (M2) **and** the category field-schema contract |
| M5 vacancy forms | dictionaries + vacancy contract |
| M7 candidate search | search + count + prefill contract |

Dictionary work (backend M2) blocks every picker in the product. Treat it as the
critical path.

---

## Milestone status

| # | Milestone | State |
|---|---|---|
| M0 | Foundations: toolchain, health slice, error handling | **done** |
| M0.5 | App shell: localization, flavors, design system, role shell skeleton | next |
| M1 | Onboarding: language, phone + OTP, role selection, session | after M0.5 |
| M2 | Dictionary cache + reusable pickers | after M1 |
| M3 | Candidate profile: dynamic forms, completeness, privacy, CV | after M2 |
| M4 | Employer profile + verification status | after M1 |
| M5 | Vacancy create/edit + statuses (employer) | after M2 + M4 |
| M6 | Vacancy discovery + applications (candidate) | after M2 + M3 |
| M7 | Candidate search + invitations + shortlists (employer) | after M2 + M5 |
| M8 | Chat + interviews | after M6 + M7 |
| M9 | Notifications + push + deep links | after M6 |
| M10 | Admin module | after M4 + M5 |
| M11 | Hardening: performance, accessibility, offline, acceptance | last |

---

## M0 - Foundations *(done)*

Flutter 3.44.8 project with Riverpod 3 + go_router + dio, `com.headhunter.app`,
feature-first layout, `ApiException` error mapping, a verified end-to-end health
slice, and CI for analyze/test/APK plus an iOS no-codesign build.

## M0.5 - App shell

No spec section of its own, but everything downstream depends on it. Doing this
before M1 avoids retrofitting localization and flavors through finished screens -
which is the expensive way to learn this lesson.

- `flutter_localizations` + `gen-l10n`; four ARB files including both Uzbek
  scripts (ARCHITECTURE.md §4).
- Locale controller: pre-auth local persistence, post-auth server sync.
- `x-lang` request interceptor.
- CI check that all four ARB files share one key set.
- Three flavors (development / testing / production) with per-flavor API base URL,
  app id suffix and display name.
- Design system: colours, typography with font-scale tolerance, spacing, and the
  shared primitives (buttons, fields, empty/error/loading states, chips).
- `StatefulShellRoute` skeleton with a placeholder shell per role, and the
  redirect chain (unauthenticated / no role / blocked / role not granted).
- Secure token storage + auth interceptor with **single-flight refresh**.
- Idempotency-key interceptor backed by persisted keys.

**Done when:** the app launches in all four variants, switches language live,
builds in three flavors, and the role shell can be switched with a hardcoded role.

## M1 - Onboarding and session

**Covers** §4, §2.3 · **BR-01, BR-10** · **UAT-01**

- Language selection **before** registration (§3.2).
- Phone entry, terms and privacy acceptance, OTP entry with resend timer and
  attempt feedback driven by server config.
- Role selection: candidate, employer, or both; route into the right onboarding.
- Role switching from the profile area (§2.3).
- Sessions screen: list devices, sign out, terminate all.
- Blocked-account screen explaining the restriction (BR-10, UAT-14 client side).
- Account deletion request flow.

**Done when:** UAT-01 passes - register in any of the four variants, land in
candidate onboarding, and the chosen locale is retained.

## M2 - Dictionary cache and pickers

**Covers** §3.3, §10.3 · **BR-13** · **UAT-13**

- Versioned per-locale cache keyed by `(type, fullLocaleTag)`.
- Searchable single- and multi-select pickers that **display labels and bind IDs**.
- Region → district cascading picker.
- Dictionary + level pickers for skills and languages (CEFR A1–C2 / native).
- Label resolution by ID for deactivated/historical items.

**Done when:** switching between all four variants changes every label while
selected values (IDs) stay put - the client half of UAT-13.

## M3 - Candidate profile

**Covers** §5 · **BR-02** · **UAT-02, UAT-03, UAT-12**

- Schema-driven form engine (ARCHITECTURE.md §6) with the widget kinds the spec
  needs.
- Profile sections of §5.1; simplified experience entry for informal/seasonal work.
- Category-adaptive fields; irrelevant fields never mandatory (§5.2).
- Completeness percentage with a missing-field list linking straight to the
  relevant editor (§5.3).
- Privacy control: searchable / hidden / visible-after-apply (UAT-12).
- Last-meaningful-update display.
- CV upload/replace/download/delete with progress, failure reason and retry
  (UAT-03); optional certificates.

## M4 - Employer profile

**Covers** §6.1 · **BR-03** · **UAT-04**

- Company and individual employer forms.
- Verification submission with evidence upload.
- Verification status display including admin reason and a changes-required path.
- BR-03 gating in the UI: explain what is missing before invitations or vacancy
  submission are possible.

## M5 - Vacancy management

**Covers** §6.3, §6.4 · **BR-05, BR-12** · **UAT-05, UAT-10**

- Vacancy create/edit using the form engine across all six categories of §6.3.
- Structured requirements: skills with level, languages with level plus
  mandatory/preferred, experience, education, attributes.
- Status display and transitions available to the employer (§6.4), with moderation
  rejection reasons shown.
- Worker count `>= 1` (BR-05); conditional age/gender fields warn that they
  require justification and moderation (BR-12).
- Seasonal/agricultural flow verified explicitly (UAT-10).
- Employer dashboard widgets (§6.2).

## M6 - Discovery and applications

**Covers** §5.5, §5.6, §8.1 · **BR-06, BR-07** · **UAT-08, UAT-15**

- Candidate home: recommended, recent, saved vacancies, profile-completion prompt.
- Vacancy filters (§5.5) as chips + sheets.
- Vacancy details with employer verification badge, and Apply / Save / Share /
  Report.
- One active application per vacancy enforced in the UI as well as the server
  (BR-07) - the button state must reflect it.
- Application list with all stages of §8.1; withdraw where permitted.
- Deadline-expired and closed vacancies render correctly (UAT-15).
- Employer side: applications per vacancy, filters, stage moves, internal notes,
  hired-vs-required counts (§6.5).

## M7 - Candidate search

**Covers** §7, §8.2 · **BR-09** · **UAT-06, UAT-07**

- Filter builder covering all groups of §7.1: searchable lists, chips, switches,
  date pickers, numeric ranges (§7.2).
- Match count before opening results, rendered as "200+" when inexact (§7.2).
- Applied filters as removable chips; reset-all and edit-one.
- Result list with sort options and candidate cards per §7.3 - **no phone numbers
  on cards** (§11.1, BR-09).
- Prefill from a vacancy, still editable (UAT-06).
- Save candidates, vacancy shortlists, private notes.
- Send invitations and track responses (UAT-07); general invitations (§8.2).
- Locally retained last search configuration (§7.2).

## M8 - Chat and interviews

**Covers** §9.1, §8.3 · **UAT-09**

- Conversation list and thread; text plus approved attachments.
- Sent / delivered / read indicators where the backend supplies them.
- Report and block; read-only history for closed interactions.
- Interview scheduling display by type (phone / in-person / external link),
  instructions, and confirm / request-another-time.

## M9 - Notifications

**Covers** §9.2

- In-app list, unread badge, mark read.
- Push registration and handling; **deep links that switch role first when needed**
  (ARCHITECTURE.md §3).
- Preferences with security/account categories not disableable.

## M10 - Admin module

**Covers** §10 · **UAT-11, UAT-14**

- Admin shell behind the admin role.
- Dashboard counters (§10.1).
- Employer verification and vacancy moderation with mandatory reason entry.
- Complaint review queues.
- User search and warn/restrict/block/unblock with reason (UAT-14).
- Dictionary management with all four localized labels and skill merging (§10.3) -
  mobile-optimized, since there is no web panel.

## M11 - Hardening and acceptance

**Covers** §12.1, §12.4, §13

- Adaptive layout pass: small phones, large font scale, safe areas.
- Cached primary screens open without blocking; loading states everywhere network
  data is fetched (§12.4).
- Offline behaviour: explicit state, safe retry, no duplicate writes.
- Crash reporting and structured logging with no sensitive data.
- Release signing config for Android; iOS build path documented.
- Walk all 15 UAT scenarios; keep the evidence (§13.2).

---

## Cross-cutting work not owned by one milestone

| Work | When |
|---|---|
| ARB keys for every new string, in all four variants | with each screen |
| Dictionary-ID discipline (never bind a label) | with each picker |
| Idempotency key on each new non-idempotent write | with the call |
| Invalidation list next to each mutation | with the mutation |
| Large-font-scale check on new dense cards | with the card |
| UAT evidence | from M1 onward |
