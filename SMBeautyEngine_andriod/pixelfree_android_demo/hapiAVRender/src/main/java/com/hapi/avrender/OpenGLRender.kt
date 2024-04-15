package com.hapi.avrender

import android.opengl.GLSurfaceView
import android.util.Log
import com.hapi.avparam.VideoFrame
import com.hapi.avparam.VideoRender
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class OpenGLRender : GLSurfaceView.Renderer, VideoRender {
    companion object {
        // Used to load the 'hapiplay' library on application startup.
        init {
            System.loadLibrary("hapiplay")
        }
    }

    var glCreateCall: (p1: EGLConfig) -> Unit = {
    }

    override fun onSurfaceCreated(p0: GL10?, p1: EGLConfig?) {
        renderHandler = native_create()
        native_OnSurfaceCreated(renderHandler)

        glCreateCall.invoke(p1!!)
    }

    override fun onSurfaceChanged(p0: GL10?, p1: Int, p2: Int) {
        native_OnSurfaceChanged(renderHandler, p1, p2)
    }

    override fun onDrawFrame(p0: GL10?) {
        if (renderHandler == -1L) return;
        native_OnDrawFrame(renderHandler)
    }

    fun release() {
        native_release(renderHandler)
        renderHandler = -1
    }

    @Volatile
    private var  renderHandler: Long = 0

    private external fun native_create(): Long
    private external fun native_OnSurfaceCreated(renderHandler: Long)
    private external fun native_release(renderHandler: Long)
    private external fun native_OnSurfaceChanged(renderHandler: Long, width: Int, height: Int)
    private external fun native_OnDrawFrame(renderHandler: Long)
    private external fun native_onFrame(
        renderHandler: Long,
        textureID: Int,
        width: Int,
        height: Int,
        format: Int,
        data: ByteArray,
        rotationDegrees: Int = 0,
        pixelStride: Int = 0,
        rowPadding: Int = 0
    )

    //update MVP matrix
    private external fun native_SetGesture(
        renderHandler: Long,
        xRotateAngle: Int,
        yRotateAngle: Int,
        scale: Float
    )

    private external fun native_SetTouchLoc(renderHandler: Long, touchX: Float, touchY: Float)

    override fun onFrame(frame: VideoFrame) {
        Log.d("hapiplayer"," onFrame(frame: VideoFrame) ${frame.textureID}" )
        native_onFrame(
            renderHandler,
            frame.textureID,
            frame.width,
            frame.height,
            frame.format.fmt,
            if (frame.textureID <= 0) {
                frame.data
            } else {
                ByteArray(0)
            },
            frame.rotationDegrees,
            frame.pixelStride,
            frame.rowPadding
        )
    }

}