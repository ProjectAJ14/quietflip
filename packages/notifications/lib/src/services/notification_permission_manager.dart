import 'package:core/logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:network/network.dart';
import 'package:notifications/src/exceptions/notification_exceptions.dart';

abstract interface class NotificationPermissionManager {
  /// Shows the OS permission prompt when the status is still undecided.
  Future<bool> requestPermissions({bool provisional = false});

  /// Reads the current status without ever showing a prompt.
  Future<bool> hasPermission();
}

class FirebasePermissionManager implements NotificationPermissionManager {
  static const String _tag = 'FirebasePermissionManager';

  final Logger _logger;
  final FirebaseMessaging _firebaseMessaging;

  FirebasePermissionManager({
    required Logger logger,
    required FirebaseMessaging firebaseMessaging,
  }) : _logger = logger,
       _firebaseMessaging = firebaseMessaging;

  @override
  Future<bool> requestPermissions({bool provisional = false}) async {
    try {
      _logger.i('$_tag: Requesting notification permissions');
      final authSettings = await _firebaseMessaging.requestPermission(
        provisional: provisional,
      );

      final isGranted = _granted(authSettings.authorizationStatus);

      _logger.i(
        '$_tag: Notification permissions requested '
        'with status: ${authSettings.authorizationStatus}, '
        'granted: $isGranted',
      );

      return isGranted;
    } catch (e, s) {
      _logger.e('$_tag: Error requesting permissions', e, s);
      throw NotificationException(message: e.message());
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return _granted(settings.authorizationStatus);
    } catch (e, s) {
      _logger.e('$_tag: Error reading permission status', e, s);
      throw NotificationException(message: e.message());
    }
  }

  static bool _granted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}
