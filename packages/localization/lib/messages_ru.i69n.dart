// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'ru';
String get _localeName => 'ru';

String _plural(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.plural(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _ordinal(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.ordinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _cardinal(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.cardinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);

class Messages_ru extends Messages {
  const Messages_ru();
  AppMessages_ru get app => AppMessages_ru(this);
  GenericMessages_ru get generic => GenericMessages_ru(this);
  CommonMessages_ru get common => CommonMessages_ru(this);
  AuthMessages_ru get auth => AuthMessages_ru(this);
  ProfileMessages_ru get profile => ProfileMessages_ru(this);
  NavMessages_ru get nav => NavMessages_ru(this);
  NotificationsMessages_ru get notifications => NotificationsMessages_ru(this);
  ErrorsMessages_ru get errors => ErrorsMessages_ru(this);
  ValidationMessages_ru get validation => ValidationMessages_ru(this);
  FilesMessages_ru get files => FilesMessages_ru(this);
  DeveloperMessages_ru get developer => DeveloperMessages_ru(this);
  ClockMessages_ru get clock => ClockMessages_ru(this);
  SyncMessages_ru get sync => SyncMessages_ru(this);
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'app':
        return app;
      case 'generic':
        return generic;
      case 'common':
        return common;
      case 'auth':
        return auth;
      case 'profile':
        return profile;
      case 'nav':
        return nav;
      case 'notifications':
        return notifications;
      case 'errors':
        return errors;
      case 'validation':
        return validation;
      case 'files':
        return files;
      case 'developer':
        return developer;
      case 'clock':
        return clock;
      case 'sync':
        return sync;
      default:
        return super[key];
    }
  }
}

class AppMessages_ru extends AppMessages {
  final Messages_ru _parent;
  const AppMessages_ru(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description => "Перекидные часы, таймер и секундомер без рекламы.";
  String get welcome_to_app => "Добро пожаловать в QuietFlip!";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'name':
        return name;
      case 'description':
        return description;
      case 'welcome_to_app':
        return welcome_to_app;
      default:
        return super[key];
    }
  }
}

class GenericMessages_ru extends GenericMessages {
  final Messages_ru _parent;
  const GenericMessages_ru(this._parent) : super(_parent);
  String get ok => "ОК";
  String get cancel => "Отмена";
  String get save => "Сохранить";
  String get delete => "Удалить";
  String get edit => "Изменить";
  String get update => "Обновить";
  String get submit => "Отправить";
  String get close => "Закрыть";
  String get back => "Назад";
  String get next => "Далее";
  String get previous => "Назад";
  String get done => "Готово";
  String get loading => "Загрузка…";
  String get error => "Ошибка";
  String get success => "Готово";
  String get warning => "Внимание";
  String get info => "Информация";
  String get retry => "Повторить";
  String get refresh => "Обновить";
  String get yes => "Да";
  String get no => "Нет";
  String get add => "+ Добавить";
  String get try_again => "Повторить";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'ok':
        return ok;
      case 'cancel':
        return cancel;
      case 'save':
        return save;
      case 'delete':
        return delete;
      case 'edit':
        return edit;
      case 'update':
        return update;
      case 'submit':
        return submit;
      case 'close':
        return close;
      case 'back':
        return back;
      case 'next':
        return next;
      case 'previous':
        return previous;
      case 'done':
        return done;
      case 'loading':
        return loading;
      case 'error':
        return error;
      case 'success':
        return success;
      case 'warning':
        return warning;
      case 'info':
        return info;
      case 'retry':
        return retry;
      case 'refresh':
        return refresh;
      case 'yes':
        return yes;
      case 'no':
        return no;
      case 'add':
        return add;
      case 'try_again':
        return try_again;
      default:
        return super[key];
    }
  }
}

class CommonMessages_ru extends CommonMessages {
  final Messages_ru _parent;
  const CommonMessages_ru(this._parent) : super(_parent);
  String get week => "Неделя";
  String get month => "Месяц";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'week':
        return week;
      case 'month':
        return month;
      default:
        return super[key];
    }
  }
}

class AuthMessages_ru extends AuthMessages {
  final Messages_ru _parent;
  const AuthMessages_ru(this._parent) : super(_parent);
  String get register => "Регистрация";
  String get sign_in => "Войти";
  String get sign_out => "Выйти";
  String get dont_have_account => "Нет аккаунта? ";
  String get already_have_account => "Уже есть аккаунт? ";
  String get sign_out_confirmation => "Выйти из аккаунта?";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'register':
        return register;
      case 'sign_in':
        return sign_in;
      case 'sign_out':
        return sign_out;
      case 'dont_have_account':
        return dont_have_account;
      case 'already_have_account':
        return already_have_account;
      case 'sign_out_confirmation':
        return sign_out_confirmation;
      default:
        return super[key];
    }
  }
}

