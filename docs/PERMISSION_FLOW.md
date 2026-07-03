# BITOO Android Permission Flow

> Google Play compliance · User trust · Beautiful UX

---

##  Permission Inventory

| Permission | API Level | Purpose | Required? | Google Play Policy |
|-----------|-----------|---------|-----------|-------------------|
| `READ_MEDIA_AUDIO` | 33+ | Scan local music files | Yes | Must use **granular media permission** (not `READ_EXTERNAL_STORAGE`) on 13+ |
| `READ_EXTERNAL_STORAGE` | 1-32 | Scan local music files | Yes | `maxSdkVersion="32"` — never request on 13+ |
| `POST_NOTIFICATIONS` | 33+ | Media playback notification | Yes | **Must** request for foreground service notification |
| `BLUETOOTH_CONNECT` | 31+ | Bluetooth AVRCP controls (wireless) | No | Request only if user wants Bluetooth features |
| `FOREGROUND_SERVICE` | 28+ | Background audio playback | Yes | `android:foregroundServiceType="mediaPlayback"` |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | 34+ | Media playback FG service type | Yes | Android 14 requires declaring service type |
| `WAKE_LOCK` | 1+ | Keep CPU awake during playback | Yes | Automatic with `MediaPlayer` — no UI prompt needed |
| `BATTERY_OPTIMIZATIONS` | 23+ | Ignore battery saver | No | **Cannot** request directly — open Settings intent |

---

##  Permission Flow Diagram

```
App Launch
    │
    ├── First Launch? ──► WelcomeScreen (explain why)
    │                          │
    │                          ▼
    │                    Permission Introduction
    │                    (beautiful explainer cards)
    │                          │
    │                          ▼
    │                    Step 1: Media Permission
    │                    ─────────────────────────
    │                    "Access your music library"
    │                    ┌──────────────────────┐
    │                    │  BITOO needs access   │
    │                    │  to your music files  │
    │                    │  to play your local   │
    │                    │  collection.          │
    │                    │                       │
    │                    │  [Grant Access]       │
    │                    │  [Not Now]            │
    │                    └──────────────────────┘
    │                          │
    │                    ┌─────┴──────┐
    │                    │            │
    │                Granted        Denied
    │                    │            │
    │                    │     Show Rationale
    │                    │     ┌────────────────┐
    │                    │     │ Music scanning  │
    │                    │     │ requires access │
    │                    │     │ to audio files. │
    │                    │     │ [OK, Try Again] │
    │                    │     └────────────────┘
    │                    │            │
    │                    │      ┌─────┴──────┐
    │                    │      │            │
    │                    │   Granted    Perm. Denied
    │                    │               │
    │                    │        ┌──────▼──────┐
    │                    │        │ Open Settings│
    │                    │        │ to enable   │
    │                    │        │ manually    │
    │                    │        └─────────────┘
    │                    │               │
    │                    │          (skip to next)
    │                    ▼               │
    │               Step 2: Notifications │
    │               ───────────────────── │
    │               "Show playback controls"│
    │                      ...            │
    │                    │               │
    │                    ▼               │
    │               Step 3: Bluetooth (optional) │
    │                      ...            │
    │                    │               │
    │                    ▼               │
    │               Step 4: Battery Optimization │
    │                      ...            │
    │                    │               │
    │                    ▼               │
    │               Setup Complete ───────┘
    │                    │
    │                    ▼
    │               Home Screen (music scanning begins)
    │
    └── Returning User ──► Check granted status
                                │
                          ┌─────┴─────┐
                          │           │
                      All Granted   Missing
                          │           │
                          │     Show Status Card
                          │     (non-blocking banner)
                          │     "Enable X in Settings"
                          │
                          ▼           ▼
                      Home Screen ◄────┘
```

---

##  Google Play Compliance Notes

### 1. Granular Media Permission (Android 13+)

```
REQUIRED by Google Play policy (2023+):
  ❌ DO NOT request READ_EXTERNAL_STORAGE on Android 13+
  ✅ MUST request READ_MEDIA_AUDIO

Implementation:
  <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
      android:maxSdkVersion="32" />
```

### 2. Permission Justification

```
Google Play requires:
  1. A user-facing explanation WHY each permission is needed
  2. Request must be made IN CONTEXT (not at first launch splash)
  3. Users must be able to continue without granting

BITOO compliance:
  ✅ Welcome screen explains value before requesting
  ✅ Each permission has a dedicated explainer card
  ✅ "Not Now" skips permission — app works with limited functionality
  ✅ Rationale dialog re-explains if user denies
```

### 3. Foreground Service Declaration

```xml
<!-- Android 14 requires explicit service type -->
<service
    android:name=".MusicPlaybackService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</service>

<!-- Foreground service notification (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 4. Battery Optimization Exception

```
Policy:
  - CANNOT request REQUEST_IGNORE_BATTERY_OPTIMIZATIONS directly
  - MUST open Settings intent and let user toggle

Implementation:
  if (batteryOptimizationsEnabled) {
    launchAppSettings();  // Opens battery optimization page
    // User manually disables optimization
  }
