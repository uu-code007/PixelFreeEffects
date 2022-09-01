package com.hapi.avrender.renderview

import com.hapi.avparam.AudioFrame
import com.hapi.avparam.AudioRender
import com.hapi.avrender.OpenSLRender

class HapiSLAudioRender : AudioRender {
    private var isMute = true
    private val mOpenSLRender = OpenSLRender()
    fun start() {
        mOpenSLRender.create()
    }

    fun stop() {
        mOpenSLRender.release()
    }

    fun mute(isMute: Boolean) {
        this.isMute = isMute
    }

    override fun onAudioFrame(audioFrame: AudioFrame) {
        if (!isMute) {
            mOpenSLRender.onAudioFrame(audioFrame)
        }
    }
}