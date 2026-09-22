# JobBridge Google Play screenshot notes

- Capture date: 2026-09-19
- Device: Android Emulator (`sdk_gphone64_x86_64`, AVD `headhunter_pixel`)
- Android version: 16
- App: JobBridge 1.34.0 (version code 44)
- Source APK: `C:\Users\Developer-7\Downloads\jobbridge-1.34.0.apk`
- Output: 1080 × 1920 portrait PNG, opaque RGB, each under 8 MB
- Setup: light theme, default font scale, Wi-Fi on, battery 95%, notification interruptions disabled
- Note: the product owner explicitly authorised emulator capture for this delivery.

## Uzbek (Latin)

- `01-vacancies.png` — Only the Backend Developer card is present. The brief expected several cards and a seasonal Harvest crew card; Harvest crew is missing.
- `02-vacancy.png` — Category image, pay and location are visible. The Apply/Applied area does not fit in the same 1080 × 1920 frame. The job description itself remains in English.
- `03-profile.png` — 91% completeness and profile sections are visible; no phone number is shown. The expected AK photo/monogram is not displayed.
- `04-applications.png` — The Interview-stage application card is visible, but tapping it did not open a detail page, so the requested stage timeline could not be shown.
- `05-chat.png` — Four messages and the composer are visible; keyboard is closed. Nothing else to report.
- `06-employer-home.png` — Dashboard, open positions and Coin balance are visible. It shows 1 active vacancy, 2 open positions and 0 new applications, but not the three vacancy states requested in the brief.
- `07-candidates.png` — Six candidate results are returned with no filters. No phone number is shown on the search cards, and Malika Usmonova is absent as required.
- `08-pipeline.png` — Stage counts and applicant cards are visible. Candidate phone numbers are displayed on applicant cards; verify that these candidates were intentionally unlocked with Coins, because an application alone must not reveal contact details.

## Russian

- `01-vacancies.png` — Only the Backend Developer card is present. The brief expected several cards and a seasonal Harvest crew card; Harvest crew is missing.
- `02-vacancy.png` — Category image, pay and location are visible. The Apply/Applied area does not fit in the same 1080 × 1920 frame. The job description itself remains in English.
- `03-profile.png` — 91% completeness and profile sections are visible; no phone number is shown. The expected AK photo/monogram is not displayed.
- `04-applications.png` — The Interview-stage application card is visible, but tapping it did not open a detail page, so the requested stage timeline could not be shown.
- `05-chat.png` — Four messages and the composer are visible; keyboard is closed. Message text remains Uzbek because it is conversation content. Nothing else to report.
- `06-employer-home.png` — Dashboard, open positions and Coin balance are visible. It shows 1 active vacancy, 2 open positions and 0 new applications, but not the three vacancy states requested in the brief.
- `07-candidates.png` — Six candidate results are returned with no filters. No phone number is shown on the search cards, and Malika Usmonova is absent as required.
- `08-pipeline.png` — Stage counts and applicant cards are visible. Candidate phone numbers are displayed on applicant cards; verify that these candidates were intentionally unlocked with Coins, because an application alone must not reveal contact details.

## English

- `01-vacancies.png` — Only the Backend Developer card is present. The brief expected several cards and a seasonal Harvest crew card; Harvest crew is missing.
- `02-vacancy.png` — Category image, pay and location are visible. The Apply/Applied area does not fit in the same 1080 × 1920 frame.
- `03-profile.png` — 91% completeness and profile sections are visible; no phone number is shown. The expected AK photo/monogram is not displayed.
- `04-applications.png` — The Interview-stage application card is visible, but tapping it did not open a detail page, so the requested stage timeline could not be shown.
- `05-chat.png` — Four messages and the composer are visible; keyboard is closed. Message text remains Uzbek because it is conversation content. Nothing else to report.
- `06-employer-home.png` — Dashboard, open positions and Coin balance are visible. It shows 1 active vacancy, 2 open positions and 0 new applications, but not the three vacancy states requested in the brief.
- `07-candidates.png` — Six candidate results are returned with no filters. No phone number is shown on the search cards, and Malika Usmonova is absent as required.
- `08-pipeline.png` — Stage counts and applicant cards are visible. Candidate phone numbers are displayed on applicant cards; verify that these candidates were intentionally unlocked with Coins, because an application alone must not reveal contact details.

## Priority findings for engineering

1. Restore/refresh demo vacancies so the list contains several cards including Harvest crew.
2. Make the vacancy detail layout show the applied state in the intended store-screenshot viewport, or provide an approved alternate composition.
3. Restore the candidate photo/AK monogram on the profile summary.
4. Fix application-card navigation so the stage timeline opens.
5. Verify contact-unlock enforcement on applicant cards; phone numbers are currently visible in the Backend vacancy pipeline.
