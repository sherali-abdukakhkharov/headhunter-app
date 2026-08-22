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

## Open — not an ask yet, but a live constraint

**`docs/openapi.json` is the only contract document there is.** `/docs-json` has
answered 404 since 2026-08-20, so the checked-in file is it. Both `@ApiOkResponse`
decorators added on 2026-08-22 put `VacancyReviewDto` and `ComplaintDetailDto` in
that file for the first time — they had no schema entry at all before.

**Six admin GETs still have no documented response**, so their shapes are absent
from that file:

| route | needed by |
|---|---|
| `GET /admin/users` | §10.4, next slice |
| `GET /admin/users/:userId` | §10.4, next slice |
| `GET /admin/audit` | §10.4, next slice |
| `GET /admin/verification` | already consumed; item DTO is documented, only the `{items}` wrapper is not |
| `GET /admin/moderation` | same |
| `GET /admin/complaints` | same |

The first three are asked for; the last three are low value, since
`VerificationQueueItemDto`, `ModerationQueueItemDto` and `ComplaintDto` all carry
`@ApiProperty` and only the wrapper is undocumented.

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

- **The client mirrors `TRANSITIONS` from `vacancy-status.ts`** and offers only
  the transitions it allows, so a 409 `vacancy.transition_not_allowed` now means
  the vacancy moved under the screen. The backend has undertaken to say before
  that table moves; if it moves silently the client starts hiding a valid action,
  which is the safe direction but still wrong. See
  `VacancyAdminStatus.availableFor`.
