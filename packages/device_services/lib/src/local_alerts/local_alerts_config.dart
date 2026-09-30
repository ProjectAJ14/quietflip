/// App-supplied identity for system notifications. The package holds no
/// product copy, so the app passes its own names here.
class LocalAlertsConfig {
  const LocalAlertsConfig({
    this.appName = 'App',
    this.channelId = 'alerts',
    this.channelName = 'Alerts',
    this.androidIcon = '@mipmap/ic_launcher',
    this.windowsAppUserModelId = 'App.LocalAlerts',
    this.windowsGuid = 'b5f5c0b8-3e8a-4d5e-9f3a-6c2d1e7a4b90',
  });

  /// Shown as the sender on Windows toasts.
  final String appName;

  /// Android notification channel (the name is visible in system settings).
  final String channelId;
  final String channelName;

  /// Android small icon resource.
  final String androidIcon;

  /// Windows toast identity; keep stable once shipped.
  final String windowsAppUserModelId;
  final String windowsGuid;
}
