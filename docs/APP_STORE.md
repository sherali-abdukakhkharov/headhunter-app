# JobBridge — App Store'ga chiqarish (shaxsiy akkaunt)

Owner qarori, **2026-11-24**: iOS ilova App Store'ga **egasining shaxsiy
(Individual) Apple Developer akkaunti** orqali chiqariladi — Google Play qanday
chiqarilgan bo'lsa, xuddi shunday. Bu
[COMPANY_PUBLISHING.md](COMPANY_PUBLISHING.md)'dagi "App Store'ni boshidan
kompaniya nomiga ochamiz" rejasini almashtiradi. Kompaniyaga keyinroq **app
transfer** orqali o'tkazish mumkin (11-bo'lim).

Apple jarayonlari tez-tez o'zgaradi. Bu hujjat **2026-11-24** holatiga Apple'ning
[enrollment sahifasi](https://developer.apple.com/programs/enroll/),
[SDK talablari](https://developer.apple.com/news/upcoming-requirements/),
[skrinshot o'lchamlari](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications),
[yosh reytingi](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating),
[app transfer](https://developer.apple.com/help/app-store-connect/transfer-an-app/overview-of-app-transfer)
va [DSA trader](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-compliance-information)
sahifalari bilan tekshirilgan. Biror qadam ekrandagidan farq qilsa, ekranga
ishoning.

**Kim nima qiladi.** Har bir qadam yonida belgi bor:
👤 **siz** (akkaunt egasi — to'lov, shaxsiy ma'lumot, kalitlar),
🛠 **dasturchi** (kod, CI; Claude sessiyasi ham bajara oladi).

---

## 0. Bir qarashda

```
👤 Apple Account + 2FA ──> 👤 Developer Program ($99) ──> 👤 App ID, APNs kalit, API kalit
                                                                  │
🛠 iOS kodini tayyorlash (channel'lar, push, ikonka) ────────────┤
                                                                  ▼
                       🛠 CI: imzolangan build ──> TestFlight ──> QA iPhone'da
                                                                  │
            👤 App Store sahifasi, App Privacy, yosh reytingi ────┤
                                                                  ▼
                                               👤 App Review'ga yuborish ──> chiqarish
```

| Bosqich | Davomiyligi | Kim |
|---|---|---|
| Apple Account + Developer Program'ga a'zo bo'lish | odatda 1–3 kun; O'zbekistondan to'lovda muammo bo'lsa 1–3 hafta | 👤 |
| iOS kodini tayyorlash (8-bo'lim) | a'zolik bilan **parallel** | 🛠 |
| TestFlight'da QA | ~1 hafta | 🛠 + QA |
| Sahifa, skrinshot, anketalar | parallel | 👤 |
| App Review | odatda 1–2 kun | Apple |

Google Play'dagidan farqli: **12 tester × 14 kun qoidasi yo'q.** Eng uzun joy —
a'zolik to'lovi va iOS kodi.

---

## 1. Atamalar (Apple bilan birinchi marta ishlayotgan bo'lsangiz)

| Atama | Nima |
|---|---|
| **Apple Account** (avvalgi nomi Apple ID) | Oddiy Apple akkaunti. Developer Program shunga "ulanadi". |
| **Apple Developer Program** | Yillik $99 a'zolik. Usiz App Store'ga ilova chiqarib bo'lmaydi. |
| **Account Holder** | A'zolik egasi — siz. Faqat u shartnomalarni qabul qiladi va to'laydi. |
| **Team ID** | 10 belgili jamoa identifikatori (`developer.apple.com/account` → *Membership details*). |
| **Bundle ID** | Ilovaning doimiy identifikatori: `com.jobbridge.app` (Android'dagi application id bilan bir xil). **Birinchi build yuklangandan keyin o'zgarmaydi.** |
| **Certificates, Identifiers & Profiles** | `developer.apple.com/account/resources` — App ID, kalitlar, sertifikatlar. |
| **App Store Connect** | `appstoreconnect.apple.com` — ilova sahifasi, buildlar, TestFlight, review. Play Console'ning muqobili. |
| **TestFlight** | Apple'ning test kanali (Play'dagi internal/closed testing). |
| **APNs** | Apple Push Notification service. Firebase iOS'ga push'ni shu orqali yetkazadi. |
| **`.p8` kalit** | Apple bergan maxfiy kalit fayl. **Faqat bir marta yuklab olinadi.** |

---

## 2. Shaxsiy akkaunt nimani anglatadi — boshlashdan oldin biling

- **Sotuvchi nomi — sizning pasportdagi ism-familiyangiz** (lotincha).
  App Store'da ilova tagida "JobBridge" emas, aynan shu ism ko'rinadi. Play'da
  developer nomini erkin tanlash mumkin edi; Apple'da Individual uchun mumkin
  emas. Apple: taxallus, qisqartma yoki kompaniya nomi yozilsa — tasdiqlash
  kechikadi.
- **D-U-N-S, kompaniya sayti, domen pochta kerak emas.** Shuning uchun tez.
- **Ilova matnidagi operator va sotuvchi farq qiladi.** Maxfiylik siyosatida
  operator — "ELITE BRIDGE GROUP" MCHJ, App Store'da sotuvchi — siz. Apple buni
  taqiqlamaydi (bu bank yoki tibbiyot ilovasi emas), lekin bu **advokat
  savoli**: siyosatni o'zgartirish kerakmi yoki yo'q.
- **Jamoa.** App Store Connect'ga boshqa odamlarni (dasturchi, QA) qo'sha
  olasiz, lekin a'zolik, to'lov va shartnomalar faqat sizda.
- **Keyin kompaniyaga o'tkazish mumkin** — 11-bo'limga qarang. Ikki narsa shu
  bilan bog'liq: `.p8` kalitlarni xavfsiz saqlang, va kerak bo'lmagan Apple
  imkoniyatlarini (iCloud, App Groups, Sign in with Apple) yoqmang — ular
  transferni murakkablashtiradi.

---

## 3. Boshlashdan oldin tayyorlab qo'ying 👤

| Nima | Nega | Izoh |
|---|---|---|
| **Alohida email** | Apple Account shu bilan ochiladi | Kundalik pochta emas. Masalan, faqat JobBridge uchun Gmail. |
| **iPhone** (iloji bo'lsa) | 2FA, Apple Developer ilovasi orqali a'zo bo'lish, TestFlight'da sinash, skrinshot | Majburiy emas, lekin **juda** osonlashtiradi. Hech bo'lmasa vaqtincha qarzga oling. Mac **kerak emas** — build CI'da bo'ladi. |
| **Xalqaro to'lovga ochiq Visa/Mastercard** | $99 a'zolik | Karta **o'z nomingizda**, 3-D Secure (SMS tasdiq) yoqilgan, xalqaro onlayn to'lov ochiq, hisobda ~$110. **Humo/Uzcard ishlamaydi.** |
| **Pasport** | Ism lotincha aynan shunday yoziladi | Apple ba'zan pasport skanini va manzil tasdig'ini so'raydi. |
| **Doimiy manzil va telefon** | A'zolik formasi | P.O. box qabul qilinmaydi. Telefon `+998…`, SMS qabul qiladigan. |

---

## 4. Apple Account ochish 👤

1. `account.apple.com` → **Create Your Apple Account**.
2. **Ism va familiya — pasportdagidek, lotincha.** Mamlakat: **Uzbekistan**.
   Tug'ilgan sana — haqiqiy (voyaga yetgan bo'lishingiz kerak).
3. Email — 3-bo'limdagi alohida pochta. Uni tasdiqlang.
4. **Ikki bosqichli autentifikatsiya (2FA)** majburiy:
   - iPhone bo'lsa — o'sha iPhone'da shu akkaunt bilan kiring, 2FA avtomatik
     yoqiladi;
   - iPhone bo'lmasa — `+998` raqamingizni **trusted phone number** qilib
     qo'shing, kodlar SMS bilan keladi.
5. Parolni va akkaunt ma'lumotlarini parol menejerida saqlang. Bu akkaunt
   ilovaning egasi bo'ladi — uni yo'qotish ilovani yo'qotish demakdir.

---

## 5. Apple Developer Program'ga a'zo bo'lish (Individual) 👤

### 5.1 Ikki yo'l — birinchisini sinang

**A. iPhone'dagi "Apple Developer" ilovasi orqali (tavsiya etiladi).**
App Store'dan **Apple Developer** ilovasini o'rnating → yangi akkaunt bilan
kiring → **Account** → **Enroll Now**. Ilova pasportni skanerlab shaxsni
tasdiqlashi mumkin. Forumlardagi xabarlarga ko'ra, sayt orqali to'lov o'tmagan
hollarda ilova orqali o'tgan. Agar ilovada **Enroll** tugmasi chiqmasa —
mamlakatingiz bu yo'lni qo'llamaydi, B'ga o'ting.

**B. Sayt orqali.** `developer.apple.com/programs/enroll/` → **Start your
enrollment** → shu Apple Account bilan kiring.

### 5.2 Formani to'ldirish

1. **Entity type: Individual / Sole Proprietor.**
2. Legal name — pasportdagidek (Apple Account'dagi bilan bir xil).
3. Manzil, telefon — haqiqiy.
4. **Apple Developer Program License Agreement**'ni qabul qiling.
5. To'lov: **99 USD/yil** (sahifada mahalliy valyutada ko'rsatilishi mumkin).
   **Automatic renewal**ni yoqib qo'ying — a'zolik tugasa ilova App Store'dan
   olib tashlanadi.

### 5.3 Keyin nima bo'ladi

- Odatda bir necha soatdan 2 kungacha "**Welcome to the Apple Developer
  Program**" xati keladi. Shundan keyin `developer.apple.com/account` va
  `appstoreconnect.apple.com` ochiladi.
- **48 soatdan ko'p "Pending" bo'lsa yoki to'lov o'tmasa:**
  - to'lovni qayta-qayta bosmang (har urinish kartada summani "muzlatishi"
    mumkin);
  - bankingizga qo'ng'iroq qilib, Apple'dan avtorizatsiya so'rovi kelganmi —
    so'rang, xalqaro to'lovni ochib qo'yishni so'rang;
  - boshqa bankning kartasini sinang;
  - `developer.apple.com/contact` → **Membership and Account** → **Program
    Enrollment** orqali yozing. Ular pasport va manzil tasdig'ini so'rasa —
    yuboring.
- Apple Developer forumida O'zbekistondan bir necha shunday holat bor (to'lov
  bankka yetib bormagan, support hujjat so'ragan). Shuning uchun bu bosqichni
  **birinchi bo'lib** boshlang — kod tayyorlash bilan parallel ketadi.

### 5.4 A'zolik tasdiqlangach — darhol qiling

1. `developer.apple.com/account` → **Membership details** → **Team ID**'ni
   yozib oling (dasturchiga kerak; maxfiy emas).
2. `appstoreconnect.apple.com` → **Business** (avval *Agreements, Tax, and
   Banking*): **Free Apps** shartnomasi faol bo'lishi kerak. **Paid Apps**
   shartnomasi, bank va soliq formalari hozir **kerak emas** — faqat ilova
   ichida sotuv (In-App Purchase) boshlansa (10-bo'lim).
3. **DSA (Yevropa Ittifoqi) trader statusi.** App Store Connect buni hamma
   uchun so'raydi. Ilovani **EI mamlakatlarida tarqatmasangiz, siz trader
   emassiz** — "not a trader" deb belgilang. Agar EI'da tarqatib, trader deb
   belgilasangiz, Apple **uy manzilingiz, telefon va email'ingizni** EI App
   Store'ida ochiq ko'rsatadi. Shuning uchun 7.7-bo'limda EI'ni chiqarib
   tashlashni tavsiya qilaman.

---

## 6. Apple portalidagi sozlamalar 👤 (brauzerda, Mac kerak emas)

### 6.1 App ID (Bundle ID) ro'yxatdan o'tkazish

`developer.apple.com/account/resources/identifiers` → **+** → **App IDs** →
**App** →

- Description: `JobBridge`
- Bundle ID: **Explicit** → `com.jobbridge.app`
- Capabilities: faqat **Push Notifications** ni belgilang. Boshqasini emas.
  Belgilanmasa, build "Provisioning profile doesn't include the Push
  Notifications capability" bilan yiqiladi (2026-11-27 da shunday bo'lgan).

→ **Continue** → **Register**.

### 6.2 Push uchun APNs kaliti

`…/resources/authkeys` (**Keys**) → **+** →

- Key name: `JobBridge APNs`
- **Apple Push Notifications service (APNs)** ni belgilang → *Configure* →
  muhit **Sandbox & Production**.

→ **Register** → **Download**. `AuthKey_XXXXXXXXXX.p8` fayli **faqat bir marta**
yuklab olinadi — parol menejeriga yoki xavfsiz joyga saqlang. **Key ID**'ni
yozib oling.

### 6.3 Firebase'ga iOS ilovasini qo'shish

Android push ishlayotgan **o'sha Firebase loyihasida**:

1. Firebase console → loyiha → **Add app** → **iOS** → Bundle ID
   `com.jobbridge.app`, nickname `JobBridge iOS` → **Register app**.
2. **`GoogleService-Info.plist`** ni yuklab oling. Bu fayl
   `google-services.json` kabi **gitga kirmaydi** — CI uni secret'dan tiklaydi
   (6.5).
3. **Project settings** → **Cloud Messaging** → **Apple app configuration** →
   **APNs Authentication Key** → **Upload**: 6.2'dagi `.p8`, Key ID va Team ID.

Backend tayyor: qurilmani ro'yxatga olish `platform: 'ios'` ni qabul qiladi va
FCM xabarida `apns` bloki yuboriladi — server tomonda ish yo'q.

### 6.4 CI uchun App Store Connect API kaliti

`appstoreconnect.apple.com` → **Users and Access** → **Integrations** → **App
Store Connect API** → (birinchi marta **Request Access** → tasdiqlang) →
**Team Keys** → **+** →

- Name: `JobBridge CI`
- Access: **App Manager**

→ **Generate** → **Download API Key** (yana `.p8`, yana **bir marta**). Sahifadan
**Issuer ID** va **Key ID**'ni yozib oling.

Bu kalit CI'ga imzo sertifikati va provisioning profile'ni **avtomatik**
yaratish hamda buildni TestFlight'ga yuklash imkonini beradi. Shuning uchun
sizga Mac, Keychain va sertifikat bilan qo'lda ishlash kerak emas.

Agar birinchi `ios-release` ishga tushganda **sertifikat yoki profile
yaratishga ruxsat yo'q** degan xato chiqsa, kalitni **Admin** roli bilan qayta
yarating va secret'larni yangilang. App Manager kifoya qilishi kerak, lekin bu
hali sinab ko'rilmagan.

### 6.5 Kalitlarni CI'ga berish — chatga emas

**Hech qaysi `.p8` faylni, plist'ni yoki ularning matnini chatga, Telegram'ga
yoki gitga qo'ymang.** GitHub repository secret sifatida o'zingiz qo'ying.
Fayllar turgan papkada PowerShell'da (`gh` o'rnatilgan va login qilingan
bo'lishi kerak):

```powershell
Get-Content .\AuthKey_CIKEYID.p8 -Raw | gh secret set APP_STORE_CONNECT_PRIVATE_KEY --repo <owner>/headhunter-app
```

```powershell
gh secret set APP_STORE_CONNECT_KEY_ID --repo <owner>/headhunter-app --body "<Key ID>"
```

```powershell
gh secret set APP_STORE_CONNECT_ISSUER_ID --repo <owner>/headhunter-app --body "<Issuer ID>"
```

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\GoogleService-Info.plist")) | gh secret set GOOGLE_SERVICE_INFO_PLIST_BASE64 --repo <owner>/headhunter-app
```

**Beshinchi secret — imzo sertifikatining kaliti.** CI distribution
sertifikatini Apple API orqali o'zi yaratadi, lekin har safar **bir xil** RSA
kalitdan foydalanishi kerak (Apple akkauntga bir nechta sertifikatgagina ruxsat
beradi). Kalitni bir marta yarating va secret'ga qo'ying (Windows'da
`ssh-keygen` tayyor turadi):

```powershell
ssh-keygen --% -t rsa -b 2048 -m PEM -f ios_distribution_key -q -N ""
```

```powershell
Get-Content .\ios_distribution_key -Raw | gh secret set CERTIFICATE_PRIVATE_KEY --repo <owner>/headhunter-app
```

`ios_distribution_key` faylini parol menejeriga saqlang, keyin papkadan o'chiring
(`.pub` fayli kerak emas).

[`ios-release.yml`](../.github/workflows/ios-release.yml) aynan shu besh nomni
o'qiydi: `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_ID`,
`APP_STORE_CONNECT_PRIVATE_KEY`, `CERTIFICATE_PRIVATE_KEY`,
`GOOGLE_SERVICE_INFO_PLIST_BASE64`. **Beshtasi ham bo'lmasa**, workflow "hali
sozlanmagan" deb yashil holda o'tib ketadi. **Bir qismigina bo'lsa**, qizil
bo'ladi — chala sozlama xato hisoblanadi. Team ID maxfiy emas va kerak ham
emas: API kalitning o'zi jamoani biladi.

### 6.6 App Store Connect'da ilova yozuvini yaratish

**Apps** → **+** → **New App**:

| Maydon | Qiymat |
|---|---|
| Platforms | iOS |
| Name | `JobBridge` (≤ 30 belgi, butun App Store bo'yicha **unikal**; band bo'lsa — `JobBridge: ish va xodimlar` kabi) |
| Primary Language | 7.1'ga qarang |
| Bundle ID | `com.jobbridge.app` (6.1'dan keyin ro'yxatda chiqadi) |
| SKU | `jobbridge-ios` (ichki, hech kim ko'rmaydi) |
| User Access | Full Access |

Yozuv yaratilishi bilan nom siz uchun band qilinadi.

---

## 7. App Store sahifasi va anketalar 👤

### 7.1 Til

App Store Connect metadata uchun ~50 tilni qo'llaydi; 2026-11-24 holatida
**o'zbek tili ro'yxatda yo'qdek** (2026-mart qo'shilgan 11 til orasida ham yo'q).
**Primary Language** ochiladigan ro'yxatida tekshiring:

- **o'zbek bo'lsa** — Primary: Uzbek, qo'shimcha: Russian, English (U.K. yoki
  U.S.);
- **bo'lmasa** — Primary: **English**, qo'shimcha: **Russian**. O'zbekcha qisqa
  matnni inglizcha tavsifning boshiga qo'yish mumkin.

Ilovaning o'zi to'rt variantda (uz-Latn, uz-Cyrl, ru, en) ishlaydi — bu
metadata tiliga bog'liq emas.

### 7.2 Matnlar

| Maydon | Chegara | Nima yoziladi |
|---|---|---|
| **Subtitle** | 30 | en: `Jobs and hiring in Uzbekistan` · ru: `Работа и найм в Узбекистане` |
| **Promotional text** | 170 | Istalgan vaqtda reviewsiz o'zgartiriladi. Masalan: yangi vakansiyalar, mavsumiy ishlar. |
| **Description** | 4000 | [PLAY_STORE.md](PLAY_STORE.md#full-description-uz-latn)'dagi to'liq tavsif (en, ru). Unda "Android", "Google Play" so'zlari **bo'lmasligi** kerak — tekshirildi, yo'q. |
| **Keywords** | 100 (vergul bilan, bo'shliqsiz) | en: `job,jobs,vacancy,hiring,resume,cv,career,work,employer,uzbekistan,tashkent` · ru: `работа,вакансии,резюме,найм,ташкент,узбекистан,подработка` |
| **Support URL** | majburiy | **Hozir mos sahifa yo'q** — 8-bo'lim, 7-band. |
| **Marketing URL** | ixtiyoriy | bo'sh qoldirish mumkin |
| **Privacy Policy URL** | majburiy | `https://hh.qitmir.uz/privacy` |
| **Copyright** | | `2026 <Ism Familiya>` |
| **Category** | | Primary: **Business**, Secondary: **Productivity** (ixtiyoriy) |
| **Price** | | Free |

### 7.3 Skrinshotlar

- **iPhone uchun eng katta o'lcham yetarli:** 1320 × 2868 (yoki 1290 × 2796),
  portret, PNG/JPEG, 1–10 ta (5–6 tavsiya etiladi). App Store Connect ularni
  kichik ekranlar uchun o'zi kichraytiradi. **Media Manager** qaysi o'lcham
  majburiyligini ko'rsatadi — o'shanga qarang.
- **Ilova faqat iPhone uchun bo'lsa, iPad skrinshot kerak emas** (8-bo'lim,
  1-band).
- **Android skrinshotlarini ishlatmang.** Android status bar yoki navigatsiya
  tugmalari ko'rinsa — Guideline 2.3.10 bo'yicha rad etiladi.
- Qayerdan olinadi: TestFlight'dagi build'dan **iPhone 15/16/17 Pro Max**'da
  (yon tugma + ovoz balandligi), yoki dasturchi CI'dagi simulator'dan
  oladi. Sahnalar — [STORE_SCREENSHOTS_BRIEF.md](STORE_SCREENSHOTS_BRIEF.md),
  seed qilingan test akkauntlari bilan.

### 7.4 App Privacy ("nutrition label")

Javoblar **maxfiylik siyosati bilan mos** bo'lishi shart; manba —
`headhunter-backend/docs/legal/PRIVACY_POLICY_BRIEF.md` oxiridagi jadval (Play
Data safety shundan to'ldirilgan). Apple kategoriyalariga taqsimoti:

| Apple turi | JobBridge'da | Linked to user | Tracking |
|---|---|---|---|
| Contact Info → Name | F.I.Sh., kontakt shaxs ismi | Ha | Yo'q |
| Contact Info → Phone Number | kirish raqami, kontakt telefon | Ha | Yo'q |
| Contact Info → Email Address | profilda bo'lsa | Ha | Yo'q |
| Contact Info → Physical Address | ish beruvchi manzili, hudud | Ha | Yo'q |
| User Content → Photos or Videos | profil rasmi, logotip | Ha | Yo'q |
| User Content → Emails or Text Messages | suhbat xabarlari | Ha | Yo'q |
| User Content → Other User Content | rezyume, sertifikat, tekshiruv hujjatlari, vakansiya matni, shikoyatlar | Ha | Yo'q |
| Identifiers → User ID | akkaunt id | Ha | Yo'q |
| Identifiers → Device ID | qurilma identifikatori, push token | Ha | Yo'q |
| Purchases → Purchase History | **hozir yo'q** — Coin sotuvi boshlansa qo'shiladi | | |
| Other Data | tug'ilgan sana, jins, ish tajribasi, ta'lim, kutilayotgan maosh | Ha | Yo'q |

Hammasi uchun maqsad: **App Functionality**. **Tracking — No** (reklama va
analitika SDK yo'q). **Location, Contacts, Diagnostics, Usage Data — yig'ilmaydi**
(ilovada crash yoki analitika SDK yo'q).

### 7.5 Yosh reytingi (yangi tizim: 4+, 9+, 13+, 16+, 18+)

App Information → **Age Rating** anketasi. Halol javoblar: user-generated
content — **ha**; messaging/chat — **ha**; reklama, qimor, zo'ravonlik, tibbiyot
— **yo'q**; cheklanmagan veb-brauzer — **yo'q**.

Apple hisoblagan reyting chiqadi. **Play'da maqsadli auditoriya 18+** (advokat
qarori). Apple qoidasi: shartlaringizdagi minimal yosh hisoblangandan yuqori
bo'lsa, **Override to Higher Age Rating** orqali ko'tarishingiz shart.
**Ziddiyat bor:** maxfiylik siyosati nomzod uchun **14+** deydi. 18+ qo'ysangiz,
ota-ona nazoratidagi 14–17 yoshli iPhone foydalanuvchisi ilovani o'rnata
olmaydi. Bu Play'dagi ochiq qaror (PLAY_STORE.md, *Open decisions* 2) bilan
bir xil savol — **advokat hal qiladi**, ikkala do'kon bir xil javob oladi.

### 7.6 Boshqa savollar

| Savol | Javob |
|---|---|
| Content Rights — uchinchi tomon kontenti bormi? | **Yes** (foydalanuvchilar yuklagan kontent) → huquqlar bor deb tasdiqlang |
| Export compliance / encryption | Faqat HTTPS → `ITSAppUsesNonExemptEncryption = NO` Info.plist'da bo'ladi va savol chiqmaydi |
| Advertising identifier (IDFA) | Yo'q |
| Sign in with Apple | **Kerak emas** — kirish faqat telefon + SMS kod, uchinchi tomon login yo'q (Guideline 4.8) |

### 7.7 Qaysi mamlakatlarda

**Pricing and Availability** → **App Availability**. Tavsiya: **EI'ning 27
mamlakatidan tashqari hammasi** (yoki faqat O'zbekiston).

- O'zbekistonda ko'p iPhone egalarining Apple Account'i AQSh yoki Rossiya
  regionida — faqat O'zbekiston tanlansa, ular ilovani topa olmaydi.
- EI'ni chiqarish — trader statusisiz qolish va uy manzilingizni ochiq
  ko'rsatmaslik uchun (5.4, 3-band).
- O'zbekistondan tashqaridagi maxfiylik qonunlari advokat tomonidan
  ko'rilmagan — bu Play'da ham shunday (PLAY_STORE.md boshi).

---

## 8. iOS kodini tayyorlash 🛠

**2026-11-27 holati: birinchi imzolangan build — `1.36.0 (47)` — App Store
Connect'ga yuklandi** (`ios-release.yml`, Mac'siz). Kod 2026-11-26 da CI'da
imzosiz kompilyatsiya bo'lgan edi. **iPhone'da hali ishga tushirilmagan.**
Dart'dan tekshirsa bo'ladigan narsalar `test/ios_project_test.dart`'da
qotirilgan.

**Qilindi:**

1. **Identifikatsiya:** bundle id `com.headhunter.app` → **`com.jobbridge.app`**,
   nom **JobBridge**, **faqat iPhone**, minimal **iOS 15** (Firebase SDK talabi).
   Ekran aylanishi Android'dagidek: portret va landshaft.
2. **Ikonka:** 1024×1024, **alfa-kanalsiz** RGB. Uni `node tool/ios_app_icon.js`
   chizadi — brend belgisini `hh_brand.dart`'dan o'qiydi va
   `--compare docs/store/icon-512.png` bilan Flutter chizgan ikonkaga
   solishtiriladi. Flutter shablonining logotiplari olib tashlandi.
   **Launch screen** — Android'dagidek to'q ko'k fon.
3. **Uchta MethodChannel Swift'da** — `ios/Runner/AppDelegate.swift`:
   `/attachments` (Quick Look, o'qiy olmasa share sheet), `/links` (faqat
   https), `/push` (ilova versiyasi). Nomlar, metodlar va xato kodlari
   `MainActivity.kt` bilan bir xil — buni test tekshiradi.
4. **Push:** `Runner.entitlements` (`aps-environment`). Gitignore qilingan
   `GoogleService-Info.plist`'ni bundle'ga nusxalaydigan build bosqichi:
   fayl bo'lmasa debug ogohlantiradi, **Release esa to'xtaydi**. Qurilma
   ro'yxatdan o'tganda endi `platform: ios` yuboradi — avval doim `android`
   edi. Background Modes kerak emas: backend `notification` blokli xabar
   yuboradi, uni iOS o'zi ko'rsatadi.
5. **Info.plist:** `ITSAppUsesNonExemptEncryption = NO`,
   `CFBundleLocalizations` (uz, uz-Cyrl, ru, en).
6. **CI:** [`ios-build.yml`](../.github/workflows/ios-build.yml) — `ios/` yoki
   pubspec o'zgarganda imzosiz kompilyatsiya.
   [`ios-release.yml`](../.github/workflows/ios-release.yml) — `v*` tegida
   imzolaydi va TestFlight'ga yuklaydi (6.5'dagi secret'lar bilan, Mac'siz).
   Ikkalasi ham eng yangi barqaror Xcode'ni tanlaydi; reliz Xcode 26 dan
   eskisini rad etadi.

7. **Birinchi imzolangan build — 2026-11-27.** CI API kaliti orqali
   distribution sertifikati va provisioning profile'ni o'zi yaratdi, IPA'ni
   imzoladi va yukladi. Birinchi urinish yiqildi: App ID'da **Push
   Notifications belgilanmagan** edi, profile esa imkoniyatlarni App ID'dan
   oladi ("Provisioning profile doesn't include the Push Notifications
   capability"). Belgilangach, qayta ishga tushirish kifoya qildi — kod
   o'zgarmadi.

**Qolgan ishlar:**

8. **Support sahifasi:** App Store **Support URL** talab qiladi. Backend'da
   faqat `/privacy` va `/account/delete` bor. `https://hh.qitmir.uz/support`
   ni xuddi shu `legal` moduli orqali qo'shish kerak (aloqa email'i, hisobni
   o'chirish havolasi; `?lang=uz|ru|en`).
9. **Maxfiylik siyosati matni "Android ilovasi" va "Android fayl tanlagichi"
   deydi.** Uni "Android va iOS ilovasi", "tizim fayl tanlagichi" ga
   o'zgartirish va xizmat ko'rsatuvchilarga **Apple Push Notification service**
   ni qo'shish kerak: `headhunter-backend/docs/legal/*.md` → `pnpm legal:build`
   → deploy. Mazmun o'zgargani uchun **advokat ko'radi**.
10. **Apple'ning yuklashdan keyingi xatlari:** ITMS-90683 (permission matni
    yetishmaydi) yoki ITMS-91053 (privacy manifest yetishmaydi) kelsa — aynan
    nomlangan kalitni qo'shish. **Bu 2026-11-27 da bo'ldi:** build 47
    "muvaffaqiyatli yuklandi", lekin bir soatdan keyin email keldi va TestFlight'da
    umuman ko'rinmadi. Sabab — `file_picker` paketi rasm va kamera tanlagichini
    doim kompilyatsiya qiladi, Apple esa skanerda `NSCameraUsageDescription` va
    `NSPhotoLibraryUsageDescription` ni talab qildi. Ikkalasi qo'shildi (ilova
    bu ruxsatlarni hech qachon so'ramaydi, shuning uchun matnlar ko'rinmaydi) va
    build 48 yuklandi. Xuddi shu xatdagi `NSLocationWhenInUseUsageDescription`
    majburiy emas deb belgilangan — qo'shilmadi.
11. **2027-yil aprelidan iOS 27 SDK (Xcode 27) majburiy.** Birinchi yuklash
    ITMS-90725 ogohlantirishi bilan qabul qilindi. Shu paytgacha
    `ios-release.yml`'dagi Xcode chegarasini 27 ga ko'tarish kerak.
12. **`flutter_secure_storage` hali Swift Package Manager'ni qo'llamaydi**, shuning
    uchun build u uchun CocoaPods ishlatadi. Hozir bu ogohlantirish; Flutter
    keyinroq uni xatoga aylantiradi — paket yangilanishini kuzatib boring.

**Versiya:** `pubspec.yaml`'dagi `version` iOS'da ham ishlatiladi
(`1.36.0+47` → `CFBundleShortVersionString` `1.36.0`, `CFBundleVersion` `47`).
Build raqami har yuklashda oshishi shart — reliz jarayoni allaqachon shunday
([CHANGELOG.md](../CHANGELOG.md)). Rad etilgan build ham o'z raqamini band
qiladi. Shuning uchun tegsiz, faqat iOS uchun qayta yuklashda ham `pubspec.yaml`
dagi raqam oshiriladi: 2026-11-27 da `1.36.0+47` → `+48`, keyin Top up matni uchun `+49`. Keyingi reliz `+50`
dan davom etadi.

---

## 9. TestFlight 🛠 + QA

1. Reliz tegi (`v1.37.0` kabi) `release-apk.yml` bilan birga `ios-release.yml`'ni
   ham ishga tushiradi. U build'ni yuklaydi → App Store Connect → **TestFlight**'da
   10–30 daqiqada "Processing" tugaydi. Tegsiz build kerak bo'lsa — Actions →
   **ios-release** → *Run workflow*.
2. **Missing Compliance** chiqsa — Info.plist'dagi
   `ITSAppUsesNonExemptEncryption` yo'qolgan (8-bo'lim, 5-band).
3. **Internal Testing:** App Store Connect foydalanuvchilari (100 tagacha),
   review yo'q. **Users and Access** → QA va dasturchini **Developer** yoki
   **App Manager** roli bilan taklif qiling → TestFlight → *Internal Testing*
   guruhiga qo'shing.
4. **External Testing** (ixtiyoriy): email yoki **public link** bilan 10 000
   tagacha tester. Birinchi build uchun **Beta App Review** (~1 kun) kerak —
   App Review'ga mashq ham bo'ladi.
5. Testerlar iPhone'ga **TestFlight** ilovasini o'rnatadi, taklifni ochadi.
6. QA to'liq o'tishi — `mobile-test-audit.md` iOS uchun. Ayniqsa: CV
   yuklash/ochish, maxfiylik siyosati havolasi, push (ruxsat → bildirishnoma
   keladi, bosilsa to'g'ri ekran ochiladi), to'rt til, rol almashtirish,
   hisobni o'chirish, chatda shikoyat va bloklash.

---

## 10. App Review'ga yuborish 👤

### 10.1 Rad etilish xavfi bor joylar — yuborishdan oldin hal qiling

| # | Xavf | Guideline | Holat | Nima qilish kerak |
|---|---|---|---|---|
| 1 | **"Top up" tugmasi "Payme va CLICK bilan keladi" degan edi** | 3.1.1 (tashqi to'lovga yo'naltirish), 2.1 (tugallanmagan funksiya) | ✅ **Hal qilindi, 2026-11-27 (owner qarori):** matn endi faqat "To'ldirish hozircha mavjud emas" deydi — to'rt variantda, ikkala platformada | Hech narsa. Build 49 dan boshlab. |
| 2 | **Coin sotuvi** | 3.1.1 | Hozir sotuv yo'q, Coin faqat bepul ro'yxatdan o'tish bonusi | Launch'ni bloklamaydi. Sotuv boshlansa iOS'da **faqat In-App Purchase** (Payme/CLICK emas). Apple Small Business Program'da komissiya 15%. Buning uchun Paid Apps shartnomasi, bank hisobi (USD/SWIFT) va soliq formasi kerak bo'ladi. |
| 3 | **Bo'sh ilova** | 2.1, 4.2 | Play launch'ida demo ma'lumot o'chirilgan, feed bo'sh edi | Yuborish kuni production'da **real faol vakansiyalar** borligini tekshiring. Bo'sh lenta reviewer'ga "ishlamaydigan ilova" bo'lib ko'rinadi. |
| 4 | **Server o'chiq bo'lsa** | 2.1 | API bitta Windows mashinada, Cloudflare tunnel orqali | Review paytida (1–3 kun) `https://hh.qitmir.uz/health` `ok` bo'lishi shart. |
| 5 | **Foydalanuvchi kontenti** | 1.2 | ✅ xabar va vakansiyaga shikoyat, ✅ bloklash, ✅ moderatsiya, ✅ aloqa email'i | Apple ba'zan "foydalanuvchilar haqoratli kontentga **nol tolerantlik** shartini qabul qilishi kerak" deb talab qiladi. Ilovada foydalanish shartlari (ToS) yo'q. Rad etilsa — qisqa shartlar sahifasi va rozilik oynasida havola. Advokat bilan oldindan tayyorlab qo'yish yaxshi. |
| 6 | **Hisobni o'chirish** | 5.1.1(v) | ✅ Profil → Hisob → Hisobni o'chirish; 30 kunlik kutish siyosatda yozilgan | Hech narsa. |
| 7 | **Android'ni eslatish** | 2.3.10 | Maxfiylik siyosati "Android ilovasi" deydi | 8-bo'lim, 8-band. |
| 8 | **Support URL** | 1.5 | Yo'q | 8-bo'lim, 7-band. |

### 10.2 Versiya sahifasi

App Store Connect → ilova → **iOS App** → **1.0 Prepare for Submission** (yoki
`1.36.x`):

1. Skrinshotlar, tavsif, keywords, support URL (7-bo'lim).
2. **Build** → TestFlight'dan tanlang.
3. **App Review Information:**
   - **Sign-in required: ✓**
   - User name: `011000001` · Password: `111111`
   - Contact: ismingiz, `+998…` telefon, email (faqat Apple ko'radi).
   - **Notes** — quyidagi matn (inglizcha).
   - **Hech qachon admin akkauntini bermang** (`019000001`).
4. **Version Release:** **Manually release this version** — tasdiqlangandan
   keyin chiqarish tugmasini o'zingiz bosasiz (Play'dagi managed publishing
   kabi).
5. **Add for Review** → **Submit to App Review**.

### 10.3 Reviewer uchun izoh (Notes)

Akkauntlar [TEST_ACCOUNTS.md](../../headhunter-backend/docs/TEST_ACCOUNTS.md)
dan. 10.1, 1-band qaroriga qarab oxirgi xatboshini moslang.

```text
JobBridge is a job-search and hiring app for Uzbekistan. Sign-in is by phone
number and a one-time SMS code. The review accounts below receive a fixed
code instead of an SMS, so no SIM card is needed.

Candidate: type 011000001 in the phone field (+998 is already shown), then
code 111111.
Employer: type 012000001, then code 222221.

Account deletion: Profile > Account > Delete account.
Reporting and blocking: in a conversation, tap the other person's message to
report it, or block the conversation with the button at the top of the
screen. Vacancies can be reported from the vacancy screen. Reports are
reviewed by our moderators.

Interface languages: Uzbek (Latin and Cyrillic), Russian, English.

Coins: an employer receives a one-time free registration bonus of Coins,
which can be spent to view a candidate's contact details. Coins cannot be
purchased in this version and the app contains no payment flow.
```

### 10.4 Keyin

- Review odatda **24–48 soat**. Holat: *Waiting for Review → In Review →
  Pending Developer Release* (yoki *Rejected*).
- **Rad etilsa:** App Store Connect → **App Review** (Resolution Center)da
  sabab va guideline raqami yoziladi. Tuzatib qayta yuboring, yoki tushuntirish
  yozing — ko'pincha izoh bilan hal bo'ladi. Rozi bo'lmasangiz — **Appeal**.
- **Pending Developer Release** → **Release This Version**. App Store'da
  bir necha soatda paydo bo'ladi.

---

## 11. Chiqqandan keyin

- **Yangilanishlar:** har reliz — `pubspec.yaml`'da build raqami oshadi →
  teg → CI TestFlight'ga yuklaydi → yangi versiya → **What's New** matni →
  Submit. Yangilanishlar uchun **Phased Release** (7 kun bosqichma-bosqich)ni
  yoqing — Play'dagi staged rollout kabi.
- **Promotional text**ni reviewsiz istalgan vaqt o'zgartirish mumkin.
- **A'zolik har yili $99** — muddat tugasa ilova do'kondan olib tashlanadi.
  Avtomatik yangilanish va kartaning amal qilish muddatini kuzating.
- **APNs kaliti** muddatsiz, lekin bekor qilinsa iOS push to'xtaydi — Firebase'da
  yangisini yuklang.

### Kompaniyaga o'tkazish (keyinroq)

Apple **App Transfer** shartlari (2026-11-24):

- ilovaning **kamida bitta versiyasi App Store'da chiqqan** bo'lishi kerak;
- ikkala akkaunt faol, oxirgi shartnomalar qabul qilingan;
- review'dagi versiya yo'q, pre-order yo'q;
- **TestFlight o'chirilgan**: buildlar va testerlar olib tashlangan.

O'tadi: bundle id, reyting va sharhlar, foydalanuvchilar yangilanishlarni
olishda davom etadi. **O'tmaydi yoki qayta sozlanadi:** APNs kaliti muddati
tugaguncha ishlaydi, keyin kompaniya o'z kalitini Firebase'ga yuklaydi;
keychain jamoa ID'siga bog'liq — transferdan keyingi birinchi yangilanishda
foydalanuvchilardan **bir marta qayta kirish** so'ralishi mumkin; analitika
eski egasida qoladi.

Kompaniyaning Apple akkaunti **Organization** bo'lishi kerak (D-U-N-S, sayt,
domen email — COMPANY_PUBLISHING.md). Apple sahifalari Individual →
Organization transferini alohida cheklamaydi, lekin forumlarda bunga zid
xabarlar bor — transfer oldidan Apple Developer Support'dan tasdiqlab oling.

---

## 12. Owner qarorlari kerak

1. ~~**"Top up" matni iOS'da.**~~ **Hal qilindi 2026-11-27:** a) varianti —
   Payme/CLICK nomlari hamma joyda olib tashlandi.
2. **Mamlakatlar:** EI'siz hamma (tavsiya) yoki faqat O'zbekiston.
3. **Yosh reytingi va minimal yosh (14+ / 18+):** advokat, Play bilan bir xil.
4. **Foydalanish shartlari (nol tolerantlik bandi bilan):** hozir
   yozdirasizmi yoki faqat Apple so'rasa.
5. **Maxfiylik siyosatidagi operator** (MCHJ) va App Store'dagi sotuvchi
   (siz) farqi: advokat.
6. **CI:** GitHub Actions (tavsiya) yoki Codemagic.
7. **Kompaniyaga transfer qachon** — Play transferi bilan birga
   rejalashtirish mantiqiy.

---

## Qisqa nazorat ro'yxati

👤 **Siz:**
- [x] Alohida email, Visa/Mastercard (xalqaro to'lov ochiq), iloji bo'lsa iPhone
- [x] Apple Account (pasportdagi ism, region Uzbekistan, 2FA)
- [x] Developer Program — Individual, $99, auto-renew (Free Apps shartnomasi
  2026-11-26 dan faol)
- [x] Team ID → dasturchiga
- [ ] DSA: not a trader (EI'da tarqatilmaydi)
- [x] App ID `com.jobbridge.app` + Push Notifications
- [x] APNs `.p8` → Firebase; Firebase iOS app → `GoogleService-Info.plist`
- [x] App Store Connect API kaliti (App Manager) → GitHub secrets (beshtasi
  2026-11-27 da qo'yildi)
- [x] App Store Connect'da "JobBridge" yozuvi
- [ ] 12-bo'lim qarorlari
- [ ] Matnlar, skrinshotlar, App Privacy, yosh reytingi, mamlakatlar
- [ ] Yuborish kuni: server ishlayapti, real vakansiyalar bor
- [ ] Submit → tasdiqlangach Release

🛠 **Dasturchi:**
- [x] Bundle id, nom, iPhone-only, iOS 15, ikonka, launch screen
- [x] Uchta Swift MethodChannel
- [x] Push: entitlements, plist build bosqichi, `platform: ios`
- [x] Info.plist kalitlari
- [x] CI: kompilyatsiya tekshiruvi va imzolangan build → TestFlight
- [x] Birinchi `ios-build.yml` — 2026-11-26 da yashil (Xcode 26.6)
- [x] Birinchi imzolangan build → App Store Connect — 2026-11-27, `1.36.0 (47)`
- [ ] `/support` sahifasi (backend)
- [ ] Maxfiylik siyosatiga iOS (advokat ko'rgandan keyin)
- [ ] TestFlight QA, skrinshotlar
