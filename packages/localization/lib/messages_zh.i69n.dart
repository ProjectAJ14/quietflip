// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'zh';
String get _localeName => 'zh';

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

class Messages_zh extends Messages {
  const Messages_zh();
  AppMessages_zh get app => AppMessages_zh(this);
  GenericMessages_zh get generic => GenericMessages_zh(this);
  CommonMessages_zh get common => CommonMessages_zh(this);
  AuthMessages_zh get auth => AuthMessages_zh(this);
  ProfileMessages_zh get profile => ProfileMessages_zh(this);
  NavMessages_zh get nav => NavMessages_zh(this);
  NotificationsMessages_zh get notifications => NotificationsMessages_zh(this);
  ErrorsMessages_zh get errors => ErrorsMessages_zh(this);
  ValidationMessages_zh get validation => ValidationMessages_zh(this);
  FilesMessages_zh get files => FilesMessages_zh(this);
  DeveloperMessages_zh get developer => DeveloperMessages_zh(this);
  ClockMessages_zh get clock => ClockMessages_zh(this);
  SyncMessages_zh get sync => SyncMessages_zh(this);
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

class AppMessages_zh extends AppMessages {
  final Messages_zh _parent;
  const AppMessages_zh(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description => "无广告的翻页时钟、倒计时器和秒表。";
  String get welcome_to_app => "欢迎使用 QuietFlip！";
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

class GenericMessages_zh extends GenericMessages {
  final Messages_zh _parent;
  const GenericMessages_zh(this._parent) : super(_parent);
  String get ok => "好";
  String get cancel => "取消";
  String get save => "保存";
  String get delete => "删除";
  String get edit => "编辑";
  String get update => "更新";
  String get submit => "提交";
  String get close => "关闭";
  String get back => "返回";
  String get next => "下一步";
  String get previous => "上一步";
  String get done => "完成";
  String get loading => "正在加载…";
  String get error => "错误";
  String get success => "成功";
  String get warning => "警告";
  String get info => "信息";
  String get retry => "重试";
  String get refresh => "刷新";
  String get yes => "是";
  String get no => "否";
  String get add => "+ 添加";
  String get try_again => "重试";
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

class CommonMessages_zh extends CommonMessages {
  final Messages_zh _parent;
  const CommonMessages_zh(this._parent) : super(_parent);
  String get week => "周";
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

class AuthMessages_zh extends AuthMessages {
  final Messages_zh _parent;
  const AuthMessages_zh(this._parent) : super(_parent);
  String get register => "注册";
  String get sign_in => "登录";
  String get sign_out => "退出登录";
  String get dont_have_account => "还没有账号？";
  String get already_have_account => "已有账号？";
  String get sign_out_confirmation => "确定要退出登录吗？";
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

class ProfileMessages_zh extends ProfileMessages {
  final Messages_zh _parent;
  const ProfileMessages_zh(this._parent) : super(_parent);
  String get profile => "个人资料";
  String get settings => "设置";
  String get account => "账号";
  String get personal_info => "个人信息";
  String get privacy_settings => "隐私设置";
  String get name => "姓名";
  String get email_address => "电子邮件地址";
  String get phone_number => "手机号码";
  String get date_of_birth => "出生日期";
  String get delete_confirmation => "确认删除";
  String get delete_confirmation_message => "确定要删除此项吗？此操作无法撤销。";
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

class NavMessages_zh extends NavMessages {
  final Messages_zh _parent;
  const NavMessages_zh(this._parent) : super(_parent);
  String get home => "首页";
  String get dashboard => "仪表板";
  String get explore => "探索";
  String get explore_placeholder => "这是第二个标签页。请替换为实际功能。";
  String get profile => "个人资料";
  String get settings => "设置";
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

class NotificationsMessages_zh extends NotificationsMessages {
  final Messages_zh _parent;
  const NotificationsMessages_zh(this._parent) : super(_parent);
  String get title => "通知";
  String get mark_as_read => "标为已读";
  String get mark_all_read => "全部标为已读";
  String get delete => "删除";
  String get filter_all => "全部";
  String get filter_unread => "未读";
  String get filter_read => "已读";
  String get type_reminder => "提醒";
  String get type_alert => "警报";
  String get type_promotion => "推广";
  String get type_system => "系统";
  String get type_custom => "自定义";
  String get empty_title => "没有通知";
  String get empty_description => "全部看完了！新通知会显示在这里。";
  String get delete_confirmation_title => "删除通知？";
  String get delete_confirmation_message => "此通知将从列表中永久移除。";
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

class ErrorsMessages_zh extends ErrorsMessages {
  final Messages_zh _parent;
  const ErrorsMessages_zh(this._parent) : super(_parent);
  String get network_error => "网络错误，请检查网络连接。";
  String get unknown_error => "发生未知错误。";
  String get validation_error => "请检查输入内容后重试。";
  String get server_error => "服务器错误，请稍后重试。";
  String get default_error_message => "哎呀，出了点问题。请重试。";
  String get user_not_found => "未找到用户，请检查登录信息。";
  String get default_error_description =>
      "处理你的请求时出错。给你带来不便，我们深表歉意。请稍后重试，如果问题仍然存在，请联系支持人员。";
  String get page_not_found => "找不到页面";
  String get page_not_found_description => "你要查找的页面不存在。";
  String get unexpected_error => "发生意外错误。";
  String get redirect_error => "重定向错误";
  String get bad_request => "请求无效，请检查输入内容。";
  String get unauthorized => "需要验证身份，请重新登录。";
  String get forbidden => "访问被拒绝，你没有权限。";
  String get not_found => "未找到请求的资源。";
  String get conflict => "数据冲突，请刷新后重试。";
  String get unprocessable_entity => "数据格式无效，请检查输入内容。";
  String get internal_server_error => "服务器错误，请稍后重试。";
  String get connection_timeout => "连接超时，请检查网络。";
  String get receive_timeout => "请求超时，请重试。";
  String get send_timeout => "上传超时，请重试。";
  String get no_internet => "没有网络连接，请检查网络。";
  String get unknown_network => "发生网络错误，请重试。";
  String format_exception_message(String code, String postfix) =>
      "这份数据格式不对，我认不出来 [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "这份数据和预期不符，无法处理 [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "嗯，列表里找不到这一项 [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "哎呀，这个数字超出范围了 [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "嘿，传入的内容有点问题 [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "我有点搞不清现在该做什么 [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "此功能仍在开发中 [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "抱歉，暂时还不支持这个操作 [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "哇，同时发生的事情太多了 [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "内存满了！需要腾出一些空间 [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "我陷入循环，转晕了 [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "发生了意外情况，但别担心 [$code] $postfix";
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

class ValidationMessages_zh extends ValidationMessages {
  final Messages_zh _parent;
  const ValidationMessages_zh(this._parent) : super(_parent);
  String get required_field => "此项为必填项";
  String get invalid_email => "请输入有效的电子邮件地址";
  String get password_too_short => "密码至少需要 8 个字符";
  String get passwords_dont_match => "两次输入的密码不一致";
  String invalid_key_config(String of, String key) => "$of 中的 $key 配置无效。请检查设置。";
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

class FilesMessages_zh extends FilesMessages {
  final Messages_zh _parent;
  const FilesMessages_zh(this._parent) : super(_parent);
  String get info_title => "文件信息";
  String get name => "文件名";
  String get type => "文件类型";
  String get extension => "文件扩展名";
  String get size => "文件大小";
  String get path => "文件路径";
  String get copy_hint => "轻点任一字段即可复制到剪贴板";
  String copied(String field) => "已将 $field 复制到剪贴板";
  String image_type(String format) => "$format 图片";
  String get image_file => "图片文件";
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

class DeveloperMessages_zh extends DeveloperMessages {
  final Messages_zh _parent;
  const DeveloperMessages_zh(this._parent) : super(_parent);
  String get no_viewer => "此日志记录器没有交互式查看器。";
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

class ClockMessages_zh extends ClockMessages {
  final Messages_zh _parent;
  const ClockMessages_zh(this._parent) : super(_parent);
  String get clock => "时钟";
  String get stopwatch => "秒表";
  String get modes => "模式";
  String get settings => "设置";
  String get times_up => "时间到";
  String get timer_finished_title => "时间到";
  String get timer_finished_body => "你的 QuietFlip 计时器已结束。";
  String get alerts_channel => "计时器提醒";
  String get show_controls => "轻点或移动鼠标以显示控件";
  String get theme => "主题";
  String get theme_light => "浅色";
  String get use_24h => "24 小时制";
  String get show_seconds => "显示秒";
  String get sound_tick_group => "嘀嗒声";
  String get sound_tick_hint => "每次翻页时播放";
  String get sound_alarm_group => "闹铃";
  String get sound_alarm_hint => "循环播放直到关闭，最长 60 秒";
  String get tick_sound => "嘀嗒声";
  String get tick_sound_description => "每次翻牌时发出轻柔的声音";
  String get alarm_sound => "闹铃声";
  String get alarm_sound_description => "计时器或番茄钟阶段结束时播放";
  String get tick_classic => "经典";
  String get tick_classic_mood => "轻柔咔嗒";
  String get tick_split_flap => "翻牌";
  String get tick_split_flap_mood => "翻页啪嗒";
  String get tick_clockwork => "发条";
  String get tick_clockwork_mood => "手表嘀嗒";
  String get tick_woodblock => "木鱼";
  String get tick_woodblock_mood => "空心敲击";
  String get tick_digital => "数字";
  String get tick_digital_mood => "清脆哔声";
  String get alarm_chime => "钟鸣";
  String get alarm_chime_mood => "双音";
  String get alarm_bell => "铃";
  String get alarm_bell_mood => "敲钟";
  String get alarm_beeps => "哔哔";
  String get alarm_beeps_mood => "床头闹钟";
  String get alarm_rising => "渐强";
  String get alarm_rising_mood => "马林巴";
  String get alarm_ring => "响铃";
  String get alarm_ring_mood => "双铃";
  String get system_notifications => "系统通知";
  String get system_notifications_description =>
      "即使 QuietFlip 在后台运行，计时器结束时也会收到通知。";
  String get permission_denied => "QuietFlip 的通知已关闭。应用打开时，你仍能看到并听到提醒。";
  String get web_closed_tab_note => "在浏览器中，只有此标签页保持打开时提醒才有效。";
  String get keep_screen_awake => "保持屏幕常亮";
  String get keep_screen_awake_description => "显示时钟时阻止屏幕休眠。";
  String current_time(String time) => "当前时间 $time";
  String time_remaining(String time) => "剩余时间 $time";
  String elapsed(String time) => "已用时间 $time";
  String get digit_brightness => "数字亮度";
  String percent(String value) => "$value%";
  String get subtle_movement => "细微移动";
  String get subtle_movement_description =>
      "全屏时，每分钟将时钟移动几个像素，避免同一批像素整夜常亮。可降低但无法完全避免烧屏风险。";
  String get full_screen_note =>
      "全屏会在 QuietFlip 打开时隐藏控件。应用必须保持打开。它不是锁屏或屏幕保护程序。";
  String get show_date => "显示日期";
  String current_time_and_date(String time, String date) => "当前时间 $time，$date";
  String get orientation => "方向";
  String get orientation_auto => "自动";
  String get orientation_landscape => "横向";
  String get orientation_portrait => "纵向";
  String get settings_card_size => "卡片大小";
  String get card_size_small => "小";
  String get card_size_medium => "中";
  String get card_size_large => "大";
  String get settings_corners => "圆角";
  String get corners_square => "直角";
  String get corners_round => "圆角";
  String corners_value(String value) => "$value px";
  String get pomodoro => "番茄钟";
  String pomodoro_focus(int round) => "专注 · 第 $round 轮";
  String pomodoro_break(int round) => "休息 · 第 $round 轮";
  String get pomodoro_focus_done => "专注结束，休息一下吧。";
  String get pomodoro_break_done => "休息结束，继续专注。";
  String get start_focus => "开始专注";
  String get start_break => "开始休息";
  String get skins_title => "皮肤";
  String get skins_customize => "自定义";
  String skins_customize_named(String name) => "自定义 $name";
  String get skins_done => "完成";
  String get skins_in_use => "使用中";
  String get skins_yours => "我的皮肤";
  String get skins_classic => "经典";
  String get skins_bold => "粗体";
  String get skins_type => "字体";
  String get skins_new => "新建皮肤";
  String get skins_from_current => "基于当前";
  String get customize_title => "自定义皮肤";
  String get customize_name => "名称";
  String customize_copy_name(String name) => "$name 副本";
  String get customize_font => "字体";
  String get customize_digits => "数字";
  String get customize_card => "卡片";
  String get customize_ground => "背景";
  String get customize_custom_colour => "自定义颜色";
  String get customize_hex_hint => "十六进制，例如 #FF7A00";
  String get customize_hex_invalid => "请输入六位十六进制数，例如 #FF7A00。";
  String get customize_apply => "应用";
  String get customize_low_contrast => "数字可能难以看清。";
  String get customize_details => "细节";
  String get customize_seconds => "秒";
  String get customize_seconds_off => "关";
  String get customize_seconds_badge => "小";
  String get customize_seconds_cards => "卡片";
  String get customize_meridiem => "上午 / 下午";
  String get customize_meridiem_hidden => "隐藏";
  String get customize_meridiem_left => "内侧";
  String get customize_meridiem_right => "旁边";
  String get customize_save => "保存皮肤";
  String get customize_reset => "重置";
  String get customize_delete => "删除皮肤";
  String get skin_mono => "单色";
  String get skin_paper => "纸张";
  String get skin_rose => "玫瑰";
  String get skin_violet => "紫罗兰";
  String get skin_amber => "琥珀";
  String get skin_signal => "信号";
  String get skin_field => "田野";
  String get skin_mint => "薄荷";
  String get skin_cyan => "青色";
  String get skin_taxi => "出租车";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "海报";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "衬线";
  String get skin_orbit => "轨道";
  String get skin_nightstand => "床头柜";
  String get skin_studio => "工作室";
  String get skin_arcade => "街机";
  String get skin_railway => "铁路";
  String get skin_desk => "书桌";
  String get skin_neon => "霓虹";
  String get skin_minimal => "极简";
  String get mode_pomodoro => "番茄钟";
  String get mode_clock => "时钟";
  String get mode_stopwatch => "秒表";
  String get action_start => "开始";
  String get action_pause => "暂停";
  String get action_resume => "继续";
  String get action_reset => "重置";
  String get action_restart => "重新开始";
  String get action_done => "完成";
  String get action_skins => "皮肤";
  String get action_settings => "设置";
  String get action_rotation => "屏幕旋转";
  String get action_timer_settings => "计时器设置";
  String preset_minutes(int minutes) => "${minutes}分";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "番茄钟";
  String preset_spoken_minutes(int minutes) => "${minutes}分钟计时器";
  String preset_spoken_seconds(int seconds) => "${seconds}秒计时器";
  String preset_spoken_both(int minutes, int seconds) =>
      "${minutes}分${seconds}秒计时器";
  String get action_lap => "计次";
  String lap_label(int number, String time) => "计次 $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "外观";
  String get settings_clock => "时钟";
  String get settings_gestures => "手势";
  String get settings_timers => "计时器";
  String get settings_sound => "声音与提醒";
  String get settings_awake => "保持常亮";
  String get settings_shortcuts => "快捷键";
  String get settings_about => "关于";
  String get theme_dark => "深色";
  String get theme_system => "跟随系统";
  String get gesture_swipes => "滑动";
  String get gesture_brightness => "上下滑动调节亮度";
  String get gesture_modes => "左右滑动切换模式";
  String get gesture_footer => "在时钟任意位置滑动。在 Mac、Windows 和网页上，调暗的是数字而不是屏幕。";
  String get gesture_controls => "控件";
  String get gesture_tap => "轻点显示控件";
  String get gesture_idle => "控件自动隐藏";
  String gesture_idle_seconds(int seconds) => "${seconds}秒";
  String get gesture_idle_never => "永不";
  String get gesture_controls_footer => "控件会先缩成一个圆点，然后消失。";
  String get timers_default => "默认计时器";
  String get timers_start_runs => "开始时运行";
  String get timers_presets => "预设";
  String get timers_add => "添加计时器";
  String get timers_limit_footer => "灵动岛最多容纳六个计时器。删除一个才能再添加。";
  String timers_delete(String timer) => "删除 $timer";
  String get timers_duplicate => "你已有这个计时器。";
  String get timers_picker_minutes => "分钟";
  String get timers_picker_seconds => "秒";
  String get skins_view_all => "查看全部";
  String get timers_pomodoro_focus => "专注";
  String get timers_pomodoro_break => "休息";
  String timers_minutes(int minutes) => "${minutes}分钟";
  String get sound_footer => "即使关闭通知，应用内提醒也始终会播放。";
  String get shortcuts_touch => "触控";
  String get shortcuts_keyboard => "键盘";
  String get touch_controls => "显示或隐藏控件";
  String get shortcut_off => "关";
  String get key_start_pause => "开始或暂停";
  String get key_change_mode => "切换模式";
  String get key_brightness => "亮度";
  String get key_show_seconds => "显示秒";
  String get key_full_screen => "全屏";
  String get key_hide_controls => "隐藏控件";
  String get key_dim => "调暗数字";
  String get key_lap => "计次（秒表）";
  String get key_rotation => "屏幕旋转";
  String get keycap_space => "空格";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "许可";
  String get about_privacy => "隐私";
  String get about_privacy_value => "无广告。无跟踪。账号可选。";
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

class SyncMessages_zh extends SyncMessages {
  final Messages_zh _parent;
  const SyncMessages_zh(this._parent) : super(_parent);
  String get account => "账号";
  String get card_title_signed_out => "你的设置只保存在本设备上";
  String get card_body_signed_out => "只有想在其他设备上使用时才需要登录。";
  String get card_title_on => "同步已开启";
  String get card_title_off => "同步已关闭";
  String card_last_synced(String when) => "上次同步：$when";
  String get headline => "你的设置只保存在本设备上";
  String get body => "QuietFlip 无需账号。只有想在其他设备上使用你的时钟、皮肤和声音时才需要登录。";
  String get sign_in => "登录以同步";
  String get sign_in_reason => "仅用于在设备间同步设置。";
  String get what_syncs => "同步内容";
  String get what_syncs_body => "主题、皮肤、声音、时钟和计时器设置。";
  String get stays_body => "仅保留在本设备：亮度、旋转、通知和正在运行的计时器。";
  String get sync_header => "同步";
  String get sync_settings => "同步设置";
  String get sync_settings_note => "在你登录的每台设备上都使用同一套设置。";
  String get last_synced => "上次同步";
  String get just_now => "刚刚";
  String minutes_ago(int n) => "${n}分钟前";
  String today_at(String time) => "今天 $time";
  String get never => "尚未同步";
  String get syncing => "正在同步…";
  String get waiting => "正在等待连接";
  String get off_note => "同步已关闭。更改仅保存在本设备上。";
  String get failed_offline => "无法同步：没有网络连接。恢复联网后会自动重试。";
  String get failed_denied => "无法同步：请重新登录。";
  String get failed_unknown => "无法同步，请重试。";
  String get try_again => "重试";
  String get sign_out_note => "退出登录后，设置仍保留在本设备上。";
  String get delete_account => "删除账号";
  String get delete_title => "删除你的账号？";
  String get delete_body => "已同步的设置将从云端删除。本设备上的设置会保留。";
  String get delete_recent_login => "请重新登录以删除账号";
  String get delete_failed => "无法删除账号，请重试。";
  String get provider_email => "电子邮件";
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
