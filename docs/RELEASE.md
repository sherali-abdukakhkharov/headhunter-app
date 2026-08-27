# Releasing an APK

Android only — iOS is out of scope (see [CLAUDE.md](../CLAUDE.md)).

> **Every command here is PowerShell**, for Windows. Three habits from
> Unix/bash guides do not work in Windows PowerShell 5.1 and will bite:
> `&&` is a **parser error**, `<` input redirection is **not supported**, and `\`
> is not a line-continuation character (the backtick `` ` `` is). `base64`, `rm`
> and `cat` are also not commands here.
>
> The bash in `.github/workflows/release-apk.yml` is correct and must stay bash —
> that runs on a `ubuntu-latest` GitHub runner, not on your machine.

**Cost:** this repository is **public**, and GitHub Actions on standard runners is
free with unmetered minutes for public repositories. So there is nothing to
optimise here — if a run refuses to start, it is an account or billing block, not
this workflow spending anything. See "Releasing by hand" below for the way round
it, which needs no Actions at all.

Push a version tag and GitHub builds a signed production APK and attaches it to a
release. The download link never changes, so the README needs no edit per release:

```
https://github.com/sherali-abdukakhkharov/headhunter-app/releases/latest/download/jobbridge.apk
```

The asset was called `headhunter.apk` up to and including **v1.1.0**, and the
rename kept both names — the same bytes — so links shared before it kept
resolving. **Dropped in v1.24.0**, after twenty-two releases had carried both:
its own condition was that one release carry both, and a link nobody updated in
twenty-two is one nobody is following. Only `jobbridge.apk` is attached now.

```powershell
git tag v1.0.1
git push origin v1.0.1
```

Two statements on two lines, deliberately — `git tag v1.0.1 && git push …` fails
to parse. To chain on one line, use `;` for unconditional or `if ($?)` to push
only when the tag succeeded:

```powershell
git tag v1.0.1; if ($?) { git push origin v1.0.1 }
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
> never be updated — a new key means a new listing — and even for direct
> download every tester has to uninstall before the next build will install,
> because Android refuses an update whose signature changed.
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

Four secrets. `gh` is **not installed on this machine**, so the browser is the
path of least resistance — and the keystore never has to touch a temporary file.

Copy the base64 straight to the clipboard (PowerShell, from the repository root):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('android\upload-keystore.jks')) | Set-Clipboard
```

One line, no trailing newline, nothing written to disk to clean up afterwards.
Then open **Settings → Secrets and variables → Actions → New repository secret**
and paste it as:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | the clipboard contents from above |
| `ANDROID_KEYSTORE_PASSWORD` | the store password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | the same as the store password |

Direct link: `https://github.com/sherali-abdukakhkharov/headhunter-app/settings/secrets/actions`

To sanity-check what you copied before pasting — it should print 2980 and True:

```powershell
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes('android\upload-keystore.jks'))
$b64.Length
$b64 -notmatch '\s'
```

<details>
<summary>If you install the <code>gh</code> CLI later</summary>

```powershell
winget install --id GitHub.cli
```

Note the pipe rather than `<`: PowerShell does not support input redirection,
so `gh secret set NAME < file` is a syntax error.

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('android\upload-keystore.jks')) |
  gh secret set ANDROID_KEYSTORE_BASE64

gh secret set ANDROID_KEY_ALIAS --body upload
gh secret set ANDROID_KEYSTORE_PASSWORD   # prompts
gh secret set ANDROID_KEY_PASSWORD        # prompts
```

</details>

The workflow **fails fast** if any of these is missing, rather than falling back
to debug signing. The fallback in `build.gradle.kts` is a warning, not an error,
so without this check a run would go green and publish an APK signed with the
debug key — one that installs fine on a clean phone and then blocks every future
update, since Android will not install over a changed signature.

### 3. The API base URL — optional now

**You can skip this.** `AppFlavor.production` points at the live backend,
`https://hh.qitmir.uz`, so a release build already talks to the right place.
Verified 2026-08-05: `GET /health` answers 200 over HTTPS and the name resolves
on Google, Cloudflare and Quad9 DNS. What a downloaded build actually needs from
that deployment now is `POST /auth/otp/send` — sign-in is phone + OTP (§4.1) —
and that in turn needs an SMS provider, which is the open item below.

