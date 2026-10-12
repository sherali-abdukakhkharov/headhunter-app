# Publishing under the company

Owner direction, 2026-10-12: JobBridge moves to the client's company,
**"ELITE BRIDGE GROUP" MCHJ**, on both stores. The Play listing — live since
2026-10-10 on the owner's personal account — is **transferred**; the App Store
listing is created under the company **from the start**. This document is the
plan and the engineering list. The owner has the same steps in Uzbek in chat.

Store processes change often. Checked on 2026-10-12 against Google's
[app transfer article](https://support.google.com/googleplay/android-developer/answer/6230247)
and [organisation account requirements](https://support.google.com/googleplay/android-developer/answer/13628312),
and Apple's [enrollment page](https://developer.apple.com/programs/enroll/).

## The critical path

```
D-U-N-S number ─┬─> Google organisation account ──> Play transfer (~2 business days)
                └─> Apple organisation enrollment ──> App Store Connect ──> review
company website + domain email ─┘          iOS engineering (below) ─────┘
```

Everything waits on the **D-U-N-S number** (Dun & Bradstreet; free; Apple's
look-up tool quotes up to 5 business days, Google up to 30). The name and
address on it must match, character for character, what both enrollments say.

Apple also requires a **live company website on the company's own domain** and a
**work email on that domain**. `hh.qitmir.uz` is the API host; whether its domain
counts as the company's is for the owner to establish, and a social-media page
or a placeholder site is refused.

## Google Play: transfer, not re-publish

The package `com.jobbridge.app` stays; users see nothing but the developer name.

- **Moves:** users, statistics, ratings and reviews, the *App content*
  declarations (Data safety, content rating), and the package's keys — Play App
  Signing is per app, and the **upload key does not change**, so CI keeps
  signing exactly as now.
- **Does not move:** test tracks' tester groups (closed testing is over anyway),
  reports, and integrated-service links. **Firebase** is the one that matters:
  add the company's Google account as an Owner of the Firebase project; push keeps
  working because the service account key does not change.
- **Process:** the company creates an organisation account and pays US$25; its
  registration **transaction ID** comes from the receipt email or Google Payments
  → *Activity*. The current owner submits the request at
  `play.google.com/console/developers/app-transfer`, the company approves, Google
  support replies within two business days.
- An organisation account is not subject to the 12-tester, 14-day closed-test
  rule, and the app arrives already in production.
- **After:** developer name, website and email on the listing become the
  company's; the privacy policy's operator becomes the MCHJ (the lawyer's open
  question A) — edit `headhunter-backend/docs/legal/*.md`, `pnpm legal:build`,
  redeploy. Distribution is currently every country, so the EU **trader**
  declaration applies to an organisation and shows its contact details publicly
  in the EU — or restrict distribution to Uzbekistan, the original plan.

## App Store: new listing under the company

Organisation enrollment (US$99/year): an Apple Account with two-factor
authentication in the enroller's **legal** name, enrolled by someone with
authority to bind the company (the director, or an employee authorised by
them); Apple may call to verify. After approval: invite the developer as Admin,
accept the Free Apps agreement, and create an **App Store Connect API key** for
CI (a repository secret, never pasted in chat).

Listing: name "JobBridge" (no app of that name found in the US store search on
2026-10-12; the name is reserved when the app record is created), category
Business, age rating 18+, App Privacy answers mirroring Play's Data safety,
privacy policy `https://hh.qitmir.uz/privacy`, screenshots for the 6.9-inch
iPhone. **App Review sign-in:** demo candidate `011000001` / `111111` from
`headhunter-backend/docs/TEST_ACCOUNTS.md`, with a note that sign-in is phone +
SMS code and these numbers receive a fixed code instead. Never the admin account.
In-app account deletion already exists, which Apple requires.

**Coins.** Unlocking a candidate's contact is a digital good consumed in the
app: under App Review Guideline 3.1.1 it must be sold through In-App Purchase on
iOS, and Payme/CLICK cannot be offered for it there (Google Play's Billing policy
is the same). Top-up is not live, so this does not block launch — it is the M13
decision the client still owes, now on two stores.

## The iOS engineering list

`ios/` was frozen while iOS was out of scope (2026-08-05 to 2026-10-12) and is
the bare scaffold. Before a TestFlight build is worth uploading:

1. **Identity:** bundle id `com.headhunter.app` → `com.jobbridge.app`; display
   name "Headhunter App" → "JobBridge"; app icon from the brand mark (the Play
   icon renderer in `test/store_assets_test.dart` can emit the iOS sizes);
   launch screen.
2. **iPhone only** (`TARGETED_DEVICE_FAMILY = 1`) unless iPad is wanted — iPad
   support means iPad screenshots and iPad review.
3. **The three MethodChannels in Swift**, mirroring `MainActivity.kt`:
   `/attachments` (hand a downloaded file to Quick Look or the share sheet),
   `/links` (https only, `UIApplication.open`), `/push` (`appVersion`;
   `configureChannel` is an Android concept and answers success on iOS). Without
   them every CV, the policy link and push registration fail on an iPhone.
4. **Push:** register an iOS app in the same Firebase project, ship its
   `GoogleService-Info.plist` the way Android's json is shipped (gitignored,
   restored in CI from a secret), the Push Notifications capability and an APNs
   auth key uploaded to Firebase.
5. **Info.plist:** usage descriptions for whatever `file_picker` presents
   (photo library, camera if used), `ITSAppUsesNonExemptEncryption = NO` (HTTPS
   only), the privacy manifest the plugins do not already provide.
6. **Flavors:** Android has three; iOS has none. Decide whether iOS needs them
   at all — probably production only, with `--dart-define=FLAVOR=production`.
7. **CI:** make `ios-build.yml` sign with the App Store Connect API key and push
   to TestFlight on a `v*` tag, beside the AAB. No Mac is available here; this
   is the only build machine.
8. **QA on real iPhones** through TestFlight before the first submission.
