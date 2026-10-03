// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'id';
String get _localeName => 'id';

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

class Messages_id extends Messages {
  const Messages_id();
  AppMessages_id get app => AppMessages_id(this);
  GenericMessages_id get generic => GenericMessages_id(this);
  CommonMessages_id get common => CommonMessages_id(this);
  AuthMessages_id get auth => AuthMessages_id(this);
  ProfileMessages_id get profile => ProfileMessages_id(this);
  NavMessages_id get nav => NavMessages_id(this);
  NotificationsMessages_id get notifications => NotificationsMessages_id(this);
  ErrorsMessages_id get errors => ErrorsMessages_id(this);
  ValidationMessages_id get validation => ValidationMessages_id(this);
  FilesMessages_id get files => FilesMessages_id(this);
  DeveloperMessages_id get developer => DeveloperMessages_id(this);
  ClockMessages_id get clock => ClockMessages_id(this);
  SyncMessages_id get sync => SyncMessages_id(this);
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

class AppMessages_id extends AppMessages {
  final Messages_id _parent;
  const AppMessages_id(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "Jam flip, timer hitung mundur, dan stopwatch tanpa iklan.";
  String get welcome_to_app => "Selamat datang di QuietFlip!";
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

class GenericMessages_id extends GenericMessages {
  final Messages_id _parent;
  const GenericMessages_id(this._parent) : super(_parent);
  String get ok => "OK";
  String get cancel => "Batal";
  String get save => "Simpan";
  String get delete => "Hapus";
  String get edit => "Edit";
  String get update => "Perbarui";
  String get submit => "Kirim";
  String get close => "Tutup";
  String get back => "Kembali";
  String get next => "Berikutnya";
  String get previous => "Sebelumnya";
  String get done => "Selesai";
  String get loading => "Memuat...";
  String get error => "Kesalahan";
  String get success => "Berhasil";
  String get warning => "Peringatan";
  String get info => "Info";
  String get retry => "Coba lagi";
  String get refresh => "Muat ulang";
  String get yes => "Ya";
  String get no => "Tidak";
  String get add => "+ Tambah";
  String get try_again => "Coba Lagi";
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

class CommonMessages_id extends CommonMessages {
  final Messages_id _parent;
  const CommonMessages_id(this._parent) : super(_parent);
  String get week => "Minggu";
  String get month => "Bulan";
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

class AuthMessages_id extends AuthMessages {
  final Messages_id _parent;
  const AuthMessages_id(this._parent) : super(_parent);
  String get register => "Daftar";
  String get sign_in => "Masuk";
  String get sign_out => "Keluar";
  String get dont_have_account => "Belum punya akun? ";
  String get already_have_account => "Sudah punya akun? ";
  String get sign_out_confirmation => "Yakin ingin keluar?";
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

class ProfileMessages_id extends ProfileMessages {
  final Messages_id _parent;
  const ProfileMessages_id(this._parent) : super(_parent);
  String get profile => "Profil";
  String get settings => "Setelan";
  String get account => "Akun";
  String get personal_info => "Informasi Pribadi";
  String get privacy_settings => "Setelan Privasi";
  String get name => "Nama";
  String get email_address => "Alamat Email";
  String get phone_number => "Nomor Telepon";
  String get date_of_birth => "Tanggal Lahir";
  String get delete_confirmation => "Konfirmasi Hapus";
  String get delete_confirmation_message =>
      "Yakin ingin menghapus item ini? Tindakan ini tidak dapat dibatalkan.";
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

class NavMessages_id extends NavMessages {
  final Messages_id _parent;
  const NavMessages_id(this._parent) : super(_parent);
  String get home => "Beranda";
  String get dashboard => "Dasbor";
  String get explore => "Jelajahi";
  String get explore_placeholder =>
      "Tab kedua Anda. Ganti dengan fitur sungguhan.";
  String get profile => "Profil";
  String get settings => "Setelan";
  String get notifications => "Notifikasi";
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

class NotificationsMessages_id extends NotificationsMessages {
  final Messages_id _parent;
  const NotificationsMessages_id(this._parent) : super(_parent);
  String get title => "Notifikasi";
  String get mark_as_read => "Tandai sudah dibaca";
  String get mark_all_read => "Tandai semua sudah dibaca";
  String get delete => "Hapus";
  String get filter_all => "Semua";
  String get filter_unread => "Belum dibaca";
  String get filter_read => "Dibaca";
  String get type_reminder => "Pengingat";
  String get type_alert => "Peringatan";
  String get type_promotion => "Promosi";
  String get type_system => "Sistem";
  String get type_custom => "Kustom";
  String get empty_title => "Tidak ada notifikasi";
  String get empty_description =>
      "Semua sudah terbaca! Notifikasi baru akan muncul di sini.";
  String get delete_confirmation_title => "Hapus notifikasi?";
  String get delete_confirmation_message =>
      "Notifikasi ini akan dihapus permanen dari daftar Anda.";
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

class ErrorsMessages_id extends ErrorsMessages {
  final Messages_id _parent;
  const ErrorsMessages_id(this._parent) : super(_parent);
  String get network_error => "Kesalahan jaringan. Periksa koneksi Anda.";
  String get unknown_error => "Terjadi kesalahan yang tidak diketahui.";
  String get validation_error => "Periksa input Anda dan coba lagi.";
  String get server_error => "Kesalahan server. Coba lagi nanti.";
  String get default_error_message => "Ups! Terjadi kesalahan. Coba lagi.";
  String get user_not_found =>
      "Pengguna tidak ditemukan. Periksa kredensial Anda.";
  String get default_error_description =>
      "Terjadi kesalahan saat memproses permintaan Anda. Mohon maaf atas ketidaknyamanannya. Coba lagi nanti atau hubungi dukungan jika masalah berlanjut.";
  String get page_not_found => "Halaman Tidak Ditemukan";
  String get page_not_found_description => "Halaman yang Anda cari tidak ada.";
  String get unexpected_error => "Terjadi kesalahan tak terduga.";
  String get redirect_error => "Kesalahan Pengalihan";
  String get bad_request => "Permintaan tidak valid. Periksa input Anda.";
  String get unauthorized => "Perlu autentikasi. Silakan masuk lagi.";
  String get forbidden => "Akses ditolak. Anda tidak punya izin.";
  String get not_found => "Sumber yang diminta tidak ditemukan.";
  String get conflict => "Konflik data. Muat ulang dan coba lagi.";
  String get unprocessable_entity =>
      "Format data tidak valid. Periksa input Anda.";
  String get internal_server_error => "Kesalahan server. Coba lagi nanti.";
  String get connection_timeout =>
      "Waktu koneksi habis. Periksa internet Anda.";
  String get receive_timeout => "Waktu permintaan habis. Coba lagi.";
  String get send_timeout => "Waktu unggah habis. Coba lagi.";
  String get no_internet =>
      "Tidak ada koneksi internet. Periksa jaringan Anda.";
  String get unknown_network => "Terjadi kesalahan jaringan. Coba lagi.";
  String format_exception_message(String code, String postfix) =>
      "Data ini memakai kostum yang salah, saya tidak mengenalinya [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "Data ini tidak sesuai harapan, saya tidak bisa memprosesnya [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, item itu sepertinya tidak ada di daftar [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Ups! Angka itu jauh di luar batas [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Hei! Ada yang tidak beres dengan data yang diberikan [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "Saya agak bingung harus melakukan apa sekarang [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "Fitur ini masih dalam pengerjaan [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Maaf, saya belum tahu cara melakukannya [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Wah! Terlalu banyak yang terjadi sekaligus [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "Memori saya penuh! Perlu mengosongkan ruang [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "Saya terjebak dalam putaran dan mulai pusing [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Terjadi hal tak terduga, tapi jangan khawatir [$code] $postfix";
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

class ValidationMessages_id extends ValidationMessages {
  final Messages_id _parent;
  const ValidationMessages_id(this._parent) : super(_parent);
  String get required_field => "Kolom ini wajib diisi";
  String get invalid_email => "Masukkan alamat email yang valid";
  String get password_too_short => "Sandi minimal 8 karakter";
  String get passwords_dont_match => "Sandi tidak cocok";
  String invalid_key_config(String of, String key) =>
      "Konfigurasi $key di $of tidak valid. Periksa setelan Anda.";
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

class FilesMessages_id extends FilesMessages {
  final Messages_id _parent;
  const FilesMessages_id(this._parent) : super(_parent);
  String get info_title => "Informasi File";
  String get name => "Nama File";
  String get type => "Jenis File";
  String get extension => "Ekstensi File";
  String get size => "Ukuran File";
  String get path => "Jalur File";
  String get copy_hint => "Ketuk kolom mana pun untuk menyalin ke papan klip";
  String copied(String field) => "$field disalin ke papan klip";
  String image_type(String format) => "Gambar $format";
  String get image_file => "File gambar";
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

class DeveloperMessages_id extends DeveloperMessages {
  final Messages_id _parent;
  const DeveloperMessages_id(this._parent) : super(_parent);
  String get no_viewer => "Logger ini tidak punya penampil interaktif.";
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

class ClockMessages_id extends ClockMessages {
  final Messages_id _parent;
  const ClockMessages_id(this._parent) : super(_parent);
  String get clock => "Jam";
  String get stopwatch => "Stopwatch";
  String get modes => "Mode";
  String get settings => "Setelan";
  String get times_up => "Waktu habis";
  String get timer_finished_title => "Waktu habis";
  String get timer_finished_body => "Timer QuietFlip Anda telah selesai.";
  String get alerts_channel => "Peringatan timer";
  String get show_controls =>
      "Ketuk atau gerakkan mouse untuk menampilkan kontrol";
  String get theme => "Tema";
  String get theme_light => "Terang";
  String get use_24h => "Format 24 jam";
  String get show_seconds => "Tampilkan detik";
  String get sound_tick_group => "Detak";
  String get sound_tick_hint => "berbunyi di setiap flip";
  String get sound_alarm_group => "Alarm";
  String get sound_alarm_hint => "berulang hingga dimatikan, maks. 60 dtk";
  String get tick_sound => "Suara detak";
  String get tick_sound_description =>
      "Suara lembut setiap kali kartu berbalik";
  String get alarm_sound => "Suara alarm";
  String get alarm_sound_description =>
      "Berbunyi saat timer atau fase Pomodoro berakhir";
  String get tick_classic => "Klasik";
  String get tick_classic_mood => "klik lembut";
  String get tick_split_flap => "Split-flap";
  String get tick_split_flap_mood => "kepak berderap";
  String get tick_clockwork => "Mekanis";
  String get tick_clockwork_mood => "detak arloji";
  String get tick_woodblock => "Balok kayu";
  String get tick_woodblock_mood => "ketukan hampa";
  String get tick_digital => "Digital";
  String get tick_digital_mood => "blip jernih";
  String get alarm_chime => "Denting";
  String get alarm_chime_mood => "dua nada";
  String get alarm_bell => "Lonceng";
  String get alarm_bell_mood => "lonceng dipukul";
  String get alarm_beeps => "Bip";
  String get alarm_beeps_mood => "samping ranjang";
  String get alarm_rising => "Naik";
  String get alarm_rising_mood => "marimba";
  String get alarm_ring => "Dering";
  String get alarm_ring_mood => "lonceng kembar";
  String get system_notifications => "Notifikasi sistem";
  String get system_notifications_description =>
      "Dapatkan notifikasi saat timer selesai, meski QuietFlip berjalan di latar belakang.";
  String get permission_denied =>
      "Notifikasi untuk QuietFlip dimatikan. Anda tetap akan melihat dan mendengar peringatan selama aplikasi terbuka.";
  String get web_closed_tab_note =>
      "Di browser, peringatan hanya berfungsi selama tab ini tetap terbuka.";
  String get keep_screen_awake => "Biarkan layar menyala";
  String get keep_screen_awake_description =>
      "Cegah layar tidur selama jam ditampilkan.";
  String current_time(String time) => "Waktu saat ini $time";
  String time_remaining(String time) => "Sisa waktu $time";
  String elapsed(String time) => "Waktu berlalu $time";
  String get digit_brightness => "Kecerahan angka";
  String percent(String value) => "$value%";
  String get subtle_movement => "Gerakan halus";
  String get subtle_movement_description =>
      "Di layar penuh, geser jam beberapa piksel setiap menit agar piksel yang sama tidak menyala semalaman. Mengurangi, tapi tidak mencegah, risiko burn-in.";
  String get full_screen_note =>
      "Layar penuh menyembunyikan kontrol selama QuietFlip terbuka. Aplikasi harus tetap terbuka. Ini bukan layar kunci atau screensaver.";
  String get show_date => "Tampilkan tanggal";
  String current_time_and_date(String time, String date) =>
      "Waktu saat ini $time, $date";
  String get orientation => "Orientasi";
  String get orientation_auto => "Otomatis";
  String get orientation_landscape => "Lanskap";
  String get orientation_portrait => "Potret";
  String get settings_card_size => "Ukuran kartu";
  String get card_size_small => "Kecil";
  String get card_size_medium => "Sedang";
  String get card_size_large => "Besar";
  String get settings_corners => "Sudut";
  String get corners_square => "Siku";
  String get corners_round => "Bulat";
  String corners_value(String value) => "$value px";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Fokus · Ronde $round";
  String pomodoro_break(int round) => "Istirahat · Ronde $round";
  String get pomodoro_focus_done => "Fokus selesai. Saatnya istirahat.";
  String get pomodoro_break_done => "Istirahat selesai. Kembali fokus.";
  String get start_focus => "Mulai fokus";
  String get start_break => "Mulai istirahat";
  String get skins_title => "Skin";
  String get skins_customize => "Sesuaikan";
  String skins_customize_named(String name) => "Sesuaikan $name";
  String get skins_done => "Selesai";
  String get skins_in_use => "Dipakai";
  String get skins_yours => "Skin Anda";
  String get skins_classic => "Klasik";
  String get skins_bold => "Tebal";
  String get skins_type => "Huruf";
  String get skins_new => "Skin baru";
  String get skins_from_current => "Dari yang aktif";
  String get customize_title => "Sesuaikan skin";
  String get customize_name => "Nama";
  String customize_copy_name(String name) => "Salinan $name";
  String get customize_font => "Font";
  String get customize_digits => "Angka";
  String get customize_card => "Kartu";
  String get customize_ground => "Latar";
  String get customize_custom_colour => "Warna kustom";
  String get customize_hex_hint => "Hex, misalnya #FF7A00";
  String get customize_hex_invalid =>
      "Masukkan enam digit hex, seperti #FF7A00.";
  String get customize_apply => "Terapkan";
  String get customize_low_contrast => "Angka mungkin sulit dibaca.";
  String get customize_details => "Detail";
  String get customize_seconds => "Detik";
  String get customize_seconds_off => "Mati";
  String get customize_seconds_badge => "Kecil";
  String get customize_seconds_cards => "Kartu";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Sembunyi";
  String get customize_meridiem_left => "Di dalam";
  String get customize_meridiem_right => "Di samping";
  String get customize_save => "Simpan skin";
  String get customize_reset => "Atur ulang";
  String get customize_delete => "Hapus skin";
  String get skin_mono => "Mono";
  String get skin_paper => "Kertas";
  String get skin_rose => "Mawar";
  String get skin_violet => "Ungu";
  String get skin_amber => "Amber";
  String get skin_signal => "Sinyal";
  String get skin_field => "Padang";
  String get skin_mint => "Mint";
  String get skin_cyan => "Sian";
  String get skin_taxi => "Taksi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Poster";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Orbit";
  String get skin_nightstand => "Meja tidur";
  String get skin_studio => "Studio";
  String get skin_arcade => "Arkade";
  String get skin_railway => "Kereta";
  String get skin_desk => "Meja";
  String get skin_neon => "Neon";
  String get skin_minimal => "Minimal";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Jam";
  String get mode_stopwatch => "Stopwatch";
  String get action_start => "Mulai";
  String get action_pause => "Jeda";
  String get action_resume => "Lanjutkan";
  String get action_reset => "Atur ulang";
  String get action_restart => "Mulai ulang";
  String get action_done => "Selesai";
  String get action_skins => "Skin";
  String get action_settings => "Setelan";
  String get action_rotation => "Rotasi layar";
  String get action_timer_settings => "Setelan timer";
  String preset_minutes(int minutes) => "${minutes} mnt";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String preset_spoken_minutes(int minutes) => "Timer $minutes menit";
  String preset_spoken_seconds(int seconds) => "Timer $seconds detik";
  String preset_spoken_both(int minutes, int seconds) =>
      "Timer $minutes menit $seconds detik";
  String get action_lap => "Putaran";
  String lap_label(int number, String time) => "Putaran $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "Tampilan";
  String get settings_clock => "Jam";
  String get settings_gestures => "Gestur";
  String get settings_timers => "Timer";
  String get settings_sound => "Suara & peringatan";
  String get settings_awake => "Tetap menyala";
  String get settings_shortcuts => "Pintasan";
  String get settings_about => "Tentang";
  String get theme_dark => "Gelap";
  String get theme_system => "Ikuti sistem";
  String get gesture_swipes => "Usap";
  String get gesture_brightness => "Usap ke atas atau bawah untuk kecerahan";
  String get gesture_modes => "Usap ke samping untuk ganti mode";
  String get gesture_footer =>
      "Usap di mana saja pada jam. Di Mac, Windows, dan web, kecerahan meredupkan angka, bukan layar.";
  String get gesture_controls => "Kontrol";
  String get gesture_tap => "Ketuk untuk menampilkan kontrol";
  String get gesture_idle => "Sembunyikan kontrol setelah";
  String gesture_idle_seconds(int seconds) => "${seconds} dtk";
  String get gesture_idle_never => "Tidak pernah";
  String get gesture_controls_footer =>
      "Kontrol mengecil menjadi titik, lalu menghilang.";
  String get timers_default => "Timer default";
  String get timers_start_runs => "Tombol Mulai menjalankan";
  String get timers_presets => "Preset";
  String get timers_add => "Tambah timer";
  String get timers_limit_footer =>
      "Pulau muat enam timer. Hapus satu untuk menambah yang lain.";
  String timers_delete(String timer) => "Hapus $timer";
  String get timers_duplicate => "Anda sudah punya timer ini.";
  String get timers_picker_minutes => "Menit";
  String get timers_picker_seconds => "Detik";
  String get skins_view_all => "Lihat semua";
  String get timers_pomodoro_focus => "Fokus";
  String get timers_pomodoro_break => "Istirahat";
  String timers_minutes(int minutes) => "$minutes mnt";
  String get sound_footer =>
      "Peringatan dalam aplikasi selalu berbunyi, meski notifikasi mati.";
  String get shortcuts_touch => "Sentuh";
  String get shortcuts_keyboard => "Keyboard";
  String get touch_controls => "Tampilkan atau sembunyikan kontrol";
  String get shortcut_off => "Mati";
  String get key_start_pause => "Mulai atau jeda";
  String get key_change_mode => "Ganti mode";
  String get key_brightness => "Kecerahan";
  String get key_show_seconds => "Tampilkan detik";
  String get key_full_screen => "Layar penuh";
  String get key_hide_controls => "Sembunyikan kontrol";
  String get key_dim => "Redupkan angka";
  String get key_lap => "Putaran (stopwatch)";
  String get key_rotation => "Rotasi layar";
  String get keycap_space => "Spasi";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "Lisensi";
  String get about_privacy => "Privasi";
  String get about_privacy_value =>
      "Tanpa iklan. Akun bersifat opsional. Statistik penggunaan anonim membantu kami menyempurnakan aplikasi.";
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

class SyncMessages_id extends SyncMessages {
  final Messages_id _parent;
  const SyncMessages_id(this._parent) : super(_parent);
  String get account => "Akun";
  String get card_title_signed_out => "Setelan Anda tetap di perangkat ini";
  String get card_body_signed_out =>
      "Masuk hanya jika Anda ingin memakainya di perangkat lain.";
  String get card_title_on => "Sinkronisasi aktif";
  String get card_title_off => "Sinkronisasi nonaktif";
  String card_last_synced(String when) => "Terakhir disinkronkan $when";
  String get headline => "Setelan Anda tetap di perangkat ini";
  String get body =>
      "QuietFlip tidak pernah memerlukan akun. Masuk hanya jika Anda ingin jam, skin, dan suara Anda ada di perangkat lain.";
  String get sign_in => "Masuk untuk sinkronisasi";
  String get sign_in_reason =>
      "Hanya diperlukan untuk menyinkronkan setelan antarperangkat.";
  String get what_syncs => "Yang disinkronkan";
  String get what_syncs_body => "Tema, skin, suara, setelan jam dan timer.";
  String get stays_body =>
      "Tetap di perangkat ini: kecerahan, rotasi, notifikasi, dan timer yang sedang berjalan.";
  String get sync_header => "Sinkronisasi";
  String get sync_settings => "Sinkronkan setelan";
  String get sync_settings_note =>
      "Setelan Anda ikut ke setiap perangkat tempat Anda masuk.";
  String get last_synced => "Terakhir disinkronkan";
  String get just_now => "Baru saja";
  String minutes_ago(int n) => "$n mnt lalu";
  String today_at(String time) => "Hari ini pukul $time";
  String get never => "Belum";
  String get syncing => "Menyinkronkan…";
  String get waiting => "Menunggu koneksi";
  String get off_note =>
      "Sinkronisasi nonaktif. Perubahan tetap di perangkat ini.";
  String get failed_offline =>
      "Gagal sinkron: tidak ada koneksi. Akan dicoba lagi saat Anda kembali online.";
  String get failed_denied => "Gagal sinkron: masuk lagi.";
  String get failed_unknown => "Gagal sinkron. Coba lagi.";
  String get try_again => "Coba lagi";
  String get sign_out_note =>
      "Setelan Anda tetap ada di perangkat ini setelah keluar.";
  String get delete_account => "Hapus akun";
  String get delete_title => "Hapus akun Anda?";
  String get delete_body =>
      "Setelan yang disinkronkan akan dihapus dari cloud. Setelan di perangkat ini tetap ada.";
  String get delete_recent_login => "Masuk lagi untuk menghapus akun Anda";
  String get delete_failed => "Tidak dapat menghapus akun Anda. Coba lagi.";
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
