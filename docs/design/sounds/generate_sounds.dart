// Synthesises Quietflip's tick and alarm sounds from scratch, so every file
// is original work with no third-party licence. Standard library only.
//
//   dart run docs/design/sounds/generate_sounds.dart [outDir]
//
// Writes 16-bit mono 44.1 kHz WAVs. The two existing files (flip.wav as the
// Classic tick, alarm.wav as the Chime alarm) are kept as they are and not
// generated here. The implementer moves this script to tool/ and points it at
// packages/device_services/assets/sounds/.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int rate = 44100;

/// Peak levels matched to the existing files: flip.wav peaks at 0.32,
/// alarm.wav at 0.57.
const double tickPeak = 0.32;
const double alarmPeak = 0.57;

final Random _noise = Random(14);

void main(List<String> args) {
  final out = args.isEmpty ? 'docs/design/sounds' : args.first;
  Directory(out).createSync(recursive: true);
  final sounds = <String, (Float64List, double)>{
    'tick_split_flap': (splitFlap(), tickPeak),
    'tick_clockwork': (clockwork(), tickPeak),
    'tick_woodblock': (woodblock(), tickPeak),
    'tick_digital': (digital(), tickPeak * 0.7),
    'alarm_bell': (bell(), alarmPeak),
    'alarm_beeps': (beeps(), alarmPeak * 0.85),
    'alarm_rising': (rising(), alarmPeak),
    'alarm_ring': (ring(), alarmPeak * 0.9),
  };
  for (final MapEntry(:key, value: (samples, peak)) in sounds.entries) {
    final file = File('$out/$key.wav')..writeAsBytesSync(wav(samples, peak));
    final ms = samples.length * 1000 ~/ rate;
    stdout.writeln('${file.path}  $ms ms');
  }
}

Float64List buffer(double seconds) => Float64List((seconds * rate).round());

/// A decaying sine added into [b] at [at] seconds.
void ping(
  Float64List b,
  double at,
  double freq,
  double amp,
  double decay, {
  double attack = 0.001,
}) {
  final start = (at * rate).round();
  for (var i = start; i < b.length; i++) {
    final t = (i - start) / rate;
    final env = min(1.0, t / attack) * exp(-t / decay);
    if (env < 1e-5 && t > attack) break;
    b[i] += amp * env * sin(2 * pi * freq * t);
  }
}

/// A short burst of noise, high-passed so it reads as a click.
void click(Float64List b, double at, double amp, double length) {
  final start = (at * rate).round();
  var last = 0.0;
  for (var i = 0; i < (length * rate).round(); i++) {
    final white = _noise.nextDouble() * 2 - 1;
    final hp = white - last;
    last = white;
    final env = exp(-i / (length * rate / 4));
    if (start + i < b.length) b[start + i] += amp * env * hp;
  }
}

// Ticks --------------------------------------------------------------------

/// A real split-flap: three flaps patter, then the card lands.
Float64List splitFlap() {
  final b = buffer(0.07);
  for (final (at, amp) in [(0.0, 1.0), (0.009, 0.6), (0.017, 0.4)]) {
    click(b, at, amp * 0.5, 0.003);
    ping(b, at, 2300, amp * 0.6, 0.004);
  }
  ping(b, 0.017, 140, 0.5, 0.015, attack: 0.002);
  return b;
}

/// A watch escapement: a sharp tick and a smaller echo 6 ms later.
Float64List clockwork() {
  final b = buffer(0.04);
  click(b, 0, 0.4, 0.0015);
  ping(b, 0, 4600, 0.8, 0.002, attack: 0.0002);
  click(b, 0.006, 0.2, 0.001);
  ping(b, 0.006, 3300, 0.45, 0.0025, attack: 0.0002);
  return b;
}

