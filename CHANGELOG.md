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

## 1.16.0+26 — 2026-08-26

The audit log reads as names instead of twenty rows of hex.

### Changed

- **§10.4's log shows who acted**, not which uuid. The administrator's name is
  on the row, and so is the name of the person acted on when the row is about
  one. Tapping still opens that account — that has not changed, and it is what
  the id was there for.
- **The uuid appears only when there is no name**, which happens for an
  administrator seeded into the deployment rather than registered through the
  app. Showing both would put 36 unusable characters under every row.
- A row about a vacancy, a complaint or a dictionary entry keeps its id, because
  those are not accounts and have no name to show. What they were is already
  written into "What changed" by the action that touched them.

### Internal

- Server half in `headhunter-backend@19e8876`, resolved in the query that
  already reads the row. The client could not have done this affordably: a name
  per distinct id meant one account fetch each, returning a phone number and a
  status history to obtain a string, and writing a §11.1 access log line every
  time — a page of names would have cost a page of logged reads of other
  people's contact details.
- `DISPLAY_NAME` moved out of the users service into its own module, so the
  three callers share one expression rather than drifting into one person shown
  under two names depending on the screen.
- 1075 tests, up from 1070. Five new backend cases, five here, all mutation-
  checked. `flutter analyze` clean.

## 1.15.0+25 — 2026-08-26

Filtering by experience, language and an upper pay limit — the three §5.5 asked
for and the app had been apologising about.

### Added

- **An upper pay limit.** The filter screen had "Pay from" and a notice saying
  the other half was not possible. Both bounds now work, and a vacancy is hidden
  only when its *floor* is above the limit — so "up to 3,000,000" still appears
  under a limit of 2,000,000, because it might well pay it. Negotiable pay passes
  both bounds, as it always has.
- **Experience.** Reads as a ceiling on what the *vacancy* asks for: set 3 and
  nothing demanding more than three years appears. **Vacancies that ask for no
  experience are still shown** — they demand nothing, so nothing is too much —
  and the screen says so, because a candidate who sets a limit and still sees
  results would otherwise assume the filter is broken.
- **Language.** Matches vacancies that *require* the language, at any level. This
  is "show me work where my Russian is wanted", not "hide work I am unqualified
  for" — the recommended feed already does the second.

### Removed

- **The notice naming those three as unavailable.** It had been on the filter
  screen since the filters shipped, and taking it down is the point of this
  release.

### Internal

- Both halves written together, in both repositories
  (`headhunter-backend@63d459d`). This had been sitting as a backend ask.
- The pay range counts as **one** filter on the badge however many of its two
  bounds are set, matching §5.5, which lists it as one of nine.
- A first integration suite for discovery on the backend — 17 cases, each of the
  three filters mutation-checked — and 11 widget cases here covering the whole
  round trip: typed on screen, stored, sent.
- **A pre-existing flaky test fixed** in the backend's candidate search. It made
  three candidates and read their positions out of a 50-row page of a database
  holding 910, so it failed whenever another suite filled the page first.
- 1070 tests, up from 1056. `flutter analyze` clean.

### Documentation

- **CLAUDE.md and ARCHITECTURE.md said there was no SMS provider.** There has
  been one since 2026-08-20 — Eskiz.uz, real numbers, random codes, with the
  static-code and echo backdoors cleared and refused at boot. Both files now say
  so, and TODO.md's blocker is closed. Two consequences worth knowing: there is
  no `devCode` any more, so a test account needs a phone that can receive a
  message, and each login costs about 160 UZS.
- **docs/design-feedback.md gains ROUND 6**, collecting every outstanding design
  asset into one list: five category photographs with their crop constraint,
  three empty-state illustrations, the success drawing, the client logo, and the
  two questions still open from earlier rounds.

## 1.14.0+24 — 2026-08-26

The code screen warns you before you run out of tries.

### Added

- **"1 attempt left"**, on the last two. Until now a wrong code was wrong, and
  wrong, and wrong, and then the code was dead with no warning that it was
  close. Held back until it matters: a caution on every mistype is one nobody
  reads.
- **When the code is finished, the screen says what to do about it** — request
  a new one — rather than only repeating that the last attempt failed. Asking
  for a new code restarts the budget and re-enables Confirm.

