# Backend asks

Contract gaps the client has hit, with the reasoning and **what came of them**,
so nobody re-derives a settled question. Spec citations are `§n`, `BR-nn`,
`UAT-nn` against [SPEC.md](SPEC.md); the backend's own source of truth is
`headhunter-backend/docs/API_CONTRACTS.md`.

**Nothing here has ever blocked the client**, which is deliberate: an ask that
stops work gets guessed at, and a guess becomes a second thing to undo. Each item
names how the client worked *without* the change.

The pattern this file exists to repeat: write the **reasoning**, not a bug title.
Every item below went across as a brief explaining why it mattered and what the
client was doing meanwhile; the two that should have been fixed were fixed and
deployed the same day, and the third came back with an argument good enough to
close it. One of them also came back with two more instances of its own bug class
that this client could not have found.

---

## Settled

### 1. The moderator had no employer — **done 2026-08-22**

§10.2 lists the employer's contact information among what a moderator reviews,
and `VacancyReviewDto.vacancy` carried only `employer_user_id`. A moderator
arriving from the queue knew whose vacancy it was because the queue row carries
`employerName`; one arriving from a deep link, a notification or a reload did
not.

Shipped as three keys, flat beside the columns, snake_case:

| key | what it is |
|---|---|
| `employer_name` | a company's public name, else the individual's own |
| `employer_phone` | the **account** number — the login identity, and §10.4's search key |
| `employer_contact_phone` | the number the employer **published** for their company (§6.1) |

Flat rather than nested because the moderation queue already identifies an
employer that way, and one payload should not do it two ways depending on which
screen asked. `employer_name` comes from the **same expression** both queues use,
with a server-side test asserting the review's name equals the queue's for the
same vacancy — so tapping a queue row cannot land on a review naming somebody
else.

**Two things came back different from the guess, and both cost a client release:**

- **There is no e-mail, anywhere.** Not deferred — answered. This product has no
  e-mail column: login is phone + OTP (§4.1) and every contact field in it is a
  phone number. An `employerEmail` getter was written on 2026-08-21 and removed
  on 2026-08-22. Do not add it back; there is a test asserting an
  `employer_email` key in the row is ignored.
- **There is a third field, and it is the better one to show.** `employer_phone`
  is the login identity; `employer_contact_phone` is what the employer published
  for business contact, and §6.1 makes it mandatory for a complete profile, so
  BR-03 guarantees any vacancy that reached review has one. Sent as two fields
  rather than one `COALESCE` precisely so a moderator about to dial knows which
  they have. The card leads with the published one and labels both; when they are
  equal — a sole trader who published the number they signed up with — only one
  is drawn.

**What the idiom bought:** `employer_name` and `employer_phone` were already
parsed when the join landed, so the card lit up **on the next fetch with no
release**. The release that followed added the third field and dropped the dead
one. That is the honest accounting: the bet paid, and it paid partially.

### 2. `ComplaintDetailDto.target.created_at` broke the frozen timestamp format — **done 2026-08-22**

`API_CONTRACTS.md` §2 is frozen: every timestamp carries an explicit numeric
offset, never `Z`, never offsetless, because Dart's `DateTime.parse` discards the
offset and `toLocal()` re-renders in the device zone. The controller honoured it
for the complaint and spread the `target` in untouched, so **one field in that
response carried `+05:00` and another carried `Z`**.

Fixed by formatting rather than dropping — and formatting was the right call,
because dropping would have closed the report and left the class open. The sweep
found two more members:

- `VacancyReviewDto.vacancy` had **four** unformatted timestamps (`published_at`,
  `closed_at`, `created_at`, `updated_at`) — in the same response item 1 was
  about. Invisible only because `VacancyReview` happens to expose no timestamp
  off that row; a `publishedAt` getter would have thrown. It is safe to add one
  now.
- The audit log's `details` bag stored `restrictedUntil` via `toISOString()`. A
  `jsonb` bag admits no read-side fix, so it is formatted where it is *written*.
  **Consequence for §10.4's audit screen: `details` is an opaque key/value bag —
  render it as text, do not parse values.**

The mechanism is `formatRowTimestamps`, converting by runtime type. That is only
safe because a calendar date is a `'YYYY-MM-DD'` string end to end
(`--date-parser string`), so a `Date` is always an instant and never a
`starts_on`; a test asserts it, so a change to the date parser fails loudly
rather than rendering a deadline as a timestamp.

`ComplaintTargetDetail` still exposes no timestamp, now on the merits rather than
for safety: a moderator judging a complaint needs when it was *reported*, which
the complaint carries.

