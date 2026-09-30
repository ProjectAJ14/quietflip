// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
// dart format off
import 'package:i69n/i69n.dart' as i69n;

String get _languageCode => 'en';
String get _localeName => 'en';

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

class Messages implements i69n.I69nMessageBundle {
  const Messages();
  AppMessages get app => AppMessages(this);
  GenericMessages get generic => GenericMessages(this);
  CommonMessages get common => CommonMessages(this);
  AuthMessages get auth => AuthMessages(this);
  ProfileMessages get profile => ProfileMessages(this);
  NavMessages get nav => NavMessages(this);
  NotificationsMessages get notifications => NotificationsMessages(this);
  ErrorsMessages get errors => ErrorsMessages(this);
  ValidationMessages get validation => ValidationMessages(this);
  DeveloperMessages get developer => DeveloperMessages(this);
  ClockMessages get clock => ClockMessages(this);
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
      case 'developer':
        return developer;
      case 'clock':
        return clock;
      default:
        return key;
    }
  }
}

class AppMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const AppMessages(this._parent);
  String get name => "QuietFlip";
  String get description =>
      "An ad-free flip clock, countdown timer, and stopwatch.";
  String get welcome_to_app => "Welcome to Quietflip!";
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
        return key;
    }
  }
}

class GenericMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const GenericMessages(this._parent);
  String get ok => "OK";
  String get cancel => "Cancel";
  String get save => "Save";
  String get delete => "Delete";
  String get edit => "Edit";
  String get update => "Update";
  String get submit => "Submit";
  String get close => "Close";
  String get back => "Back";
  String get next => "Next";
  String get previous => "Previous";
  String get done => "Done";
  String get loading => "Loading...";
  String get error => "Error";
  String get success => "Success";
  String get warning => "Warning";
  String get info => "Info";
  String get retry => "Retry";
  String get refresh => "Refresh";
  String get yes => "Yes";
  String get no => "No";
  String get add => "+ Add";
  String get try_again => "Try Again";
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
        return key;
    }
  }
}

class CommonMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const CommonMessages(this._parent);
  String get week => "Week";
  String get month => "Month";
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
        return key;
    }
  }
}

class AuthMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const AuthMessages(this._parent);
  String get register => "Register";
  String get sign_in => "Sign In";
  String get sign_out => "Sign Out";
  String get dont_have_account => "Don't have an account? ";
  String get already_have_account => "Already have an account? ";
  String get sign_out_confirmation => "Are you sure you want to sign out?";
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
        return key;
    }
  }
}

class ProfileMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ProfileMessages(this._parent);
  String get profile => "Profile";
  String get settings => "Settings";
  String get account => "Account";
  String get personal_info => "Personal Information";
  String get privacy_settings => "Privacy Settings";
  String get name => "Name";
  String get email_address => "Email Address";
  String get phone_number => "Phone Number";
  String get date_of_birth => "Date of Birth";
  String get delete_confirmation => "Delete Confirmation";
  String get delete_confirmation_message =>
      "Are you sure you want to delete this item? This action cannot be undone.";
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
        return key;
    }
  }
}

class NavMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const NavMessages(this._parent);
  String get home => "Home";
  String get dashboard => "Dashboard";
  String get explore => "Explore";
  String get explore_placeholder =>
      "Your second tab. Replace this with a real feature.";
  String get profile => "Profile";
  String get settings => "Settings";
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
        return key;
    }
  }
}

class NotificationsMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const NotificationsMessages(this._parent);
  String get title => "Notifications";
  String get mark_as_read => "Mark as read";
  String get mark_all_read => "Mark all as read";
  String get delete => "Delete";
  String get filter_all => "All";
  String get filter_unread => "Unread";
  String get filter_read => "Read";
  String get type_reminder => "Reminder";
  String get type_alert => "Alert";
  String get type_promotion => "Promotion";
  String get type_system => "System";
  String get type_custom => "Custom";
  String get empty_title => "No notifications";
  String get empty_description =>
      "You're all caught up! New notifications will appear here.";
  String get delete_confirmation_title => "Delete notification?";
  String get delete_confirmation_message =>
      "This notification will be permanently removed from your list.";
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
        return key;
    }
  }
}

class ErrorsMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ErrorsMessages(this._parent);
  String get network_error => "Network error. Please check your connection.";
  String get unknown_error => "An unknown error occurred.";
  String get validation_error => "Please check your input and try again.";
  String get server_error => "Server error. Please try again later.";
  String get default_error_message =>
      "Oops! Something went wrong. Please try again.";
  String get user_not_found => "User not found. Please check your credentials.";
  String get default_error_description =>
      "We encountered an error while processing your request. We apologize for the inconvenience. Please try again later or contact support if the issue persists.";
  String get page_not_found => "Page Not Found";
  String get page_not_found_description =>
      "The page you are looking for does not exist.";
  String get unexpected_error => "An unexpected error occurred.";
  String get redirect_error => "Redirect Error";
  String get bad_request => "Invalid request. Please check your input.";
  String get unauthorized => "Authentication required. Please sign in again.";
  String get forbidden => "Access denied. You don't have permission.";
  String get not_found => "Requested resource not found.";
  String get conflict => "Data conflict. Please refresh and try again.";
  String get unprocessable_entity =>
      "Invalid data format. Please check your input.";
  String get internal_server_error => "Server error. Please try again later.";
  String get connection_timeout =>
      "Connection timeout. Please check your internet.";
  String get receive_timeout => "Request timeout. Please try again.";
  String get send_timeout => "Upload timeout. Please try again.";
  String get no_internet =>
      "No internet connection. Please check your network.";
  String get unknown_network => "Network error occurred. Please try again.";
  String format_exception_message(String code, String postfix) =>
      "This data is wearing the wrong costume, I don't recognize it [$code] $postfix";
  String type_error_message(String code, String postfix) =>
      "This data is not what I expected, I can't process it [$code] $postfix";
  String index_error_message(String code, String postfix) =>
      "Hmm, I can't seem to find that item in the list [$code] $postfix";
  String range_error_message(String code, String postfix) =>
      "Oops! That number is way out of my comfort zone [$code] $postfix";
  String argument_error_message(String code, String postfix) =>
      "Hey! Something's not right with what you gave me [$code] $postfix";
  String state_error_message(String code, String postfix) =>
      "I'm a bit confused about what I should be doing right now [$code] $postfix";
  String unimplemented_error_message(String code, String postfix) =>
      "This feature is still under construction [$code] $postfix";
  String unsupported_error_message(String code, String postfix) =>
      "Sorry, I don't know how to do that yet [$code] $postfix";
  String concurrent_modification_error_message(String code, String postfix) =>
      "Whoa! Too many things happening at once [$code] $postfix";
  String out_of_memory_error_message(String code, String postfix) =>
      "My brain is full! Need to clear some space [$code] $postfix";
  String stack_overflow_error_message(String code, String postfix) =>
      "I'm stuck in a loop and getting dizzy [$code] $postfix";
  String unknown_error_message(String code, String postfix) =>
      "Something unexpected happened, but don't worry [$code] $postfix";
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
        return key;
    }
  }
}

class ValidationMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ValidationMessages(this._parent);
  String get required_field => "This field is required";
  String get invalid_email => "Please enter a valid email address";
  String get password_too_short => "Password must be at least 8 characters";
  String get passwords_dont_match => "Passwords do not match";
  String invalid_key_config(String of, String key) =>
      "Invalid configuration for $key in $of. Please check your settings.";
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
        return key;
    }
  }
}

class DeveloperMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const DeveloperMessages(this._parent);
  String get no_viewer => "This logger has no interactive viewer.";
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
        return key;
    }
  }
}

