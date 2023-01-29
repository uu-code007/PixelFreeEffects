package com.hapi.avparam

import android.media.MediaCodec
import android.media.MediaFormat

interface EncoderCallBack {
    fun onConfigure(mediaCodec: MediaCodec, mediaFormat: MediaFormat){}
    fun onOutputFormatChanged(codec: MediaCodec, format: MediaFormat)
    fun onOutputBufferAvailable(
        codec: MediaCodec,
        index: Int,
        info: MediaCodec.BufferInfo
    )
}