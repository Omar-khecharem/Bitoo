import 'dart:async';
import '../../domain/entities/audio_engine_state.dart';
import '../../domain/entities/preset_config.dart';
import '../../domain/services/audio_engine_service.dart';
import '../datasources/audio_engine_method_channel.dart';
import '../models/preset_model.dart';

class AudioEngineServiceImpl implements AudioEngineService {
  final AudioEngineMethodChannel _channel;
  final StreamController<AudioEngineState> _stateController =
      StreamController<AudioEngineState>.broadcast();

  AudioEngineState _state = const AudioEngineInitial();

  AudioEngineState get currentState => _state;

  AudioEngineServiceImpl({AudioEngineMethodChannel? channel})
      : _channel = channel ?? AudioEngineMethodChannel();

  @override
  Future<void> init(int audioSessionId) async {
    try {
      await _channel.init(audioSessionId);
      _state = const AudioEngineReady();
      _stateController.add(_state);
    } catch (e) {
      _state = AudioEngineUnavailable(e.toString());
      _stateController.add(_state);
    }
  }

  @override
  Future<void> release() async {
    await _channel.release();
    _state = const AudioEngineInitial();
    _stateController.add(_state);
  }

  @override
  Future<bool> isEqualizerAvailable() async =>
      _channel.isEffectAvailable('equalizer');

  @override
  Future<bool> isBassBoostAvailable() async =>
      _channel.isEffectAvailable('bassBoost');

  @override
  Future<bool> isVirtualizerAvailable() async =>
      _channel.isEffectAvailable('virtualizer');

  @override
  Future<bool> isLoudnessEnhancerAvailable() async =>
      _channel.isEffectAvailable('loudnessEnhancer');

  @override
  Future<bool> isHiResSupported(
          String mimeType, int sampleRate, int bitDepth) async =>
      _channel.isHiResSupported(mimeType, sampleRate, bitDepth);

  @override
  Future<void> setEnabled(bool enabled) async {
    await _channel.setEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(
        eqEnabled: enabled,
        bassBoostEnabled: enabled,
        virtualizerEnabled: enabled,
        loudnessEnabled: enabled,
      );
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setEqualizerEnabled(bool enabled) async {
    await _channel.setEqualizerEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(eqEnabled: enabled);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setBassBoostEnabled(bool enabled) async {
    await _channel.setBassBoostEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(bassBoostEnabled: enabled);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setVirtualizerEnabled(bool enabled) async {
    await _channel.setVirtualizerEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state =
          (_state as AudioEngineReady).copyWith(virtualizerEnabled: enabled);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setLoudnessEnabled(bool enabled) async {
    await _channel.setLoudnessEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(loudnessEnabled: enabled);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setVolumeNormalizationEnabled(bool enabled) async {
    await _channel.setVolumeNormalizationEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady)
          .copyWith(volumeNormalizationEnabled: enabled);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setBandLevel(int bandIndex, int millibels) async {
    await _channel.setBandLevel(bandIndex, millibels);
    if (_state is AudioEngineReady) {
      _state =
          (_state as AudioEngineReady).withBand(bandIndex, millibels / 100.0);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setBandLevels(List<int> millibels) async {
    await _channel.setBandLevels(millibels);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(
        eqBands: millibels.map((m) => m / 100.0).toList(),
        activePreset: 'custom',
      );
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setBassBoostStrength(int strength) async {
    await _channel.setBassBoostStrength(strength);
    if (_state is AudioEngineReady) {
      _state =
          (_state as AudioEngineReady).copyWith(bassBoostStrength: strength);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setVirtualizerStrength(int strength) async {
    await _channel.setVirtualizerStrength(strength);
    if (_state is AudioEngineReady) {
      _state =
          (_state as AudioEngineReady).copyWith(virtualizerStrength: strength);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setLoudnessGain(int gainMillibels) async {
    await _channel.setLoudnessGain(gainMillibels);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady)
          .copyWith(loudnessGainMillibels: gainMillibels);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> applyPreset(PresetConfig preset) async {
    final model = PresetModel.fromPresetConfig(preset);
    await _channel.setBandLevels(model.bandMillibels);
    await _channel.setBassBoostStrength(model.bassBoostStrength);
    await _channel.setVirtualizerStrength(model.virtualizerStrength);
    await _channel.setEqualizerEnabled(true);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).withAppliedPreset(preset);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> resetToFlat() async {
    await applyPreset(const PresetConfig(
      name: 'flat',
      label: 'Flat',
      bands: PresetConfig.flat,
      bassBoost: 0,
      virtualizerStrength: 0,
    ));
  }

  @override
  Future<void> setCrossfadeDuration(double seconds) async {
    await _channel.setCrossfadeDuration(seconds);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady)
          .copyWith(crossfadeDurationSeconds: seconds);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setGaplessEnabled(bool enabled) async {
    await _channel.setGaplessEnabled(enabled);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(gaplessEnabled: enabled);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setHiResMode(HiResMode mode) async {
    await _channel.setHiResMode(mode.name);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(hiResMode: mode);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setOutputFormat(AudioOutputFormat format) async {
    await _channel.setOutputFormat(format.name, format.bytesPerSample);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(outputFormat: format);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setReplayGain(
      double trackGain, double albumGain, ReplayGainMode mode) async {
    await _channel.setReplayGain(trackGain, albumGain, mode.name);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(
        trackGain: trackGain,
        albumGain: albumGain,
        replayGainMode: mode,
      );
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setSampleRate(int sampleRate) async {
    await _channel.setSampleRate(sampleRate);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(sampleRate: sampleRate);
      _stateController.add(_state);
    }
  }

  @override
  Future<void> setBufferSize(int frames) async {
    await _channel.setBufferSize(frames);
    if (_state is AudioEngineReady) {
      _state = (_state as AudioEngineReady).copyWith(bufferSizeFrames: frames);
      _stateController.add(_state);
    }
  }

  @override
  Future<List<int>> getBandLevels() => _channel.getBandLevels();

  @override
  Future<List<int>> getCenterFrequencies() => _channel.getCenterFrequencies();

  @override
  Future<List<int>> getFrequencyRange() => _channel.getFrequencyRange();

  @override
  Future<int> getNumberOfBands() => _channel.getNumberOfBands();

  @override
  Future<int> getCurrentPreset() => _channel.getCurrentPreset();

  @override
  Future<String> getDeviceInfo() => _channel.getDeviceInfo();

  @override
  Stream<AudioEngineState> observeState() => _stateController.stream;
}
