import 'dart:async';
import 'dart:math' as math;

import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/analytics/clock_analytics.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/brightness_control.dart';
import 'package:flip_clock/state/chrome_controller.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/gesture_layer.dart';
import 'package:flip_clock/ui/components/subtle_movement.dart';
import 'package:flip_clock/ui/screens/skins_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// Below this width the island floats under the corner buttons' row
/// instead of between them, so it never has to shrink to fit.
const double _besideCornersWidth = 600;

/// The chrome floating above the clock on a [size] window: how far the
/// island sits below the safe area, and how far it keeps from each side.
({double top, double side}) _islandPlace(Size size, double inset) =>
    size.width < _besideCornersWidth
    ? (top: inset + DesignSize.cornerButton + DesignSpace.s2, side: inset)
    : (top: inset, side: inset + DesignSize.cornerButton + DesignSpace.s2);

/// Pomodoro / Clock / Stopwatch as swipeable panels under one
/// [GestureLayer]: tap toggles the chrome (the island at the top: mode
/// tabs over the current mode's actions; Skins top-left, Settings
/// top-right and, on phones, Rotation bottom-right, mirrored in
/// right-to-left, all in step with the island), a vertical drag changes
/// brightness, a sideways swipe changes mode. The chrome shrinks to dots
/// after `controlsIdle`, then disappears.
///
/// Keys: any key shows the chrome; Left/Right mode (the next mode in
/// reading direction, so Left in right-to-left), Up/Down brightness,
/// F full screen, Esc leave full screen or hide the chrome, Space
/// start/pause, S seconds (Clock mode), L lap (Stopwatch), D dim the
/// digits, R screen rotation (phones).
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
    required this.brightness,
    required this.logger,
    required this.onOpenSettings,
    required this.onOpenTimerSettings,
    this.doubleTapFullScreen,
    this.orientationSupported = false,
  });

  final SettingsController settings;
  final ClockController clock;
  final CountdownController countdown;
  final StopwatchController stopwatch;
  final FullScreenController fullScreen;
  final ScreenWake wake;
  final SoundPlayer sound;
  final ScreenBrightness brightness;
  final Logger logger;
  final VoidCallback onOpenSettings;

  /// Opens Settings on the Timers category (the tray's tune icon).
  final VoidCallback onOpenTimerSettings;

  /// Shows the Rotation corner button and the R key (phones and tablets:
  /// `OrientationLock.supported`).
  final bool orientationSupported;

  /// Double tap toggles full screen. Null: on desktop and web only, since a
  /// double tap recognizer delays every single tap.
  final bool? doubleTapFullScreen;

  bool get _doubleTap =>
      doubleTapFullScreen ??
      (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

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
  late final BrightnessControl _brightness = BrightnessControl(
    device: widget.brightness,
    settings: widget.settings,
    logger: widget.logger,
  );
  late final PageController _pages = PageController(
    initialPage: widget.settings.state.lastMode.index,
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
    final countdown = widget.countdown.state;
    if (countdown.status == CountdownStatus.finished) {
      _setMode(ClockMode.pomodoro, source: SettingsSource.app);
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
    // Never leave the device dim.
    unawaited(_brightness.reset());
    _pages.dispose();
    _noteTimer?.cancel();
    unawaited(_chrome.close());
    widget.clock.stop();
    if (_wakeOn ?? false) unawaited(widget.wake.setEnabled(false));
    super.dispose();
  }

  void _onLifecycle(AppLifecycleState state) {
    // Rebuilt so the flip sound follows it.
    setState(() => _resumed = state == AppLifecycleState.resumed);
    // Backgrounded or closing: the device returns to its own brightness.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_brightness.reset());
    }
    // Leaving the screen: the snapshot records the time left now.
    if (state == AppLifecycleState.hidden) {
      unawaited(widget.countdown.saveProgress());
    }
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

  /// A tap or click on the clock toggles the chrome.
  void _onTap() => _chrome.tap();

  /// Shows [mode]; [source] is [SettingsSource.app] when the app switches
  /// by itself (a finished timer), so analytics does not count it as the
  /// user's.
  void _setMode(
    ClockMode mode, {
    SettingsSource source = SettingsSource.user,
  }) => unawaited(
    widget.settings.update(
      widget.settings.state.copyWith(lastMode: mode),
      source: source,
    ),
  );

  static List<String> get _modeNames {
    final c = strings.clock;
    return [c.mode_pomodoro, c.mode_clock, c.mode_stopwatch];
  }

  /// The mode [step] panels away, if there is one (no wrap-around). Only
  /// the mode changes: an open island morphs in place, no HUD.
  void _stepMode(int step) {
    final i = widget.settings.state.lastMode.index + step;
    if (i < 0 || i >= ClockMode.values.length) return;
    _setMode(ClockMode.values[i]);
  }

  /// Follows mode changes from tabs, keys and a finishing timer.
  void _showPage(ClockMode mode) {
    if (!_pages.hasClients || _pages.page?.round() == mode.index) return;
    if (reducedMotion(context)) {
      _pages.jumpToPage(mode.index);
    } else {
      unawaited(
        _pages.animateToPage(
          mode.index,
          duration: DesignMotion.islandMorph,
          curve: DesignMotion.islandCurve,
        ),
      );
    }
  }

  /// Changes brightness by [delta] and shows it in the island.
  Future<void> _brighten(double delta, {bool release = false}) async {
    final value = await _brightness.change(delta);
    if (!mounted) return;
    _chrome.showHud(
      IslandBrightnessHud(
        value,
        strings.clock.brightness_value('${(value * 100).round()}'),
      ),
    );
    if (release) _chrome.releaseHud();
  }

  /// Rotation cycles follow the device -> portrait -> landscape; the corner
  /// button's icon and spoken value say which (no HUD). `init()` applies it
  /// through `OrientationLock`.
  static const List<ClockOrientation> _rotations = [
    ClockOrientation.auto,
    ClockOrientation.portrait,
    ClockOrientation.landscape,
  ];

  static String _rotationName(ClockOrientation o) => switch (o) {
    ClockOrientation.auto => strings.clock.orientation_auto,
    ClockOrientation.portrait => strings.clock.orientation_portrait,
    ClockOrientation.landscape => strings.clock.orientation_landscape,
  };

  void _cycleRotation() {
    final s = widget.settings.state;
    final i = (_rotations.indexOf(s.orientation) + 1) % _rotations.length;
    unawaited(widget.settings.update(s.copyWith(orientation: _rotations[i])));
  }

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
      if (mode == ClockMode.pomodoro) {
        unawaited(widget.countdown.toggle());
      } else {
        widget.stopwatch.toggle();
      }
    } else if (key == LogicalKeyboardKey.keyS && mode == ClockMode.clock) {
      _toggleSeconds();
    } else if (key == LogicalKeyboardKey.keyL && mode == ClockMode.stopwatch) {
      widget.stopwatch.lap();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      // The next mode lies in reading direction: left in right-to-left.
      final rtl = Directionality.of(context) == TextDirection.rtl;
      _stepMode((key == LogicalKeyboardKey.arrowRight) != rtl ? 1 : -1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      unawaited(_brighten(BrightnessControl.keyStep, release: true));
    } else if (key == LogicalKeyboardKey.arrowDown) {
      unawaited(_brighten(-BrightnessControl.keyStep, release: true));
    } else if (key == LogicalKeyboardKey.keyD) {
      _dim();
    } else if (key == LogicalKeyboardKey.keyR && widget.orientationSupported) {
      _cycleRotation();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _openSkins() => unawaited(
    showSkins(context, settings: widget.settings, now: widget.clock.state),
  );

  /// The island, rebuilt when the countdown or stopwatch changes state
  /// (not on every tick).
  Widget _island(ClockSettings settings, ChromeState chrome, IslandHud? hud) =>
      BlocBuilder<CountdownController, CountdownState>(
        bloc: widget.countdown,
        buildWhen: (a, b) =>
            a.status != b.status ||
            a.pomodoro != b.pomodoro ||
            a.duration != b.duration,
        builder: (context, countdown) =>
            BlocBuilder<StopwatchController, StopwatchState>(
              bloc: widget.stopwatch,
              buildWhen: (a, b) =>
                  a.running != b.running || a.isIdle != b.isIdle,
              builder: (context, stopwatch) {
                final c = strings.clock;
                final mode = settings.lastMode;
                return Island(
                  state: chrome,
                  hud: hud,
                  tabs: _modeNames,
                  selected: mode.index,
                  onSelect: (i) => _setMode(ClockMode.values[i]),
                  tabsLabel: c.modes,
                  status:
                      mode == ClockMode.pomodoro &&
                          countdown.status == CountdownStatus.finished
                      ? c.times_up
                      : null,
                  actions: _tray(mode, settings, countdown, stopwatch),
                );
              },
            ),
      );

  /// What [mode]'s panel can do right now, primary action first.
  List<IslandAction> _tray(
    ClockMode mode,
    ClockSettings settings,
    CountdownState countdown,
    StopwatchState stopwatch,
  ) {
    final c = strings.clock;
    final down = widget.countdown;
    final watch = widget.stopwatch;
    IslandAction act(
      String label,
      IconData icon,
      VoidCallback onPressed, {
      bool primary = false,
    }) => IslandAction(
      label: label,
      icon: icon,
      onPressed: onPressed,
      primary: primary,
    );
    final reset = act(
      c.action_reset,
      Icons.restart_alt_rounded,
      () => unawaited(down.reset()),
    );
    return switch (mode) {
      ClockMode.clock => const [],
      ClockMode.pomodoro => switch (countdown.status) {
        CountdownStatus.idle => [
          act(
            c.action_start,
            Icons.play_arrow_rounded,
            () => unawaited(down.startPreset(settings.defaultTimer)),
            primary: true,
          ),
          IslandAction(
            label: c.preset_pomodoro,
            onPressed: () => unawaited(down.startPomodoro()),
          ),
          for (final preset in settings.timerPresets)
            IslandAction(
              label: presetLabel(preset),
              semanticsLabel: presetSpoken(preset),
              onPressed: () => unawaited(down.start(preset)),
            ),
          act(
            c.action_timer_settings,
            Icons.tune_rounded,
            widget.onOpenTimerSettings,
          ),
        ],
        CountdownStatus.running => [
          act(
            c.action_pause,
            Icons.pause_rounded,
            () => unawaited(down.pause()),
            primary: true,
          ),
          reset,
        ],
        CountdownStatus.paused => [
          act(
            c.action_resume,
            Icons.play_arrow_rounded,
            () => unawaited(down.resume()),
            primary: true,
          ),
          reset,
        ],
        CountdownStatus.finished => [
          switch (countdown.pomodoro?.phase) {
            null => act(
              c.action_restart,
              Icons.replay_rounded,
              () => unawaited(down.restart()),
              primary: true,
            ),
            final phase => act(
              phase == PomodoroPhase.focus ? c.start_break : c.start_focus,
              Icons.skip_next_rounded,
              () => unawaited(down.startNextPhase()),
              primary: true,
            ),
          },
          act(
            c.action_done,
            Icons.check_rounded,
            () => unawaited(down.reset()),
          ),
        ],
      },
      ClockMode.stopwatch => [
        if (stopwatch.running) ...[
          act(c.action_pause, Icons.pause_rounded, watch.pause, primary: true),
          act(c.action_lap, Icons.flag_outlined, watch.lap),
        ] else if (stopwatch.isIdle)
          act(
            c.action_start,
            Icons.play_arrow_rounded,
            watch.start,
            primary: true,
          )
        else ...[
          act(
            c.action_resume,
            Icons.play_arrow_rounded,
            watch.start,
            primary: true,
          ),
          act(c.action_reset, Icons.restart_alt_rounded, watch.reset),
        ],
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    // Finishing while on Clock or Stopwatch switches to Pomodoro so the
    // completion banner is seen even with the alert sound off.
    return BlocListener<CountdownController, CountdownState>(
      bloc: widget.countdown,
      listenWhen: (a, b) =>
          a.status != CountdownStatus.finished &&
          b.status == CountdownStatus.finished,
      // The island opens on the finished tray, even if it was hidden; it
      // still collapses after the idle time.
      listener: (_, _) {
        _setMode(ClockMode.pomodoro, source: SettingsSource.app);
        _chrome.wake();
      },
      child: BlocConsumer<SettingsController, ClockSettings>(
        bloc: widget.settings,
        listenWhen: (a, b) =>
            a.keepAwake != b.keepAwake ||
            a.controlsIdle != b.controlsIdle ||
            a.lastMode != b.lastMode,
        listener: (_, s) {
          _syncWake();
          _chrome.setIdle(s.controlsIdle);
          _showPage(s.lastMode);
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
    // Mono follows the theme: its ground and cards match Light or Black.
    final skin = Skins.resolve(
      settings.skinId,
      settings.customSkins,
    ).forTheme(DesignColors.of(context));
    final c = strings.clock;
    final hidden = chrome == ChromeState.hidden;
    final inset = MediaQuery.sizeOf(context).shortestSide >= 600
        ? DesignSpace.s6
        : DesignSpace.s4;
    final place = _islandPlace(MediaQuery.sizeOf(context), inset);
    // Never while a sheet or route covers the clock or the app is away.
    final flip = settings.flipSound && _visible && _resumed
        ? () => widget.sound.playTick(settings.tickSound)
        : null;
    // Every wrapper above the PageView stays in the tree whatever the
    // chrome, full screen or settings: a wrapper coming or going rebuilds
    // the PageView, whose new position starts on the launch mode.
    Widget content = PageView(
      controller: _pages,
      // The gesture layer is the only thing that moves the panels.
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final mode in ClockMode.values)
          _ModeView(
            mode: mode,
            screen: widget,
            settings: settings,
            skin: skin,
            onFlip: flip,
          ),
      ],
    );
    content = SubtleMovement(
      clock: widget.clock,
      enabled: full && settings.subtleMovement,
      child: content,
    );
    // A tap on the clock (a control keeps its own tap) toggles the chrome.
    // Off while a sheet or route covers the clock.
    content = GestureLayer(
      pages: _pages,
      pageCount: ClockMode.values.length,
      enabled: _visible,
      brightness: settings.gestureBrightness,
      modes: settings.gestureModes,
      onTap: settings.tapToggleControls ? _onTap : null,
      onDoubleTap: widget._doubleTap
          ? () => unawaited(widget.fullScreen.toggle())
          : null,
      onGestureStart: _chrome.activity,
      onBrightness: (delta) => unawaited(_brighten(delta)),
      onBrightnessEnd: _chrome.releaseHud,
      onPage: (i) => _setMode(ClockMode.values[i]),
      child: content,
    );
    // Screen readers cannot tap "anywhere", so a hidden chrome makes the
    // whole clock one "show controls" button.
    content = Semantics(
      button: hidden,
      label: hidden ? c.show_controls : null,
      onTap: hidden ? _chrome.wake : null,
      child: content,
    );
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _chrome.pointerDown(),
        onPointerHover: (_) => _chrome.hover(),
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
                  // Between the corner buttons, or below their row on a narrow
                  // window; never under them, never scaled down to fit.
                  PositionedDirectional(
                    start: place.side,
                    end: place.side,
                    top: place.top,
                    child: Center(child: _island(settings, chrome, hud)),
                  ),
                  // Corner chrome, in step with the island. A tap on one is
                  // its own (it sits above the gesture layer).
                  PositionedDirectional(
                    start: inset,
                    top: inset,
                    child: CornerButton(
                      state: chrome,
                      icon: Icons.palette_outlined,
                      tooltip: c.action_skins,
                      onPressed: _openSkins,
                      corner: AlignmentDirectional.topStart,
                    ),
                  ),
                  PositionedDirectional(
                    end: inset,
                    top: inset,
                    child: CornerButton(
                      state: chrome,
                      icon: Icons.settings_outlined,
                      tooltip: c.action_settings,
                      onPressed: widget.onOpenSettings,
                      corner: AlignmentDirectional.topEnd,
                    ),
                  ),
                  if (widget.orientationSupported)
                    PositionedDirectional(
                      end: inset,
                      bottom: inset,
                      // The new rotation is announced; nothing is spoken
                      // while the button is not there.
                      child: ExcludeSemantics(
                        excluding: chrome != ChromeState.expanded,
                        // One node: the button, its name and the rotation.
                        child: MergeSemantics(
                          child: Semantics(
                            liveRegion: true,
                            value: _rotationName(settings.orientation),
                            child: CornerButton(
                              state: chrome,
                              icon: switch (settings.orientation) {
                                ClockOrientation.auto =>
                                  Icons.screen_rotation_outlined,
                                ClockOrientation.portrait =>
                                  Icons.stay_current_portrait_outlined,
                                ClockOrientation.landscape =>
                                  Icons.stay_current_landscape_outlined,
                              },
                              tooltip: c.action_rotation,
                              onPressed: _cycleRotation,
                              corner: AlignmentDirectional.bottomEnd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Under the island.
                  if (_note)
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      top: place.top + Island.trayHeight + DesignSpace.s2,
                      child: const Center(child: _FullScreenNote()),
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

/// The stopwatch's split times under its digits: a grid of as many columns
/// as fit the widest label, newest first, left to right then down. Three
/// rows show (at most a third of the panel), the rest scroll.
class _Laps extends StatelessWidget {
  const _Laps({
    required this.laps,
    required this.skin,
    required this.maxHeight,
  });

  final List<Duration> laps;
  final Skin skin;

  /// A third of the panel, so short windows keep room for the digits.
  final double maxHeight;

  /// Rows visible before the grid scrolls.
  static const int visible = 3;

  /// The widest lap a cell must fit: `Lap 99  99:59:59.9`.
  static const int _lastNumber = 99;
  static const Duration _longest = Duration(
    hours: 99,
    minutes: 59,
    seconds: 59,
    milliseconds: 900,
  );

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.titleMedium!.fontSize!;
    final style = skin.face.style(color: skin.digitColor, fontSize: fontSize);
    final scaler = MediaQuery.textScalerOf(context);
    // A row is the scaled line plus a little air, so large text still fits.
    final row = scaler.scale(fontSize) * 1.5 + DesignSpace.s1;
    // Measured in the skin's face at the current text scale, not guessed.
    final painter = TextPainter(
      text: TextSpan(
        text: strings.clock.lap_label(_lastNumber, formatStopwatch(_longest)),
        style: style,
      ),
      textScaler: scaler,
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final cell = painter.width;
    painter.dispose();
    const across = DesignSpace.s4;
    const down = DesignSpace.s2;
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.max(1, (box.maxWidth + across) ~/ (cell + across));
        // Fewer laps than fit: just those columns, centred.
        final columns = math.min(fit, laps.length);
        final width = columns == fit
            ? box.maxWidth
            : columns * cell + (columns - 1) * across;
        return SizedBox(
          width: width,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.min(
                row * visible + down * (visible - 1),
                maxHeight,
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: row,
                mainAxisSpacing: down,
                crossAxisSpacing: across,
              ),
              itemCount: laps.length,
              itemBuilder: (context, i) => Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.clock.lap_label(
                      laps.length - i,
                      formatStopwatch(laps[i]),
                    ),
                    maxLines: 1,
                    style: style,
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

/// The active mode, filling the safe area with the same padding on every
/// side (less on tiny windows). The chrome floats over it: nothing here
/// makes room for the island, the corner buttons or the Rotation button,
/// so the clock never moves when they expand, collapse or hide.
class _ModeView extends StatelessWidget {
  const _ModeView({
    required this.mode,
    required this.screen,
    required this.settings,
    required this.skin,
    required this.onFlip,
  });

  final ClockMode mode;
  final FlipClockScreen screen;
  final ClockSettings settings;
  final Skin skin;

  /// The flip sound, or null while it must not play.
  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).shortestSide < 400
        ? DesignSpace.s4
        : DesignSpace.s8;
    final flip = onFlip;
    return Padding(
      padding: EdgeInsets.all(pad),
      child: switch (mode) {
        ClockMode.clock => BlocBuilder<ClockController, DateTime>(
          bloc: screen.clock,
          builder: (context, now) {
            final meridiem = meridiemOf(context);
            final text = formatClock(
              now,
              use24h: uses24h(context, settings),
              showSeconds: settings.showSeconds,
              meridiem: meridiem,
            );
            final value = clockValue(
              now,
              use24h: uses24h(context, settings),
              showSeconds: settings.showSeconds,
              skin: skin,
              meridiem: meridiem,
            );
            FlipDisplay display(String label) => FlipDisplay(
              cards: value.cards,
              badge: value.badge,
              meridiem: value.meridiem,
              skin: skin,
              size: settings.cardSize.factor,
              semanticsLabel: label,
              onFlip: flip,
              stackable: true,
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
            // The date dims with the digits, so it never outshines them. It
            // sits above the time, the pair centred as one block; the bottom
            // stays free.
            return Opacity(
              opacity: settings.digitBrightness,
              // On a cramped window the gap shrinks and the date scales down
              // with it, so the pair never overflows.
              child: LayoutBuilder(
                builder: (context, box) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: math.min(DesignSpace.s6, box.maxHeight / 8),
                  children: [
                    // Read as part of the display's label below. Never more
                    // than a quarter of the space, so the digits keep the rest.
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: box.maxHeight / 4),
                      child: ExcludeSemantics(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            date,
                            maxLines: 1,
                            softWrap: false,
                            style: skin.face.style(
                              color: skin.digitColor.withValues(alpha: 0.7),
                              fontSize:
                                  theme.textTheme.headlineSmall!.fontSize!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: display(
                        strings.clock.current_time_and_date(text, date),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ClockMode.pomodoro => _TimerView(
          defaultTimer: settings.defaultTimer,
          skin: skin,
          controller: screen.countdown,
          onFlip: flip,
          brightness: settings.digitBrightness,
          size: settings.cardSize.factor,
        ),
        ClockMode.stopwatch => _StopwatchView(
          skin: skin,
          controller: screen.stopwatch,
          brightness: settings.digitBrightness,
          size: settings.cardSize.factor,
        ),
      },
    );
  }
}

/// The countdown: idle, the default timer's length (a 25 min focus for
/// the cycle); running, the time left under the pomodoro round label.
class _TimerView extends StatelessWidget {
  const _TimerView({
    required this.defaultTimer,
    required this.skin,
    required this.controller,
    required this.onFlip,
    required this.brightness,
    required this.size,
  });

  /// What Start runs, shown while idle.
  final TimerPreset defaultTimer;
  final Skin skin;
  final CountdownController controller;
  final VoidCallback? onFlip;
  final double brightness;

  /// `FlipDisplay.size`: the chosen card size.
  final double size;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CountdownController, CountdownState>(
        bloc: controller,
        builder: (context, state) {
          final shown = state.status == CountdownStatus.idle
              ? switch (defaultTimer) {
                  PomodoroCycle() => PomodoroPhase.focus.duration,
                  Minutes(:final duration) => duration,
                }
              : state.remaining;
          final pomodoro = state.status == CountdownStatus.idle
              ? null
              : state.pomodoro;
          final theme = Theme.of(context);
          return Column(
            children: [
              if (pomodoro != null)
                // Announced as each phase starts.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    pomodoro.phase == PomodoroPhase.focus
                        ? strings.clock.pomodoro_focus(pomodoro.round)
                        : strings.clock.pomodoro_break(pomodoro.round),
                    style: skin.face.style(
                      color: skin.digitColor.withValues(alpha: 0.7),
                      fontSize: theme.textTheme.titleLarge!.fontSize!,
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Opacity(
                    opacity: brightness,
                    child: FlipDisplay(
                      cards: durationValue(shown).cards,
                      skin: skin,
                      size: size,
                      semanticsLabel: strings.clock.time_remaining(
                        formatHms(shown),
                      ),
                      onFlip: onFlip,
                      stackable: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
}

class _StopwatchView extends StatelessWidget {
  const _StopwatchView({
    required this.skin,
    required this.controller,
    required this.brightness,
    required this.size,
  });

  final Skin skin;
  final StopwatchController controller;
  final double brightness;

  /// `FlipDisplay.size`: the chosen card size.
  final double size;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StopwatchController, StopwatchState>(
        bloc: controller,
        builder: (context, state) {
          final value = stopwatchValue(state.elapsed);
          final display = FlipDisplay(
            cards: value.cards,
            badge: value.badge,
            skin: skin,
            size: size,
            semanticsLabel: strings.clock.elapsed(
              formatStopwatch(state.elapsed),
            ),
            stackable: true,
          );
          // The laps dim with the digits, like the date line.
          return Opacity(
            opacity: brightness,
            child: state.laps.isEmpty
                ? Center(child: display)
                : LayoutBuilder(
                    builder: (context, box) => Column(
                      children: [
                        Expanded(child: Center(child: display)),
                        _Laps(
                          laps: state.laps,
                          skin: skin,
                          maxHeight: box.maxHeight / 3,
                        ),
                      ],
                    ),
                  ),
          );
        },
      );
}
