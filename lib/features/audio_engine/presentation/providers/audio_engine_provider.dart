import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_engine_method_channel.dart';
import '../../data/repositories/audio_engine_service_impl.dart';
import '../../domain/entities/audio_engine_state.dart';
import '../../domain/entities/preset_config.dart';
import '../../domain/services/audio_engine_service.dart';

final audioEngineMethodChannelProvider = Provider<AudioEngineMethodChannel>((ref) {
  return AudioEngineMethodChannel();
});

final audioEngineServiceProvider = Provider<AudioEngineService>((ref) {
  final channel = ref.watch(audioEngineMethodChannelProvider);
  return AudioEngineServiceImpl(channel: channel);
});

final audioEngineStateProvider = StreamProvider<AudioEngineState>((ref) {
  final service = ref.watch(audioEngineServiceProvider) as AudioEngineServiceImpl;
  return service.observeState();
});

final audioEngineReadyProvider = Provider<AudioEngineReady?>((ref) {
  final asyncState = ref.watch(audioEngineStateProvider);
  return asyncState.valueOrNull is AudioEngineReady
      ? asyncState.valueOrNull as AudioEngineReady
      : null;
});

final audioEngineNotifierProvider = StateNotifierProvider<AudioEngineNotifier, AudioEngineState>((ref) {
  final service = ref.watch(audioEngineServiceProvider);
  return AudioEngineNotifier(service);
});

class AudioEngineNotifier extends StateNotifier<AudioEngineState> {
  final AudioEngineService _service;

  AudioEngineNotifier(this._service) : super(const AudioEngineInitial());

  Future<void> init(int audioSessionId) async {
    await _service.init(audioSessionId);
  }

  Future<void> release() async {
    await _service.release();
    state = const AudioEngineInitial();
  }

  Future<void> toggleEqualizer() async {
    if (state is! AudioEngineReady) return;
    final ready = state as AudioEngineReady;
    await _service.setEqualizerEnabled(!ready.eqEnabled);
  }

  Future<void> toggleBassBoost() async {
    if (state is! AudioEngineReady) return;
    final ready = state as AudioEngineReady;
    await _service.setBassBoostEnabled(!ready.bassBoostEnabled);
  }

  Future<void> toggleVirtualizer() async {
    if (state is! AudioEngineReady) return;
    final ready = state as AudioEngineReady;
    await _service.setVirtualizerEnabled(!ready.virtualizerEnabled);
  }

  Future<void> toggleLoudness() async {
    if (state is! AudioEngineReady) return;
    final ready = state as AudioEngineReady;
    await _service.setLoudnessEnabled(!ready.loudnessEnabled);
  }

  Future<void> toggleVolumeNormalization() async {
    if (state is! AudioEngineReady) return;
    final ready = state as AudioEngineReady;
    await _service.setVolumeNormalizationEnabled(!ready.volumeNormalizationEnabled);
  }

  Future<void> toggleGapless() async {
    if (state is! AudioEngineReady) return;
    final ready = state as AudioEngineReady;
    await _service.setGaplessEnabled(!ready.gaplessEnabled);
  }

  Future<void> setBand(int index, double value) async {
    if (state is! AudioEngineReady) return;
    await _service.setBandLevel(index, (value * 100).round());
    if (state is AudioEngineReady) {
      state = (state as AudioEngineReady).withBand(index, value);
    }
  }

  Future<void> setBassStrength(double value) async {
    if (state is! AudioEngineReady) return;
    final strength = (value * 1000).round();
    await _service.setBassBoostStrength(strength);
  }

  Future<void> setVirtualizerStrength(double value) async {
    if (state is! AudioEngineReady) return;
    final strength = (value * 1000).round();
    await _service.setVirtualizerStrength(strength);
  }

  Future<void> setCrossfadeDuration(double seconds) async {
    await _service.setCrossfadeDuration(seconds);
  }

  Future<void> applyPreset(PresetConfig preset) async {
    await _service.applyPreset(preset);
    if (state is AudioEngineReady) {
      state = (state as AudioEngineReady).withAppliedPreset(preset);
    }
  }

  Future<void> setHiResMode(HiResMode mode) async {
    await _service.setHiResMode(mode);
  }

  Future<void> setOutputFormat(AudioOutputFormat format) async {
    await _service.setOutputFormat(format);
  }

  Future<void> setSampleRate(int sampleRate) async {
    await _service.setSampleRate(sampleRate);
  }

  Future<void> setBufferSize(int frames) async {
    await _service.setBufferSize(frames);
  }

  Future<void> resetAll() async {
    await _service.resetToFlat();
    await _service.setEqualizerEnabled(false);
    await _service.setBassBoostEnabled(false);
    await _service.setVirtualizerEnabled(false);
    await _service.setLoudnessEnabled(false);
    await _service.setVolumeNormalizationEnabled(false);
    await _service.setCrossfadeDuration(0);
  }
}
