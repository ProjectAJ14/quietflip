// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'de';
String get _localeName => 'de';

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

class Messages_de extends Messages {
  const Messages_de();
  AppMessages_de get app => AppMessages_de(this);
  GenericMessages_de get generic => GenericMessages_de(this);
  CommonMessages_de get common => CommonMessages_de(this);
  AuthMessages_de get auth => AuthMessages_de(this);
  ProfileMessages_de get profile => ProfileMessages_de(this);
  NavMessages_de get nav => NavMessages_de(this);
  NotificationsMessages_de get notifications => NotificationsMessages_de(this);
  ErrorsMessages_de get errors => ErrorsMessages_de(this);
  ValidationMessages_de get validation => ValidationMessages_de(this);
  FilesMessages_de get files => FilesMessages_de(this);
  DeveloperMessages_de get developer => DeveloperMessages_de(this);
  ClockMessages_de get clock => ClockMessages_de(this);
  SyncMessages_de get sync => SyncMessages_de(this);
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

class AppMessages_de extends AppMessages {
  final Messages_de _parent;
  const AppMessages_de(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description => "Werbefreie Klappuhr, Timer und Stoppuhr.";
  String get welcome_to_app => "Willkommen bei QuietFlip!";
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

class GenericMessages_de extends GenericMessages {
  final Messages_de _parent;
  const GenericMessages_de(this._parent) : super(_parent);
  String get ok => "OK";
  String get cancel => "Abbrechen";
  String get save => "Speichern";
  String get delete => "Löschen";
  String get edit => "Bearbeiten";
  String get update => "Aktualisieren";
  String get submit => "Senden";
  String get close => "Schließen";
  String get back => "Zurück";
  String get next => "Weiter";
  String get previous => "Zurück";
  String get done => "Fertig";
  String get loading => "Wird geladen…";
  String get error => "Fehler";
  String get success => "Erfolgreich";
  String get warning => "Warnung";
  String get info => "Info";
  String get retry => "Wiederholen";
  String get refresh => "Aktualisieren";
  String get yes => "Ja";
  String get no => "Nein";
  String get add => "+ Hinzufügen";
  String get try_again => "Erneut versuchen";
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

class CommonMessages_de extends CommonMessages {
  final Messages_de _parent;
  const CommonMessages_de(this._parent) : super(_parent);
  String get week => "Woche";
  String get month => "Monat";
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

class AuthMessages_de extends AuthMessages {
  final Messages_de _parent;
  const AuthMessages_de(this._parent) : super(_parent);
  String get register => "Registrieren";
  String get sign_in => "Anmelden";
  String get sign_out => "Abmelden";
  String get dont_have_account => "Noch kein Konto? ";
  String get already_have_account => "Schon ein Konto? ";
  String get sign_out_confirmation => "Möchtest du dich wirklich abmelden?";
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

class ProfileMessages_de extends ProfileMessages {
  final Messages_de _parent;
  const ProfileMessages_de(this._parent) : super(_parent);
  String get profile => "Profil";
  String get settings => "Einstellungen";
  String get account => "Konto";
  String get personal_info => "Persönliche Daten";
  String get privacy_settings => "Datenschutz";
  String get name => "Name";
  String get email_address => "E-Mail-Adresse";
  String get phone_number => "Telefonnummer";
  String get date_of_birth => "Geburtsdatum";
  String get delete_confirmation => "Löschen bestätigen";
  String get delete_confirmation_message =>
      "Möchtest du dieses Element wirklich löschen? Das kann nicht rückgängig gemacht werden.";
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

class NavMessages_de extends NavMessages {
  final Messages_de _parent;
  const NavMessages_de(this._parent) : super(_parent);
  String get home => "Start";
  String get dashboard => "Übersicht";
  String get explore => "Entdecken";
  String get explore_placeholder =>
      "Dein zweiter Tab. Ersetze ihn durch eine echte Funktion.";
  String get profile => "Profil";
  String get settings => "Einstellungen";
  String get notifications => "Mitteilungen";
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

class NotificationsMessages_de extends NotificationsMessages {
  final Messages_de _parent;
  const NotificationsMessages_de(this._parent) : super(_parent);
  String get title => "Mitteilungen";
  String get mark_as_read => "Als gelesen markieren";
  String get mark_all_read => "Alle als gelesen markieren";
  String get delete => "Löschen";
  String get filter_all => "Alle";
  String get filter_unread => "Ungelesen";
  String get filter_read => "Gelesen";
  String get type_reminder => "Erinnerung";
  String get type_alert => "Hinweis";
  String get type_promotion => "Angebot";
  String get type_system => "System";
  String get type_custom => "Eigene";
  String get empty_title => "Keine Mitteilungen";
  String get empty_description =>
      "Alles erledigt! Neue Mitteilungen erscheinen hier.";
  String get delete_confirmation_title => "Mitteilung löschen?";
  String get delete_confirmation_message =>
      "Diese Mitteilung wird dauerhaft aus deiner Liste entfernt.";
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

class ErrorsMessages_de extends ErrorsMessages {
  final Messages_de _parent;
  const ErrorsMessages_de(this._parent) : super(_parent);
  String get network_error => "Netzwerkfehler. Bitte prüfe deine Verbindung.";
  String get unknown_error => "Ein unbekannter Fehler ist aufgetreten.";
  String get validation_error =>
      "Bitte prüfe deine Eingabe und versuche es erneut.";
  String get server_error => "Serverfehler. Bitte versuche es später erneut.";
  String get default_error_message =>
      "Hoppla! Etwas ist schiefgelaufen. Bitte versuche es erneut.";
  String get user_not_found =>
      "Nutzer nicht gefunden. Bitte prüfe deine Anmeldedaten.";
  String get default_error_description =>
      "Beim Verarbeiten deiner Anfrage ist ein Fehler aufgetreten. Entschuldige die Unannehmlichkeiten. Bitte versuche es später erneut oder wende dich an den Support, falls das Problem bleibt.";
  String get page_not_found => "Seite nicht gefunden";
  String get page_not_found_description =>
      "Die gesuchte Seite existiert nicht.";
  String get unexpected_error => "Ein unerwarteter Fehler ist aufgetreten.";
  String get redirect_error => "Weiterleitungsfehler";
  String get bad_request => "Ungültige Anfrage. Bitte prüfe deine Eingabe.";
  String get unauthorized =>
      "Anmeldung erforderlich. Bitte melde dich erneut an.";
  String get forbidden => "Zugriff verweigert. Dir fehlt die Berechtigung.";
  String get not_found => "Angeforderte Ressource nicht gefunden.";
  String get conflict =>
      "Datenkonflikt. Bitte aktualisiere und versuche es erneut.";
  String get unprocessable_entity =>
      "Ungültiges Datenformat. Bitte prüfe deine Eingabe.";
  String get internal_server_error =>
      "Serverfehler. Bitte versuche es später erneut.";
  String get connection_timeout =>
      "Zeitüberschreitung der Verbindung. Bitte prüfe dein Internet.";
  String get receive_timeout =>
      "Zeitüberschreitung der Anfrage. Bitte versuche es erneut.";
  String get send_timeout =>
      "Zeitüberschreitung beim Hochladen. Bitte versuche es erneut.";
  String get no_internet =>
      "Keine Internetverbindung. Bitte prüfe dein Netzwerk.";
  String get unknown_network =>
      "Netzwerkfehler aufgetreten. Bitte versuche es erneut.";
  String format_exception_message(String code, String postfix) =>
      "Diese Daten tragen das falsche Kostüm, ich erkenne sie nicht [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Diese Daten sind nicht, was ich erwartet habe, ich kann sie nicht verarbeiten [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, ich finde dieses Element nicht in der Liste [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Hoppla! Diese Zahl liegt weit außerhalb meiner Komfortzone [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Hey! Mit deiner Eingabe stimmt etwas nicht [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Ich weiß gerade nicht genau, was ich tun soll [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Diese Funktion ist noch im Bau [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Sorry, das kann ich noch nicht [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Hui! Zu viel auf einmal [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Mein Kopf ist voll! Ich brauche Platz [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Ich drehe mich im Kreis und mir wird schwindelig [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Etwas Unerwartetes ist passiert, aber keine Sorge [$code] $postfix";
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

class ValidationMessages_de extends ValidationMessages {
  final Messages_de _parent;
  const ValidationMessages_de(this._parent) : super(_parent);
  String get required_field => "Dieses Feld ist erforderlich";
  String get invalid_email => "Bitte gib eine gültige E-Mail-Adresse ein";
  String get password_too_short =>
      "Das Passwort muss mindestens 8 Zeichen lang sein";
  String get passwords_dont_match => "Die Passwörter stimmen nicht überein";
  String invalid_key_config(String of, String key) =>
      "Ungültige Konfiguration für $key in $of. Bitte prüfe deine Einstellungen.";
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

class FilesMessages_de extends FilesMessages {
  final Messages_de _parent;
  const FilesMessages_de(this._parent) : super(_parent);
  String get info_title => "Dateiinformationen";
  String get name => "Dateiname";
  String get type => "Dateityp";
  String get extension => "Dateiendung";
  String get size => "Dateigröße";
  String get path => "Dateipfad";
  String get copy_hint => "Tippe auf ein Feld, um es zu kopieren";
  String copied(String field) => "$field in die Zwischenablage kopiert";
  String image_type(String format) => "$format-Bild";
  String get image_file => "Bilddatei";
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

class DeveloperMessages_de extends DeveloperMessages {
  final Messages_de _parent;
  const DeveloperMessages_de(this._parent) : super(_parent);
  String get no_viewer => "Dieser Logger hat keine interaktive Ansicht.";
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

class ClockMessages_de extends ClockMessages {
  final Messages_de _parent;
  const ClockMessages_de(this._parent) : super(_parent);
  String get clock => "Uhr";
  String get stopwatch => "Stoppuhr";
  String get modes => "Modus";
  String get settings => "Einstellungen";
  String get times_up => "Zeit abgelaufen";
  String get timer_finished_title => "Zeit abgelaufen";
  String get timer_finished_body => "Dein QuietFlip-Timer ist abgelaufen.";
  String get alerts_channel => "Timer-Alarme";
  String get show_controls =>
      "Tippe oder bewege die Maus, um die Steuerung zu zeigen";
  String get theme => "Design";
  String get theme_light => "Hell";
  String get use_24h => "24-Stunden-Format";
  String get show_seconds => "Sekunden zeigen";
  String get sound_tick_group => "Ticken";
  String get sound_tick_hint => "bei jedem Umklappen";
  String get sound_alarm_group => "Alarm";
  String get sound_alarm_hint => "wiederholt bis zum Beenden, max. 60 s";
  String get tick_sound => "Tickgeräusch";
  String get tick_sound_description => "Ein leiser Ton bei jedem Umklappen";
  String get alarm_sound => "Alarmton";
  String get alarm_sound_description =>
      "Ertönt am Ende eines Timers oder einer Pomodoro-Phase";
  String get tick_classic => "Klassisch";
  String get tick_classic_mood => "sanftes Klicken";
  String get tick_split_flap => "Fallblatt";
  String get tick_split_flap_mood => "klappernde Blätter";
  String get tick_clockwork => "Uhrwerk";
  String get tick_clockwork_mood => "Uhrenticken";
  String get tick_woodblock => "Holzblock";
  String get tick_woodblock_mood => "hohles Klopfen";
  String get tick_digital => "Digital";
  String get tick_digital_mood => "klarer Piep";
  String get alarm_chime => "Gong";
  String get alarm_chime_mood => "zwei Töne";
  String get alarm_bell => "Glocke";
  String get alarm_bell_mood => "Glockenschlag";
  String get alarm_beeps => "Pieptöne";
  String get alarm_beeps_mood => "Wecker";
  String get alarm_rising => "Ansteigend";
  String get alarm_rising_mood => "Marimba";
  String get alarm_ring => "Klingeln";
  String get alarm_ring_mood => "Doppelglocke";
  String get system_notifications => "Systemmitteilungen";
  String get system_notifications_description =>
      "Erhalte eine Mitteilung, wenn ein Timer abläuft, auch wenn QuietFlip im Hintergrund ist.";
  String get permission_denied =>
      "Mitteilungen sind für QuietFlip deaktiviert. Solange die App geöffnet ist, siehst und hörst du den Alarm trotzdem.";
  String get web_closed_tab_note =>
      "Im Browser funktionieren Alarme nur, solange dieser Tab geöffnet bleibt.";
  String get keep_screen_awake => "Bildschirm anlassen";
  String get keep_screen_awake_description =>
      "Verhindert den Ruhezustand, solange die Uhr angezeigt wird.";
  String current_time(String time) => "Aktuelle Uhrzeit $time";
  String time_remaining(String time) => "Verbleibende Zeit $time";
  String elapsed(String time) => "Vergangene Zeit $time";
  String get digit_brightness => "Ziffernhelligkeit";
  String percent(String value) => "$value %";
  String get subtle_movement => "Leichte Bewegung";
  String get subtle_movement_description =>
      "Im Vollbild verschiebt sich die Uhr jede Minute um ein paar Pixel, damit nicht die ganze Nacht dieselben Pixel leuchten. Senkt das Risiko von Einbrennen, verhindert es aber nicht.";
  String get full_screen_note =>
      "Das Vollbild blendet die Steuerung aus, solange QuietFlip geöffnet ist. Die App muss geöffnet bleiben. Es ist kein Sperrbildschirm und kein Bildschirmschoner.";
  String get show_date => "Datum zeigen";
  String current_time_and_date(String time, String date) =>
      "Aktuelle Uhrzeit $time, $date";
  String get orientation => "Ausrichtung";
  String get orientation_auto => "Auto";
  String get orientation_landscape => "Quer";
  String get orientation_portrait => "Hoch";
  String get settings_card_size => "Kartengröße";
  String get card_size_small => "Klein";
  String get card_size_medium => "Mittel";
  String get card_size_large => "Groß";
  String get settings_corners => "Ecken";
  String get corners_square => "Eckig";
  String get corners_round => "Rund";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Fokus · Runde $round";
  String pomodoro_break(int round) => "Pause · Runde $round";
  String get pomodoro_focus_done => "Fokus beendet. Zeit für eine Pause.";
  String get pomodoro_break_done => "Pause vorbei. Zurück zum Fokus.";
  String get start_focus => "Fokus starten";
  String get start_break => "Pause starten";
  String get skins_title => "Skins";
  String get skins_customize => "Anpassen";
  String skins_customize_named(String name) => "$name anpassen";
  String get skins_done => "Fertig";
  String get skins_in_use => "Aktiv";
  String get skins_yours => "Deine Skins";
  String get skins_classic => "Klassisch";
  String get skins_bold => "Kräftig";
  String get skins_type => "Schrift";
  String get skins_new => "Neuer Skin";
  String get skins_from_current => "Vom aktuellen";
  String get customize_title => "Skin anpassen";
  String get customize_name => "Name";
  String customize_copy_name(String name) => "$name Kopie";
  String get customize_font => "Schrift";
  String get customize_digits => "Ziffern";
  String get customize_card => "Karte";
  String get customize_ground => "Hintergrund";
  String get customize_custom_colour => "Eigene Farbe";
  String get customize_hex_hint => "Hex, zum Beispiel #FF7A00";
  String get customize_hex_invalid =>
      "Gib sechs Hex-Ziffern ein, z. B. #FF7A00.";
  String get customize_apply => "Anwenden";
  String get customize_low_contrast => "Ziffern sind evtl. schwer lesbar.";
  String get customize_details => "Details";
  String get customize_seconds => "Sekunden";
  String get customize_seconds_off => "Aus";
  String get customize_seconds_badge => "Klein";
  String get customize_seconds_cards => "Karten";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Aus";
  String get customize_meridiem_left => "Innen";
  String get customize_meridiem_right => "Daneben";
  String get customize_save => "Skin speichern";
  String get customize_reset => "Zurücksetzen";
  String get customize_delete => "Skin löschen";
  String get skin_mono => "Mono";
  String get skin_paper => "Papier";
  String get skin_rose => "Rosé";
  String get skin_violet => "Violett";
  String get skin_amber => "Bernstein";
  String get skin_signal => "Signal";
  String get skin_field => "Feld";
  String get skin_mint => "Minze";
  String get skin_cyan => "Cyan";
  String get skin_taxi => "Taxi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Plakat";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Orbit";
  String get skin_nightstand => "Nachttisch";
  String get skin_studio => "Studio";
  String get skin_arcade => "Arcade";
  String get skin_railway => "Bahnhof";
  String get skin_desk => "Schreibtisch";
  String get skin_neon => "Neon";
  String get skin_minimal => "Minimal";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Uhr";
  String get mode_stopwatch => "Stoppuhr";
  String get action_start => "Start";
  String get action_pause => "Pause";
  String get action_resume => "Weiter";
  String get action_reset => "Zurücksetzen";
  String get action_restart => "Neu starten";
  String get action_done => "Fertig";
  String get action_skins => "Skins";
  String get action_settings => "Einstellungen";
  String get action_rotation => "Bildschirmdrehung";
  String get action_timer_settings => "Timer-Einstellungen";
  String preset_minutes(int minutes) => "${minutes} Min.";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Timer $minutes Min.";
  String preset_spoken_seconds(int seconds) => "Timer $seconds Sek.";
  String preset_spoken_both(int minutes, int seconds) =>
      "Timer $minutes Min. $seconds Sek.";
  String get action_lap => "Runde";
  String lap_label(int number, String time) => "Runde $number  $time";
  String brightness_value(String percent) => "$percent %";
  String get settings_appearance => "Darstellung";
  String get settings_clock => "Uhr";
  String get settings_gestures => "Gesten";
  String get settings_timers => "Timer";
  String get settings_sound => "Töne & Alarme";
  String get settings_awake => "Wach halten";
  String get settings_shortcuts => "Kurzbefehle";
  String get settings_about => "Info";
  String get theme_dark => "Dunkel";
  String get theme_system => "Wie System";
  String get gesture_swipes => "Wischen";
  String get gesture_brightness =>
      "Nach oben oder unten wischen für Helligkeit";
  String get gesture_modes => "Seitlich wischen, um den Modus zu wechseln";
  String get gesture_footer =>
      "Wische irgendwo auf der Uhr. Auf Mac, Windows und im Web dimmt die Helligkeit die Ziffern statt des Bildschirms.";
  String get gesture_controls => "Steuerung";
  String get gesture_tap => "Tippen zeigt die Steuerung";
  String get gesture_idle => "Steuerung ausblenden nach";
  String gesture_idle_seconds(int seconds) => "${seconds} s";
  String get gesture_idle_never => "Nie";
  String get gesture_controls_footer =>
      "Die Steuerung schrumpft zu einem Punkt und verschwindet dann.";
  String get timers_default => "Standard-Timer";
  String get timers_start_runs => "Start startet";
  String get timers_presets => "Vorgaben";
  String get timers_add => "Timer hinzufügen";
  String get timers_limit_footer =>
      "Auf die Insel passen sechs Timer. Lösche einen, um einen neuen hinzuzufügen.";
  String timers_delete(String timer) => "$timer löschen";
  String get timers_duplicate => "Diesen Timer hast du schon.";
  String get timers_picker_minutes => "Minuten";
  String get timers_picker_seconds => "Sekunden";
  String get skins_view_all => "Alle zeigen";
  String get timers_pomodoro_focus => "Fokus";
  String get timers_pomodoro_break => "Pause";
  String timers_minutes(int minutes) => "$minutes Min.";
  String get sound_footer =>
      "Der Alarm in der App ertönt immer, auch ohne Mitteilungen.";
  String get shortcuts_touch => "Touch";
  String get shortcuts_keyboard => "Tastatur";
  String get touch_controls => "Steuerung zeigen oder ausblenden";
  String get shortcut_off => "Aus";
  String get key_start_pause => "Start oder Pause";
  String get key_change_mode => "Modus wechseln";
  String get key_brightness => "Helligkeit";
  String get key_show_seconds => "Sekunden zeigen";
  String get key_full_screen => "Vollbild";
  String get key_hide_controls => "Steuerung ausblenden";
  String get key_dim => "Ziffern dimmen";
  String get key_lap => "Runde (Stoppuhr)";
  String get key_rotation => "Bildschirmdrehung";
  String get keycap_space => "Leertaste";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Lizenzen";
  String get about_privacy => "Datenschutz";
  String get about_privacy_value =>
      "Keine Werbung. Ein Konto ist optional. Anonyme Nutzungsstatistiken helfen uns, die App zu verbessern.";
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

class SyncMessages_de extends SyncMessages {
  final Messages_de _parent;
  const SyncMessages_de(this._parent) : super(_parent);
  String get account => "Konto";
  String get card_title_signed_out =>
      "Deine Einstellungen bleiben auf diesem Gerät";
  String get card_body_signed_out =>
      "Melde dich nur an, wenn du sie auf deinen anderen Geräten willst.";
  String get card_title_on => "Sync ist an";
  String get card_title_off => "Sync ist aus";
  String card_last_synced(String when) => "Zuletzt synchronisiert $when";
  String get headline => "Deine Einstellungen bleiben auf diesem Gerät";
  String get body =>
      "QuietFlip braucht nie ein Konto. Melde dich nur an, wenn du Uhr, Skins und Töne auf deinen anderen Geräten willst.";
  String get sign_in => "Zum Synchronisieren anmelden";
  String get sign_in_reason =>
      "Nur nötig, um Einstellungen zwischen Geräten zu synchronisieren.";
  String get what_syncs => "Was synchronisiert wird";
  String get what_syncs_body =>
      "Design, Skins, Töne, Uhr- und Timer-Einstellungen.";
  String get stays_body =>
      "Bleibt auf diesem Gerät: Helligkeit, Drehung, Mitteilungen und ein laufender Timer.";
  String get sync_header => "Sync";
  String get sync_settings => "Einstellungen synchronisieren";
  String get sync_settings_note =>
      "Deine Einstellungen folgen dir auf jedes Gerät, auf dem du dich anmeldest.";
  String get last_synced => "Zuletzt synchronisiert";
  String get just_now => "Gerade eben";
  String minutes_ago(int n) => "Vor $n Min.";
  String today_at(String time) => "Heute um $time";
  String get never => "Noch nicht";
  String get syncing => "Wird synchronisiert…";
  String get waiting => "Warte auf Verbindung";
  String get off_note => "Sync ist aus. Änderungen bleiben auf diesem Gerät.";
  String get failed_offline =>
      "Sync fehlgeschlagen: keine Verbindung. Neuer Versuch, sobald du wieder online bist.";
  String get failed_denied => "Sync fehlgeschlagen: bitte erneut anmelden.";
  String get failed_unknown => "Sync fehlgeschlagen. Erneut versuchen.";
  String get try_again => "Erneut versuchen";
  String get sign_out_note =>
      "Nach dem Abmelden bleiben deine Einstellungen auf diesem Gerät.";
  String get delete_account => "Konto löschen";
  String get delete_title => "Konto löschen?";
  String get delete_body =>
      "Deine synchronisierten Einstellungen werden aus der Cloud entfernt. Die Einstellungen auf diesem Gerät bleiben.";
  String get delete_recent_login =>
      "Melde dich erneut an, um dein Konto zu löschen";
  String get delete_failed =>
      "Konto konnte nicht gelöscht werden. Erneut versuchen.";
  String get provider_email => "E-Mail";
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
