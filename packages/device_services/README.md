# device_services

Platform adapters for QuietFlip behind small contracts: `FullScreenController`,
`ScreenWake`, `OrientationLock`, `ScreenBrightness`, `LocalAlerts`, `SoundPlayer`, `KeyValueStore`. Call `init()` after
`core.init()`. Bundled sounds live in `assets/sounds/`: five ticks (`TickSound`,
played with `playTick` from a preloaded pool per sound; `warmTick` loads one
ahead of its first tick) and five looping alarms (`AlarmSound`, `playAlarm` /
`stopAlarm`, and `previewAlarm` / `stopPreview` on a separate player that
never interrupts a ringing alarm). Eight of them are synthesised by `tool/generate_sounds.dart`
(`dart run tool/generate_sounds.dart` from the repository root); none are
third-party. See `CLAUDE.md` for the table.

```dart
await device_services.init(
  alerts: LocalAlertsConfig(appName: strings.app.name),
);
final alerts = di.get<LocalAlerts>();
```
