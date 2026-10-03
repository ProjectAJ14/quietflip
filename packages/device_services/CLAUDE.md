# Quietflip: `packages/device_services`

Platform adapters behind small contracts: full screen, screen wake,
orientation lock, screen brightness, local (non-FCM) notifications, bundled sounds and key-value storage. It knows nothing
about clocks or timers and holds no product copy: callers pass titles and
bodies. Layer 2 (see `packages/CLAUDE.md`): depends on `core`, `di`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API (`package:device_services/device_services.dart`)

| Symbol | Kind | Implementation |
|---|---|---|
| `FullScreenController` | contract: `ValueListenable<bool> active`, `toggle()`, `exit()` | `PlatformFullScreenController` over an apply function. Mobile: `SystemChrome` immersiveSticky / edgeToEdge; desktop: `window_manager` `setFullScreen` + `WindowListener`; web: `browser_full_screen_web.dart` (`requestFullscreen` / `exitFullscreen` + `fullscreenchange`). Unsupported (iPhone Safari) or failing: `toggle` only flips `active` (app hides chrome) |
| `ScreenWake` | contract: `setEnabled(bool)` | `wakelock_plus` |
| `OrientationLock`, `ScreenOrientation` | contract: `bool supported`, `set(ScreenOrientation)`; enum `auto`, `landscape`, `portrait` | `SystemOrientationLock` over `SystemChrome.setPreferredOrientations` (auto = `[]`, landscape = left + right, portrait = up). Supported on Android and iOS only; web and desktop: `supported` false, `set` is a no-op |
| `ScreenBrightness`, `ScreenBrightnessException` | contract: `bool supported`, `current()`, `set(double)`, `reset()`; exception `(operation, [cause])` | `PluginScreenBrightness` over `screen_brightness` app-scoped calls (`application`, `setApplicationScreenBrightness`, `resetApplicationScreenBrightness`; no permissions). Supported on Android and iOS only; elsewhere `current` is 1.0 and `set`/`reset` are no-ops. `set` clamps to 0..1. A failing call is logged and rethrown as `ScreenBrightnessException` so the caller can dim the app instead |
| `LocalAlerts` | contract: `requestPermission()`, `schedule({id, at, title, body})`, `cancel(id)`, `showNow({title, body})` | `NotificationLocalAlerts`: `flutter_local_notifications` on every platform (web through its service-worker plugin), initialised lazily on first call so no prompt at startup. `zonedSchedule` in `tz.UTC`; Android `exactAllowWhileIdle` when `canScheduleExactNotifications`, else `inexactAllowWhileIdle`. Web: `schedule` is a no-op, `showNow` works while the tab is open |
| `SoundPlayer`, `TickSound`, `AlarmSound` | contract: `playTick(TickSound)`, `warmTick(TickSound)`, `playAlarm(AlarmSound)`, `stopAlarm()`, `previewAlarm(AlarmSound)`, `stopPreview()`; enums naming the bundled files (`.file`) | `AudioSoundPlayer` over `assets/sounds/` (table below), one shared `AudioCache`. Ticks: one `audioplayers` `AudioPool` per `TickSound` (`maxPlayers` 2), created on the first `playTick` or `warmTick` of that sound and kept, so a tick never reloads its file; `playTick` is `pool.start()`, run one after another, and switching to a different sound stops the last one first, so ticks never layer. `warmTick` loads the pool and plays nothing. A failed pool load is logged and dropped, so the next tick retries. The pool factory is constructor-injected (`AudioPool.createFromAsset` by default). Alarm: one `AudioPlayer`; loops until `stopAlarm` or 60 s, and a new `playAlarm` while one loops stops it first, so two never stack. Preview: a second `AudioPlayer` with the same loop and limit, so stopping a preview never touches the alarm. The real alarm wins: `playAlarm` stops a preview first, and `previewAlarm` is a no-op while the alarm loops. `dispose` releases both players and every pool |
| `KeyValueStore` | contract: `read`, `write`, `delete` | `shared_preferences` (`SharedPreferencesAsync`) |
| `init({alerts})` | function | Registers every implementation with `di` (disposables via `dispose:`). The app passes `LocalAlertsConfig` (app name, Android channel name, Windows toast id); other named parameters exist only to inject fakes in tests |
| `LocalAlertsConfig` | config | Notification identity; defaults are generic, not product copy |

## Layout

| Path | Responsibility |
|---|---|
| `lib/device_services.dart` | Barrel + `init()` |
| `lib/src/contracts/` | The seven `abstract interface class` contracts + `index.dart` |
| `lib/src/<role>/` | One folder per implementation (web variants via conditional imports) |
| `assets/sounds/` | Bundled sounds; load with `AssetSource` under `packages/device_services/...` |

