// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'es';
String get _localeName => 'es';

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

class Messages_es extends Messages {
  const Messages_es();
  AppMessages_es get app => AppMessages_es(this);
  GenericMessages_es get generic => GenericMessages_es(this);
  CommonMessages_es get common => CommonMessages_es(this);
  AuthMessages_es get auth => AuthMessages_es(this);
  ProfileMessages_es get profile => ProfileMessages_es(this);
  NavMessages_es get nav => NavMessages_es(this);
  NotificationsMessages_es get notifications => NotificationsMessages_es(this);
  ErrorsMessages_es get errors => ErrorsMessages_es(this);
  ValidationMessages_es get validation => ValidationMessages_es(this);
  FilesMessages_es get files => FilesMessages_es(this);
  DeveloperMessages_es get developer => DeveloperMessages_es(this);
  ClockMessages_es get clock => ClockMessages_es(this);
  SyncMessages_es get sync => SyncMessages_es(this);
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

class AppMessages_es extends AppMessages {
  final Messages_es _parent;
  const AppMessages_es(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "Reloj de paletas, temporizador y cronómetro sin anuncios.";
  String get welcome_to_app => "¡Te damos la bienvenida a QuietFlip!";
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

class GenericMessages_es extends GenericMessages {
  final Messages_es _parent;
  const GenericMessages_es(this._parent) : super(_parent);
  String get ok => "Aceptar";
  String get cancel => "Cancelar";
  String get save => "Guardar";
  String get delete => "Eliminar";
  String get edit => "Editar";
  String get update => "Actualizar";
  String get submit => "Enviar";
  String get close => "Cerrar";
  String get back => "Atrás";
  String get next => "Siguiente";
  String get previous => "Anterior";
  String get done => "Listo";
  String get loading => "Cargando...";
  String get error => "Error";
  String get success => "Listo";
  String get warning => "Advertencia";
  String get info => "Información";
  String get retry => "Reintentar";
  String get refresh => "Actualizar";
  String get yes => "Sí";
  String get no => "No";
  String get add => "+ Añadir";
  String get try_again => "Reintentar";
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

class CommonMessages_es extends CommonMessages {
  final Messages_es _parent;
  const CommonMessages_es(this._parent) : super(_parent);
  String get week => "Semana";
  String get month => "Mes";
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

class AuthMessages_es extends AuthMessages {
  final Messages_es _parent;
  const AuthMessages_es(this._parent) : super(_parent);
  String get register => "Registrarse";
  String get sign_in => "Iniciar sesión";
  String get sign_out => "Cerrar sesión";
  String get dont_have_account => "¿No tienes cuenta? ";
  String get already_have_account => "¿Ya tienes cuenta? ";
  String get sign_out_confirmation => "¿Seguro que quieres cerrar sesión?";
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

class ProfileMessages_es extends ProfileMessages {
  final Messages_es _parent;
  const ProfileMessages_es(this._parent) : super(_parent);
  String get profile => "Perfil";
  String get settings => "Ajustes";
  String get account => "Cuenta";
  String get personal_info => "Información personal";
  String get privacy_settings => "Ajustes de privacidad";
  String get name => "Nombre";
  String get email_address => "Correo electrónico";
  String get phone_number => "Número de teléfono";
  String get date_of_birth => "Fecha de nacimiento";
  String get delete_confirmation => "Confirmar eliminación";
  String get delete_confirmation_message =>
      "¿Seguro que quieres eliminar este elemento? Esta acción no se puede deshacer.";
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

class NavMessages_es extends NavMessages {
  final Messages_es _parent;
  const NavMessages_es(this._parent) : super(_parent);
  String get home => "Inicio";
  String get dashboard => "Panel";
  String get explore => "Explorar";
  String get explore_placeholder =>
      "Tu segunda pestaña. Sustitúyela por una función real.";
  String get profile => "Perfil";
  String get settings => "Ajustes";
  String get notifications => "Notificaciones";
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

class NotificationsMessages_es extends NotificationsMessages {
  final Messages_es _parent;
  const NotificationsMessages_es(this._parent) : super(_parent);
  String get title => "Notificaciones";
  String get mark_as_read => "Marcar como leída";
  String get mark_all_read => "Marcar todas como leídas";
  String get delete => "Eliminar";
  String get filter_all => "Todas";
  String get filter_unread => "No leídas";
  String get filter_read => "Leídas";
  String get type_reminder => "Recordatorio";
  String get type_alert => "Alerta";
  String get type_promotion => "Promoción";
  String get type_system => "Sistema";
  String get type_custom => "Personalizada";
  String get empty_title => "No hay notificaciones";
  String get empty_description =>
      "Estás al día. Las nuevas notificaciones aparecerán aquí.";
  String get delete_confirmation_title => "¿Eliminar notificación?";
  String get delete_confirmation_message =>
      "Esta notificación se quitará de tu lista de forma permanente.";
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

class ErrorsMessages_es extends ErrorsMessages {
  final Messages_es _parent;
  const ErrorsMessages_es(this._parent) : super(_parent);
  String get network_error => "Error de red. Comprueba tu conexión.";
  String get unknown_error => "Se ha producido un error desconocido.";
  String get validation_error => "Revisa los datos e inténtalo de nuevo.";
  String get server_error => "Error del servidor. Inténtalo más tarde.";
  String get default_error_message =>
      "¡Vaya! Algo salió mal. Inténtalo de nuevo.";
  String get user_not_found =>
      "Usuario no encontrado. Revisa tus credenciales.";
  String get default_error_description =>
      "Se produjo un error al procesar tu solicitud. Disculpa las molestias. Inténtalo más tarde o contacta con soporte si el problema continúa.";
  String get page_not_found => "Página no encontrada";
  String get page_not_found_description => "La página que buscas no existe.";
  String get unexpected_error => "Se produjo un error inesperado.";
  String get redirect_error => "Error de redirección";
  String get bad_request => "Solicitud no válida. Revisa los datos.";
  String get unauthorized =>
      "Se requiere autenticación. Vuelve a iniciar sesión.";
  String get forbidden => "Acceso denegado. No tienes permiso.";
  String get not_found => "No se encontró el recurso solicitado.";
  String get conflict => "Conflicto de datos. Actualiza e inténtalo de nuevo.";
  String get unprocessable_entity =>
      "Formato de datos no válido. Revisa los datos.";
  String get internal_server_error =>
      "Error del servidor. Inténtalo más tarde.";
  String get connection_timeout =>
      "Tiempo de conexión agotado. Comprueba tu internet.";
  String get receive_timeout => "Tiempo de espera agotado. Inténtalo de nuevo.";
  String get send_timeout => "Tiempo de subida agotado. Inténtalo de nuevo.";
  String get no_internet => "Sin conexión a internet. Comprueba tu red.";
  String get unknown_network =>
      "Se produjo un error de red. Inténtalo de nuevo.";
  String format_exception_message(String code, String postfix) =>
      "Estos datos llevan el disfraz equivocado, no los reconozco [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Estos datos no son lo que esperaba, no puedo procesarlos [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Mmm, no encuentro ese elemento en la lista [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "¡Vaya! Ese número se sale de mi zona de confort [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "¡Oye! Algo no cuadra con lo que me diste [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Estoy un poco confundido sobre qué debería hacer ahora [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Esta función aún está en construcción [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Lo siento, aún no sé hacer eso [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "¡Uf! Pasan demasiadas cosas a la vez [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "¡Tengo la cabeza llena! Necesito hacer espacio [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Me quedé atrapado en un bucle y estoy mareado [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Pasó algo inesperado, pero no te preocupes [$code] $postfix";
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

class ValidationMessages_es extends ValidationMessages {
  final Messages_es _parent;
  const ValidationMessages_es(this._parent) : super(_parent);
  String get required_field => "Este campo es obligatorio";
  String get invalid_email => "Introduce un correo electrónico válido";
  String get password_too_short =>
      "La contraseña debe tener al menos 8 caracteres";
  String get passwords_dont_match => "Las contraseñas no coinciden";
  String invalid_key_config(String of, String key) =>
      "Configuración no válida para $key en $of. Revisa tus ajustes.";
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

class FilesMessages_es extends FilesMessages {
  final Messages_es _parent;
  const FilesMessages_es(this._parent) : super(_parent);
  String get info_title => "Información del archivo";
  String get name => "Nombre del archivo";
  String get type => "Tipo de archivo";
  String get extension => "Extensión del archivo";
  String get size => "Tamaño del archivo";
  String get path => "Ruta del archivo";
  String get copy_hint => "Toca un campo para copiarlo al portapapeles";
  String copied(String field) => "$field copiado al portapapeles";
  String image_type(String format) => "Imagen $format";
  String get image_file => "Archivo de imagen";
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

class DeveloperMessages_es extends DeveloperMessages {
  final Messages_es _parent;
  const DeveloperMessages_es(this._parent) : super(_parent);
  String get no_viewer => "Este registro no tiene visor interactivo.";
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

class ClockMessages_es extends ClockMessages {
  final Messages_es _parent;
  const ClockMessages_es(this._parent) : super(_parent);
  String get clock => "Reloj";
  String get stopwatch => "Cronómetro";
  String get modes => "Modo";
  String get settings => "Ajustes";
  String get times_up => "Se acabó el tiempo";
  String get timer_finished_title => "Se acabó el tiempo";
  String get timer_finished_body =>
      "Tu temporizador de QuietFlip ha terminado.";
  String get alerts_channel => "Alertas del temporizador";
  String get show_controls => "Toca o mueve el ratón para ver los controles";
  String get theme => "Tema";
  String get theme_light => "Claro";
  String get use_24h => "Formato de 24 horas";
  String get show_seconds => "Mostrar segundos";
  String get sound_tick_group => "Tic";
  String get sound_tick_hint => "suena en cada giro";
  String get sound_alarm_group => "Alarma";
  String get sound_alarm_hint => "se repite hasta descartarla, máx. 60 s";
  String get tick_sound => "Sonido de tic";
  String get tick_sound_description =>
      "Un sonido suave cada vez que gira una paleta";
  String get alarm_sound => "Sonido de alarma";
  String get alarm_sound_description =>
      "Suena al terminar un temporizador o una fase Pomodoro";
  String get tick_classic => "Clásico";
  String get tick_classic_mood => "clic suave";
  String get tick_split_flap => "Paletas";
  String get tick_split_flap_mood => "repiqueteo de paletas";
  String get tick_clockwork => "Mecánico";
  String get tick_clockwork_mood => "tic de reloj";
  String get tick_woodblock => "Madera";
  String get tick_woodblock_mood => "golpe hueco";
  String get tick_digital => "Digital";
  String get tick_digital_mood => "pitido limpio";
  String get alarm_chime => "Carillón";
  String get alarm_chime_mood => "dos tonos";
  String get alarm_bell => "Campana";
  String get alarm_bell_mood => "campanada";
  String get alarm_beeps => "Pitidos";
  String get alarm_beeps_mood => "despertador";
  String get alarm_rising => "Creciente";
  String get alarm_rising_mood => "marimba";
  String get alarm_ring => "Timbre";
  String get alarm_ring_mood => "dos campanas";
  String get system_notifications => "Notificaciones del sistema";
  String get system_notifications_description =>
      "Recibe una notificación cuando termine un temporizador, aunque QuietFlip esté en segundo plano.";
  String get permission_denied =>
      "Las notificaciones de QuietFlip están desactivadas. Seguirás viendo y oyendo la alerta mientras la app esté abierta.";
  String get web_closed_tab_note =>
      "En un navegador, las alertas solo funcionan mientras esta pestaña siga abierta.";
  String get keep_screen_awake => "Mantener pantalla encendida";
  String get keep_screen_awake_description =>
      "Evita que la pantalla se apague mientras se muestra el reloj.";
  String current_time(String time) => "Hora actual $time";
  String time_remaining(String time) => "Tiempo restante $time";
  String elapsed(String time) => "Tiempo transcurrido $time";
  String get digit_brightness => "Brillo de los dígitos";
  String percent(String value) => "$value %";
  String get subtle_movement => "Movimiento sutil";
  String get subtle_movement_description =>
      "En pantalla completa, mueve el reloj unos píxeles cada minuto para que no se iluminen los mismos píxeles toda la noche. Reduce, pero no evita, el riesgo de marcas en la pantalla.";
  String get full_screen_note =>
      "La pantalla completa oculta los controles mientras QuietFlip esté abierta. La app debe seguir abierta. No es una pantalla de bloqueo ni un salvapantallas.";
  String get show_date => "Mostrar fecha";
  String current_time_and_date(String time, String date) =>
      "Hora actual $time, $date";
  String get orientation => "Orientación";
  String get orientation_auto => "Automática";
  String get orientation_landscape => "Horizontal";
  String get orientation_portrait => "Vertical";
  String get settings_card_size => "Tamaño de paleta";
  String get card_size_small => "Pequeño";
  String get card_size_medium => "Mediano";
  String get card_size_large => "Grande";
  String get settings_corners => "Esquinas";
  String get corners_square => "Rectas";
  String get corners_round => "Redondas";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Enfoque · Ronda $round";
  String pomodoro_break(int round) => "Descanso · Ronda $round";
  String get pomodoro_focus_done => "Enfoque terminado. Hora de descansar.";
  String get pomodoro_break_done => "Descanso terminado. A enfocarse.";
  String get start_focus => "Iniciar enfoque";
  String get start_break => "Iniciar descanso";
  String get skins_title => "Estilos";
  String get skins_customize => "Personalizar";
  String skins_customize_named(String name) => "Personalizar $name";
  String get skins_done => "Listo";
  String get skins_in_use => "En uso";
  String get skins_yours => "Tus estilos";
  String get skins_classic => "Clásicos";
  String get skins_bold => "Llamativos";
  String get skins_type => "Tipografía";
  String get skins_new => "Nuevo estilo";
  String get skins_from_current => "Desde el actual";
  String get customize_title => "Personalizar estilo";
  String get customize_name => "Nombre";
  String customize_copy_name(String name) => "Copia de $name";
  String get customize_font => "Fuente";
  String get customize_digits => "Dígitos";
  String get customize_card => "Paleta";
  String get customize_ground => "Fondo";
  String get customize_custom_colour => "Color personalizado";
  String get customize_hex_hint => "Hex, por ejemplo #FF7A00";
  String get customize_hex_invalid =>
      "Introduce seis dígitos hex, como #FF7A00.";
  String get customize_apply => "Aplicar";
  String get customize_low_contrast => "Puede que los dígitos se lean mal.";
  String get customize_details => "Detalles";
  String get customize_seconds => "Segundos";
  String get customize_seconds_off => "No";
  String get customize_seconds_badge => "Pequeños";
  String get customize_seconds_cards => "Paletas";
  String get customize_meridiem => "a. m. / p. m.";
  String get customize_meridiem_hidden => "Oculto";
  String get customize_meridiem_left => "Dentro";
  String get customize_meridiem_right => "Al lado";
  String get customize_save => "Guardar estilo";
  String get customize_reset => "Restablecer";
  String get customize_delete => "Eliminar estilo";
  String get skin_mono => "Mono";
  String get skin_paper => "Papel";
  String get skin_rose => "Rosa";
  String get skin_violet => "Violeta";
  String get skin_amber => "Ámbar";
  String get skin_signal => "Señal";
  String get skin_field => "Campo";
  String get skin_mint => "Menta";
  String get skin_cyan => "Cian";
  String get skin_taxi => "Taxi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Póster";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Órbita";
  String get skin_nightstand => "Mesilla";
  String get skin_studio => "Estudio";
  String get skin_arcade => "Arcade";
  String get skin_railway => "Estación";
  String get skin_desk => "Escritorio";
  String get skin_neon => "Neón";
  String get skin_minimal => "Mínimo";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Reloj";
  String get mode_stopwatch => "Cronómetro";
  String get action_start => "Iniciar";
  String get action_pause => "Pausar";
  String get action_resume => "Reanudar";
  String get action_reset => "Restablecer";
  String get action_restart => "Reiniciar";
  String get action_done => "Listo";
  String get action_skins => "Estilos";
  String get action_settings => "Ajustes";
  String get action_rotation => "Rotación de pantalla";
  String get action_timer_settings => "Ajustes del temporizador";
  String preset_minutes(int minutes) => "${minutes} min";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Temporizador de $minutes min";
  String preset_spoken_seconds(int seconds) => "Temporizador de $seconds s";
  String preset_spoken_both(int minutes, int seconds) =>
      "Temporizador de $minutes min y $seconds s";
  String get action_lap => "Vuelta";
  String lap_label(int number, String time) => "Vuelta $number  $time";
  String brightness_value(String percent) => "$percent %";
  String get settings_appearance => "Apariencia";
  String get settings_clock => "Reloj";
  String get settings_gestures => "Gestos";
  String get settings_timers => "Temporizadores";
  String get settings_sound => "Sonido y alertas";
  String get settings_awake => "Pantalla encendida";
  String get settings_shortcuts => "Atajos";
  String get settings_about => "Acerca de";
  String get theme_dark => "Oscuro";
  String get theme_system => "Según el sistema";
  String get gesture_swipes => "Deslizar";
  String get gesture_brightness => "Desliza arriba o abajo para el brillo";
  String get gesture_modes => "Desliza a los lados para cambiar de modo";
  String get gesture_footer =>
      "Desliza en cualquier parte del reloj. En Mac, Windows y la web, el brillo atenúa los dígitos en vez de la pantalla.";
  String get gesture_controls => "Controles";
  String get gesture_tap => "Toca para ver los controles";
  String get gesture_idle => "Ocultar controles tras";
  String gesture_idle_seconds(int seconds) => "${seconds} s";
  String get gesture_idle_never => "Nunca";
  String get gesture_controls_footer =>
      "Los controles se reducen a un punto y luego desaparecen.";
  String get timers_default => "Temporizador predeterminado";
  String get timers_start_runs => "Al iniciar";
  String get timers_presets => "Predefinidos";
  String get timers_add => "Añadir temporizador";
  String get timers_limit_footer =>
      "En la isla caben seis temporizadores. Elimina uno para añadir otro.";
  String timers_delete(String timer) => "Eliminar $timer";
  String get timers_duplicate => "Ya tienes este temporizador.";
  String get timers_picker_minutes => "Minutos";
  String get timers_picker_seconds => "Segundos";
  String get skins_view_all => "Ver todos";
  String get timers_pomodoro_focus => "Enfoque";
  String get timers_pomodoro_break => "Descanso";
  String timers_minutes(int minutes) => "$minutes min";
  String get sound_footer =>
      "La alerta de la app siempre suena, incluso con las notificaciones desactivadas.";
  String get shortcuts_touch => "Táctil";
  String get shortcuts_keyboard => "Teclado";
  String get touch_controls => "Mostrar u ocultar controles";
  String get shortcut_off => "No";
  String get key_start_pause => "Iniciar o pausar";
  String get key_change_mode => "Cambiar de modo";
  String get key_brightness => "Brillo";
  String get key_show_seconds => "Mostrar segundos";
  String get key_full_screen => "Pantalla completa";
  String get key_hide_controls => "Ocultar controles";
  String get key_dim => "Atenuar los dígitos";
  String get key_lap => "Vuelta (cronómetro)";
  String get key_rotation => "Rotación de pantalla";
  String get keycap_space => "Espacio";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Licencias";
  String get about_privacy => "Privacidad";
  String get about_privacy_value =>
      "Sin anuncios. Sin rastreo. La cuenta es opcional.";
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

class SyncMessages_es extends SyncMessages {
  final Messages_es _parent;
  const SyncMessages_es(this._parent) : super(_parent);
  String get account => "Cuenta";
  String get card_title_signed_out =>
      "Tus ajustes se quedan en este dispositivo";
  String get card_body_signed_out =>
      "Inicia sesión solo si los quieres en tus otros dispositivos.";
  String get card_title_on => "Sincronización activada";
  String get card_title_off => "Sincronización desactivada";
  String card_last_synced(String when) => "Última sincronización: $when";
  String get headline => "Tus ajustes se quedan en este dispositivo";
  String get body =>
      "QuietFlip nunca necesita una cuenta. Inicia sesión solo si quieres tu reloj, estilos y sonidos en tus otros dispositivos.";
  String get sign_in => "Iniciar sesión para sincronizar";
  String get sign_in_reason =>
      "Solo hace falta para sincronizar tus ajustes entre dispositivos.";
  String get what_syncs => "Qué se sincroniza";
  String get what_syncs_body =>
      "Tema, estilos, sonidos y ajustes del reloj y del temporizador.";
  String get stays_body =>
      "Se queda en este dispositivo: brillo, rotación, notificaciones y un temporizador en marcha.";
  String get sync_header => "Sincronización";
  String get sync_settings => "Sincronizar ajustes";
  String get sync_settings_note =>
      "Tus ajustes te acompañan a cada dispositivo donde inicies sesión.";
  String get last_synced => "Última sincronización";
  String get just_now => "Ahora mismo";
  String minutes_ago(int n) => "Hace $n min";
  String today_at(String time) => "Hoy a las $time";
  String get never => "Aún no";
  String get syncing => "Sincronizando…";
  String get waiting => "Esperando conexión";
  String get off_note =>
      "La sincronización está desactivada. Los cambios se quedan en este dispositivo.";
  String get failed_offline =>
      "No se pudo sincronizar: sin conexión. Se volverá a intentar cuando vuelvas a estar en línea.";
  String get failed_denied =>
      "No se pudo sincronizar: vuelve a iniciar sesión.";
  String get failed_unknown => "No se pudo sincronizar. Inténtalo de nuevo.";
  String get try_again => "Reintentar";
  String get sign_out_note =>
      "Al cerrar sesión, tus ajustes se quedan en este dispositivo.";
  String get delete_account => "Eliminar cuenta";
  String get delete_title => "¿Eliminar tu cuenta?";
  String get delete_body =>
      "Tus ajustes sincronizados se borran de la nube. Los ajustes de este dispositivo se mantienen.";
  String get delete_recent_login =>
      "Vuelve a iniciar sesión para eliminar tu cuenta";
  String get delete_failed =>
      "No se pudo eliminar tu cuenta. Inténtalo de nuevo.";
  String get provider_email => "Correo";
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
