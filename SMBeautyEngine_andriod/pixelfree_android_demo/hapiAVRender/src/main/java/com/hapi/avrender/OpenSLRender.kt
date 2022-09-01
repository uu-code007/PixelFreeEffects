package com.hapi.avrender

import com.hapi.avparam.AudioFrame

class OpenSLRender {

    companion object {
        // Used to load the 'hapiplay' library on application startup.
        init {
            System.loadLibrary("hapiplay")
        }
    }

    private var nativeHandler: Long = -1

    fun create() {
        nativeHandler = native_native_create()
    }

    fun onAudioFrame(audioFrame: AudioFrame) {
        if (nativeHandler != -1L) {
            native_native_audio_frame(nativeHandler, audioFrame.data,audioFrame.audioFormat.ffmpegFMT,audioFrame.channelConfig.FFmpegChannel,audioFrame.sampleRateInHz)
        }
    }

    fun release() {
        native_native_release(nativeHandler)
    }

    private external fun native_native_create(): Long
    private external fun native_native_release(nativeHandler: Long)
    private external fun native_native_audio_frame(nativeHandler: Long, data: ByteArray,
                                                   sample_fmt: Int,
                                                   audioChannelLayout: Int,
                                                   audioSampleRate: Int
                                                   )

}