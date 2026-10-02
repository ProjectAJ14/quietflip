import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quietflip/bootstrap.dart' as bootstrap;
import 'package:quietflip/firebase_options.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('each configured platform gets the quietflip project', () {
    for (final platform in [
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(bootstrap.defaultFirebaseOptions().projectId, 'quietflip');
    }
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(
      DefaultFirebaseOptions.currentPlatform.iosBundleId,
      'live.iajaykumar.quietflip',
    );
    expect(DefaultFirebaseOptions.web.projectId, 'quietflip');
  });

  test('unconfigured platforms throw UnsupportedError so bootstrap skips '
      'Firebase', () {
    for (final platform in [TargetPlatform.linux, TargetPlatform.fuchsia]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsUnsupportedError,
      );
    }
  });
}
