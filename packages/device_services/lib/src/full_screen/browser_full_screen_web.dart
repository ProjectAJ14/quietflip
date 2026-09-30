import 'dart:js_interop';

import 'package:device_services/src/full_screen/platform_full_screen_controller.dart';
import 'package:web/web.dart' as web;

/// The document Fullscreen API; null where unsupported (iPhone Safari).
///
/// Kept to bare bindings: all behaviour lives in the VM-tested
/// [PlatformFullScreenController].
BrowserFullScreen? browserFullScreen() {
  final document = web.document;
  if (!document.fullscreenEnabled) return null;
  return (
    apply: (on) async {
      if (on) {
        await document.documentElement?.requestFullscreen().toDart;
      } else if (document.fullscreenElement != null) {
        await document.exitFullscreen().toDart;
      }
    },
    listen: (onChange) {
      final handler = ((web.Event _) {
        onChange(document.fullscreenElement != null);
      }).toJS;
      document.addEventListener('fullscreenchange', handler);
      return () => document.removeEventListener('fullscreenchange', handler);
    },
  );
}
