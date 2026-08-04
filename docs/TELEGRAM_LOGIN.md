# Log in with Telegram — research and implementation plan

**Status:** Android implementation in progress. Client direction 2026-08-05: the
MVP signs in with Telegram; **phone + OTP is deferred, not deleted.**

> **iOS is out of scope** (owner direction, 2026-08-05) — Android only until asked
> otherwise. The iOS notes below are kept because the research is correct and will
> be needed if that reverses; **do not act on them.** The iOS CI job is
> `workflow_dispatch`-only for the same reason.

Audience is both repos — the client work is in `headhunter-app`, the token
validation and session issuing in `headhunter-backend`. Read
[ARCHITECTURE.md §3](../ARCHITECTURE.md) first for the role shell the session
feeds.

---

## 1. What any solution here has to satisfy

These are not preferences; three of them are in the approved specification and
one is a consequence of work already shipped.

| Constraint | Source | Consequence |
|---|---|---|
| **A verified phone number is required to use authenticated functions** | **BR-01** | Telegram identity **alone is not sufficient**. Whatever we build must end with a phone number the platform can treat as verified. This is the single biggest constraint and it eliminates the naive "just take the Telegram user id" design. |
| Employers contact candidates by phone; the profile stores one | §5.1, §6.1, BR-09 | The phone is product data, not only an auth factor. It cannot be optional. |
| Registration ends in role selection, then role onboarding | §4.1 step 5, §2.3 | The response must tell the client whether the account is new and which roles it holds. **The backend already does this** — see §5. |
| Language is chosen *before* registration | §3.2 | Already shipped. The sign-in call must carry the chosen locale so server text matches. |
| Three flavors, three application ids | shipped M0.5 | Each application id needs its **own** registration with BotFather. See §7 — this is the step most likely to be missed. |
| UAT-01 says "registers by phone and OTP" | §13.1 | **The acceptance test contradicts this change.** UAT-01 and BR-01's wording need the client's written sign-off. Flagged in §9. |

---

## 2. The three mechanisms that actually exist

Telegram offers three distinct things that get called "Telegram login". They are
not variants of one feature and they have different security models.

### A. Log in with Telegram — the OIDC widget *(recommended)*

Telegram replaced the old iframe/hash widget with a **standard OpenID Connect
authorization-code flow**, and now ships **first-party native SDKs** for iOS and
Android. The legacy hash-based widget still works but its documentation is
archived.

| | |
|---|---|
| Authorization endpoint | `https://oauth.telegram.org/auth` |
| Token endpoint | `https://oauth.telegram.org/token` |
| Discovery / keys | `/.well-known/openid-configuration`, `/.well-known/jwks.json` |
| Client registration | @BotFather → your bot → **Login Widget** → Client ID + Client Secret |
| PKCE | supported, S256, recommended |
| Result | an **ID token (JWT)** signed by Telegram |

Scopes and what they return:

| Scope | Claims |
|---|---|
| `openid` (required) | `sub`, `iss`, `iat`, `exp` |
| `profile` | `id`, `name`, `preferred_username`, `picture` |
| `phone` | `phone_number`, `phone_number_verified` |
| `telegram:bot_access` | permission for the bot to message the user |

**Why this is the recommendation: the `phone` scope satisfies BR-01 directly.**
Telegram will only ever hold a phone number it verified itself at account
registration, so a `phone_number` claim inside a token Telegram signed is a
verified phone number — at no SMS cost. Telegram's own documentation frames it
exactly that way ("removing the need for expensive verification codes").

The native SDKs return the **`idToken` directly** to the app and require only the
`client_id`; the **Client Secret never goes into the app**, which is what makes
this safe for a mobile client. The token exchange that *does* need the secret
(HTTP Basic) is not something the app performs.

### B. Bot deep link + one-time nonce

No SDK. The app opens `https://t.me/<bot>?start=<nonce>`, the user presses Start,
the bot's backend receives `/start <nonce>`, and the app learns the outcome by
polling. The start parameter allows `A-Z a-z 0-9 _ -`, **max 64 characters**, so
base64url of a 32-byte nonce fits.

The phone comes from a `KeyboardButton` with `request_contact: true`, which is
available **in private chats only** and returns a `Contact` carrying
`phone_number`, `first_name`, `last_name`, `user_id` and `vcard`. Because the
account's number is verified by Telegram at registration, this is also a verified
number — **provided the bot checks `message.contact.user_id == message.from.id`.**
Without that check a user can forward *somebody else's* contact card and register
against a number they do not control. That check is the whole security of this
option.

### C. Telegram Gateway — verification codes over Telegram instead of SMS