### Fixed

- **The code field now sizes itself from the server.** It had six digits
  hard-coded, so changing that setting would have left everyone with an app
  that refuses to submit the code it was just sent.

### Internal

- §4.2's attempt feedback, **both repos in one change**. The backend's
  `OtpSent` response gains `codeLength` and `maxAttempts`.
- **The ask this had been sitting behind was wrong, and finding that out was
  worth more than the feature.** It read "needs the count in the response";
  implementing it showed why no such count exists. `/auth/otp/verify` answers
  `auth.otp_invalid` identically for "no code", "expired" and "wrong code" so
  that probing a number cannot reveal whether one is pending — and a
  remaining-attempt count on that refusal is exactly that oracle.
  So the **limit** travels instead, where it leaks nothing, and the client
  counts its own attempts against it: accurate for the person actually typing,
  which is the only party a countdown is for. The server stays authoritative —
  Confirm is disabled by the server's 429, never by the client's tally.
- Only a 401 counts. Offline, a timeout and a 5xx never reached the code, and
  counting them would tell somebody on a bad connection they were one guess
  from lockout.
- 12 new client cases plus 2 on the backend. 1056 app tests, up from 1044; the
  backend's auth integration suite is 38, up from 36.

## 1.13.0+23 — 2026-08-25

Opening the app without signal no longer looks like being signed out.

### Fixed

- **A cold start with no connection now says so.** If the app could not reach
  the server when you opened it, it showed the sign-in screen — as though your
  account had gone. It had not: you were still signed in the whole time, and
  the only thing on offer was to type your number again and wait for an SMS
  that could not arrive either.
  It now tells you your account is still there, and gives you a **Try again**.
  When the connection comes back, one tap puts you where you were.
- **"No connection" and "the server has a problem" are told apart**, because
  one is fixed by moving and the other by waiting.
- **There is a way out**, for a phone that will never get back in: sign in with
  a different number, which works without the connection this screen is about.

### Internal

- §12.4's explicit offline state, and M1's last open item bar one.
  `SessionUnreachable` joins the sealed session hierarchy and the redirect chain
  places it **ahead of** unauthenticated, because it is not that one: a refresh
  that is *refused* ends the session, a refresh that could not *complete* says
  nothing about whether it is valid. The tokens were always kept; what was
  missing was a state that said so.
- The sealed hierarchy earned itself again — adding the case broke the dev-tools
  screen's exhaustive `switch` at compile time, which is exactly what it is for.
- Retry re-runs the whole `restore`, not a bare refresh: the stored role, the
  granted set, the account status and the no-token fallback all come with it.
- 13 new cases across the controller, the router and the screen. 1044 tests, up
  from 1031.
- **The riverpod_lint mystery is settled** (MEMORY.md, 2026-08-25). Its
  `scoped_providers_should_specify_dependencies` warnings appear only when the
  tree does not resolve: the run that reported the exhaustiveness error above
  also reported eight of them in unrelated files, and fixing the switch made
  them vanish with nothing else changed. So the audit's 28 findings were an
  artefact of analysing an unresolved checkout, and there is nothing to fix in
  the providers they name.

## 1.12.0+22 — 2026-08-25

The administrator's module is finished: §10.5's wallets are the last section.

### Added

- **Employer wallets, for administrators (§10.5).** Under the Users tab: every
  employer's Coin balance, largest first, with how many candidates they have
  unlocked and when their registration bonus was granted — or that it never
  was, which is the part worth seeing.
- **One wallet's full history**, exactly as the employer sees it, and a plain
  statement that it cannot be edited or deleted. A correction is a new entry,
  never a change to an old one.
- **Manual balance adjustment, with a mandatory reason (BR-24).** Coins can be
  added or taken away; the reason is recorded against the administrator who
  made it, and the sheet says before the button that it cannot be undone.

### Not built, and said on screen

- **Searching payment orders.** The server has no administrator access to them
  yet — today it answers only the employer who made the request. Top-up is not
  live either, so there is nothing to search for.
- **Editing the registration bonus and the two prices.** No route yet. The rule
  that goes with them *is* shown, because it is the part people expect to work
  the other way: changing a price affects future transactions only and never
  rewrites what the ledger already recorded.

### Internal

