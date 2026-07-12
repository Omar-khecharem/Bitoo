import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music_engine/domain/repositories/music_repository.dart';
import '../../../music_engine/presentation/providers/music_engine_provider.dart';

class HomeFeedState {
  final List<HomeSectionData> sections;
  final bool isLoading;
  final String? error;

  const HomeFeedState({
    this.sections = const [],
    this.isLoading = false,
    this.error,
  });

  HomeFeedState copyWith({
    List<HomeSectionData>? sections,
    bool? isLoading,
    String? error,
  }) {
    return HomeFeedState(
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeSectionData {
  final String title;
  final String id;
  final List<dynamic> items;

  const HomeSectionData({
    required this.title,
    required this.id,
    required this.items,
  });
}

class HomeFeedNotifier extends StateNotifier<HomeFeedState> {
  HomeFeedNotifier(this._ref) : super(const HomeFeedState(isLoading: true));

  final Ref _ref;
  MusicRepository? _repo;

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      _repo ??= await _ref.read(musicRepositoryProvider.future);
      if (_repo == null) {
        state =
            state.copyWith(isLoading: false, error: 'Repository not available');
        return;
      }

      // Load all sections in parallel
      final results = await Future.wait([
        _repo!.getRecentlyPlayed(limit: 5),
        _repo!.getAllSongs().then((s) {
          debugPrint('loadFeed: ${s.length} songs in DB');
          return s.take(10).toList();
        }),
        _repo!
            .getAllSongs()
            .then((s) => s.where((s) => s.playCount > 0).take(10).toList()),
        _repo!.getFavorites(),
        _repo!.getAllArtists(),
        _repo!.getAllAlbums(),
        _repo!.getAllGenres(),
      ]);

      state = HomeFeedState(
        sections: [
          HomeSectionData(
              title: 'Continue Listening',
              id: 'continue',
              items: results[1].take(3).toList()),
          HomeSectionData(
              title: 'Recently Played', id: 'recent', items: results[0]),
          HomeSectionData(
              title: 'Most Played', id: 'popular', items: results[2]),
          HomeSectionData(
              title: 'Favorite Songs', id: 'favorites', items: results[3]),
          HomeSectionData(
              title: 'Your Artists', id: 'artists', items: results[4]),
          HomeSectionData(
              title: 'Your Albums', id: 'albums', items: results[5]),
          HomeSectionData(title: 'Genres', id: 'genres', items: results[6]),
        ],
        isLoading: false,
      );
      debugPrint(
          'loadFeed state set: continue=${results[1].take(3).length} artists=${results[4].length} albums=${results[5].length} genres=${results[6].length}');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeFeedProvider =
    StateNotifierProvider<HomeFeedNotifier, HomeFeedState>((ref) {
  final notifier = HomeFeedNotifier(ref);
  notifier.loadFeed();
  return notifier;
});
