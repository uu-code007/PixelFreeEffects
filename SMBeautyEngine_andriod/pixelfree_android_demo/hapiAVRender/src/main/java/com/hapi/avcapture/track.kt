package com.hapi.avcapture

import com.hapi.avparam.*
import com.hapi.avparam.AudioRender
import com.hapi.avparam.VideoRender
import java.util.*

const val DEFAULT_SAMPLE_RATE = 44100
val DEFAULT_CHANNEL_LAYOUT = ChannelConfig.STEREO
val DEFAULT_SAMPLE_FORMAT = SampleFormat.ENCODING_PCM_16BIT


interface FrameCall<T> {
    fun onFrame(frame: T)

    /**
     * 数据处理
     * @return 返回处理后的数据
     */
    fun onProcessFrame(frame: T): T {
        return frame;
    }
}

interface Track<T> {
    //帧回调
    var frameCall: FrameCall<T>?
}


abstract class IVideoTrack internal constructor() : Track<VideoFrame> {
    var playerView: VideoRender? = null
    override var frameCall: FrameCall<VideoFrame>? = null
    val innerFrameCalls = LinkedList<FrameCall<VideoFrame>>()
    private var lastFrameTime = 0L
    internal fun innerPushFrame(frame: VideoFrame) {
        var outFrame = frame
        frameCall?.let {
            it.onFrame(outFrame)
            outFrame = it.onProcessFrame(outFrame)
        }
        playerView?.onFrame(outFrame)
        innerFrameCalls.forEach {
            it.onFrame(outFrame)
        }
    }
}

abstract class IAudioTrack internal constructor() : Track<AudioFrame> {

    override var frameCall: FrameCall<AudioFrame>? = null

    var mAudioRender: AudioRender? = null

    val innerFrameCalls = LinkedList<FrameCall<AudioFrame>>()

    internal fun innerPushFrame(frame: AudioFrame) {
        var outFrame = frame
        frameCall?.let {
            it.onFrame(outFrame)
            outFrame = it.onProcessFrame(outFrame)
        }
        mAudioRender?.onAudioFrame(outFrame)
        innerFrameCalls.forEach {
            it.onFrame(outFrame)
        }
    }
}

abstract class VideoTrack internal constructor() : IVideoTrack() {
    abstract fun start()
    abstract fun stop()
}

abstract class AudioTrack internal constructor() : IAudioTrack() {
    abstract fun start()
    abstract fun stop()
}


class CustomAudioTrack internal constructor() : IAudioTrack() {
    fun pushVideoFrame(frame: AudioFrame) {
        innerPushFrame(frame)
    }
}

class CustomVideoTrack internal constructor() : IVideoTrack() {
    fun pushVideoFrame(frame: VideoFrame) {
        innerPushFrame(frame)
    }
}