- §10.5 completes M10. §10.1 landed 2026-08-21, §10.2 on the 22nd, §10.4 on the
  23rd, §10.3 on the 24th.
- The ledger uses `WalletTransactionRow` — the employer's own widget, not an
  admin copy. Two renderings of one ledger is how the two accounts of a
  transaction come to disagree.
- Nothing is prefetched: every wallet read is audited (§11.1), so a warmed page
  would write audit entries for wallets nobody opened. After an adjustment the
  wallet is **refetched**, because splicing a row in locally would be the
  client writing a ledger BR-24 leaves to the server.
- `/admin/users/wallets` has the same registration-order trap as the audit log
  — `:id` matches the literal as readily as a uuid — and `app_router_test.dart`
  now pins both, through the real router.
- 16 new cases in `admin_wallet_test.dart`, plus two in the router suite. 1031
  tests, up from 1013. flutter analyze clean.

## 1.11.5+21 — 2026-08-25

The app stops saying everything twice to people using a screen reader.

### Fixed

- **TalkBack no longer repeats every control.** Buttons announced as "Save,
  Save", navigation destinations as "Home, Home", status badges as "Verified
  employer, Verified employer" — three of the most-used components in the app,
  every time they were focused.
- **Navigation destinations say where they are**: "Home, tab 1 of 5, selected".
- **Picker chevrons have names.** Every icon-only button that opens a picker,
  a date or a time was announced as nothing at all, which made the one control
  on a picker that matters impossible to find. They now say what they open, and
  by the name of their own field — "Choose industry", not six identical
  "Choose"s on one form.

### Internal

- MT-015. `Semantics(label: X, child: … Text(X) …)` merges into `"X\nX"`; the
  fix is `excludeSemantics: true` on the wrapper, which also drops the child's
  tap and enabled state, so both are restated on the node.
- `HhTextField.trailingSemanticLabel`, **asserted** whenever `onTrailingTap` is
  supplied. Naming the six existing chevrons fixes today; the assert is what
  stops the seventh.
- Eight cases in `semantics_test.dart`, including one that tests the *shape* of
  the bug rather than its three instances — no shared component may produce a
  label containing its own text twice.
- **MT-016 could not be reproduced.** The employer dashboard's CTA clears the
  bottom bar by more than a spacing token and is hit-testable at 360 × 640 dp,
  200% text, with a status bar and a gesture strip. That is now a test rather
  than an opinion, and it passes — so the next device pass is what settles it.
  No speculative padding was added for a defect that cannot be demonstrated.

## 1.11.4+20 — 2026-08-25

Choosing your role no longer occasionally tells you to choose your role.

### Fixed

- **Finishing registration lands in a working shell.** Picking Employer and
  tapping Next could open the employer area showing *"No active role is
  selected. Choose a role first."* — on the screen right after choosing one.
  The role really had been granted, and closing and reopening the app fixed it,
  which made it look random. It was not: the app moved into the shell a moment
  before it finished telling the server which role you were acting as, so the
  first thing the shell asked for came back refused.

### Internal

- MT-021. Not a tap race in the end — a fixed ordering bug that a fast tap made
  easy to see. Publishing the granted roles is what releases the redirect
  chain, and the token rotation and the persisted choice both happened after
  it. Both now complete first, and the roles and the active role land in **one**
  state transition, so nothing watching the session ever sees half of one.
- `switchRole` keeps the opposite order on purpose: a tab change is not a
  network operation and blocking it on one would make switching roles fail
  offline. Registration already is one, so the extra round trip costs nothing
  anybody can perceive. Both orderings are now stated where they live.
- The Next button also guards re-entry itself. `onPressed` is decided during
  build and `setState` only schedules one, so two taps inside a single frame
  both saw an enabled button.
- Six cases in `session_controller_test.dart` over an ordered log of side
  effects. Mutation-verified: the old order produces
  `['roles', 'state', 'active-role:employer']` instead of
  `['roles', 'active-role:employer', 'state']`.

## 1.11.3+19 — 2026-08-25

Column names and raw numbers stop showing up where words and money belong.

### Fixed

- **A candidate's CV now says "CV".** For an employer who had paid to see it,
  the line under the filename read *"Unavailable value"* — in every language,
  on every attachment, for as long as that screen has existed.
