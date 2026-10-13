import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Gradle is not covered by the Dart gate, so this guards the release signing
// contract: never the debug key, a clear failure without credentials, and no
// key material that git could pick up.
void main() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();

  test('release builds never sign with the debug key', () {
    expect(gradle, isNot(contains('getByName("debug")')));
    expect(gradle, contains('signingConfigs.getByName("release")'));
  });

  test('release tasks fail when credentials are missing', () {
    expect(gradle, contains('taskGraph.whenReady'));
    expect(gradle, contains('GradleException'));
    expect(gradle, contains('!hasReleaseSigning'));
  });

  test('credentials come from the private folder or the environment', () {
    expect(gradle, contains('Documents/My Apps/QuietFlip'));
    for (final name in const [
      'ANDROID_KEYSTORE_FILE',
      'ANDROID_KEYSTORE_PASSWORD',
      'ANDROID_KEY_ALIAS',
      'ANDROID_KEY_PASSWORD',
    ]) {
      expect(gradle, contains(name));
    }
  });

  test('keystores and key.properties stay out of git', () {
    final ignored = File('android/.gitignore').readAsStringSync();
    for (final pattern in const ['key.properties', '*.jks', '*.keystore']) {
      expect(ignored, contains(pattern));
    }
  });
}