class ClockMessages implements i69n.I69nMessageBundle {
  final Messages _parent;
  const ClockMessages(this._parent);
  String get clock => "Clock";
  String get stopwatch => "Stopwatch";
  String get modes => "Mode";
  String get settings => "Settings";
  String get times_up => "Time's up";
  String get timer_finished_title => "Time's up";
  String get timer_finished_body => "Your QuietFlip timer has finished.";
  String get alerts_channel => "Timer alerts";
  String get show_controls => "Tap or move the mouse to show controls";
  String get theme => "Theme";
  String get theme_light => "Light";
  String get use_24h => "24-hour time";
  String get show_seconds => "Show seconds";
  String get sound_and_alerts => "Sound & alerts";
  String get flip_sound => "Flip sound";
  String get alert_sound => "Alert sound";
  String get system_notifications => "System notifications";
  String get system_notifications_description =>
      "Get a notification when a timer finishes, even if QuietFlip is in the background.";
  String get permission_denied =>
      "Notifications are turned off for QuietFlip. You will still see and hear the alert while the app is open.";
  String get web_closed_tab_note =>
      "In a browser, alerts only work while this tab stays open.";
  String get keep_screen_awake => "Keep screen awake";
  String get keep_screen_awake_description =>
      "Stop the screen from sleeping while the clock is showing.";
  String current_time(String time) => "Current time $time";
  String time_remaining(String time) => "Time remaining $time";
  String elapsed(String time) => "Elapsed time $time";
  String get digit_brightness => "Digit brightness";
  String percent(String value) => "$value%";
  String get subtle_movement => "Subtle movement";
  String get subtle_movement_description =>
      "In full screen, move the clock a few pixels each minute so the same pixels are not lit all night. Lowers, but does not prevent, burn-in risk.";
  String get full_screen_note =>
      "Full screen hides the controls while QuietFlip stays open. The app must stay open. It is not a lock screen or screensaver.";
  String get show_date => "Show date";
  String current_time_and_date(String time, String date) =>
      "Current time $time, $date";
  String get orientation => "Orientation";
  String get orientation_auto => "Auto";
  String get orientation_landscape => "Landscape";
  String get orientation_portrait => "Portrait";
  String get settings_card_size => "Card size";
  String get card_size_small => "Small";
  String get card_size_medium => "Medium";
  String get card_size_large => "Large";
  String get pomodoro => "Pomodoro";
  String pomodoro_focus(int round) => "Focus · Round $round";
  String pomodoro_break(int round) => "Break · Round $round";
  String get pomodoro_focus_done => "Focus done. Time for a break.";
  String get pomodoro_break_done => "Break over. Back to focus.";
  String get start_focus => "Start focus";
  String get start_break => "Start break";
  String get skins_title => "Skins";
  String get skins_customize => "Customize";
  String get skins_done => "Done";
  String get skins_yours => "Your skins";
  String get skins_classic => "Classic";
  String get skins_bold => "Bold";
  String get skins_type => "Type";
  String get skins_new => "New skin";
  String get skins_from_current => "From current";
  String get customize_title => "Customize skin";
  String get customize_name => "Name";
  String customize_copy_name(String name) => "$name copy";
  String get customize_font => "Font";
  String get customize_digits => "Digits";
  String get customize_card => "Card";
  String get customize_ground => "Background";
  String get customize_custom_colour => "Custom colour";
  String get customize_hex_hint => "Hex, for example #FF7A00";
  String get customize_hex_invalid => "Enter six hex digits, like #FF7A00.";
  String get customize_apply => "Apply";
  String get customize_low_contrast => "Digits may be hard to read.";
  String get customize_shape => "Shape";
  String get customize_radius => "Corner radius";
  String get customize_seam => "Split line";
  String get customize_details => "Details";
  String get customize_seconds => "Seconds";
  String get customize_seconds_off => "Off";
  String get customize_seconds_badge => "Small";
  String get customize_seconds_cards => "Cards";
  String get customize_meridiem => "AM / PM";
  String get customize_meridiem_hidden => "Hidden";
  String get customize_meridiem_left => "Inside";
  String get customize_meridiem_right => "Beside";
  String get customize_save => "Save skin";
  String get customize_reset => "Reset";
  String get customize_delete => "Delete skin";
  String get skin_mono => "Mono";
  String get skin_paper => "Paper";
  String get skin_rose => "Rose";
  String get skin_violet => "Violet";
  String get skin_amber => "Amber";
  String get skin_signal => "Signal";
  String get skin_field => "Field";
  String get skin_mint => "Mint";
  String get skin_cyan => "Cyan";
  String get skin_taxi => "Taxi";
  String get skin_bebas => "Bebas";
  String get skin_anton => "Anton";
  String get skin_oswald => "Oswald";
  String get skin_shoulders => "Shoulders";
  String get skin_poster => "Poster";
  String get skin_terminal => "Terminal";
  String get skin_grotesk => "Grotesk";
  String get skin_serif => "Serif";
  String get skin_orbit => "Orbit";
  String get skin_nightstand => "Nightstand";
  String get skin_studio => "Studio";
  String get skin_arcade => "Arcade";
  String get skin_railway => "Railway";
  String get skin_desk => "Desk";
  String get skin_neon => "Neon";
  String get skin_minimal => "Minimal";
  String get mode_pomodoro => "Pomodoro";
  String get mode_clock => "Clock";
  String get mode_stopwatch => "Stopwatch";
  String get action_start => "Start";
  String get action_pause => "Pause";
  String get action_resume => "Resume";
  String get action_reset => "Reset";
  String get action_restart => "Restart";
  String get action_done => "Done";
  String get action_skins => "Skins";
  String get action_settings => "Settings";
  String get action_timer_settings => "Timer settings";
  String preset_minutes(int minutes) => "${minutes}m";
  String preset_minutes_seconds(int minutes, String seconds) =>
      "$minutes:$seconds";
  String get preset_pomodoro => "Pomodoro";
  String get action_lap => "Lap";
  String lap_label(int number, String time) => "Lap $number  $time";
  String brightness_value(String percent) => "$percent%";
  String get settings_appearance => "Appearance";
  String get settings_clock => "Clock";
  String get settings_gestures => "Gestures";
  String get settings_timers => "Timers";
  String get settings_sound => "Sound & alerts";
  String get settings_awake => "Keep awake";
  String get settings_shortcuts => "Shortcuts";
  String get settings_about => "About";
  String get settings_skin => "Skin";
  String get theme_dark => "Dark";
  String get theme_system => "Match system";
  String get gesture_swipes => "Swipes";
  String get gesture_brightness => "Swipe up or down for brightness";
  String get gesture_modes => "Swipe sideways to change mode";
  String get gesture_footer =>
      "Swipe anywhere on the clock. On Mac, Windows and the web, brightness dims the digits instead of the screen.";
  String get gesture_controls => "Controls";
  String get gesture_tap => "Tap to show controls";
  String get gesture_idle => "Hide controls after";
  String gesture_idle_seconds(int seconds) => "${seconds}s";
  String get gesture_idle_never => "Never";
  String get gesture_controls_footer =>
      "Controls shrink to a dot, then disappear.";
  String get timers_pomodoro_focus => "Focus";
  String get timers_pomodoro_break => "Break";
  String timers_minutes(int minutes) => "$minutes min";
  String get sound_footer =>
      "The in-app alert always plays, even with notifications off.";
  String get key_start_pause => "Start or pause";
  String get key_change_mode => "Change mode";
  String get key_brightness => "Brightness";
  String get key_show_seconds => "Show seconds";
  String get key_full_screen => "Full screen";
  String get key_hide_controls => "Hide controls";
  String get key_dim => "Dim the digits";
  String get key_lap => "Lap (stopwatch)";
  String get keycap_space => "Space";
  String get keycap_left_right => "← →";
  String get keycap_up_down => "↑ ↓";
  String get keycap_s => "S";
  String get keycap_f => "F";
  String get keycap_esc => "Esc";
  String get keycap_d => "D";
  String get keycap_l => "L";
  String get about_licenses => "Licenses";
  String get about_privacy => "Privacy";
  String get about_privacy_value => "No ads. No tracking.";
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
      case 'sound_and_alerts':
        return sound_and_alerts;
      case 'flip_sound':
        return flip_sound;
      case 'alert_sound':
        return alert_sound;
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
      case 'skins_done':
        return skins_done;
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
      case 'customize_shape':
        return customize_shape;
      case 'customize_radius':
        return customize_radius;
      case 'customize_seam':
        return customize_seam;
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
      case 'action_timer_settings':
        return action_timer_settings;
      case 'preset_minutes':
        return preset_minutes;
      case 'preset_minutes_seconds':
        return preset_minutes_seconds;
      case 'preset_pomodoro':
        return preset_pomodoro;
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
      case 'settings_skin':
        return settings_skin;
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
      case 'timers_pomodoro_focus':
        return timers_pomodoro_focus;
      case 'timers_pomodoro_break':
        return timers_pomodoro_break;
      case 'timers_minutes':
        return timers_minutes;
      case 'sound_footer':
        return sound_footer;
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
      case 'about_licenses':
        return about_licenses;
      case 'about_privacy':
        return about_privacy;
      case 'about_privacy_value':
        return about_privacy_value;
      default:
        return key;
    }
  }
}
