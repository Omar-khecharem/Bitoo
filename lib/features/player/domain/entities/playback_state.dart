// ── Playback State ──

sealed class PlaybackState {
  const PlaybackState();
}

class Idle extends PlaybackState {
  const Idle();
}

class Loading extends PlaybackState {
  const Loading();
}

class Playing extends PlaybackState {
  final String trackId;
  final Duration position;
  final Duration buffered;

  const Playing({
    required this.trackId,
    required this.position,
    required this.buffered,
  });
}

class Paused extends PlaybackState {
  final String trackId;
  final Duration position;

  const Paused({
    required this.trackId,
    required this.position,
  });
}

class Buffering extends PlaybackState {
  final String trackId;
  final Duration position;

  const Buffering({
    required this.trackId,
    required this.position,
  });
}

class PlayerError extends PlaybackState {
  final String message;
  final String? trackId;

  const PlayerError({
    required this.message,
    this.trackId,
  });
}

// ── Queue State ──

class QueueState {
  final List<String> trackIds;
  final int currentIndex;
  final RepeatMode repeatMode;
  final bool isShuffled;
  final List<String> shuffledIds;

  const QueueState({
    required this.trackIds,
    required this.currentIndex,
    this.repeatMode = RepeatMode.all,
    this.isShuffled = false,
    this.shuffledIds = const [],
  });

  QueueState copyWith({
    List<String>? trackIds,
    int? currentIndex,
    RepeatMode? repeatMode,
    bool? isShuffled,
    List<String>? shuffledIds,
  }) {
    return QueueState(
      trackIds: trackIds ?? this.trackIds,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffled: isShuffled ?? this.isShuffled,
      shuffledIds: shuffledIds ?? this.shuffledIds,
    );
  }
}

enum RepeatMode { none, one, all }

// ── Equalizer State ──

class EqualizerState {
  final EqualizerPreset activePreset;
  final List<double> bands;
  final double bass;
  final double virtualizer;
  final bool isEnabled;

  const EqualizerState({
    this.activePreset = EqualizerPreset.custom,
    this.bands = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.bass = 0.0,
    this.virtualizer = 0.0,
    this.isEnabled = false,
  });

  EqualizerState copyWith({
    EqualizerPreset? activePreset,
    List<double>? bands,
    double? bass,
    double? virtualizer,
    bool? isEnabled,
  }) {
    return EqualizerState(
      activePreset: activePreset ?? this.activePreset,
      bands: bands ?? this.bands,
      bass: bass ?? this.bass,
      virtualizer: virtualizer ?? this.virtualizer,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

enum EqualizerPreset {
  custom,
  normal,
  pop,
  rock,
  jazz,
  classical,
  dance,
  acoustic,
  vocal,
  bass,
  treble,
  flat,
}

// ── Audio Effects State ──

class AudioEffectsState {
  final double crossfadeDuration;
  final bool fadeInEnabled;
  final double fadeInDuration;
  final bool fadeOutEnabled;
  final double fadeOutDuration;

  const AudioEffectsState({
    this.crossfadeDuration = 0.0,
    this.fadeInEnabled = false,
    this.fadeInDuration = 3.0,
    this.fadeOutEnabled = false,
    this.fadeOutDuration = 5.0,
  });

  AudioEffectsState copyWith({
    double? crossfadeDuration,
    bool? fadeInEnabled,
    double? fadeInDuration,
    bool? fadeOutEnabled,
    double? fadeOutDuration,
  }) {
    return AudioEffectsState(
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      fadeInEnabled: fadeInEnabled ?? this.fadeInEnabled,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutEnabled: fadeOutEnabled ?? this.fadeOutEnabled,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
    );
  }
}

// ── Sleep Timer State ──

class SleepTimerState {
  final bool isActive;
  final Duration? duration;
  final Duration? remaining;
  final DateTime? endTime;
  final bool stopAfterTrack;

  const SleepTimerState({
    this.isActive = false,
    this.duration,
    this.remaining,
    this.endTime,
    this.stopAfterTrack = false,
  });

  SleepTimerState copyWith({
    bool? isActive,
    Duration? duration,
    Duration? remaining,
    DateTime? endTime,
    bool? stopAfterTrack,
  }) {
    return SleepTimerState(
      isActive: isActive ?? this.isActive,
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      endTime: endTime ?? this.endTime,
      stopAfterTrack: stopAfterTrack ?? this.stopAfterTrack,
    );
  }
}
