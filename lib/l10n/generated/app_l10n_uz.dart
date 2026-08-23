// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppL10nUz extends AppL10n {
  AppL10nUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'JobBridge';

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
  String get searchShortlist => 'Short-listga qo\'shish';

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

  @override
  String get candidateProfileTitle => 'Nomzod';

  @override
  String get candidateViewProfile => 'Profilni ochish';

  @override
  String get candidateContact => 'Aloqa';

  @override
  String candidateAvailableFrom(String date) {
    return '$date dan tayyor';
  }

  @override
  String get candidateAttachments => 'Ilovalar';

  @override
  String get candidateNoFiles => 'Nomzod hech narsa yuklamagan';

  @override
  String get candidatePhoneNotOnFile =>
      'Nomzodning telefon raqami ko’rsatilmagan.';

  @override
  String get candidateExposureNotVerified =>
      'Kompaniyangiz tasdiqlangach aloqa ma’lumotlari ochiladi.';

  @override
  String get candidateExposureNoInteraction =>
      'Nomzod vakansiyangizga ariza bergach yoki taklifni qabul qilgach aloqa ma’lumotlari ochiladi.';

  @override
  String get candidateExposureHidden =>
      'Nomzod profilini qidiruvdan yashirgan. U vakansiyalaringizni ko’ra oladi va ariza bera oladi.';

  @override
  String get searchSavedEmpty => 'Saqlangan nomzodlar yo’q';

  @override
  String get commonCopy => 'Nusxalash';

  @override
  String get commonCopied => 'Nusxalandi';

  @override
  String get vacancyDetailTitle => 'Vakansiya';

  @override
  String get vacancyDescription => 'Ish haqida';

  @override
  String get vacancyRequirements => 'Talablar';

  @override
  String get vacancyMandatory => 'Majburiy';

  @override
  String get vacancyPreferred => 'Ma’qul';

  @override
  String get vacancyGoneTitle => 'Bu vakansiya endi mavjud emas';

  @override
  String get vacancyGoneBody =>
      'U yopilgan, to\'ldirilgan yoki muddati o\'tgan bo\'lishi mumkin.';

  @override
  String get vacancyReportReason => 'Bu vakansiyada nima noto\'g\'ri?';

  @override
  String get vacancyReportSend => 'Yuborish';

  @override
  String get commonYes => 'Ha';

  @override
  String get commonNo => 'Yo\'q';

  @override
  String vacancyOpenings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta o\'rin',
    );
    return '$_temp0';
  }

  @override
  String vacancyWorkWindow(String start, String end) {
    return '$start – $end';
  }

  @override
  String vacancyStartsOn(String date) {
    return '$date dan';
  }

  @override
  String get walletTitle => 'Hamyon';

  @override
  String get walletBalanceLabel => 'Balans';

  @override
  String walletCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '$_temp0';
  }

  @override
  String walletApproxUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '≈ $amountString so\'m';
  }

  @override
  String walletUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString so\'m';
  }

  @override
  String get walletPrices => 'Bugungi narxlar';

  @override
  String get walletCoinPriceLabel => '1 Coin';

  @override
  String get walletUnlockPriceLabel => 'Nomzod kontaktlarini ochish';

  @override
  String walletRegistrationBonusOn(String date) {
    return 'Ro\'yxatdan o\'tish bonusi berildi: $date';
  }

  @override
  String get walletTopUp => 'To\'ldirish';

  @override
  String get walletTopUpUnavailable =>
      'To\'ldirish hozircha mavjud emas. U Payme va CLICK qo\'llab-quvvatlashi bilan birga keladi.';

  @override
  String get walletActivity => 'So\'nggi operatsiyalar';

  @override
  String get walletActivityEmpty =>
      'Bu hamyonda hali hech qanday harakat bo\'lmagan. Kirim ham, chiqim ham shu yerda ko\'rinadi va biror yozuv hech qachon o\'chirilmaydi.';

  @override
  String walletBalanceAfter(int count) {
    return 'Balans $count';
  }

  @override
  String walletAmountCredit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '+$_temp0';
  }

  @override
  String walletAmountDebit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '−$_temp0';
  }

  @override
  String get walletKindRegistrationBonus => 'Ro\'yxatdan o\'tish bonusi';

  @override
  String get walletKindTopUp => 'To\'ldirish';

  @override
  String get walletKindCandidateUnlock => 'Nomzod kontaktlarini ochish';

  @override
  String get walletKindAdminAdjustment => 'Administrator tuzatishi';

  @override
  String get walletKindReversal => 'Qaytarish';

  @override
  String get walletKindOther => 'Hamyon operatsiyasi';

  @override
  String get walletCorrection => 'Tuzatish';

  @override
  String get walletBalanceUnavailable => 'Balans mavjud emas';

  @override
  String unlockContact(String coins) {
    return 'Kontaktni ochish — $coins';
  }

  @override
  String get unlockTitle => 'Kontaktni ochish';

  @override
  String get unlockCost => 'Narxi';

  @override
  String get unlockBalanceNow => 'Sizning balansingiz';

  @override
  String get unlockBalanceAfter => 'Keyingi balans';

  @override
  String get unlockConfirm => 'Tasdiqlash';

  @override
  String get unlockWhatYouGet =>
      'Telefon, e-mail va rezyume ochiladi, suhbatni ham boshlashingiz mumkin. Bir marta yechiladi — keyinroq bu nomzodga qaytish bepul.';

  @override
  String get unlockDone => 'Kontaktlar ochildi';

  @override
  String get unlockAlready => 'Allaqachon ochilgan — hech narsa yechilmadi';

  @override
  String unlockUnlockedOn(String date) {
    return '$date da ochilgan';
  }

  @override
  String get unlockTopUpNeeded => 'Ochish uchun to\'ldiring';

  @override
  String get candidateExposureUnlockRequired =>
      'Nomzod bilan hozir bog\'lanish uchun kontaktlarni oching. Agar u sizning vakansiyangizga ariza yuborsa yoki taklifni qabul qilsa, ular bepul ham ochiladi.';

  @override
  String get contactLockedTitle => 'Himoyalangan ma\'lumotlar';

  @override
  String get contactUnlockedTitle => 'Aloqa ma\'lumotlari';

  @override
  String get contactPhone => 'Telefon raqami';

  @override
  String get contactEmail => 'E-pochta';

  @override
  String get contactCv => 'Rezyume fayli';

  @override
  String get contactCvLocked => 'PDF · qulflangan';

  @override
  String contactLockedExplainer(String coins) {
    return '$coins bitta yangi nomzodning kontakti, rezyumesi va yozishmasini ochadi. Bir marta ochilgan nomzod uchun qayta to\'lov olinmaydi.';
  }

  @override
  String get unlockGoToVerification => 'Tasdiqlashga o\'tish';

  @override
  String unlockChargedDetail(String coins, String balance) {
    return '$coins yechildi · balans $balance';
  }

  @override
  String get unlockInsufficient => 'Coin yetarli emas';

  @override
  String walletValueAndPrice(int value, int price) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return '≈ $valueString so\'m · 1 Coin = $priceString so\'m';
  }

  @override
  String walletCoinRule(String coins) {
    return '$coins bitta yangi nomzod kontaktini ochadi. Nomzodlarni qidirish va profilni ko\'rish bepul.';
  }

  @override
  String get walletHistoryTitle => 'Amallar tarixi';

  @override
  String get walletHistoryAll => 'Barchasi';

  @override
  String get walletHistoryIncoming => 'To\'ldirish';

  @override
  String get walletHistoryOutgoing => 'Sarflangan';

  @override
  String get walletHistoryNoMatch =>
      'Bu turdagi amal hozircha yo\'q. Hamyonda yozilgan hammasini ko\'rish uchun filtrni olib tashlang.';

  @override
  String get walletDetailTitle => 'Amal tafsiloti';

  @override
  String get walletDetailSection => 'Tafsilot';

  @override
  String get walletDetailReason => 'Sabab';

  @override
  String get walletDetailWhen => 'Sana va vaqt';

  @override
  String get walletDetailAmountUzs => 'To\'langan summa';

  @override
  String get walletDetailEffect => 'Balansga ta\'siri';

  @override
  String get walletDetailBalanceAfter => 'Keyingi balans';

  @override
  String get walletDetailReference => 'Ma\'lumot raqami';

  @override
  String get walletDetailSupportTitle => 'Bu yozuvda nimadir noto\'g\'rimi?';

  @override
  String get walletDetailSupport =>
      'Qo\'llab-quvvatlash xizmatiga murojaat qilib, yuqoridagi ma\'lumot raqamini ko\'rsating. Bu tarixdagi hech bir yozuvni o\'zgartirish yoki o\'chirish mumkin emas, shuning uchun siz ko\'rgan yozuvni ular ham xuddi shunday ko\'radi.';

  @override
  String get walletCorrectionExplained =>
      'Bu yozuv oldingisini tuzatadi. Asl yozuv tarixda qoladi — tuzatishlar qo\'shiladi, ustidan yozilmaydi.';

  @override
  String get navInvitations => 'Takliflar';

  @override
  String get invitationSent => 'Yuborilgan';

  @override
  String get invitationDetailsRequested => 'Batafsil so\'ralgan';

  @override
  String get invitationAccepted => 'Qabul qilingan';

  @override
  String get invitationDeclined => 'Rad etilgan';

  @override
  String get invitationAccept => 'Qabul qilish';

  @override
  String get invitationDecline => 'Rad etish';

  @override
  String get invitationRequestDetails => 'Savol berish';

  @override
  String get invitationsInboxEmpty =>
      'Sizni vakansiyaga taklif qilgan ish beruvchilar shu yerda ko\'rinadi.';

  @override
  String get invitationGeneral => 'Umumiy taklif';

  @override
  String get invitationOpenVacancy => 'Vakansiyani ochish';

  @override
  String get invitationVacancyLoading => 'Vakansiya yuklanmoqda…';

  @override
  String get invitationVacancyUnavailable => 'Vakansiyani yuklab bo\'lmadi.';

  @override
  String get invitationVacancyUntitled => 'Vakansiya';

  @override
  String get invitationYourReply => 'Sizning javobingiz';

  @override
  String invitationPayRange(int from, int to) {
    final intl.NumberFormat fromNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String toString = toNumberFormat.format(to);

    return '$fromString – $toString so\'m';
  }

  @override
  String invitationPayFrom(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString so\'mdan';
  }

  @override
  String invitationPayUpTo(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString so\'mgacha';
  }

  @override
  String get invitationAcceptTitle => 'Bu taklif qabul qilinsinmi?';

  @override
  String get invitationAcceptDiscloses =>
      'Qabul qilsangiz, telefon raqamingiz, e-pochtangiz va rezyumeingiz shu ish beruvchiga ko\'rinadi. Buni ortga qaytarib bo\'lmaydi.';

  @override
  String get invitationDeclineTitle => 'Bu taklif rad etilsinmi?';

  @override
  String get invitationDeclineFinal =>
      'Aloqa ma\'lumotlaringiz yopiq qoladi. Rad etishni ortga qaytarib bo\'lmaydi, lekin ish beruvchi keyinroq yana taklif qilishi mumkin.';

  @override
  String get invitationRequestDetailsTitle => 'Ish beruvchiga savol berish';

  @override
  String get invitationRequestDetailsBody =>
      'Keyin ham qabul qilish yoki rad etish mumkin. Qabul qilmaguningizcha aloqa ma\'lumotlaringiz yopiq qoladi.';

  @override
  String get invitationQuestionLabel => 'Savolingiz';

  @override
  String get invitationQuestionHint =>
      'Masalan: ish aynan qayerda va qachon boshlanadi?';

  @override
  String get invitationNoteLabel => 'Xabar (majburiy emas)';

  @override
  String get invitationNoteHint =>
      'Ish beruvchi bilishi kerak deb hisoblagan narsangiz.';

  @override
  String get invitationAlreadyAnswered =>
      'Bu taklifga allaqachon javob berilgan';

  @override
  String get commonChoose => 'Tanlash';

  @override
  String get invitationSendTitle => 'Taklif yuborish';

  @override
  String get invitationSend => 'Yuborish';

  @override
  String get invitationSendFree =>
      'Yuborish bepul. Aloqa ma\'lumotlari faqat nomzod qabul qilsa ochiladi.';

  @override
  String get invitationToVacancy => 'Vakansiyaga';

  @override
  String get invitationVacancyLabel => 'Vakansiyani tanlang';

  @override
  String get invitationNoOpenVacancyTitle => 'Ochiq vakansiya yo\'q';

  @override
  String get invitationNoOpenVacancyBody =>
      'Taklif faqat faol vakansiyaga bog\'lanishi mumkin. Umumiy ish taklifini hozir ham yuborishingiz mumkin.';

  @override
  String get invitationOccupation => 'Kasb';

  @override
  String get invitationRegion => 'Viloyat';

  @override
  String get invitationDistrict => 'Tuman';

  @override
  String get invitationNegotiable => 'To\'lov kelishiladi';

  @override
  String get invitationSalaryFrom => 'To\'lov (dan)';

  @override
  String get invitationSalaryTo => 'To\'lov (gacha)';

  @override
  String get invitationSalaryPeriod => 'Davr';

  @override
  String get invitationSchedule => 'Ish vaqti';

  @override
  String get invitationScheduleHint => 'Masalan: haftada olti kun, ertalab';

  @override
  String get invitationMessageLabel => 'Xabar (majburiy emas)';

  @override
  String get invitationMessageHint =>
      'Nomzod bilishi kerak deb hisoblagan narsangiz';

  @override
  String invitationQuotaRemaining(int remaining, int limit) {
    return 'Bugun $limit taklifdan $remaining tasi qoldi';
  }

  @override
  String invitationQuotaResets(String at) {
    return '$at da yangilanadi';
  }

  @override
  String get invitationQuotaSpentTitle => 'Bugungi takliflar tugadi';

  @override
  String get invitationAlreadySentTitle => 'Allaqachon taklif qilingan';

  @override
  String get invitationSentConfirm => 'Taklif yuborildi';

  @override
  String get invitationsSentTitle => 'Yuborilgan takliflar';

  @override
  String get invitationsSentEmpty =>
      'Siz taklif qilgan nomzodlar shu yerda ko\'rinadi.';

  @override
  String get invitationsSentNoMatch =>
      'Bu holatda taklif yo\'q. Yuborilganlarning hammasini ko\'rish uchun filtrni tozalang.';

  @override
  String get invitationsSentForVacancy => 'Faqat bu vakansiya';

  @override
  String get invitationFilterAll => 'Hammasi';

  @override
  String get invitationYourMessage => 'Siz yozgan xabar';

  @override
  String get invitationCandidateReply => 'Nomzodning javobi';

  @override
  String get invitationContactOpenTitle => 'Aloqa ma\'lumotlari ochiq';

  @override
  String get invitationContactOpenBody =>
      'Nomzod taklifni qabul qildi — telefon, e-pochta va rezyume uning profilida. Buning uchun to\'lov kerak emas.';

  @override
  String get invitationOpenCandidate => 'Nomzodni ko\'rish';

  @override
  String invitationCounts(int invited, int accepted) {
    return '$invited ta taklif yuborilgan, $accepted tasi qabul qilingan';
  }

  @override
  String get fileNoViewer =>
      'Bu telefonda bu faylni ocha oladigan ilova yo\'q.';

  @override
  String get dashboardActiveVacancies => 'Faol vakansiya';

  @override
  String get dashboardOpenPositions => 'Ochiq o\'rin';

  @override
  String get dashboardNewApplications => 'Yangi ariza';

  @override
  String get dashboardAttention => 'Sizning e\'tiboringiz kerak';

  @override
  String get dashboardAttentionClear => 'Sizdan kutilayotgan ish yo\'q.';

  @override
  String get dashboardVerificationTitle => 'Tasdiqlash tugallanmagan';

  @override
  String get dashboardVacancyRejected => 'O\'zgartirish talab qilinadi';

  @override
  String dashboardUnreviewed(int count) {
    return '$count ta ariza ko\'rib chiqilmagan';
  }

  @override
  String dashboardSavedCandidates(int count) {
    return '$count ta saqlangan nomzod';
  }

  @override
  String get dashboardHiring => 'Ishga qabul jarayoni';

  @override
  String dashboardHiredOf(int hired, int openings) {
    return '$openings dan $hired';
  }

  @override
  String dashboardMeterHired(int count) {
    return 'Ishga olindi $count';
  }

  @override
  String dashboardMeterInvited(int count) {
    return 'Taklif yuborildi $count';
  }

  @override
  String dashboardMeterRemaining(int count) {
    return 'Qolgan $count';
  }

  @override
  String get dashboardWallet => 'Hamyon';

  @override
  String get accountTitle => 'Hisob va xavfsizlik';

  @override
  String get accountDevices => 'Kirgan qurilmalar';

  @override
  String get accountDevicesBody =>
      'Tanimagan qurilmani ko\'rsangiz, uning seansini tugating.';

  @override
  String get accountDeviceUnknown => 'Nomsiz qurilma';

  @override
  String accountLastUsed(String at) {
    return 'Oxirgi foydalanish: $at';
  }

  @override
  String get accountThisDevice => 'Bu qurilma';

  @override
  String get accountRevoke => 'Seansni tugatish';

  @override
  String get accountRevokeTitle => 'Bu seansni tugatilsinmi?';

  @override
  String get accountRevokeBody =>
      'O\'sha qurilma qaytadan kirishi kerak bo\'ladi.';

  @override
  String get accountRevokeCurrentTitle => 'Bu qurilmadan chiqilsinmi?';

  @override
  String get accountRevokeCurrentBody =>
      'Bu — siz foydalanayotgan qurilma. Hozir hisobdan chiqarilasiz.';

  @override
  String get accountRevokeAll => 'Barcha seanslarni tugatish';

  @override
  String get accountRevokeAllTitle => 'Barcha seanslar tugatilsinmi?';

  @override
  String get accountRevokeAllBody =>
      'Barcha qurilmalar, shu qurilma ham, hisobdan chiqariladi.';

  @override
  String get accountDelete => 'Hisobni o\'chirish';

  @override
  String get accountDeleteBody =>
      'Profilingiz, arizalaringiz va xabarlaringiz o\'chiriladi. Bu qaytarib bo\'lmaydi.';

  @override
  String get accountDeleteAction => 'O\'chirishni so\'rash';

  @override
  String get accountDeleteConfirmTitle => 'Hisobni o\'chirish so\'ralsinmi?';

  @override
  String get accountDeleteConfirmBody =>
      'Hisobingizni o\'chirishni boshlaymiz. Buni ilovadan qaytarib bo\'lmaydi.';

  @override
  String get accountDeleteRequestedTitle => 'O\'chirish so\'raldi';

  @override
  String get accountDeleteRequestedBody =>
      'So\'rovingiz qayd etildi. Keyin nima bo\'lishini qo\'llab-quvvatlash xizmati aytadi.';

  @override
  String get filtersRegion => 'Viloyat yoki tuman';

  @override
  String get filtersEmploymentType => 'Bandlik turi';

  @override
  String get filtersWorkFormat => 'Ish formati';

  @override
  String get filtersShift => 'Smena';

  @override
  String get filtersSalaryFrom => 'Maosh, dan';

  @override
  String get filtersSalaryNegotiableNote =>
      'Maoshi kelishilgan vakansiyalar ham ko\'rsatiladi.';

  @override
  String get filtersPublishedFrom => 'Chop etilgan, dan';

  @override
  String get filtersUnavailableTitle => 'Uchta filtr hozircha mavjud emas';

  @override
  String get filtersUnavailableBody =>
      'Tajriba, til va maoshning yuqori chegarasi bo\'yicha hozircha filtrlash mumkin emas. Qolgani ishlaydi.';

  @override
  String feedFilteredNote(int count) {
    return '$count filtr qo\'llangan';
  }

  @override
  String get feedFilteredEmpty =>
      'Bu filtrlarga mos vakansiya yo\'q. Ularni kengaytirib ko\'ring.';

  @override
  String get feedSavedUnfiltered => 'Saqlangan vakansiyalar filtrlanmaydi.';

  @override
  String get notesEmpty => 'Hozircha izoh yo\'q.';

  @override
  String get notesNewLabel => 'Yangi izoh';

  @override
  String get notesNewHint =>
      '8m so\'radi, 6.5 ga rozi bo\'lishi mumkin — payshanba kuni qo\'ng\'iroq';

  @override
  String get applicantsNoneAtStage =>
      'Bu bosqichda hech kim yo\'q. Hamma arizachini ko\'rish uchun filtrni tozalang.';

  @override
  String get shortlistTitle => 'Short-list';

  @override
  String get shortlistEmpty => 'Short-listda hozircha hech kim yo\'q';

  @override
  String get roleSelectionTitle => 'JobBridge\'dan qanday foydalanasiz?';

  @override
  String get roleSelectionSubtitle =>
      'Bittasini yoki ikkalasini tanlang — ikkinchisini keyin ham, ikkinchi akkaunt ochmasdan qo\'shishingiz mumkin.';

  @override
  String get roleCandidateDescription =>
      'Ish beruvchilar topadigan profil yarating, vakansiyalarga ariza yuboring va taklifnomalarga javob bering.';

  @override
  String get roleEmployerDescription =>
      'Vakansiya joylang, nomzodlarni qidiring va gaplashmoqchi bo\'lganlaringizni taklif qiling.';

  @override
  String get roleSelectionBoth =>
      'Ikkalasi tanlanganda bitta akkaunt ikkita alohida makonni saqlaydi: o\'z profilingiz va kompaniyangiz profili — almashtirish profilingizda.';

  @override
  String get chatListEmpty =>
      'Suhbat ish bo\'yicha aloqa paydo bo\'lgach ochiladi — ariza yoki qabul qilingan taklif.';

  @override
  String get chatParticipantUnknown => 'Ishtirokchi';

  @override
  String chatUnreadCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String chatUnreadSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta o\'qilmagan xabar',
    );
    return '$_temp0';
  }

  @override
  String get chatNoMessages => 'Hozircha xabar yo\'q';

  @override
  String get chatAttachment => 'Ilova';

  @override
  String get chatReadOnly => 'Faqat o\'qish';

  @override
  String get chatBlocked => 'Bloklangan';

  @override
  String get chatBlockedByYou => 'Siz bloklagansiz';

  @override
  String get chatReadOnlyTitle => 'Bu suhbat tarixga aylandi';

  @override
  String get chatReadOnlyBody =>
      'U boshlangan ariza yoki taklif tugadi, shuning uchun yangi xabar yuborilmaydi. Mavjud xabarlar o\'qish uchun qoladi.';

  @override
  String get chatBlockedTitle => 'Bloklangan';

  @override
  String get chatBlockedBody =>
      'Suhbatni ikkinchi tomon blokladi. Blok turgan vaqtda hech kim xabar yubora olmaydi, xabarlar esa o\'qish uchun qoladi.';

  @override
  String get chatBlockedByYouTitle => 'Siz bu suhbatni bloklagansiz';

  @override
  String get chatBlockedByYouBody =>
      'Blok turgan vaqtda ikki tomon ham xabar yubora olmaydi — siz ham. Yana yozish uchun ekran yuqorisidagi blokni olib tashlang.';

  @override
  String get chatUnblock => 'Blokni olib tashlash';

  @override
  String get chatUnblocked => 'Blok olib tashlandi. Yana yozishingiz mumkin.';

  @override
  String get chatBlockAction => 'Bloklash';

  @override
  String get chatBlockTitle => 'Bu suhbatni bloklaysizmi?';

  @override
  String get chatBlockBody =>
      'U ikkingiz uchun ham faqat o\'qish holatiga o\'tadi — siz ham yubora olmaysiz. Xabarlar o\'qish uchun qoladi va moderator ularni ko\'rib chiqishi mumkin.';

  @override
  String get chatBlockReasonLabel => 'Sabab (majburiy emas)';

  @override
  String get chatBlockReasonHint => 'Buni ko\'rib chiqadigan moderator uchun';

  @override
  String get chatReportTitle => 'Bu xabar ustidan shikoyat qilish';

  @override
  String get chatReportBody =>
      'Shikoyatni moderator o\'qib, qaror qabul qiladi. Suhbatni bloklash — alohida amal, ikkalasini ham qilishingiz mumkin.';

  @override
  String get chatReportReasonLabel => 'Nimasi noto\'g\'ri';

  @override
  String get chatReportReasonHint => 'Ish uchun pul to\'lashimni so\'radi';

  @override
  String get chatReportSubmit => 'Shikoyatni yuborish';

  @override
  String get chatReportDone => 'Shikoyat yuborildi. Moderator ko\'rib chiqadi.';

  @override
  String get chatComposerLabel => 'Xabar';

  @override
  String get chatComposerHint => 'Xabar yozing';

  @override
  String get chatSend => 'Yuborish';

  @override
  String get chatSendRefusedTitle => 'Yuborilmadi';

  @override
  String get chatSent => 'Yuborildi';

  @override
  String get chatRead => 'O\'qilgan';

  @override
  String get chatEarlier => 'Oldingi xabarlar';

  @override
  String get chatThreadEmpty => 'Hozircha xabar yo\'q. Birinchisini yozing.';

  @override
  String get chatThreadEmptyClosed =>
      'Bu suhbat yopilishidan oldin hech qanday xabar yuborilmagan.';

  @override
  String get chatOpenAction => 'Xabar yuborish';

  @override
  String get interviewTitle => 'Suhbat';

  @override
  String get interviewStatusScheduled => 'Belgilangan';

  @override
  String get interviewStatusConfirmed => 'Tasdiqlangan';

  @override
  String get interviewStatusRescheduleRequested => 'Boshqa vaqt so\'raldi';

  @override
  String get interviewStatusCancelled => 'Bekor qilingan';

  @override
  String get interviewTypePhone => 'Telefon orqali';

  @override
  String get interviewTypeInPerson => 'Yuzma-yuz';

  @override
  String get interviewTypeExternalLink => 'Video havola';

  @override
  String get interviewPhoneNote =>
      'Ish beruvchi profilingizdagi raqamga qo\'ng\'iroq qiladi.';

  @override
  String get interviewWhere => 'Manzil';

  @override
  String get interviewLink => 'Havola';

  @override
  String get interviewInstructions => 'Ish beruvchidan';

  @override
  String get interviewYourReply => 'Sizning javobingiz';

  @override
  String get interviewPassed => 'Bu vaqt allaqachon o\'tib ketgan.';

  @override
  String get interviewCancelledNotice =>
      'Bu suhbatni ish beruvchi bekor qildi.';

  @override
  String get interviewConfirm => 'Tasdiqlash';

  @override
  String get interviewRequestAnother => 'Boshqa vaqt so\'rash';

  @override
  String get interviewConfirmTitle => 'Bu vaqtni tasdiqlaysizmi?';

  @override
  String get interviewConfirmBody =>
      'Ish beruvchi vaqt sizga qulay ekanini ko\'radi. Keyinchalik biror narsa o\'zgarsa, boshqa vaqt so\'rashingiz mumkin.';

  @override
  String get interviewRescheduleTitle => 'Boshqa vaqt so\'rash';

  @override
  String get interviewRescheduleBody =>
      'Ish beruvchi yangi vaqt belgilamaguncha suhbat kuchda qoladi va u quyida yozganingizni ko\'radi.';

  @override
  String get interviewNoteLabel => 'Qaysi vaqtlar sizga qulay';

  @override
  String get interviewNoteHint =>
      'Shu hafta tushdan keyin yoki juma kuni ertalab';

  @override
  String get interviewReplyNoteLabel => 'Izoh (majburiy emas)';

  @override
  String get interviewReplyNoteHint => 'O\'n daqiqa oldin yetib boraman';

  @override
  String get interviewNotAllowed => 'Bu suhbat holati o\'zgargan';

  @override
  String get interviewSchedule => 'Suhbat belgilash';

  @override
  String get interviewScheduleTitle => 'Suhbat belgilash';

  @override
  String get interviewScheduleSave => 'Nomzodga yuborish';

  @override
  String get interviewRescheduleFormTitle => 'Suhbat vaqtini o\'zgartirish';

  @override
  String get interviewRescheduleSave => 'Yangi vaqtni saqlash';

  @override
  String get interviewRescheduleResets =>
      'Kichik o\'zgarish bo\'lsa ham, nomzoddan qayta tasdiqlash so\'raladi — boshqa vaqtga ko\'chirilgan suhbat tasdiqlanmagan hisoblanadi.';

  @override
  String get interviewTypeLabel => 'Suhbat turi';

  @override
  String get interviewWhereHint =>
      'Amir Temur 12, 3-qavat — qabulxonada Dilnozani so\'rang';

  @override
  String get interviewLinkHint => 'https://meet.example.com/abc-defg-hij';

  @override
  String get interviewDateLabel => 'Sana';

  @override
  String get interviewTimeLabel => 'Vaqt';

  @override
  String get interviewTimeHint => '10:00';

  @override
  String get interviewInstructionsLabel =>
      'Nima olib kelishi yoki tayyorlashi kerak';

  @override
  String get interviewInstructionsHint =>
      'Diplomingizni va mehnat daftaringizni olib keling';

  @override
  String get interviewReschedule => 'Ko\'chirish';

  @override
  String get interviewCancelAction => 'Bekor qilish';

  @override
  String get interviewCancelTitle => 'Bu suhbatni bekor qilasizmi?';

  @override
  String get interviewCancelBody =>
      'Bu ikki tomon uchun ham qat\'iy — suhbatni qaytarib bo\'lmaydi, yangi vaqt esa yangi suhbat belgilashni talab qiladi. Nomzod bekor qilinganini ko\'radi.';

  @override
  String get interviewCancelReasonLabel =>
      'Sabab (majburiy emas, nomzod ko\'radi)';

  @override
  String get interviewCancelReasonHint =>
      'Lavozim to\'ldirildi — vaqtingiz uchun rahmat';

  @override
  String get interviewCandidateReply => 'Nomzod nima dedi';

  @override
  String get commonShowMore => 'Ko\'proq ko\'rsatish';

  @override
  String get commonLoadingMore => 'Yana yuklanmoqda…';

  @override
  String get adminDashboardTitle => 'Boshqaruv';

  @override
  String get adminQueuesTitle => 'Qaror kutmoqda';

  @override
  String get adminAwaitingVerification =>
      'Tasdiqlash kutayotgan ish beruvchilar';

  @override
  String get adminAwaitingModeration => 'Moderatsiya kutayotgan vakansiyalar';

  @override
  String get adminOpenComplaints => 'Ochiq shikoyatlar';

  @override
  String get adminQueuesClear => 'Sizni kutayotgan ish yo\'q.';

  @override
  String get adminSanctionsTitle => 'Cheklovdagi hisoblar';

  @override
  String get adminRestrictedUsers => 'Cheklangan';

  @override
  String get adminBlockedUsers => 'Bloklangan';

  @override
  String get adminPeriodTitle => 'Tanlangan davr uchun';

  @override
  String adminPeriodDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days kun',
    );
    return '$_temp0';
  }

  @override
  String get adminCandidates => 'Nomzodlar';

  @override
  String get adminEmployers => 'Ish beruvchilar';

  @override
  String get adminVacanciesPublished => 'E\'lon qilingan vakansiyalar';

  @override
  String get adminApplicationsSubmitted => 'Yuborilgan arizalar';

  @override
  String get adminCountTotal => 'jami';

  @override
  String get adminCountNew => 'yangi';

  @override
  String get adminVerificationTitle => 'Ish beruvchini tasdiqlash';

  @override
  String get adminVerificationFifo =>
      'Eng eskisi birinchi — yuqoridagi ariza eng uzoq kutgan.';

  @override
  String get adminVerificationEmpty => 'Kutayotgan hech kim yo\'q';

  @override
  String get adminVerificationEmptyBody =>
      'Ish beruvchilar hujjatlarini yuborgan sayin arizalar shu yerda paydo bo\'ladi.';

  @override
  String get adminEmployerCompany => 'Tashkilot';

  @override
  String get adminEmployerIndividual => 'Jismoniy shaxs';

  @override
  String get adminEmployerUnnamed => 'Nom kiritilmagan';

  @override
  String adminWaitingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days kundan beri kutmoqda',
      zero: 'Bugun yuborilgan',
    );
    return '$_temp0';
  }

  @override
  String get adminEvidenceTitle => 'Hujjatlar';

  @override
  String get adminEvidenceNone => 'Hujjat ilova qilinmagan';

  @override
  String get adminVerify => 'Tasdiqlash';

  @override
  String get adminRequestChanges => 'O\'zgartirish so\'rash';

  @override
  String get adminReject => 'Rad etish';

  @override
  String get adminVerifyTitle => 'Bu ish beruvchini tasdiqlaysizmi?';

  @override
  String get adminVerifyBody =>
      'Bu ularga vakansiya e\'lon qilish va nomzodlarni taklif qilish imkonini beradi. Hisobdagi boshqa hech narsa o\'zgarmaydi.';

  @override
  String get adminRequestChangesTitle => 'Tuzatish uchun qaytarasizmi?';

  @override
  String get adminRequestChangesBody =>
      'Profil va fayllar saqlanadi — siz quyida aytgan narsani tuzatib, qaytadan yuborishlari mumkin.';

  @override
  String get adminRejectTitle => 'Bu arizani rad etasizmi?';

  @override
  String get adminRejectBody =>
      'Ular tasdiqlanmagan holatda qoladi, e\'lon ham, taklif ham qila olmaydi. Ularga faqat sizning sababingiz yetadi — nima qilish kerakligini yozing.';

  @override
  String get adminReasonLabel => 'Sabab (ish beruvchi so\'zma-so\'z o\'qiydi)';

  @override
  String get adminReasonHint =>
      'Ro\'yxatga olish guvohnomasi o\'qilmaydi — aniqroq nusxa yuklang';

  @override
  String get adminAlreadyDecided => 'Allaqachon hal qilingan';

  @override
  String get adminDecisionRecorded => 'Qaror qayd etildi.';

  @override
  String get adminQueueTitle => 'Moderatsiya';

  @override
  String get adminQueueEmployers => 'Ish beruvchilar';

  @override
  String get adminQueueVacancies => 'Vakansiyalar';

  @override
  String get adminModerationEmpty => 'Kutayotgan vakansiya yo\'q';

  @override
  String get adminModerationEmptyBody =>
      'Ish beruvchilar e\'lon qilish uchun yuborgan sayin vakansiyalar shu yerda paydo bo\'ladi.';

  @override
  String get adminRestrictionFlag => 'Yosh yoki jins cheklovi';

  @override
  String get adminReviewTitle => 'Ko‘rib chiqish';

  @override
  String get adminVacancyGoneTitle => 'Bu vakansiya navbatdan chiqib ketgan';

  @override
  String get adminVacancyGoneBody =>
      'Kimdir uni allaqachon hal qilgan yoki ish beruvchi qaytarib olgan bo‘lishi mumkin.';

  @override
  String get adminPublish => 'E\'lon qilish';

  @override
  String get adminSendBack => 'Qaytarish';

  @override
  String get adminPublishTitle => 'Bu vakansiyani e\'lon qilasizmi?';

  @override
  String get adminPublishBody =>
      'Nomzodlar uni darhol ko\'radi. Agar yosh yoki jins cheklovi bo\'lsa, e\'lon qilish o\'sha cheklovni ham tasdiqlaydi — cheklovli vakansiya faqat shu navbat orqali e\'lon qilinishi mumkin.';

  @override
  String get adminSendBackTitle => 'Bu vakansiyani qaytarasizmi?';

  @override
  String get adminSendBackBody =>
      'Ish beruvchi uni tuzatib qayta yuborishi mumkin. Ularga faqat sizning sababingiz yetadi — nimani o\'zgartirish kerakligini aytib bering.';

  @override
  String get adminRestrictionJudge =>
      'Cheklov faqat sabab uni haqiqatan talab qilsa ruxsat etiladi. Cheklovni emas, sababni baholang.';

  @override
  String get adminRestrictionAge => 'Yosh cheklovi';

  @override
  String get adminRestrictionGender => 'Jins cheklovi';

  @override
  String get adminRestrictionReason => 'Ish beruvchi tanlagan sabab';

  @override
  String get adminRestrictionNote => 'O\'z so\'zlari bilan';

  @override
  String get adminPreviousReason => 'Avval shu sabab bilan qaytarilgan';

  @override
  String get adminVacancyWhere => 'Ish joyi';

  @override
  String get adminVacancyEmployer => 'Ish beruvchi';

  @override
  String get adminVacancyEmployerPhone => 'Kirish raqami';

  @override
  String get adminComplaintsTitle => 'Shikoyatlar';

  @override
  String get adminComplaintsEmpty => 'Shikoyat yo\'q';

  @override
  String get adminComplaintsEmptyBody =>
      'Hech bir shikoyat qarorni kutmayapti.';

  @override
  String get adminComplaintKindVacancy => 'Vakansiya';

  @override
  String get adminComplaintKindUser => 'Foydalanuvchi';

  @override
  String get adminComplaintKindProfile => 'Profil';

  @override
  String get adminComplaintKindMessage => 'Xabar';

  @override
  String get adminComplaintKindUnknown => 'Noma\'lum tur';

  @override
  String get adminComplaintKindUnknownBody =>
      'Ilovaning bu versiyasi bu obyekt turini ko\'rsata olmaydi. Ko\'rib chiqish uchun ilovani yangilang.';

  @override
  String get adminComplaintTitle => 'Shikoyat';

  @override
  String get adminComplaintGoneTitle => 'Bu shikoyat topilmadi';

  @override
  String get adminComplaintGoneBody =>
      'Kimdir uni ko\'rib chiqqan yoki u hech qachon bo\'lmagan. Hal qiladigan narsa qolmadi.';

  @override
  String get adminComplaintReported => 'Nima haqida xabar qilingan';

  @override
  String get adminComplaintTarget => 'Shikoyat qilingan obyekt';

  @override
  String get adminComplaintTargetGone =>
      'Shikoyat qilingan obyekt o\'chirilgan';

  @override
  String get adminComplaintTargetGoneBody =>
      'U shikoyat berilgandan keyin o\'chirilgan. Shikoyat saqlanadi, shuning uchun natijani hali ham qayd etish mumkin.';

  @override
  String get adminComplaintEmployerAccount => 'Ish beruvchi hisobi';

  @override
  String get adminComplaintRemedy => 'Avval chora ko\'ring';

  @override
  String get adminComplaintRemedyBody =>
      'Shikoyatni qabul qilingan deb qayd etish hech narsani amalga oshirmaydi. Avval shu yerda chora ko\'ring.';

  @override
  String get adminComplaintNoRemedy =>
      'Bu yerda ko\'radigan chora yo\'q. Natijani pastda qayd eting.';

  @override
  String get adminComplaintOutcome => 'Natijani qayd eting';

  @override
  String get adminComplaintOutcomeBody =>
      'Shikoyatni ko\'rib chiqishni boshqa hech narsa qayd etmaydi, shuning uchun yozganingiz — uning yagona bayoni.';

  @override
  String get adminComplaintUphold => 'Qabul qilish';

  @override
  String get adminComplaintDismiss => 'Rad etish';

  @override
  String get adminComplaintUpholdTitle => 'Bu shikoyat qabul qilinsinmi?';

  @override
  String get adminComplaintUpholdBody =>
      'Shikoyat qabul qilingan holda yopiladi. Chora kerak bo\'lsa, buni qayd etishdan oldin ko\'ring.';

  @override
  String get adminComplaintDismissTitle => 'Bu shikoyat rad etilsinmi?';

  @override
  String get adminComplaintDismissBody =>
      'Shikoyat hech qanday chorasiz yopiladi. Sababini yozing — bu qarorning yagona bayoni.';

  @override
  String get adminResolutionLabel => 'Qaror (audit jurnalida saqlanadi)';

  @override
  String get adminResolutionHint =>
      'Vakansiya to\'xtatildi va ish beruvchidan tavsifdan telefon raqamini olib tashlash so\'raldi';

  @override
  String get adminPauseVacancy => 'Vakansiyani to\'xtatish';

  @override
  String get adminCloseVacancy => 'Vakansiyani olib tashlash';

  @override
  String get adminPauseVacancyTitle => 'Vakansiya to\'xtatilsinmi?';

  @override
  String get adminPauseVacancyBody =>
      'Vakansiya darhol lentadan chiqadi va ish beruvchi tuzatgandan keyin qayta tiklanishi mumkin.';

  @override
  String get adminCloseVacancyTitle => 'Vakansiya olib tashlansinmi?';

  @override
  String get adminCloseVacancyBody =>
      'Vakansiya lentadan butunlay chiqadi. Olib tashlangan vakansiya qayta ochilmaydi — ish beruvchi tuzatishi mumkin bo\'lsa, uni to\'xtating.';

  @override
  String get adminWarnUser => 'Ogohlantirish yuborish';

  @override
  String get adminWarnUserTitle => 'Ogohlantirish yuborilsinmi?';

  @override
  String get adminWarnUserBody =>
      'Hisobi o\'zgarmaydi. Ogohlantirish va uning sababi qayd etiladi, foydalanuvchi esa xabardor qilinadi.';

  @override
  String get adminWarnReasonLabel =>
      'Ogohlantirish (foydalanuvchi so\'zma-so\'z o\'qiydi)';

  @override
  String get adminWarnReasonHint =>
      'Ommaviy vakansiya tavsifida aloqa ma\'lumotlarini ko\'rsatish mumkin emas — iltimos, olib tashlang';

  @override
  String get adminAccountStatusActive => 'Faol';

  @override
  String get adminAccountStatusRestricted => 'Cheklangan';

  @override
  String get adminAccountStatusBlocked => 'Bloklangan';

  @override
  String get adminVacancyEmployerContactPhone => 'Aloqa raqami';

  @override
  String get adminUsersTitle => 'Foydalanuvchilar';

  @override
  String get adminUserSearchPhone => 'Telefon raqami';

  @override
  String get adminUserSearchPhoneHint =>
      'Oxirgi raqamlarining o\'zi ham yetadi';

  @override
  String get adminUserSearchPhoneTooShort => 'Kamida 3 ta raqam.';

  @override
  String get adminUserSearchName => 'Ism yoki nom';

  @override
  String get adminUserSearchNameHint =>
      'Shaxs, kompaniya yoki uning yuridik nomi';

  @override
  String get adminUserSearchNameTooShort => 'Kamida 2 ta belgi.';

  @override
  String get adminUserSearchMore => 'Ko\'proq filtr';

  @override
  String get adminUserSearchFewer => 'Kamroq filtr';

  @override
  String get adminUserSearchRole => 'Quyidagi roli bor';

  @override
  String get adminUserSearchStatus => 'Hisob holati';

  @override
  String get adminUserSearchRegisteredFrom => 'Ro\'yxatdan o\'tgan (dan)';

  @override
  String get adminUserSearchRegisteredTo => 'Ro\'yxatdan o\'tgan (gacha)';

  @override
  String get adminUserSearchDatesReversed => 'Bu sanalar mos kela olmaydi';

  @override
  String get adminUserSearchDatesReversedBody =>
      'Birinchi sana ikkinchisidan keyin turibdi, shuning uchun ular orasiga hech qanday hisob tushmaydi.';

  @override
  String get adminUserSearchRun => 'Qidirish';

  @override
  String get adminUserSearchClear => 'Filtrlarni tozalash';

  @override
  String get adminUserSearchIdle => 'Hisobni toping';

  @override
  String get adminUserSearchIdleBody =>
      'Telefon raqamining oxirgi raqamlari bo\'yicha yoki hisob tanilgan istalgan nom bo\'yicha qidiring — shaxs ismi, kompaniyaning ochiq nomi yoki yuridik nomi. Siz so\'ramaguningizcha hech narsa o\'qilmaydi.';

  @override
  String get adminUserSearchEmpty => 'Mos keladigan hisob topilmadi';

  @override
  String get adminUserSearchEmptyBody =>
      'Bu filtrlarga hech narsa mos kelmadi. Telefon raqami ichidagi istalgan qism bo\'yicha topiladi, shuning uchun oxirgi bir necha raqam boshqacha yozilgan to\'liq raqam topa olmagan hisobni topadi.';

  @override
  String get adminUserSearchOrder =>
      'Eng yangi ro\'yxatdan o\'tganlar birinchi. Eskiroq hisob ro\'yxatning pastida turadi, yo\'q emas — sahifalab izlashdan ko\'ra qidiruvni toraytiring.';

  @override
  String get adminUserNoName => 'Hisobda ism yo\'q';

  @override
  String get adminUserNoPhone => 'Telefon raqami yo\'q';

  @override
  String adminUserRegistered(String date) {
    return 'Ro\'yxatdan o\'tgan: $date';
  }

  @override
  String adminUserLastLogin(String date) {
    return 'Oxirgi kirish: $date';
  }

  @override
  String get adminUserNeverSignedIn => 'Hech qachon kirmagan';

  @override
  String get adminAccountStatusDeletionRequested => 'O\'chirish so\'ralgan';

  @override
  String get adminUserTitle => 'Hisob';

  @override
  String get adminUserGoneTitle => 'Bu hisob endi yo\'q';

  @override
  String get adminUserGoneBody =>
      'Topilmadi. Uni topgan qidiruvdan keyin o\'chirilgan bo\'lishi mumkin.';

  @override
  String get adminUserActions => 'Hisob bo\'yicha chora ko\'rish';

  @override
  String get adminUserNoActionsTitle =>
      'Bu yerdan hech qanday chora ko\'rib bo\'lmaydi';

  @override
  String get adminUserNoActionsBody =>
      'Bu hisob o\'chirilishini so\'ragan. So\'rov o\'z jarayoni orqali hal qilinadi, bu yerda cheklash yoki bloklash esa so\'rovni bekor qilib yuboradi.';

  @override
  String get adminUserRestrict => 'Cheklash';

  @override
  String get adminUserBlock => 'Bloklash';

  @override
  String get adminUserUnblock => 'Blokdan chiqarish';

  @override
  String get adminUserLiftRestriction => 'Cheklovni olib tashlash';

  @override
  String get adminUserRestrictTitle => 'Bu hisob cheklansinmi?';

  @override
  String get adminUserRestrictBody =>
      'Hisob ularda qoladi va kira oladilar, lekin cheklov olib tashlanmaguncha biror narsani o\'zgartiradigan har qanday amal rad etiladi. Sizning sababingiz ularga ko\'rsatiladi.';

  @override
  String get adminUserBlockTitle => 'Bu hisob bloklansinmi?';

  @override
  String get adminUserBlockBody =>
      'Sababni tushuntiruvchi xabardan boshqa hamma narsaga kirish yopiladi. Buni faqat administrator qaytara oladi.';

  @override
  String get adminUserUnblockTitle => 'Hisob blokdan chiqarilsinmi?';

  @override
  String get adminUserLiftRestrictionTitle => 'Cheklov olib tashlansinmi?';

  @override
  String get adminUserLiftBody =>
      'Bundan buyon ularga hamma narsa yana ochiq bo\'ladi.';

  @override
  String get adminUserRestrictUntilLabel => 'Tugash sanasi';

  @override
  String get adminUserRestrictUntilCaption =>
      'Cheklov shu kunning boshida, Toshkent vaqti bilan olib tashlanadi. Bo\'sh qoldirsangiz, administrator olib tashlagunicha qoladi.';

  @override
  String get adminUserStatusReasonLabel =>
      'Sabab (ular so\'zma-so\'z o\'qiydi)';

  @override
  String get adminUserStatusReasonHint =>
      'Nomzodlardan pul so\'raydigan vakansiyalarni qayta-qayta joylashtirgani uchun';

  @override
  String adminUserRestrictedUntil(String date) {
    return '$date gacha cheklangan';
  }

  @override
  String get adminUserRestrictedIndefinitely =>
      'Administrator olib tashlagunicha cheklangan';

  @override
  String get adminUserHistory => 'Hisob tarixi';

  @override
  String get adminUserHistoryEmpty =>
      'Bu hisobning holati hech qachon o\'zgarmagan.';

  @override
  String adminUserHistoryBy(String actor) {
    return '$actor tomonidan';
  }

  @override
  String get adminUserHistoryAutomatic =>
      'Muddat o\'tgach, platforma tomonidan';

  @override
  String get adminUserComplaints => 'Bu hisob ustidan shikoyatlar';

  @override
  String get adminUserComplaintsEmpty =>
      'Bu hisob ustidan hech kim shikoyat qilmagan.';

  @override
  String get adminUserComplaintOpen => 'Ochiq';

  @override
  String get adminUserComplaintClosed => 'Ko\'rib chiqilgan';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppL10nUzCyrl extends AppL10nUz {
  AppL10nUzCyrl() : super('uz_Cyrl');

  @override
  String get appTitle => 'JobBridge';

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
  String get searchShortlist => 'Шорт-листга қўшиш';

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

  @override
  String get candidateProfileTitle => 'Номзод';

  @override
  String get candidateViewProfile => 'Профилни очиш';

  @override
  String get candidateContact => 'Алоқа';

  @override
  String candidateAvailableFrom(String date) {
    return '$date дан тайёр';
  }

  @override
  String get candidateAttachments => 'Иловалар';

  @override
  String get candidateNoFiles => 'Номзод ҳеч нарса юкламаган';

  @override
  String get candidatePhoneNotOnFile =>
      'Номзоднинг телефон рақами кўрсатилмаган.';

  @override
  String get candidateExposureNotVerified =>
      'Компаниянгиз тасдиқлангач алоқа маълумотлари очилади.';

  @override
  String get candidateExposureNoInteraction =>
      'Номзод вакансиянгизга ариза бергач ёки таклифни қабул қилгач алоқа маълумотлари очилади.';

  @override
  String get candidateExposureHidden =>
      'Номзод профилини қидирувдан яширган. У вакансияларингизни кўра олади ва ариза бера олади.';

  @override
  String get searchSavedEmpty => 'Сақланган номзодлар йўқ';

  @override
  String get commonCopy => 'Нусхалаш';

  @override
  String get commonCopied => 'Нусхаланди';

  @override
  String get vacancyDetailTitle => 'Вакансия';

  @override
  String get vacancyDescription => 'Иш ҳақида';

  @override
  String get vacancyRequirements => 'Талаблар';

  @override
  String get vacancyMandatory => 'Мажбурий';

  @override
  String get vacancyPreferred => 'Маъқул';

  @override
  String get vacancyGoneTitle => 'Бу вакансия энди мавжуд эмас';

  @override
  String get vacancyGoneBody =>
      'У ёпилган, тўлдирилган ёки муддати ўтган бўлиши мумкин.';

  @override
  String get vacancyReportReason => 'Бу вакансияда нима нотўғри?';

  @override
  String get vacancyReportSend => 'Юбориш';

  @override
  String get commonYes => 'Ҳа';

  @override
  String get commonNo => 'Йўқ';

  @override
  String vacancyOpenings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count та ўрин',
    );
    return '$_temp0';
  }

  @override
  String vacancyWorkWindow(String start, String end) {
    return '$start – $end';
  }

  @override
  String vacancyStartsOn(String date) {
    return '$date дан';
  }

  @override
  String get walletTitle => 'Ҳамён';

  @override
  String get walletBalanceLabel => 'Баланс';

  @override
  String walletCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '$_temp0';
  }

  @override
  String walletApproxUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '≈ $amountString сўм';
  }

  @override
  String walletUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString сўм';
  }

  @override
  String get walletPrices => 'Бугунги нархлар';

  @override
  String get walletCoinPriceLabel => '1 Coin';

  @override
  String get walletUnlockPriceLabel => 'Номзод контактларини очиш';

  @override
  String walletRegistrationBonusOn(String date) {
    return 'Рўйхатдан ўтиш бонуси берилди: $date';
  }

  @override
  String get walletTopUp => 'Тўлдириш';

  @override
  String get walletTopUpUnavailable =>
      'Тўлдириш ҳозирча мавжуд эмас. У Payme ва CLICK қўллаб-қувватлаши билан бирга келади.';

  @override
  String get walletActivity => 'Сўнгги операциялар';

  @override
  String get walletActivityEmpty =>
      'Бу ҳамёнда ҳали ҳеч қандай ҳаракат бўлмаган. Кирим ҳам, чиқим ҳам шу ерда кўринади ва бирор ёзув ҳеч қачон ўчирилмайди.';

  @override
  String walletBalanceAfter(int count) {
    return 'Баланс $count';
  }

  @override
  String walletAmountCredit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '+$_temp0';
  }

  @override
  String walletAmountDebit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '−$_temp0';
  }

  @override
  String get walletKindRegistrationBonus => 'Рўйхатдан ўтиш бонуси';

  @override
  String get walletKindTopUp => 'Тўлдириш';

  @override
  String get walletKindCandidateUnlock => 'Номзод контактларини очиш';

  @override
  String get walletKindAdminAdjustment => 'Администратор тузатиши';

  @override
  String get walletKindReversal => 'Қайтариш';

  @override
  String get walletKindOther => 'Ҳамён операцияси';

  @override
  String get walletCorrection => 'Тузатиш';

  @override
  String get walletBalanceUnavailable => 'Баланс мавжуд эмас';

  @override
  String unlockContact(String coins) {
    return 'Контактни очиш — $coins';
  }

  @override
  String get unlockTitle => 'Контактни очиш';

  @override
  String get unlockCost => 'Нархи';

  @override
  String get unlockBalanceNow => 'Сизнинг балансингиз';

  @override
  String get unlockBalanceAfter => 'Кейинги баланс';

  @override
  String get unlockConfirm => 'Тасдиқлаш';

  @override
  String get unlockWhatYouGet =>
      'Телефон, e-mail ва резюме очилади, суҳбатни ҳам бошлашингиз мумкин. Бир марта ечилади — кейинроқ бу номзодга қайтиш бепул.';

  @override
  String get unlockDone => 'Контактлар очилди';

  @override
  String get unlockAlready => 'Аллақачон очилган — ҳеч нарса ечилмади';

  @override
  String unlockUnlockedOn(String date) {
    return '$date да очилган';
  }

  @override
  String get unlockTopUpNeeded => 'Очиш учун тўлдиринг';

  @override
  String get candidateExposureUnlockRequired =>
      'Номзод билан ҳозир боғланиш учун контактларни очинг. Агар у сизнинг вакансиянгизга ариза юборса ёки таклифни қабул қилса, улар бепул ҳам очилади.';

  @override
  String get contactLockedTitle => 'Ҳимояланган маълумотлар';

  @override
  String get contactUnlockedTitle => 'Алоқа маълумотлари';

  @override
  String get contactPhone => 'Телефон рақами';

  @override
  String get contactEmail => 'Е-почта';

  @override
  String get contactCv => 'Резюме файли';

  @override
  String get contactCvLocked => 'PDF · қулфланган';

  @override
  String contactLockedExplainer(String coins) {
    return '$coins битта янги номзоднинг контакти, резюмеси ва ёзишмасини очади. Бир марта очилган номзод учун қайта тўлов олинмайди.';
  }

  @override
  String get unlockGoToVerification => 'Тасдиқлашга ўтиш';

  @override
  String unlockChargedDetail(String coins, String balance) {
    return '$coins ечилди · баланс $balance';
  }

  @override
  String get unlockInsufficient => 'Coin етарли эмас';

  @override
  String walletValueAndPrice(int value, int price) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return '≈ $valueString сўм · 1 Coin = $priceString сўм';
  }

  @override
  String walletCoinRule(String coins) {
    return '$coins битта янги номзод контактини очади. Номзодларни қидириш ва профилни кўриш бепул.';
  }

  @override
  String get walletHistoryTitle => 'Амаллар тарихи';

  @override
  String get walletHistoryAll => 'Барчаси';

  @override
  String get walletHistoryIncoming => 'Тўлдириш';

  @override
  String get walletHistoryOutgoing => 'Сарфланган';

  @override
  String get walletHistoryNoMatch =>
      'Бу турдаги амал ҳозирча йўқ. Ҳамёнда ёзилган ҳаммасини кўриш учун филтрни олиб ташланг.';

  @override
  String get walletDetailTitle => 'Амал тафсилоти';

  @override
  String get walletDetailSection => 'Тафсилот';

  @override
  String get walletDetailReason => 'Сабаб';

  @override
  String get walletDetailWhen => 'Сана ва вақт';

  @override
  String get walletDetailAmountUzs => 'Тўланган сумма';

  @override
  String get walletDetailEffect => 'Балансга таъсири';

  @override
  String get walletDetailBalanceAfter => 'Кейинги баланс';

  @override
  String get walletDetailReference => 'Маълумот рақами';

  @override
  String get walletDetailSupportTitle => 'Бу ёзувда нимадир нотўғрими?';

  @override
  String get walletDetailSupport =>
      'Қўллаб-қувватлаш хизматига мурожаат қилиб, юқоридаги маълумот рақамини кўрсатинг. Бу тарихдаги ҳеч бир ёзувни ўзгартириш ёки ўчириш мумкин эмас, шунинг учун сиз кўрган ёзувни улар ҳам худди шундай кўради.';

  @override
  String get walletCorrectionExplained =>
      'Бу ёзув олдингисини тузатади. Асл ёзув тарихда қолади — тузатишлар қўшилади, устидан ёзилмайди.';

  @override
  String get navInvitations => 'Таклифлар';

  @override
  String get invitationSent => 'Юборилган';

  @override
  String get invitationDetailsRequested => 'Батафсил сўралган';

  @override
  String get invitationAccepted => 'Қабул қилинган';

  @override
  String get invitationDeclined => 'Рад этилган';

  @override
  String get invitationAccept => 'Қабул қилиш';

  @override
  String get invitationDecline => 'Рад этиш';

  @override
  String get invitationRequestDetails => 'Савол бериш';

  @override
  String get invitationsInboxEmpty =>
      'Сизни вакансияга таклиф қилган иш берувчилар шу ерда кўринади.';

  @override
  String get invitationGeneral => 'Умумий таклиф';

  @override
  String get invitationOpenVacancy => 'Вакансияни очиш';

  @override
  String get invitationVacancyLoading => 'Вакансия юкланмоқда…';

  @override
  String get invitationVacancyUnavailable => 'Вакансияни юклаб бўлмади.';

  @override
  String get invitationVacancyUntitled => 'Вакансия';

  @override
  String get invitationYourReply => 'Сизнинг жавобингиз';

  @override
  String invitationPayRange(int from, int to) {
    final intl.NumberFormat fromNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String toString = toNumberFormat.format(to);

    return '$fromString – $toString сўм';
  }

  @override
  String invitationPayFrom(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString сўмдан';
  }

  @override
  String invitationPayUpTo(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString сўмгача';
  }

  @override
  String get invitationAcceptTitle => 'Бу таклиф қабул қилинсинми?';

  @override
  String get invitationAcceptDiscloses =>
      'Қабул қилсангиз, телефон рақамингиз, э-почтангиз ва резюмеингиз шу иш берувчига кўринади. Буни ортга қайтариб бўлмайди.';

  @override
  String get invitationDeclineTitle => 'Бу таклиф рад этилсинми?';

  @override
  String get invitationDeclineFinal =>
      'Алоқа маълумотларингиз ёпиқ қолади. Рад этишни ортга қайтариб бўлмайди, лекин иш берувчи кейинроқ яна таклиф қилиши мумкин.';

  @override
  String get invitationRequestDetailsTitle => 'Иш берувчига савол бериш';

  @override
  String get invitationRequestDetailsBody =>
      'Кейин ҳам қабул қилиш ёки рад этиш мумкин. Қабул қилмагунингизча алоқа маълумотларингиз ёпиқ қолади.';

  @override
  String get invitationQuestionLabel => 'Саволингиз';

  @override
  String get invitationQuestionHint =>
      'Масалан: иш айнан қаерда ва қачон бошланади?';

  @override
  String get invitationNoteLabel => 'Хабар (мажбурий эмас)';

  @override
  String get invitationNoteHint =>
      'Иш берувчи билиши керак деб ҳисоблаган нарсангиз.';

  @override
  String get invitationAlreadyAnswered =>
      'Бу таклифга аллақачон жавоб берилган';

  @override
  String get commonChoose => 'Танлаш';

  @override
  String get invitationSendTitle => 'Таклиф юбориш';

  @override
  String get invitationSend => 'Юбориш';

  @override
  String get invitationSendFree =>
      'Юбориш бепул. Алоқа маълумотлари фақат номзод қабул қилса очилади.';

  @override
  String get invitationToVacancy => 'Вакансияга';

  @override
  String get invitationVacancyLabel => 'Вакансияни танланг';

  @override
  String get invitationNoOpenVacancyTitle => 'Очиқ вакансия йўқ';

  @override
  String get invitationNoOpenVacancyBody =>
      'Таклиф фақат фаол вакансияга боғланиши мумкин. Умумий иш таклифини ҳозир ҳам юборишингиз мумкин.';

  @override
  String get invitationOccupation => 'Касб';

  @override
  String get invitationRegion => 'Вилоят';

  @override
  String get invitationDistrict => 'Туман';

  @override
  String get invitationNegotiable => 'Тўлов келишилади';

  @override
  String get invitationSalaryFrom => 'Тўлов (дан)';

  @override
  String get invitationSalaryTo => 'Тўлов (гача)';

  @override
  String get invitationSalaryPeriod => 'Давр';

  @override
  String get invitationSchedule => 'Иш вақти';

  @override
  String get invitationScheduleHint => 'Масалан: ҳафтада олти кун, эрталаб';

  @override
  String get invitationMessageLabel => 'Хабар (мажбурий эмас)';

  @override
  String get invitationMessageHint =>
      'Номзод билиши керак деб ҳисоблаган нарсангиз';

  @override
  String invitationQuotaRemaining(int remaining, int limit) {
    return 'Бугун $limit таклифдан $remaining таси қолди';
  }

  @override
  String invitationQuotaResets(String at) {
    return '$at да янгиланади';
  }

  @override
  String get invitationQuotaSpentTitle => 'Бугунги таклифлар тугади';

  @override
  String get invitationAlreadySentTitle => 'Аллақачон таклиф қилинган';

  @override
  String get invitationSentConfirm => 'Таклиф юборилди';

  @override
  String get invitationsSentTitle => 'Юборилган таклифлар';

  @override
  String get invitationsSentEmpty =>
      'Сиз таклиф қилган номзодлар шу ерда кўринади.';

  @override
  String get invitationsSentNoMatch =>
      'Бу ҳолатда таклиф йўқ. Юборилганларнинг ҳаммасини кўриш учун филтрни тозаланг.';

  @override
  String get invitationsSentForVacancy => 'Фақат бу вакансия';

  @override
  String get invitationFilterAll => 'Ҳаммаси';

  @override
  String get invitationYourMessage => 'Сиз ёзган хабар';

  @override
  String get invitationCandidateReply => 'Номзоднинг жавоби';

  @override
  String get invitationContactOpenTitle => 'Алоқа маълумотлари очиқ';

  @override
  String get invitationContactOpenBody =>
      'Номзод таклифни қабул қилди — телефон, е-почта ва резюме унинг профилида. Бунинг учун тўлов керак эмас.';

  @override
  String get invitationOpenCandidate => 'Номзодни кўриш';

  @override
  String invitationCounts(int invited, int accepted) {
    return '$invited та таклиф юборилган, $accepted таси қабул қилинган';
  }

  @override
  String get fileNoViewer => 'Бу телефонда бу файлни оча оладиган илова йўқ.';

  @override
  String get dashboardActiveVacancies => 'Фаол вакансия';

  @override
  String get dashboardOpenPositions => 'Очиқ ўрин';

  @override
  String get dashboardNewApplications => 'Янги ариза';

  @override
  String get dashboardAttention => 'Сизнинг эътиборингиз керак';

  @override
  String get dashboardAttentionClear => 'Сиздан кутилаётган иш йўқ.';

  @override
  String get dashboardVerificationTitle => 'Тасдиқлаш тугалланмаган';

  @override
  String get dashboardVacancyRejected => 'Ўзгартириш талаб қилинади';

  @override
  String dashboardUnreviewed(int count) {
    return '$count та ариза кўриб чиқилмаган';
  }

  @override
  String dashboardSavedCandidates(int count) {
    return '$count та сақланган номзод';
  }

  @override
  String get dashboardHiring => 'Ишга қабул жараёни';

  @override
  String dashboardHiredOf(int hired, int openings) {
    return '$openings дан $hired';
  }

  @override
  String dashboardMeterHired(int count) {
    return 'Ишга олинди $count';
  }

  @override
  String dashboardMeterInvited(int count) {
    return 'Таклиф юборилди $count';
  }

  @override
  String dashboardMeterRemaining(int count) {
    return 'Қолган $count';
  }

  @override
  String get dashboardWallet => 'Ҳамён';

  @override
  String get accountTitle => 'Ҳисоб ва хавфсизлик';

  @override
  String get accountDevices => 'Кирган қурилмалар';

  @override
  String get accountDevicesBody =>
      'Танимаган қурилмани кўрсангиз, унинг сеансини тугатинг.';

  @override
  String get accountDeviceUnknown => 'Номсиз қурилма';

  @override
  String accountLastUsed(String at) {
    return 'Охирги фойдаланиш: $at';
  }

  @override
  String get accountThisDevice => 'Бу қурилма';

  @override
  String get accountRevoke => 'Сеансни тугатиш';

  @override
  String get accountRevokeTitle => 'Бу сеанс тугатилсинми?';

  @override
  String get accountRevokeBody => 'Ўша қурилма қайтадан кириши керак бўлади.';

  @override
  String get accountRevokeCurrentTitle => 'Бу қурилмадан чиқилсинми?';

  @override
  String get accountRevokeCurrentBody =>
      'Бу — сиз фойдаланаётган қурилма. Ҳозир ҳисобдан чиқариласиз.';

  @override
  String get accountRevokeAll => 'Барча сеансларни тугатиш';

  @override
  String get accountRevokeAllTitle => 'Барча сеанслар тугатилсинми?';

  @override
  String get accountRevokeAllBody =>
      'Барча қурилмалар, шу қурилма ҳам, ҳисобдан чиқарилади.';

  @override
  String get accountDelete => 'Ҳисобни ўчириш';

  @override
  String get accountDeleteBody =>
      'Профилингиз, аризаларингиз ва хабарларингиз ўчирилади. Бу қайтариб бўлмайди.';

  @override
  String get accountDeleteAction => 'Ўчиришни сўраш';

  @override
  String get accountDeleteConfirmTitle => 'Ҳисобни ўчириш сўралсинми?';

  @override
  String get accountDeleteConfirmBody =>
      'Ҳисобингизни ўчиришни бошлаймиз. Буни иловадан қайтариб бўлмайди.';

  @override
  String get accountDeleteRequestedTitle => 'Ўчириш сўралди';

  @override
  String get accountDeleteRequestedBody =>
      'Сўровингиз қайд этилди. Кейин нима бўлишини қўллаб-қувватлаш хизмати айтади.';

  @override
  String get filtersRegion => 'Вилоят ёки туман';

  @override
  String get filtersEmploymentType => 'Бандлик тури';

  @override
  String get filtersWorkFormat => 'Иш формати';

  @override
  String get filtersShift => 'Смена';

  @override
  String get filtersSalaryFrom => 'Маош, дан';

  @override
  String get filtersSalaryNegotiableNote =>
      'Маоши келишилган вакансиялар ҳам кўрсатилади.';

  @override
  String get filtersPublishedFrom => 'Чоп этилган, дан';

  @override
  String get filtersUnavailableTitle => 'Учта филтр ҳозирча мавжуд эмас';

  @override
  String get filtersUnavailableBody =>
      'Тажриба, тил ва маошнинг юқори чегараси бўйича ҳозирча филтрлаш мумкин эмас. Қолгани ишлайди.';

  @override
  String feedFilteredNote(int count) {
    return '$count филтр қўлланган';
  }

  @override
  String get feedFilteredEmpty =>
      'Бу филтрларга мос вакансия йўқ. Уларни кенгайтириб кўринг.';

  @override
  String get feedSavedUnfiltered => 'Сақланган вакансиялар филтрланмайди.';

  @override
  String get notesEmpty => 'Ҳозирча изоҳ йўқ.';

  @override
  String get notesNewLabel => 'Янги изоҳ';

  @override
  String get notesNewHint =>
      '8m сўради, 6.5 га рози бўлиши мумкин — пайшанба куни қўнғироқ';

  @override
  String get applicantsNoneAtStage =>
      'Бу босқичда ҳеч ким йўқ. Ҳамма аризачини кўриш учун филтрни тозаланг.';

  @override
  String get shortlistTitle => 'Шорт-лист';

  @override
  String get shortlistEmpty => 'Шорт-листда ҳозирча ҳеч ким йўқ';

  @override
  String get roleSelectionTitle => 'JobBridge\'дан қандай фойдаланасиз?';

  @override
  String get roleSelectionSubtitle =>
      'Биттасини ёки иккаласини танланг — иккинчисини кейин ҳам, иккинчи аккаунт очмасдан қўшишингиз мумкин.';

  @override
  String get roleCandidateDescription =>
      'Иш берувчилар топадиган профил яратинг, вакансияларга ариза юборинг ва таклифномаларга жавоб беринг.';

  @override
  String get roleEmployerDescription =>
      'Вакансия жойланг, номзодларни қидиринг ва гаплашмоқчи бўлганларингизни таклиф қилинг.';

  @override
  String get roleSelectionBoth =>
      'Иккаласи танланганда битта аккаунт иккита алоҳида маконни сақлайди: ўз профилингиз ва компаниянгиз профили — алмаштириш профилингизда.';

  @override
  String get chatListEmpty =>
      'Суҳбат иш бўйича алоқа пайдо бўлгач очилади — ариза ёки қабул қилинган таклиф.';

  @override
  String get chatParticipantUnknown => 'Иштирокчи';

  @override
  String chatUnreadCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String chatUnreadSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count та ўқилмаган хабар',
    );
    return '$_temp0';
  }

  @override
  String get chatNoMessages => 'Ҳозирча хабар йўқ';

  @override
  String get chatAttachment => 'Илова';

  @override
  String get chatReadOnly => 'Фақат ўқиш';

  @override
  String get chatBlocked => 'Блокланган';

  @override
  String get chatBlockedByYou => 'Сиз блоклагансиз';

  @override
  String get chatReadOnlyTitle => 'Бу суҳбат тарихга айланди';

  @override
  String get chatReadOnlyBody =>
      'У бошланган ариза ёки таклиф тугади, шунинг учун янги хабар юборилмайди. Мавжуд хабарлар ўқиш учун қолади.';

  @override
  String get chatBlockedTitle => 'Блокланган';

  @override
  String get chatBlockedBody =>
      'Суҳбатни иккинчи томон блоклади. Блок турган вақтда ҳеч ким хабар юбора олмайди, хабарлар эса ўқиш учун қолади.';

  @override
  String get chatBlockedByYouTitle => 'Сиз бу суҳбатни блоклагансиз';

  @override
  String get chatBlockedByYouBody =>
      'Блок турган вақтда икки томон ҳам хабар юбора олмайди — сиз ҳам. Яна ёзиш учун экран юқорисидаги блокни олиб ташланг.';

  @override
  String get chatUnblock => 'Блокни олиб ташлаш';

  @override
  String get chatUnblocked => 'Блок олиб ташланди. Яна ёзишингиз мумкин.';

  @override
  String get chatBlockAction => 'Блоклаш';

  @override
  String get chatBlockTitle => 'Бу суҳбатни блоклайсизми?';

  @override
  String get chatBlockBody =>
      'У иккингиз учун ҳам фақат ўқиш ҳолатига ўтади — сиз ҳам юбора олмайсиз. Хабарлар ўқиш учун қолади ва модератор уларни кўриб чиқиши мумкин.';

  @override
  String get chatBlockReasonLabel => 'Сабаб (мажбурий эмас)';

  @override
  String get chatBlockReasonHint => 'Буни кўриб чиқадиган модератор учун';

  @override
  String get chatReportTitle => 'Бу хабар устидан шикоят қилиш';

  @override
  String get chatReportBody =>
      'Шикоятни модератор ўқиб, қарор қабул қилади. Суҳбатни блоклаш — алоҳида амал, иккаласини ҳам қилишингиз мумкин.';

  @override
  String get chatReportReasonLabel => 'Нимаси нотўғри';

  @override
  String get chatReportReasonHint => 'Иш учун пул тўлашимни сўради';

  @override
  String get chatReportSubmit => 'Шикоятни юбориш';

  @override
  String get chatReportDone => 'Шикоят юборилди. Модератор кўриб чиқади.';

  @override
  String get chatComposerLabel => 'Хабар';

  @override
  String get chatComposerHint => 'Хабар ёзинг';

  @override
  String get chatSend => 'Юбориш';

  @override
  String get chatSendRefusedTitle => 'Юборилмади';

  @override
  String get chatSent => 'Юборилди';

  @override
  String get chatRead => 'Ўқилган';

  @override
  String get chatEarlier => 'Олдинги хабарлар';

  @override
  String get chatThreadEmpty => 'Ҳозирча хабар йўқ. Биринчисини ёзинг.';

  @override
  String get chatThreadEmptyClosed =>
      'Бу суҳбат ёпилишидан олдин ҳеч қандай хабар юборилмаган.';

  @override
  String get chatOpenAction => 'Хабар юбориш';

  @override
  String get interviewTitle => 'Суҳбат';

  @override
  String get interviewStatusScheduled => 'Белгиланган';

  @override
  String get interviewStatusConfirmed => 'Тасдиқланган';

  @override
  String get interviewStatusRescheduleRequested => 'Бошқа вақт сўралди';

  @override
  String get interviewStatusCancelled => 'Бекор қилинган';

  @override
  String get interviewTypePhone => 'Телефон орқали';

  @override
  String get interviewTypeInPerson => 'Юзма-юз';

  @override
  String get interviewTypeExternalLink => 'Видео ҳавола';

  @override
  String get interviewPhoneNote =>
      'Иш берувчи профилингиздаги рақамга қўнғироқ қилади.';

  @override
  String get interviewWhere => 'Манзил';

  @override
  String get interviewLink => 'Ҳавола';

  @override
  String get interviewInstructions => 'Иш берувчидан';

  @override
  String get interviewYourReply => 'Сизнинг жавобингиз';

  @override
  String get interviewPassed => 'Бу вақт аллақачон ўтиб кетган.';

  @override
  String get interviewCancelledNotice => 'Бу суҳбатни иш берувчи бекор қилди.';

  @override
  String get interviewConfirm => 'Тасдиқлаш';

  @override
  String get interviewRequestAnother => 'Бошқа вақт сўраш';

  @override
  String get interviewConfirmTitle => 'Бу вақтни тасдиқлайсизми?';

  @override
  String get interviewConfirmBody =>
      'Иш берувчи вақт сизга қулай эканини кўради. Кейинчалик бирор нарса ўзгарса, бошқа вақт сўрашингиз мумкин.';

  @override
  String get interviewRescheduleTitle => 'Бошқа вақт сўраш';

  @override
  String get interviewRescheduleBody =>
      'Иш берувчи янги вақт белгиламагунча суҳбат кучда қолади ва у қуйида ёзганингизни кўради.';

  @override
  String get interviewNoteLabel => 'Қайси вақтлар сизга қулай';

  @override
  String get interviewNoteHint => 'Шу ҳафта тушдан кейин ёки жума куни эрталаб';

  @override
  String get interviewReplyNoteLabel => 'Изоҳ (мажбурий эмас)';

  @override
  String get interviewReplyNoteHint => 'Ўн дақиқа олдин етиб бораман';

  @override
  String get interviewNotAllowed => 'Бу суҳбат ҳолати ўзгарган';

  @override
  String get interviewSchedule => 'Суҳбат белгилаш';

  @override
  String get interviewScheduleTitle => 'Суҳбат белгилаш';

  @override
  String get interviewScheduleSave => 'Номзодга юбориш';

  @override
  String get interviewRescheduleFormTitle => 'Суҳбат вақтини ўзгартириш';

  @override
  String get interviewRescheduleSave => 'Янги вақтни сақлаш';

  @override
  String get interviewRescheduleResets =>
      'Кичик ўзгариш бўлса ҳам, номзоддан қайта тасдиқлаш сўралади — бошқа вақтга кўчирилган суҳбат тасдиқланмаган ҳисобланади.';

  @override
  String get interviewTypeLabel => 'Суҳбат тури';

  @override
  String get interviewWhereHint =>
      'Амир Темур 12, 3-қават — қабулхонада Дилнозани сўранг';

  @override
  String get interviewLinkHint => 'https://meet.example.com/abc-defg-hij';

  @override
  String get interviewDateLabel => 'Сана';

  @override
  String get interviewTimeLabel => 'Вақт';

  @override
  String get interviewTimeHint => '10:00';

  @override
  String get interviewInstructionsLabel =>
      'Нима олиб келиши ёки тайёрлаши керак';

  @override
  String get interviewInstructionsHint =>
      'Дипломингизни ва меҳнат дафтарингизни олиб келинг';

  @override
  String get interviewReschedule => 'Кўчириш';

  @override
  String get interviewCancelAction => 'Бекор қилиш';

  @override
  String get interviewCancelTitle => 'Бу суҳбатни бекор қиласизми?';

  @override
  String get interviewCancelBody =>
      'Бу икки томон учун ҳам қатъий — суҳбатни қайтариб бўлмайди, янги вақт эса янги суҳбат белгилашни талаб қилади. Номзод бекор қилинганини кўради.';

  @override
  String get interviewCancelReasonLabel =>
      'Сабаб (мажбурий эмас, номзод кўради)';

  @override
  String get interviewCancelReasonHint =>
      'Лавозим тўлдирилди — вақтингиз учун раҳмат';

  @override
  String get interviewCandidateReply => 'Номзод нима деди';

  @override
  String get commonShowMore => 'Кўпроқ кўрсатиш';

  @override
  String get commonLoadingMore => 'Яна юкланмоқда…';

  @override
  String get adminDashboardTitle => 'Бошқарув';

  @override
  String get adminQueuesTitle => 'Қарор кутмоқда';

  @override
  String get adminAwaitingVerification => 'Тасдиқлаш кутаётган иш берувчилар';

  @override
  String get adminAwaitingModeration => 'Модерация кутаётган вакансиялар';

  @override
  String get adminOpenComplaints => 'Очиқ шикоятлар';

  @override
  String get adminQueuesClear => 'Сизни кутаётган иш йўқ.';

  @override
  String get adminSanctionsTitle => 'Чекловдаги ҳисоблар';

  @override
  String get adminRestrictedUsers => 'Чекланган';

  @override
  String get adminBlockedUsers => 'Блокланган';

  @override
  String get adminPeriodTitle => 'Танланган давр учун';

  @override
  String adminPeriodDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days кун',
    );
    return '$_temp0';
  }

  @override
  String get adminCandidates => 'Номзодлар';

  @override
  String get adminEmployers => 'Иш берувчилар';

  @override
  String get adminVacanciesPublished => 'Эълон қилинган вакансиялар';

  @override
  String get adminApplicationsSubmitted => 'Юборилган аризалар';

  @override
  String get adminCountTotal => 'жами';

  @override
  String get adminCountNew => 'янги';

  @override
  String get adminVerificationTitle => 'Иш берувчини тасдиқлаш';

  @override
  String get adminVerificationFifo =>
      'Энг эскиси биринчи — юқоридаги ариза энг узоқ кутган.';

  @override
  String get adminVerificationEmpty => 'Кутаётган ҳеч ким йўқ';

  @override
  String get adminVerificationEmptyBody =>
      'Иш берувчилар ҳужжатларини юборган сайин аризалар шу ерда пайдо бўлади.';

  @override
  String get adminEmployerCompany => 'Ташкилот';

  @override
  String get adminEmployerIndividual => 'Жисмоний шахс';

  @override
  String get adminEmployerUnnamed => 'Ном киритилмаган';

  @override
  String adminWaitingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days кундан бери кутмоқда',
      zero: 'Бугун юборилган',
    );
    return '$_temp0';
  }

  @override
  String get adminEvidenceTitle => 'Ҳужжатлар';

  @override
  String get adminEvidenceNone => 'Ҳужжат илова қилинмаган';

  @override
  String get adminVerify => 'Тасдиқлаш';

  @override
  String get adminRequestChanges => 'Ўзгартириш сўраш';

  @override
  String get adminReject => 'Рад этиш';

  @override
  String get adminVerifyTitle => 'Бу иш берувчини тасдиқлайсизми?';

  @override
  String get adminVerifyBody =>
      'Бу уларга вакансия эълон қилиш ва номзодларни таклиф қилиш имконини беради. Ҳисобдаги бошқа ҳеч нарса ўзгармайди.';

  @override
  String get adminRequestChangesTitle => 'Тузатиш учун қайтарасизми?';

  @override
  String get adminRequestChangesBody =>
      'Профил ва файллар сақланади — сиз қуйида айтган нарсани тузатиб, қайтадан юборишлари мумкин.';

  @override
  String get adminRejectTitle => 'Бу аризани рад этасизми?';

  @override
  String get adminRejectBody =>
      'Улар тасдиқланмаган ҳолатда қолади, эълон ҳам, таклиф ҳам қила олмайди. Уларга фақат сизнинг сабабингиз етади — нима қилиш кераклигини ёзинг.';

  @override
  String get adminReasonLabel => 'Сабаб (иш берувчи сўзма-сўз ўқийди)';

  @override
  String get adminReasonHint =>
      'Рўйхатга олиш гувоҳномаси ўқилмайди — аниқроқ нусха юкланг';

  @override
  String get adminAlreadyDecided => 'Аллақачон ҳал қилинган';

  @override
  String get adminDecisionRecorded => 'Қарор қайд этилди.';

  @override
  String get adminQueueTitle => 'Модерация';

  @override
  String get adminQueueEmployers => 'Иш берувчилар';

  @override
  String get adminQueueVacancies => 'Вакансиялар';

  @override
  String get adminModerationEmpty => 'Кутаётган вакансия йўқ';

  @override
  String get adminModerationEmptyBody =>
      'Иш берувчилар эълон қилиш учун юборган сайин вакансиялар шу ерда пайдо бўлади.';

  @override
  String get adminRestrictionFlag => 'Ёш ёки жинс чеклови';

  @override
  String get adminReviewTitle => 'Кўриб чиқиш';

  @override
  String get adminVacancyGoneTitle => 'Бу вакансия навбатдан чиқиб кетган';

  @override
  String get adminVacancyGoneBody =>
      'Кимдир уни аллақачон ҳал қилган ёки иш берувчи қайтариб олган бўлиши мумкин.';

  @override
  String get adminPublish => 'Эълон қилиш';

  @override
  String get adminSendBack => 'Қайтариш';

  @override
  String get adminPublishTitle => 'Бу вакансияни эълон қиласизми?';

  @override
  String get adminPublishBody =>
      'Номзодлар уни дарҳол кўради. Агар ёш ёки жинс чеклови бўлса, эълон қилиш ўша чекловни ҳам тасдиқлайди — чекловли вакансия фақат шу навбат орқали эълон қилиниши мумкин.';

  @override
  String get adminSendBackTitle => 'Бу вакансияни қайтарасизми?';

  @override
  String get adminSendBackBody =>
      'Иш берувчи уни тузатиб қайта юбориши мумкин. Уларга фақат сизнинг сабабингиз етади — нимани ўзгартириш кераклигини айтиб беринг.';

  @override
  String get adminRestrictionJudge =>
      'Чеклов фақат сабаб уни ҳақиқатан талаб қилса рухсат этилади. Чекловни эмас, сабабни баҳоланг.';

  @override
  String get adminRestrictionAge => 'Ёш чеклови';

  @override
  String get adminRestrictionGender => 'Жинс чеклови';

  @override
  String get adminRestrictionReason => 'Иш берувчи танлаган сабаб';

  @override
  String get adminRestrictionNote => 'Ўз сўзлари билан';

  @override
  String get adminPreviousReason => 'Аввал шу сабаб билан қайтарилган';

  @override
  String get adminVacancyWhere => 'Иш жойи';

  @override
  String get adminVacancyEmployer => 'Иш берувчи';

  @override
  String get adminVacancyEmployerPhone => 'Кириш рақами';

  @override
  String get adminComplaintsTitle => 'Шикоятлар';

  @override
  String get adminComplaintsEmpty => 'Шикоят йўқ';

  @override
  String get adminComplaintsEmptyBody => 'Ҳеч бир шикоят қарорни кутмаяпти.';

  @override
  String get adminComplaintKindVacancy => 'Вакансия';

  @override
  String get adminComplaintKindUser => 'Фойдаланувчи';

  @override
  String get adminComplaintKindProfile => 'Профил';

  @override
  String get adminComplaintKindMessage => 'Хабар';

  @override
  String get adminComplaintKindUnknown => 'Номаълум тур';

  @override
  String get adminComplaintKindUnknownBody =>
      'Илованинг бу версияси бу объект турини кўрсата олмайди. Кўриб чиқиш учун иловани янгиланг.';

  @override
  String get adminComplaintTitle => 'Шикоят';

  @override
  String get adminComplaintGoneTitle => 'Бу шикоят топилмади';

  @override
  String get adminComplaintGoneBody =>
      'Кимдир уни кўриб чиққан ёки у ҳеч қачон бўлмаган. Ҳал қиладиган нарса қолмади.';

  @override
  String get adminComplaintReported => 'Нима ҳақида хабар қилинган';

  @override
  String get adminComplaintTarget => 'Шикоят қилинган объект';

  @override
  String get adminComplaintTargetGone => 'Шикоят қилинган объект ўчирилган';

  @override
  String get adminComplaintTargetGoneBody =>
      'У шикоят берилгандан кейин ўчирилган. Шикоят сақланади, шунинг учун натижани ҳали ҳам қайд этиш мумкин.';

  @override
  String get adminComplaintEmployerAccount => 'Иш берувчи ҳисоби';

  @override
  String get adminComplaintRemedy => 'Аввал чора кўринг';

  @override
  String get adminComplaintRemedyBody =>
      'Шикоятни қабул қилинган деб қайд этиш ҳеч нарсани амалга оширмайди. Аввал шу ерда чора кўринг.';

  @override
  String get adminComplaintNoRemedy =>
      'Бу ерда кўрадиган чора йўқ. Натижани пастда қайд этинг.';

  @override
  String get adminComplaintOutcome => 'Натижани қайд этинг';

  @override
  String get adminComplaintOutcomeBody =>
      'Шикоятни кўриб чиқишни бошқа ҳеч нарса қайд этмайди, шунинг учун ёзганингиз — унинг ягона баёни.';

  @override
  String get adminComplaintUphold => 'Қабул қилиш';

  @override
  String get adminComplaintDismiss => 'Рад этиш';

  @override
  String get adminComplaintUpholdTitle => 'Бу шикоят қабул қилинсинми?';

  @override
  String get adminComplaintUpholdBody =>
      'Шикоят қабул қилинган ҳолда ёпилади. Чора керак бўлса, буни қайд этишдан олдин кўринг.';

  @override
  String get adminComplaintDismissTitle => 'Бу шикоят рад этилсинми?';

  @override
  String get adminComplaintDismissBody =>
      'Шикоят ҳеч қандай чорасиз ёпилади. Сабабини ёзинг — бу қарорнинг ягона баёни.';

  @override
  String get adminResolutionLabel => 'Қарор (аудит журналида сақланади)';

  @override
  String get adminResolutionHint =>
      'Вакансия тўхтатилди ва иш берувчидан тавсифдан телефон рақамини олиб ташлаш сўралди';

  @override
  String get adminPauseVacancy => 'Вакансияни тўхтатиш';

  @override
  String get adminCloseVacancy => 'Вакансияни олиб ташлаш';

  @override
  String get adminPauseVacancyTitle => 'Вакансия тўхтатилсинми?';

  @override
  String get adminPauseVacancyBody =>
      'Вакансия дарҳол лентадан чиқади ва иш берувчи тузатгандан кейин қайта тикланиши мумкин.';

  @override
  String get adminCloseVacancyTitle => 'Вакансия олиб ташлансинми?';

  @override
  String get adminCloseVacancyBody =>
      'Вакансия лентадан бутунлай чиқади. Олиб ташланган вакансия қайта очилмайди — иш берувчи тузатиши мумкин бўлса, уни тўхтатинг.';

  @override
  String get adminWarnUser => 'Огоҳлантириш юбориш';

  @override
  String get adminWarnUserTitle => 'Огоҳлантириш юборилсинми?';

  @override
  String get adminWarnUserBody =>
      'Ҳисоби ўзгармайди. Огоҳлантириш ва унинг сабаби қайд этилади, фойдаланувчи эса хабардор қилинади.';

  @override
  String get adminWarnReasonLabel =>
      'Огоҳлантириш (фойдаланувчи сўзма-сўз ўқийди)';

  @override
  String get adminWarnReasonHint =>
      'Оммавий вакансия тавсифида алоқа маълумотларини кўрсатиш мумкин эмас — илтимос, олиб ташланг';

  @override
  String get adminAccountStatusActive => 'Фаол';

  @override
  String get adminAccountStatusRestricted => 'Чекланган';

  @override
  String get adminAccountStatusBlocked => 'Блокланган';

  @override
  String get adminVacancyEmployerContactPhone => 'Алоқа рақами';

  @override
  String get adminUsersTitle => 'Фойдаланувчилар';

  @override
  String get adminUserSearchPhone => 'Телефон рақами';

  @override
  String get adminUserSearchPhoneHint => 'Охирги рақамларининг ўзи ҳам етади';

  @override
  String get adminUserSearchPhoneTooShort => 'Камида 3 та рақам.';

  @override
  String get adminUserSearchName => 'Исм ёки ном';

  @override
  String get adminUserSearchNameHint => 'Шахс, компания ёки унинг юридик номи';

  @override
  String get adminUserSearchNameTooShort => 'Камида 2 та белги.';

  @override
  String get adminUserSearchMore => 'Кўпроқ филтр';

  @override
  String get adminUserSearchFewer => 'Камроқ филтр';

  @override
  String get adminUserSearchRole => 'Қуйидаги роли бор';

  @override
  String get adminUserSearchStatus => 'Ҳисоб ҳолати';

  @override
  String get adminUserSearchRegisteredFrom => 'Рўйхатдан ўтган (дан)';

  @override
  String get adminUserSearchRegisteredTo => 'Рўйхатдан ўтган (гача)';

  @override
  String get adminUserSearchDatesReversed => 'Бу саналар мос кела олмайди';

  @override
  String get adminUserSearchDatesReversedBody =>
      'Биринчи сана иккинчисидан кейин турибди, шунинг учун улар орасига ҳеч қандай ҳисоб тушмайди.';

  @override
  String get adminUserSearchRun => 'Қидириш';

  @override
  String get adminUserSearchClear => 'Филтрларни тозалаш';

  @override
  String get adminUserSearchIdle => 'Ҳисобни топинг';

  @override
  String get adminUserSearchIdleBody =>
      'Телефон рақамининг охирги рақамлари бўйича ёки ҳисоб танилган исталган ном бўйича қидиринг — шахс исми, компаниянинг очиқ номи ёки юридик номи. Сиз сўрамагунингизча ҳеч нарса ўқилмайди.';

  @override
  String get adminUserSearchEmpty => 'Мос келадиган ҳисоб топилмади';

  @override
  String get adminUserSearchEmptyBody =>
      'Бу филтрларга ҳеч нарса мос келмади. Телефон рақами ичидаги исталган қисм бўйича топилади, шунинг учун охирги бир неча рақам бошқача ёзилган тўлиқ рақам топа олмаган ҳисобни топади.';

  @override
  String get adminUserSearchOrder =>
      'Энг янги рўйхатдан ўтганлар биринчи. Эскироқ ҳисоб рўйхатнинг пастида туради, йўқ эмас — саҳифалаб излашдан кўра қидирувни торайтиринг.';

  @override
  String get adminUserNoName => 'Ҳисобда исм йўқ';

  @override
  String get adminUserNoPhone => 'Телефон рақами йўқ';

  @override
  String adminUserRegistered(String date) {
    return 'Рўйхатдан ўтган: $date';
  }

  @override
  String adminUserLastLogin(String date) {
    return 'Охирги кириш: $date';
  }

  @override
  String get adminUserNeverSignedIn => 'Ҳеч қачон кирмаган';

  @override
  String get adminAccountStatusDeletionRequested => 'Ўчириш сўралган';

  @override
  String get adminUserTitle => 'Ҳисоб';

  @override
  String get adminUserGoneTitle => 'Бу ҳисоб энди йўқ';

  @override
  String get adminUserGoneBody =>
      'Топилмади. Уни топган қидирувдан кейин ўчирилган бўлиши мумкин.';

  @override
  String get adminUserActions => 'Ҳисоб бўйича чора кўриш';

  @override
  String get adminUserNoActionsTitle =>
      'Бу ердан ҳеч қандай чора кўриб бўлмайди';

  @override
  String get adminUserNoActionsBody =>
      'Бу ҳисоб ўчирилишини сўраган. Сўров ўз жараёни орқали ҳал қилинади, бу ерда чеклаш ёки блоклаш эса сўровни бекор қилиб юборади.';

  @override
  String get adminUserRestrict => 'Чеклаш';

  @override
  String get adminUserBlock => 'Блоклаш';

  @override
  String get adminUserUnblock => 'Блокдан чиқариш';

  @override
  String get adminUserLiftRestriction => 'Чекловни олиб ташлаш';

  @override
  String get adminUserRestrictTitle => 'Бу ҳисоб чеклансинми?';

  @override
  String get adminUserRestrictBody =>
      'Ҳисоб уларда қолади ва кира оладилар, лекин чеклов олиб ташланмагунча бирор нарсани ўзгартирадиган ҳар қандай амал рад этилади. Сизнинг сабабингиз уларга кўрсатилади.';

  @override
  String get adminUserBlockTitle => 'Бу ҳисоб блоклансинми?';

  @override
  String get adminUserBlockBody =>
      'Сабабни тушунтирувчи хабардан бошқа ҳамма нарсага кириш ёпилади. Буни фақат администратор қайтара олади.';

  @override
  String get adminUserUnblockTitle => 'Ҳисоб блокдан чиқарилсинми?';

  @override
  String get adminUserLiftRestrictionTitle => 'Чеклов олиб ташлансинми?';

  @override
  String get adminUserLiftBody =>
      'Бундан буён уларга ҳамма нарса яна очиқ бўлади.';

  @override
  String get adminUserRestrictUntilLabel => 'Тугаш санаси';

  @override
  String get adminUserRestrictUntilCaption =>
      'Чеклов шу куннинг бошида, Тошкент вақти билан олиб ташланади. Бўш қолдирсангиз, администратор олиб ташлагунича қолади.';

  @override
  String get adminUserStatusReasonLabel => 'Сабаб (улар сўзма-сўз ўқийди)';

  @override
  String get adminUserStatusReasonHint =>
      'Номзодлардан пул сўрайдиган вакансияларни қайта-қайта жойлаштиргани учун';

  @override
  String adminUserRestrictedUntil(String date) {
    return '$date гача чекланган';
  }

  @override
  String get adminUserRestrictedIndefinitely =>
      'Администратор олиб ташлагунича чекланган';

  @override
  String get adminUserHistory => 'Ҳисоб тарихи';

  @override
  String get adminUserHistoryEmpty =>
      'Бу ҳисобнинг ҳолати ҳеч қачон ўзгармаган.';

  @override
  String adminUserHistoryBy(String actor) {
    return '$actor томонидан';
  }

  @override
  String get adminUserHistoryAutomatic => 'Муддат ўтгач, платформа томонидан';

  @override
  String get adminUserComplaints => 'Бу ҳисоб устидан шикоятлар';

  @override
  String get adminUserComplaintsEmpty =>
      'Бу ҳисоб устидан ҳеч ким шикоят қилмаган.';

  @override
  String get adminUserComplaintOpen => 'Очиқ';

  @override
  String get adminUserComplaintClosed => 'Кўриб чиқилган';
}

