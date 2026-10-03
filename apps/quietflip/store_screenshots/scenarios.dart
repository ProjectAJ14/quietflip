// The capture is a test harness that lives outside test/ (so the coverage
// gate skips it); it switches Firebase off through the same test seam as
// test/entrypoint_test.dart.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:bloc/bloc.dart' show Closable;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/skin_customizer.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:quietflip/bootstrap.dart' as bootstrap;
import 'package:quietflip/main.dart' as entrypoint;
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../test/clock_support.dart';
import 'targets.dart';

/// audioplayers also listens on per-player event channels that
/// `clock_support.dart` cannot name in advance, and cancels them late,
/// after the test that created the player. Answers them for the whole test
/// file so no MissingPluginException lands in a later test.
void answerAudioChannels() {
  TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .allMessagesHandler = (channel, handler, message) =>
      channel.startsWith('xyz.luan/audioplayers')
      ? Future.value(const StandardMethodCodec().encodeSuccessEnvelope(null))
      : handler?.call(message);
}

/// Fails naming [what] with the whole error (the widget that overflowed,
/// say), not just its first line.
void expectNoError(WidgetTester tester, String what) {
  final error = tester.takeException();
  if (error == null) return;
  fail('$what: ${error is FlutterError ? error.toStringDeep() : error}');
}

/// The time on every capture: the classic watch-advert 10:09.
final DateTime frozenNow = DateTime(2026, 9, 29, 10, 9, 30);

/// A [Stopwatch] whose reading the scenario sets.
class _FixedStopwatch implements Stopwatch {
  Duration reading = Duration.zero;
  bool _running = false;

  @override
  Duration get elapsed => reading;

  @override
  bool get isRunning => _running;

  @override
  void start() => _running = true;

  @override
  void stop() => _running = false;

