# Sound picker (ticks and alarms with live waves): handoff

Base: `main` at 9b70425 (island, corners and layout, feedback round 3 shipped).
Previous briefs, still valid where this one is silent:
`docs/design/island-feedback-3-handoff.md`, `docs/design/island-control-hub-handoff.md`,
`docs/design/multi-skin-handoff.md`.

Design source:

- Clickable mockup (sounds play, waves move): https://claude.ai/artifact/6TxFX8QBLUZAPSvrF4bUbc
- The same page in the repo: `docs/design/sounds/index.html`. Its `shapes` object is
  the **source of truth for every wave's motion**; port it, do not reinvent it.
- The sounds: `docs/design/sounds/*.wav`, made by `docs/design/sounds/generate_sounds.dart`.

This is the brief for the coding agent. Follow the repository `CLAUDE.md` and the
nested `CLAUDE.md` files on the path (`features/flip_clock`, `packages/device_services`,
`packages/design_system`, `packages/localization`): dependency direction, 100% line
coverage, strings through i69n, colours and shapes from the design system, generated
files read-only. Load the `design-system` and `flutter-best-practices` skills before
any UI work.

## The feedback, verbatim intent

1. Sound & alerts in Settings needs a real design, and it should look cool.
2. Five tick sounds to pick from (the sound on every card flip), the best-known
   ticking sounds. Today's single click stays as one of them.
3. Get or make the sounds; free and licence-safe for a shipped product.
4. Alarm sounds: list the system's own alarm sounds if possible; if not, five
   bundled alarms to pick from.
5. Every sound has its own wave animation that matches how it sounds, and it plays
   when the sound plays.

## Research: where the sounds come from

### System alarm sounds (item 4): not possible on every platform

| Platform | List system alarms? | How |
| --- | --- | --- |
| Android | Yes | `RingtoneManager(TYPE_ALARM)` cursor, native code (method channel) |
| iOS | **No** | No public API lists or plays the Clock app's tones. Private sound IDs risk App Store rejection |
| macOS | Partly | `/System/Library/Sounds/*.aiff` (14 short UI sounds, not alarms) |
| Windows | Partly | `C:\Windows\Media\Alarm01..10.wav` |
| Web | **No** | Browsers expose no system sounds |

iOS and web cannot do it at all, so bundled alarms are needed regardless. A system
list would need a native plugin per platform, unknown sounds get no designed wave,
and the picker would differ per device. **This brief ships five bundled alarms on
every platform.** A system list (Android and Windows) is a separate follow-up; see
Decisions.

### Bundled sounds (items 2, 3): synthesised, so no licence at all

Free libraries (Freesound CC0, Pixabay, Kenney, Mixkit) work, but each file needs its
licence checked and recorded, and "free" sites often mean free with conditions
(Pixabay forbids redistributing the raw files; Mixkit has its own licence; many
Freesound files are CC-BY and need credit). Synthesising the sounds avoids all of it:
the files are original work owned by the project.

- `docs/design/sounds/generate_sounds.dart` (standard library only) writes eight
  16-bit mono 44.1 kHz WAVs. Peak levels match today's files (ticks 0.32, alarms 0.57).
- Today's `flip.wav` and `alarm.wav` stay as Classic and Chime. Their history is the
  first commit (8acf75a); nothing records a third-party source, so treat them as ours.
- Listen to all ten in the mockup before stage 1. Retuning a sound is a parameter
  change in the script, then re-run it.

