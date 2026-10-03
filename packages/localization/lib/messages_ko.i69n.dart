// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'ko';
String get _localeName => 'ko';

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

class Messages_ko extends Messages {
  const Messages_ko();
  AppMessages_ko get app => AppMessages_ko(this);
  GenericMessages_ko get generic => GenericMessages_ko(this);
  CommonMessages_ko get common => CommonMessages_ko(this);
  AuthMessages_ko get auth => AuthMessages_ko(this);
  ProfileMessages_ko get profile => ProfileMessages_ko(this);
  NavMessages_ko get nav => NavMessages_ko(this);
  NotificationsMessages_ko get notifications => NotificationsMessages_ko(this);
  ErrorsMessages_ko get errors => ErrorsMessages_ko(this);
  ValidationMessages_ko get validation => ValidationMessages_ko(this);
  FilesMessages_ko get files => FilesMessages_ko(this);
  DeveloperMessages_ko get developer => DeveloperMessages_ko(this);
  ClockMessages_ko get clock => ClockMessages_ko(this);
  SyncMessages_ko get sync => SyncMessages_ko(this);
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

class AppMessages_ko extends AppMessages {
  final Messages_ko _parent;
  const AppMessages_ko(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description => "광고 없는 플립 시계, 타이머, 스톱워치.";
  String get welcome_to_app => "QuietFlip에 오신 것을 환영합니다!";
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

class GenericMessages_ko extends GenericMessages {
  final Messages_ko _parent;
  const GenericMessages_ko(this._parent) : super(_parent);
  String get ok => "확인";
  String get cancel => "취소";
  String get save => "저장";
  String get delete => "삭제";
  String get edit => "편집";
  String get update => "업데이트";
  String get submit => "제출";
  String get close => "닫기";
  String get back => "뒤로";
  String get next => "다음";
  String get previous => "이전";
  String get done => "완료";
  String get loading => "로드 중...";
  String get error => "오류";
  String get success => "성공";
  String get warning => "경고";
  String get info => "정보";
  String get retry => "재시도";
  String get refresh => "새로고침";
  String get yes => "예";
  String get no => "아니요";
  String get add => "+ 추가";
  String get try_again => "다시 시도";
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

class CommonMessages_ko extends CommonMessages {
  final Messages_ko _parent;
  const CommonMessages_ko(this._parent) : super(_parent);
  String get week => "주";
  String get month => "월";
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

class AuthMessages_ko extends AuthMessages {
  final Messages_ko _parent;
  const AuthMessages_ko(this._parent) : super(_parent);
  String get register => "가입";
  String get sign_in => "로그인";
  String get sign_out => "로그아웃";
  String get dont_have_account => "계정이 없으신가요? ";
  String get already_have_account => "이미 계정이 있으신가요? ";
  String get sign_out_confirmation => "로그아웃하시겠습니까?";
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

class ProfileMessages_ko extends ProfileMessages {
  final Messages_ko _parent;
  const ProfileMessages_ko(this._parent) : super(_parent);
  String get profile => "프로필";
  String get settings => "설정";
  String get account => "계정";
  String get personal_info => "개인 정보";
  String get privacy_settings => "개인정보 설정";
  String get name => "이름";
  String get email_address => "이메일 주소";
  String get phone_number => "전화번호";
  String get date_of_birth => "생년월일";
  String get delete_confirmation => "삭제 확인";
  String get delete_confirmation_message => "이 항목을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.";
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

class NavMessages_ko extends NavMessages {
  final Messages_ko _parent;
  const NavMessages_ko(this._parent) : super(_parent);
  String get home => "홈";
  String get dashboard => "대시보드";
  String get explore => "탐색";
  String get explore_placeholder => "두 번째 탭입니다. 실제 기능으로 교체하세요.";
  String get profile => "프로필";
  String get settings => "설정";
  String get notifications => "알림";
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

class NotificationsMessages_ko extends NotificationsMessages {
  final Messages_ko _parent;
  const NotificationsMessages_ko(this._parent) : super(_parent);
  String get title => "알림";
  String get mark_as_read => "읽음으로 표시";
  String get mark_all_read => "모두 읽음으로 표시";
  String get delete => "삭제";
  String get filter_all => "전체";
  String get filter_unread => "읽지 않음";
  String get filter_read => "읽음";
  String get type_reminder => "리마인더";
  String get type_alert => "경고";
  String get type_promotion => "프로모션";
  String get type_system => "시스템";
  String get type_custom => "사용자 지정";
  String get empty_title => "알림 없음";
  String get empty_description => "모두 확인했습니다! 새 알림이 여기에 표시됩니다.";
  String get delete_confirmation_title => "알림을 삭제하시겠습니까?";
  String get delete_confirmation_message => "이 알림은 목록에서 영구적으로 삭제됩니다.";
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

class ErrorsMessages_ko extends ErrorsMessages {
  final Messages_ko _parent;
  const ErrorsMessages_ko(this._parent) : super(_parent);
  String get network_error => "네트워크 오류입니다. 연결을 확인하세요.";
  String get unknown_error => "알 수 없는 오류가 발생했습니다.";
  String get validation_error => "입력 내용을 확인하고 다시 시도하세요.";
  String get server_error => "서버 오류입니다. 나중에 다시 시도하세요.";
  String get default_error_message => "문제가 발생했습니다. 다시 시도하세요.";
  String get user_not_found => "사용자를 찾을 수 없습니다. 로그인 정보를 확인하세요.";
  String get default_error_description =>
      "요청을 처리하는 중 오류가 발생했습니다. 불편을 드려 죄송합니다. 나중에 다시 시도하거나, 문제가 계속되면 지원팀에 문의하세요.";
  String get page_not_found => "페이지를 찾을 수 없음";
  String get page_not_found_description => "찾으시는 페이지가 존재하지 않습니다.";
  String get unexpected_error => "예기치 않은 오류가 발생했습니다.";
  String get redirect_error => "리디렉션 오류";
  String get bad_request => "잘못된 요청입니다. 입력 내용을 확인하세요.";
  String get unauthorized => "인증이 필요합니다. 다시 로그인하세요.";
  String get forbidden => "액세스가 거부되었습니다. 권한이 없습니다.";
  String get not_found => "요청한 리소스를 찾을 수 없습니다.";
  String get conflict => "데이터 충돌입니다. 새로고침 후 다시 시도하세요.";
  String get unprocessable_entity => "잘못된 데이터 형식입니다. 입력 내용을 확인하세요.";
  String get internal_server_error => "서버 오류입니다. 나중에 다시 시도하세요.";
  String get connection_timeout => "연결 시간이 초과되었습니다. 인터넷을 확인하세요.";
  String get receive_timeout => "요청 시간이 초과되었습니다. 다시 시도하세요.";
  String get send_timeout => "업로드 시간이 초과되었습니다. 다시 시도하세요.";
  String get no_internet => "인터넷에 연결되어 있지 않습니다. 네트워크를 확인하세요.";
  String get unknown_network => "네트워크 오류가 발생했습니다. 다시 시도하세요.";
  String format_exception_message(String code, String postfix) =>
      "이 데이터는 형식이 달라 알아볼 수 없어요 [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "예상과 다른 데이터라 처리할 수 없어요 [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "목록에서 해당 항목을 찾을 수 없어요 [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "앗! 허용 범위를 벗어난 숫자예요 [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "전달된 값에 문제가 있어요 [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "지금 무엇을 해야 할지 헷갈려요 [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "이 기능은 아직 준비 중이에요 [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "죄송해요, 아직 지원하지 않는 작업이에요 [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "한꺼번에 너무 많은 일이 일어나고 있어요 [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "메모리가 가득 찼어요! 공간을 비워야 해요 [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "같은 동작을 끝없이 반복하고 있어요 [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "예상치 못한 일이 생겼지만 걱정하지 마세요 [$code] $postfix";
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

class ValidationMessages_ko extends ValidationMessages {
  final Messages_ko _parent;
  const ValidationMessages_ko(this._parent) : super(_parent);
  String get required_field => "필수 입력 항목입니다";
  String get invalid_email => "올바른 이메일 주소를 입력하세요";
  String get password_too_short => "비밀번호는 8자 이상이어야 합니다";
  String get passwords_dont_match => "비밀번호가 일치하지 않습니다";
  String invalid_key_config(String of, String key) =>
      "${of}의 $key 구성이 잘못되었습니다. 설정을 확인하세요.";
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

class FilesMessages_ko extends FilesMessages {
  final Messages_ko _parent;
  const FilesMessages_ko(this._parent) : super(_parent);
  String get info_title => "파일 정보";
  String get name => "파일 이름";
  String get type => "파일 유형";
  String get extension => "파일 확장자";
  String get size => "파일 크기";
  String get path => "파일 경로";
  String get copy_hint => "항목을 탭하면 클립보드에 복사됩니다";
  String copied(String field) => "${field}을(를) 클립보드에 복사했습니다";
  String image_type(String format) => "$format 이미지";
  String get image_file => "이미지 파일";
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

class DeveloperMessages_ko extends DeveloperMessages {
  final Messages_ko _parent;
  const DeveloperMessages_ko(this._parent) : super(_parent);
  String get no_viewer => "이 로거에는 대화형 뷰어가 없습니다.";
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

class ClockMessages_ko extends ClockMessages {
  final Messages_ko _parent;
  const ClockMessages_ko(this._parent) : super(_parent);
  String get clock => "시계";
  String get stopwatch => "스톱워치";
  String get modes => "모드";
  String get settings => "설정";
  String get times_up => "시간 종료";
  String get timer_finished_title => "시간 종료";
  String get timer_finished_body => "QuietFlip 타이머가 끝났습니다.";
  String get alerts_channel => "타이머 알림";
  String get show_controls => "탭하거나 마우스를 움직이면 컨트롤이 표시됩니다";
  String get theme => "테마";
  String get theme_light => "라이트";
  String get use_24h => "24시간제";
  String get show_seconds => "초 표시";
  String get sound_tick_group => "틱";
  String get sound_tick_hint => "넘어갈 때마다 재생";
  String get sound_alarm_group => "알람";
  String get sound_alarm_hint => "끌 때까지 반복, 최대 60초";
  String get tick_sound => "틱 소리";
  String get tick_sound_description => "카드가 넘어갈 때마다 나는 부드러운 소리";
  String get alarm_sound => "알람 소리";
  String get alarm_sound_description => "타이머나 뽀모도로 단계가 끝나면 재생";
  String get tick_classic => "클래식";
  String get tick_classic_mood => "부드러운 딸깍";
  String get tick_split_flap => "플랩";
  String get tick_split_flap_mood => "넘기는 소리";
  String get tick_clockwork => "태엽";
  String get tick_clockwork_mood => "손목시계 째깍";
  String get tick_woodblock => "목탁";
  String get tick_woodblock_mood => "속이 빈 울림";
  String get tick_digital => "디지털";
  String get tick_digital_mood => "깔끔한 삑";
  String get alarm_chime => "차임";
  String get alarm_chime_mood => "두 음";
  String get alarm_bell => "종";
  String get alarm_bell_mood => "종소리";
  String get alarm_beeps => "비프";
  String get alarm_beeps_mood => "탁상시계";
  String get alarm_rising => "점점 크게";
  String get alarm_rising_mood => "마림바";
  String get alarm_ring => "벨";
  String get alarm_ring_mood => "쌍종";
  String get system_notifications => "시스템 알림";
  String get system_notifications_description =>
      "QuietFlip이 백그라운드에 있어도 타이머가 끝나면 알림을 받습니다.";
  String get permission_denied =>
      "QuietFlip 알림이 꺼져 있습니다. 앱이 열려 있는 동안에는 알림을 보고 들을 수 있습니다.";
  String get web_closed_tab_note => "브라우저에서는 이 탭이 열려 있는 동안에만 알림이 작동합니다.";
  String get keep_screen_awake => "화면 켜짐 유지";
  String get keep_screen_awake_description => "시계가 표시되는 동안 화면이 꺼지지 않게 합니다.";
  String current_time(String time) => "현재 시각 $time";
  String time_remaining(String time) => "남은 시간 $time";
  String elapsed(String time) => "경과 시간 $time";
  String get digit_brightness => "숫자 밝기";
  String percent(String value) => "$value%";
  String get subtle_movement => "미세 이동";
  String get subtle_movement_description =>
      "전체 화면에서 매분 시계를 몇 픽셀씩 옮겨 같은 픽셀이 밤새 켜져 있지 않게 합니다. 번인 위험을 줄이지만 완전히 막지는 못합니다.";
  String get full_screen_note =>
      "전체 화면은 QuietFlip이 열려 있는 동안 컨트롤을 숨깁니다. 앱이 계속 열려 있어야 합니다. 잠금 화면이나 화면 보호기가 아닙니다.";
  String get show_date => "날짜 표시";
  String current_time_and_date(String time, String date) =>
      "현재 시각 $time, $date";
  String get orientation => "방향";
  String get orientation_auto => "자동";
  String get orientation_landscape => "가로";
  String get orientation_portrait => "세로";
  String get settings_card_size => "카드 크기";
  String get card_size_small => "작게";
  String get card_size_medium => "보통";
  String get card_size_large => "크게";
  String get settings_corners => "모서리";
  String get corners_square => "각진";
  String get corners_round => "둥근";
  String corners_value(String value) => "$value px";
  String get pomodoro => "뽀모도로";
  String pomodoro_focus(int round) => "집중 · ${round}회차";
  String pomodoro_break(int round) => "휴식 · ${round}회차";
  String get pomodoro_focus_done => "집중 완료. 쉴 시간입니다.";
  String get pomodoro_break_done => "휴식 끝. 다시 집중하세요.";
  String get start_focus => "집중 시작";
  String get start_break => "휴식 시작";
  String get skins_title => "스킨";
  String get skins_customize => "사용자 지정";
  String skins_customize_named(String name) => "$name 사용자 지정";
  String get skins_done => "완료";
  String get skins_in_use => "사용 중";
  String get skins_yours => "내 스킨";
  String get skins_classic => "클래식";
  String get skins_bold => "굵게";
  String get skins_type => "서체";
  String get skins_new => "새 스킨";
  String get skins_from_current => "현재 스킨에서";
  String get customize_title => "스킨 사용자 지정";
  String get customize_name => "이름";
  String customize_copy_name(String name) => "$name 사본";
  String get customize_font => "글꼴";
  String get customize_digits => "숫자";
  String get customize_card => "카드";
  String get customize_ground => "배경";
  String get customize_custom_colour => "사용자 지정 색상";
  String get customize_hex_hint => "16진수, 예: #FF7A00";
  String get customize_hex_invalid => "#FF7A00처럼 16진수 6자리를 입력하세요.";
  String get customize_apply => "적용";
  String get customize_low_contrast => "숫자가 잘 보이지 않을 수 있습니다.";
  String get customize_details => "세부 설정";
  String get customize_seconds => "초";
  String get customize_seconds_off => "끔";
  String get customize_seconds_badge => "작게";
  String get customize_seconds_cards => "카드";
  String get customize_meridiem => "오전 / 오후";
  String get customize_meridiem_hidden => "숨김";
  String get customize_meridiem_left => "안쪽";
  String get customize_meridiem_right => "옆";
  String get customize_save => "스킨 저장";
  String get customize_reset => "초기화";
  String get customize_delete => "스킨 삭제";
  String get skin_mono => "모노";
  String get skin_paper => "종이";
  String get skin_rose => "로즈";
  String get skin_violet => "바이올렛";
  String get skin_amber => "앰버";
  String get skin_signal => "신호";
  String get skin_field => "들판";
  String get skin_mint => "민트";
  String get skin_cyan => "시안";
  String get skin_taxi => "택시";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "포스터";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "세리프";
  String get skin_orbit => "궤도";
  String get skin_nightstand => "침대맡";
  String get skin_studio => "스튜디오";
  String get skin_arcade => "아케이드";
  String get skin_railway => "철도";
  String get skin_desk => "책상";
  String get skin_neon => "네온";
  String get skin_minimal => "미니멀";
  String get mode_pomodoro => "뽀모도로";
  String get mode_clock => "시계";
  String get mode_stopwatch => "스톱워치";
  String get action_start => "시작";
  String get action_pause => "일시정지";
  String get action_resume => "계속";
  String get action_reset => "초기화";
  String get action_restart => "다시 시작";
  String get action_done => "완료";
  String get action_skins => "스킨";
  String get action_settings => "설정";
  String get action_rotation => "화면 회전";
  String get action_timer_settings => "타이머 설정";
  String preset_minutes(int minutes) => "${minutes}분";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "뽀모도로";
  String preset_spoken_minutes(int minutes) => "${minutes}분 타이머";
  String preset_spoken_seconds(int seconds) => "${seconds}초 타이머";
  String preset_spoken_both(int minutes, int seconds) =>
      "${minutes}분 ${seconds}초 타이머";
  String get action_lap => "랩";
  String lap_label(int number, String time) => "랩 $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "화면 스타일";
  String get settings_clock => "시계";
  String get settings_gestures => "제스처";
  String get settings_timers => "타이머";
  String get settings_sound => "소리 및 알림";
  String get settings_awake => "켜짐 유지";
  String get settings_shortcuts => "단축키";
  String get settings_about => "정보";
  String get theme_dark => "다크";
  String get theme_system => "시스템 설정";
  String get gesture_swipes => "스와이프";
  String get gesture_brightness => "위아래로 스와이프해 밝기 조절";
  String get gesture_modes => "옆으로 스와이프해 모드 변경";
  String get gesture_footer =>
      "시계 어디서나 스와이프하세요. Mac, Windows, 웹에서는 화면 대신 숫자가 어두워집니다.";
  String get gesture_controls => "컨트롤";
  String get gesture_tap => "탭하여 컨트롤 표시";
  String get gesture_idle => "컨트롤 숨기기";
  String gesture_idle_seconds(int seconds) => "${seconds}초";
  String get gesture_idle_never => "안 함";
  String get gesture_controls_footer => "컨트롤이 점으로 줄어든 뒤 사라집니다.";
  String get timers_default => "기본 타이머";
  String get timers_start_runs => "시작 시 실행";
  String get timers_presets => "프리셋";
  String get timers_add => "타이머 추가";
  String get timers_limit_footer => "아일랜드에는 타이머 6개까지 들어갑니다. 추가하려면 하나를 삭제하세요.";
  String timers_delete(String timer) => "$timer 삭제";
  String get timers_duplicate => "이미 있는 타이머입니다.";
  String get timers_picker_minutes => "분";
  String get timers_picker_seconds => "초";
  String get skins_view_all => "모두 보기";
  String get timers_pomodoro_focus => "집중";
  String get timers_pomodoro_break => "휴식";
  String timers_minutes(int minutes) => "${minutes}분";
  String get sound_footer => "앱 안의 알림음은 알림이 꺼져 있어도 항상 재생됩니다.";
  String get shortcuts_touch => "터치";
  String get shortcuts_keyboard => "키보드";
  String get touch_controls => "컨트롤 표시 또는 숨기기";
  String get shortcut_off => "끔";
  String get key_start_pause => "시작 또는 일시정지";
  String get key_change_mode => "모드 변경";
  String get key_brightness => "밝기";
  String get key_show_seconds => "초 표시";
  String get key_full_screen => "전체 화면";
  String get key_hide_controls => "컨트롤 숨기기";
  String get key_dim => "숫자 어둡게";
  String get key_lap => "랩 (스톱워치)";
  String get key_rotation => "화면 회전";
  String get keycap_space => "스페이스";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "라이선스";
  String get about_privacy => "개인정보 보호";
  String get about_privacy_value => "광고 없음. 추적 없음. 계정은 선택 사항입니다.";
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

class SyncMessages_ko extends SyncMessages {
  final Messages_ko _parent;
  const SyncMessages_ko(this._parent) : super(_parent);
  String get account => "계정";
  String get card_title_signed_out => "설정은 이 기기에만 저장됩니다";
  String get card_body_signed_out => "다른 기기에서도 쓰고 싶을 때만 로그인하세요.";
  String get card_title_on => "동기화 켜짐";
  String get card_title_off => "동기화 꺼짐";
  String card_last_synced(String when) => "마지막 동기화 $when";
  String get headline => "설정은 이 기기에만 저장됩니다";
  String get body =>
      "QuietFlip은 계정이 필요 없습니다. 시계, 스킨, 소리를 다른 기기에서도 쓰고 싶을 때만 로그인하세요.";
  String get sign_in => "로그인하여 동기화";
  String get sign_in_reason => "기기 간 설정 동기화에만 필요합니다.";
  String get what_syncs => "동기화 항목";
  String get what_syncs_body => "테마, 스킨, 소리, 시계 및 타이머 설정.";
  String get stays_body => "이 기기에만 유지: 밝기, 회전, 알림, 실행 중인 타이머.";
  String get sync_header => "동기화";
  String get sync_settings => "설정 동기화";
  String get sync_settings_note => "로그인한 모든 기기에서 같은 설정을 사용합니다.";
  String get last_synced => "마지막 동기화";
  String get just_now => "방금";
  String minutes_ago(int n) => "${n}분 전";
  String today_at(String time) => "오늘 $time";
  String get never => "아직 없음";
  String get syncing => "동기화 중…";
  String get waiting => "연결 대기 중";
  String get off_note => "동기화가 꺼져 있습니다. 변경 사항은 이 기기에만 저장됩니다.";
  String get failed_offline => "동기화 실패: 연결 없음. 다시 온라인이 되면 재시도합니다.";
  String get failed_denied => "동기화 실패: 다시 로그인하세요.";
  String get failed_unknown => "동기화하지 못했습니다. 다시 시도하세요.";
  String get try_again => "다시 시도";
  String get sign_out_note => "로그아웃해도 설정은 이 기기에 남습니다.";
  String get delete_account => "계정 삭제";
  String get delete_title => "계정을 삭제하시겠습니까?";
  String get delete_body => "동기화된 설정이 클라우드에서 삭제됩니다. 이 기기의 설정은 유지됩니다.";
  String get delete_recent_login => "계정을 삭제하려면 다시 로그인하세요";
  String get delete_failed => "계정을 삭제하지 못했습니다. 다시 시도하세요.";
  String get provider_email => "이메일";
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
