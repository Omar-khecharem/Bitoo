import '../../data/datasources/permission_datasource.dart';
import '../entities/permission_state.dart';

abstract class PermissionService {
  Future<AllPermissionsState> checkAll();
  Future<AppPermissionStatus> requestMedia();
  Future<AppPermissionStatus> requestNotifications();
  Future<AppPermissionStatus> requestBluetooth();
  Future<void> requestBatteryOptimization();
  Future<AppPermissionStatus> get mediaStatus;
  Future<AppPermissionStatus> get notificationStatus;
}

class PermissionServiceImpl implements PermissionService {
  final PermissionDataSource _dataSource;

  PermissionServiceImpl(this._dataSource);

  @override
  Future<AllPermissionsState> checkAll() async {
    final media = await _dataSource.checkMediaPermission();
    final notifications = await _dataSource.checkNotificationPermission();
    final bluetooth = await _dataSource.checkBluetoothPermission();
    final battery = await _dataSource.isBatteryOptimizationDisabled();
    return AllPermissionsState(
      media: media,
      notifications: notifications,
      bluetooth: bluetooth,
      batteryOptimization:
          battery ? const AppPermissionGranted() : const AppPermissionDenied(),
    );
  }

  @override
  Future<AppPermissionStatus> requestMedia() =>
      _dataSource.requestMediaPermission();

  @override
  Future<AppPermissionStatus> requestNotifications() =>
      _dataSource.requestNotificationPermission();

  @override
  Future<AppPermissionStatus> requestBluetooth() =>
      _dataSource.requestBluetoothPermission();

  @override
  Future<void> requestBatteryOptimization() =>
      _dataSource.requestBatteryOptimization();

  @override
  Future<AppPermissionStatus> get mediaStatus =>
      _dataSource.checkMediaPermission();

  @override
  Future<AppPermissionStatus> get notificationStatus =>
      _dataSource.checkNotificationPermission();
}
