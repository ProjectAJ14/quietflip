// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;
import 'messages.i69n.dart';

String get _languageCode => 'hi';
String get _localeName => 'hi';

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

class Messages_hi extends Messages {
  const Messages_hi();
  AppMessages_hi get app => AppMessages_hi(this);
  GenericMessages_hi get generic => GenericMessages_hi(this);
  CommonMessages_hi get common => CommonMessages_hi(this);
  AuthMessages_hi get auth => AuthMessages_hi(this);
  ProfileMessages_hi get profile => ProfileMessages_hi(this);
  NavMessages_hi get nav => NavMessages_hi(this);
  NotificationsMessages_hi get notifications => NotificationsMessages_hi(this);
  ErrorsMessages_hi get errors => ErrorsMessages_hi(this);
  ValidationMessages_hi get validation => ValidationMessages_hi(this);
  FilesMessages_hi get files => FilesMessages_hi(this);
  DeveloperMessages_hi get developer => DeveloperMessages_hi(this);
  ClockMessages_hi get clock => ClockMessages_hi(this);
  SyncMessages_hi get sync => SyncMessages_hi(this);
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

class AppMessages_hi extends AppMessages {
  final Messages_hi _parent;
  const AppMessages_hi(this._parent) : super(_parent);
  String get name => "QuietFlip";
  String get description =>
      "विज्ञापन-मुक्त फ्लिप घड़ी, काउंटडाउन टाइमर और स्टॉपवॉच।";
  String get welcome_to_app => "QuietFlip में आपका स्वागत है!";
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

class GenericMessages_hi extends GenericMessages {
  final Messages_hi _parent;
  const GenericMessages_hi(this._parent) : super(_parent);
  String get ok => "ठीक है";
  String get cancel => "रद्द करें";
  String get save => "सहेजें";
  String get delete => "हटाएं";
  String get edit => "बदलें";
  String get update => "अपडेट करें";
  String get submit => "सबमिट करें";
  String get close => "बंद करें";
  String get back => "वापस";
  String get next => "आगे";
  String get previous => "पिछला";
  String get done => "हो गया";
  String get loading => "लोड हो रहा है...";
  String get error => "त्रुटि";
  String get success => "सफल";
  String get warning => "चेतावनी";
  String get info => "जानकारी";
  String get retry => "फिर कोशिश करें";
  String get refresh => "रीफ़्रेश करें";
  String get yes => "हाँ";
  String get no => "नहीं";
  String get add => "+ जोड़ें";
  String get try_again => "फिर कोशिश करें";
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

class CommonMessages_hi extends CommonMessages {
  final Messages_hi _parent;
  const CommonMessages_hi(this._parent) : super(_parent);
  String get week => "सप्ताह";
  String get month => "महीना";
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

class AuthMessages_hi extends AuthMessages {
  final Messages_hi _parent;
  const AuthMessages_hi(this._parent) : super(_parent);
  String get register => "रजिस्टर करें";
  String get sign_in => "साइन इन करें";
  String get sign_out => "साइन आउट करें";
  String get dont_have_account => "खाता नहीं है? ";
  String get already_have_account => "पहले से खाता है? ";
  String get sign_out_confirmation => "क्या आप सच में साइन आउट करना चाहते हैं?";
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

class ProfileMessages_hi extends ProfileMessages {
  final Messages_hi _parent;
  const ProfileMessages_hi(this._parent) : super(_parent);
  String get profile => "प्रोफ़ाइल";
  String get settings => "सेटिंग";
  String get account => "खाता";
  String get personal_info => "निजी जानकारी";
  String get privacy_settings => "निजता सेटिंग";
  String get name => "नाम";
  String get email_address => "ईमेल पता";
  String get phone_number => "फ़ोन नंबर";
  String get date_of_birth => "जन्मतिथि";
  String get delete_confirmation => "हटाने की पुष्टि";
  String get delete_confirmation_message =>
      "क्या आप सच में इसे हटाना चाहते हैं? इसे वापस नहीं किया जा सकता।";
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

class NavMessages_hi extends NavMessages {
  final Messages_hi _parent;
  const NavMessages_hi(this._parent) : super(_parent);
  String get home => "होम";
  String get dashboard => "डैशबोर्ड";
  String get explore => "एक्सप्लोर करें";
  String get explore_placeholder =>
      "आपका दूसरा टैब। इसे किसी असली फ़ीचर से बदलें।";
  String get profile => "प्रोफ़ाइल";
  String get settings => "सेटिंग";
  String get notifications => "सूचनाएं";
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

class NotificationsMessages_hi extends NotificationsMessages {
  final Messages_hi _parent;
  const NotificationsMessages_hi(this._parent) : super(_parent);
  String get title => "सूचनाएं";
  String get mark_as_read => "पढ़ा हुआ मार्क करें";
  String get mark_all_read => "सभी को पढ़ा हुआ मार्क करें";
  String get delete => "हटाएं";
  String get filter_all => "सभी";
  String get filter_unread => "अपठित";
  String get filter_read => "पढ़ी गई";
  String get type_reminder => "रिमाइंडर";
  String get type_alert => "अलर्ट";
  String get type_promotion => "प्रमोशन";
  String get type_system => "सिस्टम";
  String get type_custom => "कस्टम";
  String get empty_title => "कोई सूचना नहीं";
  String get empty_description => "सब देख लिया! नई सूचनाएं यहाँ दिखेंगी।";
  String get delete_confirmation_title => "सूचना हटाएं?";
  String get delete_confirmation_message =>
      "यह सूचना आपकी सूची से हमेशा के लिए हट जाएगी।";
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

class ErrorsMessages_hi extends ErrorsMessages {
  final Messages_hi _parent;
  const ErrorsMessages_hi(this._parent) : super(_parent);
  String get network_error => "नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।";
  String get unknown_error => "कोई अज्ञात त्रुटि हुई।";
  String get validation_error => "कृपया अपनी जानकारी जांचें और फिर कोशिश करें।";
  String get server_error => "सर्वर त्रुटि। कृपया बाद में फिर कोशिश करें।";
  String get default_error_message =>
      "उफ़! कुछ गड़बड़ हो गई। कृपया फिर कोशिश करें।";
  String get user_not_found =>
      "उपयोगकर्ता नहीं मिला। कृपया अपनी जानकारी जांचें।";
  String get default_error_description =>
      "आपका अनुरोध पूरा करते समय एक त्रुटि हुई। असुविधा के लिए खेद है। कृपया बाद में फिर कोशिश करें या समस्या बनी रहे तो सहायता से संपर्क करें।";
  String get page_not_found => "पेज नहीं मिला";
  String get page_not_found_description =>
      "आप जो पेज ढूंढ रहे हैं, वह मौजूद नहीं है।";
  String get unexpected_error => "एक अनपेक्षित त्रुटि हुई।";
  String get redirect_error => "रीडायरेक्ट त्रुटि";
  String get bad_request => "अमान्य अनुरोध। कृपया अपनी जानकारी जांचें।";
  String get unauthorized => "प्रमाणीकरण ज़रूरी है। कृपया फिर से साइन इन करें।";
  String get forbidden => "पहुंच अस्वीकृत। आपके पास अनुमति नहीं है।";
  String get not_found => "मांगी गई चीज़ नहीं मिली।";
  String get conflict => "डेटा में टकराव। कृपया रीफ़्रेश करके फिर कोशिश करें।";
  String get unprocessable_entity =>
      "डेटा का फ़ॉर्मेट अमान्य है। कृपया अपनी जानकारी जांचें।";
  String get internal_server_error =>
      "सर्वर त्रुटि। कृपया बाद में फिर कोशिश करें।";
  String get connection_timeout =>
      "कनेक्शन का समय खत्म। कृपया अपना इंटरनेट जांचें।";
  String get receive_timeout => "अनुरोध का समय खत्म। कृपया फिर कोशिश करें।";
  String get send_timeout => "अपलोड का समय खत्म। कृपया फिर कोशिश करें।";
  String get no_internet =>
      "इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें।";
  String get unknown_network => "नेटवर्क त्रुटि हुई। कृपया फिर कोशिश करें।";
  String format_exception_message(String code, String postfix) =>
      "यह डेटा गलत रूप में है, मैं इसे पहचान नहीं पा रहा [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "यह डेटा वैसा नहीं है जैसा मैंने सोचा था, मैं इसे प्रोसेस नहीं कर सकता [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "हम्म, सूची में वह आइटम नहीं मिल रहा [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "उफ़! यह संख्या सीमा से बहुत बाहर है [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "अरे! आपने जो दिया, उसमें कुछ ठीक नहीं है [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "मैं थोड़ा उलझन में हूं कि अभी क्या करना है [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "यह फ़ीचर अभी बन रहा है [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "माफ़ करें, मुझे अभी यह करना नहीं आता [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "अरे! एक साथ बहुत कुछ हो रहा है [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "मेरी मेमोरी भर गई! थोड़ी जगह खाली करनी होगी [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "मैं एक लूप में फंस गया हूं और चक्कर आ रहे हैं [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "कुछ अनपेक्षित हुआ, पर चिंता न करें [$code] $postfix";
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

class ValidationMessages_hi extends ValidationMessages {
  final Messages_hi _parent;
  const ValidationMessages_hi(this._parent) : super(_parent);
  String get required_field => "यह फ़ील्ड ज़रूरी है";
  String get invalid_email => "कृपया मान्य ईमेल पता डालें";
  String get password_too_short => "पासवर्ड कम से कम 8 अक्षरों का होना चाहिए";
  String get passwords_dont_match => "पासवर्ड मेल नहीं खाते";
  String invalid_key_config(String of, String key) =>
      "$of में $key का कॉन्फ़िगरेशन अमान्य है। कृपया अपनी सेटिंग जांचें।";
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

class FilesMessages_hi extends FilesMessages {
  final Messages_hi _parent;
  const FilesMessages_hi(this._parent) : super(_parent);
  String get info_title => "फ़ाइल की जानकारी";
  String get name => "फ़ाइल का नाम";
  String get type => "फ़ाइल का प्रकार";
  String get extension => "फ़ाइल एक्सटेंशन";
  String get size => "फ़ाइल का आकार";
  String get path => "फ़ाइल पाथ";
  String get copy_hint =>
      "क्लिपबोर्ड पर कॉपी करने के लिए किसी भी फ़ील्ड पर टैप करें";
  String copied(String field) => "$field क्लिपबोर्ड पर कॉपी हुआ";
  String image_type(String format) => "$format इमेज";
  String get image_file => "इमेज फ़ाइल";
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

class DeveloperMessages_hi extends DeveloperMessages {
  final Messages_hi _parent;
  const DeveloperMessages_hi(this._parent) : super(_parent);
  String get no_viewer => "इस लॉगर में इंटरैक्टिव व्यूअर नहीं है।";
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

class ClockMessages_hi extends ClockMessages {
  final Messages_hi _parent;
  const ClockMessages_hi(this._parent) : super(_parent);
  String get clock => "घड़ी";
  String get stopwatch => "स्टॉपवॉच";
  String get modes => "मोड";
  String get settings => "सेटिंग";
  String get times_up => "समय पूरा";
  String get timer_finished_title => "समय पूरा";
  String get timer_finished_body => "आपका QuietFlip टाइमर पूरा हो गया।";
  String get alerts_channel => "टाइमर अलर्ट";
  String get show_controls => "कंट्रोल दिखाने के लिए टैप करें या माउस हिलाएं";
  String get theme => "थीम";
  String get theme_light => "लाइट";
  String get use_24h => "24-घंटे का समय";
  String get show_seconds => "सेकंड दिखाएं";
  String get sound_tick_group => "टिक";
  String get sound_tick_hint => "हर फ्लिप पर बजती है";
  String get sound_alarm_group => "अलार्म";
  String get sound_alarm_hint => "बंद करने तक दोहराता है, अधिकतम 60 से.";
  String get tick_sound => "टिक की आवाज़";
  String get tick_sound_description => "हर कार्ड पलटने पर एक धीमी आवाज़";
  String get alarm_sound => "अलार्म की आवाज़";
  String get alarm_sound_description =>
      "टाइमर या पोमोडोरो चरण खत्म होने पर बजती है";
  String get tick_classic => "क्लासिक";
  String get tick_classic_mood => "धीमी क्लिक";
  String get tick_split_flap => "स्प्लिट-फ्लैप";
  String get tick_split_flap_mood => "फ्लैप की खटखट";
  String get tick_clockwork => "घड़ीसाज़ी";
  String get tick_clockwork_mood => "घड़ी की टिक";
  String get tick_woodblock => "लकड़ी का ब्लॉक";
  String get tick_woodblock_mood => "खोखली ठक";
  String get tick_digital => "डिजिटल";
  String get tick_digital_mood => "साफ़ ब्लिप";
  String get alarm_chime => "झंकार";
  String get alarm_chime_mood => "दो सुर";
  String get alarm_bell => "घंटी";
  String get alarm_bell_mood => "बजती घंटी";
  String get alarm_beeps => "बीप";
  String get alarm_beeps_mood => "बेडसाइड";
  String get alarm_rising => "बढ़ती";
  String get alarm_rising_mood => "मारिम्बा";
  String get alarm_ring => "रिंग";
  String get alarm_ring_mood => "दोहरी घंटी";
  String get system_notifications => "सिस्टम सूचनाएं";
  String get system_notifications_description =>
      "टाइमर पूरा होने पर सूचना पाएं, भले QuietFlip बैकग्राउंड में हो।";
  String get permission_denied =>
      "QuietFlip के लिए सूचनाएं बंद हैं। ऐप खुला रहने पर आप अलर्ट फिर भी देखेंगे और सुनेंगे।";
  String get web_closed_tab_note =>
      "ब्राउज़र में अलर्ट तभी काम करते हैं जब यह टैब खुला रहे।";
  String get keep_screen_awake => "स्क्रीन चालू रखें";
  String get keep_screen_awake_description =>
      "घड़ी दिखते समय स्क्रीन को स्लीप होने से रोकें।";
  String current_time(String time) => "मौजूदा समय $time";
  String time_remaining(String time) => "बचा समय $time";
  String elapsed(String time) => "बीता समय $time";
  String get digit_brightness => "अंकों की चमक";
  String percent(String value) => "$value%";
  String get subtle_movement => "हल्की हलचल";
  String get subtle_movement_description =>
      "फ़ुल स्क्रीन में घड़ी को हर मिनट कुछ पिक्सेल खिसकाएं, ताकि वही पिक्सेल पूरी रात न जलें। इससे बर्न-इन का जोखिम घटता है, पर पूरी तरह रुकता नहीं।";
  String get full_screen_note =>
      "फ़ुल स्क्रीन QuietFlip खुला रहने तक कंट्रोल छिपाता है। ऐप खुला रहना चाहिए। यह लॉक स्क्रीन या स्क्रीनसेवर नहीं है।";
  String get show_date => "तारीख दिखाएं";
  String current_time_and_date(String time, String date) =>
      "मौजूदा समय $time, $date";
  String get orientation => "दिशा";
  String get orientation_auto => "ऑटो";
  String get orientation_landscape => "लैंडस्केप";
  String get orientation_portrait => "पोर्ट्रेट";
  String get settings_card_size => "कार्ड का आकार";
  String get card_size_small => "छोटा";
  String get card_size_medium => "मध्यम";
  String get card_size_large => "बड़ा";
  String get settings_corners => "कोने";
  String get corners_square => "चौकोर";
  String get corners_round => "गोल";
  String corners_value(String value) => "$value px";
  String get pomodoro => "पोमोडोरो";
  String pomodoro_focus(int round) => "फ़ोकस · राउंड $round";
  String pomodoro_break(int round) => "ब्रेक · राउंड $round";
  String get pomodoro_focus_done => "फ़ोकस पूरा। अब ब्रेक लें।";
  String get pomodoro_break_done => "ब्रेक खत्म। फिर फ़ोकस करें।";
  String get start_focus => "फ़ोकस शुरू करें";
  String get start_break => "ब्रेक शुरू करें";
  String get skins_title => "स्किन";
  String get skins_customize => "कस्टमाइज़ करें";
  String skins_customize_named(String name) => "$name कस्टमाइज़ करें";
  String get skins_done => "हो गया";
  String get skins_in_use => "उपयोग में";
  String get skins_yours => "आपकी स्किन";
  String get skins_classic => "क्लासिक";
  String get skins_bold => "बोल्ड";
  String get skins_type => "टाइप";
  String get skins_new => "नई स्किन";
  String get skins_from_current => "मौजूदा से";
  String get customize_title => "स्किन कस्टमाइज़ करें";
  String get customize_name => "नाम";
  String customize_copy_name(String name) => "$name कॉपी";
  String get customize_font => "फ़ॉन्ट";
  String get customize_digits => "अंक";
  String get customize_card => "कार्ड";
  String get customize_ground => "बैकग्राउंड";
  String get customize_custom_colour => "कस्टम रंग";
  String get customize_hex_hint => "हेक्स, जैसे #FF7A00";
  String get customize_hex_invalid => "छह हेक्स अंक डालें, जैसे #FF7A00।";
  String get customize_apply => "लागू करें";
  String get customize_low_contrast => "अंक पढ़ने में मुश्किल हो सकते हैं।";
  String get customize_details => "विवरण";
  String get customize_seconds => "सेकंड";
  String get customize_seconds_off => "बंद";
  String get customize_seconds_badge => "छोटे";
  String get customize_seconds_cards => "कार्ड";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "छिपा";
  String get customize_meridiem_left => "अंदर";
  String get customize_meridiem_right => "बगल में";
  String get customize_save => "स्किन सहेजें";
  String get customize_reset => "रीसेट करें";
  String get customize_delete => "स्किन हटाएं";
  String get skin_mono => "मोनो";
  String get skin_paper => "कागज़";
  String get skin_rose => "गुलाब";
  String get skin_violet => "बैंगनी";
  String get skin_amber => "अंबर";
  String get skin_signal => "सिग्नल";
  String get skin_field => "मैदान";
  String get skin_mint => "पुदीना";
  String get skin_cyan => "सियान";
  String get skin_taxi => "टैक्सी";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "पोस्टर";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "सेरिफ़";
  String get skin_orbit => "कक्षा";
  String get skin_nightstand => "सिरहाना";
  String get skin_studio => "स्टूडियो";
  String get skin_arcade => "आर्केड";
  String get skin_railway => "रेलवे";
  String get skin_desk => "डेस्क";
  String get skin_neon => "नियॉन";
  String get skin_minimal => "सादा";
  String get mode_pomodoro => "पोमोडोरो";
  String get mode_clock => "घड़ी";
  String get mode_stopwatch => "स्टॉपवॉच";
  String get action_start => "शुरू करें";
  String get action_pause => "रोकें";
  String get action_resume => "जारी रखें";
  String get action_reset => "रीसेट करें";
  String get action_restart => "फिर शुरू करें";
  String get action_done => "हो गया";
  String get action_skins => "स्किन";
  String get action_settings => "सेटिंग";
  String get action_rotation => "स्क्रीन रोटेशन";
  String get action_timer_settings => "टाइमर सेटिंग";
  String preset_minutes(int minutes) => "${minutes} मि.";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "पोमोडोरो";
  String preset_spoken_minutes(int minutes) => "$minutes मिनट का टाइमर";
  String preset_spoken_seconds(int seconds) => "$seconds सेकंड का टाइमर";
  String preset_spoken_both(int minutes, int seconds) =>
      "$minutes मिनट $seconds सेकंड का टाइमर";
  String get action_lap => "लैप";
  String lap_label(int number, String time) => "लैप $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "रूप";
  String get settings_clock => "घड़ी";
  String get settings_gestures => "जेस्चर";
  String get settings_timers => "टाइमर";
  String get settings_sound => "आवाज़ और अलर्ट";
  String get settings_awake => "चालू रखें";
  String get settings_shortcuts => "शॉर्टकट";
  String get settings_about => "जानकारी";
  String get theme_dark => "डार्क";
  String get theme_system => "सिस्टम जैसा";
  String get gesture_swipes => "स्वाइप";
  String get gesture_brightness => "चमक के लिए ऊपर या नीचे स्वाइप करें";
  String get gesture_modes => "मोड बदलने के लिए बगल में स्वाइप करें";
  String get gesture_footer =>
      "घड़ी पर कहीं भी स्वाइप करें। Mac, Windows और वेब पर चमक स्क्रीन की जगह अंकों को धीमा करती है।";
  String get gesture_controls => "कंट्रोल";
  String get gesture_tap => "कंट्रोल दिखाने के लिए टैप करें";
  String get gesture_idle => "कंट्रोल छिपाएं इसके बाद";
  String gesture_idle_seconds(int seconds) => "${seconds} से.";
  String get gesture_idle_never => "कभी नहीं";
  String get gesture_controls_footer =>
      "कंट्रोल सिकुड़कर एक बिंदु बनते हैं, फिर गायब हो जाते हैं।";
  String get timers_default => "डिफ़ॉल्ट टाइमर";
  String get timers_start_runs => "शुरू पर चलेगा";
  String get timers_presets => "प्रीसेट";
  String get timers_add => "टाइमर जोड़ें";
  String get timers_limit_footer =>
      "आइलैंड में छह टाइमर आते हैं। नया जोड़ने के लिए एक हटाएं।";
  String timers_delete(String timer) => "$timer हटाएं";
  String get timers_duplicate => "यह टाइमर पहले से है।";
  String get timers_picker_minutes => "मिनट";
  String get timers_picker_seconds => "सेकंड";
  String get skins_view_all => "सभी देखें";
  String get timers_pomodoro_focus => "फ़ोकस";
  String get timers_pomodoro_break => "ब्रेक";
  String timers_minutes(int minutes) => "$minutes मि.";
  String get sound_footer =>
      "ऐप के अंदर का अलर्ट हमेशा बजता है, सूचनाएं बंद होने पर भी।";
  String get shortcuts_touch => "टच";
  String get shortcuts_keyboard => "कीबोर्ड";
  String get touch_controls => "कंट्रोल दिखाएं या छिपाएं";
  String get shortcut_off => "बंद";
  String get key_start_pause => "शुरू या रोकें";
  String get key_change_mode => "मोड बदलें";
  String get key_brightness => "चमक";
  String get key_show_seconds => "सेकंड दिखाएं";
  String get key_full_screen => "फ़ुल स्क्रीन";
  String get key_hide_controls => "कंट्रोल छिपाएं";
  String get key_dim => "अंक धीमे करें";
  String get key_lap => "लैप (स्टॉपवॉच)";
  String get key_rotation => "स्क्रीन रोटेशन";
  String get keycap_space => "Space";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get keycap_r => "R";
  String get about_licenses => "लाइसेंस";
  String get about_privacy => "निजता";
  String get about_privacy_value =>
      "कोई विज्ञापन नहीं। कोई ट्रैकिंग नहीं। खाता वैकल्पिक है।";
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

class SyncMessages_hi extends SyncMessages {
  final Messages_hi _parent;
  const SyncMessages_hi(this._parent) : super(_parent);
  String get account => "खाता";
  String get card_title_signed_out => "आपकी सेटिंग इसी डिवाइस पर रहती हैं";
  String get card_body_signed_out =>
      "साइन इन तभी करें जब आप इन्हें दूसरे डिवाइस पर चाहें।";
  String get card_title_on => "सिंक चालू है";
  String get card_title_off => "सिंक बंद है";
  String card_last_synced(String when) => "पिछला सिंक $when";
  String get headline => "आपकी सेटिंग इसी डिवाइस पर रहती हैं";
  String get body =>
      "QuietFlip को कभी खाते की ज़रूरत नहीं। साइन इन तभी करें जब आप अपनी घड़ी, स्किन और आवाज़ें दूसरे डिवाइस पर चाहें।";
  String get sign_in => "सिंक के लिए साइन इन करें";
  String get sign_in_reason =>
      "सिर्फ़ डिवाइसों के बीच सेटिंग सिंक करने के लिए।";
  String get what_syncs => "क्या सिंक होता है";
  String get what_syncs_body => "थीम, स्किन, आवाज़ें, घड़ी और टाइमर सेटिंग।";
  String get stays_body =>
      "इसी डिवाइस पर रहता है: चमक, रोटेशन, सूचनाएं और चलता टाइमर।";
  String get sync_header => "सिंक";
  String get sync_settings => "सेटिंग सिंक करें";
  String get sync_settings_note =>
      "आप जिस भी डिवाइस पर साइन इन करें, आपकी सेटिंग वहाँ साथ रहती हैं।";
  String get last_synced => "पिछला सिंक";
  String get just_now => "अभी-अभी";
  String minutes_ago(int n) => "$n मि. पहले";
  String today_at(String time) => "आज $time पर";
  String get never => "अभी नहीं";
  String get syncing => "सिंक हो रहा है…";
  String get waiting => "कनेक्शन का इंतज़ार";
  String get off_note => "सिंक बंद है। बदलाव इसी डिवाइस पर रहते हैं।";
  String get failed_offline =>
      "सिंक नहीं हुआ: कनेक्शन नहीं है। ऑनलाइन होने पर फिर कोशिश होगी।";
  String get failed_denied => "सिंक नहीं हुआ: फिर से साइन इन करें।";
  String get failed_unknown => "सिंक नहीं हुआ। फिर कोशिश करें।";
  String get try_again => "फिर कोशिश करें";
  String get sign_out_note =>
      "साइन आउट करने पर आपकी सेटिंग इसी डिवाइस पर रहती हैं।";
  String get delete_account => "खाता हटाएं";
  String get delete_title => "अपना खाता हटाएं?";
  String get delete_body =>
      "आपकी सिंक की गई सेटिंग क्लाउड से हट जाएंगी। इस डिवाइस की सेटिंग बनी रहेंगी।";
  String get delete_recent_login => "खाता हटाने के लिए फिर से साइन इन करें";
  String get delete_failed => "खाता हटाया नहीं जा सका। फिर कोशिश करें।";
  String get provider_email => "ईमेल";
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