Set the variable only to point a build somewhere else without editing code. It is
a repository **variable**, not a secret — it is a hostname, and §12.5 keeps
secrets out of the binary entirely.

**Settings → Secrets and variables → Actions → Variables → New repository
variable**, named `API_BASE_URL`.

Direct link: `https://github.com/sherali-abdukakhkharov/headhunter-app/settings/variables/actions`

Or, with `gh` installed:

```powershell
gh variable set API_BASE_URL --body https://api.staging.headhunter.uz
```

Resolution order in the workflow: the manual `api_base_url` input, then this
variable, then `AppFlavor.production`'s own default (`https://hh.qitmir.uz`,
which is live). If none is set the build still succeeds and logs a warning
naming the default it used.

### 4. What a downloaded build still needs: an SMS provider

Nothing about signing — a signed APK signs people in as soon as the backend can
send a code. Until an SMS provider is connected the backend issues a fixed
`OTP_STATIC_CODE`, and it **refuses to boot with that set when
`NODE_ENV=production`** — so a production deploy fails at startup, loudly, rather
than shipping a master key. That is the one thing standing between a release
build and a stranger being able to use it.

> **There is no BotFather step, and there never will be unless Telegram login is
> revived.** It was deprecated on 2026-08-05 and the client code was deleted on
> 2026-08-19, `AppFlavor.telegramRedirectUri` with it. Sign-in is phone + OTP
> (§4.1, UAT-01), which binds to no certificate, so the release key needs
> registering nowhere. The fingerprint mechanics — a redirect URI bound to one
> application id *plus* one signing certificate — are in
> [TELEGRAM_LOGIN.md](TELEGRAM_LOGIN.md), which is where they belong if anyone
> ever asks for the feature back.

### Printing a signing fingerprint

Needed to compare a build against the table above, not for any registration.
`keytool` is not on `PATH`; it ships inside Android Studio's bundled JBR:

```powershell
$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
& $keytool -list -v -keystore android\upload-keystore.jks -alias upload
```

`gradlew signingReport` lists every variant's certificate at once, which is the
faster way to see that a flavor is signed with the key you think it is:

```powershell
Push-Location android
try { & ./gradlew.bat signingReport } finally { Pop-Location }
```

---

## Releasing by hand, when Actions cannot run

A locked GitHub account, a billing block, or a spending limit disables Actions —
but **not** Releases. Uploading the APK yourself produces the identical download
URL, so the README link and anything already sharing it keep working.

Build and stage it under the exact name the permanent link expects:

```powershell
flutter build apk --release --flavor production --dart-define=FLAVOR=production
New-Item -ItemType Directory -Force dist | Out-Null
Copy-Item build\app\outputs\flutter-apk\app-production-release.apk dist\jobbridge.apk -Force
```

Confirm it carries the **release** key before uploading — see the next section.
This matters more than it sounds: a release build falls back to debug signing
when `android/key.properties` is missing, with only a warning in the build log,
and the APK installs perfectly well — then refuses to be updated by a correctly
signed one, on every phone that took it.

```powershell
git tag v1.0.1
git push origin v1.0.1
```

Then **Releases → Draft a new release**, pick that tag, and attach the file.
The name must be exact — the permanent URL is `latest/download/jobbridge.apk`,
and a different name breaks it.

`dist/` is gitignored: a 60 MB binary belongs in a release attachment, never in
git history, where it cannot be removed without a rewrite.

When Actions is available again the tag-triggered workflow does all of this,
including the SHA-256 in the release notes. Nothing needs undoing.

---

## Checking a downloaded APK

Confirm a release APK really carries the release key and not a debug one — the
expected SHA-256 digest is `7c1cc81cfc5564f6563ebab3fe714e0e2ac32f18173f3609f786a09dffc5421f`:

```powershell
$apksigner = Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Recurse -Filter apksigner.bat |
  Select-Object -First 1 -ExpandProperty FullName
& $apksigner verify --print-certs jobbridge.apk
```

`keytool -printcert -jarfile` does **not** work here: the APK is signed with
scheme v2/v3 only and has no v1 JAR signature, so that command prints nothing and
looks like a failure.

Application id and launcher name:

```powershell
$aapt = Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Recurse -Filter aapt2.exe |
  Select-Object -First 1 -ExpandProperty FullName
& $aapt dump badging jobbridge.apk | Select-String "^package:|^application-label:"
```

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
