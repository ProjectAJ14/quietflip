import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The app identifier is copied into every platform's project files; a store
// treats a changed one as a different app, so all copies must agree.
const _appId = 'live.iajaykumar.quietflip';

void main() {
  const files = {
    'android/app/build.gradle.kts': [
      'namespace = "$_appId"',
      'applicationId = "$_appId"',
    ],
    'android/app/src/main/kotlin/live/iajaykumar/quietflip/MainActivity.kt': [
      'package $_appId',
    ],
    'ios/Runner.xcodeproj/project.pbxproj': [
      'PRODUCT_BUNDLE_IDENTIFIER = $_appId;',
    ],
    'macos/Runner/Configs/AppInfo.xcconfig': [
      'PRODUCT_BUNDLE_IDENTIFIER = $_appId',
    ],
    'lib/bootstrap.dart': ["windowsAppUserModelId: '$_appId'"],
  };

  for (final MapEntry(key: path, value: expected) in files.entries) {
    test('$path carries the app identifier', () {
      final source = File(path).readAsStringSync();
      for (final line in expected) {
        expect(source, contains(line));
      }
      expect(source, isNot(contains('io.nonstop')));
    });
  }
}
