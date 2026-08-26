# Backend asks

Contract gaps the client has hit, with the reasoning and **what came of them**,
so nobody re-derives a settled question. Spec citations are `§n`, `BR-nn`,
`UAT-nn` against [SPEC.md](SPEC.md); the backend's own source of truth is
`headhunter-backend/docs/API_CONTRACTS.md`.

**Nothing here has ever blocked the client**, which is deliberate: an ask that
stops work gets guessed at, and a guess becomes a second thing to undo. Each item
names how the client worked *without* the change.

**Owner direction, 2026-08-26: this file is for questions that need a decision,
not for gaps that need typing.** The backend repo is editable from a session
rooted in the client (`permissions.additionalDirectories`), so a missing field
or a missing endpoint is work rather than an ask — write it, test it, and change
both sides of the contract in one go. What still belongs here is anything the
client may not decide alone: a policy, a price, a rule, or a change whose
consequences reach past the API surface.

The first item settled that way is **§4.2's attempt feedback**, which sat under
"open" as *"needs the count in the response"* for weeks. Implementing it turned
out to expose a security question worth more than the feature — see below.

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

### ~~1. The audit log has no name on it~~ — **done 2026-08-26**

`actorName` **and** `targetName` are on `AuditEntryDto`, resolved server-side by
the same `DISPLAY_NAME` expression `GET /admin/users` uses — which moved to its
own module so there is one copy of it rather than three
(`headhunter-backend@19e8876`). Client half in 1.16.0.

Two things about the answer differ from the ask, and both are worth keeping:

**A target name came too**, for a `user` target. This ask explicitly did not want
one, on the grounds that four joins to label a trail is a much larger job. That
was wrong about the cost: the same expression answers both ids, and a target that
is not an account resolves to null with no joins to arrange. §10.4's *second*
question — "what was done to this user" — had the same defect as the first, and
half an answer would have been an odd place to stop.

**The name replaces the id rather than sitting above it.** The ask said "shows it
above the id and nothing else changes". On a phone that is 36 characters nobody
can use under every row, and the way into the account is the tap, which is
unchanged. So the id is the *fallback*, shown when the name is null — which is a
real case, since a seeded administrator has no profile to take a name from.

**The reasoning that made this an ask rather than client work still holds**, and
is the reusable part: the only client route from an id to a name was
`GET /admin/users/:id`, which returns a phone number, a BR-08 status history and
a complaint list to obtain a string, and logs a §11.1 access every time. Twenty
rows would have bought a page of names with a page of logged reads of other
people's contact details, on a screen nobody opened to read contact details.
When resolving something client-side costs a privacy log line per row, it belongs
in the query that already reads the row.

### 2. §10.3 cannot edit a label it cannot read — raised 2026-08-24

§10.3 is "dictionary management with four localized labels", and there is no
route that returns them. The only read is `GET /dictionaries/:type`, which
resolves **one** label through §3.2's fallback chain — so an item with no
Russian label comes back carrying its Uzbek one, and the client has no way to
tell that apart from a Russian label that happens to read the same.

That makes the obvious client-side implementation actively wrong rather than
merely inconvenient: read four times with a different `x-lang`, show the four
strings, save what the administrator did not change, and a fallback becomes a
translation nobody wrote — in the table that decides what every picker in the
product says.

**The ask is an admin read of the raw labels**, unresolved: for one item, or
for a type, `{ 'uz-Latn': …, 'uz-Cyrl': …, ru: …, en: … }` with a key absent
where no label exists. The service already knows this — `resolveRows` selects
`label_locale` alongside the label precisely so `warnOnFallback` can log it —
so the fact is in hand and is being dropped on the way out.

A smaller version that would also work: add `labelLocale` to
`DictionaryItemDto`. It costs the client four requests per item and some
arithmetic, but it makes a fallback *visible*, which is the property that
matters. The raw map is better; either unblocks the screen.

**What the client does meanwhile.** Everything else in §10.3 shipped in 1.9.0:
the list of types from the manifest, a type's items with retired and merged
ones shown, activate and deactivate with §3.2's 422 rendered as "it has no name
in all four languages yet", the duplicate merge with its three refusals, and
**creating** an item with all four labels — which needs no read, because
nothing is being read. Label editing is the one action the screen does not
offer, and it says so rather than offering a field that would quietly write a
fallback.

