# Changelog

Releases of the JobBridge Android app.

**The version in [pubspec.yaml](pubspec.yaml) is what a device reports**, because
`android/app/build.gradle.kts` derives `versionName` and `versionCode` from it. So
a release is not cut by tagging alone — the version has to be bumped in the same
commit, or the tag and the installed app disagree.

**The build number must always increase.** Android refuses to install an APK whose
`versionCode` is not higher than the installed one, so two releases sharing a
build number cannot upgrade each other on a device: the install fails, or the
tester keeps looking at the old app and reports bugs that were fixed. The
convention here is **one build number per release**, counted from the first.

Both rules are now enforced by `release-apk.yml`, which refuses to build when the
tag and this file disagree. They had been documented in three places and broken in
three releases out of four.

## 1.5.0+10 — 2026-08-23

§10.4 lands: an administrator can now find any account and act on it. It is also
the release where the dashboard stops having numbers that lead nowhere — every
counter that describes a queue or a sanction is now a way into the screen that
counts it.

### Added

- **User search (§10.4, UAT-14)** — the fourth tab in the administrator's app.
  Search by a phone number or by a name, and narrow by role, account status or
  when the account registered.
  **The last few digits are enough**, and that is the point of the field: a
  number is matched anywhere inside it, so a number you half-remember finds the
  account that a fully typed one, typed differently, will not. A number pasted
  out of a chat with its spaces in it works too — the spaces are taken out before
  the search is sent, because they would otherwise be part of what is matched.
  **The name is looked for everywhere a name can be**: a person's own name, a
  company's public name, its legal name, and the name a colleague was seeded
  with. You do not have to know what kind of account you are looking for.
  **Nothing is looked up until you ask.** The tab opens on an empty search
  rather than a list, because every search of somebody's contact details is
  recorded, and passing through a tab is not asking for one.
  **The list says how it is ordered when there is more of it.** Results are
  newest registration first, so an older account is further down rather than
  missing — which is the one thing about this screen that would otherwise have
  people concluding somebody does not exist.
- **The account screen, and the four things §10.4 allows.** Warn somebody,
  restrict them, block them, or lift either. All four require a reason, and the
  person reads it word for word.
  **Only what applies is offered.** An active account can be restricted or
  blocked; a blocked one can only be unblocked; a restricted one can be blocked
  or lifted. An account that has asked to be deleted offers none of the three,
  and says why — that request is answered by its own process and acting here
  would overwrite it.
  **A restriction can be given an end date**, and the screen says which end of
  the day it means: the restriction lifts at the start of the day you pick,
  Tashkent time. Leave it empty and it runs until somebody lifts it.
  Below the actions: every status this account has been through, with who
  changed it and why — the platform itself where a restriction simply expired —
  and every complaint filed about them, open and already reviewed alike.
- **The restricted and blocked counters on the dashboard now open the list they
  count**, filtered to that status. They had shown a number and led nowhere
  since the dashboard shipped.

### Fixed

- **Long metadata chips could paint over the edge of their card.** A chip's
  label does not shrink, so "Registered 2026-03-14" fitted in English and would
  have overflowed in Russian on a 360pt phone. Dated facts are captions now.
  The component itself is unchanged and the fix is queued with the small-screen
  pass.

## 1.4.1+9 — 2026-08-22

The vacancy review now shows the employer. 1.4.0 was written for this and the
server started sending it the same day, so **the name and a phone number already
appear in 1.4.0** — this release adds the second number and takes out a field
that turned out not to exist.

### Added

- **Two phone numbers on the employer card, told apart.** The number the
  employer **published for their company** comes first — that is what they chose
  to be reached on, and calling somebody's sign-in number about a job posting is
  the wrong number to have picked. The sign-in number is below it, labelled, and
  is the one you can paste into the user search when it arrives. When they are
  the same number, it is shown once.

### Removed

- **The e-mail row.** There is no e-mail address anywhere in this product —
  signing in is a phone number and a code, and every contact detail in it is a
  phone number. The row could never have appeared; it is gone rather than left
  waiting for something that is not coming.

## 1.4.0+8 — 2026-08-22

§10.2 is finished. Complaints have a queue, and a published vacancy can finally
be taken down — there was no way to reach one before this.

### Added

- **Complaints (§10.2)** — the third tab in the administrator's app, and one
  list for everything that gets reported: vacancies, people, profiles and
  messages together, oldest first. Every row says what kind of thing it is
  about, how long it has waited, and what the person who reported it actually
  wrote.
  Opening one shows the report in full and the thing it is about — a vacancy
  with its current state, a person with their name and account state, or the
  reported message itself, exactly as it was sent.
  **What you can do about it comes before recording what you decided**, because
  those are two separate things: marking a complaint upheld records a decision,
  it does not carry one out. So the actions sit above, and the outcome below,
  with a line saying as much.
  Both outcomes need you to write what was decided — including a dismissal.
  Nothing else keeps a record of a complaint review, so what you write is the
  whole account of it.
  If the reported thing has since been deleted, the screen says so and you can
  still record the outcome. A complaint is kept past the life of what it was
  about on purpose.