### 3. Two admin responses are raw rows rather than DTOs — **declined 2026-08-22, and rightly**

Asked for `VacancyReviewDto.vacancy` and `ComplaintDetailDto.target` to become
camelCase DTOs. Declined, with an argument worth recording:

> `VacancyReviewDto.vacancy` being the row as stored **is the point** of a review
> screen — §10.2 reviews what was submitted. A camelCase DTO means either
> hand-writing a thirty-column mapping (a second copy of a column list, which the
> one-declaration rule exists to prevent) or a generic snake→camel converter with
> exactly one caller.

Accepted. The client's either-spelling readers mean nothing is waiting on it, and
both have a test that parses the two shapes and asserts they agree. `salary_from`
is `numeric` and arrives as a **string** (`"5000000.00"`) — the reader takes
either, and a DTO typing it `number` without a cast would be lying.

---

### 4. Six admin GETs had no response schema — **done 2026-08-22**

**`docs/openapi.json` is the only contract document there is**: `/docs-json` has
answered 404 since 2026-08-20, so the checked-in file is it. Item 1 and 2's
`@ApiOkResponse` decorators put `VacancyReviewDto` and `ComplaintDetailDto` in it
for the first time, which surfaced that six admin GETs had **no `responses.200`
content at all** — not a partial description, nothing.

