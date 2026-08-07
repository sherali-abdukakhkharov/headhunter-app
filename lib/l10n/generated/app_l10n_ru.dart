// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HeadHunter';

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
}
