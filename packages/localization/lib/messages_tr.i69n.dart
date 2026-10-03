// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'tr';
String get _localeName => 'tr';

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

class Messages_tr extends Messages {
  const Messages_tr();
  AppMessages_tr get app => AppMessages_tr(this);
  GenericMessages_tr get generic => GenericMessages_tr(this);
  CommonMessages_tr get common => CommonMessages_tr(this);
  AuthMessages_tr get auth => AuthMessages_tr(this);
  ProfileMessages_tr get profile => ProfileMessages_tr(this);
  NavMessages_tr get nav => NavMessages_tr(this);
  NotificationsMessages_tr get notifications => NotificationsMessages_tr(this);
  ErrorsMessages_tr get errors => ErrorsMessages_tr(this);
  ValidationMessages_tr get validation => ValidationMessages_tr(this);
  FilesMessages_tr get files => FilesMessages_tr(this);
  DeveloperMessages_tr get developer => DeveloperMessages_tr(this);
  ClockMessages_tr get clock => ClockMessages_tr(this);
  SyncMessages_tr get sync => SyncMessages_tr(this);
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

class AppMessages_tr extends AppMessages {
  final Messages_tr _parent;
  const AppMessages_tr(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "Reklamsız çevirmeli saat, geri sayım ve kronometre.";
  String get welcome_to_app => "QuietFlip'e hoş geldiniz!";
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

class GenericMessages_tr extends GenericMessages {
  final Messages_tr _parent;
  const GenericMessages_tr(this._parent) : super(_parent);
  String get ok => "Tamam";
  String get cancel => "İptal";
  String get save => "Kaydet";
  String get delete => "Sil";
  String get edit => "Düzenle";
  String get update => "Güncelle";
  String get submit => "Gönder";
  String get close => "Kapat";
  String get back => "Geri";
  String get next => "İleri";
  String get previous => "Önceki";
  String get done => "Bitti";
  String get loading => "Yükleniyor…";
  String get error => "Hata";
  String get success => "Başarılı";
  String get warning => "Uyarı";
  String get info => "Bilgi";
  String get retry => "Yeniden dene";
  String get refresh => "Yenile";
  String get yes => "Evet";
  String get no => "Hayır";
  String get add => "+ Ekle";
  String get try_again => "Tekrar dene";
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

class CommonMessages_tr extends CommonMessages {
  final Messages_tr _parent;
  const CommonMessages_tr(this._parent) : super(_parent);
  String get week => "Hafta";
  String get month => "Ay";
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

class AuthMessages_tr extends AuthMessages {
  final Messages_tr _parent;
  const AuthMessages_tr(this._parent) : super(_parent);
  String get register => "Kaydol";
  String get sign_in => "Oturum aç";
  String get sign_out => "Oturumu kapat";
  String get dont_have_account => "Hesabınız yok mu? ";
  String get already_have_account => "Zaten hesabınız var mı? ";
  String get sign_out_confirmation =>
      "Oturumu kapatmak istediğinizden emin misiniz?";
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

class ProfileMessages_tr extends ProfileMessages {
  final Messages_tr _parent;
  const ProfileMessages_tr(this._parent) : super(_parent);
  String get profile => "Profil";
  String get settings => "Ayarlar";
  String get account => "Hesap";
  String get personal_info => "Kişisel bilgiler";
  String get privacy_settings => "Gizlilik ayarları";
  String get name => "Ad";
  String get email_address => "E-posta adresi";
  String get phone_number => "Telefon numarası";
  String get date_of_birth => "Doğum tarihi";
  String get delete_confirmation => "Silme onayı";
  String get delete_confirmation_message =>
      "Bu öğeyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.";
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

class NavMessages_tr extends NavMessages {
  final Messages_tr _parent;
  const NavMessages_tr(this._parent) : super(_parent);
  String get home => "Ana sayfa";
  String get dashboard => "Pano";
  String get explore => "Keşfet";
  String get explore_placeholder =>
      "İkinci sekmeniz. Bunu gerçek bir özellikle değiştirin.";
  String get profile => "Profil";
  String get settings => "Ayarlar";
  String get notifications => "Bildirimler";
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

class NotificationsMessages_tr extends NotificationsMessages {
  final Messages_tr _parent;
  const NotificationsMessages_tr(this._parent) : super(_parent);
  String get title => "Bildirimler";
  String get mark_as_read => "Okundu olarak işaretle";
  String get mark_all_read => "Tümünü okundu işaretle";
  String get delete => "Sil";
  String get filter_all => "Tümü";
  String get filter_unread => "Okunmamış";
  String get filter_read => "Okunmuş";
  String get type_reminder => "Hatırlatıcı";
  String get type_alert => "Uyarı";
  String get type_promotion => "Tanıtım";
  String get type_system => "Sistem";
  String get type_custom => "Özel";
  String get empty_title => "Bildirim yok";
  String get empty_description =>
      "Hepsi bu kadar! Yeni bildirimler burada görünecek.";
  String get delete_confirmation_title => "Bildirim silinsin mi?";
  String get delete_confirmation_message =>
      "Bu bildirim listenizden kalıcı olarak kaldırılacak.";
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

class ErrorsMessages_tr extends ErrorsMessages {
  final Messages_tr _parent;
  const ErrorsMessages_tr(this._parent) : super(_parent);
  String get network_error => "Ağ hatası. Lütfen bağlantınızı kontrol edin.";
  String get unknown_error => "Bilinmeyen bir hata oluştu.";
  String get validation_error =>
      "Lütfen girdiğiniz bilgileri kontrol edip tekrar deneyin.";
  String get server_error => "Sunucu hatası. Lütfen daha sonra tekrar deneyin.";
  String get default_error_message =>
      "Hay aksi! Bir şeyler ters gitti. Lütfen tekrar deneyin.";
  String get user_not_found =>
      "Kullanıcı bulunamadı. Lütfen bilgilerinizi kontrol edin.";
  String get default_error_description =>
      "İsteğiniz işlenirken bir hata oluştu. Verdiğimiz rahatsızlıktan dolayı özür dileriz. Lütfen daha sonra tekrar deneyin veya sorun devam ederse destek ekibiyle iletişime geçin.";
  String get page_not_found => "Sayfa bulunamadı";
  String get page_not_found_description => "Aradığınız sayfa mevcut değil.";
  String get unexpected_error => "Beklenmeyen bir hata oluştu.";
  String get redirect_error => "Yönlendirme hatası";
  String get bad_request =>
      "Geçersiz istek. Lütfen girdiğiniz bilgileri kontrol edin.";
  String get unauthorized =>
      "Kimlik doğrulama gerekli. Lütfen tekrar oturum açın.";
  String get forbidden => "Erişim reddedildi. Bu işlem için izniniz yok.";
  String get not_found => "İstenen kaynak bulunamadı.";
  String get conflict => "Veri çakışması. Lütfen yenileyip tekrar deneyin.";
  String get unprocessable_entity =>
      "Geçersiz veri biçimi. Lütfen girdiğiniz bilgileri kontrol edin.";
  String get internal_server_error =>
      "Sunucu hatası. Lütfen daha sonra tekrar deneyin.";
  String get connection_timeout =>
      "Bağlantı zaman aşımına uğradı. Lütfen internetinizi kontrol edin.";
  String get receive_timeout =>
      "İstek zaman aşımına uğradı. Lütfen tekrar deneyin.";
  String get send_timeout =>
      "Yükleme zaman aşımına uğradı. Lütfen tekrar deneyin.";
  String get no_internet =>
      "İnternet bağlantısı yok. Lütfen ağınızı kontrol edin.";
  String get unknown_network => "Ağ hatası oluştu. Lütfen tekrar deneyin.";
  String format_exception_message(String code, String postfix) =>
      "Bu veri yanlış kılıkta, tanıyamadım [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Bu veri beklediğim gibi değil, işleyemiyorum [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, bu öğeyi listede bulamıyorum [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Hay aksi! Bu sayı benim için fazla uçta [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Hey! Verdiğin şeyde bir tuhaflık var [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Şu an ne yapmam gerektiği konusunda biraz kafam karışık [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Bu özellik hâlâ yapım aşamasında [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Üzgünüm, bunu henüz yapmayı bilmiyorum [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Vay! Aynı anda çok fazla şey oluyor [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Kafam doldu! Biraz yer açmam lazım [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Bir döngüye takıldım, başım dönüyor [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Beklenmedik bir şey oldu ama endişelenmeyin [$code] $postfix";
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

class ValidationMessages_tr extends ValidationMessages {
  final Messages_tr _parent;
  const ValidationMessages_tr(this._parent) : super(_parent);
  String get required_field => "Bu alan zorunludur";
  String get invalid_email => "Lütfen geçerli bir e-posta adresi girin";
  String get password_too_short => "Şifre en az 8 karakter olmalıdır";
  String get passwords_dont_match => "Şifreler eşleşmiyor";
  String invalid_key_config(String of, String key) =>
      "$of içinde $key için geçersiz yapılandırma. Lütfen ayarlarınızı kontrol edin.";
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

class FilesMessages_tr extends FilesMessages {
  final Messages_tr _parent;
  const FilesMessages_tr(this._parent) : super(_parent);
  String get info_title => "Dosya bilgileri";
  String get name => "Dosya adı";
  String get type => "Dosya türü";
  String get extension => "Dosya uzantısı";
  String get size => "Dosya boyutu";
  String get path => "Dosya yolu";
  String get copy_hint => "Panoya kopyalamak için bir alana dokunun";
  String copied(String field) => "$field panoya kopyalandı";
  String image_type(String format) => "$format görüntüsü";
  String get image_file => "Görüntü dosyası";
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

class DeveloperMessages_tr extends DeveloperMessages {
  final Messages_tr _parent;
  const DeveloperMessages_tr(this._parent) : super(_parent);
  String get no_viewer => "Bu günlükçünün etkileşimli görüntüleyicisi yok.";
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

class ClockMessages_tr extends ClockMessages {
  final Messages_tr _parent;
  const ClockMessages_tr(this._parent) : super(_parent);
  String get clock => "Saat";
  String get stopwatch => "Kronometre";
  String get modes => "Mod";
  String get settings => "Ayarlar";
  String get times_up => "Süre doldu";
  String get timer_finished_title => "Süre doldu";
  String get timer_finished_body => "QuietFlip zamanlayıcınız bitti.";
  String get alerts_channel => "Zamanlayıcı uyarıları";
  String get show_controls =>
      "Kontrolleri göstermek için dokunun veya fareyi hareket ettirin";
  String get theme => "Tema";
  String get theme_light => "Açık";
  String get use_24h => "24 saat biçimi";
  String get show_seconds => "Saniyeleri göster";
  String get sound_tick_group => "Tik sesi";
  String get sound_tick_hint => "her çevrilişte çalar";
  String get sound_alarm_group => "Alarm";
  String get sound_alarm_hint => "kapatılana dek tekrarlar, en çok 60 sn";
  String get tick_sound => "Tik sesi";
  String get tick_sound_description => "Her kart çevrildiğinde yumuşak bir ses";
  String get alarm_sound => "Alarm sesi";
  String get alarm_sound_description =>
      "Zamanlayıcı veya Pomodoro aşaması bitince çalar";
  String get tick_classic => "Klasik";
  String get tick_classic_mood => "yumuşak tık";
  String get tick_split_flap => "Paleta";
  String get tick_split_flap_mood => "kanat tıkırtısı";
  String get tick_clockwork => "Saat mekanizması";
  String get tick_clockwork_mood => "saat tiki";
  String get tick_woodblock => "Tahta blok";
  String get tick_woodblock_mood => "boğuk vuruş";
  String get tick_digital => "Dijital";
  String get tick_digital_mood => "temiz bip";
  String get alarm_chime => "Çan";
  String get alarm_chime_mood => "iki ton";
  String get alarm_bell => "Zil";
  String get alarm_bell_mood => "vurulan zil";
  String get alarm_beeps => "Bipler";
  String get alarm_beeps_mood => "başucu";
  String get alarm_rising => "Yükselen";
  String get alarm_rising_mood => "marimba";
  String get alarm_ring => "Çınlama";
  String get alarm_ring_mood => "ikiz zil";
  String get system_notifications => "Sistem bildirimleri";
  String get system_notifications_description =>
      "QuietFlip arka planda olsa bile zamanlayıcı bitince bildirim alın.";
  String get permission_denied =>
      "QuietFlip için bildirimler kapalı. Uygulama açıkken uyarıyı yine görür ve duyarsınız.";
  String get web_closed_tab_note =>
      "Tarayıcıda uyarılar yalnızca bu sekme açık kaldığı sürece çalışır.";
  String get keep_screen_awake => "Ekranı açık tut";
  String get keep_screen_awake_description =>
      "Saat görünürken ekranın uyku moduna geçmesini engeller.";
  String current_time(String time) => "Şu anki saat $time";
  String time_remaining(String time) => "Kalan süre $time";
  String elapsed(String time) => "Geçen süre $time";
  String get digit_brightness => "Rakam parlaklığı";
  String percent(String value) => "%$value";
  String get subtle_movement => "Hafif kaydırma";
  String get subtle_movement_description =>
      "Tam ekranda, aynı pikseller bütün gece yanmasın diye saati her dakika birkaç piksel kaydırır. Ekran izi riskini azaltır ama tamamen önlemez.";
  String get full_screen_note =>
      "Tam ekran, QuietFlip açıkken kontrolleri gizler. Uygulama açık kalmalıdır. Bu bir kilit ekranı veya ekran koruyucu değildir.";
  String get show_date => "Tarihi göster";
  String current_time_and_date(String time, String date) =>
      "Şu anki saat $time, $date";
  String get orientation => "Yön";
  String get orientation_auto => "Otomatik";
  String get orientation_landscape => "Yatay";
  String get orientation_portrait => "Dikey";
  String get settings_card_size => "Kart boyutu";
  String get card_size_small => "Küçük";
  String get card_size_medium => "Orta";
  String get card_size_large => "Büyük";
  String get settings_corners => "Köşeler";
  String get corners_square => "Köşeli";
  String get corners_round => "Yuvarlak";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Odak · Tur $round";
  String pomodoro_break(int round) => "Mola · Tur $round";
  String get pomodoro_focus_done => "Odak bitti. Mola zamanı.";
  String get pomodoro_break_done => "Mola bitti. Odağa dönün.";
  String get start_focus => "Odağı başlat";
  String get start_break => "Molayı başlat";
  String get skins_title => "Görünümler";
  String get skins_customize => "Özelleştir";
  String skins_customize_named(String name) => "Özelleştir: $name";
  String get skins_done => "Bitti";
  String get skins_in_use => "Kullanımda";
  String get skins_yours => "Görünümleriniz";
  String get skins_classic => "Klasik";
  String get skins_bold => "Kalın";
  String get skins_type => "Yazı";
  String get skins_new => "Yeni görünüm";
  String get skins_from_current => "Mevcuttan";
  String get customize_title => "Görünümü özelleştir";
  String get customize_name => "Ad";
  String customize_copy_name(String name) => "$name kopyası";
  String get customize_font => "Yazı tipi";
  String get customize_digits => "Rakamlar";
  String get customize_card => "Kart";
  String get customize_ground => "Arka plan";
  String get customize_custom_colour => "Özel renk";
  String get customize_hex_hint => "Hex, örneğin #FF7A00";
  String get customize_hex_invalid => "#FF7A00 gibi altı hex basamağı girin.";
  String get customize_apply => "Uygula";
  String get customize_low_contrast => "Rakamlar zor okunabilir.";
  String get customize_details => "Ayrıntılar";
  String get customize_seconds => "Saniyeler";
  String get customize_seconds_off => "Kapalı";
  String get customize_seconds_badge => "Küçük";
  String get customize_seconds_cards => "Kartlar";
  String get customize_meridiem => "ÖÖ / ÖS";
  String get customize_meridiem_hidden => "Gizli";
  String get customize_meridiem_left => "İçinde";
  String get customize_meridiem_right => "Yanında";
  String get customize_save => "Görünümü kaydet";
  String get customize_reset => "Sıfırla";
  String get customize_delete => "Görünümü sil";
  String get skin_mono => "Mono";
  String get skin_paper => "Kâğıt";
  String get skin_rose => "Gül";
  String get skin_violet => "Mor";
  String get skin_amber => "Kehribar";
  String get skin_signal => "Sinyal";
  String get skin_field => "Kır";
  String get skin_mint => "Nane";
  String get skin_cyan => "Camgöbeği";
  String get skin_taxi => "Taksi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Afiş";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Yörünge";
  String get skin_nightstand => "Komodin";
  String get skin_studio => "Stüdyo";
  String get skin_arcade => "Atari";
  String get skin_railway => "Gar";
  String get skin_desk => "Masa";
  String get skin_neon => "Neon";
  String get skin_minimal => "Minimal";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Saat";
  String get mode_stopwatch => "Kronometre";
  String get action_start => "Başlat";
  String get action_pause => "Duraklat";
  String get action_resume => "Sürdür";
  String get action_reset => "Sıfırla";
  String get action_restart => "Yeniden başlat";
  String get action_done => "Bitti";
  String get action_skins => "Görünümler";
  String get action_settings => "Ayarlar";
  String get action_rotation => "Ekran döndürme";
  String get action_timer_settings => "Zamanlayıcı ayarları";
  String preset_minutes(int minutes) => "$minutes dk";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "$minutes dakikalık zamanlayıcı";
  String preset_spoken_seconds(int seconds) => "$seconds saniyelik zamanlayıcı";
  String preset_spoken_both(int minutes, int seconds) =>
      "$minutes dakika $seconds saniyelik zamanlayıcı";
  String get action_lap => "Tur";
  String lap_label(int number, String time) => "Tur $number  $time";
  String brightness_value(String percent) => "%$percent";
  String get settings_appearance => "Görünüm";
  String get settings_clock => "Saat";
  String get settings_gestures => "Hareketler";
  String get settings_timers => "Zamanlayıcılar";
  String get settings_sound => "Ses ve uyarılar";
  String get settings_awake => "Açık tut";
  String get settings_shortcuts => "Kısayollar";
  String get settings_about => "Hakkında";
  String get theme_dark => "Koyu";
  String get theme_system => "Sistemle aynı";
  String get gesture_swipes => "Kaydırmalar";
  String get gesture_brightness => "Parlaklık için yukarı veya aşağı kaydırın";
  String get gesture_modes => "Modu değiştirmek için yana kaydırın";
  String get gesture_footer =>
      "Saatin herhangi bir yerinde kaydırın. Mac, Windows ve web'de parlaklık ekranı değil rakamları karartır.";
  String get gesture_controls => "Kontroller";
  String get gesture_tap => "Kontrolleri göstermek için dokunun";
  String get gesture_idle => "Kontrolleri gizleme süresi";
  String gesture_idle_seconds(int seconds) => "$seconds sn";
  String get gesture_idle_never => "Asla";
  String get gesture_controls_footer =>
      "Kontroller önce bir noktaya küçülür, sonra kaybolur.";
  String get timers_default => "Varsayılan zamanlayıcı";
  String get timers_start_runs => "Başlat ile çalışan";
  String get timers_presets => "Hazır ayarlar";
  String get timers_add => "Zamanlayıcı ekle";
  String get timers_limit_footer =>
      "Adaya altı zamanlayıcı sığar. Yenisini eklemek için birini silin.";
  String timers_delete(String timer) => "Sil: $timer";
  String get timers_duplicate => "Bu zamanlayıcı zaten var.";
  String get timers_picker_minutes => "Dakika";
  String get timers_picker_seconds => "Saniye";
  String get skins_view_all => "Tümünü gör";
  String get timers_pomodoro_focus => "Odak";
  String get timers_pomodoro_break => "Mola";
  String timers_minutes(int minutes) => "$minutes dk";
  String get sound_footer =>
      "Uygulama içi uyarı, bildirimler kapalıyken bile her zaman çalar.";
  String get shortcuts_touch => "Dokunma";
  String get shortcuts_keyboard => "Klavye";
  String get touch_controls => "Kontrolleri göster veya gizle";
  String get shortcut_off => "Kapalı";
  String get key_start_pause => "Başlat veya duraklat";
  String get key_change_mode => "Modu değiştir";
  String get key_brightness => "Parlaklık";
  String get key_show_seconds => "Saniyeleri göster";
  String get key_full_screen => "Tam ekran";
  String get key_hide_controls => "Kontrolleri gizle";
  String get key_dim => "Rakamları karart";
  String get key_lap => "Tur (kronometre)";
  String get key_rotation => "Ekran döndürme";
  String get keycap_space => "Boşluk";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Lisanslar";
  String get about_privacy => "Gizlilik";
  String get about_privacy_value =>
      "Reklam yok. İzleme yok. Hesap isteğe bağlıdır.";
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

class SyncMessages_tr extends SyncMessages {
  final Messages_tr _parent;
  const SyncMessages_tr(this._parent) : super(_parent);
  String get account => "Hesap";
  String get card_title_signed_out => "Ayarlarınız bu cihazda kalır";
  String get card_body_signed_out =>
      "Yalnızca diğer cihazlarınızda da istiyorsanız oturum açın.";
  String get card_title_on => "Eşitleme açık";
  String get card_title_off => "Eşitleme kapalı";
  String card_last_synced(String when) => "Son eşitleme: $when";
  String get headline => "Ayarlarınız bu cihazda kalır";
  String get body =>
      "QuietFlip hiçbir zaman hesap gerektirmez. Saatinizi, görünümlerinizi ve seslerinizi diğer cihazlarınızda da istiyorsanız oturum açın.";
  String get sign_in => "Eşitlemek için oturum açın";
  String get sign_in_reason =>
      "Yalnızca ayarlarınızı cihazlar arasında eşitlemek için gerekir.";
  String get what_syncs => "Neler eşitlenir";
  String get what_syncs_body =>
      "Tema, görünümler, sesler, saat ve zamanlayıcı ayarları.";
  String get stays_body =>
      "Bu cihazda kalanlar: parlaklık, döndürme, bildirimler ve çalışan zamanlayıcı.";
  String get sync_header => "Eşitleme";
  String get sync_settings => "Ayarları eşitle";
  String get sync_settings_note =>
      "Ayarlarınız oturum açtığınız her cihazda sizinle olur.";
  String get last_synced => "Son eşitleme";
  String get just_now => "Az önce";
  String minutes_ago(int n) => "$n dk önce";
  String today_at(String time) => "Bugün $time";
  String get never => "Henüz yok";
  String get syncing => "Eşitleniyor…";
  String get waiting => "Bağlantı bekleniyor";
  String get off_note => "Eşitleme kapalı. Değişiklikler bu cihazda kalır.";
  String get failed_offline =>
      "Eşitlenemedi: bağlantı yok. Tekrar çevrimiçi olduğunuzda yeniden denenecek.";
  String get failed_denied => "Eşitlenemedi: tekrar oturum açın.";
  String get failed_unknown => "Eşitlenemedi. Tekrar deneyin.";
  String get try_again => "Tekrar dene";
  String get sign_out_note => "Oturumu kapatmak ayarlarınızı bu cihazda tutar.";
  String get delete_account => "Hesabı sil";
  String get delete_title => "Hesabınız silinsin mi?";
  String get delete_body =>
      "Eşitlenen ayarlarınız buluttan kaldırılır. Bu cihazdaki ayarlar kalır.";
  String get delete_recent_login => "Hesabınızı silmek için tekrar oturum açın";
  String get delete_failed => "Hesabınız silinemedi. Tekrar deneyin.";
  String get provider_email => "E-posta";
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
