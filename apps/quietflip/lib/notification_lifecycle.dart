import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:notifications/notifications.dart';

/// Owns foreground notification work independently of the application view.
class NotificationLifecycle extends StatefulWidget {
  const NotificationLifecycle({
    required this.child,
    required this.logger,
    this.client,
    super.key,
  });

  final Widget child;
  final Logger logger;
  final NotificationClient? client;

  @override
  State<NotificationLifecycle> createState() => _NotificationLifecycleState();
}

class _NotificationLifecycleState extends State<NotificationLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: _resume);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _init();
    });
  }

  Future<void> _init() async {
    try {
      await widget.client?.init();
    } catch (error, stackTrace) {
      widget.logger.e('Notification initialization failed', error, stackTrace);
    }
  }

  // init() never prompts, so resuming (for example after the permission
  // dialog or the OS settings) is when a newly granted permission is seen.
  Future<void> _resume() async {
    await _init();
    try {
      await widget.client?.clearBadge();
    } catch (error, stackTrace) {
      widget.logger.e('Notification badge clearing failed', error, stackTrace);
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