- **Employers are told which document to upload in words.** The verification
  card listed `company_registration` and `evidence`; the moderator's queue did
  the same. Both now show the dictionary's own label, in the reader's language.
- **Pay is legible.** A vacancy showed `150000 – 250000` — no separators, no
  currency, nothing saying what it was per. It now reads as grouped figures
  with the currency and, where the vacancy states one, the payment period.
  Everywhere: the feed, the vacancy itself, and the moderator's review.
- **"restriction_changed_requires_review" is now a sentence.** When an employer
  edits an age or gender restriction the vacancy goes back for review, and the
  reason the app showed them was the internal name of that rule.

### Internal

- MT-009 and MT-012 from the 1.11.0 audit, which are one defect wearing three
  hats: a machine value rendered where a person was reading.
- `DictionaryCodeLabel` resolves by **code**; `DictionaryLabel` still resolves
  by id. The bug was that both are `String`, so passing one to the other
  compiles and then renders "Unavailable value" forever. An unresolved code now
  falls back to a humanised form (`company_registration` → *Company
  registration*) rather than to a phrase carrying no information.
- `formatPay` in `core/format/` replaces three private copies that had all
  drifted to the same bare interpolation. Four ARB keys, `decimalPattern` for
  grouping, and the period arrives as a **resolved** label — null while the
  dictionary is still answering, and omitted rather than shown as an ellipsis
  mid-figure.
- `moderationReasonText` words the two reasons the *server* writes and passes
  everything else through, so §2.4's verbatim rule keeps applying to the human
  text it was written for.

## 1.11.2+18 — 2026-08-25

The app stops blaming itself for things you are still typing, and starts
speaking your language when the connection drops.

### Fixed

- **Losing signal no longer produces English developer instructions.** The app
  used to ask whether "the backend" was running and whether the "base URL" was
  correct for your device — in English, whichever of the four languages you had
  chosen. It now says you are offline, in your own language, and so does every
  other failure the server was not reachable to word itself.
- **"Get a code" is no longer offered for a number that cannot work.** It used
  to light up as soon as the terms box was ticked, so two digits looked like
  enough; tapping it then reported *"Something went wrong"* — a system failure,
  for a number you had not finished typing. The button now waits for nine
  digits, and the guidance sits under the field where the problem is.
- **"Confirm" is no longer offered for an empty code**, for the same reason and
  with the same fix.

### Internal

- MT-013 and MT-014 from the 1.11.0 audit.
- `ApiException` gains `kind` (`offline` / `timeout` / `cancelled` /
  `certificate` / `server` / `unknown`) and `isRetryable`, so a screen can
  *behave* differently rather than only say something different — and so tests
  assert the condition instead of an English fragment. Two tests that had been
  matching copy now match the kind.
- Twelve ARB keys across all five files, and `ApiException.localizations`, a
  static installed from `JobBridgeApp` on every build. A static because a
  repository has no `BuildContext` and there are **117** places that build one
  of these; the `x-lang` interceptor solves the same problem the same way.
- The two sign-in screens now derive the button's enabled state from the same
  value the submit path checks. Mutation-verified: restoring either old gate
  reddens three of the eleven new cases.

## 1.11.1+17 — 2026-08-25

Notifications can be marked read again — which, it turns out, they never could.

### Fixed

- **Opening a notification, and "mark all read", now work.** Both asked the
  server in a way it does not answer, so every read action failed: tapping a
  row still took you where it led but left the row unread, "mark all read"
  answered *"The requested data was not found"*, and the unread badge never
  came down. The centre kept presenting things you had already dealt with as
  new. This affected 1.10.0 and 1.11.0 — every build that has had the
  notification centre in it.

### Internal

- The two calls were written as `POST` against routes the backend declares as
  `PUT`. Nothing caught it because the notification tests supplied a fake
  repository, so the *method* was the one property in the file nothing
  asserted — and because a wrong verb answers **404** on that route, which is
  also the legitimate answer for somebody else's notification. The failure was
  indistinguishable from the refusal the route is designed to give.
- `notification_repository_test.dart` now pins the verb and the path of all
  eight routes, and — where the backend repository is checked out beside this
  one — reads its controller decorators and fails when the two disagree. That
  last case is the only one that catches this at its source; the rest pin the
  client against a table a human transcribed, and this bug is what happens when
  the transcription is wrong.

