# Turning push notifications on

§9.2's notifications work in two halves, and only one of them is blocked.

**The in-app half already works** and needs nothing here. Every notification is
written to the database, listed in the app's notification centre, counted by
the badge and filtered by the per-category switches — whether or not a push was
ever delivered. That is deliberate: a push is a *message about* something that
happened, so it must never be able to prevent the thing from happening. An
instance with no Firebase project is a degraded instance, not a broken one.

**The push half is blocked on one thing**, and it is not code and not the
server: the Firebase project registers the app under package names it no longer
has. The server credential is configured and has been ready to send for as long
as it has been set — it has simply had no device to send to.

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

### 2.3 The server credential — **already done, do not regenerate**

`FCM_SERVICE_ACCOUNT_BASE64` is already set in `headhunter-backend/.env`.

It stays valid through this whole exercise, because **a service account
authenticates as the Firebase *project*, not as an app.** It has no package
name in it. Adding three Android apps to the project changes nothing about it,
and neither did the rename — which is why the server half was never the
blocker.

Only come back to this page if one of these is true:

- **the key was exposed** — committed, pasted into a chat, in a screenshot. Then
  generate a new one here and revoke the old from the Google Cloud console;
- **it belongs to a different Firebase project than the Android apps do.** Then
  nothing would ever be delivered, because the credential would be signing for
  one project and the devices registered in another.

To check the second: the credential is a JSON document with a `project_id`
field, and it has to read `headhunter-app-b463f`. Decode it locally — never
into a chat or a shared log:

```powershell
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($env:FCM_SERVICE_ACCOUNT_BASE64)) |
  ConvertFrom-Json | Select-Object project_id, client_email
```

**This one is a secret** wherever it lives. It can send a push to any device
registered to the project.

### 2.4 Check that the API is on

**Project settings → Cloud Messaging** → *Firebase Cloud Messaging API (V1)*
should read **Enabled**. It is on by default for any project created in recent
years, and this backend uses only V1. The *legacy* API on the same page is
deprecated and is not used; leave it disabled.

---

## 3. The server, which is already configured

`FCM_SERVICE_ACCOUNT_BASE64` is set. There is nothing to do here, and the boot
log is how you confirm it:

- **variable set** — nothing is logged, and pushes go over FCM HTTP v1;
- **variable empty** — `FCM_SERVICE_ACCOUNT_BASE64 is not set: notifications
  are stored and read in-app, but no push is delivered`.

So the server has been ready to send for as long as it has been configured, and
has been sending to nobody: there is no device token to address, because the app
cannot obtain one. **§2 is the whole of the remaining configuration work.**

### If it ever has to be set again

The backend takes the service-account JSON base64-encoded, in one variable.
Base64 because the document is multi-line and its private key contains
newlines, which `.env` files handle badly enough that most failures would be
quoting mistakes.

**This is a Windows machine and `base64` is not a command here.** PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:path	oservice-account.json"))
```

Copy the whole line — it is long, and a truncated value fails at boot rather
than at the first push, which is the good direction. Then delete the downloaded
`.json`: the value lives in `.env` now.

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

1. The API boots without the `FCM_SERVICE_ACCOUNT_BASE64 is not set` warning —
   which it already does.
2. A development build signs in and `notification_devices` gains a row for that
   phone. **This is the step that has never happened**, and everything else
   follows from it.
3. Somebody sends the signed-in candidate a message from an employer account,
   the phone is locked, and a banner appears.
4. Tapping the banner opens that conversation rather than the app's home.

If 1–2 work and 3 does not, the problem is on the device (Play services, or the
notification permission having been refused), not in the configuration — check
the in-app centre, which will have the notification either way.
