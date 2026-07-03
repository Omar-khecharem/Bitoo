import 'dart:async';
import 'package:flutter/services.dart';

class AudioEngineMethodChannel {
  static const _channel = MethodChannel('com.bitoo.bitoo/audio_engine');

  Future<void> init(int audioSessionId) async {
    await _channel.invokeMethod('init', {'audioSessionId': audioSessionId});
  }

  Future<void> release() async {
    await _channel.invokeMethod('release');
  }

  Future<bool> isEffectAvailable(String effect) async {
    final result = await _channel.invokeMethod<bool>('isEffectAvailable', {'effect': effect});
    return result ?? false;
  }

  Future<bool> isHiResSupported(String mimeType, int sampleRate, int bitDepth) async {
    final result = await _channel.invokeMethod<bool>('isHiResSupported', {
      'mimeType': mimeType,
      'sampleRate': sampleRate,
      'bitDepth': bitDepth,
    });
    return result ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    await _channel.invokeMethod('setEnabled', {'enabled': enabled});
  }

  Future<void> setEqualizerEnabled(bool enabled) async {
    await _channel.invokeMethod('setEqualizerEnabled', {'enabled': enabled});
  }

  Future<void> setBassBoostEnabled(bool enabled) async {
    await _channel.invokeMethod('setBassBoostEnabled', {'enabled': enabled});
  }

  Future<void> setVirtualizerEnabled(bool enabled) async {
    await _channel.invokeMethod('setVirtualizerEnabled', {'enabled': enabled});
  }

  Future<void> setLoudnessEnabled(bool enabled) async {
    await _channel.invokeMethod('setLoudnessEnabled', {'enabled': enabled});
  }

  Future<void> setVolumeNormalizationEnabled(bool enabled) async {
    await _channel.invokeMethod('setVolumeNormalizationEnabled', {'enabled': enabled});
  }

  Future<void> setBandLevel(int bandIndex, int millibels) async {
    await _channel.invokeMethod('setBandLevel', {
      'bandIndex': bandIndex,
      'millibels': millibels,
    });
  }

  Future<void> setBandLevels(List<int> millibels) async {
    await _channel.invokeMethod('setBandLevels', {'millibels': millibels});
  }

  Future<void> setBassBoostStrength(int strength) async {
    await _channel.invokeMethod('setBassBoostStrength', {'strength': strength});
  }

  Future<void> setVirtualizerStrength(int strength) async {
    await _channel.invokeMethod('setVirtualizerStrength', {'strength': strength});
  }

  Future<void> setLoudnessGain(int gainMillibels) async {
    await _channel.invokeMethod('setLoudnessGain', {'gainMillibels': gainMillibels});
  }

  Future<void> resetToFlat() async {
    await _channel.invokeMethod('resetToFlat');
  }

  Future<void> setCrossfadeDuration(double seconds) async {
    await _channel.invokeMethod('setCrossfadeDuration', {'seconds': seconds});
  }

  Future<void> setGaplessEnabled(bool enabled) async {
    await _channel.invokeMethod('setGaplessEnabled', {'enabled': enabled});
  }

  Future<void> setHiResMode(String mode) async {
    await _channel.invokeMethod('setHiResMode', {'mode': mode});
  }

  Future<void> setOutputFormat(String format, int bytesPerSample) async {
    await _channel.invokeMethod('setOutputFormat', {
      'format': format,
      'bytesPerSample': bytesPerSample,
    });
  }

  Future<void> setReplayGain(double trackGain, double albumGain, String mode) async {
    await _channel.invokeMethod('setReplayGain', {
      'trackGain': trackGain,
      'albumGain': albumGain,
      'mode': mode,
    });
  }

  Future<void> setSampleRate(int sampleRate) async {
    await _channel.invokeMethod('setSampleRate', {'sampleRate': sampleRate});
  }

  Future<void> setBufferSize(int frames) async {
    await _channel.invokeMethod('setBufferSize', {'frames': frames});
  }

  Future<List<int>> getBandLevels() async {
    final result = await _channel.invokeMethod<List>('getBandLevels');
    return result?.cast<int>() ?? List.filled(10, 0);
  }

  Future<List<int>> getCenterFrequencies() async {
    final result = await _channel.invokeMethod<List>('getCenterFrequencies');
    return result?.cast<int>() ?? [];
  }

  Future<List<int>> getFrequencyRange() async {
    final result = await _channel.invokeMethod<List>('getFrequencyRange');
    return result?.cast<int>() ?? [0, 22000];
  }

  Future<int> getNumberOfBands() async {
    final result = await _channel.invokeMethod<int>('getNumberOfBands');
    return result ?? 10;
  }

  Future<int> getCurrentPreset() async {
    final result = await _channel.invokeMethod<int>('getCurrentPreset');
    return result ?? 0;
  }

  Future<String> getDeviceInfo() async {
    final result = await _channel.invokeMethod<String>('getDeviceInfo');
    return result ?? '';
  }
}
