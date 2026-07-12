import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/playback_state.dart' show RepeatMode;

class QueueItem {
  final String path;
  final String title;
  final String artist;
  const QueueItem({required this.path, this.title = '', this.artist = ''});
}

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  String _currentPath = '';
  String _currentTitle = '';
  String _currentArtist = '';

  List<QueueItem> _queue = [];
  int _currentIndex = 0;

  RepeatMode _repeatMode = RepeatMode.all;
  bool _isShuffled = false;
  List<int> _shuffledIndices = [];
  int _shuffleIndex = 0;

  String? _lastPlaybackError;
  final StreamController<String?> _errorController =
      StreamController<String?>.broadcast();

  String get currentPath => _currentPath;
  String get currentTitle => _currentTitle;
  String get currentArtist => _currentArtist;
  List<QueueItem> get trackQueue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  RepeatMode get repeatMode => _repeatMode;
  bool get isShuffled => _isShuffled;
  String? get lastPlaybackError => _lastPlaybackError;
  Stream<String?> get errorStream => _errorController.stream;

  void _reportError(String? msg) {
    _lastPlaybackError = msg;
    _errorController.add(msg);
    if (msg != null) debugPrint('[AudioHandler] $msg');
  }

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
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.pause,
          MediaControl.skipToNext,
        ],
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

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  void setQueue(List<QueueItem> items, {int startIndex = 0}) {
    _queue = List.from(items);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    _buildShuffledIndices();
  }

  void changeRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    if (_repeatMode == RepeatMode.one && !_player.playing) {
      _player.play();
    }
  }

  void setShuffle(bool enabled) {
    _isShuffled = enabled;
    if (enabled) {
      _buildShuffledIndices();
      _shuffleIndex = _shuffledIndices.indexOf(_currentIndex);
      if (_shuffleIndex < 0) _shuffleIndex = 0;
    }
  }

  void _buildShuffledIndices() {
    if (_queue.length <= 1) {
      _shuffledIndices = [for (int i = 0; i < _queue.length; i++) i];
      return;
    }
    _shuffledIndices = [for (int i = 0; i < _queue.length; i++) i];
    _shuffledIndices.shuffle(_random);
  }

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_isShuffled) {
      if (_shuffleIndex < _shuffledIndices.length - 1) {
        _shuffleIndex++;
      } else {
        if (_repeatMode == RepeatMode.none) return;
        _shuffleIndex = 0;
      }
      _currentIndex = _shuffledIndices[_shuffleIndex];
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else {
        if (_repeatMode == RepeatMode.none) {
          await pause();
          return;
        }
        _currentIndex = 0;
      }
    }
    await _playCurrent();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_isShuffled) {
      if (_shuffleIndex > 0) {
        _shuffleIndex--;
      } else {
        if (_repeatMode == RepeatMode.none) return;
        _shuffleIndex = _shuffledIndices.length - 1;
      }
      _currentIndex = _shuffledIndices[_shuffleIndex];
    } else {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        if (_repeatMode == RepeatMode.none) return;
        _currentIndex = _queue.length - 1;
      }
    }
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final item = _queue[_currentIndex];
    _currentPath = item.path;
    _currentTitle = item.title;
    _currentArtist = item.artist;
    try {
      final file = File(item.path);
      if (!await file.exists()) {
        _reportError('Fichier introuvable: ${item.path}');
        await _autoSkip();
        return;
      }
      await _playFile(file, item.path);
      mediaItem.add(MediaItem(
        id: item.path,
        title: item.title.isNotEmpty ? item.title : 'Unknown Track',
        artist: item.artist.isNotEmpty ? item.artist : 'Unknown Artist',
      ));
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.pause,
          MediaControl.skipToNext,
        ],
      ));
      await _player.play();
      _reportError(null);
    } catch (e, stack) {
      _reportError('Échec lecture ${item.path}: $e');
      debugPrint('[AudioHandler] Stack: $stack');
      await _autoSkip();
    }
  }

  Future<void> _playFile(File file, String originalPath) async {
    try {
      await _player.setFilePath(originalPath);
    } catch (e) {
      debugPrint(
          '[AudioHandler] setFilePath failed ($e), trying cache copy...');
      final dir = await getTemporaryDirectory();
      final cachePath = '${dir.path}/bitoo_cache_$_currentIndex.mp3';
      try {
        await file.copy(cachePath);
        await _player.setFilePath(cachePath);
      } catch (e2) {
        debugPrint('[AudioHandler] cache copy also failed: $e2');
        rethrow;
      }
    }
  }

  Future<void> _autoSkip() async {
    if (_queue.length <= 1) return;
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _queue.length) {
      _currentIndex = nextIndex;
      await _playCurrent();
    }
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

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> setFilePath(String path,
      {String title = '', String artist = ''}) async {
    final idx = _queue.indexWhere((item) => item.path == path);
    if (idx >= 0) {
      _currentIndex = idx;
    }
    _currentPath = path;
    _currentTitle = title;
    _currentArtist = artist;
    try {
      final file = File(path);
      if (!await file.exists()) {
        _reportError('Fichier introuvable: $path');
        return;
      }
      await _playFile(file, path);
      mediaItem.add(MediaItem(
        id: path,
        title: title.isNotEmpty ? title : 'Unknown Track',
        artist: artist.isNotEmpty ? artist : 'Unknown Artist',
      ));
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.pause,
          MediaControl.skipToNext,
        ],
      ));
      await _player.play();
      _reportError(null);
    } catch (e, stack) {
      _reportError('Échec lecture $path: $e');
      debugPrint('[AudioHandler] Stack: $stack');
    }
  }
}
