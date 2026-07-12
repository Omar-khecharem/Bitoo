import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../../core/file_filters.dart';
import '../database/hive_database.dart';
import '../database/song.dart';
import '../database/album.dart';
import '../database/artist.dart';
import '../database/genre.dart';
import '../database/playlist.dart';
import '../database/scan_metadata.dart';
import '../datasources/file_scanner_datasource.dart';
import '../datasources/metadata_datasource.dart';
import '../datasources/artwork_cache_datasource.dart';
import '../datasources/permission_datasource.dart';
import '../models/scan_progress.dart';
import '../../core/audio_extensions.dart';
import '../../domain/repositories/music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({
    required HiveDatabase db,
    required FileScannerDataSource fileScanner,
    required MetadataDataSource metadataReader,
    required ArtworkCacheDataSource artworkCache,
    required PermissionDataSource permission,
  })  : _db = db,
        _fileScanner = fileScanner,
        _metadataReader = metadataReader,
        _artworkCache = artworkCache,
        _permission = permission;

  final HiveDatabase _db;
  final FileScannerDataSource _fileScanner;
  final MetadataDataSource _metadataReader;
  final ArtworkCacheDataSource _artworkCache;
  final PermissionDataSource _permission;

  // ── Permission ──

  @override
  Future<bool> hasPermission() => _permission.hasPermission();

  @override
  Future<bool> requestPermission() => _permission.requestAudioPermission();

  // ── Scan ──

  @override
  Future<bool> hasScannedBefore() async {
    return _db.scanMetaMap != null;
  }

  @override
  Future<ScanMetadata?> getLastScanMetadata() async {
    final map = _db.scanMetaMap;
    if (map == null) return null;
    return ScanMetadata.fromMap(map);
  }

  @override
  Stream<ScanProgress> scanMusic() async* {
    final hasPerm = await _permission.requestAudioPermission();
    if (!hasPerm) {
      yield const ScanProgress(
        filesScanned: 0,
        totalFiles: 0,
        currentPath: '',
        isComplete: true,
        corruptedFiles: 0,
        diagnostic: 'Permission denied for audio access',
      );
      return;
    }

    var newSongsCount = 0;
    var corruptedCount = 0;
    var totalFiles = 0;
    var diagnostic = '';

    // Phase 0: Request full file access on Android 11+ (scoped storage bypass)
    final needsFullAccess = _permission.isAndroid11OrAbove &&
        !await _permission.hasFullFileAccess();
    if (needsFullAccess) {
      yield const ScanProgress(
        filesScanned: 0,
        totalFiles: 0,
        currentPath: 'Requesting full file access...',
      );
      try {
        await _permission.requestFullFileAccess();
        diagnostic = 'Granted MANAGE_EXTERNAL_STORAGE';
      } catch (e) {
        diagnostic = 'Failed to request full access: $e';
      }
    }

    // Phase 1: Count files
    var roots = _fileScanner.getDefaultScanRoots();
    if (await _permission.hasFullFileAccess()) {
      roots = _fileScanner.getFullScanRoots();
      diagnostic += ' (full access scan)';
    } else {
      diagnostic += ' (limited scan)';
    }

    debugPrint('Scan roots: ${roots.map((r) => r.path).toList()}');
    final allFiles = <File>[];
    for (final root in roots) {
      var fileCount = 0;
      try {
        await for (final file in _walkForCount(root)) {
          allFiles.add(file);
          fileCount++;
        }
      } catch (e) {
        debugPrint('Error walking ${root.path}: $e');
      }
      debugPrint('Found $fileCount files in ${root.path}');
    }
    totalFiles = allFiles.length;
    diagnostic += ' | $totalFiles audio files found';

    debugPrint('Total audio files found: $totalFiles');
    yield ScanProgress(
        filesScanned: 0,
        totalFiles: totalFiles,
        currentPath: 'Scanning...',
        diagnostic: diagnostic);

    // Phase 2: Process each file
    final sha256Index = <String, Song>{};
    for (final m in _db.allSongMaps) {
      final s = Song.fromMap(m);
      sha256Index[s.sha256] = s;
    }

    var scanned = 0;
    final corruptedPaths = <String>{};
    for (final file in allFiles) {
      scanned++;

      yield ScanProgress(
        filesScanned: scanned,
        totalFiles: totalFiles,
        currentPath: AudioExtensions.titleFromPath(file.path),
        diagnostic: diagnostic,
      );

      try {
        final metadata = _metadataReader.extract(file.path);
        if (metadata == null) {
          debugPrint('extract returned null: ${file.path}');
          corruptedPaths.add(file.path);
          corruptedCount++;
          continue;
        }

        // Dedup check
        final existing = sha256Index[metadata.sha256];
        if (existing != null) {
          await _updateSongInMemory(existing, metadata);
          continue;
        }

        // Save artwork to cache
        String? artworkPath;
        if (metadata.artworkBytes != null) {
          artworkPath = await _artworkCache.saveArtwork(
              metadata.sha256, Uint8List.fromList(metadata.artworkBytes!));
        }

        final id = _nextSongId();
        final song = Song(
          id: id,
          filePath: metadata.filePath,
          sha256: metadata.sha256,
          title: metadata.title,
          artist: metadata.artist,
          albumTitle: metadata.albumTitle,
          albumArtist: metadata.albumArtist,
          trackNumber: metadata.trackNumber,
          discNumber: metadata.discNumber,
          year: metadata.year,
          genre: metadata.genre,
          durationMs: metadata.durationMs,
          bitrate: metadata.bitrate,
          sampleRate: metadata.sampleRate,
          artworkPath: artworkPath,
          hasArtwork: artworkPath != null,
          fileExtension: metadata.fileExtension,
          fileSize: metadata.fileSize,
          dateAdded: DateTime.now(),
          dateModified: metadata.dateModified,
        );

        await _db.putSong(id.toString(), song.toMap());
        newSongsCount++;
      } catch (e) {
        debugPrint('Error processing ${file.path}: $e');
        corruptedPaths.add(file.path);
        corruptedCount++;
      }
    }

    // Phase 3: Remove stale DB entries (files no longer on disk or unreadable)
    final foundPaths = allFiles.map((f) => f.path).toSet();
    var removedCount = 0;
    for (final key in _db.songs.keys.toList()) {
      final map = _db.getSongMap(key);
      if (map != null) {
        final path = map['filePath'] as String?;
        if (path == null ||
            !foundPaths.contains(path) ||
            corruptedPaths.contains(path)) {
          _db.deleteSong(key);
          removedCount++;
        }
      }
    }
    if (removedCount > 0) {
      debugPrint('Removed $removedCount stale songs from DB');
    }

    // Phase 5: Rebuild aggregate indexes
    await _rebuildAlbumIndex();
    await _rebuildArtistIndex();
    await _rebuildGenreIndex();

    // Phase 6: Clean orphaned data
    final currentSha256s =
        _db.allSongMaps.map((m) => m['sha256'] as String).toSet();
    await _artworkCache.cleanOrphaned(currentSha256s);
    _cleanOrphanedAlbums();
    _cleanOrphanedArtists();

    // Phase 7: Update scan metadata
    final songCount = _db.songCount;
    final albumCount = _db.albumCount;
    final artistCount = _db.artistCount;
    final genreCount = _db.genreCount;

    final scanMeta = ScanMetadata(
      lastScanTimestamp: DateTime.now(),
      totalSongs: songCount,
      totalAlbums: albumCount,
      totalArtists: artistCount,
      totalGenres: genreCount,
      corruptedFiles: corruptedCount,
      skippedFiles: totalFiles - newSongsCount - corruptedCount,
    );

    await _db.clearScanMeta();
    await _db.putScanMeta(scanMeta.toMap());

    debugPrint(
        'Scan complete: $newSongsCount new songs, $corruptedCount corrupted, ${totalFiles - newSongsCount - corruptedCount} skipped');

    yield ScanProgress(
      filesScanned: scanned,
      totalFiles: totalFiles,
      currentPath: 'Scan complete',
      isComplete: true,
      newSongs: newSongsCount,
      corruptedFiles: corruptedCount,
      diagnostic:
          '$diagnostic | $newSongsCount new songs, $corruptedCount corrupted',
    );
  }

  Stream<File> _walkForCount(Directory dir) async* {
    try {
      final entities = dir.list(recursive: true, followLinks: false);
      await for (final entity in entities) {
        if (entity is File) {
          final ext = entity.path.split('.').last.toLowerCase();
          if (AudioExtensions.supportedExtensions.contains(ext) &&
              !FileFilters.isHiddenOrSystemPath(entity.path)) {
            try {
              if (entity.lengthSync() > 0) yield entity;
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('_walkForCount error in ${dir.path}: $e');
    }
  }

  Future<void> _updateSongInMemory(
      Song existing, AudioMetadata metadata) async {
    final updated = existing.copyWith(
      title: metadata.title,
      artist: metadata.artist,
      albumTitle: metadata.albumTitle,
      albumArtist: metadata.albumArtist,
      trackNumber: metadata.trackNumber,
      discNumber: metadata.discNumber,
      year: metadata.year,
      genre: metadata.genre,
      durationMs: metadata.durationMs,
      bitrate: metadata.bitrate,
      sampleRate: metadata.sampleRate,
      fileExtension: metadata.fileExtension,
      fileSize: metadata.fileSize,
      dateModified: metadata.dateModified,
      searchIndex: '${metadata.title} ${metadata.artist} ${metadata.albumTitle}'
          .toLowerCase(),
    );
    await _db.putSong(existing.id.toString(), updated.toMap());
  }

  int _nextSongId() {
    final max = _db.songs.keys.fold(0, (int max, k) {
      final id = int.tryParse(k) ?? 0;
      return id > max ? id : max;
    });
    return max + 1;
  }

  // ── Aggregate Index Rebuilding ──

  Future<void> _rebuildAlbumIndex() async {
    final allSongs = _db.allSongMaps.map(Song.fromMap).toList();
    final grouped = groupBy(allSongs, (Song s) => s.albumTitle.toLowerCase());

    await _db.clearAlbums();
    var id = 0;
    for (final entry in grouped.entries) {
      final firstSong = entry.value.first;
      id++;
      final album = Album(
        id: id,
        title: firstSong.albumTitle,
        artist: firstSong.albumArtist ?? firstSong.artist,
        year: firstSong.year,
        genre: firstSong.genre,
        songCount: entry.value.length,
        totalDurationMs:
            entry.value.fold<int>(0, (sum, s) => sum + s.durationMs),
        artworkPath: entry.value
            .firstWhereOrNull((s) => s.hasArtwork == true)
            ?.artworkPath,
        dateAdded: DateTime.now(),
      );
      await _db.putAlbum(album.title.toLowerCase(), album.toMap());
    }
  }

  Future<void> _rebuildArtistIndex() async {
    final allSongs = _db.allSongMaps.map(Song.fromMap).toList();
    final grouped = groupBy(allSongs, (Song s) => s.artist.toLowerCase());

    await _db.clearArtists();
    for (final entry in grouped.entries) {
      final firstSong = entry.value.first;
      final albums = entry.value.map((s) => s.albumTitle).toSet();
      final artist = Artist(
        name: firstSong.artist,
        albumCount: albums.length,
        songCount: entry.value.length,
        totalDurationMs:
            entry.value.fold<int>(0, (sum, s) => sum + s.durationMs),
        artworkPath: entry.value
            .firstWhereOrNull((s) => s.hasArtwork == true)
            ?.artworkPath,
        dateAdded: DateTime.now(),
      );
      await _db.putArtist(artist.name.toLowerCase(), artist.toMap());
    }
  }

  Future<void> _rebuildGenreIndex() async {
    final allSongs = _db.allSongMaps.map(Song.fromMap).toList();
    final grouped =
        groupBy(allSongs, (Song s) => s.genre?.toLowerCase() ?? 'unknown');

    await _db.clearGenres();
    for (final entry in grouped.entries) {
      final albums = entry.value.map((s) => s.albumTitle).toSet();
      final genre = Genre(
        name: entry.key,
        songCount: entry.value.length,
        albumCount: albums.length,
        dateAdded: DateTime.now(),
      );
      await _db.putGenre(entry.key, genre.toMap());
    }
  }

  void _cleanOrphanedAlbums() {
    final validTitles = _db.allSongMaps
        .map((m) => (m['albumTitle'] as String).toLowerCase())
        .toSet();
    for (final key in _db.albums.keys.toList()) {
      if (!validTitles.contains(key)) {
        _db.deleteAlbum(key);
      }
    }
  }

  void _cleanOrphanedArtists() {
    final validNames = _db.allSongMaps
        .map((m) => (m['artist'] as String).toLowerCase())
        .toSet();
    for (final key in _db.artists.keys.toList()) {
      if (!validNames.contains(key)) {
        _db.deleteArtist(key);
      }
    }
  }

  // ── Songs ──

  @override
  Future<List<Song>> getAllSongs(
      {String? sortBy, bool ascending = true}) async {
    var list = _db.allSongMaps.map(Song.fromMap).toList();
    if (sortBy != null) {
      list.sort((a, b) {
        int cmp;
        switch (sortBy) {
          case 'title':
            cmp = a.title.compareTo(b.title);
            break;
          case 'artist':
            cmp = a.artist.compareTo(b.artist);
            break;
          case 'album':
            cmp = a.albumTitle.compareTo(b.albumTitle);
            break;
          case 'dateAdded':
            cmp = a.dateAdded.compareTo(b.dateAdded);
            break;
          case 'playCount':
            cmp = a.playCount.compareTo(b.playCount);
            break;
          default:
            cmp = a.title.compareTo(b.title);
        }
        return ascending ? cmp : -cmp;
      });
    }
    return list;
  }

  @override
  Future<List<Song>> getSongsByAlbum(String albumTitle) async {
    final q = albumTitle.toLowerCase();
    return _db.allSongMaps
        .map(Song.fromMap)
        .where((s) => s.albumTitle.toLowerCase() == q)
        .toList()
      ..sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
  }

  @override
  Future<List<Song>> getSongsByArtist(String artistName) async {
    final q = artistName.toLowerCase();
    return _db.allSongMaps
        .map(Song.fromMap)
        .where((s) => s.artist.toLowerCase() == q)
        .toList()
      ..sort((a, b) => a.albumTitle.compareTo(b.albumTitle));
  }

  @override
  Future<List<Song>> getSongsByGenre(String genre) async {
    final q = genre.toLowerCase();
    return _db.allSongMaps
        .map(Song.fromMap)
        .where((s) => s.genre?.toLowerCase() == q)
        .toList();
  }

  @override
  Future<Song?> getSongByPath(String filePath) async {
    for (final map in _db.allSongMaps) {
      if (map['filePath'] == filePath) {
        return Song.fromMap(map);
      }
    }
    return null;
  }

  // ── Albums ──

  @override
  Future<List<Album>> getAllAlbums(
      {String? sortBy, bool ascending = true}) async {
    var list = _db.allAlbumMaps.map(Album.fromMap).toList();
    list.sort((a, b) => a.title.compareTo(b.title));
    return list;
  }

  @override
  Future<Album?> getAlbum(String title, String artist) async {
    final map = _db.getAlbumMap(title.toLowerCase());
    if (map == null) return null;
    return Album.fromMap(map);
  }

  // ── Artists ──

  @override
  Future<List<Artist>> getAllArtists(
      {String? sortBy, bool ascending = true}) async {
    var list = _db.allArtistMaps.map(Artist.fromMap).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<Artist?> getArtist(String name) async {
    final map = _db.getArtistMap(name.toLowerCase());
    if (map == null) return null;
    return Artist.fromMap(map);
  }

  // ── Genres ──

  @override
  Future<List<Genre>> getAllGenres() async {
    return _db.allGenreMaps.map(Genre.fromMap).toList();
  }

  // ── Search ──

  @override
  Future<List<Song>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase();
    final terms = q.split(RegExp(r'\s+'));

    final allSongs = _db.allSongMaps.map(Song.fromMap).toList();
    final seen = <int>{};
    final ranked = <_RankedSong>[];

    void add(Iterable<Song> songs, double baseScore) {
      for (final song in songs) {
        if (seen.add(song.id)) {
          ranked.add(_RankedSong(song, _computeScore(q, song, baseScore)));
        }
      }
    }

    // FTS on searchIndex
    add(allSongs.where((s) => terms.every((t) => s.searchIndex.contains(t))),
        50);
    // Title prefix match
    add(allSongs.where((s) => s.title.toLowerCase().startsWith(q)), 80);
    // Artist prefix match
    add(allSongs.where((s) => s.artist.toLowerCase().startsWith(q)), 60);
    // Album prefix match
    add(allSongs.where((s) => s.albumTitle.toLowerCase().startsWith(q)), 40);

    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked.map((r) => r.song).toList();
  }

  double _computeScore(String query, Song song, double base) {
    double score = base;
    final q = query.toLowerCase();
    final title = song.title.toLowerCase();

    if (title == q) {
      score += 100;
    } else if (title.startsWith(q)) {
      score += 50;
    } else if (title.contains(q)) {
      score += 20;
    }

    if (song.artist.toLowerCase().startsWith(q)) score += 30;
    if (song.albumTitle.toLowerCase().startsWith(q)) score += 15;

    if (song.playCount > 0) score += song.playCount * 0.1;

    return score;
  }

  // ── Favorites ──

  @override
  Future<List<Song>> getFavorites() async {
    return _db.allSongMaps
        .map(Song.fromMap)
        .where((s) => s.isFavorite)
        .toList();
  }

  @override
  Future<void> toggleFavorite(String filePath) async {
    for (final key in _db.songs.keys) {
      final map = _db.getSongMap(key);
      if (map != null && map['filePath'] == filePath) {
        map['isFavorite'] = !(map['isFavorite'] as bool? ?? false);
        await _db.putSong(key, map);
        return;
      }
    }
  }

  @override
  Future<bool> isFavorite(String filePath) async {
    for (final map in _db.allSongMaps) {
      if (map['filePath'] == filePath) {
        return map['isFavorite'] as bool? ?? false;
      }
    }
    return false;
  }

  // ── Recently Played ──

  @override
  Future<List<Song>> getRecentlyPlayed({int limit = 50}) async {
    final played = _db.allSongMaps
        .map(Song.fromMap)
        .where((s) => s.lastPlayed != null)
        .toList();
    played.sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
    return played.take(limit).toList();
  }

  @override
  Future<void> addRecentlyPlayed(String filePath) async {
    for (final key in _db.songs.keys) {
      final map = _db.getSongMap(key);
      if (map != null && map['filePath'] == filePath) {
        map['lastPlayed'] = DateTime.now().toIso8601String();
        map['playCount'] = ((map['playCount'] as int?) ?? 0) + 1;
        await _db.putSong(key, map);
        return;
      }
    }
  }

  // ── Playlists ──

  @override
  Future<List<PlaylistEntry>> getPlaylists() async {
    return _db.allPlaylistMaps.map(PlaylistEntry.fromMap).toList();
  }

  @override
  Future<PlaylistEntry?> getPlaylist(int id) async {
    final map = _db.getPlaylistMap(id.toString());
    if (map == null) return null;
    return PlaylistEntry.fromMap(map);
  }

  @override
  Future<int> createPlaylist(String name, {String? description}) async {
    final id = _db.nextPlaylistId;
    final now = DateTime.now();
    final playlist = PlaylistEntry(
      id: id,
      name: name,
      description: description,
      dateCreated: now,
      dateModified: now,
    );
    await _db.putPlaylist(id.toString(), playlist.toMap());
    return id;
  }

  @override
  Future<void> deletePlaylist(int id) async {
    await _db.deletePlaylist(id.toString());
  }

  @override
  Future<void> renamePlaylist(int id, String newName) async {
    final map = _db.getPlaylistMap(id.toString());
    if (map == null) return;
    map['name'] = newName;
    map['searchIndex'] = newName.toLowerCase();
    map['dateModified'] = DateTime.now().toIso8601String();
    await _db.putPlaylist(id.toString(), map);
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, String songPath) async {
    final pMap = _db.getPlaylistMap(playlistId.toString());
    final song = await getSongByPath(songPath);
    if (pMap == null || song == null) return;

    final paths = (pMap['songPaths'] as List<dynamic>).cast<String>();
    paths.add(songPath);
    pMap['songPaths'] = paths;
    pMap['songCount'] = paths.length;
    pMap['totalDurationMs'] =
        ((pMap['totalDurationMs'] as int?) ?? 0) + song.durationMs;
    pMap['dateModified'] = DateTime.now().toIso8601String();
    await _db.putPlaylist(playlistId.toString(), pMap);
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistId, String songPath) async {
    final pMap = _db.getPlaylistMap(playlistId.toString());
    final song = await getSongByPath(songPath);
    if (pMap == null || song == null) return;

    final paths = (pMap['songPaths'] as List<dynamic>).cast<String>();
    paths.remove(songPath);
    pMap['songPaths'] = paths;
    pMap['songCount'] = paths.length;
    pMap['totalDurationMs'] =
        ((pMap['totalDurationMs'] as int?) ?? 0) - song.durationMs;
    if (((pMap['totalDurationMs'] as int?) ?? 0) < 0) {
      pMap['totalDurationMs'] = 0;
    }
    pMap['dateModified'] = DateTime.now().toIso8601String();
    await _db.putPlaylist(playlistId.toString(), pMap);
  }

  @override
  Future<void> reorderPlaylist(
      int playlistId, int oldIndex, int newIndex) async {
    final pMap = _db.getPlaylistMap(playlistId.toString());
    if (pMap == null) return;

    final paths = (pMap['songPaths'] as List<dynamic>).cast<String>();
    final item = paths.removeAt(oldIndex);
    paths.insert(newIndex, item);
    pMap['songPaths'] = paths;
    pMap['dateModified'] = DateTime.now().toIso8601String();
    await _db.putPlaylist(playlistId.toString(), pMap);
  }

  // ── Song Management ──

  @override
  Future<void> deleteSong(int songId, String filePath) async {
    await _db.deleteSong(songId.toString());
    try {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  @override
  Future<void> updateSongMetadata(int songId,
      {String? title, String? artist}) async {
    final map = _db.getSongMap(songId.toString());
    if (map == null) return;
    if (title != null) map['title'] = title;
    if (artist != null) map['artist'] = artist;
    await _db.putSong(songId.toString(), map);
  }

  // ── Storage ──

  @override
  Future<int> getArtworkCacheSize() => _artworkCache.getCacheSizeBytes();

  @override
  Future<int> clearArtworkCache() => _artworkCache.clearCache();

  @override
  Future<Map<String, int>> getStorageStats() async {
    return {
      'songs': _db.songCount,
      'albums': _db.albumCount,
      'artists': _db.artistCount,
      'cacheSizeBytes': await _artworkCache.getCacheSizeBytes(),
    };
  }
}

class _RankedSong {
  final Song song;
  final double score;
  _RankedSong(this.song, this.score);
}
