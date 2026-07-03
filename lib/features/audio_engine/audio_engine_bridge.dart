import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/audio_engine_method_channel.dart';
import 'data/repositories/audio_engine_service_impl.dart';
import 'domain/entities/audio_engine_state.dart';
import 'domain/services/audio_engine_service.dart';
import 'presentation/providers/audio_engine_provider.dart';

AudioEngineService createAudioEngineService() {
  return AudioEngineServiceImpl(channel: AudioEngineMethodChannel());
}

Future<void> initAudioEngineForPlayer(Ref ref, int audioSessionId) async {
  final notifier = ref.read(audioEngineNotifierProvider.notifier);
  await notifier.init(audioSessionId);
}

Future<void> releaseAudioEngine(Ref ref) async {
  final notifier = ref.read(audioEngineNotifierProvider.notifier);
  await notifier.release();
}

Future<void> applyCrossfadeToPlayer(Ref ref, double seconds) async {
  final notifier = ref.read(audioEngineNotifierProvider.notifier);
  await notifier.setCrossfadeDuration(seconds);
}

Future<void> applyGaplessToPlayer(Ref ref, bool enabled) async {
  if (enabled) {
    final service = ref.read(audioEngineServiceProvider);
    await service.setGaplessEnabled(true);
  }
}

HiResMode getRecommendedHiResMode(SongInfo song) {
  if (song.sampleRate >= 96000 && song.bitDepth >= 24) {
    return HiResMode.pcmFloat;
  }
  if (song.sampleRate >= 48000 && song.bitDepth >= 24) {
    return HiResMode.pcm24;
  }
  return HiResMode.off;
}

class SongInfo {
  final int sampleRate;
  final int bitDepth;
  final String fileExtension;

  const SongInfo({
    required this.sampleRate,
    required this.bitDepth,
    required this.fileExtension,
  });
}