```

---

##  Permission Grouping Strategy

| Group | Permissions | Request Timing | UX Pattern |
|-------|-------------|----------------|------------|
| **Required** | `READ_MEDIA_AUDIO`, `POST_NOTIFICATIONS` | First launch flow | Full-screen explainer → request |
| **Playback** | `FOREGROUND_SERVICE`, `WAKE_LOCK` | Manifest-declared | No UI needed (auto-granted) |
| **Bluetooth** | `BLUETOOTH_CONNECT` | On first Bluetooth device connect | Snackbar: "Allow Bluetooth controls?" |
| **Battery** | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Settings page | Tile: "Optimize for playback" → opens Settings |

---

##  Permission Status State Machine

```
                   ┌─────────────┐
                   │   Unknown   │
                   └──────┬──────┘
                          │
                    Check Status
                          │
              ┌───────────┴───────────┐
              │                       │
          ┌───▼────┐           ┌──────▼──────┐
          │ Granted │           │  Denied      │
          └───┬────┘           └──────┬──────┘
              │                       │
        (no action)            Should Show
                               Rationale?
                                   │
                          ┌────────┴────────┐
                          │                 │
                    ┌─────▼─────┐    ┌──────▼──────┐
                    │ Yes        │    │ Permanently  │
                    │ (show once)│    │ Denied       │
                    └─────┬─────┘    └──────┬──────┘
                          │                 │
                    Request Again      Open Settings
                          │                 │
                    ┌─────┴─────┐           │
                    │           │           │
                Granted    Denied           │
                    │       (loop)          │
                    ▼                       ▼
              PermissionState.granted  PermissionState.denied
```

---

##  User-Facing Permission Cards Design

Each permission is presented as a **glass card** (12dp radius, 10% white,
20px blur) with:

```
┌──────────────────────────────────────────────────────────┐
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │  🎵  Access Your Music Library                    │    │
│  │                                                   │    │
│  │  BITOO reads your music files to play your        │    │
│  │  local collection. We never upload or share       │    │
│  │  your music.                                      │    │
│  │                                                   │    │
│  │  [  Grant Access  ]   Skip for now                │    │
│  └──────────────────────────────────────────────────┘    │
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │  🔔  Show Playback Controls                      │    │
│  │  (same pattern)                                  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │  🛜  Wireless Audio Controls                     │    │
│  │  (optional, same pattern)                        │    │
│  └──────────────────────────────────────────────────┘    │
│                                                           │
│                                     [  Get Started  ]    │
│                                                           │
└──────────────────────────────────────────────────────────┘

Status indicator per card:
  ● Not requested (white)
  ✓ Granted (green)
  ✗ Denied (red)
  ⚠ Permanently denied (amber) → "Open Settings"
```

---

##  Rationale Dialog Design

```dart
// When user denies a permission, show this glass dialog:

PremiumDialog.show(
  context: context,
  icon: Icons.info_rounded,
  title: 'Music Access Required',
  description: 'BITOO needs access to your music library to '
      'play your songs. This permission only reads audio files — '
      'no other files are accessed.',
  confirmLabel: 'Try Again',
  cancelLabel: 'Skip',
  onConfirm: () => requestPermission(),
  onCancel: () => Navigator.pop(),
);
```

##  Permanently Denied Dialog Design

```dart
// When user has permanently denied (checked "Don't ask again"):

PremiumDialog.show(
  context: context,
  icon: Icons.settings_rounded,
  title: 'Permission Required',
  description: 'BITOO needs music access to play your songs. '
      'Please enable it in your device settings.',
  confirmLabel: 'Open Settings',
  cancelLabel: 'Not Now',
  onConfirm: () => openAppSettings(),
  onCancel: () {},
);
```

---

##  File Architecture

```
lib/features/permissions/
├── data/
│   └── datasources/
│       └── permission_datasource.dart        # Thin wrapper over permission_handler
│
├── domain/
│   ├── entities/
│   │   └── permission_state.dart             # Sealed class: granted/denied/deniedPermanently
│   └── services/
│       └── permission_service.dart           # Orchestrates all permission logic
│
├── presentation/
│   ├── pages/
│   │   ├── permission_welcome_page.dart      # Welcome + explainer flow
│   │   └── permission_request_page.dart      # Step-by-step permission cards
│   ├── widgets/
│   │   ├── permission_card.dart              # Glass card with status indicator
│   │   └── permission_status_banner.dart     # Non-blocking banner for returning users
│   └── providers/
│       └── permission_provider.dart          # StateNotifier for permission flow
│
└── core/
    └── permission_constants.dart             # Permission groups, labels, descriptions
```

---

##  Integration with App Startup

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService.initialize();

  runApp(
    ProviderScope(
      child: BitooApp(),
    ),
  );
}

// app.dart — determines initial route
@riverpod
String initialRoute(Ref ref) {
  final permissionState = ref.watch(permissionProvider);
  final hasCompletedOnboarding = ref.watch(onboardingProvider);

  if (!hasCompletedOnboarding) return '/onboarding';
  if (!permissionState.isComplete) return '/permissions';
  return '/home';
}

// GoRouter redirect
GoRouter(
  redirect: (context, state) {
    final permissions = ref.read(permissionProvider);
    if (!permissions.mediaGranted && state.uri.toString() != '/permissions') {
      return '/permissions';
    }
    return null;
  },
);
```