  @override
  void reset() => reading = Duration.zero;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The user's own skin shown on the customize card: a copy of Nightstand
/// recoloured, in another face.
Skin _customSkin() => Skin(
  id: 'custom-1',
  name: strings.clock.customize_copy_name(strings.clock.skin_nightstand),
  face: DisplayFace.spaceGrotesk,
  digitColor: DesignSkinColors.mint,
  cardColor: DesignSkinColors.cardInk,
  groundColor: DesignSkinColors.bgInk,
  seconds: SkinSeconds.badge,
);

/// Saved settings per card. Controls never auto-hide (`controlsIdle`
/// zero = Never), so a capture is never caught mid-collapse.
ClockSettings _settings(String card) {
  const base = ClockSettings(controlsIdle: Duration.zero);
  return switch (card) {
    'pomodoro' => base.copyWith(lastMode: ClockMode.pomodoro),
    'stopwatch' => base.copyWith(lastMode: ClockMode.stopwatch),
    'customize' => base.copyWith(
      customSkins: [_customSkin()],
      skinId: 'custom-1',
    ),
    'nightstand' => base.copyWith(
      skinId: 'nightstand',
      showSeconds: true,
      showDate: true,
      digitBrightness: 0.5,
    ),
    _ => base,
  };
}

/// Pomodoro focus, round 1, 18:42 left at [frozenNow].
Map<String, Object?> _countdown() => {
  'durationMs': const Duration(minutes: 25).inMilliseconds,
  'status': 'running',
  'endsAtMs': frozenNow
      .add(const Duration(minutes: 18, seconds: 42))
      .millisecondsSinceEpoch,
  'savedAtMs': frozenNow.millisecondsSinceEpoch,
  'pomodoro': {'phase': 'focus', 'round': 1},
  'timerMs': const Duration(minutes: 5).inMilliseconds,
};

Future<void> _close(Object? cubit) async => (cubit! as Closable).close();

/// Runs after the real bootstrap, before the router exists (the
/// composition edge, where `di` may be rewired): the clock and the
/// countdown read [frozenNow], the stopwatch reads [watch]. [card]'s
/// countdown is saved here, not seeded before boot: the bootstrap's own
/// controller reads the real clock and would record it as finished.
Future<void> _freeze(String card, _FixedStopwatch watch) async {
  await di.unregister<ClockController>(null);
  di.register<ClockController>(
    ClockController(now: () => frozenNow),
    dispose: _close,
  );
  await di.unregister<CountdownController>(null);
  if (card == 'pomodoro') {
    await di.get<SettingsRepository>().saveCountdown(_countdown());
  }
  final countdown = CountdownController(
    repository: di.get<SettingsRepository>(),
    alerts: di.get<LocalAlerts>(),
    sound: di.get<SoundPlayer>(),
    settings: () => di.get<SettingsController>().state,
    logger: di.get<Logger>(),
    now: () => frozenNow,
    elapsed: () => Duration.zero,
  );
  await countdown.load();
  di.register<CountdownController>(countdown, dispose: _close);
  await di.unregister<StopwatchController>(null);
  di.register<StopwatchController>(
    StopwatchController(stopwatch: watch),
    dispose: _close,
  );
}

/// Boots the real app (bootstrap, router, `App`) as [device] in [language]
/// with [card]'s saved state, brings it to that card's screen and returns
/// the capture at the device's pixel ratio. Fails naming [card] and
/// [language] when the screen is not reached.
Future<ui.Image> capture(
  WidgetTester tester, {
  required String card,
  required String language,
  required Device device,
}) async {
  final why = '$card ($language, ${device.platform.name})';
  final landscape = device.rotates && landscapeCards.contains(card);
  final size = landscape ? device.size.flipped : device.size;
  final insets = landscape ? device.landscapeInsets : device.insets;

  // Before seeding: the custom skin's name is localized.
  LocalizationProvider.select([Locale(language)]);
  useInMemoryStorage();

  // Seeds the in-memory store the real SettingsRepository reads.
  final store = SharedPreferencesAsyncPlatform.instance!;
  const options = SharedPreferencesOptions();
  await tester.runAsync(() async {
    await store.setString(
      'flip_clock.settings',
      jsonEncode(_settings(card).toJson()),
      options,
    );
  });

  tester.platformDispatcher.localesTestValue = [Locale(language)];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(() => LocalizationProvider.select(const []));
  final ratio = device.ratio;
  tester.view
    ..physicalSize = size * ratio
    ..devicePixelRatio = ratio
    ..padding = FakeViewPadding(
      left: insets.left * ratio,
      top: insets.top * ratio,
      right: insets.right * ratio,
      bottom: insets.bottom * ratio,
    )
    ..viewPadding = FakeViewPadding(
      left: insets.left * ratio,
      top: insets.top * ratio,
      right: insets.right * ratio,
      bottom: insets.bottom * ratio,
    );
  addTearDown(tester.view.reset);

  final firebase = bootstrap.defaultFirebaseOptions;
  bootstrap.defaultFirebaseOptions = () =>
      throw UnsupportedError('Firebase stays off for store screenshots');
  addTearDown(() => bootstrap.defaultFirebaseOptions = firebase);

  debugDefaultTargetPlatformOverride = device.platform;
  final watch = _FixedStopwatch();
  final boundary = GlobalKey();
  try {
    await tester.runAsync(
      () => entrypoint.startApp(
        initialize: (onOpenRoute) async {
          await bootstrap.init(onOpenRoute: onOpenRoute);
          await _freeze(card, watch);
        },
        mount: (app) => runApp(RepaintBoundary(key: boundary, child: app)),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pumpAndSettle();
    expect(
      find.byType(FlipClockScreen),
      findsOneWidget,
      reason: '$why: the clock screen did not open',
    );

    await _act(tester, card, watch, why);
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pumpAndSettle();
    expectNoError(tester, why);

    final image = await tester.runAsync(
      () =>
          (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: ratio),
    );
    // Stops the stopwatch's ticker, created in fake time.
    di.get<StopwatchController>().pause();
    await tester.pumpWidget(const SizedBox());
    return image!;
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// Shows the controls the way a user does: a tap on the clock. A double
/// tap recognizer (desktop) holds the tap for its timeout first.
Future<void> _showControls(WidgetTester tester) async {
  await tester.tapAt(tester.getCenter(find.byType(FlipClockScreen)));
  await tester.pump(kDoubleTapTimeout);
  await tester.pumpAndSettle();
}

Future<void> _act(
  WidgetTester tester,
  String card,
  _FixedStopwatch watch,
  String why,
) async {
  final c = strings.clock;
  switch (card) {
    case 'clock':
    case 'nightstand':
      expect(find.byType(FlipDisplay), findsWidgets, reason: why);
    case 'pomodoro':
      await _showControls(tester);
      expect(find.text(c.pomodoro_focus(1)), findsOneWidget, reason: why);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget, reason: why);
    case 'stopwatch':
      final stopwatch = di.get<StopwatchController>()..start();
      for (final split in const [
        Duration(minutes: 1, seconds: 4, milliseconds: 200),
        Duration(minutes: 2, seconds: 11, milliseconds: 900),
        Duration(minutes: 3, seconds: 2, milliseconds: 500),
      ]) {
        watch.reading = split;
        stopwatch.lap();
      }
      watch.reading = const Duration(
        minutes: 3,
        seconds: 27,
        milliseconds: 400,
      );
      await _showControls(tester);
      expect(stopwatch.state.laps, hasLength(3), reason: why);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget, reason: why);
    case 'skins':
    case 'customize':
      await _showControls(tester);
      await tester.tap(find.byTooltip(c.action_skins));
      await tester.pumpAndSettle();
      expect(find.byType(SkinPicker), findsOneWidget, reason: why);
      if (card == 'customize') {
        await tester.tap(find.text(c.skins_customize).first);
        await tester.pumpAndSettle();
        expect(find.byType(SkinCustomizer), findsOneWidget, reason: why);
      }
    default:
      fail('No scenario for card "$card"');
  }
}