class ProfileMessages_ru extends ProfileMessages {
  final Messages_ru _parent;
  const ProfileMessages_ru(this._parent) : super(_parent);
  String get profile => "Профиль";
  String get settings => "Настройки";
  String get account => "Аккаунт";
  String get personal_info => "Личные данные";
  String get privacy_settings => "Конфиденциальность";
  String get name => "Имя";
  String get email_address => "Эл. почта";
  String get phone_number => "Номер телефона";
  String get date_of_birth => "Дата рождения";
  String get delete_confirmation => "Подтверждение удаления";
  String get delete_confirmation_message =>
      "Удалить этот элемент? Это действие нельзя отменить.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'profile':
        return profile;
      case 'settings':
        return settings;
      case 'account':
        return account;
      case 'personal_info':
        return personal_info;
      case 'privacy_settings':
        return privacy_settings;
      case 'name':
        return name;
      case 'email_address':
        return email_address;
      case 'phone_number':
        return phone_number;
      case 'date_of_birth':
        return date_of_birth;
      case 'delete_confirmation':
        return delete_confirmation;
      case 'delete_confirmation_message':
        return delete_confirmation_message;
      default:
        return super[key];
    }
  }
}

class NavMessages_ru extends NavMessages {
  final Messages_ru _parent;
  const NavMessages_ru(this._parent) : super(_parent);
  String get home => "Главная";
  String get dashboard => "Панель";
  String get explore => "Обзор";
  String get explore_placeholder =>
      "Ваша вторая вкладка. Замените её настоящей функцией.";
  String get profile => "Профиль";
  String get settings => "Настройки";
  String get notifications => "Уведомления";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'home':
        return home;
      case 'dashboard':
        return dashboard;
      case 'explore':
        return explore;
      case 'explore_placeholder':
        return explore_placeholder;
      case 'profile':
        return profile;
      case 'settings':
        return settings;
      case 'notifications':
        return notifications;
      default:
        return super[key];
    }
  }
}

class NotificationsMessages_ru extends NotificationsMessages {
  final Messages_ru _parent;
  const NotificationsMessages_ru(this._parent) : super(_parent);
  String get title => "Уведомления";
  String get mark_as_read => "Отметить как прочитанное";
  String get mark_all_read => "Прочитать все";
  String get delete => "Удалить";
  String get filter_all => "Все";
  String get filter_unread => "Непрочитанные";
  String get filter_read => "Прочитанные";
  String get type_reminder => "Напоминание";
  String get type_alert => "Оповещение";
  String get type_promotion => "Акция";
  String get type_system => "Система";
  String get type_custom => "Другое";
  String get empty_title => "Нет уведомлений";
  String get empty_description =>
      "Всё прочитано! Новые уведомления появятся здесь.";
  String get delete_confirmation_title => "Удалить уведомление?";
  String get delete_confirmation_message =>
      "Это уведомление будет навсегда удалено из списка.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'title':
        return title;
      case 'mark_as_read':
        return mark_as_read;
      case 'mark_all_read':
        return mark_all_read;
      case 'delete':
        return delete;
      case 'filter_all':
        return filter_all;
      case 'filter_unread':
        return filter_unread;
      case 'filter_read':
        return filter_read;
      case 'type_reminder':
        return type_reminder;
      case 'type_alert':
        return type_alert;
      case 'type_promotion':
        return type_promotion;
      case 'type_system':
        return type_system;
      case 'type_custom':
        return type_custom;
      case 'empty_title':
        return empty_title;
      case 'empty_description':
        return empty_description;
      case 'delete_confirmation_title':
        return delete_confirmation_title;
      case 'delete_confirmation_message':
        return delete_confirmation_message;
      default:
        return super[key];
    }
  }
}