- **A live vacancy can be paused or removed (§10.2).** Reachable from a
  complaint about it. Pausing takes it off the feed and can be undone once the
  employer has fixed it; removing is permanent, and the confirmation says so and
  points at pausing instead. Both need a reason, and the employer reads it word
  for word. A vacancy that is already removed offers neither, rather than a
  button that would fail.

- **A person can be warned (§10.4).** From a complaint about them, or about a
  message they sent. It changes nothing about their account — the warning and
  its reason are recorded, and they are told. Restricting and blocking arrive
  with the user screen.

- **The last dashboard counter opens its queue.** All three now do.

### Changed

- **The vacancy review will show the employer's name and contact details the
  moment the server sends them**, with no app update needed. §10.2 asks for
  them and the server does not send them yet; the screen is written for them
  and simply leaves the card out until they arrive.

## 1.3.0+7 — 2026-08-21

The second gate. With 1.2.0 an administrator could verify an employer; now they
can also pass a vacancy — so between the two, a job can travel from an employer
signing up to a candidate applying without anybody touching the database.

### Added

- **Vacancy moderation (§10.2)** — the queue of vacancies waiting to be
  published, and the review screen where you decide. **No vacancy reaches a
  candidate until this happens** (BR-04), and for one with an age or gender limit
  this is the *only* way it can ever go live.
  The queue joins employer verification behind two segments in the Moderation
  tab, oldest first, and each row says how long it has been waiting and whether
  it carries a limit to judge. Tapping one opens the whole posting: what the job
  is, what it pays, where and when, the description exactly as the employer wrote
  it, and every structured requirement with required and preferred told apart.
  **A limit is shown first, above the title**, with the reason the employer chose
  and their own words underneath — because that is why the vacancy is on your
  screen instead of published already. The screen says what you are being asked
  to decide: a limit is allowed only where the reason requires it, so judge the
  reason.
  **Publishing puts it in front of candidates straight away**, and the
  confirmation says so — including that approving a limited vacancy approves the
  limit with it. Sending one back needs a reason, and the employer reads it word
  for word: they can edit and submit again, and your reason is the only guidance
  they get.
  If a colleague decided the same vacancy first, that is not an error — the
  screen says it has left the queue and takes you back to the next one.

- **The two counters on the dashboard now open the queue they name.** Employers
  awaiting verification opens the employer segment, vacancies awaiting moderation
  opens the vacancy one.

## 1.2.0+6 — 2026-08-21

The administrator role has screens for the first time, and the first of them
unblocks everything on the employer side.

### Added

- **Employer verification (§10.2)** — the queue an administrator works through to
  approve, send back, or refuse an employer's documents. **Nothing an employer
  does works until this happens**: they cannot publish a vacancy and cannot invite
  a candidate while unverified (BR-03), and until now there was no way to verify
  anybody from inside the app at all. Approving one release opens both.
  The queue is oldest first and says how long each submission has been waiting,
  because that is what the order is for. Every document is there to open, and the
  reason you type when you send something back or refuse it **is shown to the
  employer word for word** — the field says so, because it is the only thing they
  are given to act on. Approving needs no reason and does not ask for one.
  If a colleague decided the same submission a moment earlier, that is not an
  error: the row leaves your queue and the screen says it was already reviewed.

- **Administrator dashboard (§10.1)** — what is waiting on a decision right now,
  how many accounts are restricted or blocked, and the registrations, vacancies
  and applications for a period you choose (7, 30 or 90 days).
  Queue lengths and period figures are kept apart on purpose: "7 employers
  awaiting verification" is true today, not true of last month, and putting it
  under a date range would say the wrong thing. The verification count opens the
  queue; the other two do not yet, because their screens are still to come.

### Changed

- "Show more" and "Loading more…" are now one pair of strings shared by the Coin
  ledger and the verification queue, rather than a wallet-specific copy of each.

## 1.1.3+5 — 2026-08-20

### Added

- **Interviews (§8.3), the employer's side** — schedule one from an applicant,
  move it, or call it off, all from the applicants screen. Pick phone, in person
  or a video link; an address or a link appears only for the type that needs one,
  and switching type clears the other. Anything the candidate should bring or
  prepare goes in the same form and reaches them in your own words.
  Two things worth knowing. **Moving an interview asks the candidate to confirm
  again**, even for ten minutes — a confirmation belongs to the time it was given
  for, and the form says so before you save. And **the reason you give for
  calling one off is shown to the candidate**, which is why the field says so.
  The time you pick is the time your candidate will read, whichever zone your own
  phone is in.

