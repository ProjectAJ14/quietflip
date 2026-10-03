// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'fr';
String get _localeName => 'fr';

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

class Messages_fr extends Messages {
  const Messages_fr();
  AppMessages_fr get app => AppMessages_fr(this);
  GenericMessages_fr get generic => GenericMessages_fr(this);
  CommonMessages_fr get common => CommonMessages_fr(this);
  AuthMessages_fr get auth => AuthMessages_fr(this);
  ProfileMessages_fr get profile => ProfileMessages_fr(this);
  NavMessages_fr get nav => NavMessages_fr(this);
  NotificationsMessages_fr get notifications => NotificationsMessages_fr(this);
  ErrorsMessages_fr get errors => ErrorsMessages_fr(this);
  ValidationMessages_fr get validation => ValidationMessages_fr(this);
  FilesMessages_fr get files => FilesMessages_fr(this);
  DeveloperMessages_fr get developer => DeveloperMessages_fr(this);
  ClockMessages_fr get clock => ClockMessages_fr(this);
  SyncMessages_fr get sync => SyncMessages_fr(this);
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

class AppMessages_fr extends AppMessages {
  final Messages_fr _parent;
  const AppMessages_fr(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "Horloge à palettes, minuteur et chronomètre, sans publicité.";
  String get welcome_to_app => "Bienvenue dans QuietFlip !";
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

class GenericMessages_fr extends GenericMessages {
  final Messages_fr _parent;
  const GenericMessages_fr(this._parent) : super(_parent);
  String get ok => "OK";
  String get cancel => "Annuler";
  String get save => "Enregistrer";
  String get delete => "Supprimer";
  String get edit => "Modifier";
  String get update => "Mettre à jour";
  String get submit => "Envoyer";
  String get close => "Fermer";
  String get back => "Retour";
  String get next => "Suivant";
  String get previous => "Précédent";
  String get done => "OK";
  String get loading => "Chargement…";
  String get error => "Erreur";
  String get success => "Opération réussie";
  String get warning => "Attention";
  String get info => "Info";
  String get retry => "Réessayer";
  String get refresh => "Actualiser";
  String get yes => "Oui";
  String get no => "Non";
  String get add => "+ Ajouter";
  String get try_again => "Réessayer";
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

class CommonMessages_fr extends CommonMessages {
  final Messages_fr _parent;
  const CommonMessages_fr(this._parent) : super(_parent);
  String get week => "Semaine";
  String get month => "Mois";
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

class AuthMessages_fr extends AuthMessages {
  final Messages_fr _parent;
  const AuthMessages_fr(this._parent) : super(_parent);
  String get register => "S’inscrire";
  String get sign_in => "Se connecter";
  String get sign_out => "Se déconnecter";
  String get dont_have_account => "Pas encore de compte ? ";
  String get already_have_account => "Vous avez déjà un compte ? ";
  String get sign_out_confirmation => "Voulez-vous vraiment vous déconnecter ?";
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

class ProfileMessages_fr extends ProfileMessages {
  final Messages_fr _parent;
  const ProfileMessages_fr(this._parent) : super(_parent);
  String get profile => "Profil";
  String get settings => "Réglages";
  String get account => "Compte";
  String get personal_info => "Informations personnelles";
  String get privacy_settings => "Confidentialité";
  String get name => "Nom";
  String get email_address => "Adresse e-mail";
  String get phone_number => "Numéro de téléphone";
  String get date_of_birth => "Date de naissance";
  String get delete_confirmation => "Confirmer la suppression";
  String get delete_confirmation_message =>
      "Voulez-vous vraiment supprimer cet élément ? Cette action est irréversible.";
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

class NavMessages_fr extends NavMessages {
  final Messages_fr _parent;
  const NavMessages_fr(this._parent) : super(_parent);
  String get home => "Accueil";
  String get dashboard => "Tableau de bord";
  String get explore => "Explorer";
  String get explore_placeholder =>
      "Votre deuxième onglet. Remplacez-le par une vraie fonctionnalité.";
  String get profile => "Profil";
  String get settings => "Réglages";
  String get notifications => "Notifications";
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

class NotificationsMessages_fr extends NotificationsMessages {
  final Messages_fr _parent;
  const NotificationsMessages_fr(this._parent) : super(_parent);
  String get title => "Notifications";
  String get mark_as_read => "Marquer comme lu";
  String get mark_all_read => "Tout marquer comme lu";
  String get delete => "Supprimer";
  String get filter_all => "Toutes";
  String get filter_unread => "Non lues";
  String get filter_read => "Lues";
  String get type_reminder => "Rappel";
  String get type_alert => "Alerte";
  String get type_promotion => "Promotion";
  String get type_system => "Système";
  String get type_custom => "Personnalisée";
  String get empty_title => "Aucune notification";
  String get empty_description =>
      "Vous êtes à jour ! Les nouvelles notifications apparaîtront ici.";
  String get delete_confirmation_title => "Supprimer la notification ?";
  String get delete_confirmation_message =>
      "Cette notification sera définitivement retirée de votre liste.";
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

class ErrorsMessages_fr extends ErrorsMessages {
  final Messages_fr _parent;
  const ErrorsMessages_fr(this._parent) : super(_parent);
  String get network_error => "Erreur réseau. Vérifiez votre connexion.";
  String get unknown_error => "Une erreur inconnue est survenue.";
  String get validation_error => "Vérifiez votre saisie et réessayez.";
  String get server_error => "Erreur du serveur. Réessayez plus tard.";
  String get default_error_message =>
      "Oups ! Un problème est survenu. Réessayez.";
  String get user_not_found =>
      "Utilisateur introuvable. Vérifiez vos identifiants.";
  String get default_error_description =>
      "Une erreur s’est produite lors du traitement de votre demande. Veuillez nous en excuser. Réessayez plus tard ou contactez l’assistance si le problème persiste.";
  String get page_not_found => "Page introuvable";
  String get page_not_found_description =>
      "La page que vous cherchez n’existe pas.";
  String get unexpected_error => "Une erreur inattendue est survenue.";
  String get redirect_error => "Erreur de redirection";
  String get bad_request => "Requête invalide. Vérifiez votre saisie.";
  String get unauthorized => "Authentification requise. Reconnectez-vous.";
  String get forbidden => "Accès refusé. Vous n’avez pas l’autorisation.";
  String get not_found => "Ressource demandée introuvable.";
  String get conflict => "Conflit de données. Actualisez et réessayez.";
  String get unprocessable_entity =>
      "Format de données invalide. Vérifiez votre saisie.";
  String get internal_server_error => "Erreur du serveur. Réessayez plus tard.";
  String get connection_timeout =>
      "Délai de connexion dépassé. Vérifiez votre connexion Internet.";
  String get receive_timeout => "Délai de la requête dépassé. Réessayez.";
  String get send_timeout => "Délai d’envoi dépassé. Réessayez.";
  String get no_internet => "Aucune connexion Internet. Vérifiez votre réseau.";
  String get unknown_network => "Une erreur réseau est survenue. Réessayez.";
  String format_exception_message(String code, String postfix) =>
      "Ces données sont déguisées, je ne les reconnais pas [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Ces données ne sont pas celles attendues, je ne peux pas les traiter [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, je ne trouve pas cet élément dans la liste [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Oups ! Ce nombre sort largement de ma zone de confort [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Hé ! Quelque chose cloche dans ce que vous m’avez donné [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Je ne sais plus trop ce que je dois faire maintenant [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Cette fonctionnalité est encore en chantier [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Désolé, je ne sais pas encore faire ça [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Oh là ! Trop de choses en même temps [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Ma mémoire est pleine ! Il faut faire de la place [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Je tourne en boucle et j’ai le tournis [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Un imprévu est survenu, mais pas d’inquiétude [$code] $postfix";
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

class ValidationMessages_fr extends ValidationMessages {
  final Messages_fr _parent;
  const ValidationMessages_fr(this._parent) : super(_parent);
  String get required_field => "Ce champ est obligatoire";
  String get invalid_email => "Saisissez une adresse e-mail valide";
  String get password_too_short =>
      "Le mot de passe doit comporter au moins 8 caractères";
  String get passwords_dont_match => "Les mots de passe ne correspondent pas";
  String invalid_key_config(String of, String key) =>
      "Configuration invalide pour $key dans $of. Vérifiez vos réglages.";
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

class FilesMessages_fr extends FilesMessages {
  final Messages_fr _parent;
  const FilesMessages_fr(this._parent) : super(_parent);
  String get info_title => "Informations sur le fichier";
  String get name => "Nom du fichier";
  String get type => "Type de fichier";
  String get extension => "Extension";
  String get size => "Taille";
  String get path => "Chemin";
  String get copy_hint => "Touchez un champ pour le copier";
  String copied(String field) => "$field copié dans le presse-papiers";
  String image_type(String format) => "Image $format";
  String get image_file => "Fichier image";
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

class DeveloperMessages_fr extends DeveloperMessages {
  final Messages_fr _parent;
  const DeveloperMessages_fr(this._parent) : super(_parent);
  String get no_viewer => "Ce journal n’a pas de visionneuse interactive.";
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

class ClockMessages_fr extends ClockMessages {
  final Messages_fr _parent;
  const ClockMessages_fr(this._parent) : super(_parent);
  String get clock => "Horloge";
  String get stopwatch => "Chronomètre";
  String get modes => "Mode";
  String get settings => "Réglages";
  String get times_up => "Temps écoulé";
  String get timer_finished_title => "Temps écoulé";
  String get timer_finished_body => "Votre minuteur QuietFlip est terminé.";
  String get alerts_channel => "Alertes du minuteur";
  String get show_controls =>
      "Touchez ou bougez la souris pour afficher les commandes";
  String get theme => "Thème";
  String get theme_light => "Clair";
  String get use_24h => "Format 24 h";
  String get show_seconds => "Afficher les secondes";
  String get sound_tick_group => "Tic";
  String get sound_tick_hint => "à chaque bascule";
  String get sound_alarm_group => "Alarme";
  String get sound_alarm_hint => "en boucle jusqu’à l’arrêt, 60 s max";
  String get tick_sound => "Son du tic";
  String get tick_sound_description =>
      "Un son doux à chaque bascule de palette";
  String get alarm_sound => "Son de l’alarme";
  String get alarm_sound_description =>
      "Retentit à la fin d’un minuteur ou d’une phase Pomodoro";
  String get tick_classic => "Classique";
  String get tick_classic_mood => "clic doux";
  String get tick_split_flap => "Palettes";
  String get tick_split_flap_mood => "palettes qui claquent";
  String get tick_clockwork => "Mécanique";
  String get tick_clockwork_mood => "tic de montre";
  String get tick_woodblock => "Bloc de bois";
  String get tick_woodblock_mood => "coup creux";
  String get tick_digital => "Numérique";
  String get tick_digital_mood => "bip net";
  String get alarm_chime => "Carillon";
  String get alarm_chime_mood => "deux notes";
  String get alarm_bell => "Cloche";
  String get alarm_bell_mood => "cloche frappée";
  String get alarm_beeps => "Bips";
  String get alarm_beeps_mood => "réveil";
  String get alarm_rising => "Crescendo";
  String get alarm_rising_mood => "marimba";
  String get alarm_ring => "Sonnerie";
  String get alarm_ring_mood => "deux cloches";
  String get system_notifications => "Notifications système";
  String get system_notifications_description =>
      "Recevez une notification à la fin d’un minuteur, même si QuietFlip est en arrière-plan.";
  String get permission_denied =>
      "Les notifications sont désactivées pour QuietFlip. Vous verrez et entendrez quand même l’alerte tant que l’app est ouverte.";
  String get web_closed_tab_note =>
      "Dans un navigateur, les alertes ne fonctionnent que si cet onglet reste ouvert.";
  String get keep_screen_awake => "Garder l’écran allumé";
  String get keep_screen_awake_description =>
      "Empêche la mise en veille de l’écran tant que l’horloge est affichée.";
  String current_time(String time) => "Heure actuelle $time";
  String time_remaining(String time) => "Temps restant $time";
  String elapsed(String time) => "Temps écoulé $time";
  String get digit_brightness => "Luminosité des chiffres";
  String percent(String value) => "$value %";
  String get subtle_movement => "Léger déplacement";
  String get subtle_movement_description =>
      "En plein écran, l’horloge se décale de quelques pixels chaque minute pour que les mêmes pixels ne restent pas allumés toute la nuit. Réduit le risque de marquage, sans l’éliminer.";
  String get full_screen_note =>
      "Le plein écran masque les commandes tant que QuietFlip reste ouvert. L’app doit rester ouverte. Ce n’est ni un écran de verrouillage ni un économiseur d’écran.";
  String get show_date => "Afficher la date";
  String current_time_and_date(String time, String date) =>
      "Heure actuelle $time, $date";
  String get orientation => "Orientation";
  String get orientation_auto => "Auto";
  String get orientation_landscape => "Paysage";
  String get orientation_portrait => "Portrait";
  String get settings_card_size => "Taille des palettes";
  String get card_size_small => "Petite";
  String get card_size_medium => "Moyenne";
  String get card_size_large => "Grande";
  String get settings_corners => "Coins";
  String get corners_square => "Carrés";
  String get corners_round => "Arrondis";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Concentration · Cycle $round";
  String pomodoro_break(int round) => "Pause · Cycle $round";
  String get pomodoro_focus_done =>
      "Concentration terminée. C’est l’heure de la pause.";
  String get pomodoro_break_done =>
      "Pause terminée. Retour à la concentration.";
  String get start_focus => "Se concentrer";
  String get start_break => "Faire une pause";
  String get skins_title => "Habillages";
  String get skins_customize => "Personnaliser";
  String skins_customize_named(String name) => "Personnaliser $name";
  String get skins_done => "OK";
  String get skins_in_use => "Actif";
  String get skins_yours => "Vos habillages";
  String get skins_classic => "Classiques";
  String get skins_bold => "Audacieux";
  String get skins_type => "Typo";
  String get skins_new => "Nouvel habillage";
  String get skins_from_current => "À partir de l’actuel";
  String get customize_title => "Personnaliser l’habillage";
  String get customize_name => "Nom";
  String customize_copy_name(String name) => "Copie de $name";
  String get customize_font => "Police";
  String get customize_digits => "Chiffres";
  String get customize_card => "Palette";
  String get customize_ground => "Fond";
  String get customize_custom_colour => "Couleur personnalisée";
  String get customize_hex_hint => "Hex, par exemple #FF7A00";
  String get customize_hex_invalid =>
      "Saisissez six chiffres hex, comme #FF7A00.";
  String get customize_apply => "Appliquer";
  String get customize_low_contrast =>
      "Les chiffres risquent d’être peu lisibles.";
  String get customize_details => "Détails";
  String get customize_seconds => "Secondes";
  String get customize_seconds_off => "Non";
  String get customize_seconds_badge => "Petites";
  String get customize_seconds_cards => "Palettes";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Masqué";
  String get customize_meridiem_left => "Dedans";
  String get customize_meridiem_right => "À côté";
  String get customize_save => "Enregistrer";
  String get customize_reset => "Réinitialiser";
  String get customize_delete => "Supprimer l’habillage";
  String get skin_mono => "Mono";
  String get skin_paper => "Papier";
  String get skin_rose => "Rose";
  String get skin_violet => "Violet";
  String get skin_amber => "Ambre";
  String get skin_signal => "Signal";
  String get skin_field => "Champ";
  String get skin_mint => "Menthe";
  String get skin_cyan => "Cyan";
  String get skin_taxi => "Taxi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Affiche";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Orbite";
  String get skin_nightstand => "Chevet";
  String get skin_studio => "Studio";
  String get skin_arcade => "Arcade";
  String get skin_railway => "Gare";
  String get skin_desk => "Bureau";
  String get skin_neon => "Néon";
  String get skin_minimal => "Minimal";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Horloge";
  String get mode_stopwatch => "Chronomètre";
  String get action_start => "Démarrer";
  String get action_pause => "Pause";
  String get action_resume => "Reprendre";
  String get action_reset => "Réinitialiser";
  String get action_restart => "Relancer";
  String get action_done => "OK";
  String get action_skins => "Habillages";
  String get action_settings => "Réglages";
  String get action_rotation => "Rotation de l’écran";
  String get action_timer_settings => "Réglages du minuteur";
  String preset_minutes(int minutes) => "${minutes} min";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Minuteur de $minutes min";
  String preset_spoken_seconds(int seconds) => "Minuteur de $seconds s";
  String preset_spoken_both(int minutes, int seconds) =>
      "Minuteur de $minutes min $seconds s";
  String get action_lap => "Tour";
  String lap_label(int number, String time) => "Tour $number  $time";
  String brightness_value(String percent) => "$percent %";
  String get settings_appearance => "Apparence";
  String get settings_clock => "Horloge";
  String get settings_gestures => "Gestes";
  String get settings_timers => "Minuteurs";
  String get settings_sound => "Sons et alertes";
  String get settings_awake => "Veille";
  String get settings_shortcuts => "Raccourcis";
  String get settings_about => "À propos";
  String get theme_dark => "Sombre";
  String get theme_system => "Système";
  String get gesture_swipes => "Balayages";
  String get gesture_brightness =>
      "Balayez vers le haut ou le bas pour la luminosité";
  String get gesture_modes => "Balayez latéralement pour changer de mode";
  String get gesture_footer =>
      "Balayez n’importe où sur l’horloge. Sur Mac, Windows et le web, la luminosité atténue les chiffres plutôt que l’écran.";
  String get gesture_controls => "Commandes";
  String get gesture_tap => "Toucher pour afficher les commandes";
  String get gesture_idle => "Masquer les commandes après";
  String gesture_idle_seconds(int seconds) => "${seconds} s";
  String get gesture_idle_never => "Jamais";
  String get gesture_controls_footer =>
      "Les commandes se réduisent à un point, puis disparaissent.";
  String get timers_default => "Minuteur par défaut";
  String get timers_start_runs => "Démarrer lance";
  String get timers_presets => "Préréglages";
  String get timers_add => "Ajouter un minuteur";
  String get timers_limit_footer =>
      "L’îlot contient six minuteurs. Supprimez-en un pour en ajouter un autre.";
  String timers_delete(String timer) => "Supprimer $timer";
  String get timers_duplicate => "Vous avez déjà ce minuteur.";
  String get timers_picker_minutes => "Minutes";
  String get timers_picker_seconds => "Secondes";
  String get skins_view_all => "Tout afficher";
  String get timers_pomodoro_focus => "Concentration";
  String get timers_pomodoro_break => "Pause";
  String timers_minutes(int minutes) => "$minutes min";
  String get sound_footer =>
      "L’alerte dans l’app retentit toujours, même sans notifications.";
  String get shortcuts_touch => "Tactile";
  String get shortcuts_keyboard => "Clavier";
  String get touch_controls => "Afficher ou masquer les commandes";
  String get shortcut_off => "Non";
  String get key_start_pause => "Démarrer ou mettre en pause";
  String get key_change_mode => "Changer de mode";
  String get key_brightness => "Luminosité";
  String get key_show_seconds => "Afficher les secondes";
  String get key_full_screen => "Plein écran";
  String get key_hide_controls => "Masquer les commandes";
  String get key_dim => "Atténuer les chiffres";
  String get key_lap => "Tour (chronomètre)";
  String get key_rotation => "Rotation de l’écran";
  String get keycap_space => "Espace";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Licences";
  String get about_privacy => "Confidentialité";
  String get about_privacy_value =>
      "Pas de pub. Pas de pistage. Le compte est facultatif.";
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

class SyncMessages_fr extends SyncMessages {
  final Messages_fr _parent;
  const SyncMessages_fr(this._parent) : super(_parent);
  String get account => "Compte";
  String get card_title_signed_out => "Vos réglages restent sur cet appareil";
  String get card_body_signed_out =>
      "Connectez-vous seulement pour les retrouver sur vos autres appareils.";
  String get card_title_on => "Synchro activée";
  String get card_title_off => "Synchro désactivée";
  String card_last_synced(String when) => "Dernière synchro $when";
  String get headline => "Vos réglages restent sur cet appareil";
  String get body =>
      "QuietFlip ne demande jamais de compte. Connectez-vous seulement pour retrouver votre horloge, vos habillages et vos sons sur vos autres appareils.";
  String get sign_in => "Se connecter pour synchroniser";
  String get sign_in_reason =>
      "Utile seulement pour synchroniser vos réglages entre appareils.";
  String get what_syncs => "Ce qui est synchronisé";
  String get what_syncs_body =>
      "Thème, habillages, sons, réglages de l’horloge et des minuteurs.";
  String get stays_body =>
      "Reste sur cet appareil : luminosité, rotation, notifications et minuteur en cours.";
  String get sync_header => "Synchro";
  String get sync_settings => "Synchroniser les réglages";
  String get sync_settings_note =>
      "Vos réglages vous suivent sur chaque appareil où vous vous connectez.";
  String get last_synced => "Dernière synchro";
  String get just_now => "À l’instant";
  String minutes_ago(int n) => "Il y a $n min";
  String today_at(String time) => "Aujourd’hui à $time";
  String get never => "Pas encore";
  String get syncing => "Synchronisation…";
  String get waiting => "En attente de connexion";
  String get off_note =>
      "Synchro désactivée. Les modifications restent sur cet appareil.";
  String get failed_offline =>
      "Échec de la synchro : pas de connexion. Nouvel essai dès votre retour en ligne.";
  String get failed_denied => "Échec de la synchro : reconnectez-vous.";
  String get failed_unknown => "Échec de la synchro. Réessayez.";
  String get try_again => "Réessayer";
  String get sign_out_note =>
      "Vos réglages restent sur cet appareil après la déconnexion.";
  String get delete_account => "Supprimer le compte";
  String get delete_title => "Supprimer votre compte ?";
  String get delete_body =>
      "Vos réglages synchronisés sont supprimés du cloud. Ceux de cet appareil sont conservés.";
  String get delete_recent_login =>
      "Reconnectez-vous pour supprimer votre compte";
  String get delete_failed =>
      "Impossible de supprimer votre compte. Réessayez.";
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
