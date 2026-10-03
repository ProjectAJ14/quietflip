// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'pt';
String get _localeName => 'pt';

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

class Messages_pt extends Messages {
  const Messages_pt();
  AppMessages_pt get app => AppMessages_pt(this);
  GenericMessages_pt get generic => GenericMessages_pt(this);
  CommonMessages_pt get common => CommonMessages_pt(this);
  AuthMessages_pt get auth => AuthMessages_pt(this);
  ProfileMessages_pt get profile => ProfileMessages_pt(this);
  NavMessages_pt get nav => NavMessages_pt(this);
  NotificationsMessages_pt get notifications => NotificationsMessages_pt(this);
  ErrorsMessages_pt get errors => ErrorsMessages_pt(this);
  ValidationMessages_pt get validation => ValidationMessages_pt(this);
  FilesMessages_pt get files => FilesMessages_pt(this);
  DeveloperMessages_pt get developer => DeveloperMessages_pt(this);
  ClockMessages_pt get clock => ClockMessages_pt(this);
  SyncMessages_pt get sync => SyncMessages_pt(this);
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

class AppMessages_pt extends AppMessages {
  final Messages_pt _parent;
  const AppMessages_pt(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description => "Relógio flip, timer e cronômetro sem anúncios.";
  String get welcome_to_app => "Boas-vindas ao QuietFlip!";
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

class GenericMessages_pt extends GenericMessages {
  final Messages_pt _parent;
  const GenericMessages_pt(this._parent) : super(_parent);
  String get ok => "OK";
  String get cancel => "Cancelar";
  String get save => "Salvar";
  String get delete => "Excluir";
  String get edit => "Editar";
  String get update => "Atualizar";
  String get submit => "Enviar";
  String get close => "Fechar";
  String get back => "Voltar";
  String get next => "Próximo";
  String get previous => "Anterior";
  String get done => "Concluído";
  String get loading => "Carregando...";
  String get error => "Erro";
  String get success => "Sucesso";
  String get warning => "Aviso";
  String get info => "Informação";
  String get retry => "Tentar novamente";
  String get refresh => "Atualizar";
  String get yes => "Sim";
  String get no => "Não";
  String get add => "+ Adicionar";
  String get try_again => "Tentar novamente";
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

class CommonMessages_pt extends CommonMessages {
  final Messages_pt _parent;
  const CommonMessages_pt(this._parent) : super(_parent);
  String get week => "Semana";
  String get month => "Mês";
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

class AuthMessages_pt extends AuthMessages {
  final Messages_pt _parent;
  const AuthMessages_pt(this._parent) : super(_parent);
  String get register => "Cadastrar";
  String get sign_in => "Entrar";
  String get sign_out => "Sair";
  String get dont_have_account => "Não tem uma conta? ";
  String get already_have_account => "Já tem uma conta? ";
  String get sign_out_confirmation => "Tem certeza de que quer sair?";
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

class ProfileMessages_pt extends ProfileMessages {
  final Messages_pt _parent;
  const ProfileMessages_pt(this._parent) : super(_parent);
  String get profile => "Perfil";
  String get settings => "Configurações";
  String get account => "Conta";
  String get personal_info => "Informações pessoais";
  String get privacy_settings => "Configurações de privacidade";
  String get name => "Nome";
  String get email_address => "Endereço de e-mail";
  String get phone_number => "Número de telefone";
  String get date_of_birth => "Data de nascimento";
  String get delete_confirmation => "Confirmar exclusão";
  String get delete_confirmation_message =>
      "Tem certeza de que quer excluir este item? Esta ação não pode ser desfeita.";
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

class NavMessages_pt extends NavMessages {
  final Messages_pt _parent;
  const NavMessages_pt(this._parent) : super(_parent);
  String get home => "Início";
  String get dashboard => "Painel";
  String get explore => "Explorar";
  String get explore_placeholder =>
      "Sua segunda aba. Substitua por um recurso real.";
  String get profile => "Perfil";
  String get settings => "Configurações";
  String get notifications => "Notificações";
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

class NotificationsMessages_pt extends NotificationsMessages {
  final Messages_pt _parent;
  const NotificationsMessages_pt(this._parent) : super(_parent);
  String get title => "Notificações";
  String get mark_as_read => "Marcar como lida";
  String get mark_all_read => "Marcar todas como lidas";
  String get delete => "Excluir";
  String get filter_all => "Todas";
  String get filter_unread => "Não lidas";
  String get filter_read => "Lidas";
  String get type_reminder => "Lembrete";
  String get type_alert => "Alerta";
  String get type_promotion => "Promoção";
  String get type_system => "Sistema";
  String get type_custom => "Personalizada";
  String get empty_title => "Nenhuma notificação";
  String get empty_description =>
      "Tudo em dia! Novas notificações aparecerão aqui.";
  String get delete_confirmation_title => "Excluir notificação?";
  String get delete_confirmation_message =>
      "Esta notificação será removida da sua lista permanentemente.";
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

class ErrorsMessages_pt extends ErrorsMessages {
  final Messages_pt _parent;
  const ErrorsMessages_pt(this._parent) : super(_parent);
  String get network_error => "Erro de rede. Verifique sua conexão.";
  String get unknown_error => "Ocorreu um erro desconhecido.";
  String get validation_error => "Verifique os dados e tente novamente.";
  String get server_error => "Erro no servidor. Tente novamente mais tarde.";
  String get default_error_message => "Ops! Algo deu errado. Tente novamente.";
  String get user_not_found =>
      "Usuário não encontrado. Verifique suas credenciais.";
  String get default_error_description =>
      "Ocorreu um erro ao processar sua solicitação. Pedimos desculpas pelo transtorno. Tente novamente mais tarde ou fale com o suporte se o problema continuar.";
  String get page_not_found => "Página não encontrada";
  String get page_not_found_description =>
      "A página que você procura não existe.";
  String get unexpected_error => "Ocorreu um erro inesperado.";
  String get redirect_error => "Erro de redirecionamento";
  String get bad_request => "Solicitação inválida. Verifique os dados.";
  String get unauthorized => "Autenticação necessária. Entre novamente.";
  String get forbidden => "Acesso negado. Você não tem permissão.";
  String get not_found => "Recurso solicitado não encontrado.";
  String get conflict => "Conflito de dados. Atualize e tente novamente.";
  String get unprocessable_entity =>
      "Formato de dados inválido. Verifique os dados.";
  String get internal_server_error =>
      "Erro no servidor. Tente novamente mais tarde.";
  String get connection_timeout =>
      "Tempo de conexão esgotado. Verifique sua internet.";
  String get receive_timeout =>
      "Tempo da solicitação esgotado. Tente novamente.";
  String get send_timeout => "Tempo de envio esgotado. Tente novamente.";
  String get no_internet => "Sem conexão com a internet. Verifique sua rede.";
  String get unknown_network => "Ocorreu um erro de rede. Tente novamente.";
  String format_exception_message(String code, String postfix) =>
      "Estes dados estão com a fantasia errada, não os reconheço [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Estes dados não são o que eu esperava, não consigo processá-los [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, não encontro esse item na lista [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Ops! Esse número está bem fora da minha zona de conforto [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Ei! Tem algo errado com o que você me passou [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Estou meio confuso sobre o que devo fazer agora [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Este recurso ainda está em construção [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Desculpe, ainda não sei fazer isso [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Opa! Coisas demais acontecendo ao mesmo tempo [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Minha cabeça está cheia! Preciso liberar espaço [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Fiquei preso num loop e estou tonto [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Aconteceu algo inesperado, mas não se preocupe [$code] $postfix";
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

class ValidationMessages_pt extends ValidationMessages {
  final Messages_pt _parent;
  const ValidationMessages_pt(this._parent) : super(_parent);
  String get required_field => "Este campo é obrigatório";
  String get invalid_email => "Digite um endereço de e-mail válido";
  String get password_too_short => "A senha deve ter pelo menos 8 caracteres";
  String get passwords_dont_match => "As senhas não coincidem";
  String invalid_key_config(String of, String key) =>
      "Configuração inválida para $key em $of. Verifique suas configurações.";
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

class FilesMessages_pt extends FilesMessages {
  final Messages_pt _parent;
  const FilesMessages_pt(this._parent) : super(_parent);
  String get info_title => "Informações do arquivo";
  String get name => "Nome do arquivo";
  String get type => "Tipo de arquivo";
  String get extension => "Extensão do arquivo";
  String get size => "Tamanho do arquivo";
  String get path => "Caminho do arquivo";
  String get copy_hint =>
      "Toque em um campo para copiar para a área de transferência";
  String copied(String field) => "$field copiado para a área de transferência";
  String image_type(String format) => "Imagem $format";
  String get image_file => "Arquivo de imagem";
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

class DeveloperMessages_pt extends DeveloperMessages {
  final Messages_pt _parent;
  const DeveloperMessages_pt(this._parent) : super(_parent);
  String get no_viewer => "Este registro não tem visualizador interativo.";
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

class ClockMessages_pt extends ClockMessages {
  final Messages_pt _parent;
  const ClockMessages_pt(this._parent) : super(_parent);
  String get clock => "Relógio";
  String get stopwatch => "Cronômetro";
  String get modes => "Modo";
  String get settings => "Configurações";
  String get times_up => "Tempo esgotado";
  String get timer_finished_title => "Tempo esgotado";
  String get timer_finished_body => "Seu timer do QuietFlip terminou.";
  String get alerts_channel => "Alertas do timer";
  String get show_controls => "Toque ou mova o mouse para ver os controles";
  String get theme => "Tema";
  String get theme_light => "Claro";
  String get use_24h => "Formato 24 horas";
  String get show_seconds => "Mostrar segundos";
  String get sound_tick_group => "Tique";
  String get sound_tick_hint => "toca a cada virada";
  String get sound_alarm_group => "Alarme";
  String get sound_alarm_hint => "repete até ser dispensado, máx. 60 s";
  String get tick_sound => "Som de tique";
  String get tick_sound_description => "Um som suave a cada virada de placa";
  String get alarm_sound => "Som de alarme";
  String get alarm_sound_description =>
      "Toca quando um timer ou uma fase Pomodoro termina";
  String get tick_classic => "Clássico";
  String get tick_classic_mood => "clique suave";
  String get tick_split_flap => "Placas";
  String get tick_split_flap_mood => "placas batendo";
  String get tick_clockwork => "Mecânico";
  String get tick_clockwork_mood => "tique de relógio";
  String get tick_woodblock => "Bloco de madeira";
  String get tick_woodblock_mood => "batida oca";
  String get tick_digital => "Digital";
  String get tick_digital_mood => "bipe limpo";
  String get alarm_chime => "Carrilhão";
  String get alarm_chime_mood => "dois tons";
  String get alarm_bell => "Sino";
  String get alarm_bell_mood => "badalada";
  String get alarm_beeps => "Bipes";
  String get alarm_beeps_mood => "despertador";
  String get alarm_rising => "Crescente";
  String get alarm_rising_mood => "marimba";
  String get alarm_ring => "Campainha";
  String get alarm_ring_mood => "dois sinos";
  String get system_notifications => "Notificações do sistema";
  String get system_notifications_description =>
      "Receba uma notificação quando um timer terminar, mesmo com o QuietFlip em segundo plano.";
  String get permission_denied =>
      "As notificações do QuietFlip estão desativadas. Você ainda verá e ouvirá o alerta enquanto o app estiver aberto.";
  String get web_closed_tab_note =>
      "No navegador, os alertas só funcionam enquanto esta aba estiver aberta.";
  String get keep_screen_awake => "Manter tela ligada";
  String get keep_screen_awake_description =>
      "Impede que a tela apague enquanto o relógio é exibido.";
  String current_time(String time) => "Hora atual $time";
  String time_remaining(String time) => "Tempo restante $time";
  String elapsed(String time) => "Tempo decorrido $time";
  String get digit_brightness => "Brilho dos dígitos";
  String percent(String value) => "$value%";
  String get subtle_movement => "Movimento sutil";
  String get subtle_movement_description =>
      "Em tela cheia, move o relógio alguns pixels por minuto para que os mesmos pixels não fiquem acesos a noite toda. Reduz, mas não evita, o risco de marcas na tela.";
  String get full_screen_note =>
      "A tela cheia oculta os controles enquanto o QuietFlip está aberto. O app precisa ficar aberto. Não é uma tela de bloqueio nem um protetor de tela.";
  String get show_date => "Mostrar data";
  String current_time_and_date(String time, String date) =>
      "Hora atual $time, $date";
  String get orientation => "Orientação";
  String get orientation_auto => "Automática";
  String get orientation_landscape => "Paisagem";
  String get orientation_portrait => "Retrato";
  String get settings_card_size => "Tamanho da placa";
  String get card_size_small => "Pequeno";
  String get card_size_medium => "Médio";
  String get card_size_large => "Grande";
  String get settings_corners => "Cantos";
  String get corners_square => "Retos";
  String get corners_round => "Arredondados";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Foco · Rodada $round";
  String pomodoro_break(int round) => "Pausa · Rodada $round";
  String get pomodoro_focus_done => "Foco concluído. Hora da pausa.";
  String get pomodoro_break_done => "Pausa encerrada. De volta ao foco.";
  String get start_focus => "Iniciar foco";
  String get start_break => "Iniciar pausa";
  String get skins_title => "Temas visuais";
  String get skins_customize => "Personalizar";
  String skins_customize_named(String name) => "Personalizar $name";
  String get skins_done => "Concluído";
  String get skins_in_use => "Em uso";
  String get skins_yours => "Seus visuais";
  String get skins_classic => "Clássicos";
  String get skins_bold => "Marcantes";
  String get skins_type => "Tipografia";
  String get skins_new => "Novo visual";
  String get skins_from_current => "Do atual";
  String get customize_title => "Personalizar visual";
  String get customize_name => "Nome";
  String customize_copy_name(String name) => "Cópia de $name";
  String get customize_font => "Fonte";
  String get customize_digits => "Dígitos";
  String get customize_card => "Placa";
  String get customize_ground => "Fundo";
  String get customize_custom_colour => "Cor personalizada";
  String get customize_hex_hint => "Hex, por exemplo #FF7A00";
  String get customize_hex_invalid => "Digite seis dígitos hex, como #FF7A00.";
  String get customize_apply => "Aplicar";
  String get customize_low_contrast =>
      "Os dígitos podem ficar difíceis de ler.";
  String get customize_details => "Detalhes";
  String get customize_seconds => "Segundos";
  String get customize_seconds_off => "Não";
  String get customize_seconds_badge => "Pequenos";
  String get customize_seconds_cards => "Placas";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Oculto";
  String get customize_meridiem_left => "Dentro";
  String get customize_meridiem_right => "Ao lado";
  String get customize_save => "Salvar visual";
  String get customize_reset => "Redefinir";
  String get customize_delete => "Excluir visual";
  String get skin_mono => "Mono";
  String get skin_paper => "Papel";
  String get skin_rose => "Rosa";
  String get skin_violet => "Violeta";
  String get skin_amber => "Âmbar";
  String get skin_signal => "Sinal";
  String get skin_field => "Campo";
  String get skin_mint => "Menta";
  String get skin_cyan => "Ciano";
  String get skin_taxi => "Táxi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Pôster";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Órbita";
  String get skin_nightstand => "Criado-mudo";
  String get skin_studio => "Estúdio";
  String get skin_arcade => "Fliperama";
  String get skin_railway => "Estação";
  String get skin_desk => "Escrivaninha";
  String get skin_neon => "Neon";
  String get skin_minimal => "Mínimo";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Relógio";
  String get mode_stopwatch => "Cronômetro";
  String get action_start => "Iniciar";
  String get action_pause => "Pausar";
  String get action_resume => "Retomar";
  String get action_reset => "Zerar";
  String get action_restart => "Reiniciar";
  String get action_done => "Concluído";
  String get action_skins => "Visuais";
  String get action_settings => "Configurações";
  String get action_rotation => "Rotação da tela";
  String get action_timer_settings => "Configurações do timer";
  String preset_minutes(int minutes) => "${minutes} min";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Timer de $minutes min";
  String preset_spoken_seconds(int seconds) => "Timer de $seconds s";
  String preset_spoken_both(int minutes, int seconds) =>
      "Timer de $minutes min e $seconds s";
  String get action_lap => "Volta";
  String lap_label(int number, String time) => "Volta $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "Aparência";
  String get settings_clock => "Relógio";
  String get settings_gestures => "Gestos";
  String get settings_timers => "Timers";
  String get settings_sound => "Som e alertas";
  String get settings_awake => "Tela ligada";
  String get settings_shortcuts => "Atalhos";
  String get settings_about => "Sobre";
  String get theme_dark => "Escuro";
  String get theme_system => "Igual ao sistema";
  String get gesture_swipes => "Deslizes";
  String get gesture_brightness =>
      "Deslize para cima ou para baixo para o brilho";
  String get gesture_modes => "Deslize para os lados para mudar de modo";
  String get gesture_footer =>
      "Deslize em qualquer parte do relógio. No Mac, no Windows e na web, o brilho escurece os dígitos em vez da tela.";
  String get gesture_controls => "Controles";
  String get gesture_tap => "Toque para ver os controles";
  String get gesture_idle => "Ocultar controles após";
  String gesture_idle_seconds(int seconds) => "${seconds} s";
  String get gesture_idle_never => "Nunca";
  String get gesture_controls_footer =>
      "Os controles viram um ponto e depois somem.";
  String get timers_default => "Timer padrão";
  String get timers_start_runs => "Ao iniciar";
  String get timers_presets => "Predefinições";
  String get timers_add => "Adicionar timer";
  String get timers_limit_footer =>
      "Cabem seis timers na ilha. Exclua um para adicionar outro.";
  String timers_delete(String timer) => "Excluir $timer";
  String get timers_duplicate => "Você já tem este timer.";
  String get timers_picker_minutes => "Minutos";
  String get timers_picker_seconds => "Segundos";
  String get skins_view_all => "Ver todos";
  String get timers_pomodoro_focus => "Foco";
  String get timers_pomodoro_break => "Pausa";
  String timers_minutes(int minutes) => "$minutes min";
  String get sound_footer =>
      "O alerta no app sempre toca, mesmo com as notificações desativadas.";
  String get shortcuts_touch => "Toque";
  String get shortcuts_keyboard => "Teclado";
  String get touch_controls => "Mostrar ou ocultar controles";
  String get shortcut_off => "Não";
  String get key_start_pause => "Iniciar ou pausar";
  String get key_change_mode => "Mudar de modo";
  String get key_brightness => "Brilho";
  String get key_show_seconds => "Mostrar segundos";
  String get key_full_screen => "Tela cheia";
  String get key_hide_controls => "Ocultar controles";
  String get key_dim => "Escurecer os dígitos";
  String get key_lap => "Volta (cronômetro)";
  String get key_rotation => "Rotação da tela";
  String get keycap_space => "Espaço";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Licenças";
  String get about_privacy => "Privacidade";
  String get about_privacy_value =>
      "Sem anúncios. Sem rastreamento. A conta é opcional.";
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

class SyncMessages_pt extends SyncMessages {
  final Messages_pt _parent;
  const SyncMessages_pt(this._parent) : super(_parent);
  String get account => "Conta";
  String get card_title_signed_out =>
      "Suas configurações ficam neste dispositivo";
  String get card_body_signed_out =>
      "Entre só se quiser levá-las para seus outros dispositivos.";
  String get card_title_on => "Sincronização ativada";
  String get card_title_off => "Sincronização desativada";
  String card_last_synced(String when) => "Última sincronização: $when";
  String get headline => "Suas configurações ficam neste dispositivo";
  String get body =>
      "O QuietFlip nunca exige uma conta. Entre só se quiser seu relógio, visuais e sons nos seus outros dispositivos.";
  String get sign_in => "Entrar para sincronizar";
  String get sign_in_reason =>
      "Só é necessário para sincronizar suas configurações entre dispositivos.";
  String get what_syncs => "O que é sincronizado";
  String get what_syncs_body =>
      "Tema, visuais, sons e configurações do relógio e do timer.";
  String get stays_body =>
      "Fica neste dispositivo: brilho, rotação, notificações e um timer em andamento.";
  String get sync_header => "Sincronização";
  String get sync_settings => "Sincronizar configurações";
  String get sync_settings_note =>
      "Suas configurações acompanham você em cada dispositivo em que entrar.";
  String get last_synced => "Última sincronização";
  String get just_now => "Agora mesmo";
  String minutes_ago(int n) => "Há $n min";
  String today_at(String time) => "Hoje às $time";
  String get never => "Ainda não";
  String get syncing => "Sincronizando…";
  String get waiting => "Aguardando conexão";
  String get off_note =>
      "A sincronização está desativada. As alterações ficam neste dispositivo.";
  String get failed_offline =>
      "Não foi possível sincronizar: sem conexão. Vamos tentar de novo quando você estiver on-line.";
  String get failed_denied => "Não foi possível sincronizar: entre novamente.";
  String get failed_unknown => "Não foi possível sincronizar. Tente novamente.";
  String get try_again => "Tentar novamente";
  String get sign_out_note =>
      "Ao sair, suas configurações continuam neste dispositivo.";
  String get delete_account => "Excluir conta";
  String get delete_title => "Excluir sua conta?";
  String get delete_body =>
      "Suas configurações sincronizadas são removidas da nuvem. As configurações deste dispositivo continuam.";
  String get delete_recent_login => "Entre novamente para excluir sua conta";
  String get delete_failed =>
      "Não foi possível excluir sua conta. Tente novamente.";
  String get provider_email => "E-mail";
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
