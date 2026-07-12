import 'preset_config.dart';

sealed class AudioEngineState {
  const AudioEngineState();
}

class AudioEngineInitial extends AudioEngineState {
  const AudioEngineInitial();
}

class AudioEngineReady extends AudioEngineState {
  final bool eqEnabled;
  final List<double> eqBands;
  final String activePreset;
  final bool bassBoostEnabled;
  final int bassBoostStrength;
  final bool virtualizerEnabled;
  final int virtualizerStrength;
  final bool loudnessEnabled;
  final int loudnessGainMillibels;
  final bool volumeNormalizationEnabled;
  final double crossfadeDurationSeconds;
  final bool gaplessEnabled;
  final HiResMode hiResMode;
  final AudioOutputFormat outputFormat;
  final int sampleRate;
  final int bufferSizeFrames;
  final double trackGain;
  final double albumGain;
  final bool replayGainEnabled;
  final ReplayGainMode replayGainMode;

  const AudioEngineReady({
    this.eqEnabled = false,
    this.eqBands = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.activePreset = 'flat',
    this.bassBoostEnabled = false,
    this.bassBoostStrength = 0,
    this.virtualizerEnabled = false,
    this.virtualizerStrength = 0,
    this.loudnessEnabled = false,
    this.loudnessGainMillibels = 0,
    this.volumeNormalizationEnabled = false,
    this.crossfadeDurationSeconds = 0.0,
    this.gaplessEnabled = true,
    this.hiResMode = HiResMode.off,
    this.outputFormat = AudioOutputFormat.pcm16Bit,
    this.sampleRate = 48000,
    this.bufferSizeFrames = 1024,
    this.trackGain = 0.0,
    this.albumGain = 0.0,
    this.replayGainEnabled = false,
    this.replayGainMode = ReplayGainMode.track,
  });

  AudioEngineReady copyWith({
    bool? eqEnabled,
    List<double>? eqBands,
    String? activePreset,
    bool? bassBoostEnabled,
    int? bassBoostStrength,
    bool? virtualizerEnabled,
    int? virtualizerStrength,
    bool? loudnessEnabled,
    int? loudnessGainMillibels,
    bool? volumeNormalizationEnabled,
    double? crossfadeDurationSeconds,
    bool? gaplessEnabled,
    HiResMode? hiResMode,
    AudioOutputFormat? outputFormat,
    int? sampleRate,
    int? bufferSizeFrames,
    double? trackGain,
    double? albumGain,
    bool? replayGainEnabled,
    ReplayGainMode? replayGainMode,
  }) => AudioEngineReady(
    eqEnabled: eqEnabled ?? this.eqEnabled,
    eqBands: eqBands ?? this.eqBands,
    activePreset: activePreset ?? this.activePreset,
    bassBoostEnabled: bassBoostEnabled ?? this.bassBoostEnabled,
    bassBoostStrength: bassBoostStrength ?? this.bassBoostStrength,
    virtualizerEnabled: virtualizerEnabled ?? this.virtualizerEnabled,
    virtualizerStrength: virtualizerStrength ?? this.virtualizerStrength,
    loudnessEnabled: loudnessEnabled ?? this.loudnessEnabled,
    loudnessGainMillibels: loudnessGainMillibels ?? this.loudnessGainMillibels,
    volumeNormalizationEnabled: volumeNormalizationEnabled ?? this.volumeNormalizationEnabled,
    crossfadeDurationSeconds: crossfadeDurationSeconds ?? this.crossfadeDurationSeconds,
    gaplessEnabled: gaplessEnabled ?? this.gaplessEnabled,
    hiResMode: hiResMode ?? this.hiResMode,
    outputFormat: outputFormat ?? this.outputFormat,
    sampleRate: sampleRate ?? this.sampleRate,
    bufferSizeFrames: bufferSizeFrames ?? this.bufferSizeFrames,
    trackGain: trackGain ?? this.trackGain,
    albumGain: albumGain ?? this.albumGain,
    replayGainEnabled: replayGainEnabled ?? this.replayGainEnabled,
    replayGainMode: replayGainMode ?? this.replayGainMode,
  );

  AudioEngineReady withAppliedPreset(PresetConfig preset) => copyWith(
    activePreset: preset.name,
    eqBands: preset.bands,
    bassBoostStrength: (preset.bassBoost * 1000).round(),
    virtualizerStrength: (preset.virtualizerStrength * 1000).round(),
    loudnessGainMillibels: preset.loudnessTargetGain ?? loudnessGainMillibels,
  );

  AudioEngineReady withBand(int index, double value) {
    final newBands = List<double>.from(eqBands);
    newBands[index] = value;
    return copyWith(eqBands: newBands, activePreset: 'custom');
  }
}

enum HiResMode {
  off(0, 'Off'),
  pcm24(1, '24-bit PCM'),
  pcm32(2, '32-bit PCM'),
  pcmFloat(3, '32-bit Float');

  final int value;
  final String label;
  const HiResMode(this.value, this.label);
}

enum AudioOutputFormat {
  pcm16Bit(2, '16-bit PCM', 16),
  pcm24Bit(3, '24-bit PCM', 24),
  pcm32Bit(4, '32-bit PCM', 32),
  pcmFloat(4, 'Float PCM', 32);

  final int bytesPerSample;
  final String label;
  final int bitDepth;
  const AudioOutputFormat(this.bytesPerSample, this.label, this.bitDepth);
}

enum ReplayGainMode { track, album }

class AudioEngineUnavailable extends AudioEngineState {
  final String reason;
  const AudioEngineUnavailable(this.reason);
}
