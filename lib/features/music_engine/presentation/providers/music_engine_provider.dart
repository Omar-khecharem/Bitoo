import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/hive_database.dart';
import '../../data/database/song.dart';
import '../../data/database/album.dart';
import '../../data/database/artist.dart';
import '../../data/database/genre.dart';
import '../../data/database/playlist.dart';
import '../../data/datasources/file_scanner_datasource.dart';
import '../../data/datasources/metadata_datasource.dart';
import '../../data/datasources/artwork_cache_datasource.dart';
import '../../data/datasources/permission_datasource.dart';
import '../../data/models/scan_progress.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../domain/repositories/music_repository.dart';

// ── Core Dependencies ──

final hiveDatabaseProvider = Provider<HiveDatabase>((ref) {
  return HiveDatabase();
});

final fileScannerProvider = Provider<FileScannerDataSource>((ref) {
  return FileScannerDataSource();
});

final metadataReaderProvider = Provider<MetadataDataSource>((ref) {
  return MetadataDataSource();
});

final artworkCacheProvider = FutureProvider<ArtworkCacheDataSource>((ref) async {
  return ArtworkCacheDataSource.create();
});

final permissionProvider = Provider<PermissionDataSource>((ref) {
  return PermissionDataSource();
});

// ── Repository ──

final musicRepositoryProvider = FutureProvider<MusicRepository>((ref) async {
  final db = ref.read(hiveDatabaseProvider);
  await db.initialize();

  final artworkCache = await ref.read(artworkCacheProvider.future);

  return MusicRepositoryImpl(
    db: db,
    fileScanner: ref.read(fileScannerProvider),
    metadataReader: ref.read(metadataReaderProvider),
    artworkCache: artworkCache,
    permission: ref.read(permissionProvider),
  );
});

// ── Scan State ──

final scanTriggerProvider = StateProvider<int>((ref) => 0);

final scanProgressProvider = StreamProvider<ScanProgress>((ref) {
  ref.watch(scanTriggerProvider);
  final repoAsync = ref.watch(musicRepositoryProvider);

  return repoAsync.when(
    data: (repo) => repo.scanMusic(),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final scanMetadataProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getLastScanMetadata();
});

// ── Songs ──

final allSongsProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getAllSongs();
});

final songsByAlbumProvider = FutureProvider.autoDispose.family<List<Song>, String>((ref, album) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getSongsByAlbum(album);
});

final songsByArtistProvider = FutureProvider.autoDispose.family<List<Song>, String>((ref, artist) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getSongsByArtist(artist);
});

// ── Albums ──

final allAlbumsProvider = FutureProvider.autoDispose<List<Album>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getAllAlbums();
});

// ── Artists ──

final allArtistsProvider = FutureProvider.autoDispose<List<Artist>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getAllArtists();
});

// ── Genres ──

final allGenresProvider = FutureProvider.autoDispose<List<Genre>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getAllGenres();
});

// ── Search (debounced) ──

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.search(query);
});

// ── Favorites ──

final favoritesProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getFavorites();
});

final isFavoriteProvider = FutureProvider.autoDispose.family<bool, String>((ref, filePath) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.isFavorite(filePath);
});

// ── Recently Played ──

final recentlyPlayedProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getRecentlyPlayed();
});

// ── Playlists ──

final allPlaylistsProvider = FutureProvider.autoDispose<List<PlaylistEntry>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getPlaylists();
});

final playlistDetailProvider = FutureProvider.autoDispose.family<PlaylistEntry?, int>((ref, id) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getPlaylist(id);
});

// ── Storage Stats ──

final storageStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.getStorageStats();
});

// ── Permission ──

final hasPermissionProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.read(musicRepositoryProvider.future);
  return repo.hasPermission();
});
