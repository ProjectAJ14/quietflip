// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'ja';
String get _localeName => 'ja';

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

class Messages_ja extends Messages {
  const Messages_ja();
  AppMessages_ja get app => AppMessages_ja(this);
  GenericMessages_ja get generic => GenericMessages_ja(this);
  CommonMessages_ja get common => CommonMessages_ja(this);
  AuthMessages_ja get auth => AuthMessages_ja(this);
  ProfileMessages_ja get profile => ProfileMessages_ja(this);
  NavMessages_ja get nav => NavMessages_ja(this);
  NotificationsMessages_ja get notifications => NotificationsMessages_ja(this);
  ErrorsMessages_ja get errors => ErrorsMessages_ja(this);
  ValidationMessages_ja get validation => ValidationMessages_ja(this);
  FilesMessages_ja get files => FilesMessages_ja(this);
  DeveloperMessages_ja get developer => DeveloperMessages_ja(this);
  ClockMessages_ja get clock => ClockMessages_ja(this);
  SyncMessages_ja get sync => SyncMessages_ja(this);
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

class AppMessages_ja extends AppMessages {
  final Messages_ja _parent;
  const AppMessages_ja(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description => "広告なしのフリップ時計、タイマー、ストップウォッチ。";
  String get welcome_to_app => "QuietFlip へようこそ!";
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

class GenericMessages_ja extends GenericMessages {
  final Messages_ja _parent;
  const GenericMessages_ja(this._parent) : super(_parent);
  String get ok => "OK";
  String get cancel => "キャンセル";
  String get save => "保存";
  String get delete => "削除";
  String get edit => "編集";
  String get update => "更新";
  String get submit => "送信";
  String get close => "閉じる";
  String get back => "戻る";
  String get next => "次へ";
  String get previous => "前へ";
  String get done => "完了";
  String get loading => "読み込み中…";
  String get error => "エラー";
  String get success => "成功";
  String get warning => "警告";
  String get info => "情報";
  String get retry => "再試行";
  String get refresh => "更新";
  String get yes => "はい";
  String get no => "いいえ";
  String get add => "+ 追加";
  String get try_again => "再試行";
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

class CommonMessages_ja extends CommonMessages {
  final Messages_ja _parent;
  const CommonMessages_ja(this._parent) : super(_parent);
  String get week => "週";
  String get month => "月";
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

class AuthMessages_ja extends AuthMessages {
  final Messages_ja _parent;
  const AuthMessages_ja(this._parent) : super(_parent);
  String get register => "登録";
  String get sign_in => "ログイン";
  String get sign_out => "ログアウト";
  String get dont_have_account => "アカウントをお持ちでない場合 ";
  String get already_have_account => "アカウントをお持ちの場合 ";
  String get sign_out_confirmation => "ログアウトしますか?";
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

class ProfileMessages_ja extends ProfileMessages {
  final Messages_ja _parent;
  const ProfileMessages_ja(this._parent) : super(_parent);
  String get profile => "プロフィール";
  String get settings => "設定";
  String get account => "アカウント";
  String get personal_info => "個人情報";
  String get privacy_settings => "プライバシー設定";
  String get name => "名前";
  String get email_address => "メールアドレス";
  String get phone_number => "電話番号";
  String get date_of_birth => "生年月日";
  String get delete_confirmation => "削除の確認";
  String get delete_confirmation_message => "この項目を削除しますか?この操作は取り消せません。";
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

class NavMessages_ja extends NavMessages {
  final Messages_ja _parent;
  const NavMessages_ja(this._parent) : super(_parent);
  String get home => "ホーム";
  String get dashboard => "ダッシュボード";
  String get explore => "見つける";
  String get explore_placeholder => "2つ目のタブです。実際の機能に置き換えてください。";
  String get profile => "プロフィール";
  String get settings => "設定";
  String get notifications => "通知";
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

class NotificationsMessages_ja extends NotificationsMessages {
  final Messages_ja _parent;
  const NotificationsMessages_ja(this._parent) : super(_parent);
  String get title => "通知";
  String get mark_as_read => "既読にする";
  String get mark_all_read => "すべて既読にする";
  String get delete => "削除";
  String get filter_all => "すべて";
  String get filter_unread => "未読";
  String get filter_read => "既読";
  String get type_reminder => "リマインダー";
  String get type_alert => "アラート";
  String get type_promotion => "お知らせ";
  String get type_system => "システム";
  String get type_custom => "カスタム";
  String get empty_title => "通知はありません";
  String get empty_description => "すべて確認済みです。新しい通知はここに表示されます。";
  String get delete_confirmation_title => "通知を削除しますか?";
  String get delete_confirmation_message => "この通知はリストから完全に削除されます。";
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

class ErrorsMessages_ja extends ErrorsMessages {
  final Messages_ja _parent;
  const ErrorsMessages_ja(this._parent) : super(_parent);
  String get network_error => "ネットワークエラーです。接続を確認してください。";
  String get unknown_error => "不明なエラーが発生しました。";
  String get validation_error => "入力内容を確認して、もう一度お試しください。";
  String get server_error => "サーバーエラーです。しばらくしてからお試しください。";
  String get default_error_message => "問題が発生しました。もう一度お試しください。";
  String get user_not_found => "ユーザーが見つかりません。ログイン情報を確認してください。";
  String get default_error_description =>
      "リクエストの処理中にエラーが発生しました。ご不便をおかけして申し訳ありません。しばらくしてからもう一度お試しいただくか、問題が続く場合はサポートにお問い合わせください。";
  String get page_not_found => "ページが見つかりません";
  String get page_not_found_description => "お探しのページは存在しません。";
  String get unexpected_error => "予期しないエラーが発生しました。";
  String get redirect_error => "リダイレクトエラー";
  String get bad_request => "無効なリクエストです。入力内容を確認してください。";
  String get unauthorized => "認証が必要です。もう一度ログインしてください。";
  String get forbidden => "アクセスが拒否されました。権限がありません。";
  String get not_found => "リクエストされたリソースが見つかりません。";
  String get conflict => "データが競合しています。更新してもう一度お試しください。";
  String get unprocessable_entity => "データの形式が無効です。入力内容を確認してください。";
  String get internal_server_error => "サーバーエラーです。しばらくしてからお試しください。";
  String get connection_timeout => "接続がタイムアウトしました。インターネット接続を確認してください。";
  String get receive_timeout => "リクエストがタイムアウトしました。もう一度お試しください。";
  String get send_timeout => "アップロードがタイムアウトしました。もう一度お試しください。";
  String get no_internet => "インターネットに接続されていません。ネットワークを確認してください。";
  String get unknown_network => "ネットワークエラーが発生しました。もう一度お試しください。";
  String format_exception_message(String code, String postfix) =>
      "このデータは見慣れない姿をしていて、認識できません [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "想定と違うデータのため、処理できません [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "うーん、その項目がリストに見つかりません [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "おっと!その数値は範囲外です [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "渡された内容に何か問題があります [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "今何をすべきか、少し混乱しています [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "この機能はまだ準備中です [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "すみません、それにはまだ対応していません [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "おっと!一度にいろいろ起きすぎています [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "メモリがいっぱいです!少し空きが必要です [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "ループから抜け出せず、目が回っています [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "予期しないことが起きましたが、ご心配なく [$code] $postfix";
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

class ValidationMessages_ja extends ValidationMessages {
  final Messages_ja _parent;
  const ValidationMessages_ja(this._parent) : super(_parent);
  String get required_field => "この項目は必須です";
  String get invalid_email => "有効なメールアドレスを入力してください";
  String get password_too_short => "パスワードは8文字以上にしてください";
  String get passwords_dont_match => "パスワードが一致しません";
  String invalid_key_config(String of, String key) =>
      "$of の $key の設定が無効です。設定を確認してください。";
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

class FilesMessages_ja extends FilesMessages {
  final Messages_ja _parent;
  const FilesMessages_ja(this._parent) : super(_parent);
  String get info_title => "ファイル情報";
  String get name => "ファイル名";
  String get type => "ファイルの種類";
  String get extension => "拡張子";
  String get size => "ファイルサイズ";
  String get path => "ファイルパス";
  String get copy_hint => "項目をタップしてクリップボードにコピー";
  String copied(String field) => "$field をクリップボードにコピーしました";
  String image_type(String format) => "$format 画像";
  String get image_file => "画像ファイル";
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

class DeveloperMessages_ja extends DeveloperMessages {
  final Messages_ja _parent;
  const DeveloperMessages_ja(this._parent) : super(_parent);
  String get no_viewer => "このロガーには対話型ビューアがありません。";
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

class ClockMessages_ja extends ClockMessages {
  final Messages_ja _parent;
  const ClockMessages_ja(this._parent) : super(_parent);
  String get clock => "時計";
  String get stopwatch => "ストップウォッチ";
  String get modes => "モード";
  String get settings => "設定";
  String get times_up => "時間です";
  String get timer_finished_title => "時間です";
  String get timer_finished_body => "QuietFlip のタイマーが終了しました。";
  String get alerts_channel => "タイマーのアラート";
  String get show_controls => "タップまたはマウスを動かして操作ボタンを表示";
  String get theme => "テーマ";
  String get theme_light => "ライト";
  String get use_24h => "24時間表示";
  String get show_seconds => "秒を表示";
  String get sound_tick_group => "めくり音";
  String get sound_tick_hint => "めくるたびに鳴ります";
  String get sound_alarm_group => "アラーム";
  String get sound_alarm_hint => "止めるまで繰り返し、最大60秒";
  String get tick_sound => "めくり音";
  String get tick_sound_description => "カードがめくれるたびに鳴る控えめな音";
  String get alarm_sound => "アラーム音";
  String get alarm_sound_description => "タイマーやポモドーロの区切りで鳴ります";
  String get tick_classic => "クラシック";
  String get tick_classic_mood => "やわらかなクリック";
  String get tick_split_flap => "パタパタ";
  String get tick_split_flap_mood => "フラップの音";
  String get tick_clockwork => "ぜんまい";
  String get tick_clockwork_mood => "時計の秒音";
  String get tick_woodblock => "木魚";
  String get tick_woodblock_mood => "乾いたノック";
  String get tick_digital => "デジタル";
  String get tick_digital_mood => "澄んだ電子音";
  String get alarm_chime => "チャイム";
  String get alarm_chime_mood => "2つの音";
  String get alarm_bell => "ベル";
  String get alarm_bell_mood => "鐘の音";
  String get alarm_beeps => "ビープ";
  String get alarm_beeps_mood => "目覚まし時計";
  String get alarm_rising => "だんだん大きく";
  String get alarm_rising_mood => "マリンバ";
  String get alarm_ring => "リング";
  String get alarm_ring_mood => "ツインベル";
  String get system_notifications => "システム通知";
  String get system_notifications_description =>
      "QuietFlip がバックグラウンドにあっても、タイマー終了時に通知します。";
  String get permission_denied =>
      "QuietFlip の通知はオフです。アプリを開いている間はアラートが表示され、音も鳴ります。";
  String get web_closed_tab_note => "ブラウザでは、このタブを開いている間だけアラートが動作します。";
  String get keep_screen_awake => "画面をオンのままにする";
  String get keep_screen_awake_description => "時計の表示中は画面がスリープしないようにします。";
  String current_time(String time) => "現在時刻 $time";
  String time_remaining(String time) => "残り時間 $time";
  String elapsed(String time) => "経過時間 $time";
  String get digit_brightness => "数字の明るさ";
  String percent(String value) => "$value%";
  String get subtle_movement => "わずかに動かす";
  String get subtle_movement_description =>
      "全画面表示中、時計を毎分数ピクセルずつ動かし、同じピクセルが一晩中点灯し続けないようにします。焼き付きのリスクを減らしますが、完全には防げません。";
  String get full_screen_note =>
      "全画面表示では、QuietFlip を開いている間は操作ボタンが隠れます。アプリは開いたままにする必要があります。ロック画面やスクリーンセーバーではありません。";
  String get show_date => "日付を表示";
  String current_time_and_date(String time, String date) => "現在時刻 $time、$date";
  String get orientation => "画面の向き";
  String get orientation_auto => "自動";
  String get orientation_landscape => "横向き";
  String get orientation_portrait => "縦向き";
  String get settings_card_size => "カードのサイズ";
  String get card_size_small => "小";
  String get card_size_medium => "中";
  String get card_size_large => "大";
  String get settings_corners => "角";
  String get corners_square => "四角";
  String get corners_round => "丸";
  String corners_value(String value) => "$value px";
  String get pomodoro => "ポモドーロ";
  String pomodoro_focus(int round) => "集中 · ラウンド $round";
  String pomodoro_break(int round) => "休憩 · ラウンド $round";
  String get pomodoro_focus_done => "集中終了。休憩しましょう。";
  String get pomodoro_break_done => "休憩終了。集中に戻りましょう。";
  String get start_focus => "集中を開始";
  String get start_break => "休憩を開始";
  String get skins_title => "スキン";
  String get skins_customize => "カスタマイズ";
  String skins_customize_named(String name) => "$name をカスタマイズ";
  String get skins_done => "完了";
  String get skins_in_use => "使用中";
  String get skins_yours => "マイスキン";
  String get skins_classic => "クラシック";
  String get skins_bold => "ボールド";
  String get skins_type => "書体";
  String get skins_new => "新しいスキン";
  String get skins_from_current => "現在のスキンから";
  String get customize_title => "スキンをカスタマイズ";
  String get customize_name => "名前";
  String customize_copy_name(String name) => "$name のコピー";
  String get customize_font => "フォント";
  String get customize_digits => "数字";
  String get customize_card => "カード";
  String get customize_ground => "背景";
  String get customize_custom_colour => "カスタムカラー";
  String get customize_hex_hint => "16進数(例: #FF7A00)";
  String get customize_hex_invalid => "#FF7A00 のように16進数を6桁で入力してください。";
  String get customize_apply => "適用";
  String get customize_low_contrast => "数字が読みにくい可能性があります。";
  String get customize_details => "詳細";
  String get customize_seconds => "秒";
  String get customize_seconds_off => "オフ";
  String get customize_seconds_badge => "小さく";
  String get customize_seconds_cards => "カード";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "非表示";
  String get customize_meridiem_left => "内側";
  String get customize_meridiem_right => "横";
  String get customize_save => "スキンを保存";
  String get customize_reset => "リセット";
  String get customize_delete => "スキンを削除";
  String get skin_mono => "モノ";
  String get skin_paper => "ペーパー";
  String get skin_rose => "ローズ";
  String get skin_violet => "バイオレット";
  String get skin_amber => "アンバー";
  String get skin_signal => "シグナル";
  String get skin_field => "フィールド";
  String get skin_mint => "ミント";
  String get skin_cyan => "シアン";
  String get skin_taxi => "タクシー";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "ポスター";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "セリフ";
  String get skin_orbit => "オービット";
  String get skin_nightstand => "ベッドサイド";
  String get skin_studio => "スタジオ";
  String get skin_arcade => "アーケード";
  String get skin_railway => "駅";
  String get skin_desk => "デスク";
  String get skin_neon => "ネオン";
  String get skin_minimal => "ミニマル";
  String get mode_pomodoro => "ポモドーロ";
  String get mode_clock => "時計";
  String get mode_stopwatch => "ストップウォッチ";
  String get action_start => "開始";
  String get action_pause => "一時停止";
  String get action_resume => "再開";
  String get action_reset => "リセット";
  String get action_restart => "やり直す";
  String get action_done => "完了";
  String get action_skins => "スキン";
  String get action_settings => "設定";
  String get action_rotation => "画面の回転";
  String get action_timer_settings => "タイマー設定";
  String preset_minutes(int minutes) => "${minutes}分";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "ポモドーロ";
  String preset_spoken_minutes(int minutes) => "${minutes}分のタイマー";
  String preset_spoken_seconds(int seconds) => "${seconds}秒のタイマー";
  String preset_spoken_both(int minutes, int seconds) =>
      "${minutes}分${seconds}秒のタイマー";
  String get action_lap => "ラップ";
  String lap_label(int number, String time) => "ラップ $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "外観";
  String get settings_clock => "時計";
  String get settings_gestures => "ジェスチャ";
  String get settings_timers => "タイマー";
  String get settings_sound => "サウンドとアラート";
  String get settings_awake => "スリープしない";
  String get settings_shortcuts => "ショートカット";
  String get settings_about => "このアプリについて";
  String get theme_dark => "ダーク";
  String get theme_system => "システムに合わせる";
  String get gesture_swipes => "スワイプ";
  String get gesture_brightness => "上下にスワイプで明るさ調整";
  String get gesture_modes => "左右にスワイプでモード切替";
  String get gesture_footer =>
      "時計のどこでもスワイプできます。Mac、Windows、Web では画面ではなく数字の明るさが変わります。";
  String get gesture_controls => "操作ボタン";
  String get gesture_tap => "タップで操作ボタンを表示";
  String get gesture_idle => "操作ボタンを隠すまで";
  String gesture_idle_seconds(int seconds) => "${seconds}秒";
  String get gesture_idle_never => "なし";
  String get gesture_controls_footer => "操作ボタンは点になってから消えます。";
  String get timers_default => "デフォルトのタイマー";
  String get timers_start_runs => "開始で実行";
  String get timers_presets => "プリセット";
  String get timers_add => "タイマーを追加";
  String get timers_limit_footer => "アイランドに入るタイマーは6つまでです。追加するには1つ削除してください。";
  String timers_delete(String timer) => "$timer を削除";
  String get timers_duplicate => "このタイマーはすでにあります。";
  String get timers_picker_minutes => "分";
  String get timers_picker_seconds => "秒";
  String get skins_view_all => "すべて表示";
  String get timers_pomodoro_focus => "集中";
  String get timers_pomodoro_break => "休憩";
  String timers_minutes(int minutes) => "${minutes}分";
  String get sound_footer => "通知がオフでも、アプリ内のアラートは必ず鳴ります。";
  String get shortcuts_touch => "タッチ";
  String get shortcuts_keyboard => "キーボード";
  String get touch_controls => "操作ボタンの表示/非表示";
  String get shortcut_off => "オフ";
  String get key_start_pause => "開始/一時停止";
  String get key_change_mode => "モード切替";
  String get key_brightness => "明るさ";
  String get key_show_seconds => "秒を表示";
  String get key_full_screen => "全画面表示";
  String get key_hide_controls => "操作ボタンを隠す";
  String get key_dim => "数字を暗くする";
  String get key_lap => "ラップ(ストップウォッチ)";
  String get key_rotation => "画面の回転";
  String get keycap_space => "スペース";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "ライセンス";
  String get about_privacy => "プライバシー";
  String get about_privacy_value => "広告なし。アカウントは任意です。匿名の利用統計をアプリの改善に役立てています。";
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

class SyncMessages_ja extends SyncMessages {
  final Messages_ja _parent;
  const SyncMessages_ja(this._parent) : super(_parent);
  String get account => "アカウント";
  String get card_title_signed_out => "設定はこのデバイスに保存されます";
  String get card_body_signed_out => "他のデバイスでも使いたい場合のみログインしてください。";
  String get card_title_on => "同期はオンです";
  String get card_title_off => "同期はオフです";
  String card_last_synced(String when) => "最終同期 $when";
  String get headline => "設定はこのデバイスに保存されます";
  String get body =>
      "QuietFlip にアカウントは不要です。時計、スキン、サウンドを他のデバイスでも使いたい場合のみログインしてください。";
  String get sign_in => "ログインして同期";
  String get sign_in_reason => "デバイス間で設定を同期する場合のみ必要です。";
  String get what_syncs => "同期される項目";
  String get what_syncs_body => "テーマ、スキン、サウンド、時計とタイマーの設定。";
  String get stays_body => "このデバイスのみ: 明るさ、回転、通知、実行中のタイマー。";
  String get sync_header => "同期";
  String get sync_settings => "設定を同期";
  String get sync_settings_note => "ログインしたすべてのデバイスに設定が反映されます。";
  String get last_synced => "最終同期";
  String get just_now => "たった今";
  String minutes_ago(int n) => "${n}分前";
  String today_at(String time) => "今日 $time";
  String get never => "未同期";
  String get syncing => "同期中…";
  String get waiting => "接続を待っています";
  String get off_note => "同期はオフです。変更はこのデバイスにのみ保存されます。";
  String get failed_offline => "同期できませんでした: 接続がありません。オンラインに戻ると再試行します。";
  String get failed_denied => "同期できませんでした: もう一度ログインしてください。";
  String get failed_unknown => "同期できませんでした。もう一度お試しください。";
  String get try_again => "再試行";
  String get sign_out_note => "ログアウトしても、設定はこのデバイスに残ります。";
  String get delete_account => "アカウントを削除";
  String get delete_title => "アカウントを削除しますか?";
  String get delete_body => "同期した設定はクラウドから削除されます。このデバイスの設定は残ります。";
  String get delete_recent_login => "アカウントを削除するには、もう一度ログインしてください";
  String get delete_failed => "アカウントを削除できませんでした。もう一度お試しください。";
  String get provider_email => "メール";
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
