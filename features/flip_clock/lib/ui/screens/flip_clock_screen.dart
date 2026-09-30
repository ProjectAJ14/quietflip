import 'dart:async';

import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/completion_banner.dart';
import 'package:flip_clock/ui/components/controls.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/timer_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// Clock / Timer / Stopwatch. The active mode fills the screen; in full
/// screen the controls hide and a tap, click, mouse move or key shows them
/// for [revealFor].
///
/// Keys: F full screen, Esc leave it, Space start/pause, 1/2/3 modes,
/// S seconds (Clock mode), D dim the digits.
class FlipClockScreen extends StatefulWidget {
  const FlipClockScreen({
    super.key,
    required this.settings,
    required this.clock,
    required this.countdown,
    required this.stopwatch,
    required this.fullScreen,
    required this.wake,
    required this.sound,
    required this.onOpenSettings,
  });

  final SettingsController settings;
  final ClockController clock;
  final CountdownController countdown;
  final StopwatchController stopwatch;
  final FullScreenController fullScreen;
  final ScreenWake wake;
  final SoundPlayer sound;
  final VoidCallback onOpenSettings;

  /// How long revealed controls stay visible in full screen.
  static const Duration revealFor = Duration(seconds: 3);

  @override
  State<FlipClockScreen> createState() => _FlipClockScreenState();
}