| Sound | File | Length | What it is |
| --- | --- | --- | --- |
| Tick: Classic (default) | `flip.wav` (existing) | 40 ms | today's soft click |
| Tick: Split-flap | `tick_split_flap.wav` | 70 ms | three flaps patter at 0 / 9 / 17 ms, then a low 140 Hz landing |
| Tick: Clockwork | `tick_clockwork.wav` | 40 ms | watch escapement: sharp 4.6 kHz tick, smaller 3.3 kHz echo 6 ms later |
| Tick: Woodblock | `tick_woodblock.wav` | 90 ms | hollow knock: 1050 / 2650 / 380 Hz damped partials |
| Tick: Digital | `tick_digital.wav` | 30 ms | 25 ms soft square blip at 2.2 kHz, 70% level |
| Alarm: Chime (default) | `alarm.wav` (existing) | 1.0 s loop | today's two-tone chime |
| Alarm: Bell | `alarm_bell.wav` | 2.0 s loop | struck bell, 660 Hz with inharmonic partials, one strike per loop |
| Alarm: Beeps | `alarm_beeps.wav` | 1.1 s loop | bedside alarm: four 80 ms beeps at 1760 Hz, then a pause |
| Alarm: Rising | `alarm_rising.wav` | 1.6 s loop | marimba C-E-G-C, 150 ms apart, then a rest |
| Alarm: Ring | `alarm_ring.wav` | 1.6 s loop | old twin-bell clock: hammer at 22 Hz for 1.2 s, then a gap |

## Delivery order

One pull request, one commit (or more) per stage, in this order. Run
`dart run melos run lint` and `dart run melos run coverage` after each stage.

1. **Sounds and the player contract** (items 2, 3, 4). `device_services` only.
2. **Settings model and callers.** `ClockSettings` gains the two picks; the clock and
   the countdown play the picked sound.
3. **The wave** (item 5). One `SoundWave` widget in `flip_clock`.
4. **The Sound & alerts screen** (item 1). Tiles, selection and preview.

## Stage 1: sounds and the player contract

- Move `docs/design/sounds/generate_sounds.dart` to `tool/generate_sounds.dart`, run it
  with `packages/device_services/assets/sounds/` as the out dir, and commit the eight
  WAVs. Delete `docs/design/sounds/*.wav` and the script copy (the mockup page stays,
  pointing at the assets). Document the command in `packages/device_services/CLAUDE.md`
  ("Change a sound"). `tool/` is outside the lint and coverage gates, like the other
  scripts there.
- Add two enums to `device_services` (they name bundled assets, a capability of this
  package, and carry no product copy):

```dart
enum TickSound {
  classic('flip.wav'), splitFlap('tick_split_flap.wav'), clockwork('tick_clockwork.wav'),
  woodblock('tick_woodblock.wav'), digital('tick_digital.wav');
  const TickSound(this.file);
  final String file;
}
enum AlarmSound {
  chime('alarm.wav'), bell('alarm_bell.wav'), beeps('alarm_beeps.wav'),
  rising('alarm_rising.wav'), ring('alarm_ring.wav');
  const AlarmSound(this.file);
  final String file;
}
```

- `SoundPlayer` (`packages/device_services/lib/src/contracts/sound_player.dart`)
  becomes `playTick(TickSound sound)`, `playAlarm(AlarmSound sound)`, `stopAlarm()`.
  `playFlip` is removed (no speculative alias). `AudioSoundPlayer`
  (`lib/src/sound/audio_sound_player.dart`) plays `AssetSource(sound.file)` on the same
  two players; the 60 s limit and loop mode are unchanged. A new `playAlarm` while one
  loops switches the file (stop, then play), never stacks two.
- Keep existing file names (`flip.wav`, `alarm.wav`): no rename churn for one word.
- Tests (`packages/device_services/test/sound_player_test.dart`): each enum value plays
  its file; `playAlarm(bell)` then `playAlarm(beeps)` leaves one looping source with the
  beeps file; the limit still stops it; a throwing player is logged, not rethrown; every
  `TickSound.file` and `AlarmSound.file` exists under `assets/sounds/` (a file-system
  check, so a missing asset fails the gate, not the user).

## Stage 2: settings model and callers

- `ClockSettings` (`features/flip_clock/lib/data/models/clock_settings.dart`) gains
  `tickSound: TickSound` (default `classic`) and `alarmSound: AlarmSound` (default
  `chime`), saved as `'tickSound'` / `'alarmSound'` by enum name, read with the
  existing `pick(...)` fallback, in `copyWith`, `==` and `hashCode`.
