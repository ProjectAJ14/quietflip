import 'dart:async';
import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/chrome_controller.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/completion_banner.dart';
import 'package:flip_clock/ui/components/controls.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/subtle_movement.dart';
import 'package:flip_clock/ui/components/timer_input.dart';
import 'package:flip_clock/ui/screens/skins_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// Clock / Timer / Stopwatch. The active mode fills the screen; the chrome
/// (mode island at the bottom, Skins and Settings corner buttons) shrinks to
/// dots after `controlsIdle`, then disappears; a tap brings it back.
///
/// Keys: any key shows the chrome; F full screen, Esc leave full screen or
/// hide the chrome, Space start/pause, 1/2/3 modes, S seconds (Clock mode),
/// D dim the digits.
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

  /// How long the full-screen note shows after entering full screen.
  static const Duration noteFor = Duration(seconds: 3);

  @override
  State<FlipClockScreen> createState() => _FlipClockScreenState();
}

class _FlipClockScreenState extends State<FlipClockScreen> {
  late final AppLifecycleListener _lifecycle;
  late final ChromeController _chrome = ChromeController(
    idle: widget.settings.state.controlsIdle,
  );
  bool _resumed = true;
  bool _visible = true;
  bool? _wakeOn;

  /// The full-screen note, shown for [FlipClockScreen.noteFor] on entering
  /// full screen.
  bool _note = false;
  Timer? _noteTimer;

  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    _resumed = state == null || state == AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    widget.fullScreen.active.addListener(_onFullScreen);
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
    widget.fullScreen.active.removeListener(_onFullScreen);
    _noteTimer?.cancel();
    unawaited(_chrome.close());
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

  /// Entering full screen shows the chrome with the plain-words note of what
  /// full screen does.
  void _onFullScreen() {
    _noteTimer?.cancel();
    final on = widget.fullScreen.active.value;
    if (on) {
      _chrome.wake();
      _noteTimer = Timer(FlipClockScreen.noteFor, () {
        if (mounted) setState(() => _note = false);
      });
    }
    setState(() => _note = on);
  }

  void _setMode(ClockMode mode) => unawaited(
    widget.settings.update(widget.settings.state.copyWith(lastMode: mode)),
  );

  void _toggleSeconds() {
    final s = widget.settings.state;
    unawaited(widget.settings.update(s.copyWith(showSeconds: !s.showSeconds)));
  }