/// A hollow woodblock knock.
Float64List woodblock() {
  final b = buffer(0.09);
  ping(b, 0, 1050, 1, 0.018);
  ping(b, 0, 2650, 0.5, 0.008);
  ping(b, 0, 380, 0.3, 0.025);
  click(b, 0, 0.15, 0.001);
  return b;
}

/// A clean digital blip: a soft square wave, 25 ms.
Float64List digital() {
  final b = buffer(0.03);
  const length = 0.025;
  for (var i = 0; i < (length * rate).round(); i++) {
    final t = i / rate;
    final env = min(1.0, min(t, length - t) / 0.002);
    var s = 0.0;
    for (final h in [1, 3, 5]) {
      s += sin(2 * pi * 2200 * h * t) / h;
    }
    b[i] = env * s;
  }
  return b;
}

// Alarms (each file is one loop of the player's loop) -----------------------

/// A struck bell with inharmonic partials, one strike per 2 s.
Float64List bell() {
  final b = buffer(2);
  const f0 = 660.0;
  const partials = [
    (0.5, 0.35, 1.4),
    (1.0, 1.0, 1.1),
    (1.19, 0.5, 0.8),
    (1.56, 0.35, 0.6),
    (2.0, 0.3, 0.5),
    (2.51, 0.2, 0.35),
    (3.01, 0.12, 0.25),
  ];
  for (final (ratio, amp, decay) in partials) {
    ping(b, 0, f0 * ratio, amp, decay, attack: 0.002);
  }
  click(b, 0, 0.1, 0.002);
  return b;
}

/// The classic bedside alarm: four quick beeps, then a pause.
Float64List beeps() {
  final b = buffer(1.1);
  const beep = 0.08;
  for (var n = 0; n < 4; n++) {
    final start = (n * 0.15 * rate).round();
    for (var i = 0; i < (beep * rate).round(); i++) {
      final t = i / rate;
      final env = min(1.0, min(t, beep - t) / 0.004);
      b[start + i] =
          env * (sin(2 * pi * 1760 * t) + sin(2 * pi * 5280 * t) / 4);
    }
  }
  return b;
}

/// A gentle marimba arpeggio, C E G C, then a rest.
Float64List rising() {
  final b = buffer(1.6);
  const notes = [523.25, 659.25, 783.99, 1046.5];
  for (final (n, f) in notes.indexed) {
    final at = n * 0.15;
    ping(b, at, f, 1, 0.3, attack: 0.003);
    ping(b, at, f * 3.93, 0.25, 0.06, attack: 0.001);
    ping(b, at, f / 2, 0.15, 0.2, attack: 0.004);
  }
  return b;
}

/// An old twin-bell alarm clock: a hammer at 22 Hz for 1.2 s, then a gap.
Float64List ring() {
  final b = buffer(1.6);
  const strikes = 22.0;
  const length = 1.2;
  for (var hit = 0; hit < (length * strikes).round(); hit++) {
    final at = hit / strikes;
    final high = hit.isEven;
    ping(b, at, high ? 1320 : 1180, 0.6, 0.09, attack: 0.0005);
    ping(b, at, (high ? 1320 : 1180) * 2.76, 0.2, 0.03, attack: 0.0005);
    click(b, at, 0.08, 0.001);
  }
  return b;
}

// WAV -----------------------------------------------------------------------

/// [samples] normalised to [peak], with a 2 ms fade at the end so a loop
/// never clicks, as a 16-bit PCM WAV file.
Uint8List wav(Float64List samples, double peak) {
  final top = samples.fold(0.0, (m, s) => max(m, s.abs()));
  final fade = (0.002 * rate).round();
  final pcm = Int16List(samples.length);
  for (var i = 0; i < samples.length; i++) {
    final tail = min(1.0, (samples.length - i) / fade);
    pcm[i] = (samples[i] / top * peak * tail * 32767).round();
  }
  final data = pcm.buffer.asUint8List();
  final header = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + data.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, rate, Endian.little)
    ..setUint32(28, rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, data.length, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...data]);
}
