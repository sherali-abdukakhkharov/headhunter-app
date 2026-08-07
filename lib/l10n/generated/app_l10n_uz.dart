// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppL10nUz extends AppL10n {
  AppL10nUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'HeadHunter';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonNext => 'Keyingi';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonSearch => 'Qidirish';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonSignOut => 'Chiqish';

  @override
  String get stateLoading => 'Yuklanmoqda…';

  @override
  String get stateEmptyTitle => 'Hozircha bo\'sh';

  @override
  String get stateEmptyBody =>
      'Bu ekranda hozircha ko\'rsatiladigan ma\'lumot yo\'q.';

  @override
  String get stateErrorTitle => 'Nimadir xato ketdi';

  @override
  String get stateErrorBody =>
      'So\'rovni bajarib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get stateOfflineTitle => 'Internet aloqasi yo\'q';

  @override
  String get stateOfflineBody => 'Aloqani tekshiring va qayta urinib ko\'ring.';

  @override
  String get statePermissionDeniedTitle => 'Ruxsat kerak';

  @override
  String get statePermissionDeniedBody =>
      'Davom etish uchun Sozlamalarda ruxsat bering.';

  @override
  String get sessionExpired =>
      'Sessiya muddati tugadi. Iltimos, qaytadan kiring.';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get roleCandidate => 'Nomzod';

  @override
  String get roleEmployer => 'Ish beruvchi';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navVacancies => 'Vakansiyalar';

  @override
  String get navApplications => 'Arizalar';

  @override
  String get navMessages => 'Xabarlar';

  @override
  String get navProfile => 'Profil';

  @override
  String get navCandidates => 'Nomzodlar';

  @override
  String get navCompany => 'Kompaniya';

  @override
  String get navDashboard => 'Boshqaruv';

  @override
  String get navQueue => 'Moderatsiya';

  @override
  String get navComplaints => 'Shikoyatlar';

  @override
  String get navUsers => 'Foydalan­uvchilar';

  @override
  String get navDictionaries => 'Lug\'atlar';

  @override
  String get blockedTitle => 'Hisob bloklangan';

  @override
  String get blockedBody =>
      'Administrator bu hisobni bloklagan. Blok olib tashlanmaguncha ilovadan foydalana olmaysiz.';

  @override
  String get profileCompleteness => 'Profil toʻldirilganligi';

  @override
  String profileMissingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yana $count ta majburiy maydon',
    );
    return '$_temp0';
  }

  @override
  String get profileSearchable => 'Qidiruvda koʻrinadi';

  @override
  String get profileNotSearchable => 'Hozircha qidiruvda emas';

  @override
  String get profileSaved => 'Profil saqlandi';

  @override
  String get profileSectionElsewhere =>
      'Bu boʻlimning alohida tahrirlagichi bor, u keyinroq qoʻshiladi.';

  @override
  String get profileFieldNotEditableYet =>
      'Bu maydonni ilovaning ushbu versiyasida oʻzgartirib boʻlmaydi.';

  @override
  String get profileChooseParentFirst => 'Avval yuqoridagi maydonni tanlang';

  @override
  String get profileDateHint => 'YYYY-OO-KK';

  @override
  String get profileSalaryFrom => 'Dan';

  @override
  String get profileSalaryTo => 'Gacha';

  @override
  String get profileSalaryNegotiable => 'Kelishuv asosida';

  @override
  String get historyDeleteTitle => 'Yozuv o\'chirilsinmi?';

  @override
  String get historyDeleteMessage => 'U profilingizdan o\'chiriladi.';

  @override
  String get experienceEmpty => 'Ish tajribasi qo\'shilmagan';

  @override
  String get experienceAdd => 'Tajriba qo\'shish';

  @override
  String get experienceEmployer => 'Ish beruvchi';

  @override
  String get experienceRole => 'Lavozim';

  @override
  String get experienceOccupation => 'Kasb';

  @override
  String get experienceStarted => 'Boshlangan sana';

  @override
  String get experienceEnded => 'Tugagan sana';

  @override
  String get experienceCurrent => 'Hozir shu yerda ishlayman';

  @override
  String get experienceResponsibilities => 'Vazifalar';

  @override
  String get experiencePresent => 'Hozirgacha';

  @override
  String get educationEmpty => 'Ta\'lim qo\'shilmagan';

  @override
  String get educationAdd => 'Ta\'lim qo\'shish';

  @override
  String get educationLevel => 'Ta\'lim darajasi';

  @override
  String get educationInstitution => 'O\'quv muassasasi';

  @override
  String get educationSpecialization => 'Mutaxassislik';

  @override
  String get educationYear => 'Tugatgan yili';

  @override
  String get leveledChangeLevel => 'Daraja';

  @override
  String get pickerChoose => 'Tanlash';

  @override
  String get pickerAdd => 'Qo\'shish';

  @override
  String get pickerSearchHint => 'Qidirish uchun yozing';

  @override
  String get pickerNoMatches => 'Hech narsa topilmadi.';

  @override
  String get pickerNothingSelected => 'Hozircha tanlanmagan';

  @override
  String get pickerUnknownValue => 'Mavjud boʻlmagan qiymat';

  @override
  String get authSignInTitle => 'Kirish';

  @override
  String get authPhoneLabel => 'Telefon raqami';

  @override
  String get authPhoneHint => '90 123 45 67';

  @override
  String get authPhoneInvalid => '9 ta raqam kiriting, masalan 90 123 45 67.';

  @override
  String get authSendCode => 'Kod olish';

  @override
  String get authCodeTitle => 'Kodni kiriting';

  @override
  String authCodeSentTo(String phone) {
    return '$phone raqamiga kod yubordik.';
  }

  @override
  String get authCodeLabel => 'Kod';

  @override
  String authCodeInvalid(int length) {
    return '$length xonali kodni kiriting.';
  }

  @override
  String get authVerifyCode => 'Tasdiqlash';

  @override
  String get authChangePhone => 'Raqamni o\'zgartirish';

  @override
  String get authResendCode => 'Qayta yuborish';

  @override
  String authResendIn(int seconds) {
    return '$seconds s dan keyin qayta yuborish';
  }

  @override
  String get authCodeResent => 'Yangi kod yuborildi.';

  @override
  String get authTelegramSignIn => 'Telegram orqali kirish';

  @override
  String get authTermsAgree =>
      'Foydalanish shartlari va Maxfiylik siyosatini qabul qilaman';

  @override
  String get authSignInFailed =>
      'Telegram orqali kirib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get authSignInNoConnection =>
      'Telegram bilan aloqa yo\'q. Internetni tekshirib, qayta urinib ko\'ring.';

  @override
  String get authSignInUnavailable =>
      'Bu versiyada Telegram orqali kirish mavjud emas.';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppL10nUzCyrl extends AppL10nUz {
  AppL10nUzCyrl() : super('uz_Cyrl');

  @override
  String get appTitle => 'HeadHunter';

  @override
  String get commonRetry => 'Қайта уриниш';

  @override
  String get commonCancel => 'Бекор қилиш';

  @override
  String get commonSave => 'Сақлаш';

  @override
  String get commonNext => 'Кейинги';

  @override
  String get commonBack => 'Орқага';

  @override
  String get commonClose => 'Ёпиш';

  @override
  String get commonSearch => 'Қидириш';

  @override
  String get commonEdit => 'Таҳрирлаш';

  @override
  String get commonDelete => 'Ўчириш';

  @override
  String get commonSignOut => 'Чиқиш';

  @override
  String get stateLoading => 'Юкланмоқда…';

  @override
  String get stateEmptyTitle => 'Ҳозирча бўш';

  @override
  String get stateEmptyBody =>
      'Бу экранда ҳозирча кўрсатиладиган маълумот йўқ.';

  @override
  String get stateErrorTitle => 'Нимадир хато кетди';

  @override
  String get stateErrorBody => 'Сўровни бажариб бўлмади. Қайта уриниб кўринг.';

  @override
  String get stateOfflineTitle => 'Интернет алоқаси йўқ';

  @override
  String get stateOfflineBody => 'Алоқани текширинг ва қайта уриниб кўринг.';

  @override
  String get statePermissionDeniedTitle => 'Рухсат керак';

  @override
  String get statePermissionDeniedBody =>
      'Давом этиш учун Созламаларда рухсат беринг.';

  @override
  String get sessionExpired =>
      'Сессия муддати тугади. Илтимос, қайтадан киринг.';

  @override
  String get settingsLanguage => 'Тил';

  @override
  String get roleCandidate => 'Номзод';

  @override
  String get roleEmployer => 'Иш берувчи';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get navHome => 'Бош саҳифа';

  @override
  String get navVacancies => 'Вакансиялар';

  @override
  String get navApplications => 'Аризалар';

  @override
  String get navMessages => 'Хабарлар';

  @override
  String get navProfile => 'Профил';

  @override
  String get navCandidates => 'Номзодлар';

  @override
  String get navCompany => 'Компания';

  @override
  String get navDashboard => 'Бошқарув';

  @override
  String get navQueue => 'Модерация';

  @override
  String get navComplaints => 'Шикоятлар';

  @override
  String get navUsers => 'Фойдалан­увчилар';

  @override
  String get navDictionaries => 'Луғатлар';

  @override
  String get blockedTitle => 'Ҳисоб блокланган';

  @override
  String get blockedBody =>
      'Администратор бу ҳисобни блоклаган. Блок олиб ташланмагунча иловадан фойдалана олмайсиз.';

  @override
  String get profileCompleteness => 'Профил тўлдирилганлиги';

  @override
  String profileMissingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Яна $count та мажбурий майдон',
    );
    return '$_temp0';
  }

  @override
  String get profileSearchable => 'Қидирувда кўринади';

  @override
  String get profileNotSearchable => 'Ҳозирча қидирувда эмас';

  @override
  String get profileSaved => 'Профил сақланди';

  @override
  String get profileSectionElsewhere =>
      'Бу бўлимнинг алоҳида таҳрирлагичи бор, у кейинроқ қўшилади.';

  @override
  String get profileFieldNotEditableYet =>
      'Бу майдонни илованинг ушбу версиясида ўзгартириб бўлмайди.';

  @override
  String get profileChooseParentFirst => 'Аввал юқоридаги майдонни танланг';

  @override
  String get profileDateHint => 'ЙЙЙЙ-ОО-КК';

  @override
  String get profileSalaryFrom => 'Дан';

  @override
  String get profileSalaryTo => 'Гача';

  @override
  String get profileSalaryNegotiable => 'Келишув асосида';

  @override
  String get historyDeleteTitle => 'Ёзув ўчирилсинми?';

  @override
  String get historyDeleteMessage => 'У профилингиздан ўчирилади.';

  @override
  String get experienceEmpty => 'Иш тажрибаси қўшилмаган';

  @override
  String get experienceAdd => 'Тажриба қўшиш';

  @override
  String get experienceEmployer => 'Иш берувчи';

  @override
  String get experienceRole => 'Лавозим';

  @override
  String get experienceOccupation => 'Касб';

  @override
  String get experienceStarted => 'Бошланган сана';

  @override
  String get experienceEnded => 'Тугаган сана';

  @override
  String get experienceCurrent => 'Ҳозир шу ерда ишлайман';

  @override
  String get experienceResponsibilities => 'Вазифалар';

  @override
  String get experiencePresent => 'Ҳозиргача';

  @override
  String get educationEmpty => 'Таълим қўшилмаган';

  @override
  String get educationAdd => 'Таълим қўшиш';

  @override
  String get educationLevel => 'Таълим даражаси';

  @override
  String get educationInstitution => 'Ўқув муассасаси';

  @override
  String get educationSpecialization => 'Мутахассислик';

  @override
  String get educationYear => 'Тугатган йили';

  @override
  String get leveledChangeLevel => 'Даража';

  @override
  String get pickerChoose => 'Танлаш';

  @override
  String get pickerAdd => 'Қўшиш';

  @override
  String get pickerSearchHint => 'Қидириш учун ёзинг';

  @override
  String get pickerNoMatches => 'Ҳеч нарса топилмади.';

  @override
  String get pickerNothingSelected => 'Ҳозирча танланмаган';

  @override
  String get pickerUnknownValue => 'Мавжуд бўлмаган қиймат';

  @override
  String get authSignInTitle => 'Кириш';

  @override
  String get authPhoneLabel => 'Телефон рақами';

  @override
  String get authPhoneHint => '90 123 45 67';

  @override
  String get authPhoneInvalid => '9 та рақам киритинг, масалан 90 123 45 67.';

  @override
  String get authSendCode => 'Код олиш';

  @override
  String get authCodeTitle => 'Кодни киритинг';

  @override
  String authCodeSentTo(String phone) {
    return '$phone рақамига код юбордик.';
  }

  @override
  String get authCodeLabel => 'Код';

  @override
  String authCodeInvalid(int length) {
    return '$length хонали кодни киритинг.';
  }

  @override
  String get authVerifyCode => 'Тасдиқлаш';

  @override
  String get authChangePhone => 'Рақамни ўзгартириш';

  @override
  String get authResendCode => 'Қайта юбориш';

  @override
  String authResendIn(int seconds) {
    return '$seconds с дан кейин қайта юбориш';
  }

  @override
  String get authCodeResent => 'Янги код юборилди.';

  @override
  String get authTelegramSignIn => 'Telegram орқали кириш';

  @override
  String get authTermsAgree =>
      'Фойдаланиш шартлари ва Махфийлик сиёсатини қабул қиламан';

  @override
  String get authSignInFailed =>
      'Telegram орқали кириб бўлмади. Қайта уриниб кўринг.';

  @override
  String get authSignInNoConnection =>
      'Telegram билан алоқа йўқ. Интернетни текшириб, қайта уриниб кўринг.';

  @override
  String get authSignInUnavailable =>
      'Бу версияда Telegram орқали кириш мавжуд эмас.';
}

