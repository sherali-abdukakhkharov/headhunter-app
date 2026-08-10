# Specification revisions

What changed between client documents, so nobody has to diff two .docx files to find
out whether a section they already built against still says what it said.

> **Kept identical in both repos**, like `SPEC.md` itself — the spec history is shared,
> and two drifting copies of it would be worse than none. Anything true only of the
> Flutter client goes in the "What this means for the app" section at the end, which is
> the one part that differs.

---

## 2026-08-10 — Wallet, Candidate Unlock, Payme and CLICK

Source: `Universal_HeadHunter_Mobile_Platform_TZ_EN_Wallet_Payme_Click.docx`,
superseding the Tashkent 2026 approval version.

The client described this as "some new features". Most of it is, but **four sections that
existing delivered code implements were edited**, and one of those edits reverses a rule.
Read that part first.

### The edit that matters: contact access is now *bought*, not earned

| | |
|---|---|
| **§11.1, before** | "Phone number and full contact details are not shown in general candidate search cards." |
| **§11.1, after** | "Phone number, e-mail, and CV file are not returned in general candidate search or preview APIs. They become available to that employer **only after a successful Candidate Unlock or another explicitly approved entitlement**." |

§9.1 removes the remaining ambiguity: *"A candidate application may allow the employer to
review structured application/profile data, but protected phone/e-mail, CV, direct chat,
and interview/contact actions **remain locked until Candidate Unlock is completed**."*

BR-09 itself is textually unchanged — "revealed according to candidate privacy settings and
an allowed hiring interaction" — but §9.1 and §11.1 now say a hiring interaction is **not**
one of the things that reveals contact details. A purchased entitlement is.

**What that means for code already delivered and tested:** M6, M7 and M8 implement BR-09
as *privacy settings + a live hiring interaction* (`HiringInteractionService`: a
non-withdrawn application, or an accepted invitation). Under this revision that is
necessary but no longer sufficient. Four delivered behaviours change:

| Delivered behaviour | Under this revision |
|---|---|
| An application reveals the candidate's phone and CV to that employer | Reveals structured data only; contact and CV need an unlock |
| An accepted invitation reveals contact details | Same |
| An employer may open a chat off an application | Chat needs an unlock (§9.1) |
| An employer may send an invitation to any searchable candidate | §8.2 requires an unlock to "initiate direct contact" |

The existing tests assert the old rule, including the regression test for a withdrawn
application revoking exposure. They are not wrong — they encode the previous contract —
so they have to be *changed* deliberately rather than deleted when the unlock lands.

*Note the escape hatch in §11.1:* "or another explicitly approved entitlement". If the
client wants an application to keep granting contact access — a candidate who applied has
volunteered it, which is a defensible reading — that is a one-line answer from them and it
would leave M6's behaviour intact. **Worth asking before building.** §9.1 as written says
no.

### Also edited

- **§7.3** — the candidate card now states explicitly that phone, e-mail and CV are locked
  until unlock. Consistent with what the card already returns; no code change.
- **§8.2** — an employer may review a search-visible candidate for free; direct contact,
  chat, interview and invitation require the entitlement.
- **Languages** — reworded throughout as "three languages (Uzbek, Russian, English), four
  interface variants, because Uzbek ships in both scripts". **No behaviour change**: the
  four locale codes are unchanged. UAT-24 restates UAT-13 in that framing.
- **§13.3** — acceptance now reads "the three languages are complete" rather than "the four
  interface variants".

### New sections

| Section | Content |
|---|---|
| §6.6 | Employer wallet, Coins, Candidate Unlock. 10-Coin registration bonus, 1 Coin = UZS 10 000, unlock = 2 Coins, all server-side configuration |
| §6.7 | Wallet top-up through Payme and CLICK, Payment Order lifecycle, idempotent crediting |
| §10.5 | Administrator wallet and payment views, plus audited manual adjustment |
| §12.3.1 | Wallet transaction guarantees — the uniqueness constraints and atomicity, stated as requirements |
| §12.6 | Payme Merchant API and CLICK Shop API integration requirements |
| §12.7 | Apple/Google billing-policy compliance, and the requirement that the ledger stay provider-agnostic |