## Bundled sounds

All ten are original: `flip.wav` and `alarm.wav` came with the first commit,
the other eight are synthesised by `tool/generate_sounds.dart`. No licence
or credit to track. 16-bit mono 44.1 kHz WAV; ticks peak at 0.32, alarms
at 0.57.

| Enum | File | Length | Sound |
|---|---|---|---|
| `TickSound.classic` (default) | `flip.wav` | 40 ms | soft click |
| `TickSound.splitFlap` | `tick_split_flap.wav` | 70 ms | three flaps at 0 / 9 / 17 ms, low landing |
| `TickSound.clockwork` | `tick_clockwork.wav` | 40 ms | 4.6 kHz tick, smaller 3.3 kHz echo |
| `TickSound.woodblock` | `tick_woodblock.wav` | 90 ms | hollow knock |
| `TickSound.digital` | `tick_digital.wav` | 30 ms | soft 2.2 kHz square blip |
| `AlarmSound.chime` (default) | `alarm.wav` | 1.0 s loop | two-tone chime |
| `AlarmSound.bell` | `alarm_bell.wav` | 2.0 s loop | struck 660 Hz bell |
| `AlarmSound.beeps` | `alarm_beeps.wav` | 1.1 s loop | four 1760 Hz beeps, pause |
| `AlarmSound.rising` | `alarm_rising.wav` | 1.6 s loop | marimba C-E-G-C, rest |
| `AlarmSound.ring` | `alarm_ring.wav` | 1.6 s loop | twin-bell hammer, gap |

## Rules

- **Never break the timer.** Every implementation logs through the injected
  `Logger` and returns gracefully when a platform is unsupported or permission
  is denied (`requestPermission` returns false, `schedule` becomes a no-op).
  No exception escapes to the UI. The one exception: `ScreenBrightness`
  logs and rethrows a typed `ScreenBrightnessException` so the caller can fall
  back to in-app dimming. Callers must catch it.
- SDK objects (plugin instances, `SharedPreferencesAsync`, `AudioPlayer`, web
  document access) are constructor-injected so tests pass fakes.
- Web code (`package:web`) is reached only through conditional imports; the
  package must still compile for VM tests and every native target.
- No FCM here: completion alerts are local notifications only.

## Common changes

- **Add a capability:** new contract in `lib/src/contracts/`, implementation in
  `lib/src/<role>/`, register it in `init()`, fake-backed test.
- **Change a sound:** for a synthesised one, edit its parameters in
  `tool/generate_sounds.dart` and run `dart run tool/generate_sounds.dart`
  from the repository root (it rewrites the eight files in
  `assets/sounds/`; output is deterministic, so unchanged sounds stay
  byte-identical). `flip.wav` and `alarm.wav` are replaced by hand (same
  name, WAV). Keep ticks short and quiet. A recorded replacement must be
  CC0 and its source URL recorded in `README.md`.
- **Add a sound:** a value on `TickSound` / `AlarmSound` with its file;
  `test/sound_player_test.dart` fails until the file exists.

## Tests

`dart run melos exec --scope=device_services -- flutter test`. Test each
implementation against a fake SDK: success, unsupported platform, denied
permission, SDK throwing (logged, not rethrown; `ScreenBrightness` logged
and rethrown typed, see `test/brightness_test.dart`). `dart run melos run coverage`
must stay 100%.

## Gotchas

- **Coverage gate vs. web file:** `tool/coverage.dart` imports every `lib/`
  file into a VM test, and `browser_full_screen_web.dart` imports
  `dart:js_interop`, which does not exist on the VM. The gate skips
  `*_web.dart` in the VM run and instead runs `test/web/` in Chrome
  (`@TestOn('browser')`); it fails a package with a `*_web.dart` and no
  `test/web/`. Keep that file to bare bindings; all behaviour sits in the
  VM-tested `PlatformFullScreenController`.
- `flutter_local_notifications_web` registers its own service worker, replacing
  Flutter's default one.
- `showNow` uses the fixed id `NotificationLocalAlerts.showNowId`; give
  `schedule` other ids. On web `cancel(id)` also closes the `showNowId`
  notification, and `requestPermission` asks the browser before registering
  the service worker (the prompt needs the tap's user activation).
- A throwing browser Fullscreen API lookup (prefixed-only Safari) is logged
  and treated as unsupported.
- `flutter_local_notifications` needs app-side platform config (Android
  receivers, permissions, core library desugaring; iOS notification delegate).
  That lives in `apps/quietflip`, not here.
