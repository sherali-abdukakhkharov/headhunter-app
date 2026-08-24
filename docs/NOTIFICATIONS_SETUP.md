# Push notifications

**Status: configured and implemented, 2026-08-24.** Nothing on this page is
waiting on anybody. It is kept because the next person to touch Firebase — a
fourth flavor, a second project, a device that stops receiving — needs to know
what identifies what, and that is the part nobody guesses correctly.

§9.2's notifications have two halves and they are independent by design:

- **the in-app centre** — every notification is written to the database, listed
  in the app, counted by the badge and filtered by the per-category switches,
  whether or not a push was ever delivered;
- **push** — a copy of that, addressed to a device.

A push is a *message about* something that happened, so it must never be able to
prevent the thing from happening. That is what let the in-app half ship on its
own while push was blocked, and it is why a phone with no Google Play services
is a degraded install rather than a broken one.

---

## 1. What was blocked, and what it turned out to be

The product was renamed on 2026-08-19 and the Android application id changed
with it. Firebase identifies an app by its package name, **a package name cannot
be renamed there**, and `android/app/google-services.json` is the file the SDK
reads at startup to find out which app it is. Under `com.jobbridge.app` it found
no entry, refused to initialise, and produced no token — so
`POST /notifications/devices` had nothing to register and no push was ever
addressed to a phone.

Nothing failed. A token simply never arrived, which is the worst shape a
configuration bug can take.

**The fix was three new apps in the console, and nothing else.** In particular
it was *not* the server credential, which is the thing everybody reaches for:

> A service account authenticates the Firebase **project**, not an app. There is
> no package name anywhere in it. `FCM_SERVICE_ACCOUNT_BASE64` was set on
> 2026-08-07 and stayed valid through the rename and through the registration of
> three new apps. The server had been ready to send that whole time, with no
> device to send to.

Only `google-services.json` is per-app. When something looks broken after a
rename, the question to ask is **what does this credential actually identify**.

---

## 2. What the file contains now

`android/app/google-services.json` lists **six** Android apps in project
`headhunter-app-b463f`:

