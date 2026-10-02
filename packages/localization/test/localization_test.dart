import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

void main() {
  tearDown(() => LocalizationProvider.select(const []));

  group('getBestMatchingLocale', () {
    test('picks the first supported language in preference order', () {
      expect(
        LocalizationProvider.getBestMatchingLocale(const [
          Locale('sv'),
          Locale('de', 'AT'),
          Locale('fr'),
        ]),
        'de',
      );
    });

    test('falls back from a region to its language', () {
      expect(
        LocalizationProvider.getBestMatchingLocale(const [Locale('pt', 'BR')]),
        'pt',
      );
      expect(
        LocalizationProvider.getBestMatchingLocale(const [Locale('pt', 'PT')]),
        'pt',
      );
    });

    test('defaults to English for unsupported or no languages', () {
      expect(
        LocalizationProvider.getBestMatchingLocale(const [Locale('ar')]),
        'en',
      );
      expect(LocalizationProvider.getBestMatchingLocale(const []), 'en');
    });

    test('skips Traditional Chinese, which does not ship', () {
      for (final locale in const [
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'CN',
        ),
        Locale('zh', 'TW'),
        Locale('zh', 'HK'),
        Locale('zh', 'MO'),
      ]) {
        expect(
          LocalizationProvider.getBestMatchingLocale([locale, const Locale('ja')]),
          'ja',
          reason: '$locale',
        );
      }
    });

    test('matches Simplified Chinese', () {
      for (final locale in const [
        Locale('zh'),
        Locale('zh', 'CN'),
        Locale('zh', 'SG'),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
          countryCode: 'HK',
        ),
      ]) {
        expect(
          LocalizationProvider.getBestMatchingLocale([locale]),
          'zh',
          reason: '$locale',
        );
      }
    });
  });

  group('select', () {
    test('makes the match current for strings and intl', () {
      expect(LocalizationProvider.select(const [Locale('ja', 'JP')]), 'ja');
      expect(LocalizationProvider.currentLocale, 'ja');
      expect(Intl.defaultLocale, 'ja');
      expect(strings, isA<Messages_ja>());
      expect(strings.generic.cancel, isNot(const Messages().generic.cancel));
    });

    test('falls back to English messages', () {
      LocalizationProvider.select(const [Locale('de')]);
      expect(LocalizationProvider.select(const [Locale('ar')]), 'en');
      expect(LocalizationProvider.currentLocale, 'en');
      expect(Intl.defaultLocale, 'en');
      expect(strings.generic.cancel, 'Cancel');
    });
  });

  test('English is current before any selection', () {
    expect(LocalizationProvider.currentLocale, 'en');
    expect(LocalizationProvider.messages, isA<Messages>());
  });

  test('lists every phase-1 language, English first', () {
    const codes = [
      'en', 'es', 'pt', 'fr', 'de', 'it', 'ja', 'ko', 'zh', 'hi', 'id', //
      'tr', 'ru',
    ];
    expect(LocalizationProvider.supportedLocales, codes);
    expect(LocalizationProvider.locales, [for (final c in codes) Locale(c)]);
    expect(
      () => LocalizationProvider.supportedLocales.add('xx'),
      throwsUnsupportedError,
    );
  });

  test('isLocaleSupported checks language codes', () {
    expect(LocalizationProvider.isLocaleSupported('en'), isTrue);
    expect(LocalizationProvider.isLocaleSupported('ru'), isTrue);
    expect(LocalizationProvider.isLocaleSupported('ar'), isFalse);
    expect(LocalizationProvider.isLocaleSupported('pt_BR'), isFalse);
  });

  test('every language speaks its own copy', () {
    for (final code in LocalizationProvider.supportedLocales.skip(1)) {
      LocalizationProvider.select([Locale(code)]);
      expect(
        strings.generic.cancel,
        isNot('Cancel'),
        reason: '$code falls back to English',
      );
    }
  });
}
