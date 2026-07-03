# Changelog

All notable changes to BITOO are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Initial project scaffold with Feature-First Clean Architecture
- Local audio file scanning with recursive directory walk
- Metadata extraction (ID3 tags + filename-based fallback)
- Hive database persistence for songs, albums, artists, genres, playlists
- Audio playback engine with play/pause, seek, volume, sleep timer
- Hi-Res Audio support via native Android `AudioTrack` API
- 10-band equalizer with presets (Rock, Pop, Jazz, Classical, Dance, Hip-Hop, R&B, Custom)
- Tempo/pitch control (0.5x–2.0x) with independent pitch shifting
- Loudness normalization (EBU R128 / LUFS target -14)
- Crossfade and gapless playback support
- Fullscreen player with album art (standard/vinyl/visualizer modes)
- Glassmorphism UI with dark theme
- Permission onboarding flow (audio, storage, notifications, Bluetooth, battery)
- Mini-player bar with persistent playback controls
- Search with full-text indexing and relevance ranking
- Artwork caching with automated orphan cleanup
- Playlist management (create, rename, reorder, delete)
- Favorites and recently played tracking
- Flutter analysis with strict lint ruleset