  void _dim() {
    final s = widget.settings.state;
    unawaited(
      widget.settings.update(
        s.copyWith(digitBrightness: ClockSettings.nextDim(s.digitBrightness)),
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Typing digits into the timer must not switch modes.
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused?.findAncestorStateOfType<EditableTextState>() != null) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final mode = widget.settings.state.lastMode;
    if (key == LogicalKeyboardKey.escape) {
      // Esc leaves full screen first, then hides the chrome.
      if (widget.fullScreen.active.value) {
        unawaited(widget.fullScreen.exit());
      } else {
        _chrome.hide();
      }
      return KeyEventResult.handled;
    }
    _chrome.wake();
    if (key == LogicalKeyboardKey.keyF) {
      unawaited(widget.fullScreen.toggle());
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

  void _openSkins() => unawaited(
    showSkins(context, settings: widget.settings, now: widget.clock.state),
  );

  @override
  Widget build(BuildContext context) {
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
        listenWhen: (a, b) =>
            a.keepAwake != b.keepAwake || a.controlsIdle != b.controlsIdle,
        listener: (_, s) {
          _syncWake();
          _chrome.setIdle(s.controlsIdle);
        },
        builder: (context, settings) => ValueListenableBuilder<bool>(
          valueListenable: widget.fullScreen.active,
          builder: (context, full, _) => BlocBuilder<ChromeController, Chrome>(
            bloc: _chrome,
            builder: (context, chrome) =>
                _layout(context, settings, chrome.state, chrome.hud, full),
          ),
        ),
      ),
    );
  }

  Widget _layout(
    BuildContext context,
    ClockSettings settings,
    ChromeState chrome,
    IslandHud? hud,
    bool full,
  ) {
    final skin = Skins.resolve(settings.skinId, settings.customSkins);
    final c = strings.clock;
    Widget content = _ModeView(
      screen: widget,
      settings: settings,
      skin: skin,
      controlsVisible: chrome == ChromeState.expanded,
    );
    if (full && settings.subtleMovement) {
      content = SubtleMovement(clock: widget.clock, child: content);
    }
    // A tap on the clock (not on a control, which wins the tap) toggles the
    // chrome.
    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: settings.tapToggleControls ? _chrome.tap : null,
      child: content,
    );
    // Screen readers cannot tap "anywhere", so a hidden chrome makes the
    // whole clock one "show controls" button.
    if (chrome == ChromeState.hidden) {
      content = Semantics(
        button: true,
        label: c.show_controls,
        onTap: _chrome.wake,
        child: content,
      );
    }
    final inset = MediaQuery.sizeOf(context).shortestSide >= 600
        ? DesignSpace.s6
        : DesignSpace.s4;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _chrome.activity(),
        onPointerHover: (_) => _chrome.wake(),
        // Status bar icons that stay visible on the skin's ground.
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: skin.groundColor.computeLuminance() < 0.5
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: skin.groundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(child: content),
                  Positioned(
                    top: inset,
                    left: inset,
                    child: CornerButton(
                      state: chrome,
                      icon: Icons.palette_outlined,
                      tooltip: c.skins_change,
                      onPressed: _openSkins,
                      corner: Alignment.topLeft,
                    ),
                  ),
                  Positioned(
                    top: inset,
                    right: inset,
                    child: CornerButton(
                      state: chrome,
                      icon: Icons.settings_outlined,
                      tooltip: c.settings,
                      onPressed: widget.onOpenSettings,
                      corner: Alignment.topRight,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: DesignSpace.s6,
                    child: Center(
                      child: Island(
                        state: chrome,
                        hud: hud,
                        tabs: [c.clock, c.timer, c.stopwatch],
                        selected: settings.lastMode.index,
                        onSelect: (i) => _setMode(ClockMode.values[i]),
                        tabsLabel: c.modes,
                      ),
                    ),
                  ),
                  if (_note)
                    const Align(
                      alignment: Alignment.topCenter,
                      child: _FullScreenNote(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What full screen does, in plain words, shown briefly on entering it.
/// A live region, so screen readers announce it too.
class _FullScreenNote extends StatelessWidget {
  const _FullScreenNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Text(
            strings.clock.full_screen_note,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// The active mode, clear of the chrome, with padding that shrinks on tiny
/// windows.
class _ModeView extends StatelessWidget {
  const _ModeView({
    required this.screen,
    required this.settings,
    required this.skin,
    required this.controlsVisible,
  });

  final FlipClockScreen screen;
  final ClockSettings settings;
  final Skin skin;
  final bool controlsVisible;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = size.shortestSide < 400 ? DesignSpace.s2 : DesignSpace.s8;
    // Room for the corner buttons above and the island below, so the chrome
    // never covers the digits; a tiny window gives up at most a quarter of
    // its height to each.
    final top = math.min(
      DesignSize.cornerButton + DesignSpace.s4,
      size.height / 4,
    );
    final bottom = math.min(
      DesignSize.islandExpandedHeight + 2 * DesignSpace.s6,
      size.height / 4,
    );
    final flip = settings.flipSound ? screen.sound.playFlip : null;
    return Padding(
      padding: EdgeInsets.fromLTRB(side, top, side, bottom),
      child: switch (settings.lastMode) {
        ClockMode.clock => BlocBuilder<ClockController, DateTime>(
          bloc: screen.clock,
          builder: (context, now) {
            final text = formatClock(
              now,
              use24h: settings.use24h,
              showSeconds: settings.showSeconds,
            );
            final value = clockValue(
              now,
              use24h: settings.use24h,
              showSeconds: settings.showSeconds,
              skin: skin,
            );
            FlipDisplay display(String label) => FlipDisplay(
              cards: value.cards,
              badge: value.badge,
              meridiem: value.meridiem,
              skin: skin,
              semanticsLabel: label,
              onFlip: flip,
            );
            if (!settings.showDate && !skin.showDate) {
              return Center(
                child: Opacity(
                  opacity: settings.digitBrightness,
                  child: display(strings.clock.current_time(text)),
                ),
              );
            }
            final date = MaterialLocalizations.of(context).formatFullDate(now);
            final theme = Theme.of(context);
            // The date dims with the digits, so it never outshines them.
            return Opacity(
              opacity: settings.digitBrightness,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: display(
                        strings.clock.current_time_and_date(text, date),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Read as part of the display's label above.
                  ExcludeSemantics(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        date,
                        maxLines: 1,
                        softWrap: false,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: skin.digitColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ClockMode.timer => _TimerView(
          skin: skin,
          controller: screen.countdown,
          controlsVisible: controlsVisible,
          onFlip: flip,
          brightness: settings.digitBrightness,
        ),
        ClockMode.stopwatch => _StopwatchView(
          skin: skin,
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
    required this.skin,
    required this.controller,
    required this.controlsVisible,
    required this.onFlip,
    required this.brightness,
  });

  final Skin skin;
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
                secondary: FilledButton.tonalIcon(
                  onPressed: () => unawaited(controller.startPomodoro()),
                  icon: const Icon(Icons.repeat_rounded),
                  label: Text(strings.clock.pomodoro),
                ),
              ),
            );
          }
          final text = formatHms(state.remaining);
          final pomodoro = state.pomodoro;
          final theme = Theme.of(context);
          return _WithControls(
            display: Column(
              children: [
                if (pomodoro != null)
                  // Announced as each phase starts.
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      pomodoro.phase == PomodoroPhase.focus
                          ? strings.clock.pomodoro_focus(pomodoro.round)
                          : strings.clock.pomodoro_break(pomodoro.round),
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Opacity(
                      opacity: brightness,
                      child: FlipDisplay(
                        cards: durationValue(state.remaining).cards,
                        skin: skin,
                        semanticsLabel: strings.clock.time_remaining(text),
                        onFlip: onFlip,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            controls: state.status == CountdownStatus.finished
                ? CompletionBanner(
                    onDismiss: () => unawaited(controller.reset()),
                    action: pomodoro == null
                        ? null
                        : FilledButton.tonal(
                            autofocus: true,
                            onPressed: () =>
                                unawaited(controller.startNextPhase()),
                            child: Text(
                              pomodoro.phase == PomodoroPhase.focus
                                  ? strings.clock.start_break
                                  : strings.clock.start_focus,
                            ),
                          ),
                  )
                : Reveal(
                    visible: controlsVisible,
                    child: RunControls(
                      running: state.status == CountdownStatus.running,
                      started: true,
                      onPrimary: () => unawaited(controller.toggle()),
                      onReset: () => unawaited(controller.reset()),
                    ),
                  ),
          );
        },
      );
}

class _StopwatchView extends StatelessWidget {
  const _StopwatchView({
    required this.skin,
    required this.controller,
    required this.controlsVisible,
    required this.brightness,
  });

  final Skin skin;
  final StopwatchController controller;
  final bool controlsVisible;
  final double brightness;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StopwatchController, StopwatchState>(
        bloc: controller,
        builder: (context, state) {
          final text = formatStopwatch(state.elapsed);
          final value = stopwatchValue(state.elapsed);
          return _WithControls(
            display: Opacity(
              opacity: brightness,
              child: FlipDisplay(
                cards: value.cards,
                badge: value.badge,
                skin: skin,
                semanticsLabel: strings.clock.elapsed(text),
              ),
            ),
            controls: Reveal(
              visible: controlsVisible,
              child: RunControls(
                running: state.running,
                started: !state.isIdle,
                onPrimary: controller.toggle,
                onReset: controller.reset,
              ),
            ),
          );
        },
      );
}

/// The display over its controls. On a very short window (a 100 px tall
/// split view) the controls and the gap shrink to at most half the height
/// instead of overflowing; `RunControls` and `CompletionBanner` scale down.
class _WithControls extends StatelessWidget {
  const _WithControls({required this.display, required this.controls});

  final Widget display;
  final Widget controls;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Column(
      children: [
        Expanded(child: Center(child: display)),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: box.maxHeight / 2),
          child: Padding(
            padding: EdgeInsets.only(
              top: (box.maxHeight / 10).clamp(0.0, 16.0),
            ),
            child: controls,
          ),
        ),
      ],
    ),
  );
}
