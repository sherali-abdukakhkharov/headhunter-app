# Turning push notifications on

§9.2's notifications work in two halves, and only one of them is blocked.

**The in-app half already works** and needs nothing here. Every notification is
written to the database, listed in the app's notification centre, counted by
the badge and filtered by the per-category switches — whether or not a push was
ever delivered. That is deliberate: a push is a *message about* something that
happened, so it must never be able to prevent the thing from happening. An
instance with no Firebase project is a degraded instance, not a broken one.

**The push half is blocked on one thing**, and it is not code: the Firebase
project registers the app under package names it no longer has.

---

## 1. Why it is blocked

The product was renamed on 2026-08-19 and the Android application id changed
with it. Firebase still has the old one:

| Firebase has | The app actually is |
|---|---|
| `com.headhunter.app` | `com.jobbridge.app` |
| `com.headhunter.app.dev` | `com.jobbridge.app.dev` |
| `com.headhunter.app.staging` | `com.jobbridge.app.staging` |

`android/app/google-services.json` is the file the Firebase SDK reads at
startup to find out which app it is. It is checked in with the old names **on
purpose** — it was left alone rather than hand-edited, because a hand-edited
one would carry ids that exist in no Firebase project and fail later and less
clearly.

At startup the SDK looks for the running package name in that file. Under
`com.jobbridge.app` it finds nothing and refuses to initialise, so the app can
never obtain a device token, so `POST /notifications/devices` has nothing to
register and no push is ever addressed to the phone.

**A package name cannot be renamed in Firebase.** It is the app's identity
there. The fix is to register three new apps beside the old ones.

The Firebase *project* id (`headhunter-app-b463f`) does not matter and cannot
be changed either — nobody sees it, and only the package names have to match.

---

## 2. What you do in the Firebase console

Project: **headhunter-app-b463f** → ⚙ **Project settings** → **General**.

### 2.1 Register the three new apps

For each of the three ids below: **Add app** → Android →

- **Android package name** — exactly one of:
  - `com.jobbridge.app`
  - `com.jobbridge.app.dev`
  - `com.jobbridge.app.staging`
- **App nickname** — anything; *JobBridge Prod*, *JobBridge Dev*,
  *JobBridge Staging* keeps the list readable.
- **Debug signing certificate SHA-1** — **leave it empty.**

  Push does not use it. SHA fingerprints are for Google Sign-In, Dynamic Links
  and App Check; this product has none of those. The three existing apps have no
  fingerprint either, which is why they have worked for everything except this.

Then **Next → Next → Continue to console**. Skip every SDK instruction the
wizard shows — the Gradle and Dart changes are in the repository's half of this
(§4), and following the wizard's version numbers would fight the dependency
pinning in `pubspec.yaml`.

Register all three before downloading anything.

### 2.2 Download `google-services.json`

**Project settings → General → Your apps**, pick any *JobBridge* app, and press
**google-services.json**.

One file covers all three flavors: the download contains a `client` entry for
every Android app in the project, and the Gradle plugin picks the entry that
matches the id being built. Downloading it from the dev app and the prod app
gives the same file.

Send it to the development side. It replaces `android/app/google-services.json`
wholesale — **do not merge it by hand.**

It is not a secret: it ships inside every APK and contains no credential that
grants anything on its own. It is committed to the repository for that reason.

### 2.3 Generate the server credential

**Project settings → Service accounts → Firebase Admin SDK → Generate new
private key → Generate key.** A `.json` file downloads.

**This one is a secret.** It authenticates as the project and can send a push
to any device registered to it. It must not go in the repository, in a chat, or
in a screenshot. If it is ever exposed, come back to this page and generate a
new key — the old one can be revoked from the Google Cloud console.

### 2.4 Check that the API is on

**Project settings → Cloud Messaging** → *Firebase Cloud Messaging API (V1)*
should read **Enabled**. It is on by default for any project created in recent
years, and this backend uses only V1. The *legacy* API on the same page is
deprecated and is not used; leave it disabled.

---

## 3. What you do on the server

The backend takes the service-account JSON base64-encoded, in one environment
variable. Base64 because the document is multi-line and its private key
contains newlines, which `.env` files handle badly enough that most failures
would be quoting mistakes.

**This is a Windows machine and `base64` is not a command here.** PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\service-account.json"))
```

Copy the whole line — it is long, and a truncated value fails at boot rather
than at the first push, which is the good direction.

In `headhunter-backend/.env`:

```
FCM_SERVICE_ACCOUNT_BASE64=<the base64 string, no quotes, no line breaks>
FCM_TIMEOUT_MS=10000
```

Restart the API. The boot log tells you which state it is in:

- with the variable set, nothing is logged and pushes are sent over FCM HTTP v1;
- with it empty, `FCM_SERVICE_ACCOUNT_BASE64 is not set: notifications are
  stored and read in-app, but no push is delivered` — which is the state today,
  and a supported one.

Then delete the downloaded `.json` from your Downloads folder. The value lives
in `.env` now.

---

## 4. What the repository still needs (not yours)

Once the file from §2.2 arrives, the app side is code, and it is not written
yet:

- `firebase_core` and `firebase_messaging` added to `pubspec.yaml`, against
  the dependency pinning documented in CLAUDE.md — the analyzer-12 chain caps
  several packages, so the versions have to be resolved rather than taken from
  the console's instructions.
- The `com.google.gms.google-services` Gradle plugin applied, which is what
  reads `google-services.json` at build time.
- `POST_NOTIFICATIONS` in the manifest and the Android 13+ runtime permission
  request, which has to be asked for at a moment that makes sense rather than
  on first launch.
- Registering the device token with `POST /notifications/devices` after
  sign-in, and removing it with `DELETE /notifications/devices/:token` on
  sign-out — the token is per **device**, not per user, because phones in this
  market are handed on, resold and shared.
- Handling a notification tapped while the app is closed, which lands on the
  same routing the in-app centre already has.

---

## 5. What still will not work afterwards, and is nobody's fault

FCM needs **Google Play services** on the device. A Huawei phone sold after
2019 does not have it. Those users get no banner and lose nothing else: the
in-app notification centre is the record, and it is complete for everyone.

---

## 6. How to tell it worked

1. The API boots without the `FCM_SERVICE_ACCOUNT_BASE64 is not set` warning.
2. A development build signs in and `notification_devices` gains a row for that
   phone.
3. Somebody sends the signed-in candidate a message from an employer account,
   the phone is locked, and a banner appears.
4. Tapping the banner opens that conversation rather than the app's home.

If 1–2 work and 3 does not, the problem is on the device (Play services, or the
notification permission having been refused), not in the configuration — check
the in-app centre, which will have the notification either way.
