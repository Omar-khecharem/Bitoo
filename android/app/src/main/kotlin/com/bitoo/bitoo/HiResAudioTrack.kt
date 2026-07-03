package com.bitoo.bitoo

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Build
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

class HiResAudioTrack(
    private var sampleRate: Int = 48000,
    private var encoding: Int = AudioFormat.ENCODING_PCM_FLOAT,
    private var bufferSize: Int = 4096
) {
    companion object {
        private const val TAG = "HiResAudioTrack"

        fun isFormatSupported(mimeType: String, sampleRate: Int, bitDepth: Int): Boolean {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return bitDepth <= 16
            return try {
                when {
                    mimeType.contains("flac") && bitDepth <= 24 && sampleRate <= 192000 -> true
                    mimeType.contains("wav") && bitDepth <= 32 && sampleRate <= 384000 -> true
                    mimeType.contains("mp4") || mimeType.contains("aac") -> bitDepth <= 24 && sampleRate <= 96000
                    mimeType.contains("ogg") || mimeType.contains("opus") -> sampleRate <= 48000
                    mimeType.contains("mp3") -> sampleRate <= 48000
                    else -> false
                }
            } catch (e: Exception) {
                false
            }
        }
    }

    private var audioTrack: AudioTrack? = null
    private var state: State = State.IDLE

    enum class State { IDLE, INITIALIZED, PLAYING, STOPPED, RELEASED }

    fun init(): Boolean {
        if (state != State.IDLE) return true

        val channelConfig = AudioFormat.CHANNEL_OUT_STEREO
        val audioFormat = AudioFormat.Builder()
            .setEncoding(encoding)
            .setSampleRate(sampleRate)
            .setChannelMask(channelConfig)
            .build()

        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED or AudioAttributes.FLAG_HW_AV_SYNC)
            .build()

        val minBufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, encoding)
        val finalBufferSize = maxOf(minBufferSize, bufferSize)

        audioTrack = try {
            AudioTrack(
                attributes,
                audioFormat,
                finalBufferSize,
                AudioTrack.MODE_STREAM,
                AudioManager.AUDIO_SESSION_ID_GENERATE
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create Hi-Res AudioTrack", e)
            // Fallback: try 16-bit PCM
            val fallbackFormat = AudioFormat.Builder()
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setSampleRate(48000)
                .setChannelMask(channelConfig)
                .build()
            AudioTrack(
                attributes,
                fallbackFormat,
                AudioTrack.getMinBufferSize(48000, channelConfig, AudioFormat.ENCODING_PCM_16BIT),
                AudioTrack.MODE_STREAM,
                AudioManager.AUDIO_SESSION_ID_GENERATE
            )
        }

        if (audioTrack?.state != AudioTrack.STATE_INITIALIZED) {
            Log.e(TAG, "AudioTrack failed to initialize")
            return false
        }

        Log.d(TAG, "Hi-Res AudioTrack initialized: ${encodingName(encoding)} @ ${sampleRate}Hz")
        state = State.INITIALIZED
        return true
    }

    fun play() {
        if (state == State.INITIALIZED || state == State.STOPPED) {
            audioTrack?.play()
            state = State.PLAYING
        }
    }

    fun pause() {
        audioTrack?.pause()
        state = State.INITIALIZED
    }

    fun stop() {
        audioTrack?.stop()
        state = State.STOPPED
    }

    fun release() {
        try {
            audioTrack?.stop()
            audioTrack?.release()
        } catch (e: Exception) {
            Log.w(TAG, "Error releasing AudioTrack", e)
        }
        audioTrack = null
        state = State.RELEASED
    }

    fun writeFloatBuffer(buffer: FloatArray): Int {
        val track = audioTrack ?: return -1
        if (encoding != AudioFormat.ENCODING_PCM_FLOAT) return -1
        return try {
            val byteBuffer = ByteBuffer.allocate(buffer.size * 4)
            byteBuffer.order(ByteOrder.LITTLE_ENDIAN)
            byteBuffer.asFloatBuffer().put(buffer)
            track.write(byteBuffer, buffer.size * 4, AudioTrack.WRITE_BLOCKING)
        } catch (e: Exception) {
            Log.w(TAG, "Error writing float buffer", e)
            -1
        }
    }

    fun writeByteBuffer(buffer: ByteArray): Int {
        val track = audioTrack ?: return -1
        return try {
            track.write(buffer, 0, buffer.size)
        } catch (e: Exception) {
            Log.w(TAG, "Error writing byte buffer", e)
            -1
        }
    }

    fun getAudioSessionId(): Int {
        return audioTrack?.audioSessionId ?: AudioManager.AUDIO_SESSION_ID_GENERATE
    }

    fun setSampleRate(rate: Int) {
        if (rate != sampleRate && state == State.IDLE) {
            sampleRate = rate
        }
    }

    private fun encodingName(encoding: Int): String = when (encoding) {
        AudioFormat.ENCODING_PCM_16BIT -> "16-bit PCM"
        AudioFormat.ENCODING_PCM_24BIT_PACKED -> "24-bit PCM"
        AudioFormat.ENCODING_PCM_32BIT -> "32-bit PCM"
        AudioFormat.ENCODING_PCM_FLOAT -> "32-bit Float"
        else -> "Unknown"
    }
}
