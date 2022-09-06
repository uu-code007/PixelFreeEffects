package com.hapi.avrender.renderview

import android.content.Context
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.CaptureVideoSizeAdapter
import com.hapi.avrender.OpenGLRender
import com.hapi.avparam.VideoRender


class HapiGLSurfacePreview : GLSurfaceView, VideoRender {

    val mOpenGLRender by lazy { OpenGLRender() }
    var mVideoSizeAdapter = CaptureVideoSizeAdapter()

    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        setEGLContextClientVersion(2);
        setRenderer(mOpenGLRender)
        renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY;

    }

    override fun onFrame(frame: VideoFrame) {
        mOpenGLRender.onFrame(frame)
        if (mVideoSizeAdapter.adaptVideoSize(frame)) {
            post {
                requestLayout()
            }
        }
        requestRender()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mOpenGLRender.release()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        mVideoSizeAdapter.onMeasure(widthMeasureSpec, heightMeasureSpec).let {
            super.onMeasure(
                MeasureSpec.makeMeasureSpec(it.w, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(it.h, MeasureSpec.EXACTLY)
            )
        }
    }
}