# Releasing an APK

Android only — iOS is out of scope (see [CLAUDE.md](../CLAUDE.md)).

Push a version tag and GitHub builds a signed production APK and attaches it to a
release. The download link never changes, so the README needs no edit per release:

```
https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest/download/headhunter.apk
```

```sh
git tag v1.0.1
git push origin v1.0.1
```

`.github/workflows/release-apk.yml` does the rest. It can also be run by hand from
the Actions tab to get an APK without cutting a release — that run uploads a build
artifact instead of publishing.

---

## One-time setup

### 1. The keystore

`android/upload-keystore.jks` was generated on 2026-08-05 and is **gitignored**
(`android/.gitignore` covers `**/*.jks` and `key.properties`).

> **Back this file up somewhere you will not lose it, along with its password.**
> It is not recoverable. If it is lost, a Play Store listing signed with it can
> never be updated — a new key means a new listing — and every Telegram login
> breaks until a new fingerprint is registered with BotFather.
>
> A password manager entry plus an encrypted copy off this machine. Not just the
> laptop it was made on.

| | |
|---|---|
| Alias | `upload` |
| Type / algorithm | JKS, RSA 2048 |
| Valid until | 2053-12-21 |
| SHA-256 | `7C:1C:C8:1C:FC:55:64:F6:56:3E:BA:B3:FE:71:4E:0E:2A:C3:2F:18:17:3F:36:09:F7:86:A0:9D:FF:C5:42:1F` |

### 2. Repository secrets

Four, from the repository root:

```sh
# base64 of the keystore, on one line
base64 -w0 android/upload-keystore.jks > keystore.b64      # macOS: base64 -i ... -o ...
gh secret set ANDROID_KEYSTORE_BASE64 < keystore.b64
rm keystore.b64

gh secret set ANDROID_KEYSTORE_PASSWORD      # paste the store password
gh secret set ANDROID_KEY_ALIAS --body upload
gh secret set ANDROID_KEY_PASSWORD           # same as the store password
```

The workflow **fails fast** if any of these is missing, rather than falling back
to debug signing. That fallback would produce an APK that installs happily and
then cannot complete a Telegram login, because its fingerprint is not the one
registered with BotFather.

### 3. The API base URL

A repository **variable**, not a secret — it is a hostname, and §12.5 keeps
secrets out of the binary entirely:

```sh
gh variable set API_BASE_URL --body https://api.staging.headhunter.uz
```

Resolution order in the workflow: the manual `api_base_url` input, then this
variable, then `AppFlavor.production`'s own default
(`https://api.headhunter.uz`). If none is set the build still succeeds and logs a
warning — worth knowing, because that host does not exist yet.

### 4. Register the release fingerprint with BotFather

**Telegram login will not work in a downloaded APK until this is done.** Telegram
binds a redirect URI to one application id *plus one signing certificate*, and the
release keystore above is a different certificate from the debug one used so far.

In @BotFather → your bot → Login Widget, add an Android app registration for:

| | |
|---|---|
| Package name | `com.headhunter.app` |
| SHA-256 | `7C:1C:C8:1C:FC:55:64:F6:56:3E:BA:B3:FE:71:4E:0E:2A:C3:2F:18:17:3F:36:09:F7:86:A0:9D:FF:C5:42:1F` |

BotFather returns an app id; put its redirect URI into
`AppFlavor.production.telegramRedirectUri`, which is empty today, and add a
`android/app/src/production/AndroidManifest.xml` with the matching App Link host —
copy the shape of the `development` one.

Until that is done, a downloaded APK runs but the login button reports that
Telegram sign-in is unavailable in this build. That is deliberate: the Dart side
refuses to start a login it knows Telegram will reject.

---

## Versioning

`pubspec.yaml`'s `version: 1.0.0+1` supplies `versionName` and `versionCode`.
Bump it in the same commit as the tag, and keep the tag and the version in step —
nothing enforces it:

```yaml
version: 1.0.1+2   # versionName 1.0.1, versionCode 2
```

`versionCode` must **increase** for a device to treat the build as an upgrade
rather than refusing to install it.

## If Play Store distribution happens later

This keystore works as the Play **upload** key. Prefer Play App Signing, which
means Google holds the distribution key and this one only signs uploads — losing
it then costs a key rotation rather than the listing. Note that Play App Signing
introduces a *third* SHA-256 (Google's), which also has to be registered with
BotFather, or login breaks for store installs only.

Play also wants an **app bundle** rather than an APK
(`flutter build appbundle --flavor production`). The APK here is for direct
download, which is what this workflow is for.
