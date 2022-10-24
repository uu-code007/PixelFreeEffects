package com.hapi.avcapture

import android.annotation.SuppressLint
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.lifecycle.*

import com.hapi.avparam.AudioFrame
import com.hapi.avparam.ChannelConfig
import com.hapi.avparam.SampleFormat


class MicrophoneTrack internal constructor(
    private val lifecycleOwner: LifecycleOwner? = null,
    private val sampleRateInHz: Int,
    private val channelConfig: ChannelConfig,
    private val audioFormat: SampleFormat
) : AudioTrack() {

    private var mAudioRecord: AudioRecord? = null
    private var isStart = false
    private val sampleBuffer by lazy { ByteArray(4096) }

    init {
        lifecycleOwner?.lifecycle?.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if(event==Lifecycle.Event.ON_DESTROY){
                    onDestroy()
                }
            }
        })
    }

    @SuppressLint("MissingPermission")
    override fun start() {
        isStart = true;
        val mMinBufferSize = AudioRecord.getMinBufferSize(
            sampleRateInHz, channelConfig.androidChannel, audioFormat.androidFMT
        )
        if (AudioRecord.ERROR_BAD_VALUE == mMinBufferSize) {
            throw java.lang.Exception("parameters are not supported by the hardware.")
        }
        mAudioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRateInHz, channelConfig.androidChannel, audioFormat.androidFMT,
            mMinBufferSize
        )
        Thread(Runnable {
            mAudioRecord!!.startRecording()

            try {
                while (isStart && mAudioRecord != null && !Thread.currentThread().isInterrupted) {
                    val result = mAudioRecord!!.read(sampleBuffer, 0, 4096)
                    if (result > 0) {
                        val outFrame = AudioFrame(
                            sampleRateInHz, channelConfig, audioFormat,
                            sampleBuffer
                        )
                        innerPushFrame(outFrame)
                    }
                }
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
        }).start()
    }

    override fun stop() {
        mAudioRecord?.stop()
        isStart = false;
    }

    private fun onDestroy() {
        if (isStart) {
            stop()
        }
    }
}