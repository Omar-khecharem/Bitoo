class PermissionLabels {
  static const media = PermissionInfo(
    icon: '🎵',
    title: 'Access Your Music Library',
    description:
        'BITOO reads your music files to play your local collection. '
        'We never upload or share your music.',
    grantLabel: 'Grant Access',
    rationaleTitle: 'Music Access Required',
    rationaleDescription:
        'BITOO needs access to your music library to play your songs. '
        'This permission only reads audio files — no other files are accessed.',
    permanentlyDeniedTitle: 'Permission Required',
    permanentlyDeniedDescription:
        'BITOO needs music access to play your songs. '
        'Please enable it in your device settings.',
  );

  static const notifications = PermissionInfo(
    icon: '🔔',
    title: 'Show Playback Controls',
    description:
        'Control BITOO from your notification shade and lock screen. '
        'See what\'s playing without opening the app.',
    grantLabel: 'Allow Notifications',
    rationaleTitle: 'Notifications Required',
    rationaleDescription:
        'Notifications let you control playback from the lock screen '
        'and notification shade without opening the app.',
    permanentlyDeniedTitle: 'Notifications Disabled',
    permanentlyDeniedDescription:
        'Please enable notifications in your device settings to see '
        'playback controls on your lock screen.',
  );

  static const bluetooth = PermissionInfo(
    icon: '🛜',
    title: 'Wireless Audio Controls',
    description:
        'Control playback from your Bluetooth headphones, car stereo, '
        'or smartwatch. Optional — you can enable this later.',
    grantLabel: 'Enable Bluetooth',
    rationaleTitle: 'Bluetooth Access',
    rationaleDescription:
        'BITOO needs Bluetooth permission to respond to play, pause, '
        'and skip buttons on your wireless devices.',
    permanentlyDeniedTitle: 'Bluetooth Disabled',
    permanentlyDeniedDescription:
        'Please enable Bluetooth permission in your device settings '
        'to use wireless audio controls.',
  );

  static const battery = PermissionInfo(
    icon: '🔋',
    title: 'Optimize for Playback',
    description:
        'Prevent BITOO from being paused when your device enters '
        'battery saving mode. Optional.',
    grantLabel: 'Open Settings',
    rationaleTitle: 'Battery Optimization',
    rationaleDescription:
        'Disabling battery optimization helps BITOO play music '
        'uninterrupted, even when your phone is in sleep mode.',
    permanentlyDeniedTitle: '',
    permanentlyDeniedDescription: '',
  );
}

class PermissionInfo {
  final String icon;
  final String title;
  final String description;
  final String grantLabel;
  final String rationaleTitle;
  final String rationaleDescription;
  final String permanentlyDeniedTitle;
  final String permanentlyDeniedDescription;

  const PermissionInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.grantLabel,
    required this.rationaleTitle,
    required this.rationaleDescription,
    required this.permanentlyDeniedTitle,
    required this.permanentlyDeniedDescription,
  });
}