- `flipSound` and `alertSound` stay as the on/off switches and keep their JSON keys, so
  saved settings migrate with no code.
- Callers, the only two:
  - `flip_clock_screen.dart:559`: `widget.sound.playFlip` becomes
    `() => widget.sound.playTick(settings.tickSound)`.
  - `countdown_controller.dart:247`: `_sound.playAlarm()` becomes
    `_sound.playAlarm(settings.alarmSound)`. The Pomodoro short-chime cut-off
    (`_chimeFor`) applies to every alarm as it does today.
- Update `FakeSound` (`features/flip_clock/test/fakes.dart:58`) to record the sound
  passed, so tests assert *which* sound played, not only how many.
- Tests: JSON round trip, unknown name falls back, missing key keeps the default; the
  clock plays the picked tick; a finished timer plays the picked alarm.

## Stage 3: the wave

One widget, `SoundWave` (`features/flip_clock/lib/ui/components/sound_wave.dart`), a
`CustomPainter` with a `switch` over a private `_WaveShape` enum. Product-specific, so
it lives in the feature, not `design_system`.

- Input: the sound (`TickSound` or `AlarmSound`), `playing` start time (null at rest),
  and the colour (`Theme.of(context)` ink role; no raw colours).
- At rest it paints a still pose (time 0.12 s, energy 0.25), with **no ticker running**:
  the animation controller exists only while a preview plays.
- While playing it repaints every frame from elapsed time. Energy:
  - Tick: 0.25 + 0.75 x e^(-p / decay), p = seconds since the last tick, three ticks at
    0, 1, 2 s, then rest. This pulse is what makes a tick wave "hit" with the sound.
  - Alarm: 1.0 for two loops (period x 2), then back to rest.
- Shapes and parameters (port the matching function in the mockup's `shapes` object;
  the numbers there are the spec):

| Sound | Shape | What moves | Params |
| --- | --- | --- | --- |
| Classic | `spike` | one spike in the middle rings down | decay 0.25 |
| Split-flap | `flaps` | 11 bars flip one after another | decay 0.35 |
| Clockwork | `double` | two bursts, the second smaller | decay 0.2 |
| Woodblock | `rings` | 2 rings spread from the centre | speed 2.5, decay 0.4 |
| Digital | `steps` | square wave scrolls | 6 cycles, speed 4, decay 0.2 |
| Chime | `twin` | two sines swap loudness | period 1.0 s |
| Bell | `rings` | 4 slow rings spread and fade | speed 0.5, period 2.0 s |
| Beeps | `steps` | square wave pulses in groups of four | 7 cycles, speed 3, period 1.1 s |
| Rising | `rise` | four steps light up note by note | period 1.6 s |
| Ring | `ring` | dense wave shakes, then a gap | period 1.6 s |

- Line width 1.6 logical px, round joins. Size comes from the parent (square tile).
- Reduced motion (`MediaQuery.disableAnimationsOf` or the platform flag, as `Island`
  does): the still pose only, no shaking; the sound still plays.
- Tests: each sound paints without throwing at rest and at 0.5 s; no `Ticker` is active
  at rest (`tester.binding.hasScheduledFrame` is false after settle); reduced motion
  paints the rest pose while playing; golden-free (assert on the painter's inputs, not
  pixels).

## Stage 4: the Sound & alerts screen

Replaces `_sound` in `features/flip_clock/lib/ui/screens/settings_screen.dart:372`.
Layout matches the mockup:

```
 TICK                                  plays on every flip
 ┌─────────────────────────────────────────────────────┐
 │ Tick sound                                     [on] │
 │ A soft sound each time a card flips                 │
 ├─────────────────────────────────────────────────────┤
 │ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                  │
 │ │ ~✓ │ │||| │ │ ^^ │ │ () │ │ ⊓⊔ │                  │
 │ └────┘ └────┘ └────┘ └────┘ └────┘                  │
 │ Classic Split  Clock Wood   Digital                 │
 │ soft    flaps  watch knock  blip                    │
 └─────────────────────────────────────────────────────┘
 ALARM                       loops until dismissed, 60 s max
 ┌─────────────────────────────────────────────────────┐
 │ Alarm sound                                    [on] │
 │ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐  (same tiles)    │
 │ System notifications                          [off] │
 └─────────────────────────────────────────────────────┘
 The in-app alert always plays, even with notifications off.
```

