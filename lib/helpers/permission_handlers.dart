import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  // Example of requesting multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification,
      Permission.location,
    ].request();
    return statuses;
  }
}