package com.bitoo.bitoo

import android.content.Context
import android.media.audiofx.AudioEffect
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AudioEnginePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var audioEngine: AudioEngine? = null
    private var hiResTrack: HiResAudioTrack? = null
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.bitoo.bitoo/audio_engine")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        audioEngine?.release()
        hiResTrack?.release()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "init" -> handleInit(call, result)
                "release" -> handleRelease(result)
                "isEffectAvailable" -> handleIsEffectAvailable(call, result)
                "isHiResSupported" -> handleIsHiResSupported(call, result)
                "setEnabled" -> handleSetEnabled(call, result)
                "setEqualizerEnabled" -> handleSetEffectEnabled("equalizer", call, result)
                "setBassBoostEnabled" -> handleSetEffectEnabled("bassBoost", call, result)
                "setVirtualizerEnabled" -> handleSetEffectEnabled("virtualizer", call, result)
                "setLoudnessEnabled" -> handleSetEffectEnabled("loudnessEnhancer", call, result)
                "setVolumeNormalizationEnabled" -> handleSetVolumeNormalization(call, result)
                "setBandLevel" -> handleSetBandLevel(call, result)
                "setBandLevels" -> handleSetBandLevels(call, result)
                "setBassBoostStrength" -> handleSetBassBoostStrength(call, result)
                "setVirtualizerStrength" -> handleSetVirtualizerStrength(call, result)
                "setLoudnessGain" -> handleSetLoudnessGain(call, result)
                "resetToFlat" -> handleResetToFlat(result)
                "setCrossfadeDuration" -> handleSetCrossfade(call, result)
                "setGaplessEnabled" -> handleSetGapless(call, result)
                "setHiResMode" -> handleSetHiResMode(call, result)
                "setOutputFormat" -> handleSetOutputFormat(call, result)
                "setReplayGain" -> handleSetReplayGain(call, result)
                "setSampleRate" -> handleSetSampleRate(call, result)
                "setBufferSize" -> handleSetBufferSize(call, result)
                "getBandLevels" -> handleGetBandLevels(result)
                "getCenterFrequencies" -> handleGetCenterFrequencies(result)
                "getFrequencyRange" -> handleGetFrequencyRange(result)
                "getNumberOfBands" -> handleGetNumberOfBands(result)
                "getCurrentPreset" -> handleGetCurrentPreset(result)
                "getDeviceInfo" -> handleGetDeviceInfo(result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e("AudioEnginePlugin", "Error handling ${call.method}", e)
            result.error("AUDIO_ENGINE_ERROR", e.message, null)
        }
    }

    private fun getEngine(): AudioEngine {
        if (audioEngine == null) {
            audioEngine = AudioEngine()
        }
        return audioEngine!!
    }

    private fun handleInit(call: MethodCall, result: Result) {
        val sessionId = call.argument<Int>("audioSessionId") ?: 0
        getEngine().init(sessionId)
        result.success(true)
    }

    private fun handleRelease(result: Result) {
        audioEngine?.release()
        audioEngine = null
        hiResTrack?.release()
        hiResTrack = null
        result.success(true)
    }

    private fun handleIsEffectAvailable(call: MethodCall, result: Result) {
        val effect = call.argument<String>("effect") ?: ""
        val available = when (effect) {
            "equalizer" -> AudioEngine.isEffectAvailable(AudioEffect.EFFECT_TYPE_EQUALIZER)
            "bassBoost" -> AudioEngine.isEffectAvailable(AudioEffect.EFFECT_TYPE_BASS_BOOST)
            "virtualizer" -> AudioEngine.isEffectAvailable(AudioEffect.EFFECT_TYPE_VIRTUALIZER)
            "loudnessEnhancer" -> Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT
            else -> false
        }
        result.success(available)
    }

    private fun handleIsHiResSupported(call: MethodCall, result: Result) {
        val mimeType = call.argument<String>("mimeType") ?: ""
        val sampleRate = call.argument<Int>("sampleRate") ?: 48000
        val bitDepth = call.argument<Int>("bitDepth") ?: 16
        val supported = HiResAudioTrack.isFormatSupported(mimeType, sampleRate, bitDepth)
        result.success(supported)
    }

    private fun handleSetEnabled(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: true
        getEngine().setEqualizerEnabled(enabled)
        getEngine().setBassBoostEnabled(enabled)
        getEngine().setVirtualizerEnabled(enabled)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getEngine().setLoudnessEnabled(enabled)
        }
        result.success(true)
    }

    private fun handleSetEffectEnabled(effect: String, call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: true
        when (effect) {
            "equalizer" -> getEngine().setEqualizerEnabled(enabled)
            "bassBoost" -> getEngine().setBassBoostEnabled(enabled)
            "virtualizer" -> getEngine().setVirtualizerEnabled(enabled)
            "loudnessEnhancer" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
                getEngine().setLoudnessEnabled(enabled)
        }
        result.success(true)
    }

    private fun handleSetVolumeNormalization(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: true
        getEngine().setVolumeNormalizationEnabled(enabled)
        result.success(true)
    }

    private fun handleSetBandLevel(call: MethodCall, result: Result) {
        val bandIndex = call.argument<Int>("bandIndex") ?: 0
        val millibels = call.argument<Int>("millibels") ?: 0
        getEngine().setBandLevel(bandIndex.toShort(), millibels.toShort())
        result.success(true)
    }

    private fun handleSetBandLevels(call: MethodCall, result: Result) {
        val millibels = call.argument<List<Int>>("millibels") ?: emptyList()
        millibels.forEachIndexed { index, mb ->
            getEngine().setBandLevel(index.toShort(), mb.toShort())
        }
        result.success(true)
    }

    private fun handleSetBassBoostStrength(call: MethodCall, result: Result) {
        val strength = call.argument<Int>("strength") ?: 0
        getEngine().setBassBoostStrength(strength.toShort())
        result.success(true)
    }

    private fun handleSetVirtualizerStrength(call: MethodCall, result: Result) {
        val strength = call.argument<Int>("strength") ?: 0
        getEngine().setVirtualizerStrength(strength.toShort())
        result.success(true)
    }

    private fun handleSetLoudnessGain(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            val gain = call.argument<Int>("gainMillibels") ?: 0
            getEngine().setLoudnessGain(gain)
        }
        result.success(true)
    }

    private fun handleResetToFlat(result: Result) {
        getEngine().resetToFlat()
        result.success(true)
    }

    private fun handleSetCrossfade(call: MethodCall, result: Result) {
        val seconds = call.argument<Double>("seconds") ?: 0.0
        getEngine().setCrossfadeDuration(seconds.toFloat())
        result.success(true)
    }

    private fun handleSetGapless(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: true
        getEngine().setGaplessEnabled(enabled)
        result.success(true)
    }

    private fun handleSetHiResMode(call: MethodCall, result: Result) {
        val mode = call.argument<String>("mode") ?: "off"
        val encoding = when (mode) {
            "pcm24" -> android.media.AudioFormat.ENCODING_PCM_24BIT_PACKED
            "pcm32" -> android.media.AudioFormat.ENCODING_PCM_32BIT
            "pcmFloat" -> android.media.AudioFormat.ENCODING_PCM_FLOAT
            else -> android.media.AudioFormat.ENCODING_PCM_16BIT
        }
        hiResTrack?.release()
        if (mode != "off") {
            hiResTrack = HiResAudioTrack(
                sampleRate = 48000,
                encoding = encoding,
                bufferSize = 4096
            )
        }
        result.success(true)
    }

    private fun handleSetOutputFormat(call: MethodCall, result: Result) {
        // Output format handled inside HiResAudioTrack
        result.success(true)
    }

    private fun handleSetReplayGain(call: MethodCall, result: Result) {
        val trackGain = call.argument<Double>("trackGain") ?: 0.0
        val albumGain = call.argument<Double>("albumGain") ?: 0.0
        getEngine().setReplayGain(trackGain.toFloat(), albumGain.toFloat())
        result.success(true)
    }

    private fun handleSetSampleRate(call: MethodCall, result: Result) {
        val sampleRate = call.argument<Int>("sampleRate") ?: 48000
        hiResTrack?.setSampleRate(sampleRate)
        result.success(true)
    }

    private fun handleSetBufferSize(call: MethodCall, result: Result) {
        val frames = call.argument<Int>("frames") ?: 1024
        getEngine().setBufferSize(frames)
        result.success(true)
    }

    private fun handleGetBandLevels(result: Result) {
        val levels = getEngine().getBandLevels()
        result.success(levels)
    }

    private fun handleGetCenterFrequencies(result: Result) {
        val freqs = getEngine().getCenterFrequencies()
        result.success(freqs)
    }

    private fun handleGetFrequencyRange(result: Result) {
        val range = getEngine().getFrequencyRange()
        result.success(range)
    }

    private fun handleGetNumberOfBands(result: Result) {
        result.success(getEngine().getNumberOfBands())
    }

    private fun handleGetCurrentPreset(result: Result) {
        result.success(getEngine().getCurrentPreset())
    }

    private fun handleGetDeviceInfo(result: Result) {
        val info = StringBuilder()
        info.append("SDK: ${Build.VERSION.SDK_INT}, ")
        info.append("Device: ${Build.MANUFACTURER} ${Build.MODEL}, ")
        info.append("AudioEffects: EQ=${AudioEngine.isEffectAvailable(AudioEffect.EFFECT_TYPE_EQUALIZER)}, ")
        info.append("Bass=${AudioEngine.isEffectAvailable(AudioEffect.EFFECT_TYPE_BASS_BOOST)}, ")
        info.append("Virtualizer=${AudioEngine.isEffectAvailable(AudioEffect.EFFECT_TYPE_VIRTUALIZER)}")
        context?.let { ctx ->
            val am = ctx.getSystemService(Context.AUDIO_SERVICE) as android.media.AudioManager
            val devices = am.getDevices(android.media.AudioManager.GET_DEVICES_OUTPUTS)
            if (devices.isNotEmpty()) {
                info.append(", Outputs: ")
                devices.forEach { d ->
                    info.append("${d.productName}(${d.type}), ")
                }
            }
        }
        result.success(info.toString())
    }
}