- Two `SettingsGroup`s, headers "Tick" and "Alarm". Tick group: the switch
  (`flipSound`), then a `_SoundTiles` row. Alarm group: the switch (`alertSound`), the
  tiles, System notifications and its notes as today. Footer unchanged.
- `_SoundTiles`: a feature-private row widget like `_SkinStrip`. Columns from the row's
  width: 5 when each tile gets at least 80 px, else 3 (so 3 + 2 on a phone). Gaps
  `DesignSpace.s3` (12 at 10-14 in the mockup), padding `s3`.
- Tile: a square `SoundWave` on `surfaceRaised` with a hairline border and
  `DesignShape.of(context).sm` corners; under it the name (body 14, weight 500, one
  line, ellipsis) and a mood word (mono label 11, `inkSubtle`; `ink` while playing).
- Selected tile: the accent ring and check badge exactly as `SkinTile` draws them
  (`features/flip_clock/lib/ui/components/skin_picker.dart`); reuse its decoration,
  extract a shared private helper in the feature if needed, no copy.
- Tap a tile: selects it (saves at once, like every setting), **turns its switch on if
  it was off**, and plays a preview with the wave animating.
  - Tick preview: `playTick` three times, at 0, 1 and 2 s (how the clock sounds with
    seconds on).
  - Alarm preview: `playAlarm`, then `stopAlarm` after two loops (period x 2).
  - One preview at a time: a new tap cancels the old timers and stops the old alarm.
  - Leaving Settings (dispose) cancels the preview. Call `stopAlarm` only if the
    preview started an alarm and it is still running; a real alarm ringing behind
    Settings must not be stopped by the preview code.
- Switch off: the tiles stay, at 45% opacity, still tappable (tapping re-enables).
- `SettingsScreen` takes `SoundPlayer sound` in its constructor; the router passes
  `di.get<SoundPlayer>()` (`flip_clock_router.dart:48`), like `FlipClockScreen` does.
- Accessibility: the tiles are a radio group per kind; each tile announces
  "Woodblock, hollow knock, selected". Enter / Space selects and previews. Focus ring
  per the design system. Text scale 2.0: captions wrap to two lines max, never clip.
- Tests: tap selects, saves and previews the right sound (fake records `woodblock`
  three times over 2 s of fake time); alarm preview stops after two loops; second tap
  cancels the first; dispose cancels and does not stop an alarm it did not start;
  tapping while the switch is off turns it on; 5 vs 3 columns at 900 and 360 px wide;
  semantics labels; text scale 2.0.

## Strings (`clock.*`)

Add: `sound_tick_group` "Tick", `sound_tick_hint` "plays on every flip",
`sound_alarm_group` "Alarm", `sound_alarm_hint` "loops until dismissed, 60 s max",
`tick_sound` "Tick sound", `tick_sound_description` "A soft sound each time a card
flips", `alarm_sound_description` "Plays when a timer or Pomodoro phase ends",
`sound_selected(String name)` for semantics, and a name + mood pair per sound:

| Key | Name | Mood |
| --- | --- | --- |
| `tick_classic` / `_mood` | Classic | soft click |
| `tick_split_flap` | Split-flap | flaps patter |
| `tick_clockwork` | Clockwork | watch tick |
| `tick_woodblock` | Woodblock | hollow knock |
| `tick_digital` | Digital | clean blip |
| `alarm_chime` | Chime | two tones |
| `alarm_bell` | Bell | struck bell |
| `alarm_beeps` | Beeps | bedside |
| `alarm_rising` | Rising | marimba |
| `alarm_ring` | Ring | twin bells |