/// The translations for Uzbek, using the Latin script (`uz_Latn`).
class AppL10nUzLatn extends AppL10nUz {
  AppL10nUzLatn() : super('uz_Latn');

  @override
  String get appTitle => 'JobBridge';

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
  String get searchShortlist => 'Short-listga qo\'shish';

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

  @override
  String get candidateProfileTitle => 'Nomzod';

  @override
  String get candidateViewProfile => 'Profilni ochish';

  @override
  String get candidateContact => 'Aloqa';

  @override
  String candidateAvailableFrom(String date) {
    return '$date dan tayyor';
  }

  @override
  String get candidateAttachments => 'Ilovalar';

  @override
  String get candidateNoFiles => 'Nomzod hech narsa yuklamagan';

  @override
  String get candidatePhoneNotOnFile =>
      'Nomzodning telefon raqami ko’rsatilmagan.';

  @override
  String get candidateExposureNotVerified =>
      'Kompaniyangiz tasdiqlangach aloqa ma’lumotlari ochiladi.';

  @override
  String get candidateExposureNoInteraction =>
      'Nomzod vakansiyangizga ariza bergach yoki taklifni qabul qilgach aloqa ma’lumotlari ochiladi.';

  @override
  String get candidateExposureHidden =>
      'Nomzod profilini qidiruvdan yashirgan. U vakansiyalaringizni ko’ra oladi va ariza bera oladi.';

