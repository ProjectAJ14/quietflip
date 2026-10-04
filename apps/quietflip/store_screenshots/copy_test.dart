import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

import 'render.dart';
import 'targets.dart';

void main() {
  test('every app language has copy, a locale test and store codes', () {
    final languages = LocalizationProvider.supportedLocales;
    final files = Directory('store_screenshots/copy')
        .listSync()
        .map((f) => f.uri.pathSegments.last.replaceAll('.yaml', ''))
        .toSet();
    expect(files, languages.toSet());
    expect(storeLocales.keys.toSet(), languages.toSet());
    for (final language in languages) {
      expect(
        File('store_screenshots/locales/${language}_test.dart').existsSync(),
        isTrue,
        reason: 'store_screenshots/locales/${language}_test.dart',
      );
    }
  });

  test('every copy file has exactly the English keys, none empty', () {
    final english = readCopy('en');
    expect(english.keys, containsAll([...cards, featureKey]));
    for (final language in LocalizationProvider.supportedLocales) {
      final copy = readCopy(language);
      expect(copy.keys.toSet(), english.keys.toSet(), reason: language);
      for (final MapEntry(:key, :value) in copy.entries) {
        expect(value.trim(), isNotEmpty, reason: '$language $key');
      }
    }
  });
}
