# BITOO Local Music Engine Architecture

> A production-grade offline music scanning, indexing, and metadata engine.

---

##  Package Selection & Rationale

| Package | Version | Purpose | Why this over alternatives |
|---------|---------|---------|--------------------------|
| `isar` | ^3.1.0+ | Local object database | **10x faster than Hive** for complex queries. Supports `where` indexes, full-text search, auto-computed indexes. Native C++ engine = zero jank on scan. The only Flutter DB with built-in full-text search. |
| `isar_flutter_libs` | ^3.1.0 | Isar native libs | Ships the Isar core as shared libs. Required by Isar. |
| `permission_handler` | ^11.3.0 | Runtime permissions | Most mature permissions library. Handles Android 13+ granular media permissions (`READ_MEDIA_AUDIO`) and legacy `READ_EXTERNAL_STORAGE`. |
| `audio_metadata_reader` | ^0.4.0 | ID3/MP4/FLAC metadata | **Cross-platform** (Android + iOS). Reads ID3v1, ID3v2, Vorbis comments, MP4 metadata. Extracts embedded album art. No FFmpeg dependency needed. |
| `path_provider` | ^2.1.0 | Standard directories | Returns external storage, cache, temp dirs. Needed for scan root paths. |
| `path` | ^1.9.0 | Path manipulation | `p.join()`, `p.extension()`, `p.basename()`. Zero-overhead string operations. |
| `mime` | ^1.0.5 | MIME type detection | `lookupMimeType()` maps file extensions to audio/* types. Faster than reading file headers for filtering. |
| `crypto` | ^3.0.3 | SHA-256 hashing | **Deduplication** — hash file content (or path) to detect duplicates before DB insert. |
| `image_picker` | ^1.0.0 | Artwork display | For cached album art thumbnails. |
| `cached_network_image` | ^3.3.0 | Image caching | Disk + memory cache layer for album art (local URIs cached like network). |
| `rxdart` | ^0.28.0 | Reactive streams | `combineLatest`, `debounce`, `switchMap` for real-time search-as-you-type. |
| `collection` | ^1.18.0 | Grouping | `groupBy` for organizing songs into albums/artists/genres. |
| `ffmpeg_kit_flutter_full` | ^6.0.3 | Audio processing | **Optional** — for audio analysis (BPM, waveform data), format conversion, transcoding. Not loaded at scan time; only when effects panel opens. |
| `wakelock_plus` | ^1.2.0 | Prevent sleep during scan | Keeps device awake during initial full scan. Released on completion. |

### Package Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Music Engine Packages                          │
├───────────────────┬──────────────────────┬──────────────────────────┤
│   DATA LAYER      │   DOMAIN LAYER       │   PRESENTATION           │
│                   │                       │                          │
│ isar              │ (pure Dart —        │ flutter_riverpod         │
│ permission_handler│  no packages)        │ cached_network_image     │
│ audio_metadata    │                       │                          │
│ _reader           │                       │                          │
│ path              │                       │                          │
│ mime              │                       │                          │
│ crypto            │                       │                          │
│ rxdart            │                       │                          │
└───────────────────┴──────────────────────┴──────────────────────────┘
```

---

##  Data Flow

```
User opens app
      │
      ▼
PermissionService.request()
      │
      ├── Granted ──► MusicScanner.scan()
      │                    │
      │                    ├── Walk file tree (recursive)
      │                    │     ├── Skip hidden dirs (., node_modules, etc.)
      │                    │     ├── Filter by extension (.mp3, .flac, .m4a, .wav, .ogg)
      │                    │     └── Skip corrupted files (try/catch on read)
      │                    │
      │                    ├── For each valid file:
      │                    │     ├── Extract metadata (audio_metadata_reader)
      │                    │     ├── Calculate SHA-256 (dedup check)
      │                    │     ├── Parse album art (save to cache)
      │                    │     └── Write to Isar database
      │                    │
      │                    ├── Build indexes:
      │                    │     ├── album_index (sorted by album name)
      │                    │     ├── artist_index (sorted by artist name)
      │                    │     ├── genre_index
      │                    │     ├── folder_index
      │                    │     └── full-text search index (fTS)
      │                    │
      │                    └── Emit progress stream (rxdart Subject)
      │
      ├── Denied ──► Show rationale dialog
      │                  │
      │                  └── Retry / Open Settings
      │
      └── Permanent Deny ──► Navigate to Settings

User searches:
      │
      ▼
SearchProvider.query("beat")
      │
      ├── FTS on songs: title, artist, album
      ├── FTS on albums: title, artist
      ├── FTS on artists: name
      └── Combine results → sort by relevance (Levenshtein distance)
```

---

##  Database Schema (Isar)

```dart
@collection
class Song {
  Id id = Isar.autoIncrement;           // Auto-generated
  late String filePath;                  // Unique — absolute path
  late String sha256;                    // For dedup, indexed
  late String title;                     // From ID3 tag or filename
  late String artist;                    // From ID3 tag or "Unknown Artist"
  late String albumTitle;                // From ID3 tag or "Unknown Album"
  late String? albumArtist;              // Album artist (compilations)
  late int? trackNumber;                 // ID3 track number
  late int? discNumber;                  // ID3 disc number
  late int? year;                        // ID3 year
  late String? genre;                    // ID3 genre
  late int durationMs;                   // Duration in milliseconds
  late int bitrate;                      // Bitrate in kbps
  late int sampleRate;                   // Sample rate in Hz
  late String? artworkPath;              // Path to cached album art
  late bool? hasArtwork;                 // Quick check without file IO
  late String fileExtension;             // .mp3, .flac, etc.
  late int fileSize;                     // Bytes
  late DateTime dateAdded;               // When first scanned
  late DateTime dateModified;            // File last modified
  late DateTime? lastPlayed;             // For recently played
  late int playCount;                    // For "most played"
  late bool isFavorite;                  // User favorite
  late bool isCorrupted;                 // Marked if metadata parse failed

  // Indexes
  @Index()
  late String artistIndex;              // Lowercase for search

  @Index()
  late String albumIndex;               // Lowercase for search

  @Index()
  late String titleIndex;               // Lowercase for search

  @Index()
  late String? genreIndex;              // Lowercase for search

  @Index(type: IndexType.value)
  late bool favoriteIndex;              // For quick favorites query

  @Index(type: IndexType.value)
  late DateTime? lastPlayedIndex;       // For recently played sort

  // Full-text search
  @Index(type: IndexType.fullText)
  late String searchIndex;              // Combined: title + artist + album
}

@collection
class Album {
  Id id = Isar.autoIncrement;
  late String title;
  late String artist;                    // Album artist
  late int? year;
  late String? genre;
  late int songCount;
  late int totalDurationMs;
  late String? artworkPath;              // First song's artwork
  late DateTime dateAdded;

  @Index()
  late String titleIndex;

  @Index(type: IndexType.fullText)
  late String searchIndex;
}

@collection
class Artist {
  Id id = Isar.autoIncrement;
  late String name;
  late int albumCount;
  late int songCount;
  late int totalDurationMs;
  late String? artworkPath;              // Most-representative album art
  late DateTime dateAdded;

  @Index()
  late String nameIndex;

  @Index(type: IndexType.fullText)
  late String searchIndex;
}

@collection
class Genre {
  Id id = Isar.autoIncrement;
  late String name;
  late int songCount;
  late int albumCount;
  late DateTime dateAdded;

  @Index()
  late String nameIndex;
}

@collection
class Playlist {
  Id id = Isar.autoIncrement;
  late String name;
  late String? description;
  late String? artworkUri;               // Custom or from first song
  late List<String> songPaths;           // Ordered list of file paths
  late int songCount;
  late int totalDurationMs;
  late bool isSmartPlaylist;             // Auto-generated (recently added, etc.)
  late DateTime dateCreated;
  late DateTime dateModified;

  @Index(type: IndexType.fullText)
  late String searchIndex;
}

@collection
class ScanMetadata {
  Id id = Isar.autoIncrement;
  late DateTime lastScanTimestamp;
  late int totalSongs;
  late int totalAlbums;
  late int totalArtists;
  late int totalGenres;
  late double scanDurationSeconds;
  late int corruptedFiles;
  late int skippedFiles;
  late String? lastScanError;
}
```

---

##  Folder Architecture

```
lib/features/music_engine/
├── data/
│   ├── datasources/
│   │   ├── file_scanner_datasource.dart     # Recursive filesystem walker
│   │   ├── metadata_datasource.dart         # audio_metadata_reader wrapper
│   │   ├── artwork_cache_datasource.dart    # Extract + cache album art to disk
│   │   └── permission_datasource.dart       # Android permission abstraction
│   │
│   ├── models/
│   │   └── scan_progress.dart               # Stream state: filesScanned, total, currentFile
│   │
│   ├── database/
│   │   └── isar_database.dart               # Isar instance + collection registration
│   │
│   └── repositories/
│       └── music_repository_impl.dart       # Concrete implementation
│
├── domain/
│   ├── entities/                            (generated by Isar)
│   ├── repositories/
│   │   └── music_repository.dart            # Abstract interface
│   └── usecases/
│       ├── scan_music.dart
│       ├── get_songs.dart
│       ├── get_albums.dart
│       ├── get_artists.dart
│       ├── get_genres.dart
│       ├── search_music.dart
│       ├── get_favorites.dart
│       ├── toggle_favorite.dart
│       ├── add_recently_played.dart
│       ├── get_recently_played.dart
│       ├── create_playlist.dart
│       ├── delete_playlist.dart
│       ├── rename_playlist.dart
│       ├── add_song_to_playlist.dart
│       ├── remove_song_from_playlist.dart
│       ├── reorder_playlist.dart
│       └── get_storage_stats.dart
│
├── presentation/
│   └── providers/
│       ├── music_engine_provider.dart        # Main state: scan progress, counts
│       ├── song_list_provider.dart           # All songs with sort/filter
│       ├── album_list_provider.dart          # All albums
│       ├── artist_list_provider.dart         # All artists
│       ├── genre_list_provider.dart          # All genres
│       ├── search_provider.dart              # Search-as-you-type (debounced)
│       ├── playlist_provider.dart            # Playlists CRUD
│       ├── favorite_provider.dart            # Favorites
│       └── recently_played_provider.dart     # Recently played
│
├── services/
│   ├── scan_service.dart                     # Android ForegroundService for scan
│   ├── media_store_sync.dart                 # Optional: Android MediaStore bridge
│   └── file_watcher_service.dart             # Optional: inotify for auto-rescan
│
└── core/
    ├── audio_extensions.dart                 # List of supported extensions
    ├── file_filters.dart                     # Hidden folder detection
    ├── path_normalizer.dart                  # Resolve symlinks, normalize case
    └── string_similarity.dart                # Fuzzy search ranking
```

---

##  Scanning Pipeline (Step by Step)

```
Phase 1: Permission
  ┌──────────────────────────────────────────────┐
  │ PermissionDataSource.requestAudioPermission() │
  │  → Returns bool                                │
  │  → On permanent deny: opens App Settings       │
  └──────────────────────────────────────────────┘

Phase 2: Discovery
  ┌──────────────────────────────────────────────┐
  │ FileScannerDataSource.findAudioFiles(root)   │
  │  → Recursive directory walk                   │
  │  → Skip hidden dirs (starts with ., __, node) │
  │  → Filter: .mp3 .flac .m4a .wav .ogg .aac    │
  │  → Yield each valid file path                  │
  │  → Emit progress: (filesScanned, currentPath)  │
  └──────────────────────────────────────────────┘

Phase 3: Metadata Extraction
  ┌──────────────────────────────────────────────┐
  │ MetadataDataSource.extract(filePath)          │
  │  → audio_metadata_reader.readMetadataFrom()    │
  │  → Parse ID3v1/v2, Vorbis, MP4 atoms          │
  │  → Fallback: parse filename for title          │
  │  → Return AudioMetadata or null (corrupted)   │
  │  → On exception: mark corrupted, continue     │
  └──────────────────────────────────────────────┘

Phase 4: Deduplication
  ┌──────────────────────────────────────────────┐
  │ Song existing = isar.songs.where(             │
  │   sha256: sha256                               │
  │ ).findFirst()                                  │
  │ → If exists: skip (update dateModified only)  │
  │ → If new: insert                               │
  └──────────────────────────────────────────────┘

Phase 5: Indexing
  ┌──────────────────────────────────────────────┐
  │ After batch insert:                           │
  │ 1. Query all songs                            │
  │ 2. groupBy(albumTitle) → Album collection     │
  │ 3. groupBy(artist) → Artist collection        │
  │ 4. groupBy(genre) → Genre collection          │
  │ 5. Upsert into Isar collections               │
  └──────────────────────────────────────────────┘

Phase 6: Cleanup
  ┌──────────────────────────────────────────────┐
  │ Remove songs whose filePath no longer exists  │
  │ Clean orphaned albums (0 songs)              │
  │ Clean orphaned artists (0 songs)             │
  │ Update ScanMetadata with timestamp + stats   │
  └──────────────────────────────────────────────┘
```

---

##  Search Engine Design

```dart
class MusicSearchEngine {
  // Index: Isar full-text search index on searchIndex fields
  // searchIndex = "${title} ${artist} ${albumTitle}".toLowerCase()

  Future<List<Song>> search(String query) async {
    final terms = query.toLowerCase().split(RegExp(r'\s+'));

    // 1. Full-text search (fastest)
    final ftsResults = await isar.songs
        .where()
        .searchIndexMatchesAny(terms)
        .findAll();

    // 2. Prefix match on individual indexes
    final titleResults = await isar.songs
        .where()
        .titleIndexStartsWith(query.toLowerCase())
        .findAll();

    final artistResults = await isar.songs
        .where()
        .artistIndexStartsWith(query.toLowerCase())
        .findAll();

    final albumResults = await isar.songs
        .where()
        .albumIndexStartsWith(query.toLowerCase())
        .findAll();

    // 3. Merge + rank
    final merged = <Song>{}
      ..addAll(ftsResults)
      ..addAll(titleResults)
      ..addAll(artistResults)
      ..addAll(albumResults);

    return merged.toList()
      ..sort((a, b) => _rank(query, b).compareTo(_rank(query, a)));
  }

  double _rank(String query, Song song) {
    double score = 0;
    final q = query.toLowerCase();

    // Exact title match = highest score
    if (song.title.toLowerCase() == q) score += 100;
    else if (song.title.toLowerCase().startsWith(q)) score += 80;
    else if (song.title.toLowerCase().contains(q)) score += 50;

    // Artist match
    if (song.artist.toLowerCase().startsWith(q)) score += 60;
    else if (song.artist.toLowerCase().contains(q)) score += 30;

    // Album match
    if (song.albumTitle.toLowerCase().startsWith(q)) score += 40;
    else if (song.albumTitle.toLowerCase().contains(q)) score += 20;

    // Play count boost (popular songs rank higher)
    score += log(song.playCount + 1) * 5;

    return score;
  }
}
```

---

##  Background Scan Service

```dart
class ScanService {
  // 1. Platform channel triggers Android Foreground Service
  //    Notification: "BITOO is scanning your music..."
  //    Progressive: "342 songs found..."
  //
  // 2. Service runs in its own Isolate (compute isolate)
  //    → main isolate remains responsive for UI
  //    → Isar supports multi-isolate access
  //
  // 3. On completion:
  //    → Post notification: "Scan complete — 1,234 songs"
  //    → Update ScanMetadata in database
  //    → Kill foreground service
  //
  // 4. Incremental scans (subsequent launches):
  //    → Compare lastScanTimestamp with file dateModified
  //    → Only process new/modified files
  //    → Typical: < 3 seconds for 1,000 files
  //
  // 5. Full re-scan: User-initiated via Settings
}

// Android Manifest additions:
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
// <service android:name="com.bitoo.ScanService"
//     android:foregroundServiceType="dataSync"
//     android:exported="false" />
```

---

##  Cache Strategy

### Album Art Cache

```dart
// On metadata extraction:
//  1. Read embedded artwork bytes from audio_metadata_reader
//  2. Resize to 512x512 (saves 80% space vs full resolution)
//  3. Save as JPEG (quality 85) to: getApplicationCacheDirectory()/artwork/{sha256}.jpg
//  4. Store path in Song.artworkPath
//
// On display:
//  → Image.file(File(artworkPath))
//  → Falls back to gradient placeholder
//
// Cleanup:
//  → On re-scan: delete artwork files whose song no longer exists
//  → Max cache: 500MB (configurable in Settings)
//  → LRU eviction: track last-access timestamps
```

### Search Cache

```dart
// Recent searches (last 20):
//  → Store in Isar ScanMetadata as JSON list
//
// Search results:
//  → NOT cached (database query is already < 5ms with indexes)
//  → Debounce: 300ms before executing query (avoid mid-type flashes)
```

### Scan Cache

```dart
// On first scan:
//  1. Store SHA-256 + file modification date for every file
//  2. On subsequent scans:
//     → Walk filesystem
//     → Check if (sha256 exists AND dateModified unchanged) => skip
//     → Only process new/modified files
//  3. Full path index: HashMap<String, bool> (10MB for 10,000 files)
```

---

##  Storage Optimization

```dart
class StorageOptimizer {
  /// Returns stats for Settings screen
  StorageStats getStats() {
    final dbSize = File(isarPath).lengthSync();
    final artworkSize = _getDirectorySize(artworkCachePath);
    return StorageStats(
      databaseSize: dbSize,           // Typically 2-5 MB for 10k songs
      artworkCacheSize: artworkSize,  // Typically 50-200 MB
      totalSongs: songCount,
      totalDuration: totalDuration,
      lastScan: lastScanTimestamp,
    );
  }

  /// Clean up orphaned database entries
  Future<int> cleanOrphanedEntries() async {
    final allSongs = await isar.songs.where().findAll();
    int removed = 0;
    for (final song in allSongs) {
      if (!File(song.filePath).existsSync()) {
        await isar.writeTxn(() => isar.songs.delete(song.id));
        removed++;
      }
    }
    return removed;  // Return count for user feedback
  }

  /// Clear artwork cache
  Future<void> clearArtworkCache() async {
    final dir = Directory(artworkCachePath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
  }

  /// Full vacuum (compact Isar database)
  Future<void> vacuumDatabase() async {
    await isar.writeTxn(() => isar.songs.clear());  // Rebuild
  }
}
```

---

##  Permission Handling — Android 13+

```dart
class PermissionDataSource {
  /// Minimal required permissions by Android version:
  ///
  /// Android 10 (API 29) and below:
  ///   READ_EXTERNAL_STORAGE
  ///
  /// Android 11-12 (API 30-32):
  ///   READ_EXTERNAL_STORAGE (still works with scoped storage)
  ///   MANAGER_EXTERNAL_STORAGE (for full file access — optional)
  ///
  /// Android 13+ (API 33+):
  ///   READ_MEDIA_AUDIO (granular — only audio files)
  ///   No READ_EXTERNAL_STORAGE needed
  ///
  /// Android 14 (API 34):
  ///   READ_MEDIA_AUDIO (unchanged from 13)
  ///   Foreground service type: dataSync (for background scan)

  Future<bool> requestAudioPermission() async {
    if (await _isAndroid13OrAbove()) {
      return _requestGranularMediaPermission();
    }
    return _requestLegacyStoragePermission();
  }

  Future<bool> _requestGranularMediaPermission() async {
    // Android 13+: only request audio — not photos or video
    final status = await Permission.audio.request();
    return status.isGranted;
  }

  Future<bool> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }
}

// AndroidManifest.xml:
// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
//     android:maxSdkVersion="32" />
// <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
// <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
// <uses-permission android:name="android.permission.WAKE_LOCK" />
```

---

##  Error Handling Strategy

| Error | Detection | Recovery |
|-------|-----------|----------|
| Corrupted audio file | `audio_metadata_reader` throws exception | Mark song as `isCorrupted: true`, skip in UI |
| Missing album art | `metadata.artworkBytes` is null | Use gradient placeholder |
| Path too long (> 255 chars) | `FileSystemException` | Skip file, log to scan report |
| Permission denied mid-scan | `PermissionStatus` callback | Pause scan, show dialog, resume |
| Database write failure | Isar `writeTxn` exception | Retry 3x with exponential backoff |
| Duplicate file (same hash) | SHA-256 collision check | Skip, update existing entry if modified |
| File deleted between scan start and metadata read | `FileSystemException` | Skip gracefully, no crash |
| Unsupported format | `mime.lookupMimeType` returns null | Skip, count in `skippedFiles` |

---

##  Performance Targets

| Operation | Target | Measurement |
|-----------|--------|-------------|
| Initial scan (10,000 files) | < 60 seconds | Samsung Galaxy S23 |
| Incremental scan (100 new files) | < 3 seconds | Same device |
| Search query ("beat") | < 5ms | Isar FTS index |
| Get all songs (10,000) | < 10ms | Isar index scan |
| Get album art | < 5ms | File cache hit |
| Database size (10,000 songs) | < 5 MB | Isar compression |
| Artwork cache size | < 200 MB | 512px JPEG, quality 85 |
| Memory during scan | < 50 MB | Streaming, no batch load |
