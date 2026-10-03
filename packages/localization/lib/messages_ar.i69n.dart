// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'ar';
String get _localeName => 'ar';

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

class Messages_ar extends Messages {
  const Messages_ar();
  AppMessages_ar get app => AppMessages_ar(this);
  GenericMessages_ar get generic => GenericMessages_ar(this);
  CommonMessages_ar get common => CommonMessages_ar(this);
  AuthMessages_ar get auth => AuthMessages_ar(this);
  ProfileMessages_ar get profile => ProfileMessages_ar(this);
  NavMessages_ar get nav => NavMessages_ar(this);
  NotificationsMessages_ar get notifications => NotificationsMessages_ar(this);
  ErrorsMessages_ar get errors => ErrorsMessages_ar(this);
  ValidationMessages_ar get validation => ValidationMessages_ar(this);
  FilesMessages_ar get files => FilesMessages_ar(this);
  DeveloperMessages_ar get developer => DeveloperMessages_ar(this);
  ClockMessages_ar get clock => ClockMessages_ar(this);
  SyncMessages_ar get sync => SyncMessages_ar(this);
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

class AppMessages_ar extends AppMessages {
  final Messages_ar _parent;
  const AppMessages_ar(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "ساعة قلّابة ومؤقت عدّ تنازلي وساعة إيقاف، بلا إعلانات.";
  String get welcome_to_app => "مرحبًا بك في QuietFlip!";
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

class GenericMessages_ar extends GenericMessages {
  final Messages_ar _parent;
  const GenericMessages_ar(this._parent) : super(_parent);
  String get ok => "حسنًا";
  String get cancel => "إلغاء";
  String get save => "حفظ";
  String get delete => "حذف";
  String get edit => "تعديل";
  String get update => "تحديث";
  String get submit => "إرسال";
  String get close => "إغلاق";
  String get back => "رجوع";
  String get next => "التالي";
  String get previous => "السابق";
  String get done => "تم";
  String get loading => "جارٍ التحميل...";
  String get error => "خطأ";
  String get success => "تم بنجاح";
  String get warning => "تحذير";
  String get info => "معلومات";
  String get retry => "إعادة المحاولة";
  String get refresh => "تحديث";
  String get yes => "نعم";
  String get no => "لا";
  String get add => "+ إضافة";
  String get try_again => "حاول مرة أخرى";
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

class CommonMessages_ar extends CommonMessages {
  final Messages_ar _parent;
  const CommonMessages_ar(this._parent) : super(_parent);
  String get week => "أسبوع";
  String get month => "شهر";
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

class AuthMessages_ar extends AuthMessages {
  final Messages_ar _parent;
  const AuthMessages_ar(this._parent) : super(_parent);
  String get register => "إنشاء حساب";
  String get sign_in => "تسجيل الدخول";
  String get sign_out => "تسجيل الخروج";
  String get dont_have_account => "ليس لديك حساب؟ ";
  String get already_have_account => "لديك حساب بالفعل؟ ";
  String get sign_out_confirmation => "هل تريد بالتأكيد تسجيل الخروج؟";
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

class ProfileMessages_ar extends ProfileMessages {
  final Messages_ar _parent;
  const ProfileMessages_ar(this._parent) : super(_parent);
  String get profile => "الملف الشخصي";
  String get settings => "الإعدادات";
  String get account => "الحساب";
  String get personal_info => "المعلومات الشخصية";
  String get privacy_settings => "إعدادات الخصوصية";
  String get name => "الاسم";
  String get email_address => "البريد الإلكتروني";
  String get phone_number => "رقم الهاتف";
  String get date_of_birth => "تاريخ الميلاد";
  String get delete_confirmation => "تأكيد الحذف";
  String get delete_confirmation_message =>
      "هل تريد بالتأكيد حذف هذا العنصر؟ لا يمكن التراجع عن هذا الإجراء.";
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

class NavMessages_ar extends NavMessages {
  final Messages_ar _parent;
  const NavMessages_ar(this._parent) : super(_parent);
  String get home => "الرئيسية";
  String get dashboard => "لوحة المعلومات";
  String get explore => "استكشاف";
  String get explore_placeholder =>
      "علامة التبويب الثانية. استبدلها بميزة حقيقية.";
  String get profile => "الملف الشخصي";
  String get settings => "الإعدادات";
  String get notifications => "الإشعارات";
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

class NotificationsMessages_ar extends NotificationsMessages {
  final Messages_ar _parent;
  const NotificationsMessages_ar(this._parent) : super(_parent);
  String get title => "الإشعارات";
  String get mark_as_read => "تعليم كمقروء";
  String get mark_all_read => "تعليم الكل كمقروء";
  String get delete => "حذف";
  String get filter_all => "الكل";
  String get filter_unread => "غير مقروءة";
  String get filter_read => "مقروءة";
  String get type_reminder => "تذكير";
  String get type_alert => "تنبيه";
  String get type_promotion => "عرض ترويجي";
  String get type_system => "النظام";
  String get type_custom => "مخصص";
  String get empty_title => "لا توجد إشعارات";
  String get empty_description => "لا جديد لديك! ستظهر الإشعارات الجديدة هنا.";
  String get delete_confirmation_title => "حذف الإشعار؟";
  String get delete_confirmation_message =>
      "ستتم إزالة هذا الإشعار من قائمتك نهائيًا.";
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

class ErrorsMessages_ar extends ErrorsMessages {
  final Messages_ar _parent;
  const ErrorsMessages_ar(this._parent) : super(_parent);
  String get network_error => "خطأ في الشبكة. يُرجى التحقق من اتصالك.";
  String get unknown_error => "حدث خطأ غير معروف.";
  String get validation_error => "يُرجى التحقق من المدخلات والمحاولة مرة أخرى.";
  String get server_error => "خطأ في الخادم. يُرجى المحاولة لاحقًا.";
  String get default_error_message =>
      "عذرًا! حدث خطأ ما. يُرجى المحاولة مرة أخرى.";
  String get user_not_found =>
      "المستخدم غير موجود. يُرجى التحقق من بيانات الدخول.";
  String get default_error_description =>
      "واجهنا خطأ أثناء معالجة طلبك. نعتذر عن الإزعاج. يُرجى المحاولة لاحقًا أو التواصل مع الدعم إذا استمرت المشكلة.";
  String get page_not_found => "الصفحة غير موجودة";
  String get page_not_found_description => "الصفحة التي تبحث عنها غير موجودة.";
  String get unexpected_error => "حدث خطأ غير متوقع.";
  String get redirect_error => "خطأ في إعادة التوجيه";
  String get bad_request => "طلب غير صالح. يُرجى التحقق من المدخلات.";
  String get unauthorized => "يلزم تسجيل الدخول. يُرجى تسجيل الدخول مرة أخرى.";
  String get forbidden => "تم رفض الوصول. ليست لديك صلاحية.";
  String get not_found => "المورد المطلوب غير موجود.";
  String get conflict => "تعارض في البيانات. يُرجى التحديث والمحاولة مرة أخرى.";
  String get unprocessable_entity =>
      "تنسيق البيانات غير صالح. يُرجى التحقق من المدخلات.";
  String get internal_server_error => "خطأ في الخادم. يُرجى المحاولة لاحقًا.";
  String get connection_timeout =>
      "انتهت مهلة الاتصال. يُرجى التحقق من الإنترنت.";
  String get receive_timeout => "انتهت مهلة الطلب. يُرجى المحاولة مرة أخرى.";
  String get send_timeout => "انتهت مهلة الرفع. يُرجى المحاولة مرة أخرى.";
  String get no_internet => "لا يوجد اتصال بالإنترنت. يُرجى التحقق من الشبكة.";
  String get unknown_network => "حدث خطأ في الشبكة. يُرجى المحاولة مرة أخرى.";
  String format_exception_message(String code, String postfix) =>
      "هذه البيانات بشكل غير مألوف، لا أستطيع التعرف عليها [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "هذه البيانات ليست كما توقعت، لا أستطيع معالجتها [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "لا أجد هذا العنصر في القائمة [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "عذرًا! هذا الرقم خارج النطاق المسموح [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "هناك خطأ في ما أعطيتني إياه [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "لست متأكدًا مما يجب فعله الآن [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "هذه الميزة ما زالت قيد الإنشاء [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "عذرًا، لا أعرف كيف أفعل ذلك بعد [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "أشياء كثيرة تحدث في الوقت نفسه [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "الذاكرة ممتلئة! أحتاج إلى بعض المساحة [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "علقت في حلقة لا تنتهي [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "حدث شيء غير متوقع، لكن لا تقلق [$code] $postfix";
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

class ValidationMessages_ar extends ValidationMessages {
  final Messages_ar _parent;
  const ValidationMessages_ar(this._parent) : super(_parent);
  String get required_field => "هذا الحقل مطلوب";
  String get invalid_email => "يُرجى إدخال بريد إلكتروني صالح";
  String get password_too_short => "يجب ألا تقل كلمة المرور عن 8 أحرف";
  String get passwords_dont_match => "كلمتا المرور غير متطابقتين";
  String invalid_key_config(String of, String key) =>
      "إعداد غير صالح لـ $key في $of. يُرجى التحقق من إعداداتك.";
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

class FilesMessages_ar extends FilesMessages {
  final Messages_ar _parent;
  const FilesMessages_ar(this._parent) : super(_parent);
  String get info_title => "معلومات الملف";
  String get name => "اسم الملف";
  String get type => "نوع الملف";
  String get extension => "امتداد الملف";
  String get size => "حجم الملف";
  String get path => "مسار الملف";
  String get copy_hint => "اضغط على أي حقل لنسخه إلى الحافظة";
  String copied(String field) => "تم نسخ $field إلى الحافظة";
  String image_type(String format) => "صورة $format";
  String get image_file => "ملف صورة";
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

class DeveloperMessages_ar extends DeveloperMessages {
  final Messages_ar _parent;
  const DeveloperMessages_ar(this._parent) : super(_parent);
  String get no_viewer => "لا يملك هذا السجل عارضًا تفاعليًا.";
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

class ClockMessages_ar extends ClockMessages {
  final Messages_ar _parent;
  const ClockMessages_ar(this._parent) : super(_parent);
  String get clock => "الساعة";
  String get stopwatch => "ساعة الإيقاف";
  String get modes => "الوضع";
  String get settings => "الإعدادات";
  String get times_up => "انتهى الوقت";
  String get timer_finished_title => "انتهى الوقت";
  String get timer_finished_body => "انتهى مؤقت QuietFlip.";
  String get alerts_channel => "تنبيهات المؤقت";
  String get show_controls => "اضغط أو حرّك الماوس لإظهار عناصر التحكم";
  String get theme => "المظهر";
  String get theme_light => "فاتح";
  String get use_24h => "نظام 24 ساعة";
  String get show_seconds => "إظهار الثواني";
  String get sound_tick_group => "التكتكة";
  String get sound_tick_hint => "تُسمع مع كل قلبة";
  String get sound_alarm_group => "المنبّه";
  String get sound_alarm_hint => "يتكرر حتى الإيقاف، 60 ث كحد أقصى";
  String get tick_sound => "صوت التكتكة";
  String get tick_sound_description => "صوت خافت في كل مرة تنقلب فيها بطاقة";
  String get alarm_sound => "صوت المنبّه";
  String get alarm_sound_description =>
      "يُسمع عند انتهاء مؤقت أو مرحلة بومودورو";
  String get tick_classic => "كلاسيكي";
  String get tick_classic_mood => "نقرة خافتة";
  String get tick_split_flap => "لوحة قلّابة";
  String get tick_split_flap_mood => "رفرفة الألواح";
  String get tick_clockwork => "آلية ساعة";
  String get tick_clockwork_mood => "تكتكة ساعة يد";
  String get tick_woodblock => "قطعة خشب";
  String get tick_woodblock_mood => "طرقة جوفاء";
  String get tick_digital => "رقمي";
  String get tick_digital_mood => "صفير نقي";
  String get alarm_chime => "رنين";
  String get alarm_chime_mood => "نغمتان";
  String get alarm_bell => "جرس";
  String get alarm_bell_mood => "جرس مطروق";
  String get alarm_beeps => "صفارات";
  String get alarm_beeps_mood => "منبّه السرير";
  String get alarm_rising => "متصاعد";
  String get alarm_rising_mood => "ماريمبا";
  String get alarm_ring => "رنّة";
  String get alarm_ring_mood => "جرسان";
  String get system_notifications => "إشعارات النظام";
  String get system_notifications_description =>
      "احصل على إشعار عند انتهاء المؤقت، حتى لو كان QuietFlip في الخلفية.";
  String get permission_denied =>
      "الإشعارات متوقفة لتطبيق QuietFlip. سترى التنبيه وتسمعه ما دام التطبيق مفتوحًا.";
  String get web_closed_tab_note =>
      "في المتصفح، تعمل التنبيهات فقط ما دامت علامة التبويب هذه مفتوحة.";
  String get keep_screen_awake => "إبقاء الشاشة قيد التشغيل";
  String get keep_screen_awake_description =>
      "منع الشاشة من السكون أثناء عرض الساعة.";
  String current_time(String time) => "الوقت الحالي $time";
  String time_remaining(String time) => "الوقت المتبقي $time";
  String elapsed(String time) => "الوقت المنقضي $time";
  String get digit_brightness => "سطوع الأرقام";
  String percent(String value) => "$value%";
  String get subtle_movement => "حركة خفيفة";
  String get subtle_movement_description =>
      "في وضع ملء الشاشة، تتحرك الساعة بضع وحدات بكسل كل دقيقة حتى لا تبقى البكسلات نفسها مضاءة طوال الليل. يقلل ذلك خطر احتراق الشاشة ولا يمنعه.";
  String get full_screen_note =>
      "يخفي وضع ملء الشاشة عناصر التحكم ما دام QuietFlip مفتوحًا. يجب أن يبقى التطبيق مفتوحًا، فهو ليس شاشة قفل ولا شاشة توقف.";
  String get show_date => "إظهار التاريخ";
  String current_time_and_date(String time, String date) =>
      "الوقت الحالي $time، $date";
  String get orientation => "الاتجاه";
  String get orientation_auto => "تلقائي";
  String get orientation_landscape => "أفقي";
  String get orientation_portrait => "عمودي";
  String get settings_card_size => "حجم البطاقة";
  String get card_size_small => "صغير";
  String get card_size_medium => "متوسط";
  String get card_size_large => "كبير";
  String get settings_corners => "الزوايا";
  String get corners_square => "حادة";
  String get corners_round => "مستديرة";
  String corners_value(String value) => "$value بكسل";
  String get pomodoro => "بومودورو";
  String pomodoro_focus(int round) => "تركيز · الجولة $round";
  String pomodoro_break(int round) => "استراحة · الجولة $round";
  String get pomodoro_focus_done => "انتهى التركيز. حان وقت الاستراحة.";
  String get pomodoro_break_done => "انتهت الاستراحة. عُد إلى التركيز.";
  String get start_focus => "بدء التركيز";
  String get start_break => "بدء الاستراحة";
  String get skins_title => "الأشكال";
  String get skins_customize => "تخصيص";
  String skins_customize_named(String name) => "تخصيص $name";
  String get skins_done => "تم";
  String get skins_in_use => "قيد الاستخدام";
  String get skins_yours => "أشكالك";
  String get skins_classic => "كلاسيكي";
  String get skins_bold => "عريض";
  String get skins_type => "خط";
  String get skins_new => "شكل جديد";
  String get skins_from_current => "من الحالي";
  String get customize_title => "تخصيص الشكل";
  String get customize_name => "الاسم";
  String customize_copy_name(String name) => "نسخة من $name";
  String get customize_font => "الخط";
  String get customize_digits => "الأرقام";
  String get customize_card => "البطاقة";
  String get customize_ground => "الخلفية";
  String get customize_custom_colour => "لون مخصص";
  String get customize_hex_hint => "رمز سداسي، مثل #FF7A00";
  String get customize_hex_invalid => "أدخل ستة أرقام سداسية، مثل #FF7A00.";
  String get customize_apply => "تطبيق";
  String get customize_low_contrast => "قد تصعب قراءة الأرقام.";
  String get customize_details => "التفاصيل";
  String get customize_seconds => "الثواني";
  String get customize_seconds_off => "إيقاف";
  String get customize_seconds_badge => "صغيرة";
  String get customize_seconds_cards => "بطاقات";
  String get customize_meridiem => "ص / م";
  String get customize_meridiem_hidden => "مخفي";
  String get customize_meridiem_left => "داخل";
  String get customize_meridiem_right => "بجانب";
  String get customize_save => "حفظ الشكل";
  String get customize_reset => "إعادة ضبط";
  String get customize_delete => "حذف الشكل";
  String get skin_mono => "أحادي";
  String get skin_paper => "ورق";
  String get skin_rose => "وردي";
  String get skin_violet => "بنفسجي";
  String get skin_amber => "كهرماني";
  String get skin_signal => "إشارة";
  String get skin_field => "حقل";
  String get skin_mint => "نعناع";
  String get skin_cyan => "سماوي";
  String get skin_taxi => "تاكسي";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "ملصق";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "سيريف";
  String get skin_orbit => "مدار";
  String get skin_nightstand => "طاولة السرير";
  String get skin_studio => "استوديو";
  String get skin_arcade => "أركيد";
  String get skin_railway => "سكة حديد";
  String get skin_desk => "مكتب";
  String get skin_neon => "نيون";
  String get skin_minimal => "بسيط";
  String get mode_pomodoro => "بومودورو";
  String get mode_clock => "الساعة";
  String get mode_stopwatch => "ساعة الإيقاف";
  String get action_start => "بدء";
  String get action_pause => "إيقاف مؤقت";
  String get action_resume => "استئناف";
  String get action_reset => "إعادة ضبط";
  String get action_restart => "إعادة البدء";
  String get action_done => "تم";
  String get action_skins => "الأشكال";
  String get action_settings => "الإعدادات";
  String get action_rotation => "تدوير الشاشة";
  String get action_timer_settings => "إعدادات المؤقت";
  String preset_minutes(int minutes) => "${minutes} د";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "بومودورو";
  String preset_spoken_minutes(int minutes) => "مؤقت $minutes دقيقة";
  String preset_spoken_seconds(int seconds) => "مؤقت $seconds ثانية";
  String preset_spoken_both(int minutes, int seconds) =>
      "مؤقت $minutes دقيقة و$seconds ثانية";
  String get action_lap => "لفة";
  String lap_label(int number, String time) => "لفة $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "المظهر";
  String get settings_clock => "الساعة";
  String get settings_gestures => "الإيماءات";
  String get settings_timers => "المؤقتات";
  String get settings_sound => "الصوت والتنبيهات";
  String get settings_awake => "إبقاء التشغيل";
  String get settings_shortcuts => "الاختصارات";
  String get settings_about => "حول";
  String get theme_dark => "داكن";
  String get theme_system => "حسب النظام";
  String get gesture_swipes => "السحب";
  String get gesture_brightness => "اسحب لأعلى أو لأسفل لضبط السطوع";
  String get gesture_modes => "اسحب جانبيًا لتغيير الوضع";
  String get gesture_footer =>
      "اسحب في أي مكان على الساعة. على Mac وWindows والويب، يخفّض السطوع إضاءة الأرقام بدلًا من الشاشة.";
  String get gesture_controls => "عناصر التحكم";
  String get gesture_tap => "اضغط لإظهار عناصر التحكم";
  String get gesture_idle => "إخفاء عناصر التحكم بعد";
  String gesture_idle_seconds(int seconds) => "${seconds} ث";
  String get gesture_idle_never => "أبدًا";
  String get gesture_controls_footer => "تتقلص عناصر التحكم إلى نقطة ثم تختفي.";
  String get timers_default => "المؤقت الافتراضي";
  String get timers_start_runs => "زر البدء يشغّل";
  String get timers_presets => "الإعدادات المسبقة";
  String get timers_add => "إضافة مؤقت";
  String get timers_limit_footer =>
      "تتسع الجزيرة لستة مؤقتات. احذف واحدًا لإضافة آخر.";
  String timers_delete(String timer) => "حذف $timer";
  String get timers_duplicate => "لديك هذا المؤقت بالفعل.";
  String get timers_picker_minutes => "الدقائق";
  String get timers_picker_seconds => "الثواني";
  String get skins_view_all => "عرض الكل";
  String get timers_pomodoro_focus => "تركيز";
  String get timers_pomodoro_break => "استراحة";
  String timers_minutes(int minutes) => "$minutes د";
  String get sound_footer =>
      "يُسمع التنبيه داخل التطبيق دائمًا، حتى مع إيقاف الإشعارات.";
  String get shortcuts_touch => "اللمس";
  String get shortcuts_keyboard => "لوحة المفاتيح";
  String get touch_controls => "إظهار عناصر التحكم أو إخفاؤها";
  String get shortcut_off => "إيقاف";
  String get key_start_pause => "بدء أو إيقاف مؤقت";
  String get key_change_mode => "تغيير الوضع";
  String get key_brightness => "السطوع";
  String get key_show_seconds => "إظهار الثواني";
  String get key_full_screen => "ملء الشاشة";
  String get key_hide_controls => "إخفاء عناصر التحكم";
  String get key_dim => "تخفيت الأرقام";
  String get key_lap => "لفة (ساعة الإيقاف)";
  String get key_rotation => "تدوير الشاشة";
  String get keycap_space => "Space";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "التراخيص";
  String get about_privacy => "الخصوصية";
  String get about_privacy_value =>
      "بلا إعلانات. الحساب اختياري. تساعدنا إحصاءات الاستخدام المجهولة على تحسين التطبيق.";
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

class SyncMessages_ar extends SyncMessages {
  final Messages_ar _parent;
  const SyncMessages_ar(this._parent) : super(_parent);
  String get account => "الحساب";
  String get card_title_signed_out => "تبقى إعداداتك على هذا الجهاز";
  String get card_body_signed_out =>
      "سجّل الدخول فقط إن أردتها على أجهزتك الأخرى.";
  String get card_title_on => "المزامنة مفعّلة";
  String get card_title_off => "المزامنة متوقفة";
  String card_last_synced(String when) => "آخر مزامنة $when";
  String get headline => "تبقى إعداداتك على هذا الجهاز";
  String get body =>
      "لا يحتاج QuietFlip إلى حساب أبدًا. سجّل الدخول فقط إن أردت ساعتك وأشكالك وأصواتك على أجهزتك الأخرى.";
  String get sign_in => "سجّل الدخول للمزامنة";
  String get sign_in_reason => "مطلوب فقط لمزامنة إعداداتك بين الأجهزة.";
  String get what_syncs => "ما تتم مزامنته";
  String get what_syncs_body =>
      "المظهر والأشكال والأصوات وإعدادات الساعة والمؤقت.";
  String get stays_body =>
      "يبقى على هذا الجهاز: السطوع والتدوير والإشعارات والمؤقت الجاري.";
  String get sync_header => "المزامنة";
  String get sync_settings => "مزامنة الإعدادات";
  String get sync_settings_note =>
      "تنتقل إعداداتك معك إلى كل جهاز تسجّل الدخول عليه.";
  String get last_synced => "آخر مزامنة";
  String get just_now => "الآن";
  String minutes_ago(int n) => "قبل $n د";
  String today_at(String time) => "اليوم الساعة $time";
  String get never => "ليس بعد";
  String get syncing => "جارٍ المزامنة…";
  String get waiting => "في انتظار الاتصال";
  String get off_note => "المزامنة متوقفة. تبقى التغييرات على هذا الجهاز.";
  String get failed_offline =>
      "تعذّرت المزامنة: لا يوجد اتصال. ستتم المحاولة مجددًا عند عودة الاتصال.";
  String get failed_denied => "تعذّرت المزامنة: سجّل الدخول مرة أخرى.";
  String get failed_unknown => "تعذّرت المزامنة. حاول مرة أخرى.";
  String get try_again => "حاول مرة أخرى";
  String get sign_out_note => "تسجيل الخروج يُبقي إعداداتك على هذا الجهاز.";
  String get delete_account => "حذف الحساب";
  String get delete_title => "حذف حسابك؟";
  String get delete_body =>
      "تُحذف إعداداتك المتزامنة من السحابة. تبقى الإعدادات على هذا الجهاز.";
  String get delete_recent_login => "سجّل الدخول مرة أخرى لحذف حسابك";
  String get delete_failed => "تعذّر حذف حسابك. حاول مرة أخرى.";
  String get provider_email => "البريد الإلكتروني";
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
