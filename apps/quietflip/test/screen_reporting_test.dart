import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Screens are reported by route name (`clock`, `settings`) through
// `AnalyticsRouteObserver`. Firebase's automatic screen reporting would add
// one native screen (FlutterViewController, MainActivity) for the whole app,
// so every platform with an analytics SDK turns it off. (The web SDK has no
// automatic screen views.)
void main() {
  const apple =
      '<key>FirebaseAutomaticScreenReportingEnabled</key>\n\t<false/>';

  for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
    test('$path turns automatic screen reporting off', () {
      expect(File(path).readAsStringSync(), contains(apple));
    });
  }

  test('Android turns automatic screen reporting off', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');
    expect(
      manifest,
      contains(
        '<meta-data android:name='
        '"google_analytics_automatic_screen_reporting_enabled" '
        'android:value="false" />',
      ),
    );
  });
}
