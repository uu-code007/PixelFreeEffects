package com.hapi.avparam

import com.hapi.avparam.VideoFrame


interface VideoRender {
    fun onFrame(frame: VideoFrame)
}