class ErrorsMessages_ru extends ErrorsMessages {
  final Messages_ru _parent;
  const ErrorsMessages_ru(this._parent) : super(_parent);
  String get network_error => "Ошибка сети. Проверьте подключение.";
  String get unknown_error => "Произошла неизвестная ошибка.";
  String get validation_error =>
      "Проверьте введённые данные и повторите попытку.";
  String get server_error => "Ошибка сервера. Повторите попытку позже.";
  String get default_error_message =>
      "Ой! Что-то пошло не так. Повторите попытку.";
  String get user_not_found =>
      "Пользователь не найден. Проверьте данные для входа.";
  String get default_error_description =>
      "При обработке запроса произошла ошибка. Приносим извинения за неудобства. Повторите попытку позже или обратитесь в поддержку, если проблема не исчезнет.";
  String get page_not_found => "Страница не найдена";
  String get page_not_found_description =>
      "Запрошенная страница не существует.";
  String get unexpected_error => "Произошла непредвиденная ошибка.";
  String get redirect_error => "Ошибка перенаправления";
  String get bad_request => "Неверный запрос. Проверьте введённые данные.";
  String get unauthorized => "Требуется вход. Войдите снова.";
  String get forbidden => "Доступ запрещён. У вас нет разрешения.";
  String get not_found => "Запрошенный ресурс не найден.";
  String get conflict =>
      "Конфликт данных. Обновите страницу и повторите попытку.";
  String get unprocessable_entity =>
      "Неверный формат данных. Проверьте введённые данные.";
  String get internal_server_error =>
      "Ошибка сервера. Повторите попытку позже.";
  String get connection_timeout =>
      "Время подключения истекло. Проверьте интернет.";
  String get receive_timeout =>
      "Время ожидания запроса истекло. Повторите попытку.";
  String get send_timeout => "Время загрузки истекло. Повторите попытку.";
  String get no_internet => "Нет подключения к интернету. Проверьте сеть.";
  String get unknown_network => "Произошла ошибка сети. Повторите попытку.";
  String format_exception_message(String code, String postfix) =>
      "Эти данные в чужом костюме, я их не узнаю [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Это не те данные, что я ждал, не могу их обработать [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Хм, не могу найти этот элемент в списке [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Ой! Это число далеко за пределами моей зоны комфорта [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Эй! С переданными данными что-то не так [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Я немного запутался, что сейчас делать [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Эта функция ещё в разработке [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Извините, я пока не умею это делать [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Ого! Слишком много всего сразу [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Голова переполнена! Нужно освободить место [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Я застрял в цикле, и у меня кружится голова [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Случилось что-то неожиданное, но не волнуйтесь [$code] $postfix";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'network_error':
        return network_error;
      case 'unknown_error':
        return unknown_error;
      case 'validation_error':
        return validation_error;
      case 'server_error':
        return server_error;
      case 'default_error_message':
        return default_error_message;
      case 'user_not_found':
        return user_not_found;
      case 'default_error_description':
        return default_error_description;
      case 'page_not_found':
        return page_not_found;
      case 'page_not_found_description':
        return page_not_found_description;
      case 'unexpected_error':
        return unexpected_error;
      case 'redirect_error':
        return redirect_error;
      case 'bad_request':
        return bad_request;
      case 'unauthorized':
        return unauthorized;
      case 'forbidden':
        return forbidden;
      case 'not_found':
        return not_found;
      case 'conflict':
        return conflict;
      case 'unprocessable_entity':
        return unprocessable_entity;
      case 'internal_server_error':
        return internal_server_error;
      case 'connection_timeout':
        return connection_timeout;
      case 'receive_timeout':
        return receive_timeout;
      case 'send_timeout':
        return send_timeout;
      case 'no_internet':
        return no_internet;
      case 'unknown_network':
        return unknown_network;
      case 'format_exception_message':
        return format_exception_message;
      case 'type_error_message':
        return type_error_message;
      case 'index_error_message':
        return index_error_message;
      case 'range_error_message':
        return range_error_message;
      case 'argument_error_message':
        return argument_error_message;
      case 'state_error_message':
        return state_error_message;
      case 'unimplemented_error_message':
        return unimplemented_error_message;
      case 'unsupported_error_message':
        return unsupported_error_message;
      case 'concurrent_modification_error_message':
        return concurrent_modification_error_message;
      case 'out_of_memory_error_message':
        return out_of_memory_error_message;
      case 'stack_overflow_error_message':
        return stack_overflow_error_message;
      case 'unknown_error_message':
        return unknown_error_message;
      default:
        return super[key];
    }
  }
}

class ValidationMessages_ru extends ValidationMessages {
  final Messages_ru _parent;
  const ValidationMessages_ru(this._parent) : super(_parent);
  String get required_field => "Обязательное поле";
  String get invalid_email => "Введите правильный адрес эл. почты";
  String get password_too_short =>
      "Пароль должен содержать не менее 8 символов";
  String get passwords_dont_match => "Пароли не совпадают";
  String invalid_key_config(String of, String key) =>
      "Неверная настройка $key в $of. Проверьте настройки.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'required_field':
        return required_field;
      case 'invalid_email':
        return invalid_email;
      case 'password_too_short':
        return password_too_short;
      case 'passwords_dont_match':
        return passwords_dont_match;
      case 'invalid_key_config':
        return invalid_key_config;
      default:
        return super[key];
    }
  }
}

class FilesMessages_ru extends FilesMessages {
  final Messages_ru _parent;
  const FilesMessages_ru(this._parent) : super(_parent);
  String get info_title => "Сведения о файле";
  String get name => "Имя файла";
  String get type => "Тип файла";
  String get extension => "Расширение";
  String get size => "Размер файла";
  String get path => "Путь к файлу";
  String get copy_hint => "Нажмите на поле, чтобы скопировать его";
  String copied(String field) => "$field: скопировано";
  String image_type(String format) => "Изображение $format";
  String get image_file => "Файл изображения";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'info_title':
        return info_title;
      case 'name':
        return name;
      case 'type':
        return type;
      case 'extension':
        return extension;
      case 'size':
        return size;
      case 'path':
        return path;
      case 'copy_hint':
        return copy_hint;
      case 'copied':
        return copied;
      case 'image_type':
        return image_type;
      case 'image_file':
        return image_file;
      default:
        return super[key];
    }
  }
}

class DeveloperMessages_ru extends DeveloperMessages {
  final Messages_ru _parent;
  const DeveloperMessages_ru(this._parent) : super(_parent);
  String get no_viewer => "У этого журнала нет интерактивного просмотра.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'no_viewer':
        return no_viewer;
      default:
        return super[key];
    }
  }
}

