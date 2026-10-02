import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// App Store Connect asks for encryption documentation on every upload unless
// the bundle declares it. The app only uses exempt encryption (Firebase TLS
// and auth), so both Apple bundles answer `false`. Revisit if the app ever
// encrypts user data itself.
void main() {
  const declaration = '<key>ITSAppUsesNonExemptEncryption</key>\n\t<false/>';

  for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
    test('$path declares no non-exempt encryption', () {
      expect(File(path).readAsStringSync(), contains(declaration));
    });
  }
}
