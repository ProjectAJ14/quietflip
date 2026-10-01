import 'dart:math' as math;

import 'package:device_services/device_services.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// How a wave moves; each sound picks one with its own parameters.
enum _WaveShape { spike, flaps, double, rings, steps, twin, rise, ring }

/// The motion of one sound, ported from the `shapes` object in
/// `docs/design/sounds/index.html` (the spec: change both together).
@immutable
class _Wave {
  const _Wave.tick(
    this.shape, {
    required double this.decay,
    this.count = 3,
    this.speed = 0,
    this.cycles = 5,
  }) : period = null,
       groups = false;

  const _Wave.alarm(
    this.shape, {
    required double this.period,
    this.count = 3,
    this.speed = 0,
    this.cycles = 5,
    this.groups = false,
  }) : decay = null;

  final _WaveShape shape;

  /// Ticks: how fast the pulse after each tick dies down, in seconds.
  final double? decay;

  /// Alarms: one loop of the file, in seconds.
  final double? period;
  final int count;
  final double speed;
  final int cycles;
  final bool groups;

  /// How long a preview animates: three ticks a second apart, or two loops.
  double get until => decay != null ? 3 : period! * 2;

  /// 0.25 at rest; ticks pulse to 1 on every tick, alarms hold 1.
  double energy(double t) {
    if (t > until) return SoundWave.restEnergy;
    final decay = this.decay;
    if (decay == null) return 1;
    return SoundWave.restEnergy +
        (1 - SoundWave.restEnergy) * math.exp(-(t % 1) / decay);
  }
}

const _ticks = {
  TickSound.classic: _Wave.tick(_WaveShape.spike, decay: 0.25),
  TickSound.splitFlap: _Wave.tick(_WaveShape.flaps, decay: 0.35),
  TickSound.clockwork: _Wave.tick(_WaveShape.double, decay: 0.2),
  TickSound.woodblock: _Wave.tick(
    _WaveShape.rings,
    decay: 0.4,
    count: 2,
    speed: 2.5,
  ),
  TickSound.digital: _Wave.tick(
    _WaveShape.steps,
    decay: 0.2,
    cycles: 6,
    speed: 4,
  ),
};

const _alarms = {
  AlarmSound.chime: _Wave.alarm(_WaveShape.twin, period: 1),
  AlarmSound.bell: _Wave.alarm(
    _WaveShape.rings,
    period: 2,
    count: 4,
    speed: 0.5,
  ),
  AlarmSound.beeps: _Wave.alarm(
    _WaveShape.steps,
    period: 1.1,
    cycles: 7,
    speed: 3,
    groups: true,
  ),
  AlarmSound.rising: _Wave.alarm(_WaveShape.rise, period: 1.6),
  AlarmSound.ring: _Wave.alarm(_WaveShape.ring, period: 1.6),
};

/// A sound's wave: a still pose at rest, and while [playing] a motif timed
/// to the sound (a designed motion, not a live audio meter). Sized by its
/// parent; no ticker exists until a preview plays.
class SoundWave extends StatefulWidget {
  SoundWave.tick(
    TickSound sound, {
    required this.playing,
    required this.color,
    super.key,
  }) : _wave = _ticks[sound]!;

  SoundWave.alarm(
    AlarmSound sound, {
    required this.playing,
    required this.color,
    super.key,
  }) : _wave = _alarms[sound]!;

  /// When the current preview started, or null at rest. A new value
  /// restarts the motion.
  final DateTime? playing;

  /// The ink every stroke and fill is drawn in.
  final Color color;

  final _Wave _wave;

  /// The still pose: this many seconds in, at [restEnergy].
  static const double restTime = 0.12;
  static const double restEnergy = 0.25;

  /// Keeps moving this long after the sound, at rest energy, then stops.
  static const double tail = 0.4;

  @override
  State<SoundWave> createState() => _SoundWaveState();
}

class _SoundWaveState extends State<SoundWave>
    with SingleTickerProviderStateMixin {
  final _pose = ValueNotifier<WavePose>(const (
    time: SoundWave.restTime,
    energy: SoundWave.restEnergy,
  ));
  Ticker? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SoundWave old) {
    super.didUpdateWidget(old);
    if (old.playing != widget.playing || old._wave != widget._wave) {
      _ticker?.stop();
      _sync();
    }
  }

  void _sync() {
    if (widget.playing == null || reducedMotion(context)) {
      _ticker?.stop();
      _rest();
      return;
    }
    if (_ticker?.isActive ?? false) return;
    (_ticker ??= createTicker(_tick)).start();
  }

  void _tick(Duration elapsed) {
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (t > widget._wave.until + SoundWave.tail) {
      _ticker!.stop();
      _rest();
      return;
    }
    _pose.value = (time: t, energy: widget._wave.energy(t));
  }

  void _rest() => _pose.value = const (
    time: SoundWave.restTime,
    energy: SoundWave.restEnergy,
  );

  @override
  void dispose() {
    _ticker?.dispose();
    _pose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: SoundWavePainter(widget, pose: _pose),
    child: const SizedBox.expand(),
  );
}

/// Seconds into the motion and its energy (0.25 at rest .. 1).
typedef WavePose = ({double time, double energy});

/// Paints one frame of a [SoundWave] from [pose]; repaints when it moves.
class SoundWavePainter extends CustomPainter {
  SoundWavePainter(SoundWave wave, {required this.pose})
    : _wave = wave._wave,
      color = wave.color,
      super(repaint: pose);

