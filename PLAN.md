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
| M12 wallet | wallet balance/pricing/ledger + the atomic unlock endpoint |
| M13 top-up | payment-order contract, provider callbacks, verified credit |

Dictionary work (backend M2) blocks every picker in the product. Treat it as the
critical path.

---

## Spec revision 2026-08-10 - the Coin wallet

The client issued a revised .docx adding employer monetization: a Coin wallet
(§6.6), top-up through Payme and CLICK (§6.7), admin wallet/payment screens
(§10.5), ten new business rules (**BR-15 – BR-24**) and nine new acceptance
scenarios (**UAT-16 – UAT-24**). `docs/SPEC.md` has been regenerated from it in
both repos, and the section-by-section diff is in
[docs/SPEC_CHANGELOG.md](docs/SPEC_CHANGELOG.md).

**This is not only new milestones — it changes a rule already built against.**
§11.1 previously read "phone number and full contact details are not shown in
general candidate search cards". It now reads: phone, e-mail and CV "become
available to that employer only after a successful Candidate Unlock or another
explicitly approved entitlement". §8.2 and §9.1 follow: an employer may review a
candidate for free, but **revealing contact, downloading the CV, starting chat
and scheduling an interview all now require a paid entitlement** — a candidate's
application is no longer sufficient on its own.

So BR-09 has gained a gate in front of it rather than moved. The card rule is
unchanged and still holds; what changed is what an *interaction* entitles an
employer to. **M7's shipped contact-exposure copy is now wrong** and is
explicitly owned by M12 — see the note there for why it has not been changed
yet.

### Ask the client this before starting M12

§11.1 says contact opens after "a successful Candidate Unlock **or another
explicitly approved entitlement**". Whether *an application* counts as one of
those is a one-line answer from the client, and it decides how much of M6/M7
has to be retrofitted:

- **If an application still grants contact** — a candidate who applied has
  volunteered it, which is a defensible reading — then today's behaviour stands,
  the shipped exposure copy stays correct, and M12 only adds unlock for
  candidates who have *not* applied.
- **If it does not** — which is what §9.1 says as written — then an employer who
  received an application must still pay to phone the person who applied to
  them, and M6, M7 and M8 all change.

Raised by the backend first; the reasoning is in
[SPEC_CHANGELOG.md](docs/SPEC_CHANGELOG.md). Half of M12's retrofit hangs on it,
so it is worth an email before it is worth an estimate.

Two things the client owes before M13 can finish, neither of them code:
**Payme and CLICK merchant credentials** for the provider test environment
(§12.6), and a **storefront billing decision** (§12.7, BR-23) — whether Coin
purchases ship through Payme/CLICK or must go through Apple IAP / Google Play
Billing. The wallet ledger stays provider-agnostic either way, which is what
makes the decision deferrable; the *checkout surface in the app* does not.

---

## Milestone status

Numbers are identifiers shared with the backend, **not delivery order** — M9 has
been numbered 9 and delivered last since 2026-08-04, and the wallet is numbered
after M11 while being delivered before M8.

| # | Milestone | State |
|---|---|---|
| M0 | Foundations: toolchain, health slice, error handling | **done** |
| M0.5 | App shell: localization, flavors, design system, role shell skeleton | **done** - two items carried, see TODO.md |
| M1 | Onboarding: language, phone + OTP, role selection, session | **next** - blocked on the auth contract for the session half |
| M2 | Dictionary cache + reusable pickers | after M1 |
| M3 | Candidate profile: dynamic forms, completeness, privacy, CV | after M2 |
| M4 | Employer profile + verification status | after M1 |
| M5 | Vacancy create/edit + statuses (employer) | after M2 + M4 |
| M6 | Vacancy discovery + applications (candidate) | after M2 + M3 |
| M7 | Candidate search + invitations + shortlists (employer) | after M2 + M5 — **partly re-opened by the 2026-08-10 revision** |
| M12 | Employer wallet, Coins, Candidate Unlock | after M7 — **and M8 cannot finish before it** |
| M13 | Coin top-up: Payme and CLICK | after M12; blocked on client-supplied merchant credentials |
| M8 | Chat + interviews | after M6 + M7 **+ M12** (§9.1 gates employer-initiated chat on the unlock) |
| M9 | Notifications + push | **last feature milestone** - after M10 |
| M10 | Admin module (now including §10.5 wallet/payment administration) | after M4 + M5 + M12 |
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