Three were asked for (`GET /admin/users`, `/admin/users/:userId`, `/admin/audit`
— §10.4's slice) and three were deprioritised on the grounds that their item DTOs
(`VerificationQueueItemDto`, `ModerationQueueItemDto`, `ComplaintDto`) already
carry `@ApiProperty` so only the `{items}` wrapper was missing.

**All six were done, and the deprioritisation was wrong** for a reason worth
keeping: a missing wrapper means the *route* has no schema in the document, so
`GET /admin/verification` was simply absent from it. "Partially described" was the
wrong model. Three one-line decorators over DTOs that already existed was not
worth deferring to a "next touched" that might never come.

**The consequence is a rule, not a fix.** Every route in the API now declares a
response or is deliberately excluded — the only exclusions being the two payment
callbacks, whose audience is Payme and CLICK. So from here **a route missing from
`docs/openapi.json` is a bug**: report it rather than working around it.

Seven schemas appear in the document for the first time: the three above plus
`AdminUserDto`, `StatusHistoryEntryDto`, `UserComplaintDto` and `AuditEntryDto`
pulled in behind them.

---

### 5. `registeredFrom` was inclusive of the wrong day — **found and fixed 2026-08-22**

Not an ask — a bug found *because* of one. The question was an aside on item 4
("if the filter semantics have anything non-obvious, a line in the descriptions
would pre-empt what I'd otherwise ask mid-build"), explicitly not a request.

Six comparisons across four modules cast a `'YYYY-MM-DD'` to `::date` and
compared it to a `timestamptz`. Postgres resolves that cast in the **session**
zone — UTC on this deployment — so `created_at >= '2026-08-01'::date` meant 05:00
Tashkent. Anyone registering between midnight and 05:00 was filed under the
previous day: absent from a period starting that day, present in one ending the
day before.

It reached **`GET /admin/dashboard`'s four period counts** — the ones this client
renders as fact on §10.1 — plus `GET /admin/users`' `registeredFrom`/`To`,
`POST /candidates/search`' `updatedSince`, and `GET /vacancies/feed`'
`publishedFrom`. Fixed at all six against a real instant in the platform zone,
with integration tests pinned at 02:00 Tashkent that also check the previous day
does *not* reach into the range.

**No client change was needed**, and that is the payoff of `DashboardPeriod`
keeping to dates: hand-split, UTC-flagged, whole-day arithmetic, never an instant
and never the device's idea of today. But the arithmetic being right did not stop
the *figures* being wrong — see MEMORY.md, because that distinction is the lesson
rather than the fix.

**The transferable rule: when a client sends a date and the server stores an
instant, ask which instant the date resolves to.** Single-zone products are
exactly where nobody notices that question is unanswered.

---

## Open

### 1. The audit log has no name on it — raised 2026-08-23

`AuditEntryDto` carries `actorUserId` and `targetId` and no names, and §10.4's
first question of the log is *"what has this administrator done"*. A screen full
of uuids cannot answer it: an administrator reading twenty rows sees twenty
36-character strings and has to open each one to learn who acted.

**Why the client is not resolving them itself.** The only route from an id to a
name is `GET /admin/users/:id`, which returns a phone number, a BR-08 status
history and a complaint list to obtain a string — and logs a §11.1 access every
time. A page of twenty rows would buy a page of names with a page of logged
reads of other people's contact details, on a screen nobody opened to read
contact details.

**The ask is one field**: `actorName`, resolved by the same `DISPLAY_NAME`
expression `GET /admin/users` already uses, in the query that already reads the
row. Not a target name — a target can be a vacancy, a complaint or a dictionary
item, and four joins to label a trail is a different and much larger ask that
nothing has needed yet.

**What the client does meanwhile, and it is not a workaround to undo.** The
actor id is shown as it is and made a *way in*: tapping the row opens that
administrator's account, where one deliberate tap costs one deliberate read.
That navigation is worth keeping whatever happens to the field — a name is not
an account. If `actorName` arrives, the row shows it above the id and **nothing
else changes**, the same way the employer name lit up on the vacancy review
with no client release.

**Not asked for: a target name.** See above; and for a `user` target the row
already opens the account, which answers the question better than a label
would.

## Facts §10.4 needs, from settling the above

- **`AdminUserDetailDto` carries no audit entries.** It is `AdminUserDto` +
  `statusHistory` (`StatusHistoryEntryDto`) + `complaints` (`UserComplaintDto`).
  This client assumed otherwise and was corrected before building on it: audit
  rows reach a client only through `GET /admin/audit` → `AuditLogDto`, so showing
  them on a user screen is **a different endpoint and a separate fetch**.
- **It is emitted flat.** `AdminUserDetailDto` inherits from `AdminUserDto` in
  TypeScript and the generator merged the properties into one schema rather than
  an `allOf`, so expect ten on the object: `userId`, `phone`, `name`, `roles`,
  `status`, `restrictedUntil`, `createdAt`, `lastLoginAt`, `statusHistory`,
  `complaints`.
- **`AuditEntryDto.details` is an opaque key/value bag.** Its keys differ per
  `action`, are enumerated nowhere, and a client that guesses at them is wrong
  for the next action added. Render as text; do not parse values. Any timestamp
  inside carries §2's offset, formatted at the write site.
- **The filters are substrings, and `role` means "holds".** `phone` matches a
  substring (min 3 characters — a number is remembered by its last digits), not a
  prefix; `name` is a case-insensitive substring (min 2) over **five** columns,
  and the response's `name` resolves by the same order of preference so a list
  and a detail cannot disagree; `role` matches a user who *holds* that role, not
  one whose only role it is (§2.3), so the label must not read as "is a";
  `status` is exact.
- **Paging bites before the filters do.** Results are ordered newest-registration
  first, then `limit`/`offset`, so an old account matching a broad filter sits
  **past the page rather than outside the filter** — indistinguishable from the
  client. The empty state must not say "no such user" when it means "not on this
  page".

## Known noise on the backend side, so it is not mistaken for a contract problem

Roughly twenty integration specs there mint a fixture phone from `Math.random()`
and it has collided twice in one session (`users_phone_key`). A backend test
failure that vanishes on re-run is usually that flaky *fixture*, not a flaky
behaviour — worth knowing before treating such a report as evidence about the
API. Tracked on their side.

---

## Considered and deliberately not asked for

- **A reporter name on `ComplaintDto`.** `reporterUserId` is a bare uuid with no
  route to a name, and it is off the screen on purpose: a complaint is judged on
  what was reported and what the target says, and inviting a moderator to weigh
  *who* complained is the wrong question in the one place §10.2 asks for a fair
  reading. If repeat-reporter abuse becomes real, the ask is a count, not a name.
- **Complaints filed *by* a given user.** Same reasoning, and nothing in §10 asks
  for it.

## Client-side commitments made in return

- **The client mirrors the administrative transition table** from
  `vacancy-status.ts` and offers only the transitions it allows, so a 409
  `vacancy.transition_not_allowed` now means the vacancy moved under the screen.
  Written out and confirmed on 2026-08-22: pause from `active` only, close from
  `active` or `paused`, neither from `closed`, `draft`, `under_moderation` or
  `rejected`. The backend has undertaken to say before that table moves; if it
  moves silently the client starts hiding a valid action, which is the safe
  direction but still wrong. See `VacancyAdminStatus.availableFor`.

  **The boundary is narrower than "that file"**, which is the useful part: the
  employer's own transitions and moderation's `active | rejected` decision are
  separate tables in the same file, so a change to either does not reach this
  mirror and must not be copied into it. `closed` being terminal is enforced by
  the table alone, so a reopen path would be a schema question rather than a
  table edit — it would not arrive quietly.
