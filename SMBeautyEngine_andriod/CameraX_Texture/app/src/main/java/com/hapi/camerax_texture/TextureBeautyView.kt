package com.hapi.camerax_texture

import android.content.Context
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import androidx.camera.core.Preview
import androidx.core.content.ContextCompat
import com.hapi.camerax_texture.gl.TextureBeautyRenderer
import com.hapi.pixelfree.PixelFree
import java.io.File

class TextureBeautyView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : GLSurfaceView(context, attrs) {

    private val renderer = TextureBeautyRenderer(context.applicationContext) {
        requestRender()
    }
    val pixelFree: PixelFree
        get() = renderer.pixelFree

    var onPixelFreeReady: (() -> Unit)? = null
        set(value) {
            field = value
            renderer.onPixelFreeReady = value
        }

    val surfaceProvider = Preview.SurfaceProvider { request ->
        queueEvent {
            renderer.setSurfaceRequest(request, ContextCompat.getMainExecutor(context))
        }
    }

    init {
        setEGLContextClientVersion(3)
        preserveEGLContextOnPause = true
        setRenderer(renderer)
        renderMode = RENDERMODE_WHEN_DIRTY
    }

    fun startRecording(file: File, onError: (Throwable) -> Unit): Boolean {
        if (!renderer.hasCameraFrameSize()) {
            return false
        }
        queueEvent { renderer.startRecording(file, onError) }
        return true
    }

    fun stopRecording(onStopped: (Throwable?) -> Unit) {
        queueEvent { renderer.stopRecording(onStopped) }
    }

    fun setCompareOriginalEnabled(enabled: Boolean) {
        queueEvent { renderer.setCompareOriginalEnabled(enabled) }
    }

    fun release() {
        queueEvent { renderer.release() }
    }
}
