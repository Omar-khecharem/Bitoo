package com.bitoo.bitoo

import android.content.Context
import android.media.audiofx.AudioEffect
import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import android.media.audiofx.LoudnessEnhancer
import android.media.audiofx.Virtualizer
import android.os.Build
import android.util.Log

class AudioEngine {
    companion object {
        private const val TAG = "AudioEngine"

        fun isEffectAvailable(effectType: java.util.UUID): Boolean {
            return try {
                val effects = AudioEffect.queryEffects()
                effects.any { it.type.equals(effectType) }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to query effects", e)
                false
            }
        }
    }

    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null
    private var loudnessEnhancer: Any? = null // LoudnessEnhancer (API 19+)

    private var audioSessionId: Int = 0
    private var isEqEnabled: Boolean = false
    private var isBassEnabled: Boolean = false
    private var isVirtualizerEnabled: Boolean = false
    private var isLoudnessEnabled: Boolean = false
    private var isVolumeNormalizationEnabled: Boolean = false
    private var crossfadeDuration: Float = 0f
    private var isGaplessEnabled: Boolean = true
    private var trackGain: Float = 0f
    private var albumGain: Float = 0f
    private var bufferSize: Int = 1024
    private var engineEnabled: Boolean = false

    fun init(sessionId: Int) {
        this.audioSessionId = sessionId
        Log.d(TAG, "AudioEngine initialized on session $sessionId")
    }

    fun release() {
        equalizer?.release()
        bassBoost?.release()
        virtualizer?.release()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            (loudnessEnhancer as? LoudnessEnhancer)?.release()
        }
        equalizer = null
        bassBoost = null
        virtualizer = null
        loudnessEnhancer = null
        engineEnabled = false
        Log.d(TAG, "AudioEngine released")
    }

    // -- Equalizer --

    fun setEqualizerEnabled(enabled: Boolean) {
        if (enabled && equalizer == null) {
            equalizer = createEqualizer()
        }
        equalizer?.enabled = enabled
        isEqEnabled = enabled
        if (!enabled && !isAnyEffectActive()) {
            engineEnabled = false
        }
    }

    private fun createEqualizer(): Equalizer? {
        return try {
            val eq = Equalizer(0, audioSessionId)
            eq.enabled = false
            // Set default number of bands
            val bands = eq.numberOfBands
            Log.d(TAG, "Equalizer created: $bands bands")
            eq
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create Equalizer", e)
            null
        }
    }

    fun setBandLevel(bandIndex: Short, millibels: Short) {
        val eq = equalizer ?: return
        try {
            eq.setBandLevel(bandIndex, millibels)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to set band $bandIndex to $millibels", e)
        }
    }

    fun getBandLevels(): List<Int> {
        val eq = equalizer
        if (eq == null) return List(10) { 0 }
        return (0 until eq.numberOfBands).map { i ->
            try { eq.getBandLevel(i.toShort()).toInt() } catch (e: Exception) { 0 }
        }
    }

    fun getCenterFrequencies(): List<Int> {
        val eq = equalizer
        if (eq == null) return listOf(31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000)
        return (0 until eq.numberOfBands).map { i ->
            try { eq.getCenterFreq(i.toShort()).toInt() } catch (e: Exception) { 0 }
        }
    }

    fun getFrequencyRange(): List<Int> {
        val eq = equalizer ?: return listOf(0, 22000)
        return try {
            if (eq.numberOfBands > 0) {
                val range = eq.getBandFreqRange(0.toShort())
                listOf(range[0].toInt(), range[range.size - 1].toInt())
            } else {
                listOf(0, 22000)
            }
        } catch (e: Exception) {
            listOf(0, 22000)
        }
    }

    fun getNumberOfBands(): Int {
        return (equalizer?.numberOfBands ?: 10).toInt()
    }

    fun getCurrentPreset(): Int {
        return (equalizer?.currentPreset ?: 0).toInt()
    }

    // -- Bass Boost --

    fun setBassBoostEnabled(enabled: Boolean) {
        if (enabled && bassBoost == null) {
            bassBoost = createBassBoost()
        }
        bassBoost?.enabled = enabled
        isBassEnabled = enabled
    }

    private fun createBassBoost(): BassBoost? {
        return try {
            val bb = BassBoost(0, audioSessionId)
            bb.enabled = false
            bb
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create BassBoost", e)
            null
        }
    }

    fun setBassBoostStrength(strength: Short) {
        val bb = bassBoost ?: return
        try {
            val clamped = strength.coerceIn(0, 1000)
            bb.setStrength(clamped)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to set bass boost strength", e)
        }
    }

    // -- Virtualizer --

    fun setVirtualizerEnabled(enabled: Boolean) {
        if (enabled && virtualizer == null) {
            virtualizer = createVirtualizer()
        }
        virtualizer?.enabled = enabled
        isVirtualizerEnabled = enabled
    }

    private fun createVirtualizer(): Virtualizer? {
        return try {
            val virt = Virtualizer(0, audioSessionId)
            virt.enabled = false
            virt
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create Virtualizer", e)
            null
        }
    }

    fun setVirtualizerStrength(strength: Short) {
        val virt = virtualizer ?: return
        try {
            val clamped = strength.coerceIn(0, 1000)
            virt.setStrength(clamped)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to set virtualizer strength", e)
        }
    }

    // -- Loudness Enhancer (API 19+) --

    fun setLoudnessEnabled(enabled: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) return
        if (enabled && loudnessEnhancer == null) {
            loudnessEnhancer = createLoudnessEnhancer()
        }
        (loudnessEnhancer as? LoudnessEnhancer)?.enabled = enabled
        isLoudnessEnabled = enabled
    }

    private fun createLoudnessEnhancer(): LoudnessEnhancer? {
        return try {
            val le = LoudnessEnhancer(audioSessionId)
            le.enabled = false
            le
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create LoudnessEnhancer", e)
            null
        }
    }

    fun setLoudnessGain(gainMillibels: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) return
        (loudnessEnhancer as? LoudnessEnhancer)?.setTargetGain(gainMillibels)
    }

    // -- Volume Normalization --

    fun setVolumeNormalizationEnabled(enabled: Boolean) {
        isVolumeNormalizationEnabled = enabled
    }

    // -- Reset --

    fun resetToFlat() {
        val eq = equalizer
        if (eq != null) {
            for (i in 0 until eq.numberOfBands) {
                eq.setBandLevel(i.toShort(), 0)
            }
        }
        setBassBoostStrength(0)
        setVirtualizerStrength(0)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            setLoudnessGain(0)
        }
    }

    // -- Crossfade & Gapless (metadata) --

    fun setCrossfadeDuration(seconds: Float) {
        crossfadeDuration = seconds
    }

    fun setGaplessEnabled(enabled: Boolean) {
        isGaplessEnabled = enabled
    }

    // -- ReplayGain --

    fun setReplayGain(trackGain: Float, albumGain: Float) {
        this.trackGain = trackGain
        this.albumGain = albumGain
    }

    // -- Buffer --

    fun setBufferSize(frames: Int) {
        bufferSize = frames
    }

    // -- Helpers --

    private fun isAnyEffectActive(): Boolean {
        return isEqEnabled || isBassEnabled || isVirtualizerEnabled || isLoudnessEnabled
    }
}
