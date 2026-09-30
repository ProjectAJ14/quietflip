# device_services

Platform adapters for QuietFlip behind small contracts: `FullScreenController`,
`ScreenWake`, `OrientationLock`, `LocalAlerts`, `SoundPlayer`, `KeyValueStore`. Call `init()` after
`core.init()`. Bundled sounds live in `assets/sounds/`. See `CLAUDE.md`.

```dart
await device_services.init(
  alerts: LocalAlertsConfig(appName: strings.app.name),
);
final alerts = di.get<LocalAlerts>();
```
