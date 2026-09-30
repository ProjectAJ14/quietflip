import 'dart:async';
import 'dart:math' as math;

import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/brightness_control.dart';
import 'package:flip_clock/state/chrome_controller.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/completion_banner.dart';
import 'package:flip_clock/ui/components/controls.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/gesture_layer.dart';
import 'package:flip_clock/ui/components/subtle_movement.dart';
import 'package:flip_clock/ui/components/timer_input.dart';
import 'package:flip_clock/ui/screens/skins_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// Pomodoro / Clock / Timer / Stopwatch as swipeable panels under one
/// [GestureLayer]: tap toggles the chrome (mode island at the top, Skins
/// and Settings corner buttons), a vertical drag changes brightness, a
/// sideways swipe changes mode. The chrome shrinks to dots after
/// `controlsIdle`, then disappears.
///
/// Keys: any key shows the chrome; Left/Right mode, Up/Down brightness,
/// F full screen, Esc leave full screen or hide the chrome, Space
/// start/pause, S seconds (Clock mode), D dim the digits.
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
    this.doubleTapFullScreen,
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

  /// Double tap toggles full screen. Null: on desktop and web only, since a
  /// double tap recognizer delays every single tap.
  final bool? doubleTapFullScreen;

  bool get _doubleTap =>
      doubleTapFullScreen ??
      (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Below this width the island sits on its own row under the corners.
  static const double stackedChromeWidth = 600;

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

  /// A text field (the timer input) has focus: gestures are off.
  bool _typing = false;

  /// The last press came from a mouse.
  bool _mouse = false;

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
    FocusManager.instance.addListener(_onFocus);
    widget.clock.start();
    // A timer that finished while the app was closed shows its banner.
    final countdown = widget.countdown.state;
    if (countdown.status == CountdownStatus.finished) {
      _setMode(
        countdown.pomodoro == null ? ClockMode.timer : ClockMode.pomodoro,
      );
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
    FocusManager.instance.removeListener(_onFocus);
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

  static bool _editing() =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() !=
      null;

  void _onFocus() {
    final typing = _editing();
    if (typing != _typing && mounted) setState(() => _typing = typing);
  }

  /// A tap on the clock toggles the chrome. A mouse click only shows it:
  /// moving the mouse there has already shown it, so toggling would hide
  /// the controls the person is reaching for. A mouse hides them by idling
  /// or Esc.
  void _onTap() => _mouse ? _chrome.wake() : _chrome.tap();

  void _setMode(ClockMode mode) => unawaited(
    widget.settings.update(widget.settings.state.copyWith(lastMode: mode)),
  );

  static List<String> get _modeNames {
    final c = strings.clock;
    return [c.mode_pomodoro, c.mode_clock, c.mode_timer, c.mode_stopwatch];
  }

  /// Shows [mode]'s name and page dots in the island for a moment.
  void _modeHud(ClockMode mode) {
    _chrome
      ..showHud(IslandTitleHud(_modeNames[mode.index], mode.index, 4))
      ..releaseHud();
  }

  /// The mode [step] panels away, if there is one (no wrap-around).
  void _stepMode(int step) {
    final i = widget.settings.state.lastMode.index + step;
    if (i < 0 || i >= ClockMode.values.length) return;
    _setMode(ClockMode.values[i]);
    _modeHud(ClockMode.values[i]);
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
    // Typing into the timer must not switch modes.
    if (_editing()) return KeyEventResult.ignored;
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
      if (mode == ClockMode.timer || mode == ClockMode.pomodoro) {
        unawaited(widget.countdown.toggle());
      } else {
        widget.stopwatch.toggle();
      }
    } else if (key == LogicalKeyboardKey.keyS && mode == ClockMode.clock) {
      _toggleSeconds();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _stepMode(-1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _stepMode(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      unawaited(_brighten(BrightnessControl.keyStep, release: true));
    } else if (key == LogicalKeyboardKey.arrowDown) {
      unawaited(_brighten(-BrightnessControl.keyStep, release: true));
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
      listener: (_, s) =>
          _setMode(s.pomodoro == null ? ClockMode.timer : ClockMode.pomodoro),
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
    // Narrow windows have no room for the tabs between the corner buttons:
    // the island takes its own row just under them.
    final stacked =
        MediaQuery.sizeOf(context).width < FlipClockScreen.stackedChromeWidth;
    final islandTop = stacked
        ? inset + DesignSize.cornerButton + DesignSpace.s2
        : inset;
    // Never while a sheet or route covers the clock or the app is away.
    final flip = settings.flipSound && _visible && _resumed
        ? widget.sound.playFlip
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
            inset: inset,
            chromeTop: islandTop,
            onFlip: flip,
            controlsVisible: chrome == ChromeState.expanded,
          ),
      ],
    );
    content = SubtleMovement(
      clock: widget.clock,
      enabled: full && settings.subtleMovement,
      child: content,
    );
    // A tap on the clock (a control keeps its own tap) toggles the chrome.
    // Off while a sheet or route covers the clock or the timer is typed in.
    content = GestureLayer(
      pages: _pages,
      pageCount: ClockMode.values.length,
      enabled: _visible && !_typing,
      brightness: settings.gestureBrightness,
      modes: settings.gestureModes,
      onTap: settings.tapToggleControls ? _onTap : null,
      onDoubleTap: widget._doubleTap
          ? () => unawaited(widget.fullScreen.toggle())
          : null,
      onGestureStart: _chrome.activity,
      onBrightness: (delta) => unawaited(_brighten(delta)),
      onBrightnessEnd: _chrome.releaseHud,
      onPage: (i) {
        _setMode(ClockMode.values[i]);
        _modeHud(ClockMode.values[i]);
      },
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
        onPointerDown: (e) {
          _mouse = e.kind == PointerDeviceKind.mouse;
          _chrome.activity();
        },
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
                  // Top centre: between the corner buttons, or on its own
                  // row under them when narrow; tabs scale down rather than
                  // run under anything.
                  Positioned(
                    left: stacked
                        ? inset
                        : inset + DesignSize.cornerButton + DesignSpace.s2,
                    right: stacked
                        ? inset
                        : inset + DesignSize.cornerButton + DesignSpace.s2,
                    top: islandTop,
                    child: Center(
                      child: Island(
                        state: chrome,
                        hud: hud,
                        tabs: _modeNames,
                        selected: settings.lastMode.index,
                        onSelect: (i) => _setMode(ClockMode.values[i]),
                        tabsLabel: c.modes,
                      ),
                    ),
                  ),
                  // Under the island.
                  if (_note)
                    Positioned(
                      left: 0,
                      right: 0,
                      top:
                          islandTop +
                          DesignSize.islandExpandedHeight +
                          DesignSpace.s2,
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
    required this.mode,
    required this.screen,
    required this.settings,
    required this.skin,
    required this.inset,
    required this.chromeTop,
    required this.onFlip,
    required this.controlsVisible,
  });

  final ClockMode mode;
  final FlipClockScreen screen;
  final ClockSettings settings;
  final Skin skin;

  /// The corner buttons' and island's distance from the safe area.
  final double inset;

  /// Where the island starts; the digits begin below it.
  final double chromeTop;

  /// The flip sound, or null while it must not play.
  final VoidCallback? onFlip;
  final bool controlsVisible;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = size.shortestSide < 400 ? DesignSpace.s2 : DesignSpace.s8;
    // Room for the chrome row (corner buttons and island) above, so it
    // never covers the digits; a tiny window gives up at most a quarter of
    // its height.
    final top = math.min(
      chromeTop +
          math.max(DesignSize.cornerButton, DesignSize.islandExpandedHeight) +
          inset,
      size.height / 4,
    );
    final flip = onFlip;
    return Padding(
      padding: EdgeInsets.fromLTRB(side, top, side, side),
      child: switch (mode) {
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
              size: settings.cardSize.factor,
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
                        style: skin.face.style(
                          color: skin.digitColor.withValues(alpha: 0.7),
                          fontSize: theme.textTheme.headlineSmall!.fontSize!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ClockMode.pomodoro || ClockMode.timer => _TimerView(
          pomodoroPanel: mode == ClockMode.pomodoro,
          skin: skin,
          controller: screen.countdown,
          controlsVisible: controlsVisible,
          onFlip: flip,
          brightness: settings.digitBrightness,
          size: settings.cardSize.factor,
        ),
        ClockMode.stopwatch => _StopwatchView(
          skin: skin,
          controller: screen.stopwatch,
          controlsVisible: controlsVisible,
          brightness: settings.digitBrightness,
          size: settings.cardSize.factor,
        ),
      },
    );
  }
}

/// The shared countdown. Idle, the Pomodoro panel offers a 25 min focus
/// and the Timer panel the duration input; once running, both show the
/// countdown (one engine).
class _TimerView extends StatelessWidget {
  const _TimerView({
    required this.pomodoroPanel,
    required this.skin,
    required this.controller,
    required this.controlsVisible,
    required this.onFlip,
    required this.brightness,
    required this.size,
  });

  final bool pomodoroPanel;
  final Skin skin;
  final CountdownController controller;
  final bool controlsVisible;
  final VoidCallback? onFlip;
  final double brightness;

  /// `FlipDisplay.size`: the chosen card size.
  final double size;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CountdownController, CountdownState>(
        bloc: controller,
        builder: (context, state) {
          if (state.status == CountdownStatus.idle && pomodoroPanel) {
            final focus = PomodoroPhase.focus.duration;
            return _WithControls(
              display: Opacity(
                opacity: brightness,
                child: FlipDisplay(
                  cards: durationValue(focus).cards,
                  skin: skin,
                  size: size,
                  semanticsLabel: strings.clock.time_remaining(
                    formatHms(focus),
                  ),
                ),
              ),
              controls: Reveal(
                visible: controlsVisible,
                child: FilledButton.tonalIcon(
                  onPressed: () => unawaited(controller.startPomodoro()),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(strings.clock.start),
                ),
              ),
            );
          }
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
          final pomodoro = state.pomodoro;
          final theme = Theme.of(context);
          final label = skin.digitColor.withValues(alpha: 0.7);
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
                      style: skin.face.style(
                        color: label,
                        fontSize: theme.textTheme.titleLarge!.fontSize!,
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
                        size: size,
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
    required this.size,
  });

  final Skin skin;
  final StopwatchController controller;
  final bool controlsVisible;
  final double brightness;

  /// `FlipDisplay.size`: the chosen card size.
  final double size;

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
                size: size,
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
