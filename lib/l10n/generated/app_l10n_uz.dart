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
  String profileLastUpdated(String date) {
    return 'Yangilangan $date';
  }

  @override
  String get profileFixField => 'To\'ldirish';

  @override
  String get profileVisibilityTitle => 'Sizni kim topa oladi';

  @override
  String get profileVisibilitySearchable => 'Qidiruvda ko\'rinadi';

  @override
  String get profileVisibilitySearchableHint =>
      'Ish beruvchilar sizni nomzodlar qidiruvida topa oladi.';

  @override
  String get profileVisibilityHidden => 'Qidiruvdan yashirilgan';

  @override
  String get profileVisibilityHiddenHint =>
      'Siz vakansiyalarni ko\'rishingiz va ariza yuborishingiz mumkin. Ish beruvchilar sizni topa olmaydi.';

  @override
  String get profileVisibilityAfterApply =>
      'Ariza yuborgandan keyin ko\'rinadi';

  @override
  String get profileVisibilityAfterApplyHint =>
      'Profilingizni faqat siz ariza yuborgan vakansiya egalari ko\'radi.';

  @override
  String get feedRecommended => 'Tavsiya etilgan';

  @override
  String get feedRecent => 'Yangi';

  @override
  String get feedSaved => 'Saqlangan';

  @override
  String get feedEmpty => 'Hozircha ko\'rsatadigan narsa yo\'q';

  @override
  String get vacancyVerifiedEmployer => 'Tasdiqlangan ish beruvchi';

  @override
  String get vacancyNegotiablePay => 'To\'lov kelishiladi';

  @override
  String vacancyDeadline(String date) {
    return '$date gacha ariza';
  }

  @override
  String get vacancyApply => 'Ariza yuborish';

  @override
  String get vacancyApplied => 'Ariza yuborilgan';

  @override
  String get vacancyClosedToApplications => 'Arizalar qabul qilinmaydi';

  @override
  String get vacancySave => 'Saqlash';

  @override
  String get vacancySaved => 'Saqlangan';

  @override
  String get vacancyReport => 'Shikoyat';

  @override
  String get vacancyReportTitle => 'Vakansiya ustidan shikoyat';

  @override
  String get vacancyReportHint => 'Unda nima noto\'g\'ri?';

  @override
  String get vacancyReported => 'Rahmat. Moderator ko\'rib chiqadi.';

  @override
  String get applicationsMine => 'Sizning arizalaringiz';

  @override
  String get applicationsEmpty => 'Siz hali ariza yubormagansiz';

  @override
  String get applicationWithdraw => 'Qaytarib olish';

  @override
  String get applicationWithdrawTitle => 'Ariza qaytarib olinsinmi?';

  @override
  String get stageSubmitted => 'Yuborilgan';

  @override
  String get stageViewed => 'Ko\'rilgan';

  @override
  String get stageShortlisted => 'Short-listda';

  @override
  String get stageInterview => 'Suhbat';

  @override
  String get stageOffer => 'Taklif';

  @override
  String get stageHired => 'Qabul qilingan';

  @override
  String get stageRejected => 'Tanlanmadi';

  @override
  String get stageWithdrawn => 'Qaytarib olingan';

  @override
  String get vacancyMine => 'Sizning vakansiyalaringiz';

  @override
  String get vacancyNew => 'Yangi vakansiya';

  @override
  String get vacancyNone => 'Hozircha vakansiyalar yo\'q';

  @override
  String get vacancyUntitled => 'Nomsiz vakansiya';

  @override
  String get vacancyStatusDraft => 'Qoralama';

  @override
  String get vacancyStatusModeration => 'Ko\'rib chiqilmoqda';

  @override
  String get vacancyStatusActive => 'E\'lon qilingan';

  @override
  String get vacancyStatusPaused => 'To\'xtatilgan';

  @override
  String get vacancyStatusClosed => 'Yopilgan';

  @override
  String get vacancyStatusRejected => 'Rad etilgan';

  @override
  String get vacancySubmit => 'E\'lon qilishga yuborish';

  @override
  String get vacancyPause => 'To\'xtatish';

  @override
  String get vacancyResume => 'Davom ettirish';

  @override
  String get vacancyClose => 'Yopish';

  @override
  String get vacancyCloseTitle => 'Vakansiya yopilsinmi?';

  @override
  String get vacancyCloseMessage =>
      'Yopish qaytarilmaydi. Vakansiya qidiruvdan chiqadi va tarixda qoladi.';

  @override
  String vacancyMissingForSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yana $count ta maydonni to\'ldiring',
    );
    return '$_temp0';
  }

  @override
  String get vacancyNotEditable => 'Bu vakansiyani hozir tahrirlab bo\'lmaydi.';

  @override
  String get vacancyOpenForApplications => 'Arizalar qabul qilinmoqda';

  @override
  String get vacancyRestrictionTitle => 'Yosh va jins bo\'yicha cheklashlar';

  @override
  String get vacancyRestrictionWarning =>
      'Yosh va jins bo\'yicha cheklashlar asoslashni talab qiladi va har doim moderator tomonidan tekshiriladi.';

  @override
  String get employerChooseType => 'Siz qanday ish beruvchisiz?';

  @override
  String get employerTypeCompany => 'Tashkilot';

  @override
  String get employerTypeCompanyHint =>
      'Tashkilot nomidan ishga oluvchi ro\'yxatdan o\'tgan biznes.';

  @override
  String get employerTypeIndividual => 'Jismoniy shaxs';

  @override
  String get employerTypeIndividualHint =>
      'Uy yoki shaxsiy ish uchun odam yollaysiz.';

  @override
  String get employerTypeFixed =>
      'Bir marta tanlanadi va keyin o\'zgartirib bo\'lmaydi.';

  @override
  String get employerDetails => 'Ish beruvchi ma\'lumotlari';

  @override
  String get employerLegalName => 'Rasmiy nomi';

  @override
  String get employerPublicName => 'Nomzodlarga ko\'rinadigan nom';

  @override
  String get employerFullName => 'To\'liq ismingiz';

  @override
  String get employerIndustry => 'Soha';

  @override
  String get employerContactPerson => 'Aloqa uchun shaxs';

  @override
  String get employerContactPhone => 'Aloqa telefoni';

  @override
  String get employerRegion => 'Viloyat';

  @override
  String get employerDistrict => 'Tuman yoki shahar';

  @override
  String get employerAddress => 'Manzil';

  @override
  String get employerDescription => 'Tavsif';

  @override
  String get employerVerification => 'Tasdiqlash';

  @override
  String get employerVerificationNotSubmitted => 'Yuborilmagan';

  @override
  String get employerVerificationUnderReview => 'Ko\'rib chiqilmoqda';

  @override
  String get employerVerificationVerified => 'Tasdiqlangan';

  @override
  String get employerVerificationRejected => 'Rad etilgan';

  @override
  String get employerVerificationChangesRequired => 'Tuzatish talab qilinadi';

  @override
  String get employerSubmitVerification => 'Tasdiqlashga yuborish';

  @override
  String get employerEvidence => 'Kerakli hujjatlar';

  @override
  String get employerEvidenceRequired => 'Majburiy';

  @override
  String get employerEvidenceOptional => 'Ixtiyoriy';

  @override
  String get employerCannotPublish =>
      'Vakansiya joylash va nomzod taklif qilish uchun profilni to\'ldiring va tasdiqdan o\'ting.';

  @override
  String get employerCanPublish =>
      'Siz vakansiya joylashingiz va nomzodlarni taklif qilishingiz mumkin.';

  @override
  String get employerSaveFirst =>
      'Tasdiqlashga yuborishdan oldin ma\'lumotlarni saqlang.';

  @override
  String get attachmentsTitle => 'Hujjatlar';

  @override
  String get attachmentUpload => 'Yuklash';

  @override
  String get attachmentReplace => 'Almashtirish';

  @override
  String attachmentUploading(String percent) {
    return 'Yuklanmoqda… $percent%';
  }

  @override
  String get attachmentNone => 'Hech narsa yuklanmagan';

  @override
  String attachmentTooLarge(String limit) {
    return 'Fayl $limit MB dan katta.';
  }

  @override
  String attachmentWrongType(String types) {
    return '$types formatidagi faylni tanlang.';
  }

  @override
  String get attachmentDeleteTitle => 'Fayl o\'chirilsinmi?';

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

  @override
  String get vacancyApplicants => 'Arizalar';

  @override
  String get vacancyApplicantsEmpty => 'Hozircha arizalar yo\'q';

  @override
  String applicationsHired(int hired, int required) {
    return '$required tadan $hired tasi qabul qilindi';
  }

  @override
  String applicationsHiredNoTarget(int hired) {
    return '$hired tasi qabul qilindi';
  }

  @override
  String get applicationMoveTo => 'Bosqichga o\'tkazish';

  @override
  String get applicationRejectReason => 'Sabab (nomzod ko\'radi)';

  @override
  String get candidatePhoneHidden => 'Telefon mavjud emas';

  @override
  String get candidatePhoneHiddenWhy =>
      'Nomzodning maxfiylik sozlamalari ish beruvchi uni qachon ko\'rishini belgilaydi.';

  @override
  String get candidateFilesHidden => 'Fayllar mavjud emas';

  @override
  String candidateCompleteness(int percent) {
    return 'Profil $percent% to’ldirilgan';
  }

  @override
  String get notesTitle => 'Shaxsiy eslatmalar';

  @override
  String get notesHint => 'Ularni faqat siz ko’rasiz';

  @override
  String get notesAdd => 'Eslatma qo’shish';

  @override
  String get searchCandidates => 'Nomzodlar qidiruvi';

  @override
  String get searchRun => 'Qidirish';

  @override
  String searchCountExact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta nomzod',
    );
    return '$_temp0';
  }

  @override
  String searchCountCapped(int count) {
    return '$count+ nomzod';
  }

  @override
  String get searchNoResults => 'Bu filtrlar bo’yicha hech kim topilmadi';

  @override
  String get searchSaved => 'Saqlangan nomzodlar';

  @override
  String searchMatch(int percent) {
    return 'Moslik $percent%';
  }

  @override
  String searchExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yil tajriba',
    );
    return '$_temp0';
  }

  @override
  String get searchShortlist => 'Short-listga';

  @override
  String get searchShortlisted => 'Short-listda';

  @override
  String get filtersTitle => 'Filtrlar';

  @override
  String get filtersApply => 'Filtrlarni qo’llash';

  @override
  String get filtersReset => 'Tozalash';

  @override
  String get filtersEdit => 'Filtrlar';

  @override
  String get filtersClearAll => 'Hammasini tozalash';

  @override
  String get filtersNone => 'Filtrsiz — qidiruvga ochiq barcha nomzodlar';

  @override
  String get filtersBlockedTitle => 'Hozircha qidirib bo’lmaydi';

  @override
  String get filtersOccupation => 'Kasb';

  @override
  String get filtersSkills => 'Ko’nikmalar';

  @override
  String get filtersExperience => 'Tajriba';

  @override
  String get filtersLanguages => 'Tillar';

  @override
  String get filtersEducation => 'Ta’lim';

  @override
  String get filtersLocation => 'Joylashuv';

  @override
  String get filtersPreferences => 'Ish shartlari';

  @override
  String get filtersAvailability => 'Ishga tayyorlik';

  @override
  String get filtersAttributes => 'Qo’shimcha talablar';

  @override
  String get filtersProfile => 'Profil';

  @override
  String get filtersRestrictions => 'Cheklovlar';

  @override
  String get filtersSort => 'Saralash';

  @override
  String get filterOccupations => 'Kasblar';

  @override
  String get filterPrimaryOnly => 'Faqat asosiy kasb';

  @override
  String get filterPrimaryOnlyHint =>
      'Nomzodning barcha kasblari emas, asosiysi hisobga olinadi';

  @override
  String get filterOccupationLevels => 'Kasbiy daraja';

  @override
  String get filterCurrentOccupations => 'Hozirgi yoki oxirgi lavozim';

  @override
  String get filterSkills => 'Ko’nikmalar';

  @override
  String get filterMatchMode => 'Moslik';

  @override
  String get filterMatchAny => 'Har qanday';

  @override
  String get filterMatchAll => 'Barchasi';

  @override
  String get filterMinLevel => 'Eng past daraja';

  @override
  String get filterLevelAny => 'Har qanday daraja';

  @override
  String get filterExperienceYearsMin => 'Jami yillar, kamida';

  @override
  String get filterOccupationExperience => 'Shu kasbda yillar, kamida';

  @override
  String get filterOccupationExperienceNeedsOccupation =>
      'Avval kasbni tanlang';

  @override
  String get filterLanguages => 'Tillar';

  @override
  String get filterLanguageCertificate => 'Sertifikat talab qilinadi';

  @override
  String get filterEducationLevels => 'Ta’lim darajasi';

  @override
  String get filterSpecializations => 'Mutaxassislik';

  @override
  String get filterRegion => 'Viloyat';

  @override
  String get filterDistricts => 'Tumanlar';

  @override
  String get filterDistrictsNeedRegion => 'Avval viloyatni tanlang';

  @override
  String get filterWillingToRelocate => 'Ko’chib o’tishga tayyor';

  @override
  String get filterWillingToTravel => 'Xizmat safarlariga tayyor';

  @override
  String get filterProximityDistrict => 'Shu tumanga yaqin';

  @override
  String get filterProximityHint => '“Eng yaqin” saralashi uchun';

  @override
  String get filterEmploymentTypes => 'Bandlik turi';

  @override
  String get filterWorkFormats => 'Ish formati';

  @override
  String get filterShifts => 'Smena';

  @override
  String get filterSalaryMin => 'Maosh (dan)';

  @override
  String get filterSalaryMax => 'Maosh (gacha)';

  @override
  String get filterSalaryMaxHint =>
      'Ko’proq kutayotgan nomzod chiqarib tashlanadi. Kelishiladigan kutish esa mos keladi.';

  @override
  String get filterAvailableBy => 'Ishga tayyor (sana)';

  @override
  String get filterAvailableImmediately => 'Darhol ishga tayyor';

  @override
  String get filterAttributes => 'Guvohnoma, transport va asboblar';

  @override
  String get filterCrewSizeMin => 'Kamida shuncha kishilik brigada';

  @override
  String get filterMinCompleteness => 'Profil to’ldirilishi, kamida (%)';

  @override
  String get filterUpdatedSince => 'Yangilangan (sanadan)';

  @override
  String get filterAgeMin => 'Yosh (dan)';

  @override
  String get filterAgeMax => 'Yosh (gacha)';

  @override
  String get filterGender => 'Jins';

  @override
  String get filterJustification => 'Cheklov asosi';

  @override
  String get filterRestrictionRequired =>
      'Yosh yoki jins bo’yicha filtr uchun asos ko’rsatilishi shart. Har bir foydalanish qayd etiladi.';

  @override
  String get filterRestrictionExplain =>
      'Faqat ish haqiqatan talab qilgan holatda.';

  @override
  String get sortMatch => 'Mosligi bo’yicha';

  @override
  String get sortRecent => 'Yangilanishi bo’yicha';

  @override
  String get sortExperience => 'Tajribasi bo’yicha';

  @override
  String get sortSalary => 'Kutilgan maosh bo’yicha';

  @override
  String get sortProximity => 'Yaqinligi bo’yicha';

  @override
  String get commonLoadMore => 'Yana ko’rsatish';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String filterChipValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get searchFromVacancy => 'Nomzod topish';

  @override
  String get searchScopedToVacancy => 'Filtrlar vakansiyadan olindi';
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
  String profileLastUpdated(String date) {
    return 'Янгиланган $date';
  }

  @override
  String get profileFixField => 'Тўлдириш';

  @override
  String get profileVisibilityTitle => 'Сизни ким топа олади';

  @override
  String get profileVisibilitySearchable => 'Қидирувда кўринади';

  @override
  String get profileVisibilitySearchableHint =>
      'Иш берувчилар сизни номзодлар қидирувида топа олади.';

  @override
  String get profileVisibilityHidden => 'Қидирувдан яширилган';

  @override
  String get profileVisibilityHiddenHint =>
      'Сиз вакансияларни кўришингиз ва ариза юборишингиз мумкин. Иш берувчилар сизни топа олмайди.';

  @override
  String get profileVisibilityAfterApply => 'Ариза юборгандан кейин кўринади';

  @override
  String get profileVisibilityAfterApplyHint =>
      'Профилингизни фақат сиз ариза юборган вакансия эгалари кўради.';

  @override
  String get feedRecommended => 'Тавсия этилган';

  @override
  String get feedRecent => 'Янги';

  @override
  String get feedSaved => 'Сақланган';

  @override
  String get feedEmpty => 'Ҳозирча кўрсатадиган нарса йўқ';

  @override
  String get vacancyVerifiedEmployer => 'Тасдиқланган иш берувчи';

  @override
  String get vacancyNegotiablePay => 'Тўлов келишилади';

  @override
  String vacancyDeadline(String date) {
    return '$date гача ариза';
  }

  @override
  String get vacancyApply => 'Ариза юбориш';

  @override
  String get vacancyApplied => 'Ариза юборилган';

  @override
  String get vacancyClosedToApplications => 'Аризалар қабул қилинмайди';

  @override
  String get vacancySave => 'Сақлаш';

  @override
  String get vacancySaved => 'Сақланган';

  @override
  String get vacancyReport => 'Шикоят';

  @override
  String get vacancyReportTitle => 'Вакансия устидан шикоят';

  @override
  String get vacancyReportHint => 'Унда нима нотўғри?';

  @override
  String get vacancyReported => 'Раҳмат. Модератор кўриб чиқади.';

  @override
  String get applicationsMine => 'Сизнинг аризаларингиз';

  @override
  String get applicationsEmpty => 'Сиз ҳали ариза юбормагансиз';

  @override
  String get applicationWithdraw => 'Қайтариб олиш';

  @override
  String get applicationWithdrawTitle => 'Ариза қайтариб олинсинми?';

  @override
  String get stageSubmitted => 'Юборилган';

  @override
  String get stageViewed => 'Кўрилган';

  @override
  String get stageShortlisted => 'Шорт-листда';

  @override
  String get stageInterview => 'Суҳбат';

  @override
  String get stageOffer => 'Таклиф';

  @override
  String get stageHired => 'Қабул қилинган';

  @override
  String get stageRejected => 'Танланмади';

  @override
  String get stageWithdrawn => 'Қайтариб олинган';

  @override
  String get vacancyMine => 'Сизнинг вакансияларингиз';

  @override
  String get vacancyNew => 'Янги вакансия';

  @override
  String get vacancyNone => 'Ҳозирча вакансиялар йўқ';

  @override
  String get vacancyUntitled => 'Номсиз вакансия';

  @override
  String get vacancyStatusDraft => 'Қоралама';

  @override
  String get vacancyStatusModeration => 'Кўриб чиқилмоқда';

  @override
  String get vacancyStatusActive => 'Эълон қилинган';

  @override
  String get vacancyStatusPaused => 'Тўхтатилган';

  @override
  String get vacancyStatusClosed => 'Ёпилган';

  @override
  String get vacancyStatusRejected => 'Рад этилган';

  @override
  String get vacancySubmit => 'Эълон қилишга юбориш';

  @override
  String get vacancyPause => 'Тўхтатиш';

  @override
  String get vacancyResume => 'Давом эттириш';

  @override
  String get vacancyClose => 'Ёпиш';

  @override
  String get vacancyCloseTitle => 'Вакансия ёпилсинми?';

  @override
  String get vacancyCloseMessage =>
      'Ёпиш қайтарилмайди. Вакансия қидирувдан чиқади ва тарихда қолади.';

  @override
  String vacancyMissingForSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Яна $count та майдонни тўлдиринг',
    );
    return '$_temp0';
  }

  @override
  String get vacancyNotEditable => 'Бу вакансияни ҳозир таҳрирлаб бўлмайди.';

  @override
  String get vacancyOpenForApplications => 'Аризалар қабул қилинмоқда';

  @override
  String get vacancyRestrictionTitle => 'Ёш ва жинс бўйича чеклашлар';

  @override
  String get vacancyRestrictionWarning =>
      'Ёш ва жинс бўйича чеклашлар асослашни талаб қилади ва ҳар доим модератор томонидан текширилади.';

  @override
  String get employerChooseType => 'Сиз қандай иш берувчисиз?';

  @override
  String get employerTypeCompany => 'Ташкилот';

  @override
  String get employerTypeCompanyHint =>
      'Ташкилот номидан ишга олувчи рўйхатдан ўтган бизнес.';

  @override
  String get employerTypeIndividual => 'Жисмоний шахс';

  @override
  String get employerTypeIndividualHint =>
      'Уй ёки шахсий иш учун одам ёллайсиз.';

  @override
  String get employerTypeFixed =>
      'Бир марта танланади ва кейин ўзгартириб бўлмайди.';

  @override
  String get employerDetails => 'Иш берувчи маълумотлари';

  @override
  String get employerLegalName => 'Расмий номи';

  @override
  String get employerPublicName => 'Номзодларга кўринадиган ном';

  @override
  String get employerFullName => 'Тўлиқ исмингиз';

  @override
  String get employerIndustry => 'Соҳа';

  @override
  String get employerContactPerson => 'Алоқа учун шахс';

  @override
  String get employerContactPhone => 'Алоқа телефони';

  @override
  String get employerRegion => 'Вилоят';

  @override
  String get employerDistrict => 'Туман ёки шаҳар';

  @override
  String get employerAddress => 'Манзил';

  @override
  String get employerDescription => 'Тавсиф';

  @override
  String get employerVerification => 'Тасдиқлаш';

  @override
  String get employerVerificationNotSubmitted => 'Юборилмаган';

  @override
  String get employerVerificationUnderReview => 'Кўриб чиқилмоқда';

  @override
  String get employerVerificationVerified => 'Тасдиқланган';

  @override
  String get employerVerificationRejected => 'Рад этилган';

  @override
  String get employerVerificationChangesRequired => 'Тузатиш талаб қилинади';

  @override
  String get employerSubmitVerification => 'Тасдиқлашга юбориш';

  @override
  String get employerEvidence => 'Керакли ҳужжатлар';

  @override
  String get employerEvidenceRequired => 'Мажбурий';

  @override
  String get employerEvidenceOptional => 'Ихтиёрий';

  @override
  String get employerCannotPublish =>
      'Вакансия жойлаш ва номзод таклиф қилиш учун профилни тўлдиринг ва тасдиқдан ўтинг.';

  @override
  String get employerCanPublish =>
      'Сиз вакансия жойлашингиз ва номзодларни таклиф қилишингиз мумкин.';

  @override
  String get employerSaveFirst =>
      'Тасдиқлашга юборишдан олдин маълумотларни сақланг.';

  @override
  String get attachmentsTitle => 'Ҳужжатлар';

  @override
  String get attachmentUpload => 'Юклаш';

  @override
  String get attachmentReplace => 'Алмаштириш';

  @override
  String attachmentUploading(String percent) {
    return 'Юкланмоқда… $percent%';
  }

  @override
  String get attachmentNone => 'Ҳеч нарса юкланмаган';

  @override
  String attachmentTooLarge(String limit) {
    return 'Файл $limit МБ дан катта.';
  }

  @override
  String attachmentWrongType(String types) {
    return '$types форматидаги файлни танланг.';
  }

  @override
  String get attachmentDeleteTitle => 'Файл ўчирилсинми?';

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

  @override
  String get vacancyApplicants => 'Аризалар';

  @override
  String get vacancyApplicantsEmpty => 'Ҳозирча аризалар йўқ';

  @override
  String applicationsHired(int hired, int required) {
    return '$required тадан $hired таси қабул қилинди';
  }

  @override
  String applicationsHiredNoTarget(int hired) {
    return '$hired таси қабул қилинди';
  }

  @override
  String get applicationMoveTo => 'Босқичга ўтказиш';

  @override
  String get applicationRejectReason => 'Сабаб (номзод кўради)';

  @override
  String get candidatePhoneHidden => 'Телефон мавжуд эмас';

  @override
  String get candidatePhoneHiddenWhy =>
      'Номзоднинг махфийлик созламалари иш берувчи уни қачон кўришини белгилайди.';

  @override
  String get candidateFilesHidden => 'Файллар мавжуд эмас';

  @override
  String candidateCompleteness(int percent) {
    return 'Профил $percent% тўлдирилган';
  }

  @override
  String get notesTitle => 'Шахсий эслатмалар';

  @override
  String get notesHint => 'Уларни фақат сиз кўрасиз';

  @override
  String get notesAdd => 'Эслатма қўшиш';

  @override
  String get searchCandidates => 'Номзодлар қидируви';

  @override
  String get searchRun => 'Қидириш';

  @override
  String searchCountExact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count та номзод',
    );
    return '$_temp0';
  }

  @override
  String searchCountCapped(int count) {
    return '$count+ номзод';
  }

  @override
  String get searchNoResults => 'Бу фильтрлар бўйича ҳеч ким топилмади';

  @override
  String get searchSaved => 'Сақланган номзодлар';

  @override
  String searchMatch(int percent) {
    return 'Мослик $percent%';
  }

  @override
  String searchExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years йил тажриба',
    );
    return '$_temp0';
  }

  @override
  String get searchShortlist => 'Шорт-листга';

  @override
  String get searchShortlisted => 'Шорт-листда';

  @override
  String get filtersTitle => 'Филтрлар';

  @override
  String get filtersApply => 'Филтрларни қўллаш';

  @override
  String get filtersReset => 'Тозалаш';

  @override
  String get filtersEdit => 'Филтрлар';

  @override
  String get filtersClearAll => 'Ҳаммасини тозалаш';

  @override
  String get filtersNone => 'Филтрсиз — қидирувга очиқ барча номзодлар';

  @override
  String get filtersBlockedTitle => 'Ҳозирча қидириб бўлмайди';

  @override
  String get filtersOccupation => 'Касб';

  @override
  String get filtersSkills => 'Кўникмалар';

  @override
  String get filtersExperience => 'Тажриба';

  @override
  String get filtersLanguages => 'Тиллар';

  @override
  String get filtersEducation => 'Таълим';

  @override
  String get filtersLocation => 'Жойлашув';

  @override
  String get filtersPreferences => 'Иш шартлари';

  @override
  String get filtersAvailability => 'Ишга тайёрлик';

  @override
  String get filtersAttributes => 'Қўшимча талаблар';

  @override
  String get filtersProfile => 'Профил';

  @override
  String get filtersRestrictions => 'Чекловлар';

  @override
  String get filtersSort => 'Саралаш';

  @override
  String get filterOccupations => 'Касблар';

  @override
  String get filterPrimaryOnly => 'Фақат асосий касб';

  @override
  String get filterPrimaryOnlyHint =>
      'Номзоднинг барча касблари эмас, асосийси ҳисобга олинади';

  @override
  String get filterOccupationLevels => 'Касбий даража';

  @override
  String get filterCurrentOccupations => 'Ҳозирги ёки охирги лавозим';

  @override
  String get filterSkills => 'Кўникмалар';

  @override
  String get filterMatchMode => 'Мослик';

  @override
  String get filterMatchAny => 'Ҳар қандай';

  @override
  String get filterMatchAll => 'Барчаси';

  @override
  String get filterMinLevel => 'Энг паст даража';

  @override
  String get filterLevelAny => 'Ҳар қандай даража';

  @override
  String get filterExperienceYearsMin => 'Жами йиллар, камида';

  @override
  String get filterOccupationExperience => 'Шу касбда йиллар, камида';

  @override
  String get filterOccupationExperienceNeedsOccupation =>
      'Аввал касбни танланг';

  @override
  String get filterLanguages => 'Тиллар';

  @override
  String get filterLanguageCertificate => 'Сертификат талаб қилинади';

  @override
  String get filterEducationLevels => 'Таълим даражаси';

  @override
  String get filterSpecializations => 'Мутахассислик';

  @override
  String get filterRegion => 'Вилоят';

  @override
  String get filterDistricts => 'Туманлар';

  @override
  String get filterDistrictsNeedRegion => 'Аввал вилоятни танланг';

  @override
  String get filterWillingToRelocate => 'Кўчиб ўтишга тайёр';

  @override
  String get filterWillingToTravel => 'Хизмат сафарларига тайёр';

  @override
  String get filterProximityDistrict => 'Шу туманга яқин';

  @override
  String get filterProximityHint => '«Энг яқин» саралаши учун';

  @override
  String get filterEmploymentTypes => 'Бандлик тури';

  @override
  String get filterWorkFormats => 'Иш формати';

  @override
  String get filterShifts => 'Смена';

  @override
  String get filterSalaryMin => 'Маош (дан)';

  @override
  String get filterSalaryMax => 'Маош (гача)';

  @override
  String get filterSalaryMaxHint =>
      'Кўпроқ кутаётган номзод чиқариб ташланади. Келишиладиган кутиш эса мос келади.';

  @override
  String get filterAvailableBy => 'Ишга тайёр (сана)';

  @override
  String get filterAvailableImmediately => 'Дарҳол ишга тайёр';

  @override
  String get filterAttributes => 'Гувоҳнома, транспорт ва асбоблар';

  @override
  String get filterCrewSizeMin => 'Камида шунча кишилик бригада';

  @override
  String get filterMinCompleteness => 'Профил тўлдирилиши, камида (%)';

  @override
  String get filterUpdatedSince => 'Янгиланган (санадан)';

  @override
  String get filterAgeMin => 'Ёш (дан)';

  @override
  String get filterAgeMax => 'Ёш (гача)';

  @override
  String get filterGender => 'Жинс';

  @override
  String get filterJustification => 'Чеклов асоси';

  @override
  String get filterRestrictionRequired =>
      'Ёш ёки жинс бўйича филтр учун асос кўрсатилиши шарт. Ҳар бир фойдаланиш қайд этилади.';

  @override
  String get filterRestrictionExplain =>
      'Фақат иш ҳақиқатан талаб қилган ҳолатда.';

  @override
  String get sortMatch => 'Мослиги бўйича';

  @override
  String get sortRecent => 'Янгиланиши бўйича';

  @override
  String get sortExperience => 'Тажрибаси бўйича';

  @override
  String get sortSalary => 'Кутилган маош бўйича';

  @override
  String get sortProximity => 'Яқинлиги бўйича';

  @override
  String get commonLoadMore => 'Яна кўрсатиш';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String filterChipValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get searchFromVacancy => 'Номзод топиш';

  @override
  String get searchScopedToVacancy => 'Филтрлар вакансиядан олинди';
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
  String profileLastUpdated(String date) {
    return 'Yangilangan $date';
  }

  @override
  String get profileFixField => 'To\'ldirish';

  @override
  String get profileVisibilityTitle => 'Sizni kim topa oladi';

  @override
  String get profileVisibilitySearchable => 'Qidiruvda ko\'rinadi';

  @override
  String get profileVisibilitySearchableHint =>
      'Ish beruvchilar sizni nomzodlar qidiruvida topa oladi.';

  @override
  String get profileVisibilityHidden => 'Qidiruvdan yashirilgan';

  @override
  String get profileVisibilityHiddenHint =>
      'Siz vakansiyalarni ko\'rishingiz va ariza yuborishingiz mumkin. Ish beruvchilar sizni topa olmaydi.';

  @override
  String get profileVisibilityAfterApply =>
      'Ariza yuborgandan keyin ko\'rinadi';

  @override
  String get profileVisibilityAfterApplyHint =>
      'Profilingizni faqat siz ariza yuborgan vakansiya egalari ko\'radi.';

  @override
  String get feedRecommended => 'Tavsiya etilgan';

  @override
  String get feedRecent => 'Yangi';

  @override
  String get feedSaved => 'Saqlangan';

  @override
  String get feedEmpty => 'Hozircha ko\'rsatadigan narsa yo\'q';

  @override
  String get vacancyVerifiedEmployer => 'Tasdiqlangan ish beruvchi';

  @override
  String get vacancyNegotiablePay => 'To\'lov kelishiladi';

  @override
  String vacancyDeadline(String date) {
    return '$date gacha ariza';
  }

  @override
  String get vacancyApply => 'Ariza yuborish';

  @override
  String get vacancyApplied => 'Ariza yuborilgan';

  @override
  String get vacancyClosedToApplications => 'Arizalar qabul qilinmaydi';

  @override
  String get vacancySave => 'Saqlash';

  @override
  String get vacancySaved => 'Saqlangan';

  @override
  String get vacancyReport => 'Shikoyat';

  @override
  String get vacancyReportTitle => 'Vakansiya ustidan shikoyat';

  @override
  String get vacancyReportHint => 'Unda nima noto\'g\'ri?';

  @override
  String get vacancyReported => 'Rahmat. Moderator ko\'rib chiqadi.';

  @override
  String get applicationsMine => 'Sizning arizalaringiz';

  @override
  String get applicationsEmpty => 'Siz hali ariza yubormagansiz';

  @override
  String get applicationWithdraw => 'Qaytarib olish';

  @override
  String get applicationWithdrawTitle => 'Ariza qaytarib olinsinmi?';

  @override
  String get stageSubmitted => 'Yuborilgan';

  @override
  String get stageViewed => 'Ko\'rilgan';

  @override
  String get stageShortlisted => 'Short-listda';

  @override
  String get stageInterview => 'Suhbat';

  @override
  String get stageOffer => 'Taklif';

  @override
  String get stageHired => 'Qabul qilingan';

  @override
  String get stageRejected => 'Tanlanmadi';

  @override
  String get stageWithdrawn => 'Qaytarib olingan';

  @override
  String get vacancyMine => 'Sizning vakansiyalaringiz';

  @override
  String get vacancyNew => 'Yangi vakansiya';

  @override
  String get vacancyNone => 'Hozircha vakansiyalar yo\'q';

  @override
  String get vacancyUntitled => 'Nomsiz vakansiya';

  @override
  String get vacancyStatusDraft => 'Qoralama';

  @override
  String get vacancyStatusModeration => 'Ko\'rib chiqilmoqda';

  @override
  String get vacancyStatusActive => 'E\'lon qilingan';

  @override
  String get vacancyStatusPaused => 'To\'xtatilgan';

  @override
  String get vacancyStatusClosed => 'Yopilgan';

  @override
  String get vacancyStatusRejected => 'Rad etilgan';

  @override
  String get vacancySubmit => 'E\'lon qilishga yuborish';

  @override
  String get vacancyPause => 'To\'xtatish';

  @override
  String get vacancyResume => 'Davom ettirish';

  @override
  String get vacancyClose => 'Yopish';

  @override
  String get vacancyCloseTitle => 'Vakansiya yopilsinmi?';

  @override
  String get vacancyCloseMessage =>
      'Yopish qaytarilmaydi. Vakansiya qidiruvdan chiqadi va tarixda qoladi.';

  @override
  String vacancyMissingForSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yana $count ta maydonni to\'ldiring',
    );
    return '$_temp0';
  }

  @override
  String get vacancyNotEditable => 'Bu vakansiyani hozir tahrirlab bo\'lmaydi.';

  @override
  String get vacancyOpenForApplications => 'Arizalar qabul qilinmoqda';

  @override
  String get vacancyRestrictionTitle => 'Yosh va jins bo\'yicha cheklashlar';

  @override
  String get vacancyRestrictionWarning =>
      'Yosh va jins bo\'yicha cheklashlar asoslashni talab qiladi va har doim moderator tomonidan tekshiriladi.';

  @override
  String get employerChooseType => 'Siz qanday ish beruvchisiz?';

  @override
  String get employerTypeCompany => 'Tashkilot';

  @override
  String get employerTypeCompanyHint =>
      'Tashkilot nomidan ishga oluvchi ro\'yxatdan o\'tgan biznes.';

  @override
  String get employerTypeIndividual => 'Jismoniy shaxs';

  @override
  String get employerTypeIndividualHint =>
      'Uy yoki shaxsiy ish uchun odam yollaysiz.';

  @override
  String get employerTypeFixed =>
      'Bir marta tanlanadi va keyin o\'zgartirib bo\'lmaydi.';

  @override
  String get employerDetails => 'Ish beruvchi ma\'lumotlari';

  @override
  String get employerLegalName => 'Rasmiy nomi';

  @override
  String get employerPublicName => 'Nomzodlarga ko\'rinadigan nom';

  @override
  String get employerFullName => 'To\'liq ismingiz';

  @override
  String get employerIndustry => 'Soha';

  @override
  String get employerContactPerson => 'Aloqa uchun shaxs';

  @override
  String get employerContactPhone => 'Aloqa telefoni';

  @override
  String get employerRegion => 'Viloyat';

  @override
  String get employerDistrict => 'Tuman yoki shahar';

  @override
  String get employerAddress => 'Manzil';

  @override
  String get employerDescription => 'Tavsif';

  @override
  String get employerVerification => 'Tasdiqlash';

  @override
  String get employerVerificationNotSubmitted => 'Yuborilmagan';

  @override
  String get employerVerificationUnderReview => 'Ko\'rib chiqilmoqda';

  @override
  String get employerVerificationVerified => 'Tasdiqlangan';

  @override
  String get employerVerificationRejected => 'Rad etilgan';

  @override
  String get employerVerificationChangesRequired => 'Tuzatish talab qilinadi';

  @override
  String get employerSubmitVerification => 'Tasdiqlashga yuborish';

  @override
  String get employerEvidence => 'Kerakli hujjatlar';

  @override
  String get employerEvidenceRequired => 'Majburiy';

  @override
  String get employerEvidenceOptional => 'Ixtiyoriy';

  @override
  String get employerCannotPublish =>
      'Vakansiya joylash va nomzod taklif qilish uchun profilni to\'ldiring va tasdiqdan o\'ting.';

  @override
  String get employerCanPublish =>
      'Siz vakansiya joylashingiz va nomzodlarni taklif qilishingiz mumkin.';

  @override
  String get employerSaveFirst =>
      'Tasdiqlashga yuborishdan oldin ma\'lumotlarni saqlang.';

  @override
  String get attachmentsTitle => 'Hujjatlar';

  @override
  String get attachmentUpload => 'Yuklash';

  @override
  String get attachmentReplace => 'Almashtirish';

  @override
  String attachmentUploading(String percent) {
    return 'Yuklanmoqda… $percent%';
  }

  @override
  String get attachmentNone => 'Hech narsa yuklanmagan';

  @override
  String attachmentTooLarge(String limit) {
    return 'Fayl $limit MB dan katta.';
  }

  @override
  String attachmentWrongType(String types) {
    return '$types formatidagi faylni tanlang.';
  }

  @override
  String get attachmentDeleteTitle => 'Fayl o\'chirilsinmi?';

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

  @override
  String get vacancyApplicants => 'Arizalar';

  @override
  String get vacancyApplicantsEmpty => 'Hozircha arizalar yo\'q';

  @override
  String applicationsHired(int hired, int required) {
    return '$required tadan $hired tasi qabul qilindi';
  }

  @override
  String applicationsHiredNoTarget(int hired) {
    return '$hired tasi qabul qilindi';
  }

  @override
  String get applicationMoveTo => 'Bosqichga o\'tkazish';

  @override
  String get applicationRejectReason => 'Sabab (nomzod ko\'radi)';

  @override
  String get candidatePhoneHidden => 'Telefon mavjud emas';

  @override
  String get candidatePhoneHiddenWhy =>
      'Nomzodning maxfiylik sozlamalari ish beruvchi uni qachon ko\'rishini belgilaydi.';

  @override
  String get candidateFilesHidden => 'Fayllar mavjud emas';

  @override
  String candidateCompleteness(int percent) {
    return 'Profil $percent% to’ldirilgan';
  }

  @override
  String get notesTitle => 'Shaxsiy eslatmalar';

  @override
  String get notesHint => 'Ularni faqat siz ko’rasiz';

  @override
  String get notesAdd => 'Eslatma qo’shish';

  @override
  String get searchCandidates => 'Nomzodlar qidiruvi';

  @override
  String get searchRun => 'Qidirish';

  @override
  String searchCountExact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta nomzod',
    );
    return '$_temp0';
  }

  @override
  String searchCountCapped(int count) {
    return '$count+ nomzod';
  }

  @override
  String get searchNoResults => 'Bu filtrlar bo’yicha hech kim topilmadi';

  @override
  String get searchSaved => 'Saqlangan nomzodlar';

  @override
  String searchMatch(int percent) {
    return 'Moslik $percent%';
  }

  @override
  String searchExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yil tajriba',
    );
    return '$_temp0';
  }

  @override
  String get searchShortlist => 'Short-listga';

  @override
  String get searchShortlisted => 'Short-listda';

  @override
  String get filtersTitle => 'Filtrlar';

  @override
  String get filtersApply => 'Filtrlarni qo’llash';

  @override
  String get filtersReset => 'Tozalash';

  @override
  String get filtersEdit => 'Filtrlar';

  @override
  String get filtersClearAll => 'Hammasini tozalash';

  @override
  String get filtersNone => 'Filtrsiz — qidiruvga ochiq barcha nomzodlar';

  @override
  String get filtersBlockedTitle => 'Hozircha qidirib bo’lmaydi';

  @override
  String get filtersOccupation => 'Kasb';

  @override
  String get filtersSkills => 'Ko’nikmalar';

  @override
  String get filtersExperience => 'Tajriba';

  @override
  String get filtersLanguages => 'Tillar';

  @override
  String get filtersEducation => 'Ta’lim';

  @override
  String get filtersLocation => 'Joylashuv';

  @override
  String get filtersPreferences => 'Ish shartlari';

  @override
  String get filtersAvailability => 'Ishga tayyorlik';

  @override
  String get filtersAttributes => 'Qo’shimcha talablar';

  @override
  String get filtersProfile => 'Profil';

  @override
  String get filtersRestrictions => 'Cheklovlar';

  @override
  String get filtersSort => 'Saralash';

  @override
  String get filterOccupations => 'Kasblar';

  @override
  String get filterPrimaryOnly => 'Faqat asosiy kasb';

  @override
  String get filterPrimaryOnlyHint =>
      'Nomzodning barcha kasblari emas, asosiysi hisobga olinadi';

  @override
  String get filterOccupationLevels => 'Kasbiy daraja';

  @override
  String get filterCurrentOccupations => 'Hozirgi yoki oxirgi lavozim';

  @override
  String get filterSkills => 'Ko’nikmalar';

  @override
  String get filterMatchMode => 'Moslik';

  @override
  String get filterMatchAny => 'Har qanday';

  @override
  String get filterMatchAll => 'Barchasi';

  @override
  String get filterMinLevel => 'Eng past daraja';

  @override
  String get filterLevelAny => 'Har qanday daraja';

  @override
  String get filterExperienceYearsMin => 'Jami yillar, kamida';

  @override
  String get filterOccupationExperience => 'Shu kasbda yillar, kamida';

  @override
  String get filterOccupationExperienceNeedsOccupation =>
      'Avval kasbni tanlang';

  @override
  String get filterLanguages => 'Tillar';

  @override
  String get filterLanguageCertificate => 'Sertifikat talab qilinadi';

  @override
  String get filterEducationLevels => 'Ta’lim darajasi';

  @override
  String get filterSpecializations => 'Mutaxassislik';

  @override
  String get filterRegion => 'Viloyat';

  @override
  String get filterDistricts => 'Tumanlar';

  @override
  String get filterDistrictsNeedRegion => 'Avval viloyatni tanlang';

  @override
  String get filterWillingToRelocate => 'Ko’chib o’tishga tayyor';

  @override
  String get filterWillingToTravel => 'Xizmat safarlariga tayyor';

  @override
  String get filterProximityDistrict => 'Shu tumanga yaqin';

  @override
  String get filterProximityHint => '“Eng yaqin” saralashi uchun';

  @override
  String get filterEmploymentTypes => 'Bandlik turi';

  @override
  String get filterWorkFormats => 'Ish formati';

  @override
  String get filterShifts => 'Smena';

  @override
  String get filterSalaryMin => 'Maosh (dan)';

  @override
  String get filterSalaryMax => 'Maosh (gacha)';

  @override
  String get filterSalaryMaxHint =>
      'Ko’proq kutayotgan nomzod chiqarib tashlanadi. Kelishiladigan kutish esa mos keladi.';

  @override
  String get filterAvailableBy => 'Ishga tayyor (sana)';

  @override
  String get filterAvailableImmediately => 'Darhol ishga tayyor';

  @override
  String get filterAttributes => 'Guvohnoma, transport va asboblar';

  @override
  String get filterCrewSizeMin => 'Kamida shuncha kishilik brigada';

  @override
  String get filterMinCompleteness => 'Profil to’ldirilishi, kamida (%)';

  @override
  String get filterUpdatedSince => 'Yangilangan (sanadan)';

  @override
  String get filterAgeMin => 'Yosh (dan)';

  @override
  String get filterAgeMax => 'Yosh (gacha)';

  @override
  String get filterGender => 'Jins';

  @override
  String get filterJustification => 'Cheklov asosi';

  @override
  String get filterRestrictionRequired =>
      'Yosh yoki jins bo’yicha filtr uchun asos ko’rsatilishi shart. Har bir foydalanish qayd etiladi.';

  @override
  String get filterRestrictionExplain =>
      'Faqat ish haqiqatan talab qilgan holatda.';

  @override
  String get sortMatch => 'Mosligi bo’yicha';

  @override
  String get sortRecent => 'Yangilanishi bo’yicha';

  @override
  String get sortExperience => 'Tajribasi bo’yicha';

  @override
  String get sortSalary => 'Kutilgan maosh bo’yicha';

  @override
  String get sortProximity => 'Yaqinligi bo’yicha';

  @override
  String get commonLoadMore => 'Yana ko’rsatish';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String filterChipValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get searchFromVacancy => 'Nomzod topish';

  @override
  String get searchScopedToVacancy => 'Filtrlar vakansiyadan olindi';
}
