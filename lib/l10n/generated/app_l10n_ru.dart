// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'JobBridge';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonSignOut => 'Выйти';

  @override
  String get stateLoading => 'Загрузка…';

  @override
  String get stateEmptyTitle => 'Пока пусто';

  @override
  String get stateEmptyBody => 'На этом экране пока нечего показать.';

  @override
  String get stateErrorTitle => 'Что-то пошло не так';

  @override
  String get stateErrorBody =>
      'Не удалось выполнить запрос. Попробуйте ещё раз.';

  @override
  String get stateOfflineTitle => 'Нет подключения';

  @override
  String get stateOfflineBody => 'Проверьте соединение и попробуйте снова.';

  @override
  String get statePermissionDeniedTitle => 'Нужно разрешение';

  @override
  String get statePermissionDeniedBody =>
      'Разрешите доступ в настройках, чтобы продолжить.';

  @override
  String get sessionExpired => 'Сеанс истёк. Войдите снова.';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get roleCandidate => 'Соискатель';

  @override
  String get roleEmployer => 'Работодатель';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get navHome => 'Главная';

  @override
  String get navVacancies => 'Вакансии';

  @override
  String get navApplications => 'Заявки';

  @override
  String get navMessages => 'Сообщения';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navCandidates => 'Кандидаты';

  @override
  String get navCompany => 'Компания';

  @override
  String get navDashboard => 'Обзор';

  @override
  String get navQueue => 'Модерация';

  @override
  String get navComplaints => 'Жалобы';

  @override
  String get navUsers => 'Пользователи';

  @override
  String get navDictionaries => 'Справочники';

  @override
  String get blockedTitle => 'Аккаунт заблокирован';

  @override
  String get blockedBody =>
      'Администратор заблокировал этот аккаунт. Вы не сможете пользоваться приложением, пока блокировка не снята.';

  @override
  String get profileCompleteness => 'Заполненность профиля';

  @override
  String profileMissingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count обязательных полей',
      many: 'Осталось $count обязательных полей',
      few: 'Осталось $count обязательных поля',
      one: 'Осталось $count обязательное поле',
    );
    return '$_temp0';
  }

  @override
  String get profileSearchable => 'Виден в поиске';

  @override
  String get profileNotSearchable => 'Пока не в поиске';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get profileSectionElsewhere =>
      'У этого раздела свой редактор, он появится позже.';

  @override
  String get profileFieldNotEditableYet =>
      'Это поле пока нельзя изменить в приложении.';

  @override
  String get profileChooseParentFirst => 'Сначала заполните поле выше';

  @override
  String get profileDateHint => 'ГГГГ-ММ-ДД';

  @override
  String get profileSalaryFrom => 'От';

  @override
  String get profileSalaryTo => 'До';

  @override
  String get profileSalaryNegotiable => 'По договорённости';

  @override
  String profileLastUpdated(String date) {
    return 'Обновлено $date';
  }

  @override
  String get profileFixField => 'Заполнить';

  @override
  String get profileVisibilityTitle => 'Кто может вас найти';

  @override
  String get profileVisibilitySearchable => 'Виден в поиске';

  @override
  String get profileVisibilitySearchableHint =>
      'Работодатели могут найти вас в поиске кандидатов.';

  @override
  String get profileVisibilityHidden => 'Скрыт из поиска';

  @override
  String get profileVisibilityHiddenHint =>
      'Вы по-прежнему можете смотреть вакансии и откликаться. Работодатели вас не найдут.';

  @override
  String get profileVisibilityAfterApply => 'Виден после отклика';

  @override
  String get profileVisibilityAfterApplyHint =>
      'Профиль увидят только работодатели, на вакансию которых вы откликнулись.';

  @override
  String get feedRecommended => 'Рекомендуемые';

  @override
  String get feedRecent => 'Новые';

  @override
  String get feedSaved => 'Сохранённые';

  @override
  String get feedEmpty => 'Пока нечего показать';

  @override
  String get vacancyVerifiedEmployer => 'Проверенный работодатель';

  @override
  String get vacancyNegotiablePay => 'Оплата договорная';

  @override
  String vacancyDeadline(String date) {
    return 'Отклик до $date';
  }

  @override
  String get vacancyApply => 'Откликнуться';

  @override
  String get vacancyApplied => 'Вы откликнулись';

  @override
  String get vacancyClosedToApplications => 'Отклики не принимаются';

  @override
  String get vacancySave => 'Сохранить';

  @override
  String get vacancySaved => 'Сохранено';

  @override
  String get vacancyReport => 'Пожаловаться';

  @override
  String get vacancyReportTitle => 'Пожаловаться на вакансию';

  @override
  String get vacancyReportHint => 'Что с ней не так?';

  @override
  String get vacancyReported => 'Спасибо. Модератор рассмотрит жалобу.';

  @override
  String get applicationsMine => 'Ваши отклики';

  @override
  String get applicationsEmpty => 'Вы ещё никуда не откликались';

  @override
  String get applicationWithdraw => 'Отозвать';

  @override
  String get applicationWithdrawTitle => 'Отозвать отклик?';

  @override
  String get stageSubmitted => 'Отправлен';

  @override
  String get stageViewed => 'Просмотрен';

  @override
  String get stageShortlisted => 'В шорт-листе';

  @override
  String get stageInterview => 'Собеседование';

  @override
  String get stageOffer => 'Оффер';

  @override
  String get stageHired => 'Принят';

  @override
  String get stageRejected => 'Не выбран';

  @override
  String get stageWithdrawn => 'Отозван';

  @override
  String get vacancyMine => 'Ваши вакансии';

  @override
  String get vacancyNew => 'Новая вакансия';

  @override
  String get vacancyNone => 'Вакансий пока нет';

  @override
  String get vacancyUntitled => 'Вакансия без названия';

  @override
  String get vacancyStatusDraft => 'Черновик';

  @override
  String get vacancyStatusModeration => 'На проверке';

  @override
  String get vacancyStatusActive => 'Опубликована';

  @override
  String get vacancyStatusPaused => 'Приостановлена';

  @override
  String get vacancyStatusClosed => 'Закрыта';

  @override
  String get vacancyStatusRejected => 'Отклонена';

  @override
  String get vacancySubmit => 'Отправить на публикацию';

  @override
  String get vacancyPause => 'Приостановить';

  @override
  String get vacancyResume => 'Возобновить';

  @override
  String get vacancyClose => 'Закрыть';

  @override
  String get vacancyCloseTitle => 'Закрыть вакансию?';

  @override
  String get vacancyCloseMessage =>
      'Закрытие необратимо. Вакансия исчезнет из поиска и останется в истории.';

  @override
  String vacancyMissingForSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось заполнить $count полей',
      many: 'Осталось заполнить $count полей',
      few: 'Осталось заполнить $count поля',
      one: 'Осталось заполнить $count поле',
    );
    return '$_temp0';
  }

  @override
  String get vacancyNotEditable => 'Эту вакансию сейчас нельзя редактировать.';

  @override
  String get vacancyOpenForApplications => 'Принимает отклики';

  @override
  String get vacancyRestrictionTitle => 'Ограничения по возрасту и полу';

  @override
  String get vacancyRestrictionWarning =>
      'Ограничения по возрасту и полу требуют обоснования и всегда проходят проверку модератора.';

  @override
  String get employerChooseType => 'Кто вы как работодатель?';

  @override
  String get employerTypeCompany => 'Компания';

  @override
  String get employerTypeCompanyHint =>
      'Зарегистрированный бизнес, нанимающий от имени компании.';

  @override
  String get employerTypeIndividual => 'Частное лицо';

  @override
  String get employerTypeIndividualHint =>
      'Нанимаете для дома или частной работы.';

  @override
  String get employerTypeFixed =>
      'Выбирается один раз и не может быть изменено.';

  @override
  String get employerDetails => 'Данные работодателя';

  @override
  String get employerLegalName => 'Юридическое название';

  @override
  String get employerPublicName => 'Название для кандидатов';

  @override
  String get employerFullName => 'Ваше полное имя';

  @override
  String get employerIndustry => 'Отрасль';

  @override
  String get employerContactPerson => 'Контактное лицо';

  @override
  String get employerContactPhone => 'Контактный телефон';

  @override
  String get employerRegion => 'Регион';

  @override
  String get employerDistrict => 'Район или город';

  @override
  String get employerAddress => 'Адрес';

  @override
  String get employerDescription => 'Описание';

  @override
  String get employerVerification => 'Верификация';

  @override
  String get employerVerificationNotSubmitted => 'Не отправлено';

  @override
  String get employerVerificationUnderReview => 'На проверке';

  @override
  String get employerVerificationVerified => 'Подтверждено';

  @override
  String get employerVerificationRejected => 'Отклонено';

  @override
  String get employerVerificationChangesRequired => 'Требуются исправления';

  @override
  String get employerSubmitVerification => 'Отправить на проверку';

  @override
  String get employerEvidence => 'Необходимые документы';

  @override
  String get employerEvidenceRequired => 'Обязательно';

  @override
  String get employerEvidenceOptional => 'Необязательно';

  @override
  String get employerCannotPublish =>
      'Заполните профиль и пройдите верификацию, чтобы публиковать вакансии и приглашать кандидатов.';

  @override
  String get employerCanPublish =>
      'Вы можете публиковать вакансии и приглашать кандидатов.';

  @override
  String get employerSaveFirst =>
      'Сохраните данные перед отправкой на проверку.';

  @override
  String get attachmentsTitle => 'Документы';

  @override
  String get attachmentUpload => 'Загрузить';

  @override
  String get attachmentReplace => 'Заменить';

  @override
  String attachmentUploading(String percent) {
    return 'Загрузка… $percent%';
  }

  @override
  String get attachmentNone => 'Ничего не загружено';

  @override
  String attachmentTooLarge(String limit) {
    return 'Файл больше $limit МБ.';
  }

  @override
  String attachmentWrongType(String types) {
    return 'Выберите файл в формате $types.';
  }

  @override
  String get attachmentDeleteTitle => 'Удалить файл?';

  @override
  String get historyDeleteTitle => 'Удалить запись?';

  @override
  String get historyDeleteMessage => 'Она будет удалена из вашего профиля.';

  @override
  String get experienceEmpty => 'Опыт работы не добавлен';

  @override
  String get experienceAdd => 'Добавить опыт';

  @override
  String get experienceEmployer => 'Работодатель';

  @override
  String get experienceRole => 'Должность';

  @override
  String get experienceOccupation => 'Профессия';

  @override
  String get experienceStarted => 'Дата начала';

  @override
  String get experienceEnded => 'Дата окончания';

  @override
  String get experienceCurrent => 'Работаю здесь сейчас';

  @override
  String get experienceResponsibilities => 'Обязанности';

  @override
  String get experiencePresent => 'По настоящее время';

  @override
  String get educationEmpty => 'Образование не добавлено';

  @override
  String get educationAdd => 'Добавить образование';

  @override
  String get educationLevel => 'Уровень образования';

  @override
  String get educationInstitution => 'Учебное заведение';

  @override
  String get educationSpecialization => 'Специальность';

  @override
  String get educationYear => 'Год окончания';

  @override
  String get leveledChangeLevel => 'Уровень';

  @override
  String get pickerChoose => 'Выбрать';

  @override
  String get pickerAdd => 'Добавить';

  @override
  String get pickerSearchHint => 'Начните вводить для поиска';

  @override
  String get pickerNoMatches => 'Ничего не найдено.';

  @override
  String get pickerNothingSelected => 'Пока ничего не выбрано';

  @override
  String get pickerUnknownValue => 'Недоступное значение';

  @override
  String get authSignInTitle => 'Вход';

  @override
  String get authPhoneLabel => 'Номер телефона';

  @override
  String get authPhoneHint => '90 123 45 67';

  @override
  String get authPhoneInvalid => 'Введите 9 цифр, например 90 123 45 67.';

  @override
  String get authSendCode => 'Получить код';

  @override
  String get authCodeTitle => 'Введите код';

  @override
  String authCodeSentTo(String phone) {
    return 'Мы отправили код на номер $phone.';
  }

  @override
  String get authCodeLabel => 'Код';

  @override
  String authCodeInvalid(int length) {
    return 'Введите код из $length цифр.';
  }

  @override
  String get authVerifyCode => 'Подтвердить';

  @override
  String get authChangePhone => 'Изменить номер';

  @override
  String get authResendCode => 'Отправить ещё раз';

  @override
  String authResendIn(int seconds) {
    return 'Отправить ещё раз через $seconds с';
  }

  @override
  String get authCodeResent => 'Новый код отправлен.';

  @override
  String get authTelegramSignIn => 'Войти через Telegram';

  @override
  String get authTermsAgree =>
      'Я принимаю Условия использования и Политику конфиденциальности';

  @override
  String get authSignInFailed =>
      'Не удалось войти через Telegram. Попробуйте ещё раз.';

  @override
  String get authSignInNoConnection =>
      'Нет связи с Telegram. Проверьте интернет и попробуйте снова.';

  @override
  String get authSignInUnavailable =>
      'Вход через Telegram недоступен в этой сборке.';

  @override
  String get vacancyApplicants => 'Отклики';

  @override
  String get vacancyApplicantsEmpty => 'Откликов пока нет';

  @override
  String applicationsHired(int hired, int required) {
    return 'Принято $hired из $required';
  }

  @override
  String applicationsHiredNoTarget(int hired) {
    return 'Принято $hired';
  }

  @override
  String get applicationMoveTo => 'Перевести в';

  @override
  String get applicationRejectReason => 'Причина (увидит кандидат)';

  @override
  String get candidatePhoneHidden => 'Телефон недоступен';

  @override
  String get candidatePhoneHiddenWhy =>
      'Настройки приватности кандидата решают, когда работодатель его видит.';

  @override
  String get candidateFilesHidden => 'Файлы недоступны';

  @override
  String candidateCompleteness(int percent) {
    return 'Профиль заполнен на $percent%';
  }

  @override
  String get notesTitle => 'Личные заметки';

  @override
  String get notesHint => 'Их видите только вы';

  @override
  String get notesAdd => 'Добавить заметку';

  @override
  String get searchCandidates => 'Поиск кандидатов';

  @override
  String get searchRun => 'Найти';

  @override
  String searchCountExact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кандидатов',
      many: '$count кандидатов',
      few: '$count кандидата',
      one: '$count кандидат',
    );
    return '$_temp0';
  }

  @override
  String searchCountCapped(int count) {
    return '$count+ кандидатов';
  }

  @override
  String get searchNoResults => 'По этим фильтрам никого нет';

  @override
  String get searchSaved => 'Сохранённые кандидаты';

  @override
  String searchMatch(int percent) {
    return 'Совпадение $percent%';
  }

  @override
  String searchExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years лет опыта',
      many: '$years лет опыта',
      few: '$years года опыта',
      one: '$years год опыта',
    );
    return '$_temp0';
  }

  @override
  String get searchShortlist => 'В шорт-лист';

  @override
  String get searchShortlisted => 'В шорт-листе';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get filtersApply => 'Применить фильтры';

  @override
  String get filtersReset => 'Сбросить';

  @override
  String get filtersEdit => 'Фильтры';

  @override
  String get filtersClearAll => 'Очистить все';

  @override
  String get filtersNone => 'Без фильтров — все доступные для поиска кандидаты';

  @override
  String get filtersBlockedTitle => 'Поиск пока невозможен';

  @override
  String get filtersOccupation => 'Профессия';

  @override
  String get filtersSkills => 'Навыки';

  @override
  String get filtersExperience => 'Опыт';

  @override
  String get filtersLanguages => 'Языки';

  @override
  String get filtersEducation => 'Образование';

  @override
  String get filtersLocation => 'Местоположение';

  @override
  String get filtersPreferences => 'Условия работы';

  @override
  String get filtersAvailability => 'Готовность приступить';

  @override
  String get filtersAttributes => 'Дополнительные требования';

  @override
  String get filtersProfile => 'Профиль';

  @override
  String get filtersRestrictions => 'Ограничения';

  @override
  String get filtersSort => 'Сортировка';

  @override
  String get filterOccupations => 'Профессии';

  @override
  String get filterPrimaryOnly => 'Только основная профессия';

  @override
  String get filterPrimaryOnlyHint =>
      'Учитывать основную профессию, а не все указанные';

  @override
  String get filterOccupationLevels => 'Профессиональный уровень';

  @override
  String get filterCurrentOccupations => 'Текущая или последняя должность';

  @override
  String get filterSkills => 'Навыки';

  @override
  String get filterMatchMode => 'Совпадение';

  @override
  String get filterMatchAny => 'Любой';

  @override
  String get filterMatchAll => 'Все';

  @override
  String get filterMinLevel => 'Минимальный уровень';

  @override
  String get filterLevelAny => 'Любой уровень';

  @override
  String get filterExperienceYearsMin => 'Всего лет, минимум';

  @override
  String get filterOccupationExperience => 'Лет в этой профессии, минимум';

  @override
  String get filterOccupationExperienceNeedsOccupation =>
      'Сначала выберите профессию';

  @override
  String get filterLanguages => 'Языки';

  @override
  String get filterLanguageCertificate => 'Нужен сертификат';

  @override
  String get filterEducationLevels => 'Уровень образования';

  @override
  String get filterSpecializations => 'Специальность';

  @override
  String get filterRegion => 'Регион';

  @override
  String get filterDistricts => 'Районы';

  @override
  String get filterDistrictsNeedRegion => 'Сначала выберите регион';

  @override
  String get filterWillingToRelocate => 'Готов к переезду';

  @override
  String get filterWillingToTravel => 'Готов к командировкам';

  @override
  String get filterProximityDistrict => 'Рядом с этим районом';

  @override
  String get filterProximityHint => 'Используется сортировкой «Ближайшие»';

  @override
  String get filterEmploymentTypes => 'Тип занятости';

  @override
  String get filterWorkFormats => 'Формат работы';

  @override
  String get filterShifts => 'Смена';

  @override
  String get filterSalaryMin => 'Зарплата от';

  @override
  String get filterSalaryMax => 'Зарплата до';

  @override
  String get filterSalaryMaxHint =>
      'Кандидат, ожидающий больше, исключается. Договорные ожидания по-прежнему подходят.';

  @override
  String get filterAvailableBy => 'Готов приступить к';

  @override
  String get filterAvailableImmediately => 'Готов приступить сразу';

  @override
  String get filterAttributes => 'Права, транспорт и инструменты';

  @override
  String get filterCrewSizeMin => 'Может привести бригаду не менее';

  @override
  String get filterMinCompleteness => 'Заполненность профиля, минимум (%)';

  @override
  String get filterUpdatedSince => 'Обновлён с';

  @override
  String get filterAgeMin => 'Возраст от';

  @override
  String get filterAgeMax => 'Возраст до';

  @override
  String get filterGender => 'Пол';

  @override
  String get filterJustification => 'Основание для ограничения';

  @override
  String get filterRestrictionRequired =>
      'Фильтр по возрасту или полу требует указания основания. Каждое использование фиксируется.';

  @override
  String get filterRestrictionExplain =>
      'Только если этого действительно требует работа.';

  @override
  String get sortMatch => 'По совпадению';

  @override
  String get sortRecent => 'По обновлению';

  @override
  String get sortExperience => 'По опыту';

  @override
  String get sortSalary => 'По ожидаемой зарплате';

  @override
  String get sortProximity => 'По близости';

  @override
  String get commonLoadMore => 'Показать ещё';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String filterChipValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get searchFromVacancy => 'Найти кандидатов';

  @override
  String get searchScopedToVacancy => 'Фильтры взяты из вакансии';

  @override
  String get candidateProfileTitle => 'Кандидат';

  @override
  String get candidateViewProfile => 'Открыть профиль';

  @override
  String get candidateContact => 'Контакты';

  @override
  String candidateAvailableFrom(String date) {
    return 'Готов с $date';
  }

  @override
  String get candidateAttachments => 'Вложения';

  @override
  String get candidateNoFiles => 'Кандидат ничего не загрузил';

  @override
  String get candidatePhoneNotOnFile => 'У кандидата не указан номер телефона.';

  @override
  String get candidateExposureNotVerified =>
      'Контакты откроются после верификации компании.';

  @override
  String get candidateExposureNoInteraction =>
      'Контакты откроются, когда кандидат откликнется на вашу вакансию или примет приглашение.';

  @override
  String get candidateExposureHidden =>
      'Кандидат скрыл профиль из поиска. Он по-прежнему видит ваши вакансии и может откликнуться.';

  @override
  String get searchSavedEmpty => 'Нет сохранённых кандидатов';

  @override
  String get commonCopy => 'Копировать';

  @override
  String get commonCopied => 'Скопировано';

  @override
  String get vacancyDetailTitle => 'Вакансия';

  @override
  String get vacancyDescription => 'О работе';

  @override
  String get vacancyRequirements => 'Требования';

  @override
  String get vacancyMandatory => 'Обязательно';

  @override
  String get vacancyPreferred => 'Желательно';

  @override
  String get vacancyGoneTitle => 'Вакансия больше недоступна';

  @override
  String get vacancyGoneBody =>
      'Возможно, она закрыта, заполнена или истёк срок подачи.';

  @override
  String get vacancyReportReason => 'Что не так с этой вакансией?';

  @override
  String get vacancyReportSend => 'Отправить';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String vacancyOpenings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мест',
      many: '$count мест',
      few: '$count места',
      one: '$count место',
    );
    return '$_temp0';
  }

  @override
  String vacancyWorkWindow(String start, String end) {
    return '$start – $end';
  }

  @override
  String vacancyStartsOn(String date) {
    return 'С $date';
  }

  @override
  String get walletTitle => 'Кошелёк';

  @override
  String get walletBalanceLabel => 'Баланс';

  @override
  String walletCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coin',
      many: '$count Coin',
      few: '$count Coin',
      one: '$count Coin',
    );
    return '$_temp0';
  }

  @override
  String walletApproxUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '≈ $amountString сум';
  }

  @override
  String walletUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString сум';
  }

  @override
  String get walletPrices => 'Цены на сегодня';

  @override
  String get walletCoinPriceLabel => '1 Coin';

  @override
  String get walletUnlockPriceLabel => 'Доступ к контактам кандидата';

  @override
  String walletRegistrationBonusOn(String date) {
    return 'Бонус за регистрацию начислен $date';
  }

  @override
  String get walletTopUp => 'Пополнить';

  @override
  String get walletTopUpUnavailable =>
      'Пополнение пока недоступно. Оно появится вместе с поддержкой Payme и CLICK.';

  @override
  String get walletActivity => 'Последние операции';

  @override
  String get walletActivityEmpty =>
      'В этом кошельке пока ничего не происходило. Здесь появляются и начисления, и списания, и ни одна запись никогда не удаляется.';

  @override
  String get walletShowMore => 'Показать ещё';

  @override
  String get walletLoadingMore => 'Загружаем ещё…';

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
      many: '$count Coin',
      few: '$count Coin',
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
      many: '$count Coin',
      few: '$count Coin',
      one: '$count Coin',
    );
    return '−$_temp0';
  }

  @override
  String get walletKindRegistrationBonus => 'Бонус за регистрацию';

  @override
  String get walletKindTopUp => 'Пополнение';

  @override
  String get walletKindCandidateUnlock => 'Доступ к контактам кандидата';

  @override
  String get walletKindAdminAdjustment => 'Корректировка администратора';

  @override
  String get walletKindReversal => 'Возврат';

  @override
  String get walletKindOther => 'Операция по кошельку';

  @override
  String get walletCorrection => 'Корректировка';

  @override
  String get walletBalanceUnavailable => 'Баланс недоступен';

  @override
  String unlockContact(String coins) {
    return 'Открыть контакты — $coins';
  }

  @override
  String get unlockTitle => 'Открыть контакты';

  @override
  String get unlockCost => 'Стоимость';

  @override
  String get unlockBalanceNow => 'Ваш баланс';

  @override
  String get unlockBalanceAfter => 'Баланс после';

  @override
  String get unlockConfirm => 'Подтвердить';

  @override
  String get unlockWhatYouGet =>
      'Станут доступны телефон, e-mail и резюме, и вы сможете начать переписку. Списывается один раз — вернуться к этому кандидату позже можно бесплатно.';

  @override
  String get unlockDone => 'Контакты открыты';

  @override
  String get unlockAlready => 'Уже открыто — ничего не списано';

  @override
  String unlockUnlockedOn(String date) {
    return 'Открыто $date';
  }

  @override
  String get unlockTopUpNeeded => 'Пополнить, чтобы открыть';

  @override
  String get candidateExposureUnlockRequired =>
      'Откройте контакты, чтобы связаться с кандидатом сейчас. Они также откроются бесплатно, если он откликнется на вашу вакансию или примет приглашение.';

  @override
  String get contactLockedTitle => 'Защищённые данные';

  @override
  String get contactUnlockedTitle => 'Контактные данные';

  @override
  String get contactPhone => 'Номер телефона';

  @override
  String get contactEmail => 'E-mail';

  @override
  String get contactCv => 'Файл резюме';

  @override
  String get contactCvLocked => 'PDF · закрыт';

  @override
  String contactLockedExplainer(String coins) {
    return '$coins открывает телефон, e-mail, резюме и переписку одного нового кандидата. За уже открытого кандидата повторно списаний нет.';
  }

  @override
  String get unlockGoToVerification => 'Перейти к верификации';

  @override
  String unlockChargedDetail(String coins, String balance) {
    return 'Списано $coins · баланс $balance';
  }

  @override
  String get unlockInsufficient => 'Недостаточно Coin';

  @override
  String walletValueAndPrice(int value, int price) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return '≈ $valueString сум · 1 Coin = $priceString сум';
  }

  @override
  String walletCoinRule(String coins) {
    return '$coins открывает контакты одного нового кандидата. Поиск кандидатов и просмотр профилей бесплатны.';
  }

  @override
  String get walletHistoryTitle => 'История операций';

  @override
  String get walletHistoryAll => 'Все';

  @override
  String get walletHistoryIncoming => 'Пополнения';

  @override
  String get walletHistoryOutgoing => 'Списания';

  @override
  String get walletHistoryNoMatch =>
      'Операций такого типа пока нет. Снимите фильтр, чтобы увидеть всё, что записано в кошельке.';

  @override
  String get walletDetailTitle => 'Детали операции';

  @override
  String get walletDetailSection => 'Детали';

  @override
  String get walletDetailReason => 'Причина';

  @override
  String get walletDetailWhen => 'Дата и время';

  @override
  String get walletDetailAmountUzs => 'Оплаченная сумма';

  @override
  String get walletDetailEffect => 'Влияние на баланс';

  @override
  String get walletDetailBalanceAfter => 'Баланс после';

  @override
  String get walletDetailReference => 'Номер для обращения';

  @override
  String get walletDetailSupportTitle => 'Что-то не так с этой записью?';

  @override
  String get walletDetailSupport =>
      'Обратитесь в поддержку и укажите номер выше. Ни одну запись в этой истории нельзя изменить или удалить, поэтому вы видите ровно то, что увидят они.';

  @override
  String get walletCorrectionExplained =>
      'Эта запись исправляет предыдущую. Исходная остаётся в истории — исправления добавляются, а не переписываются.';

  @override
  String get navInvitations => 'Приглашения';

  @override
  String get invitationSent => 'Отправлено';

  @override
  String get invitationDetailsRequested => 'Запрошены детали';

  @override
  String get invitationAccepted => 'Принято';

  @override
  String get invitationDeclined => 'Отклонено';

  @override
  String get invitationAccept => 'Принять';

  @override
  String get invitationDecline => 'Отклонить';

  @override
  String get invitationRequestDetails => 'Задать вопрос';

  @override
  String get invitationsInboxEmpty =>
      'Здесь появятся работодатели, которые пригласят вас на вакансию.';

  @override
  String get invitationGeneral => 'Общее приглашение';

  @override
  String get invitationOpenVacancy => 'Открыть вакансию';

  @override
  String get invitationVacancyLoading => 'Загрузка вакансии…';

  @override
  String get invitationVacancyUnavailable => 'Не удалось загрузить вакансию.';

  @override
  String get invitationVacancyUntitled => 'Вакансия';

  @override
  String get invitationYourReply => 'Ваш ответ';

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

    return '$fromString – $toString сум';
  }

  @override
  String invitationPayFrom(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'От $amountString сум';
  }

  @override
  String invitationPayUpTo(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'До $amountString сум';
  }

  @override
  String get invitationAcceptTitle => 'Принять это приглашение?';

  @override
  String get invitationAcceptDiscloses =>
      'Если вы примете приглашение, работодатель увидит ваш номер телефона, адрес электронной почты и резюме. Отменить это нельзя.';

  @override
  String get invitationDeclineTitle => 'Отклонить это приглашение?';

  @override
  String get invitationDeclineFinal =>
      'Ваши контактные данные останутся закрытыми. Отклонить можно только один раз, но работодатель может пригласить вас снова позже.';

  @override
  String get invitationRequestDetailsTitle => 'Задать вопрос работодателю';

  @override
  String get invitationRequestDetailsBody =>
      'Вы сможете принять или отклонить приглашение позже. До этого ваши контактные данные останутся закрытыми.';

  @override
  String get invitationQuestionLabel => 'Ваш вопрос';

  @override
  String get invitationQuestionHint =>
      'Например: где именно находится работа и когда она начинается?';

  @override
  String get invitationNoteLabel => 'Сообщение (необязательно)';

  @override
  String get invitationNoteHint => 'Всё, что вы хотите сообщить работодателю.';

  @override
  String get invitationAlreadyAnswered => 'На это приглашение уже ответили';

  @override
  String get commonChoose => 'Выбрать';

  @override
  String get invitationSendTitle => 'Отправить приглашение';

  @override
  String get invitationSend => 'Отправить';

  @override
  String get invitationSendFree =>
      'Отправка бесплатна. Контактные данные откроются только если кандидат примет приглашение.';

  @override
  String get invitationToVacancy => 'На вакансию';

  @override
  String get invitationVacancyLabel => 'Выберите вакансию';

  @override
  String get invitationNoOpenVacancyTitle => 'Нет открытых вакансий';

  @override
  String get invitationNoOpenVacancyBody =>
      'Приглашение можно привязать только к активной вакансии. Общее приглашение на работу отправить всё равно можно.';

  @override
  String get invitationOccupation => 'Профессия';

  @override
  String get invitationRegion => 'Регион';

  @override
  String get invitationDistrict => 'Район';

  @override
  String get invitationNegotiable => 'Оплата по договорённости';

  @override
  String get invitationSalaryFrom => 'Оплата от';

  @override
  String get invitationSalaryTo => 'Оплата до';

  @override
  String get invitationSalaryPeriod => 'За период';

  @override
  String get invitationSchedule => 'График';

  @override
  String get invitationScheduleHint =>
      'Например: шесть дней в неделю, по утрам';

  @override
  String get invitationMessageLabel => 'Сообщение (необязательно)';

  @override
  String get invitationMessageHint => 'Что вы хотите сообщить кандидату';

  @override
  String invitationQuotaRemaining(int remaining, int limit) {
    return 'Осталось $remaining из $limit приглашений на сегодня';
  }

  @override
  String invitationQuotaResets(String at) {
    return 'Обновится в $at';
  }

  @override
  String get invitationQuotaSpentTitle => 'Приглашения на сегодня закончились';

  @override
  String get invitationAlreadySentTitle => 'Приглашение уже отправлено';

  @override
  String get invitationSentConfirm => 'Приглашение отправлено';

  @override
  String get invitationsSentTitle => 'Отправленные приглашения';

  @override
  String get invitationsSentEmpty =>
      'Здесь появятся кандидаты, которых вы пригласили.';

  @override
  String get invitationsSentNoMatch =>
      'Приглашений с этим статусом нет. Снимите фильтр, чтобы увидеть все отправленные.';

  @override
  String get invitationsSentForVacancy => 'Только эта вакансия';

  @override
  String get invitationFilterAll => 'Все';

  @override
  String get invitationYourMessage => 'Ваше сообщение';

  @override
  String get invitationCandidateReply => 'Ответ кандидата';

  @override
  String get invitationContactOpenTitle => 'Контакты открыты';

  @override
  String get invitationContactOpenBody =>
      'Кандидат принял приглашение — телефон, эл. почта и резюме доступны в профиле кандидата. Платное открытие не требуется.';

  @override
  String get invitationOpenCandidate => 'Открыть кандидата';

  @override
  String invitationCounts(int invited, int accepted) {
    return 'Приглашено: $invited, принято: $accepted';
  }

  @override
  String get candidateFileNoViewer =>
      'На этом телефоне нет приложения, которое откроет этот файл.';

  @override
  String get dashboardActiveVacancies => 'Активные вакансии';

  @override
  String get dashboardOpenPositions => 'Открытых мест';

  @override
  String get dashboardNewApplications => 'Новые заявки';

  @override
  String get dashboardAttention => 'Требует вашего внимания';

  @override
  String get dashboardAttentionClear => 'Ничего не ждёт вашего решения.';

  @override
  String get dashboardVerificationTitle => 'Проверка не завершена';

  @override
  String get dashboardVacancyRejected => 'Требуются изменения';

  @override
  String dashboardUnreviewed(int count) {
    return 'Не рассмотрено заявок: $count';
  }

  @override
  String dashboardSavedCandidates(int count) {
    return 'Сохранённых кандидатов: $count';
  }

  @override
  String get dashboardHiring => 'Ход найма';

  @override
  String dashboardHiredOf(int hired, int openings) {
    return '$hired из $openings';
  }

  @override
  String dashboardMeterHired(int count) {
    return 'Приняты $count';
  }

  @override
  String dashboardMeterInvited(int count) {
    return 'Приглашены $count';
  }

  @override
  String dashboardMeterRemaining(int count) {
    return 'Осталось $count';
  }

  @override
  String get dashboardWallet => 'Кошелёк';

  @override
  String get accountTitle => 'Аккаунт и безопасность';

  @override
  String get accountDevices => 'Устройства с активным входом';

  @override
  String get accountDevicesBody =>
      'Если видите незнакомое устройство — завершите его сеанс.';

  @override
  String get accountDeviceUnknown => 'Устройство без имени';

  @override
  String accountLastUsed(String at) {
    return 'Последний вход: $at';
  }

  @override
  String get accountThisDevice => 'Это устройство';

  @override
  String get accountRevoke => 'Завершить сеанс';

  @override
  String get accountRevokeTitle => 'Завершить этот сеанс?';

  @override
  String get accountRevokeBody =>
      'На этом устройстве потребуется войти заново.';

  @override
  String get accountRevokeCurrentTitle => 'Выйти на этом устройстве?';

  @override
  String get accountRevokeCurrentBody =>
      'Это устройство, которым вы пользуетесь. Сейчас вы выйдете из аккаунта.';

  @override
  String get accountRevokeAll => 'Завершить все сеансы';

  @override
  String get accountRevokeAllTitle => 'Завершить все сеансы?';

  @override
  String get accountRevokeAllBody =>
      'Из аккаунта выйдут все устройства, включая это.';

  @override
  String get accountDelete => 'Удаление аккаунта';

  @override
  String get accountDeleteBody =>
      'Ваш профиль, заявки и сообщения будут удалены. Отменить это нельзя.';

  @override
  String get accountDeleteAction => 'Запросить удаление';

  @override
  String get accountDeleteConfirmTitle => 'Запросить удаление аккаунта?';

  @override
  String get accountDeleteConfirmBody =>
      'Мы начнём удаление вашего аккаунта. Отменить это из приложения будет нельзя.';

  @override
  String get accountDeleteRequestedTitle => 'Удаление запрошено';

  @override
  String get accountDeleteRequestedBody =>
      'Ваш запрос зарегистрирован. Что будет дальше — расскажет поддержка.';

  @override
  String get filtersRegion => 'Область или район';

  @override
  String get filtersEmploymentType => 'Тип занятости';

  @override
  String get filtersWorkFormat => 'Формат работы';

  @override
  String get filtersShift => 'Смена';

  @override
  String get filtersSalaryFrom => 'Оплата от';

  @override
  String get filtersSalaryNegotiableNote =>
      'Вакансии с оплатой по договорённости тоже показываются.';

  @override
  String get filtersPublishedFrom => 'Опубликовано с';

  @override
  String get filtersUnavailableTitle => 'Три фильтра пока недоступны';

  @override
  String get filtersUnavailableBody =>
      'Пока нельзя фильтровать по опыту, языку и верхней границе оплаты. Остальное работает.';

  @override
  String feedFilteredNote(int count) {
    return 'Применено фильтров: $count';
  }

  @override
  String get feedFilteredEmpty =>
      'Под эти фильтры вакансий нет. Попробуйте расширить их.';

  @override
  String get feedSavedUnfiltered => 'Сохранённые вакансии не фильтруются.';
}
