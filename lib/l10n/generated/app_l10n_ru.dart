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
  String get fileNoViewer =>
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

  @override
  String get notesEmpty => 'Заметок пока нет.';

  @override
  String get notesNewLabel => 'Новая заметка';

  @override
  String get notesNewHint =>
      'Просит 8м, возможно согласится на 6,5 — перезвонить в четверг';

  @override
  String get applicantsNoneAtStage =>
      'На этом этапе никого нет. Снимите фильтр, чтобы увидеть всех.';

  @override
  String get shortlistTitle => 'Шорт-лист';

  @override
  String get shortlistEmpty => 'В шорт-листе пока никого нет';

  @override
  String get roleSelectionTitle => 'Как вы будете пользоваться JobBridge?';

  @override
  String get roleSelectionSubtitle =>
      'Выберите одно или оба — второе можно добавить позже, без второго аккаунта.';

  @override
  String get roleCandidateDescription =>
      'Создайте профиль, который найдут работодатели, откликайтесь на вакансии и отвечайте на приглашения.';

  @override
  String get roleEmployerDescription =>
      'Публикуйте вакансии, ищите кандидатов и приглашайте тех, с кем хотите поговорить.';

  @override
  String get roleSelectionBoth =>
      'С обеими ролями один аккаунт хранит два отдельных пространства: ваш личный профиль и профиль компании, переключение — в профиле.';

  @override
  String get chatListEmpty =>
      'Переписка открывается после взаимодействия по вакансии — отклика или принятого приглашения.';

  @override
  String get chatParticipantUnknown => 'Участник';

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
      other: '$count непрочитанных сообщений',
      many: '$count непрочитанных сообщений',
      few: '$count непрочитанных сообщения',
      one: '$count непрочитанное сообщение',
    );
    return '$_temp0';
  }

  @override
  String get chatNoMessages => 'Сообщений пока нет';

  @override
  String get chatAttachment => 'Вложение';

  @override
  String get chatReadOnly => 'Только чтение';

  @override
  String get chatBlocked => 'Заблокировано';

  @override
  String get chatBlockedByYou => 'Вы заблокировали';

  @override
  String get chatReadOnlyTitle => 'Эта переписка стала историей';

  @override
  String get chatReadOnlyBody =>
      'Отклик или приглашение, с которого она началась, завершились, поэтому новые сообщения отправить нельзя. Всё написанное остаётся доступным для чтения.';

  @override
  String get chatBlockedTitle => 'Заблокировано';

  @override
  String get chatBlockedBody =>
      'Другая сторона заблокировала эту переписку. Пока блокировка действует, писать не может никто, а сообщения остаются доступными для чтения.';

  @override
  String get chatBlockedByYouTitle => 'Вы заблокировали эту переписку';

  @override
  String get chatBlockedByYouBody =>
      'Пока блокировка действует, писать не может ни одна сторона — включая вас. Чтобы снова писать, снимите блокировку сверху экрана.';

  @override
  String get chatUnblock => 'Разблокировать';

  @override
  String get chatUnblocked => 'Блокировка снята. Теперь можно писать.';

  @override
  String get chatBlockAction => 'Заблокировать';

  @override
  String get chatBlockTitle => 'Заблокировать эту переписку?';

  @override
  String get chatBlockBody =>
      'Она станет доступной только для чтения для вас обоих — вы тоже не сможете писать. Сообщения останутся доступными, и модератор сможет их просмотреть.';

  @override
  String get chatBlockReasonLabel => 'Причина (необязательно)';

  @override
  String get chatBlockReasonHint => 'Для модератора, который это рассмотрит';

  @override
  String get chatReportTitle => 'Пожаловаться на это сообщение';

  @override
  String get chatReportBody =>
      'Жалобу читает модератор и принимает решение. Блокировка переписки — отдельное действие, можно сделать и то и другое.';

  @override
  String get chatReportReasonLabel => 'Что с ним не так';

  @override
  String get chatReportReasonHint => 'Попросил заплатить за трудоустройство';

  @override
  String get chatReportSubmit => 'Отправить жалобу';

  @override
  String get chatReportDone => 'Жалоба отправлена. Модератор её рассмотрит.';

  @override
  String get chatComposerLabel => 'Сообщение';

  @override
  String get chatComposerHint => 'Напишите сообщение';

  @override
  String get chatSend => 'Отправить';

  @override
  String get chatSendRefusedTitle => 'Не отправлено';

  @override
  String get chatSent => 'Отправлено';

  @override
  String get chatRead => 'Прочитано';

  @override
  String get chatEarlier => 'Более ранние сообщения';

  @override
  String get chatThreadEmpty => 'Сообщений пока нет. Напишите первое.';

  @override
  String get chatThreadEmptyClosed =>
      'До закрытия этой переписки сообщений не было.';

  @override
  String get chatOpenAction => 'Отправить сообщение';

  @override
  String get interviewTitle => 'Собеседование';

  @override
  String get interviewStatusScheduled => 'Назначено';

  @override
  String get interviewStatusConfirmed => 'Подтверждено';

  @override
  String get interviewStatusRescheduleRequested => 'Просят другое время';

  @override
  String get interviewStatusCancelled => 'Отменено';

  @override
  String get interviewTypePhone => 'По телефону';

  @override
  String get interviewTypeInPerson => 'Личная встреча';

  @override
  String get interviewTypeExternalLink => 'Видеосвязь';

  @override
  String get interviewPhoneNote =>
      'Работодатель позвонит на номер из вашего профиля.';

  @override
  String get interviewWhere => 'Где';

  @override
  String get interviewLink => 'Ссылка';

  @override
  String get interviewInstructions => 'От работодателя';

  @override
  String get interviewYourReply => 'Ваш ответ';

  @override
  String get interviewPassed => 'Это время уже прошло.';

  @override
  String get interviewCancelledNotice =>
      'Работодатель отменил это собеседование.';

  @override
  String get interviewConfirm => 'Подтвердить';

  @override
  String get interviewRequestAnother => 'Попросить другое время';

  @override
  String get interviewConfirmTitle => 'Подтвердить это время?';

  @override
  String get interviewConfirmBody =>
      'Работодатель увидит, что время вам подходит. Если что-то изменится, вы всё равно сможете попросить другое время.';

  @override
  String get interviewRescheduleTitle => 'Попросить другое время';

  @override
  String get interviewRescheduleBody =>
      'Собеседование остаётся в силе, пока работодатель не назначит новое время, и он увидит то, что вы напишете ниже.';

  @override
  String get interviewNoteLabel => 'Какое время вам подходит';

  @override
  String get interviewNoteHint =>
      'Любой день на этой неделе после обеда или утро пятницы';

  @override
  String get interviewReplyNoteLabel => 'Комментарий (необязательно)';

  @override
  String get interviewReplyNoteHint => 'Буду на месте на десять минут раньше';

  @override
  String get interviewNotAllowed => 'Статус собеседования изменился';

  @override
  String get interviewSchedule => 'Назначить собеседование';

  @override
  String get interviewScheduleTitle => 'Назначить собеседование';

  @override
  String get interviewScheduleSave => 'Отправить кандидату';

  @override
  String get interviewRescheduleFormTitle => 'Перенести собеседование';

  @override
  String get interviewRescheduleSave => 'Сохранить новое время';

  @override
  String get interviewRescheduleResets =>
      'Кандидата попросят подтвердить заново, даже при небольшом изменении — собеседование, перенесённое на другое время, не считается подтверждённым.';

  @override
  String get interviewTypeLabel => 'Вид собеседования';

  @override
  String get interviewWhereHint =>
      'Амира Темура 12, 3-й этаж — на ресепшене спросите Дилнозу';

  @override
  String get interviewLinkHint => 'https://meet.example.com/abc-defg-hij';

  @override
  String get interviewDateLabel => 'Дата';

  @override
  String get interviewTimeLabel => 'Время';

  @override
  String get interviewTimeHint => '10:00';

  @override
  String get interviewInstructionsLabel => 'Что взять с собой или подготовить';

  @override
  String get interviewInstructionsHint => 'Возьмите диплом и трудовую книжку';

  @override
  String get interviewReschedule => 'Перенести';

  @override
  String get interviewCancelAction => 'Отменить собеседование';

  @override
  String get interviewCancelTitle => 'Отменить это собеседование?';

  @override
  String get interviewCancelBody =>
      'Это окончательно для обеих сторон — собеседование не вернуть, а новое время означает новое собеседование. Кандидат увидит, что оно отменено.';

  @override
  String get interviewCancelReasonLabel =>
      'Причина (необязательно, кандидат её увидит)';

  @override
  String get interviewCancelReasonHint =>
      'Вакансия закрыта — спасибо за ваше время';

  @override
  String get interviewCandidateReply => 'Что ответил кандидат';

  @override
  String get commonShowMore => 'Показать ещё';

  @override
  String get commonLoadingMore => 'Загружаем ещё…';

  @override
  String get adminDashboardTitle => 'Администрирование';

  @override
  String get adminQueuesTitle => 'Ожидают решения';

  @override
  String get adminAwaitingVerification => 'Работодатели, ожидающие проверки';

  @override
  String get adminAwaitingModeration => 'Вакансии, ожидающие модерации';

  @override
  String get adminOpenComplaints => 'Открытые жалобы';

  @override
  String get adminQueuesClear => 'Ничего не ждёт вашего решения.';

  @override
  String get adminSanctionsTitle => 'Аккаунты с ограничениями';

  @override
  String get adminRestrictedUsers => 'Ограничены';

  @override
  String get adminBlockedUsers => 'Заблокированы';

  @override
  String get adminPeriodTitle => 'За выбранный период';

  @override
  String adminPeriodDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0';
  }

  @override
  String get adminCandidates => 'Кандидаты';

  @override
  String get adminEmployers => 'Работодатели';

  @override
  String get adminVacanciesPublished => 'Опубликованные вакансии';

  @override
  String get adminApplicationsSubmitted => 'Поданные заявки';

  @override
  String get adminCountTotal => 'всего';

  @override
  String get adminCountNew => 'новых';

  @override
  String get adminVerificationTitle => 'Проверка работодателей';

  @override
  String get adminVerificationFifo =>
      'Сначала самые давние — заявка сверху ждёт дольше всех.';

  @override
  String get adminVerificationEmpty => 'Никто не ожидает';

  @override
  String get adminVerificationEmptyBody =>
      'Заявки появятся здесь, когда работодатели пришлют документы.';

  @override
  String get adminEmployerCompany => 'Организация';

  @override
  String get adminEmployerIndividual => 'Физическое лицо';

  @override
  String get adminEmployerUnnamed => 'Название не указано';

  @override
  String adminWaitingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Ждёт $days дней',
      many: 'Ждёт $days дней',
      few: 'Ждёт $days дня',
      one: 'Ждёт $days день',
      zero: 'Отправлено сегодня',
    );
    return '$_temp0';
  }

  @override
  String get adminEvidenceTitle => 'Документы';

  @override
  String get adminEvidenceNone => 'Документы не приложены';

  @override
  String get adminVerify => 'Подтвердить';

  @override
  String get adminRequestChanges => 'Запросить изменения';

  @override
  String get adminReject => 'Отклонить';

  @override
  String get adminVerifyTitle => 'Подтвердить этого работодателя?';

  @override
  String get adminVerifyBody =>
      'Это откроет им публикацию вакансий и приглашение кандидатов. Больше ничего в аккаунте не изменится.';

  @override
  String get adminRequestChangesTitle => 'Вернуть на доработку?';

  @override
  String get adminRequestChangesBody =>
      'Профиль и файлы сохранятся — они смогут отправить заявку снова, исправив то, что вы укажете ниже.';

  @override
  String get adminRejectTitle => 'Отклонить эту заявку?';

  @override
  String get adminRejectBody =>
      'Работодатель останется непроверенным и не сможет публиковать вакансии и приглашать. Ваша причина — всё, что он получит, поэтому напишите, что нужно исправить.';

  @override
  String get adminReasonLabel => 'Причина (работодатель прочитает её дословно)';

  @override
  String get adminReasonHint =>
      'Свидетельство о регистрации не читается — загрузите более чёткий скан';

  @override
  String get adminAlreadyDecided => 'Решение уже принято';

  @override
  String get adminDecisionRecorded => 'Решение зафиксировано.';

  @override
  String get adminQueueTitle => 'Модерация';

  @override
  String get adminQueueEmployers => 'Работодатели';

  @override
  String get adminQueueVacancies => 'Вакансии';

  @override
  String get adminModerationEmpty => 'Нет вакансий на модерации';

  @override
  String get adminModerationEmptyBody =>
      'Вакансии появятся здесь, когда работодатели отправят их на публикацию.';

  @override
  String get adminRestrictionFlag => 'Ограничение по возрасту или полу';

  @override
  String get adminReviewTitle => 'Проверка';

  @override
  String get adminVacancyGoneTitle => 'Эта вакансия больше не в очереди';

  @override
  String get adminVacancyGoneBody =>
      'Возможно, решение уже принято, или работодатель отозвал её.';

  @override
  String get adminPublish => 'Опубликовать';

  @override
  String get adminSendBack => 'Вернуть';

  @override
  String get adminPublishTitle => 'Опубликовать эту вакансию?';

  @override
  String get adminPublishBody =>
      'Кандидаты увидят её сразу. Если есть ограничение по возрасту или полу, публикация одобряет и его — иначе такая вакансия не может быть опубликована вообще.';

  @override
  String get adminSendBackTitle => 'Вернуть эту вакансию?';

  @override
  String get adminSendBackBody =>
      'Работодатель сможет исправить её и отправить снова. Ваша причина — единственное указание, которое он получит, поэтому напишите, что нужно изменить.';

  @override
  String get adminRestrictionJudge =>
      'Ограничение допустимо только там, где причина действительно его требует. Оценивайте причину, а не ограничение.';

  @override
  String get adminRestrictionAge => 'Ограничение по возрасту';

  @override
  String get adminRestrictionGender => 'Ограничение по полу';

  @override
  String get adminRestrictionReason => 'Причина, выбранная работодателем';

  @override
  String get adminRestrictionNote => 'Их собственными словами';

  @override
  String get adminPreviousReason => 'Ранее возвращена по этой причине';

  @override
  String get adminVacancyWhere => 'Место работы';

  @override
  String get adminVacancyEmployer => 'Работодатель';

  @override
  String get adminVacancyEmployerPhone => 'Номер для входа';

  @override
  String get adminComplaintsTitle => 'Жалобы';

  @override
  String get adminComplaintsEmpty => 'Жалоб нет';

  @override
  String get adminComplaintsEmptyBody => 'Ни одна жалоба не ждёт решения.';

  @override
  String get adminComplaintKindVacancy => 'Вакансия';

  @override
  String get adminComplaintKindUser => 'Пользователь';

  @override
  String get adminComplaintKindProfile => 'Профиль';

  @override
  String get adminComplaintKindMessage => 'Сообщение';

  @override
  String get adminComplaintKindUnknown => 'Неизвестный тип';

  @override
  String get adminComplaintKindUnknownBody =>
      'Эта версия приложения не может показать тип объекта. Обновите приложение, чтобы рассмотреть жалобу.';

  @override
  String get adminComplaintTitle => 'Жалоба';

  @override
  String get adminComplaintGoneTitle => 'Жалоба не найдена';

  @override
  String get adminComplaintGoneBody =>
      'Её уже рассмотрели, либо её не существовало. Решать больше нечего.';

  @override
  String get adminComplaintReported => 'О чём сообщили';

  @override
  String get adminComplaintTarget => 'Объект жалобы';

  @override
  String get adminComplaintTargetGone => 'Объект жалобы удалён';

  @override
  String get adminComplaintTargetGoneBody =>
      'Он был удалён после подачи жалобы. Жалоба сохранена, поэтому результат всё ещё можно зафиксировать.';

  @override
  String get adminComplaintEmployerAccount => 'Аккаунт работодателя';

  @override
  String get adminComplaintRemedy => 'Сначала примите меру';

  @override
  String get adminComplaintRemedyBody =>
      'Отметка «удовлетворена» ничего не выполняет. Сначала примите меру здесь.';

  @override
  String get adminComplaintNoRemedy =>
      'Здесь принимать меру не к чему. Зафиксируйте результат ниже.';

  @override
  String get adminComplaintOutcome => 'Зафиксируйте результат';

  @override
  String get adminComplaintOutcomeBody =>
      'Рассмотрение жалобы больше нигде не фиксируется, поэтому написанное вами — единственный её отчёт.';

  @override
  String get adminComplaintUphold => 'Удовлетворить';

  @override
  String get adminComplaintDismiss => 'Отклонить';

  @override
  String get adminComplaintUpholdTitle => 'Удовлетворить эту жалобу?';

  @override
  String get adminComplaintUpholdBody =>
      'Жалоба закроется как удовлетворённая. Если нужна мера, примите её до фиксации.';

  @override
  String get adminComplaintDismissTitle => 'Отклонить эту жалобу?';

  @override
  String get adminComplaintDismissBody =>
      'Жалоба закроется без каких-либо мер. Укажите причину — это единственный отчёт о решении.';

  @override
  String get adminResolutionLabel => 'Решение (хранится в журнале аудита)';

  @override
  String get adminResolutionHint =>
      'Вакансия приостановлена, работодателя попросили убрать номер телефона из описания';

  @override
  String get adminPauseVacancy => 'Приостановить вакансию';

  @override
  String get adminCloseVacancy => 'Снять вакансию';

  @override
  String get adminPauseVacancyTitle => 'Приостановить вакансию?';

  @override
  String get adminPauseVacancyBody =>
      'Она сразу уйдёт из ленты и может быть возобновлена после исправления работодателем.';

  @override
  String get adminCloseVacancyTitle => 'Снять вакансию?';

  @override
  String get adminCloseVacancyBody =>
      'Она уйдёт из ленты навсегда. Снятую вакансию нельзя открыть заново — если работодатель может исправить, приостановите её.';

  @override
  String get adminWarnUser => 'Предупредить';

  @override
  String get adminWarnUserTitle => 'Отправить предупреждение?';

  @override
  String get adminWarnUserBody =>
      'Аккаунт не изменится. Предупреждение и его причина будут зафиксированы, а пользователь — уведомлён.';

  @override
  String get adminWarnReasonLabel =>
      'Предупреждение (пользователь прочитает дословно)';

  @override
  String get adminWarnReasonHint =>
      'Указывать контактные данные в публичном описании вакансии нельзя — пожалуйста, уберите их';

  @override
  String get adminAccountStatusActive => 'Активен';

  @override
  String get adminAccountStatusRestricted => 'Ограничен';

  @override
  String get adminAccountStatusBlocked => 'Заблокирован';

  @override
  String get adminVacancyEmployerContactPhone => 'Контактный номер';

  @override
  String get adminUsersTitle => 'Пользователи';

  @override
  String get adminUserSearchPhone => 'Номер телефона';

  @override
  String get adminUserSearchPhoneHint => 'Достаточно последних цифр';

  @override
  String get adminUserSearchPhoneTooShort => 'Не менее 3 цифр.';

  @override
  String get adminUserSearchName => 'Имя или название';

  @override
  String get adminUserSearchNameHint =>
      'Человек, компания или её юридическое название';

  @override
  String get adminUserSearchNameTooShort => 'Не менее 2 символов.';

  @override
  String get adminUserSearchMore => 'Больше фильтров';

  @override
  String get adminUserSearchFewer => 'Меньше фильтров';

  @override
  String get adminUserSearchRole => 'Имеет роль';

  @override
  String get adminUserSearchStatus => 'Статус аккаунта';

  @override
  String get adminUserSearchRegisteredFrom => 'Зарегистрирован с';

  @override
  String get adminUserSearchRegisteredTo => 'Зарегистрирован по';

  @override
  String get adminUserSearchDatesReversed => 'Эти даты не совпадут';

  @override
  String get adminUserSearchDatesReversedBody =>
      'Первая дата позже второй, поэтому между ними не окажется ни одного аккаунта.';

  @override
  String get adminUserSearchRun => 'Найти';

  @override
  String get adminUserSearchClear => 'Очистить фильтры';

  @override
  String get adminUserSearchIdle => 'Найдите аккаунт';

  @override
  String get adminUserSearchIdleBody =>
      'Ищите по последним цифрам номера или по любому имени, под которым известен аккаунт: имени человека, публичному названию компании или её юридическому названию. Пока вы не спросите, ничего не читается.';

  @override
  String get adminUserSearchEmpty => 'Совпадений нет';

  @override
  String get adminUserSearchEmptyBody =>
      'По этим фильтрам ничего не найдено. Номер ищется по любой части, поэтому последние несколько цифр находят аккаунт, который полный номер, набранный иначе, не найдёт.';

  @override
  String get adminUserSearchOrder =>
      'Сначала самые новые регистрации. Более старый аккаунт находится ниже по списку, а не отсутствует — сузьте поиск, а не листайте до него.';

  @override
  String get adminUserNoName => 'Имя не указано';

  @override
  String get adminUserNoPhone => 'Номера телефона нет';

  @override
  String adminUserRegistered(String date) {
    return 'Регистрация: $date';
  }

  @override
  String adminUserLastLogin(String date) {
    return 'Последний вход: $date';
  }

  @override
  String get adminUserNeverSignedIn => 'Ни разу не входил';

  @override
  String get adminAccountStatusDeletionRequested => 'Запрошено удаление';

  @override
  String get adminUserTitle => 'Аккаунт';

  @override
  String get adminUserGoneTitle => 'Этого аккаунта больше нет';

  @override
  String get adminUserGoneBody =>
      'Аккаунт не найден. Возможно, он был удалён уже после поиска, который его нашёл.';

  @override
  String get adminUserActions => 'Действия с аккаунтом';

  @override
  String get adminUserNoActionsTitle => 'Отсюда ничего сделать нельзя';

  @override
  String get adminUserNoActionsBody =>
      'Этот аккаунт запросил удаление. Запрос обрабатывается своим процессом, а ограничение или блокировка отсюда перезапишут его.';

  @override
  String get adminUserRestrict => 'Ограничить';

  @override
  String get adminUserBlock => 'Заблокировать';

  @override
  String get adminUserUnblock => 'Разблокировать';

  @override
  String get adminUserLiftRestriction => 'Снять ограничение';

  @override
  String get adminUserRestrictTitle => 'Ограничить этот аккаунт?';

  @override
  String get adminUserRestrictBody =>
      'Аккаунт остаётся у них, войти они смогут, но любое действие, что-либо изменяющее, будет отклонено до снятия ограничения. Вашу причину они увидят.';

  @override
  String get adminUserBlockTitle => 'Заблокировать этот аккаунт?';

  @override
  String get adminUserBlockBody =>
      'Им остаётся только уведомление с объяснением причины. Отменить это может лишь администратор.';

  @override
  String get adminUserUnblockTitle => 'Разблокировать этот аккаунт?';

  @override
  String get adminUserLiftRestrictionTitle => 'Снять это ограничение?';

  @override
  String get adminUserLiftBody => 'С этого момента им снова доступно всё.';

  @override
  String get adminUserRestrictUntilLabel => 'Дата окончания';

  @override
  String get adminUserRestrictUntilCaption =>
      'Ограничение снимается в начале этого дня по ташкентскому времени. Оставьте поле пустым — оно будет действовать, пока его не снимет администратор.';

  @override
  String get adminUserStatusReasonLabel => 'Причина (её прочитают дословно)';

  @override
  String get adminUserStatusReasonHint =>
      'Повторная публикация вакансий, требующих денег от кандидатов';

  @override
  String adminUserRestrictedUntil(String date) {
    return 'Ограничен до $date';
  }

  @override
  String get adminUserRestrictedIndefinitely =>
      'Ограничен до снятия администратором';

  @override
  String get adminUserHistory => 'История аккаунта';

  @override
  String get adminUserHistoryEmpty => 'Статус этого аккаунта не менялся.';

  @override
  String adminUserHistoryBy(String actor) {
    return 'Кто: $actor';
  }

  @override
  String get adminUserHistoryAutomatic => 'Платформой, по истечении срока';

  @override
  String get adminUserComplaints => 'Жалобы на этот аккаунт';

  @override
  String get adminUserComplaintsEmpty => 'На этот аккаунт никто не жаловался.';

  @override
  String get adminUserComplaintOpen => 'Открыта';

  @override
  String get adminUserComplaintClosed => 'Рассмотрена';

  @override
  String get adminAuditTitle => 'Журнал аудита';

  @override
  String get adminAuditNote =>
      'Сначала новые. Ничего здесь нельзя изменить или удалить.';

  @override
  String get adminAuditEmpty => 'Пока ничего не записано';

  @override
  String get adminAuditEmptyBody =>
      'Запись появляется здесь, когда администратор что-то решает, проверяет, модерирует или применяет санкцию.';

  @override
  String get adminAuditEmptyFilteredBody =>
      'По этому ничего не записано. Остальной журнал — ниже.';

  @override
  String get adminAuditFilteredByActor => 'Только этот администратор';

  @override
  String get adminAuditFilteredByTarget => 'Только эта запись';

  @override
  String get adminAuditShowAll => 'Показать весь журнал';

  @override
  String get adminAuditActor => 'Администратор';

  @override
  String get adminAuditDetails => 'Что изменилось';

  @override
  String get adminAuditTargetUser => 'Аккаунт';

  @override
  String get adminAuditTargetEmployer => 'Работодатель';

  @override
  String get adminAuditTargetVacancy => 'Вакансия';

  @override
  String get adminAuditTargetComplaint => 'Жалоба';

  @override
  String get adminAuditTargetDictionaryItem => 'Элемент справочника';

  @override
  String get adminAuditTargetUnknown => 'Другое';

  @override
  String get adminAuditVerificationDecided =>
      'Решение по проверке работодателя';

  @override
  String get adminAuditVacancyModerated => 'Вакансия проверена';

  @override
  String get adminAuditComplaintReviewed => 'Жалоба рассмотрена';

  @override
  String get adminAuditUserWarned => 'Пользователь предупреждён';

  @override
  String get adminAuditUserRestricted => 'Пользователь ограничен';

  @override
  String get adminAuditUserBlocked => 'Пользователь заблокирован';

  @override
  String get adminAuditUserUnblocked => 'Пользователь разблокирован';

  @override
  String get adminAuditRestrictionExpired => 'Срок ограничения истёк';

  @override
  String get adminAuditAccountPurged => 'Аккаунт удалён';

  @override
  String get adminAuditWalletAdjusted => 'Кошелёк скорректирован';

  @override
  String get adminAuditDictionaryCreated => 'Добавлен элемент справочника';

  @override
  String get adminAuditDictionaryUpdated => 'Изменён элемент справочника';

  @override
  String get adminAuditDictionaryDeactivated => 'Элемент справочника отключён';

  @override
  String get adminAuditDictionaryMerged => 'Элементы справочника объединены';

  @override
  String get adminUserAuditAbout => 'Всё, что делали с этим аккаунтом';

  @override
  String get adminUserAuditBy => 'Всё, что сделал этот администратор';

  @override
  String get candidateHomeTitle => 'Главная';

  @override
  String candidateHomeInvitations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count приглашений ждут вашего ответа',
      many: '$count приглашений ждут вашего ответа',
      few: '$count приглашения ждут вашего ответа',
      one: '$count приглашение ждёт вашего ответа',
    );
    return '$_temp0';
  }

  @override
  String candidateHomeApplications(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count откликов на рассмотрении',
      many: '$count откликов на рассмотрении',
      few: '$count отклика на рассмотрении',
      one: '$count отклик на рассмотрении',
    );
    return '$_temp0';
  }

  @override
  String get candidateHomeProfileEmpty => 'Заполните профиль';

  @override
  String get candidateHomeProfileIncomplete => 'Завершите профиль';

  @override
  String get candidateHomeProfileBody =>
      'Чем полнее профиль, тем больше вакансий ему соответствует.';

  @override
  String get candidateHomeProfileHidden =>
      'Работодатели пока не могут вас найти — чтобы профиль появился в поиске, он должен быть заполнен.';

  @override
  String get candidateHomeRecommended => 'Рекомендуем вам';

  @override
  String get candidateHomeSeeAll => 'Все';

  @override
  String get candidateHomeNoRecommendations => 'Пока нет рекомендаций';

  @override
  String get candidateHomeNoRecommendationsBody =>
      'Рекомендации подбираются по вашим профессиям, местоположению и предпочтениям. А пока посмотрите недавно опубликованные вакансии.';

  @override
  String get candidateHomeBrowseAll => 'Смотреть новые вакансии';

  @override
  String get invitationAwaitingYou => 'Ждёт вашего ответа';

  @override
  String get employerTypeFirst =>
      'Выберите выше, кто нанимает. От этого зависит, какие данные потребуются.';

  @override
  String get employerRequired => 'Обязательно';

  @override
  String employerMissingRequired(String fields) {
    return 'Ещё нужно: $fields';
  }

  @override
  String get dashboardProfileTitle => 'Заполните профиль компании';

  @override
  String get dashboardProfileMissing => 'Пока ничего не заполнено';

  @override
  String dashboardProfileIncomplete(int percent) {
    return 'Заполнено $percent% — для вакансий и поиска кандидатов нужно всё';
  }

  @override
  String get adminDictionariesTitle => 'Справочники';

  @override
  String get adminDictionariesBody =>
      'Всё, что предлагают списки выбора. Ничего не удаляется — элемент уходит из списков и остаётся читаемым в записях, где он использовался.';

  @override
  String adminDictionaryActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count используются',
      many: '$count используются',
      few: '$count используются',
      one: '$count используется',
    );
    return '$_temp0';
  }

  @override
  String get adminDictionarySearch => 'Найти элемент';

  @override
  String get adminDictionarySearchHint => 'По названию или коду';

  @override
  String get adminDictionaryAdd => 'Добавить элемент';

  @override
  String get adminDictionaryCreate => 'Добавить';

  @override
  String get adminDictionaryCode => 'Код';

  @override
  String get adminDictionaryCodeHint => 'welder';

  @override
  String get adminDictionaryCodeNote =>
      'Никому не показывается. Названия можно менять на любом языке, а это — нет.';

  @override
  String get adminDictionaryLabels => 'Названия';

  @override
  String get adminDictionaryLabelsNote =>
      'Прежде чем элемент можно использовать, нужны все четыре. Меньше — это черновик, который в списки не попадёт.';

  @override
  String adminDictionaryDraftNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось написать на $count языках — будет добавлен как черновик',
      many: 'Осталось написать на $count языках — будет добавлен как черновик',
      few: 'Осталось написать на $count языках — будет добавлен как черновик',
      one: 'Осталось написать на $count языке — будет добавлен как черновик',
    );
    return '$_temp0';
  }

  @override
  String get adminDictionaryRetired => 'Не используется';

  @override
  String get adminDictionaryMerged => 'Объединён';

  @override
  String get adminDictionaryMergedBody =>
      'Он указывает на элемент, в который был объединён, поэтому всё, что его использовало, по-прежнему читается. Делать с ним больше нечего.';

  @override
  String get adminDictionaryActivate => 'Ввести в использование';

  @override
  String get adminDictionaryRetire => 'Вывести из использования';

  @override
  String get adminDictionaryLabelsMissing =>
      'Пока у него нет названия на всех четырёх языках, использовать его нельзя.';

  @override
  String get adminDictionaryMerge => 'Объединить дубликат';

  @override
  String get adminDictionaryMergeBody =>
      'Уходит именно этот элемент. Он выводится из использования и указывает на выбранный вами, поэтому всё, что его использовало, по-прежнему читается.';

  @override
  String get adminDictionaryMergeInto => 'Оставить вместо него';

  @override
  String get adminDictionaryMergeConfirm => 'Объединить';

  @override
  String get adminDictionaryEmpty => 'Пока пусто';

  @override
  String get adminDictionaryEmptyBody =>
      'Добавьте первый элемент — он появится в списках выбора, как только у него будут все четыре названия.';

  @override
  String get adminDictionaryNoMatch => 'Совпадений нет';

  @override
  String get adminDictionaryNoMatchBody =>
      'Поиск смотрит на названия и коды. Выведенный из использования элемент тоже есть в этом списке.';

  @override
  String get dictTypeOccupation => 'Профессии';

  @override
  String get dictTypeSkill => 'Навыки';

  @override
  String get dictTypeIndustry => 'Отрасли';

  @override
  String get dictTypeRegion => 'Регионы и районы';

  @override
  String get dictTypeLanguage => 'Языки';

  @override
  String get dictTypeEmploymentType => 'Типы занятости';

  @override
  String get dictTypeWorkFormat => 'Форматы работы';

  @override
  String get dictTypeShift => 'Смены';

  @override
  String get dictTypeAttribute => 'Атрибуты требований';

  @override
  String get dictTypeSkillLevel => 'Уровни навыков';

  @override
  String get dictTypeLanguageLevel => 'Уровни языка';

  @override
  String get dictTypeEducationLevel => 'Уровни образования';

  @override
  String get dictTypeSpecialization => 'Специальности';

  @override
  String get dictTypePaymentPeriod => 'Периоды оплаты';

  @override
  String get dictTypeFilePurpose => 'Назначения файлов';

  @override
  String get dictTypeGender => 'Пол';

  @override
  String get dictTypeRestrictionJustification => 'Причины ограничений';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsAll => 'Все';

  @override
  String get notificationsUnread => 'Непрочитанные';

  @override
  String get notificationsMarkAllRead => 'Отметить все';

  @override
  String notificationsMarkedRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отмечено как прочитанные',
      many: '$count отмечено как прочитанные',
      few: '$count отмечены как прочитанные',
      one: '$count отмечено как прочитанное',
    );
    return '$_temp0';
  }

  @override
  String get notificationsNothingUnread => 'Всё уже было прочитано';

  @override
  String get notificationsEmpty => 'Пока ничего';

  @override
  String get notificationsEmptyBody =>
      'Здесь появляются ответы на ваши отклики, приглашения, сообщения и собеседования.';

  @override
  String get notificationsNoUnread => 'Непрочитанных нет';

  @override
  String get notificationsNoUnreadBody =>
      'Всё здесь прочитано. Чтобы посмотреть назад, переключитесь на «Все».';

  @override
  String get notificationsSettings => 'О чём вас уведомлять';

  @override
  String get notificationsSettingsBody =>
      'Если выключить категорию, она вообще перестанет записываться — пропущенные здесь потом не найдутся.';

  @override
  String get notificationsAlwaysOn =>
      'Уведомления о безопасности и аккаунте приходят всегда';

  @override
  String get notificationsApplications => 'Отклики';

  @override
  String get notificationsInvitations => 'Приглашения';

  @override
  String get notificationsMessages => 'Сообщения';

  @override
  String get notificationsInterviews => 'Собеседования';

  @override
  String get notificationsAccount => 'Аккаунт';

  @override
  String get notificationsOther => 'Другое';

  @override
  String get pushChannelName => 'Уведомления';

  @override
  String get pushChannelDescription =>
      'Ответы на ваши отклики, приглашения, сообщения и собеседования.';
}
