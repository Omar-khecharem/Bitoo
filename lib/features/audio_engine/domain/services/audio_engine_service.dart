import '../entities/audio_engine_state.dart';
import '../entities/preset_config.dart';

abstract class AudioEngineService {
  Future<void> init(int audioSessionId);
  Future<void> release();

  Future<bool> isEqualizerAvailable();
  Future<bool> isBassBoostAvailable();
  Future<bool> isVirtualizerAvailable();
  Future<bool> isLoudnessEnhancerAvailable();
  Future<bool> isHiResSupported(String mimeType, int sampleRate, int bitDepth);

  Future<void> setEnabled(bool enabled);
  Future<void> setEqualizerEnabled(bool enabled);
  Future<void> setBassBoostEnabled(bool enabled);
  Future<void> setVirtualizerEnabled(bool enabled);
  Future<void> setLoudnessEnabled(bool enabled);
  Future<void> setVolumeNormalizationEnabled(bool enabled);

  Future<void> setBandLevel(int bandIndex, int millibels);
  Future<void> setBandLevels(List<int> millibels);
  Future<void> setBassBoostStrength(int strength);
  Future<void> setVirtualizerStrength(int strength);
  Future<void> setLoudnessGain(int gainMillibels);

  Future<void> applyPreset(PresetConfig preset);
  Future<void> resetToFlat();

  Future<void> setCrossfadeDuration(double seconds);
  Future<void> setGaplessEnabled(bool enabled);
  Future<void> setHiResMode(HiResMode mode);
  Future<void> setOutputFormat(AudioOutputFormat format);
  Future<void> setReplayGain(
      double trackGain, double albumGain, ReplayGainMode mode);
  Future<void> setSampleRate(int sampleRate);
  Future<void> setBufferSize(int frames);

  Future<List<int>> getBandLevels();
  Future<List<int>> getCenterFrequencies();
  Future<List<int>> getFrequencyRange();
  Future<int> getNumberOfBands();
  Future<int> getCurrentPreset();
  Future<String> getDeviceInfo();

  Stream<AudioEngineState> observeState();
}
