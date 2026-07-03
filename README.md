# BITOO — Premium Local Music Player

[![Flutter](https://img.shields.io/badge/Flutter-3.6+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/Omar-khecharem/Bitoo/actions/workflows/ci.yml/badge.svg)](https://github.com/Omar-khecharem/Bitoo/actions/workflows/ci.yml)

BITOO is a **high-performance local music player** for Android, built with Flutter. It scans your device for audio files, reads rich metadata, and delivers a premium, gesture-driven listening experience — all offline.

---

## ✨ Features

- **Local Music Scanning** — Recursively scans device storage for audio files (MP3, FLAC, M4A, WAV, OGG, AAC, WMA, OPUS, AIFF, ALAC, DSF, DFF).
- **Rich Metadata Extraction** — Reads ID3 tags (title, artist, album, artwork) with intelligent filename-based fallback.
- **Premium UI** — Glassmorphism design, animated album art (standard/vinyl/visualizer modes), fluid transitions, dark theme.
- **Full-featured Player** — Play/pause, seek, volume control, sleep timer, queue management, lyrics view.
- **Audio Engine** — 10-band equalizer with presets, tempo/pitch control, loudness normalization (EBU R128 / LUFS), crossfade, gapless playback.
- **Hi-Res Audio Support** — Native Android Hi-Res Audio track API for lossless playback (DSF, DFF, FLAC, ALAC, WAV, AIFF).
- **Smart Organization** — Browse by songs, albums, artists, genres, favorites, recently played, most played.
- **Search** — Full-text search across title, artist, and album with relevance ranking.
- **Playlists** — Create, rename, reorder, and manage custom playlists.
- **Permissions** — Graceful Android permission flow (audio, storage, notifications, Bluetooth, battery optimization).

---

## 📱 Screenshots

> _Screenshots to be added._

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.6.1`
- Dart SDK `^3.6.1`
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

```bash
# Clone the repository
git clone https://github.com/Omar-khecharem/Bitoo.git
cd Bitoo

# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

---

## 🏗 Architecture

BITOO follows **Feature-First Clean Architecture** — each feature is an independent vertical slice with three layers:

```
feature/
├── data/           # Repositories, datasources, DTOs, database (Hive)
├── domain/         # Entities, repository interfaces, services
└── presentation/   # Providers (Riverpod), pages, widgets
```

| Layer | Responsibility |
|-------|---------------|
| **Presentation** | Riverpod state management, UI pages & widgets |
| **Domain** | Business logic, entities, repository contracts |
| **Data** | Hive persistence, file scanning, metadata extraction |

For detailed architecture documentation, see [`ARCHITECTURE.md`](ARCHITECTURE.md) and [`ADVANCED_ARCHITECTURE.md`](ADVANCED_ARCHITECTURE.md).

---

## 🧩 Tech Stack

| Category | Choice |
|----------|--------|
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Database** | Hive (local NoSQL) |
| **Audio Playback** | `just_audio` + `audio_service` |
| **Audio Engine** | Custom 10-band EQ, tempo/pitch, LUFS normalization |
| **Metadata** | `audio_metadata_reader` |
| **Networking** | Dio |
| **Code Generation** | `build_runner`, `json_serializable` |
| **Linting** | `flutter_lints` (strict ruleset) |

---

## 📂 Project Structure

```
lib/
├── app.dart                          # App shell, permission flow, mini-player
├── main.dart                         # Entry point
├── core/
│   ├── theme/                        # Design tokens, color schemes, typography
│   └── animations/                   # Shared animation constants & durations
├── shared/
│   ├── widgets/                      # Reusable UI components
│   └── animations/                   # Shared animation widgets
└── features/
    ├── audio_engine/                 # 10-band EQ, presets, audio processing
    ├── home/                         # Home feed, song listing
    ├── music_engine/                 # File scanning, metadata, database
    ├── permissions/                  # Permission onboarding & requests
    └── player/                       # Fullscreen player, controls, queue
```

---

## 🛠 Development

### Code Style

BITOO enforces a strict Dart style guide. See [`CODING_STANDARDS.md`](CODING_STANDARDS.md).

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Build Variants

```bash
# Debug APK
flutter build apk --debug

# Release APK (split per ABI)
flutter build apk --release --split-per-abi

# App Bundle
flutter build appbundle --release
```

---

## 🤝 Contributing

Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

---

## 📄 License

This project is licensed under the MIT License — see the [`LICENSE`](LICENSE) file for details.

---

## 🔒 Security

Report vulnerabilities to **khcharem.omar@gmail.com**. See [`SECURITY.md`](SECURITY.md) for details.

---

## 🙏 Acknowledgments

- `just_audio` team for the excellent audio playback library
- Riverpod team for state management
- Hive team for the lightweight NoSQL database
