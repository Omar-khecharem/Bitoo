# Audio DSP Architecture

## 1. DSP Processing Pipeline

```
[Audio File] → [Decoder] → [Sample Rate Converter] → [Equalizer] → [Bass Boost] → [Virtualizer]
    → [Loudness Normalizer] → [Volume Ramp (Crossfade)] → [Hi-Res AudioTrack]
```

Each stage is a pure DSP node that can be enabled/disabled independently.

### 1.1 Android AudioEffect Chain (Native)

```
AudioTrack (player) → AudioSessionId
  ├── Equalizer (10-band ISO 31-band, gain ±15dB, 31-16000 Hz)
  ├── BassBoost (strength 0-1000, ~100 Hz cutoff)
  ├── Virtualizer (strength 0-1000, 3D spatialization)
  └── LoudnessEnhancer (gain mB, API 19+, dynamic range compression)
```

### 1.2 DSP Units

| Unit | Type | Parameters | Platform |
|------|------|------------|----------|
| Equalizer | 10-band ISO | 31, 62, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz ±15dB | Android AudioEffect |
| Bass Boost | Shelf filter | Strength 0-100%, ~100 Hz cutoff | AudioEffect |
| Virtualizer | 3D spatial | Strength 0-100% | AudioEffect |
| Loudness Enhancer | Dynamic range | Target gain mB | AudioEffect (API 19+) |
| Volume Normalizer | RMS-based | Target -14 LUFS (loudness), ceiling -1dB | Custom native |
| Crossfade | Linear ramp | Duration 0-12s, curve (linear/cosine) | Custom Flutter mix |
| Gapless | Zero-delay | N/A (next track decode overlap) | Android setNextMediaPlayer |
| ReplayGain | Track/album gain | Per-track gain offset dB | Custom native |

## 2. Preset System

### 2.1 Preset Band Values (±15 dB scale)

| Frequency | Rock | Pop | Jazz | Classic | Electronic | Podcast | Movie | Gaming | Voice |
|-----------|------|-----|------|---------|------------|---------|-------|--------|-------|
| 31 Hz | +4.0 | +3.0 | +2.0 | +1.0 | +5.0 | 0.0 | +3.0 | +4.0 | -1.0 |
| 62 Hz | +3.5 | +4.0 | +2.5 | +1.5 | +5.5 | 0.0 | +4.0 | +5.0 | -1.0 |
| 125 Hz | +2.0 | +2.5 | +2.0 | +0.5 | +4.0 | -1.0 | +3.0 | +3.5 | -1.5 |
| 250 Hz | -1.0 | +1.5 | +1.0 | 0.0 | +2.0 | -2.0 | +2.0 | +1.0 | -2.0 |
| 500 Hz | -1.5 | 0.0 | +1.5 | +0.5 | 0.0 | -2.5 | -1.0 | 0.0 | -1.0 |
| 1 kHz | 0.0 | +0.5 | +1.0 | +1.0 | +0.5 | -1.0 | -2.0 | -0.5 | +2.0 |
| 2 kHz | +1.0 | +1.5 | +0.5 | +2.0 | +1.5 | +1.0 | -1.0 | +1.0 | +3.0 |
| 4 kHz | +2.0 | +2.0 | 0.0 | +2.5 | +2.5 | +2.5 | 0.0 | +2.0 | +3.5 |
| 8 kHz | +2.5 | +1.0 | -0.5 | +2.0 | +3.0 | +4.0 | +1.0 | +2.5 | +2.0 |
| 16 kHz | +2.0 | +0.5 | -1.0 | +1.0 | +3.5 | +3.5 | +1.5 | +3.0 | +1.5 |

### 2.2 Bass Boost per Preset

| Preset | Bass Boost % |
|--------|-------------|
| Rock | 60% |
| Pop | 40% |
| Jazz | 30% |
| Classic | 20% |
| Electronic | 80% |
| Podcast | 0% |
| Movie | 70% |
| Gaming | 65% |
| Voice | 0% |

### 2.3 Virtualizer per Preset

| Preset | Virtualizer % |
|--------|--------------|
| Rock | 40% |
| Pop | 50% |
| Jazz | 70% |
| Classic | 60% |
| Electronic | 65% |
| Podcast | 20% |
| Movie | 80% |
| Gaming | 75% |
| Voice | 30% |

## 3. High-Resolution Audio Architecture

### 3.1 Supported Formats & Decoders

| Format | Encoder | Max Bit Depth | Max Sample Rate | Container |
|--------|---------|--------------|-----------------|-----------|
| FLAC | Native Android Decoder | 24-bit | 192 kHz | .flac |
| WAV | Native Android Decoder | 32-bit float | 384 kHz | .wav |
| M4A/AAC | Native Android Decoder | 24-bit (ALAC) | 96 kHz | .m4a, .mp4 |
| OGG | Native Android Decoder | 16-bit | 48 kHz | .ogg |
| MP3 | Native Android Decoder | 16-bit | 48 kHz | .mp3 |
| PCM | Direct AudioTrack | 32-bit float | 192 kHz | .pcm, .wav |

### 3.2 Hi-Res Playback Path

