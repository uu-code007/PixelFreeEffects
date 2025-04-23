package com.hapi.avrender.renderview

import android.content.Context
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import android.util.Log
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.CaptureVideoSizeAdapter
import com.hapi.avrender.OpenGLRender
import com.hapi.avparam.VideoRender


class HapiGLSurfacePreview : GLSurfaceView, VideoRender {
    private val TAG = "HapiGLSurfacePreview"
    private var isReleased = false

    val mOpenGLRender by lazy { OpenGLRender() }
    var mVideoSizeAdapter = CaptureVideoSizeAdapter()

    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        setEGLContextClientVersion(2);
        setRenderer(mOpenGLRender)
        renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY;
    }

    override fun onFrame(frame: VideoFrame) {
        if (isReleased) {
            Log.w(TAG, "Attempted to render frame after release")
            return
        }
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
        isReleased = true
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

    fun setMirror(
        xRotateAngle: Int = 0,
        yRotateAngle: Int = 0,
        scaleX: Float = 1.0f,
        scaleY: Float = 1.0f,
        mirrorHorizontal: Boolean = false,
        mirrorVertical: Boolean = false
    ) {
        if (isReleased) {
            Log.w(TAG, "Attempted to set mirror after release")
            return
        }
        
        try {
            mOpenGLRender.setMirror(xRotateAngle, yRotateAngle, scaleX, scaleY, mirrorHorizontal, mirrorVertical)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting mirror parameters", e)
        }
    }
}