// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'it';
String get _localeName => 'it';

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

class Messages_it extends Messages {
  const Messages_it();
  AppMessages_it get app => AppMessages_it(this);
  GenericMessages_it get generic => GenericMessages_it(this);
  CommonMessages_it get common => CommonMessages_it(this);
  AuthMessages_it get auth => AuthMessages_it(this);
  ProfileMessages_it get profile => ProfileMessages_it(this);
  NavMessages_it get nav => NavMessages_it(this);
  NotificationsMessages_it get notifications => NotificationsMessages_it(this);
  ErrorsMessages_it get errors => ErrorsMessages_it(this);
  ValidationMessages_it get validation => ValidationMessages_it(this);
  FilesMessages_it get files => FilesMessages_it(this);
  DeveloperMessages_it get developer => DeveloperMessages_it(this);
  ClockMessages_it get clock => ClockMessages_it(this);
  SyncMessages_it get sync => SyncMessages_it(this);
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

class AppMessages_it extends AppMessages {
  final Messages_it _parent;
  const AppMessages_it(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "Orologio a palette, timer e cronometro, senza pubblicità.";
  String get welcome_to_app => "Benvenuto in QuietFlip!";
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

class GenericMessages_it extends GenericMessages {
  final Messages_it _parent;
  const GenericMessages_it(this._parent) : super(_parent);
  String get ok => "OK";
  String get cancel => "Annulla";
  String get save => "Salva";
  String get delete => "Elimina";
  String get edit => "Modifica";
  String get update => "Aggiorna";
  String get submit => "Invia";
  String get close => "Chiudi";
  String get back => "Indietro";
  String get next => "Avanti";
  String get previous => "Precedente";
  String get done => "Fine";
  String get loading => "Caricamento…";
  String get error => "Errore";
  String get success => "Operazione riuscita";
  String get warning => "Attenzione";
  String get info => "Info";
  String get retry => "Riprova";
  String get refresh => "Aggiorna";
  String get yes => "Sì";
  String get no => "No";
  String get add => "+ Aggiungi";
  String get try_again => "Riprova";
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

class CommonMessages_it extends CommonMessages {
  final Messages_it _parent;
  const CommonMessages_it(this._parent) : super(_parent);
  String get week => "Settimana";
  String get month => "Mese";
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

class AuthMessages_it extends AuthMessages {
  final Messages_it _parent;
  const AuthMessages_it(this._parent) : super(_parent);
  String get register => "Registrati";
  String get sign_in => "Accedi";
  String get sign_out => "Esci";
  String get dont_have_account => "Non hai un account? ";
  String get already_have_account => "Hai già un account? ";
  String get sign_out_confirmation => "Vuoi davvero uscire?";
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

class ProfileMessages_it extends ProfileMessages {
  final Messages_it _parent;
  const ProfileMessages_it(this._parent) : super(_parent);
  String get profile => "Profilo";
  String get settings => "Impostazioni";
  String get account => "Account";
  String get personal_info => "Informazioni personali";
  String get privacy_settings => "Impostazioni privacy";
  String get name => "Nome";
  String get email_address => "Indirizzo email";
  String get phone_number => "Numero di telefono";
  String get date_of_birth => "Data di nascita";
  String get delete_confirmation => "Conferma eliminazione";
  String get delete_confirmation_message =>
      "Vuoi davvero eliminare questo elemento? L’azione non può essere annullata.";
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

class NavMessages_it extends NavMessages {
  final Messages_it _parent;
  const NavMessages_it(this._parent) : super(_parent);
  String get home => "Home";
  String get dashboard => "Dashboard";
  String get explore => "Esplora";
  String get explore_placeholder =>
      "La tua seconda scheda. Sostituiscila con una funzione reale.";
  String get profile => "Profilo";
  String get settings => "Impostazioni";
  String get notifications => "Notifiche";
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

class NotificationsMessages_it extends NotificationsMessages {
  final Messages_it _parent;
  const NotificationsMessages_it(this._parent) : super(_parent);
  String get title => "Notifiche";
  String get mark_as_read => "Segna come letta";
  String get mark_all_read => "Segna tutte come lette";
  String get delete => "Elimina";
  String get filter_all => "Tutte";
  String get filter_unread => "Non lette";
  String get filter_read => "Lette";
  String get type_reminder => "Promemoria";
  String get type_alert => "Avviso";
  String get type_promotion => "Promozione";
  String get type_system => "Sistema";
  String get type_custom => "Personalizzata";
  String get empty_title => "Nessuna notifica";
  String get empty_description =>
      "Sei in pari! Le nuove notifiche appariranno qui.";
  String get delete_confirmation_title => "Eliminare la notifica?";
  String get delete_confirmation_message =>
      "Questa notifica verrà rimossa definitivamente dal tuo elenco.";
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

class ErrorsMessages_it extends ErrorsMessages {
  final Messages_it _parent;
  const ErrorsMessages_it(this._parent) : super(_parent);
  String get network_error => "Errore di rete. Controlla la connessione.";
  String get unknown_error => "Si è verificato un errore sconosciuto.";
  String get validation_error => "Controlla i dati inseriti e riprova.";
  String get server_error => "Errore del server. Riprova più tardi.";
  String get default_error_message => "Ops! Qualcosa è andato storto. Riprova.";
  String get user_not_found => "Utente non trovato. Controlla le credenziali.";
  String get default_error_description =>
      "Si è verificato un errore durante l’elaborazione della richiesta. Ci scusiamo per l’inconveniente. Riprova più tardi o contatta l’assistenza se il problema persiste.";
  String get page_not_found => "Pagina non trovata";
  String get page_not_found_description => "La pagina che cerchi non esiste.";
  String get unexpected_error => "Si è verificato un errore imprevisto.";
  String get redirect_error => "Errore di reindirizzamento";
  String get bad_request => "Richiesta non valida. Controlla i dati inseriti.";
  String get unauthorized => "Autenticazione richiesta. Accedi di nuovo.";
  String get forbidden => "Accesso negato. Non hai l’autorizzazione.";
  String get not_found => "Risorsa richiesta non trovata.";
  String get conflict => "Conflitto di dati. Aggiorna e riprova.";
  String get unprocessable_entity =>
      "Formato dei dati non valido. Controlla i dati inseriti.";
  String get internal_server_error => "Errore del server. Riprova più tardi.";
  String get connection_timeout =>
      "Timeout della connessione. Controlla la rete.";
  String get receive_timeout => "Timeout della richiesta. Riprova.";
  String get send_timeout => "Timeout del caricamento. Riprova.";
  String get no_internet =>
      "Nessuna connessione a internet. Controlla la rete.";
  String get unknown_network => "Si è verificato un errore di rete. Riprova.";
  String format_exception_message(String code, String postfix) =>
      "Questi dati sono travestiti, non li riconosco [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Questi dati non sono quelli che mi aspettavo, non riesco a elaborarli [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Mmm, non riesco a trovare quell’elemento nell’elenco [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Ops! Quel numero è decisamente fuori portata [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Ehi! C’è qualcosa che non va in ciò che mi hai dato [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Sono un po’ confuso su cosa dovrei fare adesso [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Questa funzione è ancora in costruzione [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Spiacente, non so ancora come farlo [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Ehi! Troppe cose tutte insieme [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Ho la testa piena! Devo fare un po’ di spazio [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Sono bloccato in un ciclo e mi gira la testa [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "È successo qualcosa di imprevisto, ma niente paura [$code] $postfix";
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

class ValidationMessages_it extends ValidationMessages {
  final Messages_it _parent;
  const ValidationMessages_it(this._parent) : super(_parent);
  String get required_field => "Campo obbligatorio";
  String get invalid_email => "Inserisci un indirizzo email valido";
  String get password_too_short =>
      "La password deve contenere almeno 8 caratteri";
  String get passwords_dont_match => "Le password non coincidono";
  String invalid_key_config(String of, String key) =>
      "Configurazione non valida per $key in $of. Controlla le impostazioni.";
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

class FilesMessages_it extends FilesMessages {
  final Messages_it _parent;
  const FilesMessages_it(this._parent) : super(_parent);
  String get info_title => "Informazioni file";
  String get name => "Nome file";
  String get type => "Tipo di file";
  String get extension => "Estensione";
  String get size => "Dimensione";
  String get path => "Percorso";
  String get copy_hint => "Tocca un campo per copiarlo negli appunti";
  String copied(String field) => "$field copiato negli appunti";
  String image_type(String format) => "Immagine $format";
  String get image_file => "File immagine";
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

class DeveloperMessages_it extends DeveloperMessages {
  final Messages_it _parent;
  const DeveloperMessages_it(this._parent) : super(_parent);
  String get no_viewer => "Questo logger non ha un visualizzatore interattivo.";
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

class ClockMessages_it extends ClockMessages {
  final Messages_it _parent;
  const ClockMessages_it(this._parent) : super(_parent);
  String get clock => "Orologio";
  String get stopwatch => "Cronometro";
  String get modes => "Modalità";
  String get settings => "Impostazioni";
  String get times_up => "Tempo scaduto";
  String get timer_finished_title => "Tempo scaduto";
  String get timer_finished_body => "Il timer di QuietFlip è terminato.";
  String get alerts_channel => "Avvisi timer";
  String get show_controls => "Tocca o muovi il mouse per mostrare i controlli";
  String get theme => "Tema";
  String get theme_light => "Chiaro";
  String get use_24h => "Formato 24 ore";
  String get show_seconds => "Mostra secondi";
  String get sound_tick_group => "Tic";
  String get sound_tick_hint => "suona a ogni giro di paletta";
  String get sound_alarm_group => "Allarme";
  String get sound_alarm_hint => "si ripete finché non lo chiudi, max 60 s";
  String get tick_sound => "Suono tic";
  String get tick_sound_description =>
      "Un suono leggero a ogni giro di paletta";
  String get alarm_sound => "Suono allarme";
  String get alarm_sound_description =>
      "Suona quando finisce un timer o una fase Pomodoro";
  String get tick_classic => "Classico";
  String get tick_classic_mood => "clic leggero";
  String get tick_split_flap => "Palette";
  String get tick_split_flap_mood => "fruscio di palette";
  String get tick_clockwork => "Meccanico";
  String get tick_clockwork_mood => "tic d’orologio";
  String get tick_woodblock => "Legno";
  String get tick_woodblock_mood => "colpo sordo";
  String get tick_digital => "Digitale";
  String get tick_digital_mood => "bip pulito";
  String get alarm_chime => "Rintocco";
  String get alarm_chime_mood => "due toni";
  String get alarm_bell => "Campana";
  String get alarm_bell_mood => "campana battuta";
  String get alarm_beeps => "Bip";
  String get alarm_beeps_mood => "sveglia da comodino";
  String get alarm_rising => "Crescente";
  String get alarm_rising_mood => "marimba";
  String get alarm_ring => "Squillo";
  String get alarm_ring_mood => "doppia campana";
  String get system_notifications => "Notifiche di sistema";
  String get system_notifications_description =>
      "Ricevi una notifica alla fine di un timer, anche con QuietFlip in background.";
  String get permission_denied =>
      "Le notifiche di QuietFlip sono disattivate. Vedrai e sentirai comunque l’avviso con l’app aperta.";
  String get web_closed_tab_note =>
      "Nel browser, gli avvisi funzionano solo se questa scheda resta aperta.";
  String get keep_screen_awake => "Schermo sempre attivo";
  String get keep_screen_awake_description =>
      "Impedisce allo schermo di spegnersi mentre è visibile l’orologio.";
  String current_time(String time) => "Ora attuale $time";
  String time_remaining(String time) => "Tempo rimanente $time";
  String elapsed(String time) => "Tempo trascorso $time";
  String get digit_brightness => "Luminosità cifre";
  String percent(String value) => "$value%";
  String get subtle_movement => "Movimento leggero";
  String get subtle_movement_description =>
      "A schermo intero, sposta l’orologio di pochi pixel ogni minuto perché gli stessi pixel non restino accesi tutta la notte. Riduce, ma non elimina, il rischio di burn-in.";
  String get full_screen_note =>
      "Lo schermo intero nasconde i controlli finché QuietFlip resta aperta. L’app deve restare aperta. Non è una schermata di blocco né un salvaschermo.";
  String get show_date => "Mostra data";
  String current_time_and_date(String time, String date) =>
      "Ora attuale $time, $date";
  String get orientation => "Orientamento";
  String get orientation_auto => "Automatico";
  String get orientation_landscape => "Orizzontale";
  String get orientation_portrait => "Verticale";
  String get settings_card_size => "Dimensione palette";
  String get card_size_small => "Piccola";
  String get card_size_medium => "Media";
  String get card_size_large => "Grande";
  String get settings_corners => "Angoli";
  String get corners_square => "Squadrati";
  String get corners_round => "Arrotondati";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Focus · Ciclo $round";
  String pomodoro_break(int round) => "Pausa · Ciclo $round";
  String get pomodoro_focus_done => "Focus finito. È ora di una pausa.";
  String get pomodoro_break_done => "Pausa finita. Torna al focus.";
  String get start_focus => "Avvia focus";
  String get start_break => "Avvia pausa";
  String get skins_title => "Skin";
  String get skins_customize => "Personalizza";
  String skins_customize_named(String name) => "Personalizza $name";
  String get skins_done => "Fine";
  String get skins_in_use => "In uso";
  String get skins_yours => "Le tue skin";
  String get skins_classic => "Classiche";
  String get skins_bold => "Decise";
  String get skins_type => "Caratteri";
  String get skins_new => "Nuova skin";
  String get skins_from_current => "Da quella attuale";
  String get customize_title => "Personalizza skin";
  String get customize_name => "Nome";
  String customize_copy_name(String name) => "Copia di $name";
  String get customize_font => "Font";
  String get customize_digits => "Cifre";
  String get customize_card => "Paletta";
  String get customize_ground => "Sfondo";
  String get customize_custom_colour => "Colore personalizzato";
  String get customize_hex_hint => "Esadecimale, per esempio #FF7A00";
  String get customize_hex_invalid =>
      "Inserisci sei cifre esadecimali, come #FF7A00.";
  String get customize_apply => "Applica";
  String get customize_low_contrast =>
      "Le cifre potrebbero essere poco leggibili.";
  String get customize_details => "Dettagli";
  String get customize_seconds => "Secondi";
  String get customize_seconds_off => "No";
  String get customize_seconds_badge => "Piccoli";
  String get customize_seconds_cards => "Palette";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Nascosto";
  String get customize_meridiem_left => "Dentro";
  String get customize_meridiem_right => "Accanto";
  String get customize_save => "Salva skin";
  String get customize_reset => "Ripristina";
  String get customize_delete => "Elimina skin";
  String get skin_mono => "Mono";
  String get skin_paper => "Carta";
  String get skin_rose => "Rosa";
  String get skin_violet => "Viola";
  String get skin_amber => "Ambra";
  String get skin_signal => "Segnale";
  String get skin_field => "Campo";
  String get skin_mint => "Menta";
  String get skin_cyan => "Ciano";
  String get skin_taxi => "Taxi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Manifesto";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Orbita";
  String get skin_nightstand => "Comodino";
  String get skin_studio => "Studio";
  String get skin_arcade => "Arcade";
  String get skin_railway => "Ferrovia";
  String get skin_desk => "Scrivania";
  String get skin_neon => "Neon";
  String get skin_minimal => "Minimal";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Orologio";
  String get mode_stopwatch => "Cronometro";
  String get action_start => "Avvia";
  String get action_pause => "Pausa";
  String get action_resume => "Riprendi";
  String get action_reset => "Azzera";
  String get action_restart => "Ricomincia";
  String get action_done => "Fine";
  String get action_skins => "Skin";
  String get action_settings => "Impostazioni";
  String get action_rotation => "Rotazione schermo";
  String get action_timer_settings => "Impostazioni timer";
  String preset_minutes(int minutes) => "$minutes min";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Timer da $minutes min";
  String preset_spoken_seconds(int seconds) => "Timer da $seconds s";
  String preset_spoken_both(int minutes, int seconds) =>
      "Timer da $minutes min e $seconds s";
  String get action_lap => "Giro";
  String lap_label(int number, String time) => "Giro $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "Aspetto";
  String get settings_clock => "Orologio";
  String get settings_gestures => "Gesti";
  String get settings_timers => "Timer";
  String get settings_sound => "Suoni e avvisi";
  String get settings_awake => "Schermo attivo";
  String get settings_shortcuts => "Scorciatoie";
  String get settings_about => "Info";
  String get theme_dark => "Scuro";
  String get theme_system => "Come il sistema";
  String get gesture_swipes => "Scorrimenti";
  String get gesture_brightness => "Scorri su o giù per la luminosità";
  String get gesture_modes => "Scorri di lato per cambiare modalità";
  String get gesture_footer =>
      "Scorri in qualsiasi punto dell’orologio. Su Mac, Windows e web, la luminosità attenua le cifre anziché lo schermo.";
  String get gesture_controls => "Controlli";
  String get gesture_tap => "Tocca per mostrare i controlli";
  String get gesture_idle => "Nascondi controlli dopo";
  String gesture_idle_seconds(int seconds) => "$seconds s";
  String get gesture_idle_never => "Mai";
  String get gesture_controls_footer =>
      "I controlli si riducono a un punto, poi spariscono.";
  String get timers_default => "Timer predefinito";
  String get timers_start_runs => "Avvio rapido";
  String get timers_presets => "Preimpostati";
  String get timers_add => "Aggiungi timer";
  String get timers_limit_footer =>
      "L’isola contiene sei timer. Eliminane uno per aggiungerne un altro.";
  String timers_delete(String timer) => "Elimina $timer";
  String get timers_duplicate => "Hai già questo timer.";
  String get timers_picker_minutes => "Minuti";
  String get timers_picker_seconds => "Secondi";
  String get skins_view_all => "Vedi tutte";
  String get timers_pomodoro_focus => "Focus";
  String get timers_pomodoro_break => "Pausa";
  String timers_minutes(int minutes) => "$minutes min";
  String get sound_footer =>
      "L’avviso nell’app suona sempre, anche con le notifiche disattivate.";
  String get shortcuts_touch => "Tocco";
  String get shortcuts_keyboard => "Tastiera";
  String get touch_controls => "Mostra o nascondi i controlli";
  String get shortcut_off => "No";
  String get key_start_pause => "Avvia o metti in pausa";
  String get key_change_mode => "Cambia modalità";
  String get key_brightness => "Luminosità";
  String get key_show_seconds => "Mostra secondi";
  String get key_full_screen => "Schermo intero";
  String get key_hide_controls => "Nascondi controlli";
  String get key_dim => "Attenua le cifre";
  String get key_lap => "Giro (cronometro)";
  String get key_rotation => "Rotazione schermo";
  String get keycap_space => "Spazio";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Licenze";
  String get about_privacy => "Privacy";
  String get about_privacy_value =>
      "Niente pubblicità. Nessun tracciamento. L’account è facoltativo.";
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

class SyncMessages_it extends SyncMessages {
  final Messages_it _parent;
  const SyncMessages_it(this._parent) : super(_parent);
  String get account => "Account";
  String get card_title_signed_out =>
      "Le impostazioni restano su questo dispositivo";
  String get card_body_signed_out =>
      "Accedi solo se le vuoi anche sugli altri dispositivi.";
  String get card_title_on => "Sincronizzazione attiva";
  String get card_title_off => "Sincronizzazione disattivata";
  String card_last_synced(String when) => "Ultima sincronizzazione $when";
  String get headline => "Le impostazioni restano su questo dispositivo";
  String get body =>
      "QuietFlip non richiede mai un account. Accedi solo se vuoi orologio, skin e suoni anche sugli altri dispositivi.";
  String get sign_in => "Accedi per sincronizzare";
  String get sign_in_reason =>
      "Serve solo a sincronizzare le impostazioni tra dispositivi.";
  String get what_syncs => "Cosa si sincronizza";
  String get what_syncs_body =>
      "Tema, skin, suoni, impostazioni di orologio e timer.";
  String get stays_body =>
      "Restano su questo dispositivo: luminosità, rotazione, notifiche e il timer in corso.";
  String get sync_header => "Sincronizzazione";
  String get sync_settings => "Sincronizza impostazioni";
  String get sync_settings_note =>
      "Le impostazioni ti seguono su ogni dispositivo in cui accedi.";
  String get last_synced => "Ultima sincronizzazione";
  String get just_now => "Adesso";
  String minutes_ago(int n) => "$n min fa";
  String today_at(String time) => "Oggi alle $time";
  String get never => "Non ancora";
  String get syncing => "Sincronizzazione…";
  String get waiting => "In attesa di connessione";
  String get off_note =>
      "Sincronizzazione disattivata. Le modifiche restano su questo dispositivo.";
  String get failed_offline =>
      "Sincronizzazione non riuscita: nessuna connessione. Riproverà quando tornerai online.";
  String get failed_denied => "Sincronizzazione non riuscita: accedi di nuovo.";
  String get failed_unknown => "Sincronizzazione non riuscita. Riprova.";
  String get try_again => "Riprova";
  String get sign_out_note =>
      "Uscendo, le impostazioni restano su questo dispositivo.";
  String get delete_account => "Elimina account";
  String get delete_title => "Eliminare l’account?";
  String get delete_body =>
      "Le impostazioni sincronizzate vengono rimosse dal cloud. Quelle su questo dispositivo restano.";
  String get delete_recent_login => "Accedi di nuovo per eliminare l’account";
  String get delete_failed => "Impossibile eliminare l’account. Riprova.";
  String get provider_email => "Email";
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
