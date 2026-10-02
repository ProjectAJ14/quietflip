import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

// The App Store lists the languages a bundle declares. Each language the app
// ships must be declared, in Apple's code for it.
void main() {
  const apple = {'pt': 'pt-BR', 'zh': 'zh-Hans'};

  for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
    test('$path declares every shipped language', () {
      final plist = File(path).readAsStringSync();
      final array = RegExp(
        r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
        dotAll: true,
      ).firstMatch(plist);
      expect(array, isNotNull);
      final declared = RegExp(
        '<string>([^<]+)</string>',
      ).allMatches(array![1]!).map((m) => m[1]).toList();
      expect(declared, [
        for (final code in LocalizationProvider.supportedLocales)
          apple[code] ?? code,
      ]);
    });
  }
}