### Fixed

- Private notes were unreachable on a hired or rejected application: the control
  sat behind the stage-move buttons, which a finished application has none of.

## 1.1.2+4 — 2026-08-20

Cut in the first place to correct 1.1.1's version: that build reports **1.1.0+3**,
so a device cannot tell the two apart and a phone holding 1.1.0 will not accept
build 3 as an upgrade. It carries §9.1's chat and §8.3's candidate side as well.

**Releases are cut often from here on**, on owner direction (2026-08-20): the
owner installs the APK to test, and cannot build one locally while Gradle is
broken on that machine, so an untagged commit is invisible to them. Several small
releases beat one large one — which is also what keeps the build number honest,
since a phone refuses an upgrade that does not carry a higher one.

### Added

- **Interviews (§8.3), the candidate's side** — the time, the kind, where to go
  or the link to join, whatever the employer wrote to prepare you, and the two
  answers: confirm, or ask for another time. It appears on the application the
  interview belongs to, which is where the stage badge already says "Interview".
  Asking for another time asks *which* time, because "another time please" with
  nothing attached leaves both sides waiting for the other. Confirming is not
  final — if something changes you can still ask.
  A meeting link is **copyable** rather than tappable: opening one would mean a
  new dependency, and the browser takes a URL from the clipboard exactly as the
  dialler takes a phone number.
- The candidate's application rows now say **which job** they are for. They had
  been showing a stage badge and nothing else.
- **Chat (§9.1)** — the Messages tab in both shells, and the thread behind it:
  history, a composer, sent/read state, attachments you can open, blocking with
  its reason, and reporting a message into the queue M10 reviews. One screen
  serves a candidate and an employer because the server scopes the list by the
  caller's active role.
  Two things a reader should know. **There is no "delivered" tick**: the server
  sends read state and nothing else, because delivery belongs to push (M9) and a
  flag written at the same moment as the timestamp would be a fabricated answer.
  And **the thread does not refresh itself** — M9's push is what makes it live,
  so the app bar carries an explicit refresh rather than a timer that would drain
  a battery to answer "nothing yet".
  Sending an attachment is not in this release: it needs a `file_purpose`
  dictionary code for a message attachment, which is server data the client must
  not invent. Receiving one works.