class ClockMessages_ru extends ClockMessages {
  final Messages_ru _parent;
  const ClockMessages_ru(this._parent) : super(_parent);
  String get clock => "Часы";
  String get stopwatch => "Секундомер";
  String get modes => "Режим";
  String get settings => "Настройки";
  String get times_up => "Время вышло";
  String get timer_finished_title => "Время вышло";
  String get timer_finished_body => "Таймер QuietFlip завершён.";
  String get alerts_channel => "Сигналы таймера";
  String get show_controls =>
      "Коснитесь экрана или двиньте мышь, чтобы показать кнопки";
  String get theme => "Тема";
  String get theme_light => "Светлая";
  String get use_24h => "24-часовой формат";
  String get show_seconds => "Показывать секунды";
  String get sound_tick_group => "Тиканье";
  String get sound_tick_hint => "звучит при каждом перевороте";
  String get sound_alarm_group => "Сигнал";
  String get sound_alarm_hint => "повторяется до отключения, макс. 60 с";
  String get tick_sound => "Звук тиканья";
  String get tick_sound_description =>
      "Тихий звук при каждом перевороте карточки";
  String get alarm_sound => "Звук сигнала";
  String get alarm_sound_description =>
      "Звучит по окончании таймера или фазы Pomodoro";
  String get tick_classic => "Классика";
  String get tick_classic_mood => "мягкий щелчок";
  String get tick_split_flap => "Табло";
  String get tick_split_flap_mood => "шелест флажков";
  String get tick_clockwork => "Механизм";
  String get tick_clockwork_mood => "тиканье часов";
  String get tick_woodblock => "Коробочка";
  String get tick_woodblock_mood => "глухой стук";
  String get tick_digital => "Цифровой";
  String get tick_digital_mood => "чистый сигнал";
  String get alarm_chime => "Перезвон";
  String get alarm_chime_mood => "два тона";
  String get alarm_bell => "Колокол";
  String get alarm_bell_mood => "удар колокола";
  String get alarm_beeps => "Писк";
  String get alarm_beeps_mood => "прикроватный";
  String get alarm_rising => "Нарастающий";
  String get alarm_rising_mood => "маримба";
  String get alarm_ring => "Звонок";
  String get alarm_ring_mood => "два звонка";
  String get system_notifications => "Системные уведомления";
  String get system_notifications_description =>
      "Уведомление об окончании таймера, даже если QuietFlip работает в фоне.";
  String get permission_denied =>
      "Уведомления для QuietFlip отключены. Пока приложение открыто, сигнал всё равно будет виден и слышен.";
  String get web_closed_tab_note =>
      "В браузере сигналы работают, только пока эта вкладка открыта.";
  String get keep_screen_awake => "Не выключать экран";
  String get keep_screen_awake_description =>
      "Экран не гаснет, пока показаны часы.";
  String current_time(String time) => "Текущее время $time";
  String time_remaining(String time) => "Осталось $time";
  String elapsed(String time) => "Прошло $time";
  String get digit_brightness => "Яркость цифр";
  String percent(String value) => "$value %";
  String get subtle_movement => "Лёгкое смещение";
  String get subtle_movement_description =>
      "В полноэкранном режиме часы каждую минуту сдвигаются на несколько пикселей, чтобы одни и те же пиксели не светились всю ночь. Снижает, но не исключает риск выгорания.";
  String get full_screen_note =>
      "Полноэкранный режим скрывает кнопки, пока QuietFlip открыт. Приложение должно оставаться открытым. Это не экран блокировки и не заставка.";
  String get show_date => "Показывать дату";
  String current_time_and_date(String time, String date) =>
      "Текущее время $time, $date";
  String get orientation => "Ориентация";
  String get orientation_auto => "Авто";
  String get orientation_landscape => "Альбомная";
  String get orientation_portrait => "Книжная";
  String get settings_card_size => "Размер карточек";
  String get card_size_small => "Маленький";
  String get card_size_medium => "Средний";
  String get card_size_large => "Большой";
  String get settings_corners => "Углы";
  String get corners_square => "Прямые";
  String get corners_round => "Скруглённые";
  String corners_value(String value) => "$value пкс";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Фокус · Раунд $round";
  String pomodoro_break(int round) => "Перерыв · Раунд $round";
  String get pomodoro_focus_done => "Фокус завершён. Время перерыва.";
  String get pomodoro_break_done => "Перерыв окончен. Снова за работу.";
  String get start_focus => "Начать фокус";
  String get start_break => "Начать перерыв";
  String get skins_title => "Скины";
  String get skins_customize => "Настроить";
  String skins_customize_named(String name) => "Настроить «$name»";
  String get skins_done => "Готово";
  String get skins_in_use => "Используется";
  String get skins_yours => "Ваши скины";
  String get skins_classic => "Классика";
  String get skins_bold => "Жирные";
  String get skins_type => "Шрифт";
  String get skins_new => "Новый скин";
  String get skins_from_current => "Из текущего";
  String get customize_title => "Настройка скина";
  String get customize_name => "Название";
  String customize_copy_name(String name) => "$name (копия)";
  String get customize_font => "Шрифт";
  String get customize_digits => "Цифры";
  String get customize_card => "Карточка";
  String get customize_ground => "Фон";
  String get customize_custom_colour => "Свой цвет";
  String get customize_hex_hint => "Hex, например #FF7A00";
  String get customize_hex_invalid =>
      "Введите шесть hex-цифр, например #FF7A00.";
  String get customize_apply => "Применить";
  String get customize_low_contrast => "Цифры могут плохо читаться.";
  String get customize_details => "Детали";
  String get customize_seconds => "Секунды";
  String get customize_seconds_off => "Выкл.";
  String get customize_seconds_badge => "Мелко";
  String get customize_seconds_cards => "Карточки";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Скрыто";
  String get customize_meridiem_left => "Внутри";
  String get customize_meridiem_right => "Рядом";
  String get customize_save => "Сохранить скин";
  String get customize_reset => "Сбросить";
  String get customize_delete => "Удалить скин";
  String get skin_mono => "Моно";
  String get skin_paper => "Бумага";
  String get skin_rose => "Роза";
  String get skin_violet => "Фиалка";
  String get skin_amber => "Янтарь";
  String get skin_signal => "Сигнал";
  String get skin_field => "Поле";
  String get skin_mint => "Мята";
  String get skin_cyan => "Циан";
  String get skin_taxi => "Такси";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Афиша";
  String get skin_terminal => "Терминал";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Антиква";
  String get skin_orbit => "Орбита";
  String get skin_nightstand => "Тумбочка";
  String get skin_studio => "Студия";
  String get skin_arcade => "Аркада";
  String get skin_railway => "Вокзал";
  String get skin_desk => "Стол";
  String get skin_neon => "Неон";
  String get skin_minimal => "Минимал";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Часы";
  String get mode_stopwatch => "Секундомер";
  String get action_start => "Старт";
  String get action_pause => "Пауза";
  String get action_resume => "Продолжить";
  String get action_reset => "Сброс";
  String get action_restart => "Заново";
  String get action_done => "Готово";
  String get action_skins => "Скины";
  String get action_settings => "Настройки";
  String get action_rotation => "Поворот экрана";
  String get action_timer_settings => "Настройки таймера";
  String preset_minutes(int minutes) => "$minutes мин";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Таймер на $minutes мин";
  String preset_spoken_seconds(int seconds) => "Таймер на $seconds с";
  String preset_spoken_both(int minutes, int seconds) =>
      "Таймер на $minutes мин $seconds с";
  String get action_lap => "Круг";
  String lap_label(int number, String time) => "Круг $number  $time";
  String brightness_value(String percent) => "$percent %";
  String get settings_appearance => "Оформление";
  String get settings_clock => "Часы";
  String get settings_gestures => "Жесты";
  String get settings_timers => "Таймеры";
  String get settings_sound => "Звук и сигналы";
  String get settings_awake => "Без сна";
  String get settings_shortcuts => "Сочетания клавиш";
  String get settings_about => "О приложении";
  String get theme_dark => "Тёмная";
  String get theme_system => "Как в системе";
  String get gesture_swipes => "Свайпы";
  String get gesture_brightness => "Свайп вверх или вниз меняет яркость";
  String get gesture_modes => "Свайп в сторону меняет режим";
  String get gesture_footer =>
      "Проводите в любом месте часов. На Mac, Windows и в браузере меняется яркость цифр, а не экрана.";
  String get gesture_controls => "Кнопки";
  String get gesture_tap => "Касание показывает кнопки";
  String get gesture_idle => "Скрывать кнопки через";
  String gesture_idle_seconds(int seconds) => "$seconds с";
  String get gesture_idle_never => "Никогда";
  String get gesture_controls_footer =>
      "Кнопки сжимаются в точку, а затем исчезают.";
  String get timers_default => "Таймер по умолчанию";
  String get timers_start_runs => "Кнопка «Старт» запускает";
  String get timers_presets => "Шаблоны";
  String get timers_add => "Добавить таймер";
  String get timers_limit_footer =>
      "На острове помещается шесть таймеров. Удалите один, чтобы добавить новый.";
  String timers_delete(String timer) => "Удалить $timer";
  String get timers_duplicate => "Такой таймер уже есть.";
  String get timers_picker_minutes => "Минуты";
  String get timers_picker_seconds => "Секунды";
  String get skins_view_all => "Все";
  String get timers_pomodoro_focus => "Фокус";
  String get timers_pomodoro_break => "Перерыв";
  String timers_minutes(int minutes) => "$minutes мин";
  String get sound_footer =>
      "Сигнал в приложении звучит всегда, даже если уведомления выключены.";
  String get shortcuts_touch => "Касания";
  String get shortcuts_keyboard => "Клавиатура";
  String get touch_controls => "Показать или скрыть кнопки";
  String get shortcut_off => "Выкл.";
  String get key_start_pause => "Старт или пауза";
  String get key_change_mode => "Сменить режим";
  String get key_brightness => "Яркость";
  String get key_show_seconds => "Показывать секунды";
  String get key_full_screen => "Во весь экран";
  String get key_hide_controls => "Скрыть кнопки";
  String get key_dim => "Приглушить цифры";
  String get key_lap => "Круг (секундомер)";
  String get key_rotation => "Поворот экрана";
  String get keycap_space => "Пробел";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Лицензии";
  String get about_privacy => "Конфиденциальность";
  String get about_privacy_value =>
      "Без рекламы. Аккаунт не обязателен. Анонимная статистика использования помогает нам улучшать приложение.";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'clock':
        return clock;
      case 'stopwatch':
        return stopwatch;
      case 'modes':
        return modes;
      case 'settings':
        return settings;
      case 'times_up':
        return times_up;
      case 'timer_finished_title':
        return timer_finished_title;
      case 'timer_finished_body':
        return timer_finished_body;
      case 'alerts_channel':
        return alerts_channel;
      case 'show_controls':
        return show_controls;
      case 'theme':
        return theme;
      case 'theme_light':
        return theme_light;
      case 'use_24h':
        return use_24h;
      case 'show_seconds':
        return show_seconds;
      case 'sound_tick_group':
        return sound_tick_group;
      case 'sound_tick_hint':
        return sound_tick_hint;
      case 'sound_alarm_group':
        return sound_alarm_group;
      case 'sound_alarm_hint':
        return sound_alarm_hint;
      case 'tick_sound':
        return tick_sound;
      case 'tick_sound_description':
        return tick_sound_description;
      case 'alarm_sound':
        return alarm_sound;
      case 'alarm_sound_description':
        return alarm_sound_description;
      case 'tick_classic':
        return tick_classic;
      case 'tick_classic_mood':
        return tick_classic_mood;
      case 'tick_split_flap':
        return tick_split_flap;
      case 'tick_split_flap_mood':
        return tick_split_flap_mood;
      case 'tick_clockwork':
        return tick_clockwork;
      case 'tick_clockwork_mood':
        return tick_clockwork_mood;
      case 'tick_woodblock':
        return tick_woodblock;
      case 'tick_woodblock_mood':
        return tick_woodblock_mood;
      case 'tick_digital':
        return tick_digital;
      case 'tick_digital_mood':
        return tick_digital_mood;
      case 'alarm_chime':
        return alarm_chime;
      case 'alarm_chime_mood':
        return alarm_chime_mood;
      case 'alarm_bell':
        return alarm_bell;
      case 'alarm_bell_mood':
        return alarm_bell_mood;
      case 'alarm_beeps':
        return alarm_beeps;
      case 'alarm_beeps_mood':
        return alarm_beeps_mood;
      case 'alarm_rising':
        return alarm_rising;
      case 'alarm_rising_mood':
        return alarm_rising_mood;
      case 'alarm_ring':
        return alarm_ring;
      case 'alarm_ring_mood':
        return alarm_ring_mood;
      case 'system_notifications':
        return system_notifications;
      case 'system_notifications_description':
        return system_notifications_description;
      case 'permission_denied':
        return permission_denied;
      case 'web_closed_tab_note':
        return web_closed_tab_note;
      case 'keep_screen_awake':
        return keep_screen_awake;
      case 'keep_screen_awake_description':
        return keep_screen_awake_description;
      case 'current_time':
        return current_time;
      case 'time_remaining':
        return time_remaining;
      case 'elapsed':
        return elapsed;
      case 'digit_brightness':
        return digit_brightness;
      case 'percent':
        return percent;
      case 'subtle_movement':
        return subtle_movement;
      case 'subtle_movement_description':
        return subtle_movement_description;
      case 'full_screen_note':
        return full_screen_note;
      case 'show_date':
        return show_date;
      case 'current_time_and_date':
        return current_time_and_date;
      case 'orientation':
        return orientation;
      case 'orientation_auto':
        return orientation_auto;
      case 'orientation_landscape':
        return orientation_landscape;
      case 'orientation_portrait':
        return orientation_portrait;
      case 'settings_card_size':
        return settings_card_size;
      case 'card_size_small':
        return card_size_small;
      case 'card_size_medium':
        return card_size_medium;
      case 'card_size_large':
        return card_size_large;
      case 'settings_corners':
        return settings_corners;
      case 'corners_square':
        return corners_square;
      case 'corners_round':
        return corners_round;
      case 'corners_value':
        return corners_value;
      case 'pomodoro':
        return pomodoro;
      case 'pomodoro_focus':
        return pomodoro_focus;
      case 'pomodoro_break':
        return pomodoro_break;
      case 'pomodoro_focus_done':
        return pomodoro_focus_done;
      case 'pomodoro_break_done':
        return pomodoro_break_done;
      case 'start_focus':
        return start_focus;
      case 'start_break':
        return start_break;
      case 'skins_title':
        return skins_title;
      case 'skins_customize':
        return skins_customize;
      case 'skins_customize_named':
        return skins_customize_named;
      case 'skins_done':
        return skins_done;
      case 'skins_in_use':
        return skins_in_use;
      case 'skins_yours':
        return skins_yours;
      case 'skins_classic':
        return skins_classic;
      case 'skins_bold':
        return skins_bold;
      case 'skins_type':
        return skins_type;
      case 'skins_new':
        return skins_new;
      case 'skins_from_current':
        return skins_from_current;
      case 'customize_title':
        return customize_title;
      case 'customize_name':
        return customize_name;
      case 'customize_copy_name':
        return customize_copy_name;
      case 'customize_font':
        return customize_font;
      case 'customize_digits':
        return customize_digits;
      case 'customize_card':
        return customize_card;
      case 'customize_ground':
        return customize_ground;
      case 'customize_custom_colour':
        return customize_custom_colour;
      case 'customize_hex_hint':
        return customize_hex_hint;
      case 'customize_hex_invalid':
        return customize_hex_invalid;
      case 'customize_apply':
        return customize_apply;
      case 'customize_low_contrast':
        return customize_low_contrast;
      case 'customize_details':
        return customize_details;
      case 'customize_seconds':
        return customize_seconds;
      case 'customize_seconds_off':
        return customize_seconds_off;
      case 'customize_seconds_badge':
        return customize_seconds_badge;
      case 'customize_seconds_cards':
        return customize_seconds_cards;
      case 'customize_meridiem':
        return customize_meridiem;
      case 'customize_meridiem_hidden':
        return customize_meridiem_hidden;
      case 'customize_meridiem_left':
        return customize_meridiem_left;
      case 'customize_meridiem_right':
        return customize_meridiem_right;
      case 'customize_save':
        return customize_save;
      case 'customize_reset':
        return customize_reset;
      case 'customize_delete':
        return customize_delete;
      case 'skin_mono':
        return skin_mono;
      case 'skin_paper':
        return skin_paper;
      case 'skin_rose':
        return skin_rose;
      case 'skin_violet':
        return skin_violet;
      case 'skin_amber':
        return skin_amber;
      case 'skin_signal':
        return skin_signal;
      case 'skin_field':
        return skin_field;
      case 'skin_mint':
        return skin_mint;
      case 'skin_cyan':
        return skin_cyan;
      case 'skin_taxi':
        return skin_taxi;
      case 'skin_bebas':
        return skin_bebas;
      case 'skin_anton':
        return skin_anton;
      case 'skin_oswald':
        return skin_oswald;
      case 'skin_shoulders':
        return skin_shoulders;
      case 'skin_poster':
        return skin_poster;
      case 'skin_terminal':
        return skin_terminal;
      case 'skin_grotesk':
        return skin_grotesk;
      case 'skin_serif':
        return skin_serif;
      case 'skin_orbit':
        return skin_orbit;
      case 'skin_nightstand':
        return skin_nightstand;
      case 'skin_studio':
        return skin_studio;
      case 'skin_arcade':
        return skin_arcade;
      case 'skin_railway':
        return skin_railway;
      case 'skin_desk':
        return skin_desk;
      case 'skin_neon':
        return skin_neon;
      case 'skin_minimal':
        return skin_minimal;
      case 'mode_pomodoro':
        return mode_pomodoro;
      case 'mode_clock':
        return mode_clock;
      case 'mode_stopwatch':
        return mode_stopwatch;
      case 'action_start':
        return action_start;
      case 'action_pause':
        return action_pause;
      case 'action_resume':
        return action_resume;
      case 'action_reset':
        return action_reset;
      case 'action_restart':
        return action_restart;
      case 'action_done':
        return action_done;
      case 'action_skins':
        return action_skins;
      case 'action_settings':
        return action_settings;
      case 'action_rotation':
        return action_rotation;
      case 'action_timer_settings':
        return action_timer_settings;
      case 'preset_minutes':
        return preset_minutes;
      case 'preset_minutes_seconds':
        return preset_minutes_seconds;
      case 'preset_pomodoro':
        return preset_pomodoro;
      case 'preset_spoken_minutes':
        return preset_spoken_minutes;
      case 'preset_spoken_seconds':
        return preset_spoken_seconds;
      case 'preset_spoken_both':
        return preset_spoken_both;
      case 'action_lap':
        return action_lap;
      case 'lap_label':
        return lap_label;
      case 'brightness_value':
        return brightness_value;
      case 'settings_appearance':
        return settings_appearance;
      case 'settings_clock':
        return settings_clock;
      case 'settings_gestures':
        return settings_gestures;
      case 'settings_timers':
        return settings_timers;
      case 'settings_sound':
        return settings_sound;
      case 'settings_awake':
        return settings_awake;
      case 'settings_shortcuts':
        return settings_shortcuts;
      case 'settings_about':
        return settings_about;
      case 'theme_dark':
        return theme_dark;
      case 'theme_system':
        return theme_system;
      case 'gesture_swipes':
        return gesture_swipes;
      case 'gesture_brightness':
        return gesture_brightness;
      case 'gesture_modes':
        return gesture_modes;
      case 'gesture_footer':
        return gesture_footer;
      case 'gesture_controls':
        return gesture_controls;
      case 'gesture_tap':
        return gesture_tap;
      case 'gesture_idle':
        return gesture_idle;
      case 'gesture_idle_seconds':
        return gesture_idle_seconds;
      case 'gesture_idle_never':
        return gesture_idle_never;
      case 'gesture_controls_footer':
        return gesture_controls_footer;
      case 'timers_default':
        return timers_default;
      case 'timers_start_runs':
        return timers_start_runs;
      case 'timers_presets':
        return timers_presets;
      case 'timers_add':
        return timers_add;
      case 'timers_limit_footer':
        return timers_limit_footer;
      case 'timers_delete':
        return timers_delete;
      case 'timers_duplicate':
        return timers_duplicate;
      case 'timers_picker_minutes':
        return timers_picker_minutes;
      case 'timers_picker_seconds':
        return timers_picker_seconds;
      case 'skins_view_all':
        return skins_view_all;
      case 'timers_pomodoro_focus':
        return timers_pomodoro_focus;
      case 'timers_pomodoro_break':
        return timers_pomodoro_break;
      case 'timers_minutes':
        return timers_minutes;
      case 'sound_footer':
        return sound_footer;
      case 'shortcuts_touch':
        return shortcuts_touch;
      case 'shortcuts_keyboard':
        return shortcuts_keyboard;
      case 'touch_controls':
        return touch_controls;
      case 'shortcut_off':
        return shortcut_off;
      case 'key_start_pause':
        return key_start_pause;
      case 'key_change_mode':
        return key_change_mode;
      case 'key_brightness':
        return key_brightness;
      case 'key_show_seconds':
        return key_show_seconds;
      case 'key_full_screen':
        return key_full_screen;
      case 'key_hide_controls':
        return key_hide_controls;
      case 'key_dim':
        return key_dim;
      case 'key_lap':
        return key_lap;
      case 'key_rotation':
        return key_rotation;
      case 'keycap_space':
        return keycap_space;
      case 'keycap_left_right':
        return keycap_left_right;
      case 'keycap_up_down':
        return keycap_up_down;
      case 'keycap_s':
        return keycap_s;
      case 'keycap_f':
        return keycap_f;
      case 'keycap_esc':
        return keycap_esc;
      case 'keycap_d':
        return keycap_d;
      case 'keycap_l':
        return keycap_l;
      case 'keycap_r':
        return keycap_r;
      case 'about_licenses':
        return about_licenses;
      case 'about_privacy':
        return about_privacy;
      case 'about_privacy_value':
        return about_privacy_value;
      default:
        return super[key];
    }
  }
}

