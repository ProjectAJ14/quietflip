import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:localization/messages.i69n.dart';
import 'package:localization/messages_de.i69n.dart';
import 'package:localization/messages_es.i69n.dart';
import 'package:localization/messages_fr.i69n.dart';
import 'package:localization/messages_hi.i69n.dart';
import 'package:localization/messages_id.i69n.dart';
import 'package:localization/messages_it.i69n.dart';
import 'package:localization/messages_ja.i69n.dart';
import 'package:localization/messages_ko.i69n.dart';
import 'package:localization/messages_pt.i69n.dart';
import 'package:localization/messages_ru.i69n.dart';
import 'package:localization/messages_tr.i69n.dart';
import 'package:localization/messages_zh.i69n.dart';

/// Picks the language Quietflip speaks and hands out its messages.
///
/// The app calls [select] with the device's preferred languages at launch
/// and again whenever they change; everything else reads [messages]
/// (through `strings`) and [currentLocale]. English is the fallback.
///
/// To add a locale, add `messages_<code>.i69n.yaml`, list the code under
/// `locales` and the file under `generate_for` in `build.yaml`, regenerate,
/// and add its generated class to [_messages].
class LocalizationProvider {
  /// Generated messages per language code; the first entry is the fallback.
  /// `pt` is Brazilian Portuguese and `zh` Simplified Chinese.
  static const Map<String, Messages> _messages = {
    'en': Messages(),
    'es': Messages_es(),
    'pt': Messages_pt(),
    'fr': Messages_fr(),
    'de': Messages_de(),
    'it': Messages_it(),
    'ja': Messages_ja(),
    'ko': Messages_ko(),
    'zh': Messages_zh(),
    'hi': Messages_hi(),
    'id': Messages_id(),
    'tr': Messages_tr(),
    'ru': Messages_ru(),
  };

  static const String _fallback = 'en';

  /// Regions whose Chinese is written in Traditional characters when the
  /// locale names no script.
  static const Set<String> _traditionalRegions = {'TW', 'HK', 'MO'};

  static String _current = _fallback;

  /// The messages for [currentLocale].
  static Messages get messages => _messages[_current]!;

  /// The selected language code, `'en'` until [select] picks another.
  static String get currentLocale => _current;

  /// Language codes with generated messages, English first.
  static List<String> get supportedLocales => List.unmodifiable(_messages.keys);

  /// [supportedLocales] as `Locale`s, for `MaterialApp.supportedLocales`.
  static List<Locale> get locales => [
    for (final code in _messages.keys) Locale(code),
  ];

  /// Whether [locale] (a language code) has generated messages.
  static bool isLocaleSupported(String locale) =>
      _messages.containsKey(locale);

  /// The first of [preferredLocales] Quietflip speaks, matched by language
  /// (`pt_BR` and `pt_PT` -> `pt`), else `'en'`. Traditional Chinese
  /// (`zh_Hant`, or `zh` in Taiwan, Hong Kong or Macau) is skipped: only
  /// Simplified ships.
  static String getBestMatchingLocale(List<Locale> preferredLocales) {
    for (final locale in preferredLocales) {
      if (_isTraditionalChinese(locale)) continue;
      if (isLocaleSupported(locale.languageCode)) return locale.languageCode;
    }
    return _fallback;
  }

  /// Makes the best match for [preferredLocales] current, for `strings` and
  /// for `intl` formatting without an explicit locale; returns it.
  static String select(List<Locale> preferredLocales) {
    _current = getBestMatchingLocale(preferredLocales);
    Intl.defaultLocale = _current;
    return _current;
  }

  static bool _isTraditionalChinese(Locale locale) =>
      locale.languageCode == 'zh' &&
      (locale.scriptCode == 'Hant' ||
          (locale.scriptCode == null &&
              _traditionalRegions.contains(locale.countryCode)));
}
