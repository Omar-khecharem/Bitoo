import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../domain/entities/permission_state.dart';

class PermissionDataSource {
  Future<AppPermissionStatus> requestMediaPermission() async {
    // Try audio permission first (Android 13+)
    var status = await ph.Permission.audio.request();
    if (status.isGranted) return const AppPermissionGranted();
    if (status.isPermanentlyDenied) {
      return const AppPermissionPermanentlyDenied();
    }

    // Show rationale and retry once for audio
    var shouldShow = await ph.Permission.audio.shouldShowRequestRationale;
    if (shouldShow) {
      status = await ph.Permission.audio.request();
      if (status.isGranted) return const AppPermissionGranted();
    }

    // Fallback to storage permission (Android 12 and below)
    status = await ph.Permission.storage.request();
    if (status.isGranted) return const AppPermissionGranted();
    if (status.isPermanentlyDenied) {
      return const AppPermissionPermanentlyDenied();
    }

    return const AppPermissionDenied();
  }

  Future<AppPermissionStatus> requestNotificationPermission() async {
    if (!await _isAndroid13OrAbove()) {
      return const AppPermissionGranted();
    }
    final status = await ph.Permission.notification.request();
    return _mapStatus(status);
  }

  Future<AppPermissionStatus> requestBluetoothPermission() async {
    if (!await _isAndroid12OrAbove()) {
      return const AppPermissionGranted();
    }
    final status = await ph.Permission.bluetoothConnect.request();
    return _mapStatus(status);
  }

  Future<AppPermissionStatus> checkMediaPermission() async {
    if (await ph.Permission.audio.status.isGranted) {
      return const AppPermissionGranted();
    }
    final status = await ph.Permission.storage.status;
    return _mapStatus(status);
  }

  Future<AppPermissionStatus> checkNotificationPermission() async {
    if (!await _isAndroid13OrAbove()) {
      return const AppPermissionGranted();
    }
    final status = await ph.Permission.notification.status;
    return _mapStatus(status);
  }

  Future<AppPermissionStatus> checkBluetoothPermission() async {
    if (!await _isAndroid12OrAbove()) {
      return const AppPermissionGranted();
    }
    final status = await ph.Permission.bluetoothConnect.status;
    return _mapStatus(status);
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final version = Platform.operatingSystemVersion;
      final major = int.tryParse(version.split('.').first) ?? 0;
      return major >= 13;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isAndroid12OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final version = Platform.operatingSystemVersion;
      final major = int.tryParse(version.split('.').first) ?? 0;
      return major >= 12;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    final status = await ph.Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  Future<void> requestBatteryOptimization() async {
    await ph.openAppSettings();
  }

  AppPermissionStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted) return const AppPermissionGranted();
    if (status.isPermanentlyDenied) return const AppPermissionPermanentlyDenied();
    return const AppPermissionDenied();
  }
}