class SyncMessages_ru extends SyncMessages {
  final Messages_ru _parent;
  const SyncMessages_ru(this._parent) : super(_parent);
  String get account => "Аккаунт";
  String get card_title_signed_out => "Настройки хранятся на этом устройстве";
  String get card_body_signed_out =>
      "Войдите, только если хотите перенести их на другие устройства.";
  String get card_title_on => "Синхронизация включена";
  String get card_title_off => "Синхронизация выключена";
  String card_last_synced(String when) => "Последняя синхронизация: $when";
  String get headline => "Настройки хранятся на этом устройстве";
  String get body =>
      "QuietFlip не требует аккаунта. Войдите, только если хотите видеть свои часы, скины и звуки на других устройствах.";
  String get sign_in => "Войти для синхронизации";
  String get sign_in_reason =>
      "Нужно только для синхронизации настроек между устройствами.";
  String get what_syncs => "Что синхронизируется";
  String get what_syncs_body =>
      "Тема, скины, звуки, настройки часов и таймеров.";
  String get stays_body =>
      "Остаётся на этом устройстве: яркость, поворот, уведомления и запущенный таймер.";
  String get sync_header => "Синхронизация";
  String get sync_settings => "Синхронизировать настройки";
  String get sync_settings_note =>
      "Ваши настройки будут на каждом устройстве, где вы вошли.";
  String get last_synced => "Последняя синхронизация";
  String get just_now => "Только что";
  String minutes_ago(int n) => "$n мин назад";
  String today_at(String time) => "Сегодня в $time";
  String get never => "Ещё нет";
  String get syncing => "Синхронизация…";
  String get waiting => "Ожидание подключения";
  String get off_note =>
      "Синхронизация выключена. Изменения остаются на этом устройстве.";
  String get failed_offline =>
      "Не удалось синхронизировать: нет подключения. Повторим, когда вы снова будете в сети.";
  String get failed_denied => "Не удалось синхронизировать: войдите снова.";
  String get failed_unknown =>
      "Не удалось синхронизировать. Повторите попытку.";
  String get try_again => "Повторить";
  String get sign_out_note =>
      "После выхода настройки останутся на этом устройстве.";
  String get delete_account => "Удалить аккаунт";
  String get delete_title => "Удалить аккаунт?";
  String get delete_body =>
      "Синхронизированные настройки будут удалены из облака. Настройки на этом устройстве останутся.";
  String get delete_recent_login => "Войдите снова, чтобы удалить аккаунт";
  String get delete_failed => "Не удалось удалить аккаунт. Повторите попытку.";
  String get provider_email => "Эл. почта";
  String get provider_google => "Google";
  String get provider_apple => "Apple";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'account':
        return account;
      case 'card_title_signed_out':
        return card_title_signed_out;
      case 'card_body_signed_out':
        return card_body_signed_out;
      case 'card_title_on':
        return card_title_on;
      case 'card_title_off':
        return card_title_off;
      case 'card_last_synced':
        return card_last_synced;
      case 'headline':
        return headline;
      case 'body':
        return body;
      case 'sign_in':
        return sign_in;
      case 'sign_in_reason':
        return sign_in_reason;
      case 'what_syncs':
        return what_syncs;
      case 'what_syncs_body':
        return what_syncs_body;
      case 'stays_body':
        return stays_body;
      case 'sync_header':
        return sync_header;
      case 'sync_settings':
        return sync_settings;
      case 'sync_settings_note':
        return sync_settings_note;
      case 'last_synced':
        return last_synced;
      case 'just_now':
        return just_now;
      case 'minutes_ago':
        return minutes_ago;
      case 'today_at':
        return today_at;
      case 'never':
        return never;
      case 'syncing':
        return syncing;
      case 'waiting':
        return waiting;
      case 'off_note':
        return off_note;
      case 'failed_offline':
        return failed_offline;
      case 'failed_denied':
        return failed_denied;
      case 'failed_unknown':
        return failed_unknown;
      case 'try_again':
        return try_again;
      case 'sign_out_note':
        return sign_out_note;
      case 'delete_account':
        return delete_account;
      case 'delete_title':
        return delete_title;
      case 'delete_body':
        return delete_body;
      case 'delete_recent_login':
        return delete_recent_login;
      case 'delete_failed':
        return delete_failed;
      case 'provider_email':
        return provider_email;
      case 'provider_google':
        return provider_google;
      case 'provider_apple':
        return provider_apple;
      default:
        return super[key];
    }
  }
}
