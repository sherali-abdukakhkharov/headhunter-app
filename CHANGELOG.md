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
