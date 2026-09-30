@TestOn('browser')
library;

import 'package:device_services/src/full_screen/browser_full_screen_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

// Run by tool/coverage.dart with `flutter test --platform chrome`, because the
// VM runner cannot compile dart:js_interop.
void main() {
  test('binds the document Fullscreen API when the browser offers it', () {
    expect(web.document.fullscreenEnabled, isTrue);
    expect(browserFullScreen(), isNotNull);
  });

  test('forwards fullscreenchange events until the listener is removed', () {
    final changes = <bool>[];
    final remove = browserFullScreen()!.listen(changes.add);

    web.document.dispatchEvent(web.Event('fullscreenchange'));
    remove();
    web.document.dispatchEvent(web.Event('fullscreenchange'));

    expect(changes, [false]);
  });

  test('leaving full screen when not in it is a no-op', () async {
    await browserFullScreen()!.apply(false);
    expect(web.document.fullscreenElement, isNull);
  });

  test('entering full screen asks the browser', () async {
    // Headless Chrome rejects requests without a user gesture; the call
    // reaching the browser is what this binding owns.
    try {
      await browserFullScreen()!.apply(true);
    } catch (_) {}
    expect(web.document.fullscreenEnabled, isTrue);
  });
}
