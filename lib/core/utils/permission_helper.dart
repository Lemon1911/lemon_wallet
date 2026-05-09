import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestSmsAndNotificationPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.notification,
    ].request();

    return statuses[Permission.sms]!.isGranted &&
        statuses[Permission.notification]!.isGranted;
  }

  static Future<bool> hasAllPermissions() async {
    bool sms = await Permission.sms.isGranted;
    bool notification = await Permission.notification.isGranted;
    return sms && notification;
  }
}
