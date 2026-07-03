import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionDataSource {
  Future<bool> requestAudioPermission() async {
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) return true;

    if (storageStatus.isPermanentlyDenied || audioStatus.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<bool> hasPermission() async {
    return (await Permission.audio.status).isGranted ||
        (await Permission.storage.status).isGranted;
  }

  Future<bool> requestFullFileAccess() async {
    if (!Platform.isAndroid) return true;
    await Permission.manageExternalStorage.request();
    return (await Permission.manageExternalStorage.status).isGranted;
  }

  Future<bool> hasFullFileAccess() async {
    if (!Platform.isAndroid) return true;
    return (await Permission.manageExternalStorage.status).isGranted;
  }

  bool get isAndroid11OrAbove {
    if (!Platform.isAndroid) return false;
    try {
      final version = Platform.operatingSystemVersion;
      final major = int.tryParse(version.split('.').first) ?? 0;
      return major >= 11;
    } catch (_) {
      return false;
    }
  }
}
