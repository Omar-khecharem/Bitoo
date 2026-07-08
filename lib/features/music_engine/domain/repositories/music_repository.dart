import 'dart:async';
import '../../data/database/song.dart';
import '../../data/database/album.dart';
import '../../data/database/artist.dart';
import '../../data/database/genre.dart';
import '../../data/database/playlist.dart';
import '../../data/database/scan_metadata.dart';
import '../../data/models/scan_progress.dart';

abstract class MusicRepository {
  // ── Scan ──
  Stream<ScanProgress> scanMusic();
  Future<bool> hasScannedBefore();
  Future<ScanMetadata?> getLastScanMetadata();

  // ── Songs ──
  Future<List<Song>> getAllSongs({String? sortBy, bool ascending = true});
  Future<List<Song>> getSongsByAlbum(String albumTitle);
  Future<List<Song>> getSongsByArtist(String artistName);
  Future<List<Song>> getSongsByGenre(String genre);
  Future<Song?> getSongByPath(String filePath);

  // ── Albums ──
  Future<List<Album>> getAllAlbums({String? sortBy, bool ascending = true});
  Future<Album?> getAlbum(String title, String artist);

  // ── Artists ──
  Future<List<Artist>> getAllArtists({String? sortBy, bool ascending = true});
  Future<Artist?> getArtist(String name);

  // ── Genres ──
  Future<List<Genre>> getAllGenres();

  // ── Search ──
  Future<List<Song>> search(String query);

  // ── Favorites ──
  Future<List<Song>> getFavorites();
  Future<void> toggleFavorite(String filePath);
  Future<bool> isFavorite(String filePath);

  // ── Recently Played ──
  Future<List<Song>> getRecentlyPlayed({int limit = 50});
  Future<void> addRecentlyPlayed(String filePath);

  // ── Playlists ──
  Future<List<PlaylistEntry>> getPlaylists();
  Future<PlaylistEntry?> getPlaylist(int id);
  Future<int> createPlaylist(String name, {String? description});
  Future<void> deletePlaylist(int id);
  Future<void> renamePlaylist(int id, String newName);
  Future<void> addSongToPlaylist(int playlistId, String songPath);
  Future<void> removeSongFromPlaylist(int playlistId, String songPath);
  Future<void> reorderPlaylist(int playlistId, int oldIndex, int newIndex);

  // ── Song Management ──
  Future<void> deleteSong(int songId, String filePath);
  Future<void> updateSongMetadata(int songId, {String? title, String? artist});

  // ── Storage ──
  Future<int> getArtworkCacheSize();
  Future<int> clearArtworkCache();
  Future<Map<String, int>> getStorageStats();

  // ── Permission ──
  Future<bool> requestPermission();
  Future<bool> hasPermission();
}
