sealed class AppPermissionStatus {
  const AppPermissionStatus();
}

class AppPermissionGranted extends AppPermissionStatus {
  const AppPermissionGranted();
}

class AppPermissionDenied extends AppPermissionStatus {
  const AppPermissionDenied();
}

class AppPermissionPermanentlyDenied extends AppPermissionStatus {
  const AppPermissionPermanentlyDenied();
}

class AppPermissionRationaleRequired extends AppPermissionStatus {
  const AppPermissionRationaleRequired();
}

class AllPermissionsState {
  final AppPermissionStatus media;
  final AppPermissionStatus notifications;
  final AppPermissionStatus bluetooth;
  final AppPermissionStatus batteryOptimization;

  const AllPermissionsState({
    this.media = const AppPermissionDenied(),
    this.notifications = const AppPermissionDenied(),
    this.bluetooth = const AppPermissionDenied(),
    this.batteryOptimization = const AppPermissionDenied(),
  });

  bool get isComplete =>
      media is AppPermissionGranted && notifications is AppPermissionGranted;

  bool get mediaGranted => media is AppPermissionGranted;

  AllPermissionsState copyWith({
    AppPermissionStatus? media,
    AppPermissionStatus? notifications,
    AppPermissionStatus? bluetooth,
    AppPermissionStatus? batteryOptimization,
  }) {
    return AllPermissionsState(
      media: media ?? this.media,
      notifications: notifications ?? this.notifications,
      bluetooth: bluetooth ?? this.bluetooth,
      batteryOptimization: batteryOptimization ?? this.batteryOptimization,
    );
  }
}
