import 'package:window_manager/window_manager.dart';

/// Forwards desktop window full-screen changes (OS controls) to [onChange].
class WindowFullScreenListener with WindowListener {
  WindowFullScreenListener(this.onChange);

  final void Function(bool on) onChange;

  @override
  void onWindowEnterFullScreen() => onChange(true);

  @override
  void onWindowLeaveFullScreen() => onChange(false);
}