Not a login mechanism: a **delivery channel** for the OTP flow that already
exists. ~**$0.01 per delivered code**, around 50× cheaper than SMS, delivered
instantly, and you pay only for codes actually delivered. `checkSendAbility`
tests whether a number can receive a Telegram message at all.

Worth knowing precisely: the Gateway **does not** prove a phone belongs to a
Telegram account — the service supplies the number and Telegram delivers a code to
it. The verification still comes from the user typing the code back.

---

## 3. Recommendation

**Primary: A (OIDC + native SDKs) with `scopes = [openid, profile, phone]`.**
It is the officially supported path, it is one tap, and it settles BR-01 without
sending a single SMS.

**Keep two fallbacks, and do not delete either:**

1. **The user declines the `phone` scope**, or the token arrives without
   `phone_number_verified`. Then the account exists but cannot pass BR-01, so the
   client must route into a phone-verification step. That step is the **existing
   OTP flow**, which is why the backend's OTP module stays exactly where it is —
   switching its delivery to **C (Gateway)** later is a backend-only change.
2. **Telegram is not installed.** The OIDC flow degrades to the browser
   (`oauth.telegram.org`), where the user signs into Telegram Web. Verify this on
   a clean device during the spike — it is the assumption most likely to be wrong,
   and if it fails, **B** becomes the fallback.

**Deliberately not chosen:** the legacy hash-based widget in a WebView. It needs
`/setdomain`, it authenticates by an HMAC over a `data_check_string` rather than a
signed JWT, and it is documented as archived. Building a new MVP on it in 2026
buys a migration.

---

## 4. Client work (`headhunter-app`)

### 4.1 The dependency decision, which is not obvious

The official SDKs are not both freely resolvable:

- **Android:** `org.telegram:login-sdk` lives on **GitHub Packages and requires a
  GitHub personal access token with `read:packages`**. Building the app would need
  that credential on every developer machine **and in CI** — a new secret in the
  release path, which is exactly the kind of thing §12.5 asks us to keep small.
- **`io.khode:telegram-login-sdk` on Maven Central is a community fork** of the
  official SDK, published to dodge that credential. The `telegram_login` Flutter
  package (khode.io, v1.2.1, ~5 likes, ~600 weekly downloads) wraps that fork.

So the choices are: a build-time GitHub credential, or a **third-party fork of the
library that guards every account in the product**. Neither is free, and this is a
decision to make deliberately rather than by reaching for the first pub.dev
result.

**Recommendation:** write **our own thin platform channel** over the official iOS
Swift package and the official Android artifact, and take the GitHub Packages
credential in CI. The surface we need is one method and one callback — `login()`
returning an `idToken` — which is far less code than the risk of a low-adoption
wrapper around a forked auth SDK. Reassess if the spike shows the official Android
artifact reaching Maven Central.

### 4.2 Platform floors

| | Required | This project today | Action |
|---|---|---|---|
| Android | API 23 | `flutter.minSdkVersion` (24 on Flutter 3.44) | none |
| iOS | 15.0 | 13.0 (`IPHONEOS_DEPLOYMENT_TARGET`) | **none — iOS out of scope** |

The iOS floor is *not* being raised: iOS is out of scope, so the project stays at
Flutter's default 13.0 and the iOS CI job is `workflow_dispatch`-only. Raising it
would drop iOS 13/14 devices, which is a product decision to take at the point
iOS is actually wanted — not a side effect of adding a login.

### 4.3 Shape of the client change

The redirect chain and session model built in M0.5 need **no structural change**
— this replaces the *acquisition* seam already marked in `SessionController`:

```
OnboardingScreen  (language chosen — already live)
  └─ "Log in with Telegram"
       └─ TelegramLogin.login()          → idToken (JWT)
            └─ POST /auth/telegram        { idToken, locale, device… }
                 ├─ verified phone present → SessionActive(roles) → shell
                 ├─ no roles yet           → /role-selection  (already built)
                 └─ no verified phone      → phone-verification step (OTP)
```

- `signInAsDevelopmentRole` is replaced by the real call; the `/_dev` scenarios
  stay, because they are how the redirect chain is exercised without a network.
- Terms and privacy acceptance (§4.1 step 2) still has to appear **before** the
  login call — Telegram does not collect it for us.
- The `idToken` is a bearer credential in transit: never log it (`debugPrint`
  included), and do not persist it. Only the session tokens go to `TokenStore`.

---

## 5. Backend work (`headhunter-backend`)

The backend is further along than the app: `src/modules/auth` already implements
OTP send/resend/verify, session creation, **rotating refresh with reuse
detection**, `logout`, `logout-all`, session listing and revocation,
`POST /auth/roles` and `POST /auth/active-role`. None of that is wasted.

