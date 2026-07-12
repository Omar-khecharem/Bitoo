import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/audio_handler.dart';

final audioHandlerProvider = Provider<AudioPlayerHandler>((ref) {
  return AudioPlayerHandler();
});

final currentSongProvider =
    Provider<({String path, String title, String artist})>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return (
    path: handler.currentPath,
    title: handler.currentTitle,
    artist: handler.currentArtist
  );
});
