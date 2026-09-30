# Quietflip: `packages/device_services`

Platform adapters behind small contracts: full screen, screen wake,
orientation lock, local (non-FCM) notifications, bundled sounds and key-value storage. It knows nothing
about clocks or timers and holds no product copy: callers pass titles and
bodies. Layer 2 (see `packages/CLAUDE.md`): depends on `core`, `di`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API (`package:device_services/device_services.dart`)

| Symbol | Kind | Implementation |
|---|---|---|
| `FullScreenController` | contract: `ValueListenable<bool> active`, `toggle()`, `exit()` | `PlatformFullScreenController` over an apply function. Mobile: `SystemChrome` immersiveSticky / edgeToEdge; desktop: `window_manager` `setFullScreen` + `WindowListener`; web: `browser_full_screen_web.dart` (`requestFullscreen` / `exitFullscreen` + `fullscreenchange`). Unsupported (iPhone Safari) or failing: `toggle` only flips `active` (app hides chrome) |
| `ScreenWake` | contract: `setEnabled(bool)` | `wakelock_plus` |
| `OrientationLock`, `ScreenOrientation` | contract: `bool supported`, `set(ScreenOrientation)`; enum `auto`, `landscape`, `portrait` | `SystemOrientationLock` over `SystemChrome.setPreferredOrientations` (auto = `[]`, landscape = left + right, portrait = up). Supported on Android and iOS only; web and desktop: `supported` false, `set` is a no-op |
| `LocalAlerts` | contract: `requestPermission()`, `schedule({id, at, title, body})`, `cancel(id)`, `showNow({title, body})` | `NotificationLocalAlerts`: `flutter_local_notifications` on every platform (web through its service-worker plugin), initialised lazily on first call so no prompt at startup. `zonedSchedule` in `tz.UTC`; Android `exactAllowWhileIdle` when `canScheduleExactNotifications`, else `inexactAllowWhileIdle`. Web: `schedule` is a no-op, `showNow` works while the tab is open |
| `SoundPlayer` | contract: `playFlip()`, `playAlarm()`, `stopAlarm()` | `audioplayers` with `assets/sounds/flip.wav` (~40 ms click) and `assets/sounds/alarm.wav` (~1 s two-tone chime, looped until `stopAlarm` or 60 s) |
| `KeyValueStore` | contract: `read`, `write`, `delete` | `shared_preferences` (`SharedPreferencesAsync`) |
| `init({alerts})` | function | Registers every implementation with `di` (disposables via `dispose:`). The app passes `LocalAlertsConfig` (app name, Android channel name, Windows toast id); other named parameters exist only to inject fakes in tests |
| `LocalAlertsConfig` | config | Notification identity; defaults are generic, not product copy |

## Layout

| Path | Responsibility |
|---|---|
| `lib/device_services.dart` | Barrel + `init()` |
| `lib/src/contracts/` | The six `abstract interface class` contracts + `index.dart` |
| `lib/src/<role>/` | One folder per implementation (web variants via conditional imports) |
| `assets/sounds/` | Bundled sounds; load with `AssetSource` under `packages/device_services/...` |

## Rules

- **Never break the timer.** Every implementation logs through the injected
  `Logger` and returns gracefully when a platform is unsupported or permission
  is denied (`requestPermission` returns false, `schedule` becomes a no-op).
  No exception escapes to the UI.
- SDK objects (plugin instances, `SharedPreferencesAsync`, `AudioPlayer`, web
  document access) are constructor-injected so tests pass fakes.
- Web code (`package:web`) is reached only through conditional imports; the
  package must still compile for VM tests and every native target.
- No FCM here: completion alerts are local notifications only.

## Common changes

- **Add a capability:** new contract in `lib/src/contracts/`, implementation in
  `lib/src/<role>/`, register it in `init()`, fake-backed test.
- **Change a sound:** replace the file in `assets/sounds/` (same name, WAV);
  keep the flip click short and quiet.

## Tests

`dart run melos exec --scope=device_services -- flutter test`. Test each
implementation against a fake SDK: success, unsupported platform, denied
permission, SDK throwing (logged, not rethrown). `dart run melos run coverage`
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
