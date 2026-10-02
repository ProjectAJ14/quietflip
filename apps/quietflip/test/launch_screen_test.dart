import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quietflip/ui/splash_screen.dart';

/// Width and height from a PNG's IHDR chunk.
(int, int) _pngSize(String path) {
  final bytes = ByteData.sublistView(File(path).readAsBytesSync());
  return (bytes.getUint32(16), bytes.getUint32(20));
}

String _read(String path) => File(path).readAsStringSync();

// The native launch screens come from flutter_native_splash.yaml. These
// checks keep them in step with the Flutter SplashScreen, so the hand-off
// from native to Flutter does not jump.
void main() {
  test('the logo is 4x of the width the Flutter splash draws it at', () {
    final (width, _) = _pngSize(SplashScreen.logoAsset);
    expect(width, SplashScreen.logoWidth * 4);
  });

  test('the Android 12+ icon keeps the logo inside the 192dp circle', () {
    final (width, height) = _pngSize(
      'assets/splash/quietflip-logo-android12.png',
    );
    expect((width, height), (1152, 1152));
    final (logoW, logoH) = _pngSize(SplashScreen.logoAsset);
    // Half the logo's diagonal fits in the 768px (192dp at 4x) circle.
    expect(logoW * logoW + logoH * logoH, lessThanOrEqualTo(768 * 768));
  });

  test('Android shows the logo on black before and from Android 12', () {
    for (final dir in ['drawable', 'drawable-v21']) {
      expect(
        _read('android/app/src/main/res/$dir/launch_background.xml'),
        contains('@drawable/splash'),
      );
    }
    for (final dir in ['values-v31', 'values-night-v31']) {
      final styles = _read('android/app/src/main/res/$dir/styles.xml');
      expect(styles, contains('@drawable/android12splash'));
      expect(
        styles,
        contains('android:windowSplashScreenBackground">#000000<'),
      );
      expect(styles, isNot(contains('?android:colorBackground')));
    }
  });

  test('iOS centres the launch image on a full-screen background', () {
    final storyboard = _read('ios/Runner/Base.lproj/LaunchScreen.storyboard');
    expect(storyboard, contains('image="LaunchImage"'));
    expect(storyboard, contains('image="LaunchBackground"'));
    expect(storyboard, contains('contentMode="center"'));
    final (width, _) = _pngSize(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
    );
    expect(width, SplashScreen.logoWidth * 3);
  });

  test('web shows the logo until the first Flutter frame', () {
    final html = _read('web/index.html');
    expect(html, contains('<picture id="splash">'));
    expect(html, contains('"flutter-first-frame", removeSplashFromWeb'));
    final (width, _) = _pngSize('web/splash/img/dark-1x.png');
    expect(width, SplashScreen.logoWidth);
  });
}
