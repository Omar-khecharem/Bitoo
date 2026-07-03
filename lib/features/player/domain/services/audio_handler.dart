import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  String _currentPath = '';
  String _currentTitle = '';
  String _currentArtist = '';

  String get currentPath => _currentPath;
  String get currentTitle => _currentTitle;
  String get currentArtist => _currentArtist;

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    _player.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state.playing,
        processingState: switch (state.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
      ));
    });

    _player.positionStream.listen((pos) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: pos,
      ));
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        mediaItem.add(mediaItem.value?.copyWith(duration: dur));
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.dispose();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setFilePath(String path, {String title = '', String artist = ''}) async {
    _currentPath = path;
    _currentTitle = title;
    _currentArtist = artist;
    await _player.setFilePath(path);
    mediaItem.add(MediaItem(
      id: path,
      title: title.isNotEmpty ? title : 'Unknown Track',
      artist: artist.isNotEmpty ? artist : 'Unknown Artist',
    ));
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.play, MediaControl.pause],
    ));
    await _player.play();
  }
}