Add `alarm_sound` "Alarm sound" as the alarm switch label. Reuse
`system_notifications`, `sound_footer`. Remove `flip_sound` and `alert_sound` (replaced
by `tick_sound` and `alarm_sound`) and any key left unused. Regenerate.

## Data and migrations

- New JSON keys `tickSound`, `alarmSound`; absent on old installs, so defaults
  (Classic, Chime) reproduce today's sounds exactly. No migration code.
- Eight new assets, about 570 KB in total (alarms are most of it). Acceptable; OGG
  would halve it but `audioplayers` WAV playback is proven on every target here.

## Tests the gate expects

- Player: each enum plays its file; alarm switch never stacks; limit; logged failures;
  every asset file exists.
- Settings: two new fields round trip, fall back, compare.
- Callers: picked tick on flip, picked alarm on finish, Pomodoro short chime with any
  alarm.
- Wave: every sound paints at rest and playing; no ticker at rest; reduced motion.
- Screen: select, save, preview timing, cancel, dispose safety, switch auto-on,
  columns, semantics, text scale.

## Acceptance

- Settings > Sound & alerts shows two rows of five tiles, each with a different wave.
- Tapping Split-flap ticks three times, one second apart, and its bars flip in time
  with each tick; Woodblock throws a ring on each knock.
- Tapping Beeps plays two loops of four beeps and the square wave pulses with them,
  then everything stops and the wave returns to rest.
- With the tick switch off, tapping a tick tile turns it back on.
- With seconds on, the clock ticks with the picked sound every second; a timer ends
  with the picked alarm, looping until dismissed or 60 s.
- Reduced motion on: waves stay still, sounds still play.
- Works on web (`flutter run -d chrome`), macOS and a phone.

## Docs to update in the same PR

`packages/device_services/CLAUDE.md` and `README.md` (`SoundPlayer` API, the two enums,
the asset table, `tool/generate_sounds.dart`), `features/flip_clock/CLAUDE.md` and
`README.md` (sound picker, `SoundWave`, preview rules), root `CLAUDE.md` repository map
(add `tool/generate_sounds.dart`), `packages/localization` notes if keys are listed.

## Decisions taken for the user (change here if wrong)

- **Bundled alarms everywhere, no system list now.** iOS and web cannot list system
  alarms at all, so the bundled five are needed anyway. Cost: Android and Windows
  users do not see their system tones. Follow-up ticket if wanted: an Android-and-
  Windows "System" group below the five, generic wave, a native method channel in
  `plugins/` (about a day, plus playing `content://` URIs through `audioplayers`, which
  is a **hypothesis** to test first).
- **Synthesised, not downloaded.** No licence to track or credit to show. Cost: they
  are designed rather than recorded; if a sound feels thin, tune the script or swap in
  a CC0 recording (record its source URL in `device_services/README.md`).
- **The five ticks:** Classic, Split-flap, Clockwork, Woodblock, Digital. Rejected:
  metronome (too close to Woodblock), soft thump (inaudible on phone speakers).
- **The five alarms:** Chime, Bell, Beeps, Rising, Ring. Rejected: rooster and other
  novelty sounds (off-brand for a quiet clock).
- **Waves are designed motifs timed to each sound, not a live audio meter.**
  `audioplayers` exposes no amplitude stream; a real meter would need a new audio
  stack. Cost: the wave follows the sound's rhythm, not its exact samples.
- **Tiles, not a list.** Matches the skin gallery and gives each wave room. Rejected: a
  list with a small wave per row (reads as a plain setting, not "cool"); one big hero
  wave above a list (an extra element, same information).
- **Picking a sound turns its switch on**, and tiles stay visible (dimmed) when off.
  Rejected: hiding tiles when off (layout jumps, the choice is invisible).
- **No volume slider.** Not asked; the system volume covers it.
- **Known gap, unchanged by this brief:** with the app in the background, the system
  notification uses the OS default sound, not the picked alarm. Using the picked sound
  there means bundling it as a notification sound per platform; ticket it if wanted.
