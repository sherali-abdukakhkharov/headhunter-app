# Brief for the tester taking the Google Play screenshots

*Hand everything below this line to the tester (a person with an Android phone,
or an agent driving one). It is self-contained. Do not start before the
engineering team confirms that the demo data has been refreshed — the employer
must appear as "Chinor Technologies", not "Uzum Technologies".*

---

## Your task

Take the phone screenshots for the JobBridge listing on Google Play, and
deliver them as files that meet Play's technical rules. Eight screenshots in
Uzbek (Latin), and — if time allows — the same eight in Russian.

You are also the last person to look at these screens before the public does.
**Anything that looks wrong while you are taking them is a finding**: note it
in `notes.md` with the screenshot number, even if it is small. Do not fix or
hide it in the shot.

## Setup

1. **Phone:** any Android 8+ phone with a 1080-pixel-wide screen (most phones
   sold since 2018). Not a tablet, not an emulator.
2. **The build:** the newest release from
   <https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest> —
   download `jobbridge.apk`. If a JobBridge is already installed from an older
   download, updating in place is fine.
3. **System settings, before the first shot:**
   - Interface language of the phone does not matter — the app has its own.
   - **Do Not Disturb on**, so no notification icons appear in the status bar.
   - **Battery above 90 %**, not charging (no charging icon).
   - Wi-Fi connected, so the status bar shows Wi-Fi rather than a weak signal.
   - Screen brightness does not matter; **dark mode off** (system setting).
   - **Font size and display size at the default** (Settings → Display). A
     large font changes every layout.
   - Close every other app; clear notifications.
4. **In the app:** on first launch choose **O‘zbekcha (lotin)**. If the app
   opens in another language, change it: *Profile → Account → Language*.

## The accounts

Type the nine digits into the phone field (it already shows `+998`), then the
six-digit code. **No SMS is sent** — the code is fixed.

| Type this | Code | Who | Use for |
|---|---|---|---|
| `011000001` | `111111` | Aziza Karimova, candidate | Screens 1–5 |
| `012000001` | `222221` | Chinor Technologies, employer | Screens 6–8 |
| `011000002` | `111112` | Jasur Toshmatov, candidate (Russian) | The Russian set, if you do it |

Sign out between accounts: *Profile → Account → Sign out*. Signing in with a
different number on the same phone is expected to work.

These are invented people and an invented company. The phone numbers cannot
receive calls. If you see a **real** company name anywhere, stop and report it.

## The shots, in order

Order matters: shoppers see the first two or three and rarely swipe further.
Each shot: full screen, portrait, nothing cropped yet — cropping is a separate
step below.

| # | File name | Account | Where | What must be visible | What must not |
|---|---|---|---|---|---|
| 1 | `01-vacancies` | Aziza | Bottom tab **Vacancies** (the list) | Several vacancy cards with their category pictures — "Backend Developer (Node.js)" from Chinor Technologies near the top, and the seasonal "Harvest crew" card | An empty list, a loading spinner |
| 2 | `02-vacancy` | Aziza | Tap "Backend Developer (Node.js)" | The picture band at the top with the category name, the pay, the location, and the **Apply** area at the bottom (she has already applied — the screen will say so; that is fine) | — |
| 3 | `03-profile` | Aziza | Bottom tab **Profile** | Her photo (a monogram "AK"), the completeness card (about 91 %), and the list of profile sections | The phone number `+998 01 …` if it appears on this screen — scroll so it is out of frame |
| 4 | `04-applications` | Aziza | Bottom tab **Applications**, then open the Chinor one | The application at the **Interview** stage with its timeline of stages | — |
| 5 | `05-chat` | Aziza | Bottom tab **Messages**, open the conversation with Chinor Technologies | The four messages, the composer at the bottom | Keyboard open |
| 6 | `06-employer-home` | Chinor | Bottom tab **Home** | The dashboard: three vacancies in three states (active, paused, waiting for moderation), the applications count, the Coin balance | — |
| 7 | `07-candidates` | Chinor | Bottom tab **Candidates**, search with no filters | Candidate cards. **Confirm no phone number is shown on any card** — if one is, that is a serious finding, report it immediately | Malika Usmonova — she is hidden and must not appear; if she does, report it |
| 8 | `08-pipeline` | Chinor | Bottom tab **Vacancies** → "Backend Developer (Node.js)" → its applications | The applicants across their stages (viewed, interview, rejected) | — |

Take each shot twice if unsure; keep the better one. Do not take screenshots of
the **Company → Coins / Top up** screen (it says top-up is not available yet,
which is expected but not a selling point), of the administrator account, or of
any screen that says "development" or shows a debug button.

## The Russian set (optional)

Sign in as Jasur (`011000002`): his account is already in Russian. Repeat shots
1, 2, 3 and 4 as `ru/01…04`. For 6–8, sign in as Chinor and switch the language
to Русский in *Profile → Account → Language*; switch it back afterwards.

## Cropping — read this, it is what usually gets a listing rejected

Google Play refuses a phone screenshot whose **long side is more than twice its
short side**. Nearly every modern phone produces 1080 × 2400 (a ratio of 2.22),
which is refused as-is.

- Crop each image to **1080 × 1920** (9:16). Remove pixels from the **top**
  (the status bar) first, then from the bottom, keeping the content centred.
  Do not scale, stretch or add borders.
- PNG or JPEG. **No transparency.** Under 8 MB each.
- No device frames, no text overlays, no arrows. Plain captures only — the
  marketing framing is done separately.

Any phone gallery app or a free image editor can crop to exact pixels; check
the numbers in the file's properties before delivering.

## Delivery

```
screenshots/
  uz-Latn/01-vacancies.png … 08-pipeline.png
  ru/…                      (optional)
  notes.md
```

`notes.md`: the phone model, Android version, the app version shown in
*Profile → Account*, the date — and one line per screenshot for anything that
looked wrong or surprising. "Nothing to report" is a valid line, but write it.

Zip the folder and send it back on the same channel you received this brief.