```
AudioFile → MediaExtractor → MediaCodec (decoder)
  → Float PCM buffer → AudioEffect chain
  → AudioTrack (ENCODING_PCM_FLOAT / ENCODING_PCM_24BIT)
  → AudioDevice (Wired/A2DP/LDAC)
```

- Use `AudioAttributes.USAGE_MEDIA` with `FLAG_HW_AV_SYNC` for ALAC/MQA passthrough
- Request native float output with `AudioFormat.ENCODING_PCM_FLOAT`
- Detect device capabilities: `AudioManager.getDevices()` → `AudioDeviceInfo` for Hi-Res support
- Fallback chain: 32-bit float → 24-bit → 16-bit PCM

## 4. Gapless Playback Implementation

### 4.1 Architecture

```
Track A [playing]
  ├── MediaCodec decode to float buffer [256 samples ahead]
  ├── AudioEffect processing
  └── AudioTrack.write()

Track B [prepared, overlap decode]
  ├── Pre-decode first 8192 frames
  ├── Detect silent leading samples (skip)
  └── Queue via MediaPlayer.setNextMediaPlayer()
```

**Gapless Detection:**
- Read encoder delay + padding from container headers (MP4/M4A `elst` box)
- For FLAC: `STREAMINFO` block has min/max/positive zero frame info
- CD-quality files: assume 0 delay, ~20ms overlap

### 4.2 Crossfade

```
Track A volume: 1.0 → 0.0 over T seconds (linear or cosine ramp)
Track B volume: 0.0 → 1.0 over T seconds
Mix: output[i] = A[i] * fadeOut[i] + B[i] * fadeIn[i]

Ramp curve: f(t) = 0.5 - 0.5 * cos(π * t / T)  [cosine, more natural]
```

- Crossfade only active when user enables it (default: gapless, no crossfade)
- At track boundary: start crossfade mixer thread, mix PCM frames, write to AudioTrack
- Duration 0-12 seconds, adjustable in 0.5s increments

## 5. Volume Normalization

### 5.1 Loudness Normalization (EBU R128 / ITU-R BS.1770-4)

```
1. Measure integrated LUFS of audio stream (sliding window 400ms)
2. Apply gain: targetLUFS - measuredLUFS
3. Clamp gain to ±12dB
4. True-peak limiter at -1dB TP (inter-sample peak detection)
```

- Target: -14 LUFS (music streaming standard)
- Implemented as native Android audio processor
- Bypass when user explicitly sets volume > 85%

### 5.2 ReplayGain Support

```
- Read REPLAYGAIN_TRACK_GAIN / REPLAYGAIN_ALBUM_GAIN from metadata
- Prefer album gain, fall back to track gain
- Apply as pre-gain to AudioTrack before effects chain
```

## 6. Permission Enforcement

| Feature | Permission | Android Version |
|---------|-----------|----------------|
| AudioEffect (EQ, Bass, Virtualizer) | None (session-based) | All |
| LoudnessEnhancer | None | API 19+ |
| Hi-Res AudioTrack | `RECORD_AUDIO` (for AAudio) | API 23+ |
| Bluetooth codec selection | `BLUETOOTH_CONNECT` | API 31+ |

## 7. Error Recovery Strategy

| Error | Recovery | Fallback |
|-------|----------|----------|
| AudioEffect not available | Disable effect, notify | Bypass DSP stage |
| Hi-Res format unsupported | Downsample to 48kHz/16-bit | AudioTrack standard path |
| LoudnessEnhancer missing (API <19) | Disable silently | Null effect |
| AudioTrack write underrun | Buffer 2x, increase latency | Default buffer size |
| Format not decodable | Try software decoder | AudioService error callback |
| Crossfade buffer overflow | Reduce crossfade duration | Gapless (no crossfade) |

## 8. Threading Model

```
UI Thread: Provider reads/writes state (AudioEngineState)
Backround Isolate: Not used (all DSP is native)
Native Audio Thread (Android): AudioTrack callback, AudioEffect processing
  ├── Real-time priority (android.os.Process.THREAD_PRIORITY_URGENT_AUDIO)
  ├── Lock-free ring buffer between decode + DSP
  └── <10ms per callback cycle
```

## 9. File Architecture

```
lib/features/audio_engine/
  domain/
    entities/
      audio_engine_state.dart        # Full engine state sealed class
      preset_config.dart              # Preset definitions + band values
    services/
      audio_engine_service.dart       # Abstract interface

  data/
    datasources/
      audio_engine_method_channel.dart # Flutter → Native bridge
    models/
      preset_model.dart               # (de)serializable preset
    repositories/
      audio_engine_service_impl.dart   # Impl delegates to method channel

  presentation/
    providers/
      audio_engine_provider.dart       # Riverpod StateNotifier
    widgets/
      equalizer_visualizer.dart        # Premium 10-band visualizer
      preset_selector.dart             # Preset chip grid
      audio_effects_panel.dart         # Full effects sheet

android/app/src/main/kotlin/com/bitoo/bitoo/
  AudioEnginePlugin.kt                # Flutter method channel handler
  AudioEngine.kt                      # Core native engine (AudioEffect chain)
  HiResAudioTrack.kt                  # Native Hi-Res audio output
```