What is new is **one endpoint** that produces the same
`AuthTokensResponseDto` the OTP path already returns:

```
POST /auth/telegram      (@Public, rate limited)
  body:  { idToken, locale?, deviceFingerprint?, deviceName?, platform?, appVersion? }
  200:   AuthTokensResponseDto   ← unchanged shape: accessToken, refreshToken,
                                   expiresInSeconds, roles, activeRole, isNewUser
```

Reusing that DTO is the point: the client's session handling, the role-selection
redirect and `isNewUser` routing all keep working untouched.

Validation, in order, all mandatory:

1. Fetch and **cache** Telegram's JWKS; verify the **signature**.
2. `iss == https://oauth.telegram.org`.
3. `aud` matches our **bot id**.
4. `exp` not passed (and `iat` not implausibly old — treat the token as
   single-use and short-lived).
5. Read `sub`/`id` → the Telegram user id. This is the account key.
6. If `phone_number_verified` is true, take `phone_number`, normalise it through
   the existing `normalizePhone`, and mark the phone verified. Otherwise create
   the account **without** a verified phone and let the response drive the client
   into phone verification.

Data model: add `telegram_user_id` (unique) to users, and keep `phone` nullable
**until** verified. Two edge cases that need a decided answer before coding:

- **A Telegram account whose phone matches an existing OTP-registered user** →
  link them, do not create a second account. Uzbekistan users will have both paths
  available during the transition.
- **A user changes their phone number in Telegram** → the next login presents a
  new `phone_number` for a known `telegram_user_id`. Re-verification is required
  (§4.2 already asks for "additional confirmation for a phone-number change").

---

## 6. Security requirements

- **The Client Secret never ships in the app.** The native SDKs return the
  `idToken` and need only `client_id`; the secret belongs to the backend, which is
  the only party that would ever call the token endpoint.
- **The backend never trusts the app's word about identity.** The only accepted
  input is a JWT that Telegram signed; a `telegram_user_id` sent as a plain field
  would let anyone impersonate anyone.
- **Treat the `idToken` as single-use.** Record the `jti`/`sub`+`iat` briefly and
  reject replays.
- Rate-limit `/auth/telegram` with the existing `@RateLimit('auth')`.
- If option **B** is ever used, `message.contact.user_id == message.from.id` is
  not optional — see §2B.
- Never log the token, the phone number in full, or the OTP.

---

## 7. BotFather registration interacts with the flavors

This is the step most likely to be missed, and it fails at *runtime*, per
environment, not at build time.

Registration is **per application id**, and M0.5 gave us three:

| Flavor | Application id | Needs |
|---|---|---|
| development | `com.headhunter.app.dev` | own registration + debug SHA-256 |
| staging | `com.headhunter.app.staging` | own registration + its signing SHA-256 |
| production | `com.headhunter.app` | own registration + **Play App Signing** SHA-256 |

Also:

- Android registration takes the **package name and SHA-256 signing
  fingerprint**. Debug, upload and Play-App-Signing certificates have **different**
  fingerprints — all of the ones we use must be registered, or login fails only in
  the environment nobody tested.
- iOS takes the **bundle id and Apple Team ID**, with Associated Domains
  (`applinks:` and `webcredentials:`).
- BotFather returns a redirect domain of the form `app{CLIENT_ID}-login.tg.dev`,
  used as the App Link / Universal Link target.
- **Use separate bots per environment** (a dev bot and a production bot). One bot
  across environments means a staging build can complete a login against
  production identity, and the bot's display name is what the user sees on the
  consent screen.

---

## 7a. Verified on an Android emulator, 2026-08-05

The spike in §8 step 1 is done, and it was done against the real Telegram, not a
stub. What the run proves, and what it does not.

**Confirmed working.** The SDK produced this authorization request, recovered from
`adb shell dumpsys activity activities`:

```
https://oauth.telegram.org/auth
  ?client_id=8565299674
  &response_type=code
  &scope=openid%20profile%20phone
  &redirect_uri=https%3A%2F%2Fapp1562839855-login.tg.dev%2Ftglogin
  &code_challenge=Uv88SIBdf8QNZ4rQDiWltiv2amLRGHdFz-AtBX335Yw
  &code_challenge_method=S256
```

Which settles four things that were assumptions until now:

1. **The `phone` scope is sent.** It is in the request, so nothing on our side is
   dropping it.
2. **PKCE S256 is used by the SDK**, confirming the app needs no client secret —
   §6's central security claim.
