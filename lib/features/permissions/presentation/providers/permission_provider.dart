import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/permission_datasource.dart';
import '../../domain/entities/permission_state.dart';
import '../../domain/services/permission_service.dart';

final permissionDataSourceProvider = Provider<PermissionDataSource>((ref) {
  return PermissionDataSource();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionServiceImpl(ref.read(permissionDataSourceProvider));
});

final permissionStateProvider =
    StateNotifierProvider<PermissionStateNotifier, AllPermissionsState>(
  (ref) {
    final service = ref.read(permissionServiceProvider);
    return PermissionStateNotifier(service);
  },
);

class PermissionStateNotifier extends StateNotifier<AllPermissionsState> {
  final PermissionService _service;
  bool _disposed = false;

  PermissionStateNotifier(this._service) : super(const AllPermissionsState()) {
    _initialize();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _initialize() async {
    final state = await _service.checkAll();
    if (!_disposed) {
      this.state = state;
    }
  }

  Future<AppPermissionStatus> requestMedia() async {
    final result = await _service.requestMedia();
    if (!_disposed) {
      state = state.copyWith(media: result);
    }
    return result;
  }

  Future<AppPermissionStatus> requestNotifications() async {
    final result = await _service.requestNotifications();
    if (!_disposed) {
      state = state.copyWith(notifications: result);
    }
    return result;
  }

  Future<AppPermissionStatus> requestBluetooth() async {
    final result = await _service.requestBluetooth();
    if (!_disposed) {
      state = state.copyWith(bluetooth: result);
    }
    return result;
  }

  Future<void> requestBatteryOptimization() async {
    await _service.requestBatteryOptimization();
    if (!_disposed) {
      state = state.copyWith(
        batteryOptimization: const AppPermissionGranted(),
      );
    }
  }

  void refresh() => _initialize();

  bool get isComplete =>
      state.media is AppPermissionGranted &&
      state.notifications is AppPermissionGranted;
}
