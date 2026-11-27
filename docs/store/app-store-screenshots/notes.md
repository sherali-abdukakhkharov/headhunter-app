# JobBridge App Store screenshot notes

- Capture date: 2026-11-27 (run [46055042052](https://github.com/sherali-abdukakhkharov/headhunter-app/actions/runs/46055042052))
- Taken by: `.github/workflows/ios-screenshots.yml` driving `test_driver/screenshots.dart`
- Device: iOS Simulator, iPhone 17 Pro Max, newest runtime on `macos-latest`
- App: 1.36.0 (49), commit `f330ed2`, debug build with `FLAVOR=production`
- Data: a throwaway headhunter-backend (`feat/m1-auth` at `3e88680`) on the
  runner, with `pnpm seed` and `pnpm seed:demo` — **not production**, which
  has carried only the reviewer accounts since 2026-10-08
- Output: 1320 × 2868 portrait PNG, RGB with no alpha (6.9-inch display)
- Status bar: Apple's override — 9:41, Wi-Fi, full bars, full battery not
  charging, no carrier name. Light mode, default text size.
- Accounts: Aziza Karimova (`011000001`) for 1–5 and Chinor Technologies
  (`012000001`) for 6–8 in every language. The language was switched on the
  device only, so neither account's own language changed.

Which set goes where: the listing's **English** localization takes `en/`, and
**Russian** takes `ru/`. App Store Connect has no Uzbek localization
(docs/APP_STORE.md §7.1); `uz-Latn/` is there if the owner prefers to show the
Uzbek interface in the English listing.

## What each shows

- `01-vacancies` — Recommended feed: Backend Developer (Node.js) from Chinor
  Technologies, *Applied*, then Harvest crew — apricot season from Otabek
  Sattorov. Both carry their category picture and the verified-employer badge.
- `02-vacancy` — The picture band, title, pay, two openings, deadline, address,
  *About the job* and the first two requirements. The *Applied* line is below
  the fold. The description is the employer's own text and stays in English in
  every set (§2.4).
- `03-profile` — 91 %, *Visible in search*, the section list. No phone number.
- `04-applications` — The application at the **Interview** stage.
- `05-chat` — The four seeded messages with Chinor Technologies, the composer,
  no keyboard. The messages are Uzbek in every set: conversation content.
- `06-employer-home` — 1 active vacancy, 2 open positions, hiring progress
  (0 of 2), the 8-Coin wallet, *New vacancy* and *Find candidates*.
- `07-candidates` — Search with no filters: 5 candidates. **No phone number on
  any card**, and Malika Usmonova (hidden) is absent.
- `08-pipeline` — Applicants for the Backend vacancy with their stages. Phone
  numbers and CVs are shown here, and that is correct: an application is an
  entitlement to contact (the client's decision, 2026-08-20).

## Worth a look before uploading

- `02-vacancy` — the seeded description says the job will "own the
  integrations with Payme and CLICK". That is a job description, not a payment
  offer, and Guideline 3.1.1 is about paying for digital goods; but the Top up
  message dropped the same two names for App Review on 2026-11-27. Changing it
  means editing the vacancy in `headhunter-backend`'s demo seed and re-running.
- `08-pipeline` — the summary card at the top is narrower than the cards below
  it and sits centred. The vacancy feed's empty state does the same: the card
  shrinks to its text instead of taking the column's width. A layout defect,
  not a data one.
- `05-chat` — the message times are the moment the runner seeded them (00:13
  here), which reads oddly beside 9:41. Harmless.