  final ValueListenable<WavePose> pose;
  final Color color;
  final _Wave _wave;

  static const double strokeWidth = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final (:time, :energy) = pose.value;
    final w = size.width;
    final h = size.height;
    final o = _wave;
    switch (o.shape) {
      case _WaveShape.spike:
        _line(
          canvas,
          size,
          (x) =>
              energy *
              0.8 *
              math.sin((x - 0.5) * 60 - time * 30) *
              _gauss(x - 0.5, 0.08),
        );
      case _WaveShape.double:
        _line(
          canvas,
          size,
          (x) =>
              energy *
              (0.8 * math.sin(x * 120 - time * 40) * _gauss(x - 0.38, 0.04) +
                  0.5 * math.sin(x * 90 - time * 40) * _gauss(x - 0.62, 0.04)),
        );
      case _WaveShape.flaps:
        const n = 11;
        final bw = w / (n * 1.8);
        for (var i = 0; i < n; i++) {
          final k = math.cos(time * 9 - i * 0.55).abs();
          final bh =
              h * (0.12 + energy * 0.6 * k * _gauss(i / (n - 1) - 0.5, 0.3));
          canvas.drawRect(
            Rect.fromLTWH(
              w * 0.1 + i * (w * 0.8 / (n - 1)) - bw / 2,
              (h - bh) / 2,
              bw,
              bh,
            ),
            _fill(),
          );
        }
      case _WaveShape.rings:
        final side = math.min(w, h);
        final base = side * 0.08;
        final centre = size.center(Offset.zero);
        for (var i = 0; i < o.count; i++) {
          final p = (time * o.speed + i / o.count) % 1;
          final alpha = math.max(0, (1 - p) * math.min(1, energy * 1.6));
          canvas.drawCircle(
            centre,
            base + p * side * 0.42,
            _stroke(alpha.toDouble()),
          );
        }
        canvas.drawCircle(centre, base * (0.6 + energy * 0.6), _fill());
      case _WaveShape.steps:
        final g = !o.groups
            ? 1.0
            : ((time % 1.1) / 0.15).floor() < 4 && (time % 0.15) < 0.08
            ? 1.0
            : 0.2;
        final a = energy * g * 0.35;
        final path = Path();
        for (var i = 0; i <= 200; i++) {
          final x = i / 200;
          final sign = math
              .sin((x * o.cycles - time * o.speed) * math.pi * 2)
              .sign;
          final s = sign == 0 ? 1.0 : sign;
          final y = h / 2 - s * a * h * _gauss(x - 0.5, 0.28);
          i == 0 ? path.moveTo(x * w, y) : path.lineTo(x * w, y);
        }
        canvas.drawPath(path, _stroke());
      case _WaveShape.twin:
        final sw = math.sin(time * math.pi * 2) * 0.5 + 0.5;
        _line(
          canvas,
          size,
          (x) => energy * 0.35 * (0.4 + 0.6 * sw) * math.sin(x * 14 - time * 6),
        );
        _line(
          canvas,
          size,
          (x) =>
              energy * 0.3 * (1 - 0.6 * sw) * math.sin(x * 20 - time * 8 + 1),
          alpha: 0.5,
        );
      case _WaveShape.rise:
        const n = 4;
        final step = ((time % 1.6) / 0.15).floor();
        final bw = w * 0.12;
        for (var i = 0; i < n; i++) {
          final lit = step >= i && step < 8 ? 1.0 : 0.3;
          final bh = h * (0.18 + i * 0.13);
          canvas.drawRect(
            Rect.fromLTWH(
              w * 0.2 + i * (w * 0.6 / (n - 1)) - bw / 2,
              h * 0.78 - bh,
              bw,
              bh,
            ),
            _fill(0.25 + 0.75 * lit * math.min(1, energy * 1.4)),
          );
        }
      case _WaveShape.ring:
        final on = (time % 1.6) < 1.2 ? 1.0 : 0.25;
        final shake = math.sin(time * 138);
        canvas
          ..save()
          ..translate(shake * 2 * energy * on, 0);
        _line(
          canvas,
          size,
          (x) =>
              energy *
              on *
              0.4 *
              math.sin(x * 70 + time * 20) *
              (0.6 + 0.4 * shake) *
              _gauss(x - 0.5, 0.3),
        );
        canvas.restore();
    }
  }

  static double _gauss(double x, double w) => math.exp(-(x * x) / (2 * w * w));

  Paint _fill([double alpha = 1]) =>
      Paint()..color = color.withValues(alpha: color.a * alpha);

  Paint _stroke([double alpha = 1]) => _fill(alpha)
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeJoin = StrokeJoin.round;

  /// A 160-segment line across the box: y = middle - f(x) * height.
  void _line(
    Canvas canvas,
    Size size,
    double Function(double x) f, {
    double alpha = 1,
  }) {
    final path = Path();
    for (var i = 0; i <= 160; i++) {
      final x = i / 160;
      final y = size.height / 2 - f(x) * size.height;
      i == 0 ? path.moveTo(x * size.width, y) : path.lineTo(x * size.width, y);
    }
    canvas.drawPath(path, _stroke(alpha));
  }

  @override
  bool shouldRepaint(SoundWavePainter old) =>
      old._wave != _wave || old.color != color || old.pose != pose;
}
