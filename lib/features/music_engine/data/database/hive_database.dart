import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveDatabase {
  static const _songsBox = 'songs';
  static const _albumsBox = 'albums';
  static const _artistsBox = 'artists';
  static const _genresBox = 'genres';
  static const _playlistsBox = 'playlists';
  static const _scanMetaBox = 'scan_metadata';

  HiveDatabase._();
  static final HiveDatabase _instance = HiveDatabase._();
  factory HiveDatabase() => _instance;

  late Box<String> songs;
  late Box<String> albums;
  late Box<String> artists;
  late Box<String> genres;
  late Box<String> playlists;
  late Box<String> scanMeta;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    songs = await Hive.openBox<String>(_songsBox);
    albums = await Hive.openBox<String>(_albumsBox);
    artists = await Hive.openBox<String>(_artistsBox);
    genres = await Hive.openBox<String>(_genresBox);
    playlists = await Hive.openBox<String>(_playlistsBox);
    scanMeta = await Hive.openBox<String>(_scanMetaBox);

    _initialized = true;
  }

  Future<void> close() async {
    await songs.close();
    await albums.close();
    await artists.close();
    await genres.close();
    await playlists.close();
    await scanMeta.close();
    _initialized = false;
  }

  // ── JSON Helpers ──

  Map<String, dynamic>? _decode(String? value) {
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  String _encode(Map<String, dynamic> map) => jsonEncode(map);

  // ── Songs ──

  List<Map<String, dynamic>> get allSongMaps {
    return songs.values
        .map((v) => _decode(v))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic>? getSongMap(String key) => _decode(songs.get(key));

  Future<void> putSong(String key, Map<String, dynamic> map) async {
    await songs.put(key, _encode(map));
  }

  Future<void> deleteSong(String key) async {
    await songs.delete(key);
  }

  int get songCount => songs.length;

  // ── Albums ──

  List<Map<String, dynamic>> get allAlbumMaps {
    return albums.values
        .map((v) => _decode(v))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic>? getAlbumMap(String key) => _decode(albums.get(key));

  Future<void> putAlbum(String key, Map<String, dynamic> map) async {
    await albums.put(key, _encode(map));
  }

  Future<void> deleteAlbum(String key) async {
    await albums.delete(key);
  }

  Future<void> clearAlbums() async {
    await albums.clear();
  }

  int get albumCount => albums.length;

  // ── Artists ──

  List<Map<String, dynamic>> get allArtistMaps {
    return artists.values
        .map((v) => _decode(v))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic>? getArtistMap(String key) => _decode(artists.get(key));

  Future<void> putArtist(String key, Map<String, dynamic> map) async {
    await artists.put(key, _encode(map));
  }

  Future<void> deleteArtist(String key) async {
    await artists.delete(key);
  }

  Future<void> clearArtists() async {
    await artists.clear();
  }

  int get artistCount => artists.length;

  // ── Genres ──

  List<Map<String, dynamic>> get allGenreMaps {
    return genres.values
        .map((v) => _decode(v))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> putGenre(String key, Map<String, dynamic> map) async {
    await genres.put(key, _encode(map));
  }

  Future<void> clearGenres() async {
    await genres.clear();
  }

  int get genreCount => genres.length;

  // ── Playlists ──

  List<Map<String, dynamic>> get allPlaylistMaps {
    return playlists.values
        .map((v) => _decode(v))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic>? getPlaylistMap(String key) =>
      _decode(playlists.get(key));

  Future<void> putPlaylist(String key, Map<String, dynamic> map) async {
    await playlists.put(key, _encode(map));
  }

  Future<void> deletePlaylist(String key) async {
    await playlists.delete(key);
  }

  int get nextPlaylistId {
    final max = playlists.keys.fold(0, (int max, k) {
      final id = int.tryParse(k) ?? 0;
      return id > max ? id : max;
    });
    return max + 1;
  }

  // ── Scan Metadata ──

  Map<String, dynamic>? get scanMetaMap => _decode(scanMeta.get('latest'));

  Future<void> putScanMeta(Map<String, dynamic> map) async {
    await scanMeta.put('latest', _encode(map));
  }

  Future<void> clearScanMeta() async {
    await scanMeta.clear();
  }
}