### 3. §10.5's Payment Order search has no administrator route — raised 2026-08-25

§10.5 asks an administrator to *"search Payment Orders by employer, provider,
status, date, internal order ID, and provider transaction ID"* and to open a
detail with *"Coin quantity, UZS amount, provider, status history, timestamps,
and failure/reversal reason"*.

The payment module exists — `GET /payments/orders` and
`GET /payments/orders/:orderId` are built, and `PaymentOrderDto` already carries
almost every field the detail wants. **But both are scoped to the caller**, and
deliberately: the route's own description says *"an order id is an identifier,
not an authorization"*. An administrator asking about somebody else's order gets
nothing, which is the correct behaviour for that route and leaves §10.5 with no
route at all.

**The ask is an admin-scoped list**, `GET /admin/payments`, taking the six
filters §10.5 names and answering with the same `PaymentOrderDto` plus the
employer — the shape `GET /admin/wallets` already establishes for this section.
A detail route is probably unnecessary: if the list carries the DTO, the only
thing missing is the status *history*, and whether that is a separate table or a
column on the order is the backend's call.

Worth pairing with the note that **top-up is not live on the client either**
(M13, blocked on merchant credentials), so nothing an administrator would search
for exists yet. That is why this is an ask rather than a blocker.

**What the client does meanwhile.** The wallet half of §10.5 shipped in 1.12.0 —
balances, the immutable ledger, and BR-24's manual adjustment. The screen states
that payment search is not available and why, in all four variants, rather than
leaving a gap somebody reports as a missing feature.

### 4. The three money settings are not editable — raised 2026-08-25

§10.5's last line makes the registration bonus, the Coin price and the Candidate
Unlock price *"server configuration values"* an administrator may change, and
adds the rule that matters: **a change affects future transactions only and does
not rewrite historical ledger records.**

There is no route. The values reach the client through `GET /wallet`, which is
employer-scoped and read-only, so an administrator can neither see nor set them.

**The ask is small and the rule is the interesting part**: whatever the route
looks like, repricing must not touch `amount_uzs` on an existing ledger row.
BR-24 already forbids rewriting the ledger, so this is likely satisfied by
construction — worth confirming rather than assuming, because the natural
implementation of "change the price" is an `UPDATE` somewhere.

**What the client does meanwhile.** The §10.5 screen states that the three are
server configuration and that a change applies to future transactions only. The
rule is the half of this that is already true and worth saying; the editing is
the half that is waiting.

### 5. §4.2's attempt feedback — **done 2026-08-26, both sides, and not as asked**

The ask, as it had stood: *"the server locks a code out after `OTP_MAX_ATTEMPTS`
and says so, but the screen cannot count down remaining attempts — it needs the
count in the response."*

**Implementing it showed the ask was wrong.** Returning a remaining-attempt
count on a failed `verify` would have been a phone-number oracle. That route
answers `auth.otp_invalid` identically for "no code", "expired" and "wrong code"
— on purpose, so probing a number cannot reveal whether one is pending — and a
counter attached to that refusal undoes it exactly: a number with a live code
answers with a figure, a number without one does not.

What shipped instead: the **send** response carries `codeLength` and
`maxAttempts`, and the client counts its own attempts against the limit.

- The limit leaks nothing. It is policy, and an attacker learns it by guessing
  wrong five times.
- The count is accurate for the person actually typing, who is the only party a
  countdown is for. It can undercount — a second device, an app restart — which
  errs toward warning early.
- The server stays authoritative and answers `auth.otp_too_many_attempts`
  whatever the client believed. The screen does not disable anything on its own
  tally; it disables on the server's 429.

`codeLength` came along because it is the same defect one field over: the client
hard-coded six digits with a comment admitting it was an assumption, so changing
`OTP_LENGTH` would have given every installed app an input that refuses the code
it was sent, with nothing on screen to say why.

**Worth keeping as a pattern**: an ask phrased as "send me X" deserves one pass
asking *why the server does not already send X*. Here the answer was a
deliberate security property, and the useful change was a different field.

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