/// The translations for Uzbek, using the Latin script (`uz_Latn`).
class AppL10nUzLatn extends AppL10nUz {
  AppL10nUzLatn() : super('uz_Latn');

  @override
  String get appTitle => 'HeadHunter';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonNext => 'Keyingi';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonSearch => 'Qidirish';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonSignOut => 'Chiqish';

  @override
  String get stateLoading => 'Yuklanmoqda…';

  @override
  String get stateEmptyTitle => 'Hozircha bo\'sh';

  @override
  String get stateEmptyBody =>
      'Bu ekranda hozircha ko\'rsatiladigan ma\'lumot yo\'q.';

  @override
  String get stateErrorTitle => 'Nimadir xato ketdi';

  @override
  String get stateErrorBody =>
      'So\'rovni bajarib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get stateOfflineTitle => 'Internet aloqasi yo\'q';

  @override
  String get stateOfflineBody => 'Aloqani tekshiring va qayta urinib ko\'ring.';

  @override
  String get statePermissionDeniedTitle => 'Ruxsat kerak';

  @override
  String get statePermissionDeniedBody =>
      'Davom etish uchun Sozlamalarda ruxsat bering.';

  @override
  String get sessionExpired =>
      'Sessiya muddati tugadi. Iltimos, qaytadan kiring.';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get roleCandidate => 'Nomzod';

