import '../../data/datasources/permission_datasource.dart';
import '../entities/permission_state.dart';

class PermissionService {
  final PermissionDataSource _dataSource;

  PermissionService(this._dataSource);

  Future<AllPermissionsState> checkAll() async {
    final media = await _dataSource.checkMediaPermission();
    final notifications = await _dataSource.checkNotificationPermission();
    final bluetooth = await _dataSource.checkBluetoothPermission();
    final battery = await _dataSource.isBatteryOptimizationDisabled();
    return AllPermissionsState(
      media: media,
      notifications: notifications,
      bluetooth: bluetooth,
      batteryOptimization: battery
          ? const AppPermissionGranted()
          : const AppPermissionDenied(),
    );
  }

  Future<AppPermissionStatus> requestMedia() =>
      _dataSource.requestMediaPermission();

  Future<AppPermissionStatus> requestNotifications() =>
      _dataSource.requestNotificationPermission();

  Future<AppPermissionStatus> requestBluetooth() =>
      _dataSource.requestBluetoothPermission();

  Future<void> requestBatteryOptimization() =>
      _dataSource.requestBatteryOptimization();

  Future<AppPermissionStatus> get mediaStatus =>
      _dataSource.checkMediaPermission();

  Future<AppPermissionStatus> get notificationStatus =>
      _dataSource.checkNotificationPermission();
}
