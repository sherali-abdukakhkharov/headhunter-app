# Design feedback — Universal HeadHunter, round 1

**To:** design
**From:** mobile engineering
**Re:** `Universal HeadHunter.dc.html`, implemented 2026-08-04

---

## ROUND 3 — all eight answers implemented

Thank you for the standalone copy; it read through cleanly. Everything in §§1–8
is implemented and verified on device. `flutter analyze` clean, 31 tests green.

- **Twenty states** as named constructors, with tests asserting *both* halves of
  the glyph rule — no glyph repeating inside an object type, and shared glyphs
  meaning the same thing across types. The rule is what makes it testable at all;
  a plain list of twenty rows would not have been.
- **Category band** now always renders, with the tint-plus-glyph-plus-name
  fallback. A test asserts the card is the same height with and without a
  photograph, which is the property you actually cared about.
- **Control height, turquoise rail, two-line nav, 2.0× clamp, derived
  skeletons** — all in. The conditional-field rail was the most useful single
  answer: turquoise had genuinely no job before it.

### Two notes from running your QA case

We ran **"Ariza topshirish" at 2.0× on 320pt**, and it found two things:

1. **A real bug in our own code**, not yours: a header row without a flex and a
   fixed-width label column that split "Database" into "Databa / se". Fixed. Your
   QA case earned its keep on the first run.
2. **One thing we cannot fix in layout.** At 320pt × 2.0× with five tabs, each tab
   is ~64pt wide, and two lines still cannot hold `Bosh sahifa` — it renders as
   `Bosh / sahif`. Your §6 rule says shorten the string or soft-hyphenate, never
   the box, and we have obeyed that: the box is correct and nothing overflows.
   **So this is a copy question, and you own the uz-Latn source.** Options: a
   shorter label (`Asosiy`?), a soft hyphen, or an explicit decision that 2.0× on
   the narrowest device is an accepted edge. We have not guessed.

### One place your two sections disagreed, and how we read it

§3 says "only labels scale, and the bar grows with them." §6 says the label box is
a hard 25pt and "no string can ever grow the bar." Both are satisfiable and we
implemented both: the clamp applies **at the default scale** (bar exactly 70pt, a
long string clipped to two lines) and **relaxes above it** (the two lines lay out
at their true height, so the bar grows with the font). If you meant the box to
stay hard-clamped at every scale, say so — it is a one-line change, but it does
cut descenders at 2.0×, which is why we read it the other way.

Nothing is blocked on you. Next from your side, per your own list: the string
table, the client logo, and the undrawn admin / messaging / candidate-search
surfaces.

---

## ROUND 2 — one thing blocks us, and it is our tooling, not your work

Thank you for §08. Two of your changes were fully readable and are **implemented
and verified on device**:

- **§08.2, control height.** Changed to `min 52 — the box grows with the label,
  it never clips it`. Applied: every control is now a `minHeight`, labels wrap
  instead of truncating, and there is a test asserting a control gets *taller* at
  2× system font scale rather than clipping. Verified at 1.6× on an emulator with
  zero overflow. This was the right call.
- **Offer → warning tone with the document glyph.** Applied, with a test pinning
  it. The reasoning is airtight and we would not have got there ourselves: an
  offer is *waiting on the candidate*, so success ("resolved well") was actively
  misleading about whose deadline it is.

**However, we cannot read most of §08.** The API we pull the project through caps
a single file at 256 KiB, and `Universal HeadHunter.dc.html` is now ~266 KB — so
the response is truncated mid-tag, exactly where §08 begins. Concretely, we can
read the tone rule only as far as:

> Info · ko'k — In motion. Progressing normally, nobody needs to do anything.
> Warning · sariq — Waiting on a person. The word says who — you, or a reviewer.
> Success · yashil — Resolved well. Not reserved for verification — see the glyph rule.

and then it cuts off. We do **not** have: the Error and Neutral rules, the glyph
rule, the twenty-state table itself, or your answers to items 2 and 4–8.

**The fix is small:** please save §08 as its own file in the project — e.g.
`handoff-answers-r1.html`, or plain `.md`, whatever is easiest. Any separate file
is comfortably under the cap and we can read it in full. Pasting the twenty-state
table into chat works equally well.

We have deliberately **not guessed the remaining nineteen states.** Guessing is
the exact failure mode item 1 was raised about — if we invent the mapping, the
status vocabulary becomes ours rather than yours, and users learn an inconsistent
one. The six drawn badges plus `offer` are implemented; the rest are waiting on
that file.

---

The design is implemented and running on device. Foundations (§01), the component
library (§02) and all eleven required UI states (§06) are built in Flutter, and
the whole set renders in an in-app catalogue we can screen-share.

Three things that made this unusually smooth, worth keeping in the next handoff:

- **Drawing the states as component variants rather than describing them.** The
  eleven states in §06 went in essentially one-to-one. That never happens when
  states arrive as prose.
