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
}