  @override
  String get roleEmployer => 'Ish beruvchi';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navVacancies => 'Vakansiyalar';

  @override
  String get navApplications => 'Arizalar';

  @override
  String get navMessages => 'Xabarlar';

  @override
  String get navProfile => 'Profil';

  @override
  String get navCandidates => 'Nomzodlar';

  @override
  String get navCompany => 'Kompaniya';

  @override
  String get navDashboard => 'Boshqaruv';

  @override
  String get navQueue => 'Moderatsiya';

  @override
  String get navComplaints => 'Shikoyatlar';

  @override
  String get navUsers => 'Foydalan­uvchilar';

  @override
  String get navDictionaries => 'Lug\'atlar';

  @override
  String get blockedTitle => 'Hisob bloklangan';

  @override
  String get blockedBody =>
      'Administrator bu hisobni bloklagan. Blok olib tashlanmaguncha ilovadan foydalana olmaysiz.';

  @override
  String get profileCompleteness => 'Profil toʻldirilganligi';

  @override
  String profileMissingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yana $count ta majburiy maydon',
    );
    return '$_temp0';
  }

  @override
  String get profileSearchable => 'Qidiruvda koʻrinadi';

  @override
  String get profileNotSearchable => 'Hozircha qidiruvda emas';

  @override
  String get profileSaved => 'Profil saqlandi';

  @override
  String get profileSectionElsewhere =>
      'Bu boʻlimning alohida tahrirlagichi bor, u keyinroq qoʻshiladi.';

  @override
  String get profileFieldNotEditableYet =>
      'Bu maydonni ilovaning ushbu versiyasida oʻzgartirib boʻlmaydi.';

  @override
  String get profileChooseParentFirst => 'Avval yuqoridagi maydonni tanlang';

  @override
  String get profileDateHint => 'YYYY-OO-KK';

  @override
  String get profileSalaryFrom => 'Dan';

  @override
  String get profileSalaryTo => 'Gacha';

  @override
  String get profileSalaryNegotiable => 'Kelishuv asosida';

  @override
  String get historyDeleteTitle => 'Yozuv o\'chirilsinmi?';

  @override
  String get historyDeleteMessage => 'U profilingizdan o\'chiriladi.';

  @override
  String get experienceEmpty => 'Ish tajribasi qo\'shilmagan';

  @override
  String get experienceAdd => 'Tajriba qo\'shish';

  @override
  String get experienceEmployer => 'Ish beruvchi';

  @override
  String get experienceRole => 'Lavozim';

  @override
  String get experienceOccupation => 'Kasb';

  @override
  String get experienceStarted => 'Boshlangan sana';

  @override
  String get experienceEnded => 'Tugagan sana';

  @override
  String get experienceCurrent => 'Hozir shu yerda ishlayman';

  @override
  String get experienceResponsibilities => 'Vazifalar';

  @override
  String get experiencePresent => 'Hozirgacha';

  @override
  String get educationEmpty => 'Ta\'lim qo\'shilmagan';

  @override
  String get educationAdd => 'Ta\'lim qo\'shish';

  @override
  String get educationLevel => 'Ta\'lim darajasi';

  @override
  String get educationInstitution => 'O\'quv muassasasi';

  @override
  String get educationSpecialization => 'Mutaxassislik';

  @override
  String get educationYear => 'Tugatgan yili';

  @override
  String get leveledChangeLevel => 'Daraja';

  @override
  String get pickerChoose => 'Tanlash';

  @override
  String get pickerAdd => 'Qo\'shish';

  @override
  String get pickerSearchHint => 'Qidirish uchun yozing';

  @override
  String get pickerNoMatches => 'Hech narsa topilmadi.';

  @override
  String get pickerNothingSelected => 'Hozircha tanlanmagan';

  @override
  String get pickerUnknownValue => 'Mavjud boʻlmagan qiymat';

  @override
  String get authSignInTitle => 'Kirish';

  @override
  String get authPhoneLabel => 'Telefon raqami';

  @override
  String get authPhoneHint => '90 123 45 67';

  @override
  String get authPhoneInvalid => '9 ta raqam kiriting, masalan 90 123 45 67.';

  @override
  String get authSendCode => 'Kod olish';

  @override
  String get authCodeTitle => 'Kodni kiriting';

  @override
  String authCodeSentTo(String phone) {
    return '$phone raqamiga kod yubordik.';
  }

  @override
  String get authCodeLabel => 'Kod';

  @override
  String authCodeInvalid(int length) {
    return '$length xonali kodni kiriting.';
  }

  @override
  String get authVerifyCode => 'Tasdiqlash';

  @override
  String get authChangePhone => 'Raqamni o\'zgartirish';

  @override
  String get authResendCode => 'Qayta yuborish';

  @override
  String authResendIn(int seconds) {
    return '$seconds s dan keyin qayta yuborish';
  }

  @override
  String get authCodeResent => 'Yangi kod yuborildi.';

  @override
  String get authTelegramSignIn => 'Telegram orqali kirish';

  @override
  String get authTermsAgree =>
      'Foydalanish shartlari va Maxfiylik siyosatini qabul qilaman';

  @override
  String get authSignInFailed =>
      'Telegram orqali kirib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get authSignInNoConnection =>
      'Telegram bilan aloqa yo\'q. Internetni tekshirib, qayta urinib ko\'ring.';

  @override
  String get authSignInUnavailable =>
      'Bu versiyada Telegram orqali kirish mavjud emas.';
}