- **Golos Text with the reasoning attached.** Choosing one family for all four
  variants was correct and the Cyrillic renders cleanly — Ўў Ққ Ғғ Ҳҳ all land.
- **The "one control size for everyone" decision.** It genuinely halved the
  component library, exactly as §00 predicted.

Below is what we could not resolve from the document. Items 1–3 block or risk
rework; 4–8 we've made a defensible choice on and need a yes/no.

---

## Blocking

### 1. Status → tone + glyph mapping is incomplete

§02 draws six badges and defines five tones. The functional spec has roughly
fifteen states that all need to use that one component:

- **Vacancy** (§6.4): draft, under moderation, active, paused, closed, rejected
- **Application** (§8.1): submitted, viewed, shortlisted, interview, offer,
  hired, rejected, withdrawn, vacancy-closed
- **Employer verification** (§6.1): not submitted, under review, verified,
  rejected, changes required

Six of these are drawn. The rest we had to assign ourselves, which means
*we* are making a design decision that affects how users learn the vocabulary —
precisely what §00's third principle is trying to prevent.

**What we need:** a table of all fifteen states → tone + glyph. Specifically
unclear: **draft** (no badge drawn at all), **active** (success, or is green
reserved for verification?), **hired** vs **verified** (both success — same glyph?),
**withdrawn** vs **paused** vs **closed** (all three currently land on neutral,
which loses the distinction between "the candidate stopped" and "the employer
stopped").

### 2. Image assets

Eight `image-slot` placeholders are unfilled:

| Slot | Context |
|---|---|
| `cmp-cat-1`, `c14-cat-1`, `c14-cat-2`, `proto-detail-hero` | vacancy category imagery |
| `cmp-empty-1`, `st-empty-first`, `proto-empty-filter` | empty-state illustration |
| `proto-success-art` | success screen |

**Questions:** is there one image per work category (§2.1 defines five:
professional, service, physical, seasonal/agricultural, temporary/shift), or one
generic band? What aspect ratio — the card reserves 86px height at full card
width. And are these illustrations you're producing, or should we brief stock
photography?

Right now the vacancy card omits the band entirely when no image is supplied,
which looks intentional but isn't the drawn design.

### 3. 52px fixed control height vs system font scaling

These two requirements are in tension and we cannot satisfy both as drawn:

- §01 fixes standard control height at **52px**
- §12.1 requires supporting **system font scaling** (Android goes to 2.0×)

At ~1.6× and above, a 15px button label inside a hard 52px box clips. We have
kept 52px, so at large scales the label currently truncates.

**Options, and we'd like you to pick:** (a) the control grows vertically and 52px
becomes a *minimum*; (b) label caps at some scale factor and stops growing;
(c) label wraps to two lines and the control grows. We lean (a) — it preserves
legibility and the 52px rhythm at default scale — but it changes vertical rhythm
on dense screens, so it's your call.

---

## Please confirm

### 4. Light scheme only

No dark variant is specified, so we did not invent one — a user with system dark
mode on will see the app in light. Defensible for an institutional product, and we
prefer not to guess at a dark palette. **Confirm this is deliberate and final**, or
tell us it's coming.

### 5. What is turquoise actually for?

§01 documents accent-500 as surface/accent only, never text on white. In the drawn
screens it appears almost exclusively as the logo mark's background, plus
`#8FD3DB` for text on dark surfaces. The result is that the accent has essentially
no role in the component library we built.

**Is turquoise intended as a brand-mark colour only?** If it should appear in the
product UI, where — selected states, progress, empty-state art?

### 6. Bottom nav height varies by role

§02 says tab labels wrap to two lines rather than truncate, and notes
"Фойдаланувчилар" as the longest in the set. Consequence: the admin bar is taller
than the candidate bar, because only admin labels wrap. We implemented
wrap-as-needed. **Should the bar instead reserve two lines always**, so its height
is constant across roles?

### 7. Copy in all four variants

The drawn copy is Uzbek Latin. Every string needs Uzbek Cyrillic, Russian and
English before we can ship a screen — the spec (§3.2, BR-13) forbids ever showing
a technical key as a fallback.

**Who owns this copy?** If it's you, we'd also like the **longest-variant string
per component**: your own §02 note says Cyrillic runs ~30% longer, and that is the
set we need to test layouts against, not the Latin.

### 8. App icon and launch screen

Not in the design and required for store submission.

---

## Minor

- **Focus ring** (2px blue-600 at 2px offset) is specified for every interactive
  element. On touch this is only reachable via an external keyboard or switch
  access. Implemented, low priority — flagging so it isn't mistaken for missing.
- **Skeleton geometry** (§06 state 01) mirrors the vacancy card well. If the
  candidate and application cards get their own skeletons we'd rather match your
  geometry than guess; happy to derive them if you'd prefer.
