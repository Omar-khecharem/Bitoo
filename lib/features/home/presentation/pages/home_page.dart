import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/preferences_provider.dart';
import '../../../../shared/widgets/premium_dialogs.dart';
import '../../../../shared/widgets/premium_category_bar.dart';
import '../widgets/hero_header.dart';
import '../../../music_engine/core/audio_extensions.dart';
import '../../../music_engine/data/database/song.dart';
import '../../../music_engine/data/database/album.dart';
import '../../../music_engine/data/database/artist.dart';
import '../../../music_engine/data/database/playlist.dart';
import '../../../music_engine/data/database/genre.dart';
import '../../../music_engine/presentation/providers/music_engine_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/services/audio_handler.dart';
import '../../../player/presentation/pages/fullscreen_player_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

enum _SortOption {
  date,
  alphabetical,
  random,
  longestDuration,
  mostPlayed,
  lastInstalled,
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.date;
  String? _selectedCategory;

  static const _categories = [
    CategoryItem(icon: Icons.music_note_rounded, label: 'Songs', color: Color(0xFFFFB300), id: 'songs'),
    CategoryItem(icon: Icons.favorite_rounded, label: 'Favorites', color: Color(0xFFFF6B6B), id: 'favorites'),
    CategoryItem(icon: Icons.album_rounded, label: 'Albums', color: Color(0xFFE040FB), id: 'albums'),
    CategoryItem(icon: Icons.person_rounded, label: 'Artists', color: Color(0xFF00C9A7), id: 'artists'),
    CategoryItem(icon: Icons.category_rounded, label: 'Genres', color: Color(0xFFFF8C00), id: 'genres'),
    CategoryItem(icon: Icons.queue_music_rounded, label: 'Playlists', color: Color(0xFFFFD700), id: 'playlists'),
    CategoryItem(icon: Icons.history_rounded, label: 'Recent', color: Color(0xFFFF4081), id: 'recent'),
    CategoryItem(icon: Icons.trending_up_rounded, label: 'Most Played', color: Color(0xFFFF6D00), id: 'mostplayed'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    if (_searchQuery != q) {
      setState(() => _searchQuery = q);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Song> _filterSongs(List<Song> songs) {
    var result = songs;
    if (_searchQuery.isNotEmpty) {
      result = songs.where((s) =>
        s.title.toLowerCase().contains(_searchQuery) ||
        s.artist.toLowerCase().contains(_searchQuery) ||
        s.albumTitle.toLowerCase().contains(_searchQuery) ||
        (s.genre?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }
    return _sortSongs(result);
  }

  List<Song> _sortSongs(List<Song> songs) {
    final sorted = List<Song>.from(songs);
    switch (_sortOption) {
      case _SortOption.date:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case _SortOption.alphabetical:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case _SortOption.random:
        sorted.shuffle();
      case _SortOption.longestDuration:
        sorted.sort((a, b) => b.durationMs.compareTo(a.durationMs));
      case _SortOption.mostPlayed:
        sorted.sort((a, b) => b.playCount.compareTo(a.playCount));
      case _SortOption.lastInstalled:
        sorted.sort((a, b) => b.dateModified.compareTo(a.dateModified));
    }
    return sorted;
  }

  void _showSortMenu() {
    PremiumBottomSheet.show(
      context,
      builder: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.sort_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
          ..._SortOption.values.map((option) => _buildSortOption(option)),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSortOption(_SortOption option) {
    final isSelected = option == _sortOption;
    final label = switch (option) {
      _SortOption.date => 'Date Added',
      _SortOption.alphabetical => 'A-Z',
      _SortOption.random => 'Random',
      _SortOption.longestDuration => 'Duration',
      _SortOption.mostPlayed => 'Most Played',
      _SortOption.lastInstalled => 'Last Installed',
    };
    final icon = switch (option) {
      _SortOption.date => Icons.calendar_today_rounded,
      _SortOption.alphabetical => Icons.sort_by_alpha_rounded,
      _SortOption.random => Icons.shuffle_rounded,
      _SortOption.longestDuration => Icons.timer_rounded,
      _SortOption.mostPlayed => Icons.trending_up_rounded,
      _SortOption.lastInstalled => Icons.download_done_rounded,
    };

    return GestureDetector(
      onTap: () {
        setState(() => _sortOption = option);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonIndigo.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.neonIndigo : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.neonIndigo : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 18, color: AppColors.neonIndigo),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    ref.read(scanTriggerProvider.notifier).state++;
    await Future.delayed(const Duration(milliseconds: 800));
    ref.invalidate(allSongsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final allSongsAsync = ref.watch(allSongsProvider);
    final allAlbumsAsync = ref.watch(allAlbumsProvider);
    final allArtistsAsync = ref.watch(allArtistsProvider);
    final allGenresAsync = ref.watch(allGenresProvider);
    final allPlaylistsAsync = ref.watch(allPlaylistsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final recentlyPlayedAsync = ref.watch(recentlyPlayedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 60,
        color: AppColors.neonIndigo,
        backgroundColor: Theme.of(context).cardColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          cacheExtent: 500,
          slivers: [
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _ScrollAwareHeader(
                  scrollController: _scrollController,
                  searchController: _searchController,
                  onFilterTap: _showSortMenu,
                  onSettingsTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: PremiumCategoryBar(
                  categories: _categories,
                  selectedId: _selectedCategory,
                  onCategoryTap: (id) {
                    setState(() {
                      _selectedCategory = _selectedCategory == id ? null : id;
                    });
                  },
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              _buildSearchResults(allSongsAsync)
            else if (_selectedCategory != null)
              _buildCategoryContent(
                _selectedCategory!,
                allSongsAsync,
                allAlbumsAsync,
                allArtistsAsync,
                allGenresAsync,
                allPlaylistsAsync,
                favoritesAsync,
                recentlyPlayedAsync,
              )
            else
              _buildSongList(allSongsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Song>> allSongsAsync) {
    return allSongsAsync.when(
      loading: () => SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('$e', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 14), textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (songs) {
        final valid = songs.where((s) => s.filePath.isNotEmpty).toList();
        final filtered = valid.where((s) =>
          s.title.toLowerCase().contains(_searchQuery) ||
          s.artist.toLowerCase().contains(_searchQuery) ||
          s.albumTitle.toLowerCase().contains(_searchQuery) ||
          (s.genre?.toLowerCase().contains(_searchQuery) ?? false)
        ).toList();
        final sorted = _sortSongs(filtered);

        if (sorted.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
                  SizedBox(height: 16),
                  Text(
                    'No results for "$_searchQuery"',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _SongTile(song: sorted[i]),
              childCount: sorted.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryContent(
    String category,
    AsyncValue<List<Song>> allSongsAsync,
    AsyncValue<List<Album>> allAlbumsAsync,
    AsyncValue<List<Artist>> allArtistsAsync,
    AsyncValue<List<Genre>> allGenresAsync,
    AsyncValue<List<PlaylistEntry>> allPlaylistsAsync,
    AsyncValue<List<Song>> favoritesAsync,
    AsyncValue<List<Song>> recentlyPlayedAsync,
  ) {
    switch (category) {
      case 'albums':
        return allAlbumsAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, _) => SliverFillRemaining(child: Center(child: Text('$e', style: TextStyle(color: AppColors.neonRose)))),
          data: (albums) {
            if (albums.isEmpty) return _emptyState('No albums found', Icons.album_rounded);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _AlbumCard(album: albums[i]),
                  childCount: albums.length,
                ),
              ),
            );
          },
        );
      case 'favorites':
        return favoritesAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _emptyState('Could not load favorites', Icons.favorite_rounded),
          data: (songs) {
            if (songs.isEmpty) return _emptyState('No favorite songs yet', Icons.favorite_rounded);
            return SliverPadding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _SongTile(song: songs[i]),
                  childCount: songs.length,
                ),
              ),
            );
          },
        );
      case 'artists':
        return allArtistsAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _emptyState('Could not load artists', Icons.person_rounded),
          data: (artists) {
            if (artists.isEmpty) return _emptyState('No artists found', Icons.person_rounded);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ArtistCard(artist: artists[i]),
                  childCount: artists.length,
                ),
              ),
            );
          },
        );
      case 'genres':
        return allGenresAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _emptyState('Could not load genres', Icons.category_rounded),
          data: (genres) {
            if (genres.isEmpty) return _emptyState('No genres found', Icons.category_rounded);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _GenreCard(genre: genres[i]),
                  childCount: genres.length,
                ),
              ),
            );
          },
        );
      case 'playlists':
        return allPlaylistsAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _emptyState('Could not load playlists', Icons.queue_music_rounded),
          data: (playlists) {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                if (i == 0) return _CreatePlaylistTile();
                return _PlaylistTile(playlist: playlists[i - 1]);
              },
              childCount: playlists.length + 1,
            ),
          ),
        );
          },
        );
      case 'recent':
        return recentlyPlayedAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _emptyState('Could not load recent tracks', Icons.history_rounded),
          data: (songs) {
            if (songs.isEmpty) return _emptyState('No recently played tracks', Icons.history_rounded);
            return SliverPadding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _SongTile(song: songs[i]),
                  childCount: songs.length,
                ),
              ),
            );
          },
        );
      case 'mostplayed':
        return allSongsAsync.when(
          loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _emptyState('Could not load', Icons.trending_up_rounded),
          data: (songs) {
            final mostPlayed = songs.where((s) => s.playCount > 0).toList()
              ..sort((a, b) => b.playCount.compareTo(a.playCount));
            if (mostPlayed.isEmpty) return _emptyState('No played tracks yet', Icons.trending_up_rounded);
            return SliverPadding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _SongTile(song: mostPlayed[i]),
                  childCount: mostPlayed.length,
                ),
              ),
            );
          },
        );
      default:
        return _buildSongList(allSongsAsync);
    }
  }

  Widget _emptyState(String message, IconData icon) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList(AsyncValue<List<Song>> allSongsAsync) {
    return allSongsAsync.when(
      loading: () => SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('$e', style: TextStyle(color: AppColors.neonRose, fontSize: 14), textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (songs) {
        final valid = songs.where((s) => s.filePath.isNotEmpty).toList();
        final filtered = _filterSongs(valid);
        if (valid.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(height: 16),
                  Text('Scanning your music...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 15)),
                ],
              ),
            ),
          );
        }

        if (_searchQuery.isNotEmpty && filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
                  SizedBox(height: 16),
                  Text(
                    'No results for "$_searchQuery"',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _SongTile(song: filtered[i]),
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }
}

class _ScrollAwareHeader extends StatefulWidget {
  final ScrollController scrollController;
  final TextEditingController? searchController;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSettingsTap;

  const _ScrollAwareHeader({
    required this.scrollController,
    this.searchController,
    this.onFilterTap,
    this.onSettingsTap,
  });

  @override
  State<_ScrollAwareHeader> createState() => _ScrollAwareHeaderState();
}

class _ScrollAwareHeaderState extends State<_ScrollAwareHeader> {
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    if ((offset - _scrollOffset).abs() > 0.5) {
      setState(() => _scrollOffset = offset);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroHeader(
      scrollOffset: _scrollOffset,
      searchController: widget.searchController,
      onSearchChanged: (v) {},
      onFilterTap: widget.onFilterTap,
      onSettingsTap: widget.onSettingsTap,
    );
  }
}

class _SongTile extends ConsumerStatefulWidget {
  final Song song;

  const _SongTile({required this.song});

  @override
  ConsumerState<_SongTile> createState() => _SongTileState();
}

class _SongTileState extends ConsumerState<_SongTile> {
  bool _isCurrentTrack = false;
  String _lastPath = '';
  bool _isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTrackStatus();
    _loadFavoriteStatus();
  }

  void _updateTrackStatus() {
    final path = ref.read(audioHandlerProvider).currentPath;
    if (path != _lastPath) {
      _lastPath = path;
      setState(() => _isCurrentTrack = path == widget.song.filePath);
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final repo = await ref.read(musicRepositoryProvider.future);
    final fav = await repo.isFavorite(widget.song.filePath);
    if (mounted && fav != _isFavorite) {
      setState(() => _isFavorite = fav);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.blueToIndigo,
              border: _isCurrentTrack
                  ? Border.all(color: AppColors.neonIndigo, width: 2)
                  : null,
            ),
            child: Icon(
              _isCurrentTrack ? Icons.play_arrow_rounded : Icons.music_note_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: _isCurrentTrack ? 0.9 : 0.4),
              size: 22,
            ),
          ),
        ),
        title: Text(
          AudioExtensions.titleFromPath(widget.song.filePath),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          widget.song.artist.isNotEmpty && widget.song.artist != 'Unknown Artist'
              ? widget.song.artist
              : 'Unknown Artist',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(widget.song.durationMs),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => _toggleFavorite(context),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    size: 18,
                    color: _isFavorite ? AppColors.neonRose : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showSongMenu(context),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
        onTap: () => _playSong(context),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      final repo = await ref.read(musicRepositoryProvider.future);
      await repo.toggleFavorite(widget.song.filePath);
      final newState = !_isFavorite;
      setState(() => _isFavorite = newState);
      ref.invalidate(favoritesProvider);
      ref.invalidate(allSongsProvider);
      ref.invalidate(isFavoriteProvider(widget.song.filePath));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _playSong(BuildContext context) {
    final handler = ref.read(audioHandlerProvider);
    final allSongs = ref.read(allSongsProvider).valueOrNull ?? [];
    final idx = allSongs.indexWhere((s) => s.filePath == widget.song.filePath);
    if (idx >= 0) {
      handler.setQueue(
        allSongs.map((s) => QueueItem(
          path: s.filePath,
          title: AudioExtensions.titleFromPath(s.filePath),
          artist: s.artist.isNotEmpty && s.artist != 'Unknown Artist' ? s.artist : '',
        )).toList(),
        startIndex: idx,
      );
    }
    final title = AudioExtensions.titleFromPath(widget.song.filePath);
    final artist = widget.song.artist.isNotEmpty && widget.song.artist != 'Unknown Artist'
        ? widget.song.artist
        : '';
    handler.setFilePath(widget.song.filePath, title: title, artist: artist);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenPlayerPage(
          filePath: widget.song.filePath,
          title: title,
          artist: artist,
        ),
      ),
    );
  }

  void _showSongMenu(BuildContext context) {
    PremiumBottomSheet.show(
      context,
      builder: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.blueToIndigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.music_note_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AudioExtensions.titleFromPath(widget.song.filePath),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      if (widget.song.artist.isNotEmpty && widget.song.artist != 'Unknown Artist')
                        Text(widget.song.artist,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
          PremiumActionSheetTile(
            icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            label: _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            color: AppColors.neonRose,
            onTap: () {
              Navigator.of(context).pop();
              _toggleFavorite(context);
            },
          ),
          PremiumActionSheetTile(
            icon: Icons.playlist_add_rounded,
            label: 'Add to Playlist',
            color: AppColors.neonIndigo,
            onTap: () {
              Navigator.of(context).pop();
              _showAddToPlaylistSheet(context);
            },
          ),
          PremiumActionSheetTile(
            icon: Icons.timer_rounded,
            label: 'Play Next',
            color: AppColors.neonBlue,
            onTap: () {
              Navigator.of(context).pop();
              _playNext();
            },
          ),
          PremiumActionSheetTile(
            icon: Icons.edit_rounded,
            label: 'Edit Info',
            color: AppColors.neonIndigo,
            onTap: () {
              Navigator.of(context).pop();
              _showEditDialog(context);
            },
          ),
          PremiumActionSheetTile(
            icon: Icons.delete_rounded,
            label: 'Delete',
            color: AppColors.neonRose,
            onTap: () {
              Navigator.of(context).pop();
              _deleteSong(context);
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _showAddToPlaylistSheet(BuildContext context) async {
    final playlists = await ref.read(allPlaylistsProvider.future);
    if (!mounted) return;

    PremiumBottomSheet.show(
      context,
      builder: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.playlist_add_rounded, size: 18, color: AppColors.neonIndigo),
                    SizedBox(width: 8),
                    Text(
                      'Add to Playlist',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final name = await PremiumInputDialog.show(
                      context,
                      title: 'New Playlist',
                      hintText: 'Playlist name',
                      confirmLabel: 'Create',
                    );
                    if (name != null && name.isNotEmpty) {
                      final repo = await ref.read(musicRepositoryProvider.future);
                      final id = await repo.createPlaylist(name);
                      await repo.addSongToPlaylist(id, widget.song.filePath);
                      ref.invalidate(allPlaylistsProvider);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonIndigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'New',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
          if (playlists.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No playlists yet',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            )
          else
            ...playlists.map((p) => GestureDetector(
              onTap: () async {
                final repo = await ref.read(musicRepositoryProvider.future);
                await repo.addSongToPlaylist(p.id, widget.song.filePath);
                ref.invalidate(allPlaylistsProvider);
                if (mounted) Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to "${p.name}"'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.neonIndigo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.queue_music_rounded, size: 18, color: AppColors.neonIndigo),
                    ),
                    SizedBox(width: 12),
                    Text(
                      p.name,
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85)),
                    ),
                    Spacer(),
                    Text(
                      '${p.songCount}',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
              ),
            )),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _playNext() {
    final handler = ref.read(audioHandlerProvider);
    final queue = handler.trackQueue;
    final currentIdx = handler.currentIndex;
    final newQueue = List<QueueItem>.from(queue);
    newQueue.insert(
      currentIdx + 1,
      QueueItem(
        path: widget.song.filePath,
        title: AudioExtensions.titleFromPath(widget.song.filePath),
        artist: widget.song.artist,
      ),
    );
    handler.setQueue(newQueue, startIndex: currentIdx);
  }

  Future<void> _deleteSong(BuildContext context) async {
    final confirm = await PremiumConfirmDialog.show(
      context,
      title: 'Delete Song',
      message: 'Are you sure you want to delete "${AudioExtensions.titleFromPath(widget.song.filePath)}"?',
      confirmLabel: 'Delete',
      icon: Icons.delete_rounded,
      confirmColor: AppColors.neonRose,
    );
    if (confirm != true) return;
    try {
      final repo = await ref.read(musicRepositoryProvider.future);
      await repo.deleteSong(widget.song.id, widget.song.filePath);
      ref.invalidate(allSongsProvider);
      ref.invalidate(favoritesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.neonRose,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final titleCtrl = TextEditingController(text: AudioExtensions.titleFromPath(widget.song.filePath));
    final artistCtrl = TextEditingController(text: widget.song.artist != 'Unknown Artist' ? widget.song.artist : '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.54)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).colorScheme.primary)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: artistCtrl,
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Artist',
                labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.54)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).colorScheme.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.54)))),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Save', style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
          ),
        ],
      ),
    );
    if (result != true) return;
    try {
      final repo = await ref.read(musicRepositoryProvider.future);
      await repo.updateSongMetadata(
        widget.song.id,
        title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : null,
        artist: artistCtrl.text.trim().isNotEmpty ? artistCtrl.text.trim() : null,
      );
      ref.invalidate(allSongsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.neonRose,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _formatDuration(int ms) {
    if (ms <= 0) return '--:--';
    final sec = ms ~/ 1000;
    final min = sec ~/ 60;
    return '${min.toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
  }
}

class _AlbumCard extends ConsumerWidget {
  final Album album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(preferencesProvider).accentColor;
    return GestureDetector(
      onTap: () {
        _showAlbumDetail(context, ref, album);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.primary.withValues(alpha: 0.6), accent.secondary.withValues(alpha: 0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.album_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent.primary, accent.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Text(
                album.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                '${album.artist} • ${album.songCount} songs',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAlbumDetail(BuildContext context, WidgetRef ref, Album album) {
    PremiumBottomSheet.show(
      context,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      builder: AlbumDetailSheet(album: album),
    );
  }
}

class AlbumDetailSheet extends ConsumerWidget {
  final Album album;

  const AlbumDetailSheet({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsByAlbumProvider(album.title));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.neonIndigo.withValues(alpha: 0.5), AppColors.neonRose.withValues(alpha: 0.3)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.album_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(album.title,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text('${album.artist} • ${album.songCount} songs',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
        Flexible(
          child: songsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppColors.neonRose))),
            data: (songs) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, i) {
                final song = songs[i];
                return ListTile(
                  leading: Container(
                    width: 28, height: 28,
                    alignment: Alignment.center,
                    child: Text('${song.trackNumber ?? i + 1}',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ),
                  title: Text(song.title,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_formatDuration(song.durationMs),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
                  ),
                  dense: true,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDuration(int ms) {
    if (ms <= 0) return '--:--';
    final sec = ms ~/ 1000;
    final min = sec ~/ 60;
    return '${min.toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
  }
}

class _ArtistCard extends StatelessWidget {
  final Artist artist;

  const _ArtistCard({required this.artist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PremiumBottomSheet.show(
          context,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          builder: ArtistDetailSheet(artist: artist),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(Icons.person_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                artist.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${artist.songCount} songs',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistDetailSheet extends ConsumerWidget {
  final Artist artist;

  const ArtistDetailSheet({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsByArtistProvider(artist.name));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  ),
                ),
                child: Icon(Icons.person_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(artist.name,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    Text('${artist.songCount} songs • ${artist.albumCount} albums',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
        Flexible(
          child: songsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppColors.neonRose))),
            data: (songs) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, i) => ListTile(
                leading: Icon(Icons.music_note_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                title: Text(songs[i].title,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(songs[i].albumTitle,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
                ),
                dense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenreCard extends StatelessWidget {
  final Genre genre;

  const _GenreCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PremiumBottomSheet.show(
          context,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          builder: GenreDetailSheet(genre: genre),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                ),
                child: Icon(Icons.category_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      genre.name.isNotEmpty ? genre.name[0].toUpperCase() + genre.name.substring(1) : 'Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${genre.songCount} songs',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class GenreDetailSheet extends ConsumerWidget {
  final Genre genre;

  const GenreDetailSheet({super.key, required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsByGenreProvider(genre.name));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                ),
                child: Icon(Icons.category_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(genre.name.isNotEmpty ? genre.name[0].toUpperCase() + genre.name.substring(1) : 'Unknown',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    Text('${genre.songCount} songs',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
        Flexible(
          child: songsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppColors.neonRose))),
            data: (songs) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, i) => ListTile(
                leading: Icon(Icons.music_note_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                title: Text(songs[i].title,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(songs[i].artist,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
                ),
                dense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreatePlaylistTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final name = await PremiumInputDialog.show(
          context,
          title: 'New Playlist',
          hintText: 'Playlist name',
          confirmLabel: 'Create',
        );
        if (name != null && name.isNotEmpty) {
          try {
            final repo = await ref.read(musicRepositoryProvider.future);
            await repo.createPlaylist(name);
            ref.invalidate(allPlaylistsProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playlist "$name" created'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonIndigo.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.neonIndigo.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.add_rounded, size: 22, color: AppColors.neonIndigo),
          ),
          title: Text(
            'Create Playlist',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: Text(
            'Organize your music',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neonIndigo.withValues(alpha: 0.5),
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.neonIndigo.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  final PlaylistEntry playlist;

  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showPlaylistDetail(context, ref, playlist),
      onLongPress: () => _showPlaylistMenu(context, ref, playlist),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [AppColors.neonIndigo.withValues(alpha: 0.5), AppColors.neonBlue.withValues(alpha: 0.3)],
              ),
            ),
            child: Icon(Icons.queue_music_rounded, size: 22, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          title: Text(
            playlist.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${playlist.songCount} songs',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  static void _showPlaylistDetail(BuildContext context, WidgetRef ref, PlaylistEntry playlist) {
    PremiumBottomSheet.show(
      context,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      builder: PlaylistDetailSheet(playlist: playlist),
    );
  }

  static void _showPlaylistMenu(BuildContext context, WidgetRef ref, PlaylistEntry playlist) {
    PremiumBottomSheet.show(
      context,
      builder: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [AppColors.neonIndigo.withValues(alpha: 0.5), AppColors.neonBlue.withValues(alpha: 0.3)],
                    ),
                  ),
                  child: Icon(Icons.queue_music_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(playlist.name,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      Text('${playlist.songCount} songs',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
          PremiumActionSheetTile(
            icon: Icons.edit_rounded,
            label: 'Rename',
            color: AppColors.neonIndigo,
            onTap: () async {
              Navigator.of(context).pop();
              final name = await PremiumInputDialog.show(
                context,
                title: 'Rename Playlist',
                hintText: playlist.name,
                initialValue: playlist.name,
                confirmLabel: 'Rename',
              );
              if (name != null && name.isNotEmpty && name != playlist.name) {
                final repo = await ref.read(musicRepositoryProvider.future);
                await repo.renamePlaylist(playlist.id, name);
                ref.invalidate(allPlaylistsProvider);
              }
            },
          ),
          PremiumActionSheetTile(
            icon: Icons.delete_rounded,
            label: 'Delete Playlist',
            color: AppColors.neonRose,
            onTap: () async {
              Navigator.of(context).pop();
              final confirm = await PremiumConfirmDialog.show(
                context,
                title: 'Delete Playlist',
                message: 'Are you sure you want to delete "${playlist.name}"?',
                confirmLabel: 'Delete',
                icon: Icons.delete_rounded,
                confirmColor: AppColors.neonRose,
              );
              if (confirm == true) {
                final repo = await ref.read(musicRepositoryProvider.future);
                await repo.deletePlaylist(playlist.id);
                ref.invalidate(allPlaylistsProvider);
              }
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class PlaylistDetailSheet extends ConsumerWidget {
  final PlaylistEntry playlist;

  const PlaylistDetailSheet({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSongsAsync = ref.watch(allSongsProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [AppColors.neonIndigo.withValues(alpha: 0.5), AppColors.neonBlue.withValues(alpha: 0.3)],
                  ),
                ),
                child: Icon(Icons.queue_music_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playlist.name,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text('${playlist.songCount} songs',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
        Flexible(
          child: allSongsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppColors.neonRose))),
            data: (allSongs) {
              final songPaths = playlist.songPaths;
              final songs = allSongs.where((s) => songPaths.contains(s.filePath)).toList();
              if (songs.isEmpty) {
                return Center(
                  child: Text('No songs in this playlist',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, i) {
                  final song = songs[i];
                  return ListTile(
                    leading: Icon(Icons.music_note_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    title: Text(song.title,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(song.artist,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
                    ),
                    trailing: GestureDetector(
                      onTap: () async {
                        final repo = await ref.read(musicRepositoryProvider.future);
                        await repo.removeSongFromPlaylist(playlist.id, song.filePath);
                        ref.invalidate(allPlaylistsProvider);
                      },
                      child: Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.neonRose.withValues(alpha: 0.5)),
                    ),
                    dense: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
