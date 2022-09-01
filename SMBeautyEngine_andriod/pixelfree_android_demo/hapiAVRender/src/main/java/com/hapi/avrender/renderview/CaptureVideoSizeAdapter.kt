package com.hapi.avrender

import android.annotation.SuppressLint
import android.view.View
import com.hapi.avparam.VideoFrame

enum class ScaleType(val type: Int) {
    CENTER_CROP(0),
    FIT_CENTER(1)
}

class MeasureResult(val w: Int, val h: Int)

open class VideoSizeAdapter {
    protected var videoHeight: Int = 0
    protected var videoWidth: Int = 0
    protected var mViewRotation = 0

    var mScaleType: ScaleType = ScaleType.CENTER_CROP

    open fun adaptVideoSize(videoFrame: VideoFrame): Boolean {
        var widthMeasureSpec = videoFrame.width
        var heightMeasureSpec = videoFrame.height
        val rote = videoFrame.rotationDegrees

        if (mViewRotation == 90 || mViewRotation == 270) {
            val tempMeasureSpec = widthMeasureSpec
            widthMeasureSpec = heightMeasureSpec
            heightMeasureSpec = tempMeasureSpec
        }

        if (this.videoWidth != widthMeasureSpec || this.videoHeight != heightMeasureSpec
            || rote != mViewRotation
        ) {
            this.mViewRotation = rote
            this.videoWidth = widthMeasureSpec
            this.videoHeight = heightMeasureSpec
            return true
        }
        return false
    }

    @SuppressLint("DrawAllocation")
    open fun onMeasure(w: Int, h: Int): MeasureResult {
        return MeasureResult(0, 0)
    }
}

class CaptureVideoSizeAdapter : VideoSizeAdapter() {

    @SuppressLint("DrawAllocation")
    override fun onMeasure(w: Int, h: Int): MeasureResult {
        var widthV = videoWidth
        var heightV = videoHeight

        val widthSpecMode = View.MeasureSpec.getMode(w)
        val widthSpecSize = View.MeasureSpec.getSize(w)
        val heightSpecMode = View.MeasureSpec.getMode(h)
        val heightSpecSize = View.MeasureSpec.getSize(h)
        //控件宽高
//        Log.d("HappyTextureView", )
        if (videoWidth > 0 && videoHeight > 0) {
            widthV = widthSpecSize
            heightV = heightSpecSize

            if (mScaleType == ScaleType.FIT_CENTER) {
                // for compatibility, we adjust size based on aspect ratio
                if (videoWidth * heightV < widthV * videoHeight) {
                    widthV = heightV * videoWidth / videoHeight
                } else {
                    heightV = widthV * videoHeight / videoWidth
                }
            } else {
                // for compatibility, we adjust size based on aspect ratio
                if (videoWidth * heightV > widthV * videoHeight) {
                    widthV = heightV * videoWidth / videoHeight
                } else {
                    heightV = widthV * videoHeight / videoWidth
                }
            }
            return MeasureResult(widthV, heightV)
        }
        return MeasureResult(w, h)
    }

}