package com.hapi.avrender

import android.content.Context
import android.util.AttributeSet
import android.widget.FrameLayout
import com.hapi.avparam.VideoFrame
import com.hapi.avparam.VideoRender
import com.hapi.avrender.renderview.HapiGLSurfacePreview

class HapiCapturePreView : FrameLayout, VideoRender {

    val mHapiGLSurfacePreview by lazy { HapiGLSurfacePreview(context) }

    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        addView(
            mHapiGLSurfacePreview,
            FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        )
    }
    fun setScaleType(scaleType: ScaleType) {
        mHapiGLSurfacePreview.mVideoSizeAdapter.mScaleType = scaleType
    }

    fun setMirror(
        xRotateAngle: Int = 0,
        yRotateAngle: Int = 0,
        scaleX: Float = 1.0f,
        scaleY: Float = 1.0f,
        mirrorHorizontal: Boolean = false,
        mirrorVertical: Boolean = false
    ) {
        mHapiGLSurfacePreview.setMirror(xRotateAngle, yRotateAngle, scaleX, scaleY, mirrorHorizontal, mirrorVertical)
    }

    override fun onFrame(frame: VideoFrame) {
        mHapiGLSurfacePreview.onFrame(frame)
    }


}