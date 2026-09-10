# Google Play launch

How JobBridge gets from a GitHub Releases APK to a listing on Google Play, in
the order the steps actually have to happen, with what is decided and what is
still open. Written 2026-09-10 against Play Console as it is then; the Console
changes its forms every few months, so check a step against the screen before
trusting it.

## The decisions already made

| Decision | What | Why |
|---|---|---|
| **Developer account** | A **personal** account in the owner's name, for now | Faster to open than an organisation account, which needs a D-U-N-S number (up to 30 days). The app will be **transferred** to the client's organisation account — "ELITE BRIDGE GROUP" MCHJ — later; Play supports app transfers between accounts and everything (installs, reviews, the Google-held signing key) moves with it. |
| **Application id** | `com.jobbridge.app` | Never published, so still changeable today; **fixed forever after the first upload.** |
| **Signing** | Play App Signing with a **Google-generated** app signing key; the existing `upload-keystore.jks` stays the upload key | See [RELEASE.md](RELEASE.md#play-store-distribution). Cost: every tester uninstalls the GitHub-download APK once when they move to a Play track. |
| **Build artefact** | The `.aab` the release workflow publishes on every tag | Same flavour, same defines as the APKs — the uploaded file is the one the tag produced. |
| **Distribution** | Uzbekistan only, phones only | No tablet screenshots needed; no EU trader disclosures. |
| **Reviewer access** | The seeded test accounts (`headhunter-backend/docs/TEST_ACCOUNTS.md`) | Google's reviewers are not in Uzbekistan and cannot receive an Eskiz SMS. |

## Two things worth knowing before anything else

**The personal-account testing rule.** A personal developer account created
after 13 November 2023 cannot publish to production until the app has run a
**closed test with at least 12 testers opted in for 14 consecutive days**, after
which the owner *applies* for production access and answers Google's
questionnaire. The 14 days start when the twelfth tester is in; a tester who
leaves stops the clock. This is the longest fixed stretch of the whole launch
and it cannot be shortened, so the closed test starts the moment the listing's
mandatory sections are complete.

**Coins are a Google Play Billing question, and it is unresolved.** Coins are a
virtual currency bought in the app and spent in the app, which is the textbook
case for Play's requirement to use Google Play's billing system — a
Payme/CLICK checkout inside the app for Coins would be a policy violation and
a ground for removal. Today top-up is not available, so the first release
carries no purchase flow and nothing to review. **Before M13 ships**, the
client has to decide between Play Billing (verify that Uzbekistan is a
supported merchant country; it may not be), selling Coins outside the app
(with Play's anti-steering rules limiting how the app may point at it), or a
different model. This document does not decide it.

## The sequence

### 1. Legal pages — start today, they gate the closed test

Play requires two public URLs, and the Console will not let a closed-test
release out without the app-content declarations that depend on them:

- **Privacy policy.** Drafted from
  [`headhunter-backend/docs/legal/PRIVACY_POLICY_BRIEF.md`](../../headhunter-backend/docs/legal/PRIVACY_POLICY_BRIEF.md),
  which is the prompt for whoever writes it and carries every product fact
  they need. **The client's lawyer approves it** — BR-14 rests on "the
  approved privacy policy", and there is none yet.
- **Account deletion page.** Required for any app with account creation: how to
  delete in-app, and how to request deletion without the app. Same brief.

Where they live: served by the backend at `https://hh.qitmir.uz/privacy` and
`https://hh.qitmir.uz/account/delete` (three languages, one URL each with a
language switch). The pages are deployed **after** approval — a draft privacy
policy on a public URL is a published policy.

### 2. The developer account

1. A **dedicated** Google account the owner controls (not a daily-use Gmail),
   with 2-Step Verification on and recovery details set. It becomes the
   account owner; ownership is hard to move.
2. `play.google.com/console/signup` → *Yourself* → legal name as in the
   passport, address, phone (SMS-verified), contact email (verified, and
   **shown publicly** on the listing), developer name — `JobBridge` is fine,
   it need not be a personal name — $25, Developer Distribution Agreement.
3. **Identity verification**: government ID, sometimes a selfie; one to three
   days. Nothing can be published until it passes, but the app record and the
   listing can be drafted meanwhile.

If the app ever monetises through Play, Google displays a personal account's
**postal address** on the listing. Another reason the transfer to the
organisation account happens before M13.

### 3. Store listing

| Asset | Spec | Status |
|---|---|---|
| App icon | 512 × 512 PNG, no transparency, ≤ 1 MB | **[docs/store/icon-512.png](store/icon-512.png)** — the in-house mark at 56 % on navy, the design's figure for square masks (owner's decision 2026-09-10: launch with it; the client's logo has not arrived and the icon can be replaced later). |
| Feature graphic | 1024 × 500 PNG/JPEG | **[docs/store/feature-graphic-1024x500.png](store/feature-graphic-1024x500.png)** — the horizontal lockup on navy, one graphic for all four interface variants because the logotype is not translated. |

Both are rendered from the real brand widgets by `test/store_assets_test.dart`
— `flutter test test/store_assets_test.dart --dart-define=STORE_ASSETS_OUT=docs/store` —
so when the brand changes, re-run that rather than editing a PNG. Without the
define the file is one skipped test, which is what lets it live in `test/`.
| Phone screenshots | 2–8, PNG/JPEG, no alpha, **long side ≤ 2 × short side** (so 1080 × 1920, *not* 1080 × 2400) | Brief in [STORE_SCREENSHOTS_BRIEF.md](STORE_SCREENSHOTS_BRIEF.md); taken by the tester from a real phone against the seeded data. |
| Short description | ≤ 80 characters | Below, three languages. |
| Full description | ≤ 4000 characters | Below. |
| Category | Business | — |
| Contact email, website | Public | Owner's choice; the website can be `hh.qitmir.uz` until the client has one. |

Check that no other listing already uses the name "JobBridge" in a way that
invites a trademark complaint; Play does not enforce unique titles.

#### Short description

| Locale | Text |
|---|---|
| uz-Latn | O‘zbekistonda ish: profil tuzing, ariza bering, xodim toping — har qanday soha. |
| ru | Работа в Узбекистане: профиль, отклики, наём — для любой сферы труда. |
| en | Jobs in Uzbekistan: build a profile, apply, and hire — for every kind of work. |

#### Full description (uz-Latn)

> JobBridge — O‘zbekiston uchun ish topish va xodim yollash ilovasi. Bitta
> ilovada ham ish izlovchi, ham ish beruvchi bo‘lish mumkin.
>
> **Ish izlovchilar uchun.** Telefon raqami bilan kiring, profil tuzing — kasb,
> ko‘nikmalar, tillar, tajriba, kutilayotgan maosh. Rezyume yuklash shart
> emas: qidiruv profildagi ma’lumotlar bo‘yicha ishlaydi. Vakansiyalarni
> viloyat, kasb va maosh bo‘yicha qidiring, ariza bering, javobni kuzatib
> boring va ish beruvchi bilan ilovaning o‘zida yozishing. Telefon raqamingiz
> qidiruvda ko‘rinmaydi.
>
> **Ish beruvchilar uchun.** Kompaniya yoki jismoniy shaxs sifatida ro‘yxatdan
> o‘ting, tekshiruvdan o‘ting va vakansiya joylashtiring. Nomzodlarni kasb,
> ko‘nikma, viloyat va maosh bo‘yicha qidiring, suhbatga taklif qiling,
> arizalarni bosqichma-bosqich ko‘rib chiqing.
>
> **Besh yo‘nalish.** Mutaxassislar, xizmat ko‘rsatish va savdo, ishlab
> chiqarish va qurilish, mavsumiy va qishloq xo‘jaligi, vaqtinchalik va
> smenali ish — har biri uchun o‘z so‘rovnomasi.
>
> Ilova o‘zbek (lotin va kirill), rus va ingliz tillarida ishlaydi.

#### Full description (ru)

> JobBridge — приложение для поиска работы и найма сотрудников в Узбекистане.
> В одном приложении можно быть и соискателем, и работодателем.
>
> **Соискателям.** Войдите по номеру телефона и заполните профиль: профессия,
> навыки, языки, опыт, ожидаемая оплата. Загружать резюме не обязательно —
> поиск работает по данным профиля. Ищите вакансии по региону, профессии и
> оплате, откликайтесь, следите за статусом отклика и переписывайтесь с
> работодателем прямо в приложении. Ваш номер телефона в поиске не виден.
>
> **Работодателям.** Зарегистрируйтесь как компания или частное лицо,
> пройдите проверку и размещайте вакансии. Ищите кандидатов по профессии,
> навыкам, региону и оплате, приглашайте на собеседование, ведите отклики по
> этапам.
>
> **Пять направлений.** Специалисты, сервис и торговля, производство и
> строительство, сезонная и сельскохозяйственная работа, временная и сменная
> работа — у каждого своя анкета.
>
> Приложение работает на узбекском (латиница и кириллица), русском и
> английском языках.

#### Full description (en)

> JobBridge is a job search and hiring app for Uzbekistan. One app, and you can
> be both a job seeker and an employer.
>
> **For job seekers.** Sign in with your phone number and build a profile:
> occupation, skills, languages, experience, expected pay. No CV required —
> search works on the profile itself. Search vacancies by region, occupation
> and pay, apply, follow your application through its stages, and message the
> employer inside the app. Your phone number is never shown in search results.
>
> **For employers.** Register as a company or an individual, pass verification,
> and post vacancies. Search candidates by occupation, skills, region and pay,
> invite them to interview, and move applications through stages.
>
> **Five kinds of work.** Professional, service and trade, industrial and
> construction, seasonal and agricultural, temporary and shift — each with its
> own form.
>
> Available in Uzbek (Latin and Cyrillic), Russian and English.

### 4. Console questionnaires ("App content")

| Section | Answer |
|---|---|
| **App access** | *All or some functionality is restricted* → provide: candidate `+998 011000001` code `111111`; employer `+998 012000001` code `222221`. Instructions: "Type the nine digits after +998 into the phone field; no SMS is sent; the code is fixed." Keep the demo accounts seeded for as long as the app is under review. |
| **Ads** | No ads. |
| **Content rating** | IARC questionnaire. Expected answers: users can interact (chat), users can share text and files, no violence/sexual/drug content, no gambling, no purchases of digital goods **yet** (re-answer when Coins go on sale). |
| **Target audience** | **Open decision.** The profile accepts age 14+, following Uzbek labour law. Declaring 13–15 brings extra obligations; declaring only 16–17 and 18+ contradicts the validator. The client's lawyer decides, and the validator follows the answer. |
| **Data safety** | The table at the end of `PRIVACY_POLICY_BRIEF.md`; it must match the published policy word for word in substance. Encryption in transit: yes. Deletion: yes, in-app and by request. |
| **News app** | No. |
| **Government app** | No. |
| **Financial features** | Read the form when it is live; the app holds a Coin balance but no loans, banking or card handling. |
| **Health** | No. |
| **Account deletion URL** | `https://hh.qitmir.uz/account/delete` |
| **Privacy policy URL** | `https://hh.qitmir.uz/privacy` |

### 5. The build

Tagging `vX.Y.Z` runs the release workflow, which now publishes
`jobbridge-X.Y.Z.aab` beside the APKs. Download it from the GitHub release and
upload it in the Console. `versionCode` must increase on every upload; it is
the `+N` in `pubspec.yaml`, and the release procedure in [CHANGELOG.md](../CHANGELOG.md)
already bumps it.

**The first upload is manual** — Play requires it before the publishing API can
be used. Automating later uploads (a service account with the *Release
manager* role, `r0adkll/upload-google-play` or fastlane) is worth doing once
the closed test is running and builds go up weekly.

### 6. Tracks

1. **Internal testing** — up to 100 email addresses, no review, live in
   minutes. The QA team moves here from the GitHub/Telegram APK; each of them
   uninstalls the direct download once (different signing key).
2. **Closed testing** — the 12 × 14 rule above. Invite 15–20 people (QA, the
   client's staff, friends) with a Google account each; give them one line of
   instruction: *open the invitation link, join, install from Play, keep it
   installed for two weeks*. Ship fixes into this track as the QA audits find
   them — Google's questionnaire asks what the test found and what changed.
3. **Apply for production access** in the Console once the 14 days show as
   met. Answer concretely: number of testers, the audit findings fixed during
   the test, how feedback was collected.
4. **Production** — first review can take up to seven days. Use a **staged
   rollout** (20 % → 50 % → 100 %) and watch Play's crash and ANR reports; the
   app ships no crash SDK, so Play's own vitals are the only signal.

### 7. Before real users arrive

In this order, on the production backend:

```powershell
pnpm seed:demo:clean
pnpm seed:demo:reviewers
```

The full demo world has active vacancies that real job seekers would apply to
and searchable candidates that a real employer could pay Coins to unlock.
`seed:demo:reviewers` keeps the ten accounts and their codes — so *App access*
stays true — but hides every candidate, publishes no vacancy and creates no
application. `TEST_ACCOUNTS.md` documents the difference.

And check the deployment itself: the API runs on one Windows machine behind a
Cloudflare tunnel with `restart: unless-stopped`. That survives a reboot, not
a power cut or an ISP outage — and a store app is one the public expects to
find up. Moving the API and the database to a hosted VPS before production is a
**decision for the owner**, not a requirement of this document.

## Timeline

| Stage | Duration |
|---|---|
| Developer account + identity verification | 1–3 days |
| Privacy policy: draft → lawyer → approved → deployed | 1–2 weeks, **the critical path** |
| Listing, assets, questionnaires | in parallel |
| Internal testing | same day as the first AAB |
| Closed testing | **14 days**, fixed |
| Production-access application | 2–5 days |
| Production review | up to 7 days |

Four to five weeks from the day the lawyer receives the brief.

## Open decisions

1. ~~**Icon**: in-house brand mark now, or wait for the client's logo.~~
   Decided 2026-09-10: the in-house mark. Replace the two files in
   `docs/store/` if the client's logo ever arrives.
2. **Target audience / minimum age**: lawyer.
3. **Coins and Google Play Billing**: client, before M13.
4. **Hosting** the API somewhere that is not a laptop: owner.
5. **When to transfer** the app to the ELITE BRIDGE GROUP organisation
   account (needs their D-U-N-S and their own $25 registration first).