**Met, verified on an emulator** (2026-08-04): onboarding → developer tools → all
three role shells, live switch to Uzbek Cyrillic across the whole shell, the BR-10
blocked notice with the admin's reason verbatim, session restored across a cold
start, and the long admin label wrapping at its soft hyphen without growing the
70pt bar. 132 tests; `flutter analyze` clean.

Carried forward, neither blocking M1: **bottom sheets** (the last design-system
primitive, first needed by the M2 pickers) and **iOS flavor schemes** (needs a
Mac). Installing `AuthInterceptor` remains blocked on the backend's auth contract.

Three M1 items landed here because the redirect chain needed real destinations
rather than dead ends: the pre-registration language picker, the role-selection
mechanism, and the blocked-account screen.

## M1 - Onboarding and session

**Covers** §4, §2.3 · **BR-01, BR-10** · **UAT-01**

**Sign-in is phone + OTP**, as §4.1 and UAT-01 specify. Telegram login was tried
and deprecated on 2026-08-05; **BR-01 and UAT-01 therefore need no re-wording,
and the sign-off that was pending is moot.** Verifying a code makes the number
verified, so BR-01 is satisfied by construction. Why the reversal, and what of
the Telegram work survives: [docs/TELEGRAM_LOGIN.md](docs/TELEGRAM_LOGIN.md).

*No SMS provider is connected yet — the backend issues a fixed `OTP_STATIC_CODE`.
Connecting a provider is a backend-only change, and* **M1 is not done until it is
either connected or explicitly deferred by the client.**

- Language selection **before** registration (§3.2).
- Terms and privacy acceptance, then phone entry and code entry.
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

Added by the 2026-08-10 revision:

- **The wallet appears at first employer registration** (§6.6, BR-15, UAT-16).
  The grant is entirely server-side and the app must not attempt to trigger it:
  "exactly once" survives logout, reinstall, device change and role switching
  only if the client has no say in when it happens. The app's job is to show the
  balance that comes back and never to compute one.

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
- Employer dashboard widgets (§6.2), which the 2026-08-10 revision extends with
  a **Wallet tile**: Coin balance, approximate UZS value, recent activity and a
  Top up action. The approximate value is rendered from the server's current
  price, never from a constant in Dart (§6.6).

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

### Re-opened by the 2026-08-10 revision

The search half of M7 is unaffected — cards were already free of contact detail
and stay that way. What changed is everything downstream of a card:

- §7.3 now says phone, e-mail and CV "are locked until Candidate Unlock is
  purchased for that employer". The result card is unchanged; the **profile view
  behind it** gains a locked state and an "Unlock contact — 2 Coins" action.
- §8.2 now requires an entitlement before an invitation can carry contact
  context, so **UAT-07 cannot be finished before M12**.
- **The shipped contact-exposure copy is now wrong and is deliberately left
  alone.** `exposureExplanation` tells an employer that contact "opens once this
  candidate applies to one of your vacancies", which the revision has just made
  untrue. It is still exactly right for *today's server*, which has no unlocks
  and no new reason codes. Correcting the copy before the backend returns the
  new codes would replace one wrong sentence with another and lose the mutation
  tests that pin it. It moves with M12, in the same change as the codes.

## M12 - Employer wallet, Coins and Candidate Unlock

**Covers** §6.6, §7.3, §8.2, §11.1 · **BR-15 – BR-18, BR-21, BR-24** ·
**UAT-16 – UAT-19**

Delivered **before M8**, because §9.1 puts employer-initiated chat behind the
same entitlement. Nothing in this milestone needs a payment provider: the ten
free Coins are enough to build and accept the whole unlock flow, which is why it
is separated from M13 rather than waiting on credentials.

- Wallet screen: balance, approximate UZS value, and the ledger as an
  **append-only list** (BR-24). Reversals and administrator adjustments appear
  as their own entries — the history is never rewritten, and the UI must not
  render a "corrected" balance that hides one.
- **Prices and the bonus come from the server** (§6.6). `1 Coin = UZS 10,000`
  and `unlock = 2 Coins` are business configuration; a constant in Dart would
  make a price change a store release, and would disagree with the ledger the
  moment it moved.