  @override
  String get searchSavedEmpty => 'Saqlangan nomzodlar yo’q';

  @override
  String get commonCopy => 'Nusxalash';

  @override
  String get commonCopied => 'Nusxalandi';

  @override
  String get vacancyDetailTitle => 'Vakansiya';

  @override
  String get vacancyDescription => 'Ish haqida';

  @override
  String get vacancyRequirements => 'Talablar';

  @override
  String get vacancyMandatory => 'Majburiy';

  @override
  String get vacancyPreferred => 'Ma’qul';

  @override
  String get vacancyGoneTitle => 'Bu vakansiya endi mavjud emas';

  @override
  String get vacancyGoneBody =>
      'U yopilgan, to\'ldirilgan yoki muddati o\'tgan bo\'lishi mumkin.';

  @override
  String get vacancyReportReason => 'Bu vakansiyada nima noto\'g\'ri?';

  @override
  String get vacancyReportSend => 'Yuborish';

  @override
  String get commonYes => 'Ha';

  @override
  String get commonNo => 'Yo\'q';

  @override
  String vacancyOpenings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta o\'rin',
    );
    return '$_temp0';
  }

  @override
  String vacancyWorkWindow(String start, String end) {
    return '$start – $end';
  }

  @override
  String vacancyStartsOn(String date) {
    return '$date dan';
  }

  @override
  String get walletTitle => 'Hamyon';

  @override
  String get walletBalanceLabel => 'Balans';

  @override
  String walletCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '$_temp0';
  }

  @override
  String walletApproxUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '≈ $amountString so\'m';
  }

  @override
  String walletUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString so\'m';
  }

  @override
  String get walletPrices => 'Bugungi narxlar';

  @override
  String get walletCoinPriceLabel => '1 Coin';

  @override
  String get walletUnlockPriceLabel => 'Nomzod kontaktlarini ochish';

  @override
  String walletRegistrationBonusOn(String date) {
    return 'Ro\'yxatdan o\'tish bonusi berildi: $date';
  }

  @override
  String get walletTopUp => 'To\'ldirish';

  @override
  String get walletTopUpUnavailable =>
      'To\'ldirish hozircha mavjud emas. U Payme va CLICK qo\'llab-quvvatlashi bilan birga keladi.';

  @override
  String get walletActivity => 'So\'nggi operatsiyalar';

  @override
  String get walletActivityEmpty =>
      'Bu hamyonda hali hech qanday harakat bo\'lmagan. Kirim ham, chiqim ham shu yerda ko\'rinadi va biror yozuv hech qachon o\'chirilmaydi.';

  @override
  String walletBalanceAfter(int count) {
    return 'Balans $count';
  }

  @override
  String walletAmountCredit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '+$_temp0';
  }

  @override
  String walletAmountDebit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      one: '$count Coin',
    );
    return '−$_temp0';
  }

  @override
  String get walletKindRegistrationBonus => 'Ro\'yxatdan o\'tish bonusi';

  @override
  String get walletKindTopUp => 'To\'ldirish';

  @override
  String get walletKindCandidateUnlock => 'Nomzod kontaktlarini ochish';

  @override
  String get walletKindAdminAdjustment => 'Administrator tuzatishi';

  @override
  String get walletKindReversal => 'Qaytarish';

  @override
  String get walletKindOther => 'Hamyon operatsiyasi';

  @override
  String get walletCorrection => 'Tuzatish';

  @override
  String get walletBalanceUnavailable => 'Balans mavjud emas';

  @override
  String unlockContact(String coins) {
    return 'Kontaktni ochish — $coins';
  }

  @override
  String get unlockTitle => 'Kontaktni ochish';

  @override
  String get unlockCost => 'Narxi';

  @override
  String get unlockBalanceNow => 'Sizning balansingiz';

  @override
  String get unlockBalanceAfter => 'Keyingi balans';

  @override
  String get unlockConfirm => 'Tasdiqlash';

  @override
  String get unlockWhatYouGet =>
      'Telefon, e-mail va rezyume ochiladi, suhbatni ham boshlashingiz mumkin. Bir marta yechiladi — keyinroq bu nomzodga qaytish bepul.';

  @override
  String get unlockDone => 'Kontaktlar ochildi';

  @override
  String get unlockAlready => 'Allaqachon ochilgan — hech narsa yechilmadi';

  @override
  String unlockUnlockedOn(String date) {
    return '$date da ochilgan';
  }

  @override
  String get unlockTopUpNeeded => 'Ochish uchun to\'ldiring';

  @override
  String get candidateExposureUnlockRequired =>
      'Nomzod bilan hozir bog\'lanish uchun kontaktlarni oching. Agar u sizning vakansiyangizga ariza yuborsa yoki taklifni qabul qilsa, ular bepul ham ochiladi.';

  @override
  String get contactLockedTitle => 'Himoyalangan ma\'lumotlar';

  @override
  String get contactUnlockedTitle => 'Aloqa ma\'lumotlari';

  @override
  String get contactPhone => 'Telefon raqami';

  @override
  String get contactEmail => 'E-pochta';

  @override
  String get contactCv => 'Rezyume fayli';

  @override
  String get contactCvLocked => 'PDF · qulflangan';

  @override
  String contactLockedExplainer(String coins) {
    return '$coins bitta yangi nomzodning kontakti, rezyumesi va yozishmasini ochadi. Bir marta ochilgan nomzod uchun qayta to\'lov olinmaydi.';
  }

  @override
  String get unlockGoToVerification => 'Tasdiqlashga o\'tish';

  @override
  String unlockChargedDetail(String coins, String balance) {
    return '$coins yechildi · balans $balance';
  }

  @override
  String get unlockInsufficient => 'Coin yetarli emas';

  @override
  String walletValueAndPrice(int value, int price) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return '≈ $valueString so\'m · 1 Coin = $priceString so\'m';
  }

  @override
  String walletCoinRule(String coins) {
    return '$coins bitta yangi nomzod kontaktini ochadi. Nomzodlarni qidirish va profilni ko\'rish bepul.';
  }

  @override
  String get walletHistoryTitle => 'Amallar tarixi';

  @override
  String get walletHistoryAll => 'Barchasi';

  @override
  String get walletHistoryIncoming => 'To\'ldirish';

  @override
  String get walletHistoryOutgoing => 'Sarflangan';

  @override
  String get walletHistoryNoMatch =>
      'Bu turdagi amal hozircha yo\'q. Hamyonda yozilgan hammasini ko\'rish uchun filtrni olib tashlang.';

  @override
  String get walletDetailTitle => 'Amal tafsiloti';

  @override
  String get walletDetailSection => 'Tafsilot';

  @override
  String get walletDetailReason => 'Sabab';

  @override
  String get walletDetailWhen => 'Sana va vaqt';

  @override
  String get walletDetailAmountUzs => 'To\'langan summa';

  @override
  String get walletDetailEffect => 'Balansga ta\'siri';

  @override
  String get walletDetailBalanceAfter => 'Keyingi balans';

  @override
  String get walletDetailReference => 'Ma\'lumot raqami';

  @override
  String get walletDetailSupportTitle => 'Bu yozuvda nimadir noto\'g\'rimi?';

  @override
  String get walletDetailSupport =>
      'Qo\'llab-quvvatlash xizmatiga murojaat qilib, yuqoridagi ma\'lumot raqamini ko\'rsating. Bu tarixdagi hech bir yozuvni o\'zgartirish yoki o\'chirish mumkin emas, shuning uchun siz ko\'rgan yozuvni ular ham xuddi shunday ko\'radi.';

  @override
  String get walletCorrectionExplained =>
      'Bu yozuv oldingisini tuzatadi. Asl yozuv tarixda qoladi — tuzatishlar qo\'shiladi, ustidan yozilmaydi.';

  @override
  String get navInvitations => 'Takliflar';

  @override
  String get invitationSent => 'Yuborilgan';

  @override
  String get invitationDetailsRequested => 'Batafsil so\'ralgan';

  @override
  String get invitationAccepted => 'Qabul qilingan';

  @override
  String get invitationDeclined => 'Rad etilgan';

  @override
  String get invitationAccept => 'Qabul qilish';

  @override
  String get invitationDecline => 'Rad etish';

  @override
  String get invitationRequestDetails => 'Savol berish';

  @override
  String get invitationsInboxEmpty =>
      'Sizni vakansiyaga taklif qilgan ish beruvchilar shu yerda ko\'rinadi.';

  @override
  String get invitationGeneral => 'Umumiy taklif';

  @override
  String get invitationOpenVacancy => 'Vakansiyani ochish';

  @override
  String get invitationVacancyLoading => 'Vakansiya yuklanmoqda…';

  @override
  String get invitationVacancyUnavailable => 'Vakansiyani yuklab bo\'lmadi.';

  @override
  String get invitationVacancyUntitled => 'Vakansiya';

  @override
  String get invitationYourReply => 'Sizning javobingiz';

  @override
  String invitationPayRange(int from, int to) {
    final intl.NumberFormat fromNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String toString = toNumberFormat.format(to);

    return '$fromString – $toString so\'m';
  }

  @override
  String invitationPayFrom(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString so\'mdan';
  }

  @override
  String invitationPayUpTo(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString so\'mgacha';
  }

  @override
  String get invitationAcceptTitle => 'Bu taklif qabul qilinsinmi?';

  @override
  String get invitationAcceptDiscloses =>
      'Qabul qilsangiz, telefon raqamingiz, e-pochtangiz va rezyumeingiz shu ish beruvchiga ko\'rinadi. Buni ortga qaytarib bo\'lmaydi.';

  @override
  String get invitationDeclineTitle => 'Bu taklif rad etilsinmi?';

  @override
  String get invitationDeclineFinal =>
      'Aloqa ma\'lumotlaringiz yopiq qoladi. Rad etishni ortga qaytarib bo\'lmaydi, lekin ish beruvchi keyinroq yana taklif qilishi mumkin.';

  @override
  String get invitationRequestDetailsTitle => 'Ish beruvchiga savol berish';

  @override
  String get invitationRequestDetailsBody =>
      'Keyin ham qabul qilish yoki rad etish mumkin. Qabul qilmaguningizcha aloqa ma\'lumotlaringiz yopiq qoladi.';

  @override
  String get invitationQuestionLabel => 'Savolingiz';

  @override
  String get invitationQuestionHint =>
      'Masalan: ish aynan qayerda va qachon boshlanadi?';

  @override
  String get invitationNoteLabel => 'Xabar (majburiy emas)';

  @override
  String get invitationNoteHint =>
      'Ish beruvchi bilishi kerak deb hisoblagan narsangiz.';

  @override
  String get invitationAlreadyAnswered =>
      'Bu taklifga allaqachon javob berilgan';

  @override
  String get commonChoose => 'Tanlash';

  @override
  String get invitationSendTitle => 'Taklif yuborish';

  @override
  String get invitationSend => 'Yuborish';

  @override
  String get invitationSendFree =>
      'Yuborish bepul. Aloqa ma\'lumotlari faqat nomzod qabul qilsa ochiladi.';

  @override
  String get invitationToVacancy => 'Vakansiyaga';

  @override
  String get invitationVacancyLabel => 'Vakansiyani tanlang';

  @override
  String get invitationNoOpenVacancyTitle => 'Ochiq vakansiya yo\'q';

  @override
  String get invitationNoOpenVacancyBody =>
      'Taklif faqat faol vakansiyaga bog\'lanishi mumkin. Umumiy ish taklifini hozir ham yuborishingiz mumkin.';

  @override
  String get invitationOccupation => 'Kasb';

  @override
  String get invitationRegion => 'Viloyat';

  @override
  String get invitationDistrict => 'Tuman';

  @override
  String get invitationNegotiable => 'To\'lov kelishiladi';

  @override
  String get invitationSalaryFrom => 'To\'lov (dan)';

  @override
  String get invitationSalaryTo => 'To\'lov (gacha)';

  @override
  String get invitationSalaryPeriod => 'Davr';

  @override
  String get invitationSchedule => 'Ish vaqti';

  @override
  String get invitationScheduleHint => 'Masalan: haftada olti kun, ertalab';

  @override
  String get invitationMessageLabel => 'Xabar (majburiy emas)';

  @override
  String get invitationMessageHint =>
      'Nomzod bilishi kerak deb hisoblagan narsangiz';

  @override
  String invitationQuotaRemaining(int remaining, int limit) {
    return 'Bugun $limit taklifdan $remaining tasi qoldi';
  }

  @override
  String invitationQuotaResets(String at) {
    return '$at da yangilanadi';
  }

  @override
  String get invitationQuotaSpentTitle => 'Bugungi takliflar tugadi';

  @override
  String get invitationAlreadySentTitle => 'Allaqachon taklif qilingan';

  @override
  String get invitationSentConfirm => 'Taklif yuborildi';

  @override
  String get invitationsSentTitle => 'Yuborilgan takliflar';

  @override
  String get invitationsSentEmpty =>
      'Siz taklif qilgan nomzodlar shu yerda ko\'rinadi.';

  @override
  String get invitationsSentNoMatch =>
      'Bu holatda taklif yo\'q. Yuborilganlarning hammasini ko\'rish uchun filtrni tozalang.';

  @override
  String get invitationsSentForVacancy => 'Faqat bu vakansiya';

  @override
  String get invitationFilterAll => 'Hammasi';

  @override
  String get invitationYourMessage => 'Siz yozgan xabar';

  @override
  String get invitationCandidateReply => 'Nomzodning javobi';

  @override
  String get invitationContactOpenTitle => 'Aloqa ma\'lumotlari ochiq';

  @override
  String get invitationContactOpenBody =>
      'Nomzod taklifni qabul qildi — telefon, e-pochta va rezyume uning profilida. Buning uchun to\'lov kerak emas.';

  @override
  String get invitationOpenCandidate => 'Nomzodni ko\'rish';

  @override
  String invitationCounts(int invited, int accepted) {
    return '$invited ta taklif yuborilgan, $accepted tasi qabul qilingan';
  }

  @override
  String get fileNoViewer =>
      'Bu telefonda bu faylni ocha oladigan ilova yo\'q.';

  @override
  String get dashboardActiveVacancies => 'Faol vakansiya';

  @override
  String get dashboardOpenPositions => 'Ochiq o\'rin';

  @override
  String get dashboardNewApplications => 'Yangi ariza';

  @override
  String get dashboardAttention => 'Sizning e\'tiboringiz kerak';

  @override
  String get dashboardAttentionClear => 'Sizdan kutilayotgan ish yo\'q.';

  @override
  String get dashboardVerificationTitle => 'Tasdiqlash tugallanmagan';

  @override
  String get dashboardVacancyRejected => 'O\'zgartirish talab qilinadi';

  @override
  String dashboardUnreviewed(int count) {
    return '$count ta ariza ko\'rib chiqilmagan';
  }

  @override
  String dashboardSavedCandidates(int count) {
    return '$count ta saqlangan nomzod';
  }

  @override
  String get dashboardHiring => 'Ishga qabul jarayoni';

  @override
  String dashboardHiredOf(int hired, int openings) {
    return '$openings dan $hired';
  }

  @override
  String dashboardMeterHired(int count) {
    return 'Ishga olindi $count';
  }

  @override
  String dashboardMeterInvited(int count) {
    return 'Taklif yuborildi $count';
  }

  @override
  String dashboardMeterRemaining(int count) {
    return 'Qolgan $count';
  }

  @override
  String get dashboardWallet => 'Hamyon';

  @override
  String get accountTitle => 'Hisob va xavfsizlik';

  @override
  String get accountDevices => 'Kirgan qurilmalar';

  @override
  String get accountDevicesBody =>
      'Tanimagan qurilmani ko\'rsangiz, uning seansini tugating.';

  @override
  String get accountDeviceUnknown => 'Nomsiz qurilma';

  @override
  String accountLastUsed(String at) {
    return 'Oxirgi foydalanish: $at';
  }

  @override
  String get accountThisDevice => 'Bu qurilma';

  @override
  String get accountRevoke => 'Seansni tugatish';

  @override
  String get accountRevokeTitle => 'Bu seansni tugatilsinmi?';

  @override
  String get accountRevokeBody =>
      'O\'sha qurilma qaytadan kirishi kerak bo\'ladi.';

  @override
  String get accountRevokeCurrentTitle => 'Bu qurilmadan chiqilsinmi?';

  @override
  String get accountRevokeCurrentBody =>
      'Bu — siz foydalanayotgan qurilma. Hozir hisobdan chiqarilasiz.';

  @override
  String get accountRevokeAll => 'Barcha seanslarni tugatish';

  @override
  String get accountRevokeAllTitle => 'Barcha seanslar tugatilsinmi?';

  @override
  String get accountRevokeAllBody =>
      'Barcha qurilmalar, shu qurilma ham, hisobdan chiqariladi.';

  @override
  String get accountDelete => 'Hisobni o\'chirish';

  @override
  String get accountDeleteBody =>
      'Profilingiz, arizalaringiz va xabarlaringiz o\'chiriladi. Bu qaytarib bo\'lmaydi.';

  @override
  String get accountDeleteAction => 'O\'chirishni so\'rash';

  @override
  String get accountDeleteConfirmTitle => 'Hisobni o\'chirish so\'ralsinmi?';

  @override
  String get accountDeleteConfirmBody =>
      'Hisobingizni o\'chirishni boshlaymiz. Buni ilovadan qaytarib bo\'lmaydi.';

  @override
  String get accountDeleteRequestedTitle => 'O\'chirish so\'raldi';

  @override
  String get accountDeleteRequestedBody =>
      'So\'rovingiz qayd etildi. Keyin nima bo\'lishini qo\'llab-quvvatlash xizmati aytadi.';

  @override
  String get filtersRegion => 'Viloyat yoki tuman';

  @override
  String get filtersEmploymentType => 'Bandlik turi';

  @override
  String get filtersWorkFormat => 'Ish formati';

  @override
  String get filtersShift => 'Smena';

  @override
  String get filtersSalaryFrom => 'Maosh, dan';

  @override
  String get filtersSalaryNegotiableNote =>
      'Maoshi kelishilgan vakansiyalar ham ko\'rsatiladi.';

  @override
  String get filtersPublishedFrom => 'Chop etilgan, dan';

  @override
  String get filtersUnavailableTitle => 'Uchta filtr hozircha mavjud emas';

  @override
  String get filtersUnavailableBody =>
      'Tajriba, til va maoshning yuqori chegarasi bo\'yicha hozircha filtrlash mumkin emas. Qolgani ishlaydi.';

  @override
  String feedFilteredNote(int count) {
    return '$count filtr qo\'llangan';
  }

  @override
  String get feedFilteredEmpty =>
      'Bu filtrlarga mos vakansiya yo\'q. Ularni kengaytirib ko\'ring.';

  @override
  String get feedSavedUnfiltered => 'Saqlangan vakansiyalar filtrlanmaydi.';

  @override
  String get notesEmpty => 'Hozircha izoh yo\'q.';

  @override
  String get notesNewLabel => 'Yangi izoh';

  @override
  String get notesNewHint =>
      '8m so\'radi, 6.5 ga rozi bo\'lishi mumkin — payshanba kuni qo\'ng\'iroq';

  @override
  String get applicantsNoneAtStage =>
      'Bu bosqichda hech kim yo\'q. Hamma arizachini ko\'rish uchun filtrni tozalang.';

  @override
  String get shortlistTitle => 'Short-list';

  @override
  String get shortlistEmpty => 'Short-listda hozircha hech kim yo\'q';

  @override
  String get roleSelectionTitle => 'JobBridge\'dan qanday foydalanasiz?';

  @override
  String get roleSelectionSubtitle =>
      'Bittasini yoki ikkalasini tanlang — ikkinchisini keyin ham, ikkinchi akkaunt ochmasdan qo\'shishingiz mumkin.';

  @override
  String get roleCandidateDescription =>
      'Ish beruvchilar topadigan profil yarating, vakansiyalarga ariza yuboring va taklifnomalarga javob bering.';

  @override
  String get roleEmployerDescription =>
      'Vakansiya joylang, nomzodlarni qidiring va gaplashmoqchi bo\'lganlaringizni taklif qiling.';

  @override
  String get roleSelectionBoth =>
      'Ikkalasi tanlanganda bitta akkaunt ikkita alohida makonni saqlaydi: o\'z profilingiz va kompaniyangiz profili — almashtirish profilingizda.';

  @override
  String get chatListEmpty =>
      'Suhbat ish bo\'yicha aloqa paydo bo\'lgach ochiladi — ariza yoki qabul qilingan taklif.';

  @override
  String get chatParticipantUnknown => 'Ishtirokchi';

  @override
  String chatUnreadCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String chatUnreadSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta o\'qilmagan xabar',
    );
    return '$_temp0';
  }

  @override
  String get chatNoMessages => 'Hozircha xabar yo\'q';

  @override
  String get chatAttachment => 'Ilova';

  @override
  String get chatReadOnly => 'Faqat o\'qish';

  @override
  String get chatBlocked => 'Bloklangan';

  @override
  String get chatBlockedByYou => 'Siz bloklagansiz';

  @override
  String get chatReadOnlyTitle => 'Bu suhbat tarixga aylandi';

  @override
  String get chatReadOnlyBody =>
      'U boshlangan ariza yoki taklif tugadi, shuning uchun yangi xabar yuborilmaydi. Mavjud xabarlar o\'qish uchun qoladi.';

  @override
  String get chatBlockedTitle => 'Bloklangan';

  @override
  String get chatBlockedBody =>
      'Suhbatni ikkinchi tomon blokladi. Blok turgan vaqtda hech kim xabar yubora olmaydi, xabarlar esa o\'qish uchun qoladi.';

  @override
  String get chatBlockedByYouTitle => 'Siz bu suhbatni bloklagansiz';

  @override
  String get chatBlockedByYouBody =>
      'Blok turgan vaqtda ikki tomon ham xabar yubora olmaydi — siz ham. Yana yozish uchun ekran yuqorisidagi blokni olib tashlang.';

  @override
  String get chatUnblock => 'Blokni olib tashlash';

  @override
  String get chatUnblocked => 'Blok olib tashlandi. Yana yozishingiz mumkin.';

  @override
  String get chatBlockAction => 'Bloklash';

  @override
  String get chatBlockTitle => 'Bu suhbatni bloklaysizmi?';

  @override
  String get chatBlockBody =>
      'U ikkingiz uchun ham faqat o\'qish holatiga o\'tadi — siz ham yubora olmaysiz. Xabarlar o\'qish uchun qoladi va moderator ularni ko\'rib chiqishi mumkin.';

  @override
  String get chatBlockReasonLabel => 'Sabab (majburiy emas)';

  @override
  String get chatBlockReasonHint => 'Buni ko\'rib chiqadigan moderator uchun';

  @override
  String get chatReportTitle => 'Bu xabar ustidan shikoyat qilish';

  @override
  String get chatReportBody =>
      'Shikoyatni moderator o\'qib, qaror qabul qiladi. Suhbatni bloklash — alohida amal, ikkalasini ham qilishingiz mumkin.';

  @override
  String get chatReportReasonLabel => 'Nimasi noto\'g\'ri';

  @override
  String get chatReportReasonHint => 'Ish uchun pul to\'lashimni so\'radi';

  @override
  String get chatReportSubmit => 'Shikoyatni yuborish';

  @override
  String get chatReportDone => 'Shikoyat yuborildi. Moderator ko\'rib chiqadi.';

  @override
  String get chatComposerLabel => 'Xabar';

  @override
  String get chatComposerHint => 'Xabar yozing';

  @override
  String get chatSend => 'Yuborish';

  @override
  String get chatSendRefusedTitle => 'Yuborilmadi';

  @override
  String get chatSent => 'Yuborildi';

  @override
  String get chatRead => 'O\'qilgan';

  @override
  String get chatEarlier => 'Oldingi xabarlar';

  @override
  String get chatThreadEmpty => 'Hozircha xabar yo\'q. Birinchisini yozing.';

  @override
  String get chatThreadEmptyClosed =>
      'Bu suhbat yopilishidan oldin hech qanday xabar yuborilmagan.';

  @override
  String get chatOpenAction => 'Xabar yuborish';

  @override
  String get interviewTitle => 'Suhbat';

  @override
  String get interviewStatusScheduled => 'Belgilangan';

  @override
  String get interviewStatusConfirmed => 'Tasdiqlangan';

  @override
  String get interviewStatusRescheduleRequested => 'Boshqa vaqt so\'raldi';

  @override
  String get interviewStatusCancelled => 'Bekor qilingan';

  @override
  String get interviewTypePhone => 'Telefon orqali';

  @override
  String get interviewTypeInPerson => 'Yuzma-yuz';

  @override
  String get interviewTypeExternalLink => 'Video havola';

  @override
  String get interviewPhoneNote =>
      'Ish beruvchi profilingizdagi raqamga qo\'ng\'iroq qiladi.';

  @override
  String get interviewWhere => 'Manzil';

  @override
  String get interviewLink => 'Havola';

  @override
  String get interviewInstructions => 'Ish beruvchidan';

  @override
  String get interviewYourReply => 'Sizning javobingiz';

  @override
  String get interviewPassed => 'Bu vaqt allaqachon o\'tib ketgan.';

  @override
  String get interviewCancelledNotice =>
      'Bu suhbatni ish beruvchi bekor qildi.';

  @override
  String get interviewConfirm => 'Tasdiqlash';

  @override
  String get interviewRequestAnother => 'Boshqa vaqt so\'rash';

  @override
  String get interviewConfirmTitle => 'Bu vaqtni tasdiqlaysizmi?';

  @override
  String get interviewConfirmBody =>
      'Ish beruvchi vaqt sizga qulay ekanini ko\'radi. Keyinchalik biror narsa o\'zgarsa, boshqa vaqt so\'rashingiz mumkin.';

  @override
  String get interviewRescheduleTitle => 'Boshqa vaqt so\'rash';

  @override
  String get interviewRescheduleBody =>
      'Ish beruvchi yangi vaqt belgilamaguncha suhbat kuchda qoladi va u quyida yozganingizni ko\'radi.';

  @override
  String get interviewNoteLabel => 'Qaysi vaqtlar sizga qulay';

  @override
  String get interviewNoteHint =>
      'Shu hafta tushdan keyin yoki juma kuni ertalab';

  @override
  String get interviewReplyNoteLabel => 'Izoh (majburiy emas)';

  @override
  String get interviewReplyNoteHint => 'O\'n daqiqa oldin yetib boraman';

  @override
  String get interviewNotAllowed => 'Bu suhbat holati o\'zgargan';

  @override
  String get interviewSchedule => 'Suhbat belgilash';

  @override
  String get interviewScheduleTitle => 'Suhbat belgilash';

  @override
  String get interviewScheduleSave => 'Nomzodga yuborish';

  @override
  String get interviewRescheduleFormTitle => 'Suhbat vaqtini o\'zgartirish';

  @override
  String get interviewRescheduleSave => 'Yangi vaqtni saqlash';

  @override
  String get interviewRescheduleResets =>
      'Kichik o\'zgarish bo\'lsa ham, nomzoddan qayta tasdiqlash so\'raladi — boshqa vaqtga ko\'chirilgan suhbat tasdiqlanmagan hisoblanadi.';

  @override
  String get interviewTypeLabel => 'Suhbat turi';

  @override
  String get interviewWhereHint =>
      'Amir Temur 12, 3-qavat — qabulxonada Dilnozani so\'rang';

  @override
  String get interviewLinkHint => 'https://meet.example.com/abc-defg-hij';

  @override
  String get interviewDateLabel => 'Sana';

  @override
  String get interviewTimeLabel => 'Vaqt';

  @override
  String get interviewTimeHint => '10:00';

  @override
  String get interviewInstructionsLabel =>
      'Nima olib kelishi yoki tayyorlashi kerak';

  @override
  String get interviewInstructionsHint =>
      'Diplomingizni va mehnat daftaringizni olib keling';

  @override
  String get interviewReschedule => 'Ko\'chirish';

  @override
  String get interviewCancelAction => 'Bekor qilish';

  @override
  String get interviewCancelTitle => 'Bu suhbatni bekor qilasizmi?';

  @override
  String get interviewCancelBody =>
      'Bu ikki tomon uchun ham qat\'iy — suhbatni qaytarib bo\'lmaydi, yangi vaqt esa yangi suhbat belgilashni talab qiladi. Nomzod bekor qilinganini ko\'radi.';

  @override
  String get interviewCancelReasonLabel =>
      'Sabab (majburiy emas, nomzod ko\'radi)';

  @override
  String get interviewCancelReasonHint =>
      'Lavozim to\'ldirildi — vaqtingiz uchun rahmat';

  @override
  String get interviewCandidateReply => 'Nomzod nima dedi';

  @override
  String get commonShowMore => 'Ko\'proq ko\'rsatish';

  @override
  String get commonLoadingMore => 'Yana yuklanmoqda…';

  @override
  String get adminDashboardTitle => 'Boshqaruv';

  @override
  String get adminQueuesTitle => 'Qaror kutmoqda';

  @override
  String get adminAwaitingVerification =>
      'Tasdiqlash kutayotgan ish beruvchilar';

  @override
  String get adminAwaitingModeration => 'Moderatsiya kutayotgan vakansiyalar';

  @override
  String get adminOpenComplaints => 'Ochiq shikoyatlar';

  @override
  String get adminQueuesClear => 'Sizni kutayotgan ish yo\'q.';

  @override
  String get adminSanctionsTitle => 'Cheklovdagi hisoblar';

  @override
  String get adminRestrictedUsers => 'Cheklangan';

  @override
  String get adminBlockedUsers => 'Bloklangan';

  @override
  String get adminPeriodTitle => 'Tanlangan davr uchun';

  @override
  String adminPeriodDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days kun',
    );
    return '$_temp0';
  }

  @override
  String get adminCandidates => 'Nomzodlar';

  @override
  String get adminEmployers => 'Ish beruvchilar';

  @override
  String get adminVacanciesPublished => 'E\'lon qilingan vakansiyalar';

  @override
  String get adminApplicationsSubmitted => 'Yuborilgan arizalar';

  @override
  String get adminCountTotal => 'jami';

  @override
  String get adminCountNew => 'yangi';

  @override
  String get adminVerificationTitle => 'Ish beruvchini tasdiqlash';

  @override
  String get adminVerificationFifo =>
      'Eng eskisi birinchi — yuqoridagi ariza eng uzoq kutgan.';

  @override
  String get adminVerificationEmpty => 'Kutayotgan hech kim yo\'q';

  @override
  String get adminVerificationEmptyBody =>
      'Ish beruvchilar hujjatlarini yuborgan sayin arizalar shu yerda paydo bo\'ladi.';

  @override
  String get adminEmployerCompany => 'Tashkilot';

  @override
  String get adminEmployerIndividual => 'Jismoniy shaxs';

  @override
  String get adminEmployerUnnamed => 'Nom kiritilmagan';

  @override
  String adminWaitingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days kundan beri kutmoqda',
      zero: 'Bugun yuborilgan',
    );
    return '$_temp0';
  }

  @override
  String get adminEvidenceTitle => 'Hujjatlar';

  @override
  String get adminEvidenceNone => 'Hujjat ilova qilinmagan';

  @override
  String get adminVerify => 'Tasdiqlash';

  @override
  String get adminRequestChanges => 'O\'zgartirish so\'rash';

  @override
  String get adminReject => 'Rad etish';

  @override
  String get adminVerifyTitle => 'Bu ish beruvchini tasdiqlaysizmi?';

  @override
  String get adminVerifyBody =>
      'Bu ularga vakansiya e\'lon qilish va nomzodlarni taklif qilish imkonini beradi. Hisobdagi boshqa hech narsa o\'zgarmaydi.';

  @override
  String get adminRequestChangesTitle => 'Tuzatish uchun qaytarasizmi?';

  @override
  String get adminRequestChangesBody =>
      'Profil va fayllar saqlanadi — siz quyida aytgan narsani tuzatib, qaytadan yuborishlari mumkin.';

  @override
  String get adminRejectTitle => 'Bu arizani rad etasizmi?';

  @override
  String get adminRejectBody =>
      'Ular tasdiqlanmagan holatda qoladi, e\'lon ham, taklif ham qila olmaydi. Ularga faqat sizning sababingiz yetadi — nima qilish kerakligini yozing.';

  @override
  String get adminReasonLabel => 'Sabab (ish beruvchi so\'zma-so\'z o\'qiydi)';

  @override
  String get adminReasonHint =>
      'Ro\'yxatga olish guvohnomasi o\'qilmaydi — aniqroq nusxa yuklang';

  @override
  String get adminAlreadyDecided => 'Allaqachon hal qilingan';

  @override
  String get adminDecisionRecorded => 'Qaror qayd etildi.';

  @override
  String get adminQueueTitle => 'Moderatsiya';

  @override
  String get adminQueueEmployers => 'Ish beruvchilar';

  @override
  String get adminQueueVacancies => 'Vakansiyalar';

  @override
  String get adminModerationEmpty => 'Kutayotgan vakansiya yo\'q';

  @override
  String get adminModerationEmptyBody =>
      'Ish beruvchilar e\'lon qilish uchun yuborgan sayin vakansiyalar shu yerda paydo bo\'ladi.';

  @override
  String get adminRestrictionFlag => 'Yosh yoki jins cheklovi';

  @override
  String get adminReviewTitle => 'Ko‘rib chiqish';

  @override
  String get adminVacancyGoneTitle => 'Bu vakansiya navbatdan chiqib ketgan';

  @override
  String get adminVacancyGoneBody =>
      'Kimdir uni allaqachon hal qilgan yoki ish beruvchi qaytarib olgan bo‘lishi mumkin.';

  @override
  String get adminPublish => 'E\'lon qilish';

  @override
  String get adminSendBack => 'Qaytarish';

  @override
  String get adminPublishTitle => 'Bu vakansiyani e\'lon qilasizmi?';

  @override
  String get adminPublishBody =>
      'Nomzodlar uni darhol ko\'radi. Agar yosh yoki jins cheklovi bo\'lsa, e\'lon qilish o\'sha cheklovni ham tasdiqlaydi — cheklovli vakansiya faqat shu navbat orqali e\'lon qilinishi mumkin.';

  @override
  String get adminSendBackTitle => 'Bu vakansiyani qaytarasizmi?';

  @override
  String get adminSendBackBody =>
      'Ish beruvchi uni tuzatib qayta yuborishi mumkin. Ularga faqat sizning sababingiz yetadi — nimani o\'zgartirish kerakligini aytib bering.';

  @override
  String get adminRestrictionJudge =>
      'Cheklov faqat sabab uni haqiqatan talab qilsa ruxsat etiladi. Cheklovni emas, sababni baholang.';

  @override
  String get adminRestrictionAge => 'Yosh cheklovi';

  @override
  String get adminRestrictionGender => 'Jins cheklovi';

  @override
  String get adminRestrictionReason => 'Ish beruvchi tanlagan sabab';

  @override
  String get adminRestrictionNote => 'O\'z so\'zlari bilan';

  @override
  String get adminPreviousReason => 'Avval shu sabab bilan qaytarilgan';

  @override
  String get adminVacancyWhere => 'Ish joyi';

  @override
  String get adminVacancyEmployer => 'Ish beruvchi';

  @override
  String get adminVacancyEmployerPhone => 'Kirish raqami';

  @override
  String get adminComplaintsTitle => 'Shikoyatlar';

  @override
  String get adminComplaintsEmpty => 'Shikoyat yo\'q';

  @override
  String get adminComplaintsEmptyBody =>
      'Hech bir shikoyat qarorni kutmayapti.';

  @override
  String get adminComplaintKindVacancy => 'Vakansiya';

  @override
  String get adminComplaintKindUser => 'Foydalanuvchi';

  @override
  String get adminComplaintKindProfile => 'Profil';

  @override
  String get adminComplaintKindMessage => 'Xabar';

  @override
  String get adminComplaintKindUnknown => 'Noma\'lum tur';

  @override
  String get adminComplaintKindUnknownBody =>
      'Ilovaning bu versiyasi bu obyekt turini ko\'rsata olmaydi. Ko\'rib chiqish uchun ilovani yangilang.';

  @override
  String get adminComplaintTitle => 'Shikoyat';

  @override
  String get adminComplaintGoneTitle => 'Bu shikoyat topilmadi';

  @override
  String get adminComplaintGoneBody =>
      'Kimdir uni ko\'rib chiqqan yoki u hech qachon bo\'lmagan. Hal qiladigan narsa qolmadi.';

  @override
  String get adminComplaintReported => 'Nima haqida xabar qilingan';

  @override
  String get adminComplaintTarget => 'Shikoyat qilingan obyekt';

  @override
  String get adminComplaintTargetGone =>
      'Shikoyat qilingan obyekt o\'chirilgan';

  @override
  String get adminComplaintTargetGoneBody =>
      'U shikoyat berilgandan keyin o\'chirilgan. Shikoyat saqlanadi, shuning uchun natijani hali ham qayd etish mumkin.';

  @override
  String get adminComplaintEmployerAccount => 'Ish beruvchi hisobi';

  @override
  String get adminComplaintRemedy => 'Avval chora ko\'ring';

  @override
  String get adminComplaintRemedyBody =>
      'Shikoyatni qabul qilingan deb qayd etish hech narsani amalga oshirmaydi. Avval shu yerda chora ko\'ring.';

  @override
  String get adminComplaintNoRemedy =>
      'Bu yerda ko\'radigan chora yo\'q. Natijani pastda qayd eting.';

  @override
  String get adminComplaintOutcome => 'Natijani qayd eting';

  @override
  String get adminComplaintOutcomeBody =>
      'Shikoyatni ko\'rib chiqishni boshqa hech narsa qayd etmaydi, shuning uchun yozganingiz — uning yagona bayoni.';

  @override
  String get adminComplaintUphold => 'Qabul qilish';

  @override
  String get adminComplaintDismiss => 'Rad etish';

  @override
  String get adminComplaintUpholdTitle => 'Bu shikoyat qabul qilinsinmi?';

  @override
  String get adminComplaintUpholdBody =>
      'Shikoyat qabul qilingan holda yopiladi. Chora kerak bo\'lsa, buni qayd etishdan oldin ko\'ring.';

  @override
  String get adminComplaintDismissTitle => 'Bu shikoyat rad etilsinmi?';

  @override
  String get adminComplaintDismissBody =>
      'Shikoyat hech qanday chorasiz yopiladi. Sababini yozing — bu qarorning yagona bayoni.';

  @override
  String get adminResolutionLabel => 'Qaror (audit jurnalida saqlanadi)';

  @override
  String get adminResolutionHint =>
      'Vakansiya to\'xtatildi va ish beruvchidan tavsifdan telefon raqamini olib tashlash so\'raldi';

  @override
  String get adminPauseVacancy => 'Vakansiyani to\'xtatish';

  @override
  String get adminCloseVacancy => 'Vakansiyani olib tashlash';

  @override
  String get adminPauseVacancyTitle => 'Vakansiya to\'xtatilsinmi?';

  @override
  String get adminPauseVacancyBody =>
      'Vakansiya darhol lentadan chiqadi va ish beruvchi tuzatgandan keyin qayta tiklanishi mumkin.';

  @override
  String get adminCloseVacancyTitle => 'Vakansiya olib tashlansinmi?';

  @override
  String get adminCloseVacancyBody =>
      'Vakansiya lentadan butunlay chiqadi. Olib tashlangan vakansiya qayta ochilmaydi — ish beruvchi tuzatishi mumkin bo\'lsa, uni to\'xtating.';

  @override
  String get adminWarnUser => 'Ogohlantirish yuborish';

  @override
  String get adminWarnUserTitle => 'Ogohlantirish yuborilsinmi?';

  @override
  String get adminWarnUserBody =>
      'Hisobi o\'zgarmaydi. Ogohlantirish va uning sababi qayd etiladi, foydalanuvchi esa xabardor qilinadi.';

  @override
  String get adminWarnReasonLabel =>
      'Ogohlantirish (foydalanuvchi so\'zma-so\'z o\'qiydi)';

  @override
  String get adminWarnReasonHint =>
      'Ommaviy vakansiya tavsifida aloqa ma\'lumotlarini ko\'rsatish mumkin emas — iltimos, olib tashlang';

  @override
  String get adminAccountStatusActive => 'Faol';

  @override
  String get adminAccountStatusRestricted => 'Cheklangan';

  @override
  String get adminAccountStatusBlocked => 'Bloklangan';

  @override
  String get adminVacancyEmployerContactPhone => 'Aloqa raqami';

  @override
  String get adminUsersTitle => 'Foydalanuvchilar';

  @override
  String get adminUserSearchPhone => 'Telefon raqami';

  @override
  String get adminUserSearchPhoneHint =>
      'Oxirgi raqamlarining o\'zi ham yetadi';

  @override
  String get adminUserSearchPhoneTooShort => 'Kamida 3 ta raqam.';

  @override
  String get adminUserSearchName => 'Ism yoki nom';

  @override
  String get adminUserSearchNameHint =>
      'Shaxs, kompaniya yoki uning yuridik nomi';

  @override
  String get adminUserSearchNameTooShort => 'Kamida 2 ta belgi.';

  @override
  String get adminUserSearchMore => 'Ko\'proq filtr';

  @override
  String get adminUserSearchFewer => 'Kamroq filtr';

  @override
  String get adminUserSearchRole => 'Quyidagi roli bor';

  @override
  String get adminUserSearchStatus => 'Hisob holati';

  @override
  String get adminUserSearchRegisteredFrom => 'Ro\'yxatdan o\'tgan (dan)';

  @override
  String get adminUserSearchRegisteredTo => 'Ro\'yxatdan o\'tgan (gacha)';

  @override
  String get adminUserSearchDatesReversed => 'Bu sanalar mos kela olmaydi';

  @override
  String get adminUserSearchDatesReversedBody =>
      'Birinchi sana ikkinchisidan keyin turibdi, shuning uchun ular orasiga hech qanday hisob tushmaydi.';

  @override
  String get adminUserSearchRun => 'Qidirish';

  @override
  String get adminUserSearchClear => 'Filtrlarni tozalash';

  @override
  String get adminUserSearchIdle => 'Hisobni toping';

  @override
  String get adminUserSearchIdleBody =>
      'Telefon raqamining oxirgi raqamlari bo\'yicha yoki hisob tanilgan istalgan nom bo\'yicha qidiring — shaxs ismi, kompaniyaning ochiq nomi yoki yuridik nomi. Siz so\'ramaguningizcha hech narsa o\'qilmaydi.';

  @override
  String get adminUserSearchEmpty => 'Mos keladigan hisob topilmadi';

  @override
  String get adminUserSearchEmptyBody =>
      'Bu filtrlarga hech narsa mos kelmadi. Telefon raqami ichidagi istalgan qism bo\'yicha topiladi, shuning uchun oxirgi bir necha raqam boshqacha yozilgan to\'liq raqam topa olmagan hisobni topadi.';

  @override
  String get adminUserSearchOrder =>
      'Eng yangi ro\'yxatdan o\'tganlar birinchi. Eskiroq hisob ro\'yxatning pastida turadi, yo\'q emas — sahifalab izlashdan ko\'ra qidiruvni toraytiring.';

  @override
  String get adminUserNoName => 'Hisobda ism yo\'q';

  @override
  String get adminUserNoPhone => 'Telefon raqami yo\'q';

  @override
  String adminUserRegistered(String date) {
    return 'Ro\'yxatdan o\'tgan: $date';
  }

  @override
  String adminUserLastLogin(String date) {
    return 'Oxirgi kirish: $date';
  }

  @override
  String get adminUserNeverSignedIn => 'Hech qachon kirmagan';

  @override
  String get adminAccountStatusDeletionRequested => 'O\'chirish so\'ralgan';

  @override
  String get adminUserTitle => 'Hisob';

  @override
  String get adminUserGoneTitle => 'Bu hisob endi yo\'q';

  @override
  String get adminUserGoneBody =>
      'Topilmadi. Uni topgan qidiruvdan keyin o\'chirilgan bo\'lishi mumkin.';

  @override
  String get adminUserActions => 'Hisob bo\'yicha chora ko\'rish';

  @override
  String get adminUserNoActionsTitle =>
      'Bu yerdan hech qanday chora ko\'rib bo\'lmaydi';

  @override
  String get adminUserNoActionsBody =>
      'Bu hisob o\'chirilishini so\'ragan. So\'rov o\'z jarayoni orqali hal qilinadi, bu yerda cheklash yoki bloklash esa so\'rovni bekor qilib yuboradi.';

  @override
  String get adminUserRestrict => 'Cheklash';

  @override
  String get adminUserBlock => 'Bloklash';

  @override
  String get adminUserUnblock => 'Blokdan chiqarish';

  @override
  String get adminUserLiftRestriction => 'Cheklovni olib tashlash';

  @override
  String get adminUserRestrictTitle => 'Bu hisob cheklansinmi?';

  @override
  String get adminUserRestrictBody =>
      'Hisob ularda qoladi va kira oladilar, lekin cheklov olib tashlanmaguncha biror narsani o\'zgartiradigan har qanday amal rad etiladi. Sizning sababingiz ularga ko\'rsatiladi.';

  @override
  String get adminUserBlockTitle => 'Bu hisob bloklansinmi?';

  @override
  String get adminUserBlockBody =>
      'Sababni tushuntiruvchi xabardan boshqa hamma narsaga kirish yopiladi. Buni faqat administrator qaytara oladi.';

  @override
  String get adminUserUnblockTitle => 'Hisob blokdan chiqarilsinmi?';

  @override
  String get adminUserLiftRestrictionTitle => 'Cheklov olib tashlansinmi?';

  @override
  String get adminUserLiftBody =>
      'Bundan buyon ularga hamma narsa yana ochiq bo\'ladi.';

  @override
  String get adminUserRestrictUntilLabel => 'Tugash sanasi';

  @override
  String get adminUserRestrictUntilCaption =>
      'Cheklov shu kunning boshida, Toshkent vaqti bilan olib tashlanadi. Bo\'sh qoldirsangiz, administrator olib tashlagunicha qoladi.';

  @override
  String get adminUserStatusReasonLabel =>
      'Sabab (ular so\'zma-so\'z o\'qiydi)';

  @override
  String get adminUserStatusReasonHint =>
      'Nomzodlardan pul so\'raydigan vakansiyalarni qayta-qayta joylashtirgani uchun';

  @override
  String adminUserRestrictedUntil(String date) {
    return '$date gacha cheklangan';
  }

  @override
  String get adminUserRestrictedIndefinitely =>
      'Administrator olib tashlagunicha cheklangan';

  @override
  String get adminUserHistory => 'Hisob tarixi';

  @override
  String get adminUserHistoryEmpty =>
      'Bu hisobning holati hech qachon o\'zgarmagan.';

  @override
  String adminUserHistoryBy(String actor) {
    return '$actor tomonidan';
  }

  @override
  String get adminUserHistoryAutomatic =>
      'Muddat o\'tgach, platforma tomonidan';

  @override
  String get adminUserComplaints => 'Bu hisob ustidan shikoyatlar';

  @override
  String get adminUserComplaintsEmpty =>
      'Bu hisob ustidan hech kim shikoyat qilmagan.';

  @override
  String get adminUserComplaintOpen => 'Ochiq';

  @override
  String get adminUserComplaintClosed => 'Ko\'rib chiqilgan';
}
