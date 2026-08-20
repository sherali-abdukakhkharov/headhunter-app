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