class _FlipClockScreenState extends State<FlipClockScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _resumed = true;
  bool _visible = true;
  bool? _wakeOn;
  bool _revealed = false;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    _resumed = state == null || state == AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    widget.clock.start();
    // A timer that finished while the app was closed shows its banner.
    if (widget.countdown.state.status == CountdownStatus.finished) {
      _setMode(ClockMode.timer);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = ModalRoute.isCurrentOf(context) ?? true;
    _syncWake();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _hide?.cancel();
    widget.clock.stop();
    if (_wakeOn ?? false) unawaited(widget.wake.setEnabled(false));
    super.dispose();
  }

  void _onLifecycle(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _syncWake();
    if (_resumed) {
      widget.clock.refresh();
      unawaited(widget.countdown.check());
    }
  }

  /// Wake lock only while wanted, resumed and on top.
  void _syncWake() {
    final on = widget.settings.state.keepAwake && _resumed && _visible;
    if (on == _wakeOn) return;
    _wakeOn = on;
    unawaited(widget.wake.setEnabled(on));
  }

  void _reveal() {
    if (!widget.fullScreen.active.value) return;
    _hide?.cancel();
    _hide = Timer(FlipClockScreen.revealFor, () {
      if (mounted) setState(() => _revealed = false);
    });
    if (!_revealed) setState(() => _revealed = true);
  }

  void _setMode(ClockMode mode) => unawaited(
    widget.settings.update(widget.settings.state.copyWith(lastMode: mode)),
  );

  /// Toggling seconds also retires the one-time hint.
  void _toggleSeconds() {
    final s = widget.settings.state;
    unawaited(
      widget.settings.update(
        s.copyWith(showSeconds: !s.showSeconds, secondsHintSeen: true),
      ),
    );
  }

  void _dim() {
    final s = widget.settings.state;
    unawaited(
      widget.settings.update(
        s.copyWith(digitBrightness: ClockSettings.nextDim(s.digitBrightness)),
      ),
    );
  }

  void _dismissHint() => unawaited(
    widget.settings.update(
      widget.settings.state.copyWith(secondsHintSeen: true),
    ),
  );

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Typing digits into the timer must not switch modes.
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused?.findAncestorStateOfType<EditableTextState>() != null) {
      return KeyEventResult.ignored;
    }
    _reveal();
    final key = event.logicalKey;
    final mode = widget.settings.state.lastMode;
    if (key == LogicalKeyboardKey.keyF) {
      unawaited(widget.fullScreen.toggle());
    } else if (key == LogicalKeyboardKey.escape &&
        widget.fullScreen.active.value) {
      unawaited(widget.fullScreen.exit());
    } else if (key == LogicalKeyboardKey.space &&
        node.hasPrimaryFocus &&
        mode != ClockMode.clock) {
      // Only when no control has focus: a focused button's own Space
      // activation must win.
      if (mode == ClockMode.timer) {
        unawaited(widget.countdown.toggle());
      } else {
        widget.stopwatch.toggle();
      }
    } else if (key == LogicalKeyboardKey.keyS && mode == ClockMode.clock) {
      _toggleSeconds();
    } else if (key == LogicalKeyboardKey.digit1) {
      _setMode(ClockMode.clock);
    } else if (key == LogicalKeyboardKey.digit2) {
      _setMode(ClockMode.timer);
    } else if (key == LogicalKeyboardKey.digit3) {
      _setMode(ClockMode.stopwatch);
    } else if (key == LogicalKeyboardKey.keyD) {
      _dim();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Finishing while on Clock or Stopwatch switches to the Timer so the
    // completion banner is seen even with the alert sound off.
    return BlocListener<CountdownController, CountdownState>(
      bloc: widget.countdown,
      listenWhen: (a, b) =>
          a.status != CountdownStatus.finished &&
          b.status == CountdownStatus.finished,
      listener: (_, _) => _setMode(ClockMode.timer),
      child: BlocConsumer<SettingsController, ClockSettings>(
        bloc: widget.settings,
        listenWhen: (a, b) => a.keepAwake != b.keepAwake,
        listener: (_, _) => _syncWake(),
        builder: (context, settings) => ValueListenableBuilder<bool>(
          valueListenable: widget.fullScreen.active,
          builder: (context, full, _) {
            final controlsVisible = !full || _revealed;
            final bar = _TopBar(
              mode: settings.lastMode,
              fullScreen: full,
              showSeconds: settings.showSeconds,
              onSeconds: _toggleSeconds,
              onMode: _setMode,
              onFullScreen: () => unawaited(widget.fullScreen.toggle()),
              onSettings: widget.onOpenSettings,
              onDim: _dim,
            );
            Widget content = _ModeView(
              screen: widget,
              settings: settings,
              controlsVisible: controlsVisible,
            );
            // Screen readers cannot send the pointer events that reveal hidden
            // controls, so the display itself offers "show controls".
            if (full && !_revealed) {
              content = Semantics(
                button: true,
                label: strings.clock.show_controls,
                onTap: _reveal,
                child: content,
              );
            }
            return Focus(
              autofocus: true,
              onKeyEvent: _onKey,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _reveal(),
                onPointerHover: (_) => _reveal(),
                // Status bar icons that stay visible on the Black theme.
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: theme.brightness == Brightness.dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark,
                  child: Scaffold(
                    body: SafeArea(
                      child: full
                          ? Stack(
                              children: [
                                Positioned.fill(child: content),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Reveal(visible: _revealed, child: bar),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                bar,
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(child: content),
                                      // Overlays the display's padding so
                                      // the digits keep their full size.
                                      if (settings.lastMode ==
                                              ClockMode.clock &&
                                          !settings.secondsHintSeen)
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: _SecondsHint(
                                            onDismiss: _dismissHint,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.mode,
    required this.fullScreen,
    required this.showSeconds,
    required this.onSeconds,
    required this.onMode,
    required this.onFullScreen,
    required this.onSettings,
    required this.onDim,
  });

  final ClockMode mode;
  final bool fullScreen;
  final bool showSeconds;
  final VoidCallback onSeconds;
  final ValueChanged<ClockMode> onMode;
  final VoidCallback onFullScreen;
  final VoidCallback onSettings;
  final VoidCallback onDim;

  /// Below this width the mode segments show icons only.
  static const double compactWidth = 520;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < compactWidth;
    ButtonSegment<ClockMode> segment(
      ClockMode value,
      IconData icon,
      String label,
    ) => ButtonSegment(
      value: value,
      icon: Icon(icon),
      label: compact ? null : Text(label, maxLines: 1, softWrap: false),
      tooltip: compact ? label : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: strings.clock.modes,
              child: SegmentedButton<ClockMode>(
                showSelectedIcon: false,
                segments: [
                  segment(
                    ClockMode.clock,
                    Icons.schedule_rounded,
                    strings.clock.clock,
                  ),
                  segment(
                    ClockMode.timer,
                    Icons.hourglass_bottom_rounded,
                    strings.clock.timer,
                  ),
                  segment(
                    ClockMode.stopwatch,
                    Icons.timer_outlined,
                    strings.clock.stopwatch,
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (s) => onMode(s.single),
              ),
            ),
            const SizedBox(width: 16),
            if (mode == ClockMode.clock)
              IconButton(
                tooltip: showSeconds
                    ? strings.clock.hide_seconds
                    : strings.clock.show_seconds,
                isSelected: showSeconds,
                onPressed: onSeconds,
                icon: const Icon(Icons.av_timer_rounded),
              ),
            if (fullScreen)
              IconButton(
                tooltip: strings.clock.dim_digits,
                onPressed: onDim,
                icon: const Icon(Icons.brightness_6_rounded),
              ),
            IconButton(
              tooltip: fullScreen
                  ? strings.clock.exit_full_screen
                  : strings.clock.enter_full_screen,
              onPressed: onFullScreen,
              icon: Icon(
                fullScreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
              ),
            ),
            IconButton(
              tooltip: strings.clock.settings,
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-time, quiet pointer to the seconds button, with a dismiss control.
class _SecondsHint extends StatelessWidget {
  const _SecondsHint({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.clock.seconds_hint,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            tooltip: strings.clock.dismiss_hint,
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

/// The active mode, with padding that shrinks on tiny windows.
class _ModeView extends StatelessWidget {
  const _ModeView({
    required this.screen,
    required this.settings,
    required this.controlsVisible,
  });

  final FlipClockScreen screen;
  final ClockSettings settings;
  final bool controlsVisible;

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).shortestSide < 400;
    final flip = settings.flipSound ? screen.sound.playFlip : null;
    return Padding(
      padding: EdgeInsets.all(small ? 8 : 32),
      child: switch (settings.lastMode) {
        ClockMode.clock => BlocBuilder<ClockController, DateTime>(
          bloc: screen.clock,
          builder: (context, now) {
            final text = formatClock(
              now,
              use24h: settings.use24h,
              showSeconds: settings.showSeconds,
            );
            return Center(
              child: Opacity(
                opacity: settings.digitBrightness,
                child: FlipDisplay(
                  text: text,
                  semanticsLabel: strings.clock.current_time(text),
                  onFlip: flip,
                ),
              ),
            );
          },
        ),
        ClockMode.timer => _TimerView(
          controller: screen.countdown,
          controlsVisible: controlsVisible,
          onFlip: flip,
          brightness: settings.digitBrightness,
        ),
        ClockMode.stopwatch => _StopwatchView(
          controller: screen.stopwatch,
          controlsVisible: controlsVisible,
          brightness: settings.digitBrightness,
        ),
      },
    );
  }
}

class _TimerView extends StatelessWidget {
  const _TimerView({
    required this.controller,
    required this.controlsVisible,
    required this.onFlip,
    required this.brightness,
  });

  final CountdownController controller;
  final bool controlsVisible;
  final VoidCallback? onFlip;
  final double brightness;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CountdownController, CountdownState>(
        bloc: controller,
        builder: (context, state) {
          if (state.status == CountdownStatus.idle) {
            return Center(
              child: TimerInput(
                initial: state.duration,
                onChanged: (d) => unawaited(controller.setDuration(d)),
                onStart: (d) => unawaited(controller.start(d)),
              ),
            );
          }
          final text = formatHms(state.remaining);
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Opacity(
                    opacity: brightness,
                    child: FlipDisplay(
                      text: text,
                      semanticsLabel: strings.clock.time_remaining(text),
                      onFlip: onFlip,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state.status == CountdownStatus.finished)
                CompletionBanner(onDismiss: () => unawaited(controller.reset()))
              else
                Reveal(
                  visible: controlsVisible,
                  child: RunControls(
                    running: state.status == CountdownStatus.running,
                    started: true,
                    onPrimary: () => unawaited(controller.toggle()),
                    onReset: () => unawaited(controller.reset()),
                  ),
                ),
            ],
          );
        },
      );
}

class _StopwatchView extends StatelessWidget {
  const _StopwatchView({
    required this.controller,
    required this.controlsVisible,
    required this.brightness,
  });

  final StopwatchController controller;
  final bool controlsVisible;
  final double brightness;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StopwatchController, StopwatchState>(
        bloc: controller,
        builder: (context, state) {
          final text = formatStopwatch(state.elapsed);
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Opacity(
                    opacity: brightness,
                    child: FlipDisplay(
                      text: text,
                      semanticsLabel: strings.clock.elapsed(text),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Reveal(
                visible: controlsVisible,
                child: RunControls(
                  running: state.running,
                  started: !state.isIdle,
                  onPrimary: controller.toggle,
                  onReset: controller.reset,
                ),
              ),
            ],
          );
        },
      );
}