### New business rules

BR-15 to BR-24. The ones that constrain the schema rather than the UI:

- **BR-15** — the 10-Coin bonus is granted **exactly once**, and not again after logout,
  reinstall, device change or role switch.
- **BR-16** — unlock is charged once per employer-candidate pair.
- **BR-18** — debit and entitlement creation are **atomic**.
- **BR-19/BR-20** — a Payment Order credits Coins exactly once regardless of duplicate
  callbacks; failed, cancelled or unverified payments never credit.
- **BR-24** — the wallet ledger is **append-only**; reversals and adjustments are separate
  audited entries.

BR-17 is worth noting because it is aimed at us: "Protected contact/CV data is enforced
server-side; hiding it only in the UI is not sufficient."

### New acceptance scenarios

UAT-16 to UAT-23 (wallet, unlock, insufficient balance, Payme, CLICK, duplicate callback,
failed payment). UAT-24 is a restatement of UAT-13. The suite goes from 15 scenarios to 24,
so `src/uat/uat.int.spec.ts` grows by eight `describe` blocks.

### What did not change

§1–§5, §6.1–§6.5, §7.1–§7.2, §7.4–§7.5, §8.1, §8.3, §9.2, §10.1–§10.4, §11 (other than
§11.1), §12.1–§12.5, §13.1's first fifteen rows and §13.2. Every rule this backend has
already implemented outside the four sections above still reads exactly as it did.

---

## What this means for the app

*This section is the app repo's; the backend copy has its own equivalent.*

**Nothing shipped is wrong on screen today.** The search card carried no contact
detail before the revision and carries none after, so BR-09's card rule and the test
pinning it are untouched. §7.3's new sentence — phone, e-mail and CV "are locked until
Candidate Unlock is purchased" — describes what the card already does.

**One shipped string is wrong, and is deliberately still there.**
`exposureExplanation` in `lib/src/features/applications/presentation/` turns the
server's `exposureReason` into a sentence, and for `no_interaction` it says contact
"opens once this candidate applies to one of your vacancies". Under §9.1 as written,
that is no longer true. It is left alone on purpose:

- it is exactly right for **today's server**, which has no unlocks and no new reason
  codes, so changing it now swaps one wrong sentence for another;
- the escape-hatch question above may restore it unchanged;
- the mutation tests that pin "no two denial reasons read the same" are written
  against the current six codes and move with them.

It changes in the same commit as the new codes, in M12.

**What the app has to build**, in `PLAN.md` order:

| Section | App work | Milestone |
|---|---|---|
| §6.6 | Wallet screen, append-only ledger, unlock sheet, locked profile state | M12 |
| §6.2 | Wallet tile on the employer dashboard | M5 (amended) |
| §6.7 | Coin chooser, provider checkout, Payment Order states, order history | M13 |
| §10.5 | Admin wallet/payment screens and audited adjustment | M10 |
| §8.2, §9.1 | Entitlement gating on invitations, chat and interview entry points | M12 → M8 |

**Two client-side rules the revision adds**, now in `CLAUDE.md` and TODO's standing
rules:

- **Money is the server's.** Coin price, unlock cost and the bonus are server
  configuration (§6.6); a constant in Dart makes a price change a store release and
  disagrees with the ledger the moment it moves. The client never computes a total, a
  balance or an amount payable (§12.3.1).
- **No card data or provider credentials in the app, ever** (BR-22) — including no
  convenience-cached card field.

**BR-17 is aimed at the backend, and the app's half of it is the negative one:** never
render a field the server did not send, and never keep one cached across an entitlement
change. The client has no copy of the rule to disagree with, and must not grow one.
