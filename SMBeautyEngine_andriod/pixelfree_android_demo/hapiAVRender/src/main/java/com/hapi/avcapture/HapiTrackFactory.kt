package com.hapi.avcapture

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import com.hapi.avparam.ChannelConfig
import com.hapi.avparam.SampleFormat

object  HapiTrackFactory {

    fun createCameraXTrack(
        context: Context,
        lifecycleOwner: LifecycleOwner,
        width: Int,
        height: Int
    ): CameraXTrack {
        return CameraXTrack(width, height, context, lifecycleOwner)
    }

    fun createMicrophoneTrack(
        lifecycleOwner: LifecycleOwner? = null,
        sampleRateInHz: Int = DEFAULT_SAMPLE_RATE,
        channelConfig: ChannelConfig = DEFAULT_CHANNEL_LAYOUT,
        audioFormat: SampleFormat = DEFAULT_SAMPLE_FORMAT
    ): MicrophoneTrack {
        return MicrophoneTrack(lifecycleOwner, sampleRateInHz, channelConfig, audioFormat)
    }

    fun createCustomAudioTrack(): CustomAudioTrack {
        return CustomAudioTrack()
    }

    fun createCustomVideoTrack(): CustomVideoTrack {
        return CustomVideoTrack()
    }

    fun createScreenCaptureTrack(
        lifecycleOwner: LifecycleOwner? = null,
    ): ScreenCaptureTrack {
        return ScreenCaptureTrack(lifecycleOwner)
    }
}