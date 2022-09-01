package com.hapi.avparam

import com.hapi.avparam.AudioFrame

interface AudioRender {


    fun onAudioFrame(audioFrame: AudioFrame)
}