- Candidate Unlock: confirmation sheet showing cost, current balance and
  remaining balance before anything is charged (§6.6).
- **The unlock is one server call, and the client must not simulate it.** Debit
  and entitlement are atomic server-side (BR-18); a client that debited
  optimistically and then failed would show Coins gone with no access. Treat the
  response as the only truth about the new balance.
- **Persisted idempotency key on the unlock**, the same discipline as apply
  (§12.4): a retry after a timeout must not be able to charge twice, and one
  employer-candidate pair is charged once (BR-16, UAT-18).
- Locked state on the candidate profile: structured data free, contact/CV
  locked, with the price and balance visible before the decision (UAT-17).
- Fewer than 2 Coins routes to top-up rather than failing (UAT-19). Until M13
  ships, that route ends in an honest "top-up is not available yet" rather than
  a dead button.
- Rewrite the contact-exposure copy against the new reason codes, and re-point
  the tests that pin it.

**Done when:** UAT-16 – UAT-19 pass — the wallet exists with exactly ten Coins
after first employer registration, an unlock debits two and opens contact,
revisiting the same candidate charges nothing, and an empty wallet blocks the
action and offers top-up.

**Not this milestone:** BR-17 and the server-side enforcement it names are the
backend's. The client's obligation is the negative one — never render a field
the server did not send, and never cache one across an entitlement change.

## M13 - Coin top-up: Payme and CLICK

**Covers** §6.7, §12.6, §12.7 · **BR-19, BR-20, BR-22, BR-23** ·
**UAT-20 – UAT-23**

**Blocked on the client for two things**, both outside this repo: merchant
credentials for the providers' test environments (§12.6), and the storefront
billing decision of §12.7/BR-23.

- Coin quantity chooser; **the server calculates the amount** and returns the
  Payment Order. A total computed in Dart is never the source of truth (§12.3.1)
  — display the server's figure or display nothing.
- Provider choice and checkout through an approved link, deep link or SDK flow.
- **No card data in the app, ever** (BR-22). No PAN, no CVV, no provider
  credentials — which also means no "helpful" card field cached for next time.
- **A success redirect credits nothing** (§6.7). Returning from the provider
  puts the order into a pending state and the app polls or waits for the
  backend's verified result; Coins appear only when the server says PAID.
- Payment Order states rendered honestly, including the ones nobody wants:
  CREATED, PENDING, PAID, FAILED, CANCELLED, REVERSED/REFUNDED. Failure and
  cancellation return to Wallet with a reason and a retry (§12.6).
- Order history with the internal order ID, so a support conversation can start
  from something the user can read out.

**Done when:** UAT-20 – UAT-23 pass in the providers' test environments —
including UAT-22, the duplicated callback, which is the one that has to be
*proved* rather than argued.

**Store compliance (BR-23) is a release-gate, not a feature.** §12.7 says the
wallet ledger and unlock rules stay identical whichever channel is verified, so
the app must keep the checkout surface swappable: if the storefront requires
IAP, that replaces the Payme/CLICK sheet and nothing else. Verify the rules
immediately before release, not now — they change.

## M8 - Chat and interviews

**Covers** §9.1, §8.3 · **UAT-09** · **depends on M12**

The 2026-08-10 revision moved the gate: §9.1 now reads that employer-initiated
chat is enabled "only after that employer has a Candidate Unlock entitlement for
the candidate", and that an application lets the employer review structured data
while chat, contact and interview actions stay locked. So the entry points into
this milestone are entitlement-driven, and **the candidate's side is not** — a
candidate who applied can still be written to, and must not be shown a paywall
that is not theirs.

- Conversation list and thread; text plus approved attachments.
- Sent / delivered / read indicators where the backend supplies them.
- Report and block; read-only history for closed interactions.
- Interview scheduling display by type (phone / in-person / external link),
  instructions, and confirm / request-another-time.
- **Deep links, including the role switch before navigating** (ARCHITECTURE.md
  §3). Moved here from M9: routing infrastructure that chat and share-a-vacancy
  both need, and it must not sit behind the deferred notifications milestone.
  Notification taps reuse it later rather than introducing it.

## M9 - Notifications

**Covers** §9.2 · **deferred to last on client direction (2026-08-04)**