## 1.11.0+16 — 2026-08-24

Your phone tells you now. Until this release the app could show you everything
that had happened, but only once you opened it and went looking.

### Added

- **Push notifications (§9.2).** A message, an invitation, an interview time or
  a decision on your application reaches your phone while the app is closed,
  and **tapping it opens the thing itself** rather than the app's home screen —
  the conversation, the application, the vacancy. Where a notice is about your
  own account and there is nothing to open, it says so by not pretending
  otherwise.
  You are asked for permission when you sign in, which is the point at which
  there is something to be notified about. **Saying no costs you nothing else:**
  every notification is still recorded and still listed in the app, and turning
  notifications on later in your phone's settings starts push working without
  signing out and back in.
  Signing out stops notifications to that phone, immediately and on purpose —
  phones get handed on, and the next person to sign in takes the device over.

### Fixed

- A notification arriving while the app is open now updates the unread count
  straight away. Android shows no banner in that case, so the number was the
  only sign, and it was the one thing not refreshing.
- `searchShortlist` and `searchShortlisted` were each defined twice in all five
  translation files, with different English wording. The later definition won
  silently; there is now one of each.

### Not in this release

Nothing on a phone with no Google Play services — every Huawei sold after 2019.
Those phones lose the banner and nothing else: the in-app notification list is
the record, and it is complete for everyone.

## 1.10.0+15 — 2026-08-24

Notifications, in the app. Until now the only way to find out that an employer
had replied, an interview had moved or a profile had been verified was to go
looking for it.

### Added

- **A notification centre (§9.2)**, reached from the top of the first tab in
  every role — with the number of unread ones on it.
  It lists what has happened to you, newest first, and **tapping one opens what
  it is about**: a message opens the conversation, an application or an
  invitation opens the list it is in, a vacancy decision opens the vacancy.
  Where there is nothing to open — a notice about your own account is the whole
  of the news — the row simply does not pretend there is.
  **Unread and read are told apart by a dot and a weight**, not by colour, and
  "Mark all read" says how many actually were: marking an already-read list
  changes nothing, and it says that instead.
  **You choose what you are told about.** Applications, invitations, messages
  and interviews can each be switched off. Security and account notices cannot,
  and that switch is shown greyed out rather than hidden — a switch you cannot
  find is one you assume is off. Switching a category off stops it being
  recorded at all, and the screen says so before you do it, because the ones
  you miss will not be waiting here later.

### Not in this release

Push notifications. The app can show you everything that has happened once it
is open; making your phone tell you while it is closed needs a Firebase
configuration file that still names the app's old identifier. Nothing else
stands in the way, and nothing above depends on it.

## 1.9.0+14 — 2026-08-24

Dictionary management, which was the last unfinished tab anywhere in the app.
Every screen a candidate, an employer or an administrator can reach is now a
real one.

### Added

- **Dictionaries (§10.3)** — the administrator's fifth tab. It opens on the
  list of everything the pickers draw from: occupations, skills, regions,
  languages, levels and the rest, each with how many of its items are in use.
  Opening one lists its items, searchable by name **or code** — a duplicate is
  usually hunted by code, and the name on screen may be in a language you
  cannot type.
  **Retired items are in the list, and marked.** Nothing in this product is
  ever deleted: an item taken out of use leaves the pickers and stays readable
  in every profile and vacancy that chose it. An item merged into another says
  that instead, and points at the one that replaced it.
  **Adding an item asks for all four names.** An item needs a name in Uzbek
  (both scripts), Russian and English before it can be used, so the form
  collects them together and says how many are still to write. Fewer is a
  draft: it is added, it stays out of the pickers, and it can be put into use
  the moment the last name arrives.
  **Putting an item into use can be refused, and the reason is said plainly** —
  "it has no name in all four languages yet" rather than an error code.
  **Merging a duplicate says which one goes.** The item you opened is the one
  that is retired and pointed at the one you keep, so nothing that used it
  breaks. That direction is stated before the choice, not after it.

### Note

