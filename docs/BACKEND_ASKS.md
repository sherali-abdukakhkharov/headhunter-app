# Backend asks

Contract gaps the client has hit, with the reasoning, so the backend session can
act on them without re-deriving why. Spec citations are `§n`, `BR-nn`, `UAT-nn`
against [SPEC.md](SPEC.md); the backend's own source of truth is
`headhunter-backend/docs/API_CONTRACTS.md`.

**Nothing here blocks the client.** Each item names how the client works today
and what changes when the ask lands. That is deliberate: an ask that stops work
gets guessed at, and a guess becomes a second thing to undo.

The pattern this file exists to repeat: `InvitationDto.candidateName` was asked
for the same way, parsed by the client before it existed, and shipped — so the
field appeared on screen with no client release and no coordinated deploy. Two
of the three asks below are shaped for exactly that.

---

## 1. `GET /admin/moderation/:vacancyId` has no employer

**Priority: this is the one worth doing.** §10.2 lists the employer's contact
information among what a moderator reviews, and the review cannot show it.

`VacancyReviewDto.vacancy` is the `vacancies` row. It carries
`employer_user_id`; nothing joins the employer, so there is no name, no phone
and no e-mail. A moderator who arrives from the queue knows whose vacancy it is
because the *queue row* carries `employerName`; one who opens the review from a
deep link, a notification, or a reload does not.

**Asked for:** three fields on the review response.

```
employerName   string | null   the public name, or the legal name for a company
employerPhone  string | null
employerEmail  string | null
```

Same resolution `ModerationQueueItemDto.employerName` already does, so the query
exists — it is being run for the list and not for the detail.

**BR-09 is not in the way.** §11.1 releases contact data to the `admin` role and
logs every read; the rule that gates phone and e-mail behind a paid Candidate
Unlock (§6.6) is about the **employer** role reading a *candidate*. `AdminUserDto`
already exposes `phone` to this role for the same reason.

**Client state:** `VacancyReview` parses all three today and the employer card
renders only when at least one arrives — so it is invisible now and appears the
day the join lands, with no release. Pinned by
`test/features/admin/vacancy_moderation_test.dart`, in the group *"the employer
card is written before the server sends it"*, including the absent case.

## 2. `ComplaintDetailDto.target.created_at` breaks the frozen timestamp format

**A contract violation rather than a missing feature**, and worth fixing even
though the client currently steps around it.

`API_CONTRACTS.md` §2 is frozen: *every* timestamp in *every* response carries an
explicit numeric offset, never `Z`, never offsetless — because Dart's
`DateTime.parse` discards the offset and `toLocal()` then re-renders in the
device zone. The admin controller honours this for the complaint itself:

```ts
complaint: { ...complaint, createdAt: formatWithOffset(complaint.createdAt, tz) }
```

The **target** beside it is spread in untouched, and two of the four resolved
shapes carry a `created_at`:

| kind | columns |
|---|---|
| `message` | `id`, `body`, `sender_user_id`, `conversation_id`, **`created_at`** |
| `user` / `profile` | `id`, `status`, **`created_at`**, `full_name` |

So those arrive as `timestamptz` serialised by the driver — with a `Z`. §2's own
implementation note says serialisation goes through one deliberate formatter with
a test; this path bypasses it.

**Asked for:** either run the target's timestamps through `formatWithOffset`, or
drop them from the selection. Dropping them is fine — see the client note.

**Client state:** `ComplaintTargetDetail` deliberately exposes **no timestamp**.
`ZonedTimestamp.parse` refuses a `Z` by design, so a `createdAt` getter would
throw a `FormatException` at the repository boundary and take the whole review
with it. Nothing is lost: a moderator judging a complaint needs when it was
*reported*, which the complaint carries correctly. Pinned by
`test/features/admin/complaint_review_test.dart` — *"a target carrying a Z
timestamp does not throw"*, which also asserts the string really is one the
contract refuses.

## 3. Two admin responses are raw rows rather than DTOs

**Cosmetic now.** Both are neutralised client-side and neither is worth a
release on its own; do them when either endpoint is next touched.

- `VacancyReviewDto.vacancy` — `Record<string, unknown>`, the selected columns
  unchanged, so **snake_case** while `requirements` beside it is camelCase and
  every other vacancy route answers with a camelCase DTO.
- `ComplaintDetailDto.target` — `Record<string, unknown> | null`, the same
  shape, per kind.

**Client state:** `VacancyReview` and `ComplaintTargetDetail` each read **either
spelling** for every field, so one build is correct before and after a typed DTO
lands. Both have a test that parses the two shapes and asserts they agree.

Worth knowing that the first is narrower than it looks: `VacancyDto.fields` is
keyed by **schema field code** and the codes *are* the column names — the
employer dashboard already reads `fields['worker_count']`. What is genuinely
storage-shaped is the handful of columns that are not fields.

One real trap if this is picked up: `salary_from` is `numeric`, so it arrives as
a **string** (`"5000000.00"`). The client takes either; a DTO that types it
`number` without a cast would be lying.

---

## Considered and not asked for

- **A reporter name on `ComplaintDto`.** `reporterUserId` is a bare uuid and
  there is no route that turns it into a name. Left alone on purpose: a
  complaint is judged on what was reported and what the target actually says,
  and inviting a moderator to weigh *who* complained is the wrong question in
  the one place §10.2 asks for a fair reading. If repeat-reporter abuse becomes
  real the ask is a count, not a name.
- **Complaints filed *by* a given user.** Same reasoning, and nothing in §10
  asks for it.
