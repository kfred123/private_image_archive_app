import 'package:photo_manager/photo_manager.dart';

class PermissionManager {
  static Future<bool> requestPermissions() async {
    PermissionState permissionState = await PhotoManager.requestPermissionExtend();
    return permissionState.hasAccess;
  }
}