Editing the names of an item that already exists is not offered yet. The app
can only read one name at a time and cannot tell a missing translation from a
real one, so a form here would risk saving the wrong language over the right
one. Adding new items, which is where the four names actually get written, is
unaffected.

## 1.8.0+13 — 2026-08-24

The employer's first ten minutes, from the 1.4.1 audit. It was possible to
create an account that could do nothing, in one tap, and then be told nothing
was wrong.

### Fixed

- **A company profile can no longer be created by accident.** The "who is
  hiring" question used to arrive with *A company* already chosen, and the
  first Save made that permanent — so tapping Save before reading anything
  committed the wrong kind of account, and the choice then disappeared with no
  way back. Nothing is preselected now, and the form below the question only
  appears once it is answered: which details are asked for is what the answer
  decides.
- **And it cannot be created empty.** The first save is held to everything §6.1
  asks for, because that save is what makes the choice permanent — and a
  profile that satisfies it is one that can go straight to verification, rather
  than the 0%-complete account that blocked vacancies, candidate search and
  verification alike. What is still missing is named under the button and
  marked on the fields, and the screen scrolls to the first one. Editing an
  existing profile is unchanged: half-finished edits save as before.
- **Saving a profile no longer leaves the verification section stale.** It used
  to keep showing its earlier "no profile" error until you tapped Try again, so
  a save that had worked looked like it had not.
- **The dashboard no longer says "Nothing is waiting on you" to an employer who
  cannot do anything.** An account with no company profile — or a half-filled
  one — now has that at the top of the list, with the way to fix it. This was
  the app saying everything was fine and then refusing every main action.

## 1.7.0+12 — 2026-08-24

The first release answering the 1.4.1 QA audit. Candidates get a real home
screen, administrators can sign out, and three smaller defects the audit found
are gone.

### Added

- **A candidate home screen (§5.5).** It replaces the milestone note that had
  been the default destination after every login and every restart.
  It leads with **what is waiting on you** — invitations still to answer and
  applications still in progress, each opening the tab that holds them. Then,
  while a profile is unfinished, how complete it is and what that costs: an
  incomplete profile is not searchable at all, so the card says employers
  cannot find you yet rather than leaving that to be discovered. Then the work
  the platform recommends, three at a time, with the full feed one tap away.
  **A section that cannot load simply is not there.** Home is built from four
  separate requests, and one of them failing must not make a candidate's first
  screen look broken — every one of them has a tab of its own that reports the
  failure properly.
- **The administrator can reach their account and sign out.** The candidate and
  the employer had this on their profile tab; the administrator's five tabs are
  all work queues, so in a production build there was no way out of the app at
  all. It is the same row, at the bottom of the dashboard.

### Changed

- **An invitation you have been sent no longer says "Sent".** On the
  recipient's own list it now reads *Awaiting your answer* — the old wording is
  the employer's side of the same event, and on an inbox card it read as though
  you had sent something.
- **A match percentage is only shown where something was matched.** Searching
  with no requirements set scored every candidate at 100%, which reads as a
  judgement about a person and was not one.
- **The vacancies tab remembers which feed a link meant.** Opening "Saved" or
  "Recommended" from elsewhere now arrives at that feed instead of whichever one
  was last looked at.

## 1.6.0+11 — 2026-08-23

§10.4 is finished: the audit log is in the app. Everything an administrator
decides is now readable by another administrator, from the account it was done
to or from the person who did it.

### Added

- **The audit log (§10.4)** — reachable from the top of the Users tab, and from
  any account by two questions: **everything done to this account**, and, on a
  colleague's account, **everything this administrator has done**.
  Each entry says what was done, the date **and the time**, what it was about,
  the reason the administrator typed, and — where the action recorded one — what
  changed, exactly as it was stored.
  **Nothing here can be changed or removed**, and the screen says so. That is a
  property of the database rather than of this app not offering a button.
  **An id opens the account it names.** The log records who acted as an
  identifier rather than a name, so instead of showing a string nobody can read,
  the row leads to that person's account. The same goes for an entry about an
  account. Entries about a vacancy or a complaint keep their identifier and lead
  nowhere, because opening a decision somebody already made is how it gets made
  a second time.
  **An action this version has not heard of still appears**, under its own code.
  The list of things worth recording grows on the server, and a log that hid the
  rows it could not name would not be a log.

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