- **The finished role-selection screen** (§2.3), the last step of registration.
  There is no separate sign-up — verifying an OTP creates the account and a new
  account holds no role — so this screen is where registering ends, and until now
  it showed a placeholder notice reading "Role selection arrives in M1". Each
  role now says what it *does* (§2.2's capabilities), choosing both is explained
  rather than merely allowed (§2.3 keeps the two data sets separate), and
  administrator is still absent because §10 grants it.

### Changed

- `release-apk.yml` **fails before building** when the tag does not match
  `pubspec.yaml`. The rule was already in this file, in `pubspec.yaml` and in
  README.md; the run is the only one of the four that nobody can skip reading.
- `HhCheckboxRow` and `HhRadioRow` take an optional `description`, the second
  line `HhSwitchRow` already had. The control aligns to the label rather than to
  the middle of a two-line block.
- The status vocabulary gains four badges for an interview — scheduled,
  confirmed, another-time-asked, cancelled — two for a conversation
  (read-only, blocked), and `HhUnreadPill` for a count. All seven are in
  `/_design`.
- One date format for the whole app. `invitationStamp` and a private copy in the
  account screen became `wallClockStamp` in `lib/src/shared/format/`; chat was
  the third caller, and three copies of a date format are three ways to date one
  event.
- `candidateFileNoViewer` is now `fileNoViewer`. The sentence is about the phone,
  not about whose file it is, and a chat attachment reaches a candidate too.

## 1.1.1 — 2026-08-20

The vacancy shortlist (§7.3, closing M7) and the release asset's rename to
`jobbridge.apk`, with `headhunter.apk` kept beside it as a byte-identical alias
so links shared before the JobBridge rename keep resolving.

**Shipped as `1.1.0+3`** — the tag was pushed and `pubspec.yaml` was not bumped,
the same slip as 1.0.1 and 1.0.2. Two consequences worth knowing, because the APK
itself is fine: a device reports **1.1.0**, so this build and the previous one are
indistinguishable in a bug report; and it reuses build number **3**, so a phone
holding 1.1.0 will not accept it as an upgrade. 1.1.2 exists to correct both.

### Added

- **The per-vacancy shortlist** (§7.3), the last open M7 item. The list hangs off
  its vacancy, and the shortlist action appears only on a card that was fetched
  for one — outside a vacancy `isShortlisted` is false for everybody, including
  people who are shortlisted somewhere.

### Fixed

- **The saved-candidates list had been badging everyone a 100% match** since M7.
  An unfiltered card query has nothing to have matched, so the server scores every
  row 100; the badge is now painted only where a filter produced it.
- **Save and shortlist reverted their own labels** after a successful write, which
  read as the tap having failed.
- A prefilled search (UAT-06) could leave the previous search's results on screen
  under someone else's requirements.

### Changed

- The release asset is `jobbridge.apk`; `headhunter.apk` remains as an alias.
- README.md, docs/RELEASE.md and `build.gradle.kts` no longer explain a
  debug-signed release by way of Telegram login, which was removed on 2026-08-19.
  The cost is worse and current: such an APK installs, and then no properly
  signed build can update it.

## 1.1.0+3 — 2026-08-20

The release the product was renamed in, and the first with a working version
number (see the note under 1.0.2).

### Added

- **Coin wallet and Candidate Unlock** (§6.6, §06, M12). The balance, its som
  value, the append-only ledger with history and per-entry detail, and the unlock
  purchase. The client holds no price: coin price, unlock cost and the
  registration bonus are all server configuration (§12.3.1).
- **Direct invitations, both sides** (§8.2, UAT-07, M7). The candidate's inbox with
  accept, decline and request-details; the employer's compose screen with §8.2's
  two shapes; the sent list with server-side filters; and §7.4's counts. Sending
  is **free**, capped at 30 per employer per calendar day by server
  configuration.
- **The brand mark** (design §01). The mark, both lockups, the launch screen and
  the Android launcher icon — adaptive and legacy, replacing Flutter's default.
- **The employer dashboard** (§6.2). Active vacancies, open positions, new
  applications, candidates to review, hiring progress, and the wallet tile.
- **Account and security** (§4.2, BR-14). Signed-in devices with per-device
  revoke and terminate-all, sign-out, and the account-deletion request. Before
  this the app had **no sign-out an ordinary user could reach**.
- **Vacancy filters** (§5.5) on the candidate's feed, and a **stage filter** plus
  **private notes** (§7.3) on the employer's applicant list.
- Candidate attachments open through the OS, using the file's own server-built
  `downloadPath`.

### Changed

- **Renamed to JobBridge** — launcher name, in-app title, Android application id
  (`com.jobbridge.app` plus flavor suffixes), namespace, Kotlin package and Dart
  package. Deliberately partial: the repository folders, `docs/SPEC.md`, the
  design document and the `hh.qitmir.uz` host keep the old name.
- Screens are painted on `#F7F8FA`, the colour the design draws them on. The app
  had adopted the *paper* the artboards are laid out on as its screen colour.
- The platform launch window is navy, so a cold start no longer flashes white
  before the Flutter splash.

### Removed

- **`telegram_login`.** It applied the Kotlin Gradle Plugin, which future Flutter
  versions will refuse, and pulled a community fork of Telegram's SDK onto the
  path that guards every account — for a feature nothing called.
  `POST /auth/telegram` still exists server-side and is now unreachable from the
  client.
- Flutter's default launcher icons.

### Fixed

- **Every build before this reported `1.0.0` and build number `1`**, whatever the
  tag said, because `pubspec.yaml` had not changed since the initial commit. Two
  APKs therefore could not be installed over each other as an update. Fixed by
  bumping the version here and writing the rule at the top of this file.
- `HhButton.text` did not wrap its label, so a text button in a card overflowed
  by 190pt at 320pt and 2.0x text scale. The design-system test for that rule
  existed and only ever exercised the filled variant.
- The launch plate was sized from the literal screen width and overflowed a
  600pt-tall surface by 36pt.

### Known gaps

- **Coin top-up is not available** (§6.7, M13): blocked on Payme and CLICK
  merchant credentials and on the storefront billing decision (§12.7).
- **Three of §5.5's nine vacancy filters** — experience, language, and the pay
  range's upper bound — have no query parameter, so they are not offered. The
  filter screen names them.
- **§6.2's Interviews widget** cannot be built: `GET /interviews/mine` is
  candidate-only, so there is no route an employer may call.
- No SMS provider is connected. Sign-in uses a fixed OTP code, which the backend
  refuses to boot with when `NODE_ENV=production`.

## 1.0.2 — 2026-08-05

Tagged at the M0.5 app-shell merge. **Shipped as `1.0.0+1`**, like every build
before 1.1.0: the tag was moved and `pubspec.yaml` was not.

## 1.0.1 — 2026-08-05

Tagged during the initial toolchain and documentation work. Also shipped as
`1.0.0+1`.