| Package name | Why it is there |
|---|---|
| `com.jobbridge.app` | production |
| `com.jobbridge.app.dev` | development |
| `com.jobbridge.app.staging` | staging (§12.1's "testing") |
| `com.headhunter.app` | pre-rename, kept |
| `com.headhunter.app.dev` | pre-rename, kept |
| `com.headhunter.app.staging` | pre-rename, kept |

**One file covers all three flavors**: a download contains a `client` entry for
every Android app in the project, and the Gradle plugin picks the one matching
the id being built. So there is deliberately no per-flavor copy under
`src/development/` — a second copy is a second thing to forget.

The old three are kept because deleting them buys nothing: one download returns
every app in the project regardless, and they identify builds that may still be
installed on somebody's phone.

### It is not in the repository — one owner action is outstanding

`android/.gitignore` keeps it out. Google does not treat the API key inside it as
a secret and it ships in every APK, but GitHub's scanner flagged it on
2026-08-07 and this repository keeps credential-shaped files out, alongside the
keystore. So it is **supplied per machine**, and two things follow:

- **a fresh clone cannot build Android** until you download it from the console;
- **CI needs it as a repository secret**, because the google-services Gradle
  plugin now refuses the build without it.

> **Do this once:** add a repository secret named
> **`GOOGLE_SERVICES_JSON_BASE64`** holding the base64 of the file. Until it
> exists, `app-ci.yml`'s Android job and `release-apk.yml` fail with an error
> naming it, and the Firebase configuration checks in `push_test.dart` skip.
>
> ```powershell
> [Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\google-services.json")) | Set-Clipboard
> ```
>
> Then GitHub → the repository → **Settings → Secrets and variables → Actions →
> New repository secret**. Same shape as `ANDROID_KEYSTORE_BASE64`, which
> `release-apk.yml` already uses.

Unlike the keystore and the service account, **this value is not sensitive** —
it is recoverable from any APK with `unzip`. It is a secret here only to keep
the scanner quiet.

### Registering a fourth flavor

Firebase console → project **headhunter-app-b463f** → ⚙ **Project settings** →
**General** → **Add app** → Android:

- **Android package name** — exactly the `applicationId` Gradle builds.
- **Debug signing certificate SHA-1** — **leave it empty.** Push does not use
  it. SHA fingerprints are for Google Sign-In, Dynamic Links and App Check, and
  this product has none of those. All six existing apps have no fingerprint.
- Skip every SDK instruction the wizard shows. The Gradle and Dart sides are
  already done, and the wizard's version numbers fight the dependency pinning in
  `pubspec.yaml`.

Then **Project settings → General → Your apps → google-services.json** and
replace the file wholesale. **Do not hand-edit it**: Firebase issues a
`mobilesdk_app_id`, an `api_key` and a `client_id` per package name, so editing
only `package_name` yields a file the build accepts and the device rejects.

### It now fails loudly

A flavor with no entry **fails the build** — `No matching client found for
package name` — because `com.google.gms.google-services` is applied. And
`test/features/notifications/push_test.dart` derives the ids from
`build.gradle.kts` and fails sooner still, without Gradle.

---

## 3. The server

`FCM_SERVICE_ACCOUNT_BASE64` is set in `headhunter-backend/.env`. There is
nothing to do, and the boot log is how you confirm it:

- **set** — nothing is logged, and pushes go over FCM HTTP v1;
- **empty** — `FCM_SERVICE_ACCOUNT_BASE64 is not set: notifications are stored
  and read in-app, but no push is delivered`.

Cloud Messaging API (V1) must read **Enabled** under **Project settings → Cloud
Messaging**. It is on by default and this backend uses only V1; the legacy API
on the same page is deprecated and unused.

### When it *would* need regenerating

Only two cases:

- **the key was exposed** — committed, pasted into a chat, in a screenshot.
  Generate a new one and revoke the old from the Google Cloud console.
- **it belongs to a different Firebase project than the Android apps.** Nothing
  would ever be delivered: the credential signs for one project and the devices
  are registered in another. To check, `project_id` must read
  `headhunter-app-b463f`. Decode it locally — never into a chat or a shared log:

```powershell
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($env:FCM_SERVICE_ACCOUNT_BASE64)) | ConvertFrom-Json | Select-Object project_id, client_email
```

**This one is a secret** wherever it lives. It can send a push to any device
registered to the project.

---

## 4. What the app does

- `firebase_core` and `firebase_messaging` in `pubspec.yaml`. Both were checked
  against the Kotlin Gradle Plugin rule (CLAUDE.md) before being added and are
  clean — `com.android.library` with Java sources — and neither moves anything
  in the analyzer-12 pinning.
- The `com.google.gms.google-services` Gradle plugin, 4.5.0 (this project is on
  AGP 9).
- `POST_NOTIFICATIONS` in the manifest, requested **at sign-in** rather than at
  first launch, so the dialog has a reason a user can see. Registration does not
  depend on the answer: permission decides whether a banner is *shown*, and
  somebody who turns notifications on later in system settings should not have
  to sign out and back in.
- A notification channel at `IMPORTANCE_HIGH`, created over the app's own
  `/push` MethodChannel — `flutter_local_notifications` applies the Kotlin
  Gradle Plugin, and the channel's **name is a translated string**, because
  §2.4's four interface variants are chosen inside the app rather than by the
  phone's locale.
- `res/drawable/ic_notification.xml`, because a small icon is an alpha mask on
  API 21+ and the fallback — the launcher icon — is an opaque navy plate that
  would render as a solid white square.
- Token registration after sign-in and after every rotation, and
  `DELETE /notifications/devices/:token` **before** sign-out clears the
  credentials. A token identifies an app installation rather than a person, so
  re-registering one moves it — which is what a resold or shared phone needs.
- Tap routing through the same table the in-app rows use, held until the session
  resolves when the tap is what launched the app.

---

## 5. What still will not work, and is nobody's fault

FCM needs **Google Play services**. A Huawei phone sold after 2019 does not have
it. Those users get no banner and lose nothing else: the in-app notification
centre is the record, and it is complete for everyone.

---

## 6. How to tell it worked

1. The API boots without the `FCM_SERVICE_ACCOUNT_BASE64 is not set` warning.
2. A development build signs in and `notification_devices` gains a row for that
   phone. **This is the step that had never happened**, and everything else
   follows from it.
3. Somebody sends the signed-in candidate a message from an employer account,
   the phone is locked, and a banner appears — with the mark as its icon, not a
   white square.
4. Tapping the banner opens that conversation rather than the app's home.
5. Signing out and sending again delivers nothing to that phone.

If 1–2 work and 3 does not, the problem is on the device — Play services, or the
notification permission having been refused — not in the configuration. Check
the in-app centre, which will have the notification either way.
