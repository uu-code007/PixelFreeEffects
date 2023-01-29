package com.hapi.avcapture

import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.hapi.avcapture.screen.ImageListener
import com.hapi.avcapture.screen.ScreenServicePlugin
import com.hapi.avparam.ImgFmt
import com.hapi.avparam.VideoFrame


class ScreenCaptureTrack internal constructor(val lifecycleOwner: LifecycleOwner? = null) :
    IVideoTrack() {

    private val mImageListener by lazy {
        ImageListener { rgbaBuffer, width, height, pixelStride, rowPadding ->
            val outFrame = VideoFrame(
                width, height,
                ImgFmt.IMAGE_FORMAT_RGBA,
                rgbaBuffer,
                0,
                pixelStride,
                rowPadding
            )
            innerPushFrame(outFrame)
        }
    }

    init {
        lifecycleOwner?.lifecycle?.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if(event== Lifecycle.Event.ON_DESTROY){
                    onDestroy()
                }
            }
        })
    }

    private var isStart = false
    private var activity: FragmentActivity? = null
    fun start(
        activity: FragmentActivity,
        callback: ScreenServicePlugin.ScreenCaptureServiceCallBack
    ) {
        this.activity = activity
        isStart = true
        ScreenServicePlugin.addImageListener(activity, mImageListener, callback)
    }

    fun stop() {
        isStart = false
        activity?.let { ScreenServicePlugin.removeImageListener(it, mImageListener) }
    }

    private fun onDestroy() {
        if (isStart) {
            stop()
        }
    }

}