Ordering changed from "after M6" to the last feature milestone. No Firebase
dependency is added to `pubspec.yaml` until this milestone opens, which keeps the
load-bearing version pins untouched for the whole build.

- In-app list, unread badge, mark read. *(No push dependency - this is an
  API-backed list screen and can be pulled forward at any time at no cost if the
  client wants notification history earlier.)*
- Push registration and handling.
- Preferences with security/account categories not disableable.

**Deep links moved out of this milestone** - see M8. They are routing
infrastructure, not a notification feature, and holding them to last would strand
share-a-vacancy and chat entry points behind a deferred milestone.

## M10 - Admin module

**Covers** §10 · **UAT-11, UAT-14**

- Admin shell behind the admin role.
- Dashboard counters (§10.1).
- Employer verification and vacancy moderation with mandatory reason entry.
- Complaint review queues.
- User search and warn/restrict/block/unblock with reason (UAT-14).
- Dictionary management with all four localized labels and skill merging (§10.3) -
  mobile-optimized, since there is no web panel.

Added by the 2026-08-10 revision — **§10.5 wallet and payment administration**,
and it is a real screen rather than a read-only list:

- Employer wallet balance and its immutable transaction history.
- Payment Order search by employer, provider, status, date, internal order ID
  and provider transaction ID — six axes, because the one support has is
  whichever the user can read out.
- Payment detail: Coin quantity, UZS amount, provider, status history,
  timestamps, failure or reversal reason.
- **Manual wallet adjustment with a mandatory reason**, audited (BR-24). It
  writes a new ledger entry; nothing in this screen may edit an existing one.
- Registration bonus, Coin price and unlock price as server configuration —
  editable here, and **the change affects future transactions only**. The screen
  has to say so, because the natural reading of "change the price" is that
  history follows.

## M11 - Hardening and acceptance

**Covers** §12.1, §12.4, §13

- Adaptive layout pass: small phones, large font scale, safe areas.
- Cached primary screens open without blocking; loading states everywhere network
  data is fetched (§12.4).
- Offline behaviour: explicit state, safe retry, no duplicate writes.
- Crash reporting and structured logging with no sensitive data.
- Release signing config for Android; iOS build path documented.
- Walk **all 24 UAT scenarios** — the 2026-08-10 revision added UAT-16 – UAT-24 —
  and keep the evidence (§13.2). UAT-20 – UAT-23 need the providers' test
  environments, so book that before the acceptance window rather than inside it.
- **Verify storefront billing rules immediately before release** (§12.7,
  BR-23). Named here as well as in M13 because it is a release gate that expires:
  rules checked two months out are not evidence.
- Delivery package now also owes **payment-integration documentation** —
  callback endpoints, test and production configuration, reconciliation
  behaviour, secure credential setup (§13.2).

---

## Cross-cutting work not owned by one milestone

| Work | When |
|---|---|
| ARB keys for every new string, in all four variants | with each screen |
| Dictionary-ID discipline (never bind a label) | with each picker |
| Idempotency key on each new non-idempotent write | with the call |
| Invalidation list next to each mutation | with the mutation |
| Large-font-scale check on new dense cards | with the card |
| **Money is the server's** — never compute a price, total or balance in Dart (§6.6, §12.3.1) | with anything that shows a figure |
| **No payment credentials or card data in the app** (BR-22) | with the top-up flow, and at every review after |
| UAT evidence | from M1 onward |

## Design decisions the revision opens, not yet made

Recorded here rather than invented, so ARCHITECTURE.md keeps only decisions that
were actually taken:

- **Where the locked state lives.** Every protected field is server-withheld
  (BR-17), so the client never has data to hide — but it does need to tell
  "locked, unlockable" from "allowed, empty" from "refused", and today's
  `exposureReason` carries three of those and not the fourth. The shape of that
  contract is the backend's call and this app follows it.
- **Whether the wallet is a shell tab or lives under Company.** §6.2 puts a
  Wallet tile on the dashboard, which does not settle where the full screen
  hangs. The employer shell already has five tabs; a sixth is not free.
- **What the app does between "provider says paid" and "server says PAID".**
  §6.7 forbids crediting on a redirect, so there is a window with no answer in
  it. Poll, push, or make the user pull to refresh — all three are defensible
  and the choice belongs with the payment contract, not ahead of it.