3. **The redirect URI matches BotFather byte for byte**, `/tglogin` included.
   Telegram accepted it and served the consent page; a mismatch is refused
   outright, so this is a real check.
4. **The browser fallback works.** The emulator has no Telegram installed and the
   flow still reached the consent screen in a Chrome Custom Tab, offering both
   "Continue with Telegram" and "Or log in with a phone number". This was the
   path §3 flagged as most likely to be wrong; it is not.

**The open question, and it is the important one.** The consent screen reads:

> "The website will receive your **Name**, **Username** and **Profile Photo**."

**It does not mention the phone number** — even though the scope was requested.
Three possible explanations, in decreasing likelihood:

- Telegram discloses and asks for the phone **after** "Continue with Telegram", as
  a separate opt-in. That matches its documented "phone number sharing requires
  explicit user consent".
- The **bot must have the `phone` scope enabled** in BotFather's Login Widget
  settings, separately from requesting it.
- The scope is silently ignored for this bot.

This matters more than anything else in this document: **BR-01 requires a verified
phone number and the backend refuses a login without one**, so if the phone never
arrives, every login fails at our own server. It cannot be settled from this
machine — completing the flow needs a real Telegram account. **Whoever finishes
the first real login should check the decoded `id_token` for `phone_number` and
`phone_number_verified`.**

**Not yet verified:** the full round trip. The `id_token` → `POST /auth/telegram`
→ session → shell path has never run, because no login has completed.

**Also found:** the locally running backend returned **404** for
`POST /auth/telegram` while the route exists in its source (`@Post('telegram')` in
`auth.controller.ts`). That process was started before the Telegram module landed
— it needs a restart, not a fix.

## 8. Implementation order

1. ~~Spike~~ — **done, see §7a.** The browser fallback works and the scope is
   sent; whether the phone comes back is still open.
2. ~~Backend: `POST /auth/telegram`, JWKS verification, `telegram_user_id`~~ —
   **done in headhunter-backend**, with 22 integration tests. The route 404s on a
   stale dev process; restart it.
3. ~~Client: login button, wire call, terms acceptance before login~~ — **done.**
   `TelegramSignIn` → `AuthRepository.signInWithTelegram` →
   `SessionController.signInWithTelegram`, with consent gating the button.
4. **Next: complete one real login** on a device with a Telegram account, and
   check the decoded token for `phone_number_verified` (§7a).
5. **Then: the no-verified-phone branch** into the OTP screens — only worth
   building once step 4 says whether it is the common path or the rare one.
6. Update UAT-01 evidence once the client signs off on §9.

*(iOS is out of scope — see the note at the top.)*

## 9. Decisions needed from the client, before step 2

1. **BR-01 and UAT-01 name phone + OTP.** Telegram login satisfies the *intent*
   (a verified phone) by a different route. Both need re-wording and written
   sign-off, or the acceptance walk-through fails on a technicality.
2. **Is Telegram login the only route for MVP, or is OTP offered alongside it?**
   Telegram's reach in Uzbekistan is very high, but "only" means an
   account-recovery story that depends entirely on a third party. Recommendation:
   ship Telegram as the primary and keep the OTP path reachable, since the backend
   already has it.
3. **Raising the iOS floor to 15.0** (§4.2).

---

## Sources

- [Log in with Telegram](https://core.telegram.org/bots/telegram-login) — overview, bot requirements
- [Telegram Login Widget (OIDC)](https://core.telegram.org/widgets/login) — endpoints, scopes, claims, JWKS validation, PKCE, BotFather Client ID/Secret
- [telegram-login-android](https://github.com/TelegramMessenger/telegram-login-android) — official Android SDK; returns `idToken`, API 23+, GitHub Packages distribution
- [telegram-login-ios](https://github.com/TelegramMessenger/telegram-login-ios) — official iOS Swift package
- [io.khode:telegram-login-sdk](https://central.sonatype.com/artifact/io.khode/telegram-login-sdk/1.0.0) — community Maven Central fork
- [telegram_login (pub.dev)](https://pub.dev/packages/telegram_login) — Flutter wrapper; iOS 15+/API 23+, setup steps, `app{CLIENT_ID}-login.tg.dev`
- [Bot features — deep linking](https://core.telegram.org/bots/features#deep-linking) — start parameter charset and 64-character limit
- [Bot API — KeyboardButton / Contact](https://core.telegram.org/bots/api#keyboardbutton) — `request_contact`, `Contact` fields
- [Telegram Gateway](https://core.telegram.org/gateway) — code delivery over Telegram, ~$0.01/code, `checkSendAbility`
- [Seamless Telegram Login](https://core.telegram.org/api/url-authorization) — `url_authorization`, for completeness
