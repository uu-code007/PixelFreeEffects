package com.hapi.camerax_texture.gl

import android.content.Context
import android.graphics.Rect
import android.graphics.SurfaceTexture
import android.opengl.EGL14
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.Surface
import androidx.camera.core.SurfaceRequest
import com.hapi.camerax_texture.record.TextureVideoRecorder
import com.hapi.pixelfree.PFDetectFormat
import com.hapi.pixelfree.PFImageInput
import com.hapi.pixelfree.PFRotationMode
import com.hapi.pixelfree.PFSrcType
import com.hapi.pixelfree.PixelFree
import java.io.File
import java.util.concurrent.Executor
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.roundToInt

internal class TextureBeautyRenderer(
    private val appContext: Context,
    private val requestRender: () -> Unit
) : GLSurfaceView.Renderer {
    companion object {
        private const val TAG = "TextureBeautyRenderer"
    }

    val pixelFree = PixelFree()
    var onPixelFreeReady: (() -> Unit)? = null

    private var viewWidth = 0
    private var viewHeight = 0
    private var cameraWidth = 0
    private var cameraHeight = 0
    @Volatile private var cropWidth = 0
    @Volatile private var cropHeight = 0
    @Volatile private var rotationDegrees = 0
    private var oesTextureId = 0
    private var surfaceTexture: SurfaceTexture? = null
    private var cameraSurface: Surface? = null
    @Volatile private var pendingFrame = false
    private var pendingSurfaceRequest: SurfaceRequest? = null
    private var pendingSurfaceExecutor: Executor? = null
    private var pixelFreeReady = false
    private val textureMatrix = FloatArray(16)
    private val oesDrawer = lazy { OesTo2DDrawer() }
    private val textureDrawer = lazy { Texture2DDrawer() }
    private val cameraFrameBuffer = TextureFrameBuffer()
    private var recorder: TextureVideoRecorder? = null
    private var recorderStartNs = 0L
    private var compareOriginalEnabled = false

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDisable(GLES20.GL_CULL_FACE)
        oesTextureId = GlUtil.createOesTexture()
        surfaceTexture = SurfaceTexture(oesTextureId).apply {
            setOnFrameAvailableListener {
                pendingFrame = true
                requestRender()
            }
        }
        val request = pendingSurfaceRequest
        val executor = pendingSurfaceExecutor
        if (request != null && executor != null) {
            attachSurfaceRequest(request, executor)
            pendingSurfaceRequest = null
            pendingSurfaceExecutor = null
        }
        createPixelFree()
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        viewWidth = width
        viewHeight = height
        GLES20.glViewport(0, 0, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        val st = surfaceTexture ?: return
        if (pendingFrame) {
            pendingFrame = false
            st.updateTexImage()
            st.getTransformMatrix(textureMatrix)
        }
        if (cameraWidth <= 0 || cameraHeight <= 0) {
            clearScreen()
            return
        }

        val outputWidth = getOutputWidth()
        val outputHeight = getOutputHeight()
        cameraFrameBuffer.ensureSize(outputWidth, outputHeight)
        cameraFrameBuffer.bind()
        GLES20.glViewport(0, 0, outputWidth, outputHeight)
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        oesDrawer.value.draw(oesTextureId, textureMatrix)
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)

        val outputTexture = processWithPixelFree(cameraFrameBuffer.textureId)
        drawToPreview(if (compareOriginalEnabled) cameraFrameBuffer.textureId else outputTexture)
        recorder?.drawFrame(outputTexture, System.nanoTime() - recorderStartNs)
    }

    fun setCompareOriginalEnabled(enabled: Boolean) {
        compareOriginalEnabled = enabled
        requestRender()
    }

    fun setSurfaceRequest(request: SurfaceRequest, executor: Executor) {
        if (surfaceTexture == null) {
            pendingSurfaceRequest = request
            pendingSurfaceExecutor = executor
            return
        }
        attachSurfaceRequest(request, executor)
    }

    private fun attachSurfaceRequest(request: SurfaceRequest, executor: Executor) {
        val st = surfaceTexture ?: return
        val resolution = request.resolution
        cameraWidth = resolution.width
        cameraHeight = resolution.height
        cropWidth = cameraWidth
        cropHeight = cameraHeight
        request.setTransformationInfoListener(executor) { transformationInfo ->
            val cropRect: Rect = transformationInfo.cropRect
            cropWidth = cropRect.width().takeIf { it > 0 } ?: cameraWidth
            cropHeight = cropRect.height().takeIf { it > 0 } ?: cameraHeight
            rotationDegrees = transformationInfo.rotationDegrees
            requestRender()
        }
        st.setDefaultBufferSize(cameraWidth, cameraHeight)
        cameraSurface?.release()
        cameraSurface = Surface(st)
        request.provideSurface(cameraSurface!!, executor) {
            cameraSurface?.release()
            cameraSurface = null
        }
    }

    fun hasCameraFrameSize(): Boolean = cameraWidth > 0 && cameraHeight > 0

    fun startRecording(file: File, onError: (Throwable) -> Unit) {
        if (cameraWidth <= 0 || cameraHeight <= 0 || recorder != null) {
            return
        }
        try {
            recorder = TextureVideoRecorder(file.absolutePath, getOutputWidth(), getOutputHeight()).also {
                it.start(EGL14.eglGetCurrentContext())
            }
            recorderStartNs = System.nanoTime()
            Log.i(TAG, "Recording started: ${file.absolutePath}, size=${getOutputWidth()}x${getOutputHeight()}")
        } catch (t: Throwable) {
            recorder = null
            recorderStartNs = 0L
            onError(t)
        }
    }

    fun stopRecording(onStopped: (Throwable?) -> Unit) {
        val activeRecorder = recorder
        recorder = null
        recorderStartNs = 0L
        var error: Throwable? = null
        if (activeRecorder != null) {
            try {
                activeRecorder.stop()
            } catch (t: Throwable) {
                error = t
                Log.e(TAG, "Recording stop failed", t)
            }
        }
        onStopped(error)
    }

    fun release() {
        recorder?.stop()
        recorder = null
        cameraFrameBuffer.release()
        if (oesDrawer.isInitialized()) {
            oesDrawer.value.release()
        }
        if (textureDrawer.isInitialized()) {
            textureDrawer.value.release()
        }
        GlUtil.deleteTexture(oesTextureId)
        surfaceTexture?.release()
        surfaceTexture = null
        cameraSurface?.release()
        cameraSurface = null
        if (pixelFreeReady) {
            pixelFree.release()
            pixelFreeReady = false
        }
    }

    private fun createPixelFree() {
        pixelFree.create()
        pixelFreeReady = true
        pixelFree.readBundleFile(appContext, "pixelfreeAuth.lic")?.let {
            pixelFree.auth(appContext, it, it.size)
        }
        pixelFree.readBundleFile(appContext, "filter_model.bundle")?.let {
            pixelFree.createBeautyItemFormBundle(it, it.size, PFSrcType.PFSrcTypeFilter)
        }
        onPixelFreeReady?.invoke()
    }

    private fun processWithPixelFree(textureId: Int): Int {
        if (!pixelFreeReady) {
            return textureId
        }
        val input = PFImageInput().apply {
            this.textureID = textureId
            this.wigth = getOutputWidth()
            this.height = getOutputHeight()
            this.format = PFDetectFormat.PFFORMAT_IMAGE_TEXTURE
            this.rotationMode = PFRotationMode.PFRotationMode180
        }
        pixelFree.processWithBuffer(input)
        return if (input.textureID > 0) input.textureID else textureId
    }

    private fun drawToPreview(textureId: Int) {
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        setFitCenterViewport(getOutputWidth(), getOutputHeight(), viewWidth, viewHeight)
        textureDrawer.value.draw(textureId, mirrorX = false, flipY = false)
    }

    private fun clearScreen() {
        GLES20.glViewport(0, 0, viewWidth, viewHeight)
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
    }

    private fun setFitCenterViewport(srcWidth: Int, srcHeight: Int, dstWidth: Int, dstHeight: Int) {
        if (srcWidth <= 0 || srcHeight <= 0 || dstWidth <= 0 || dstHeight <= 0) {
            GLES20.glViewport(0, 0, dstWidth, dstHeight)
            return
        }
        val srcAspect = srcWidth.toFloat() / srcHeight.toFloat()
        val dstAspect = dstWidth.toFloat() / dstHeight.toFloat()
        val viewportWidth: Int
        val viewportHeight: Int
        if (srcAspect > dstAspect) {
            viewportWidth = dstWidth
            viewportHeight = (dstWidth / srcAspect).roundToInt()
        } else {
            viewportHeight = dstHeight
            viewportWidth = (dstHeight * srcAspect).roundToInt()
        }
        val x = (dstWidth - viewportWidth) / 2
        val y = (dstHeight - viewportHeight) / 2
        GLES20.glViewport(x, y, viewportWidth, viewportHeight)
    }

    private fun getOutputWidth(): Int {
        val baseWidth = cropWidth.takeIf { it > 0 } ?: cameraWidth
        val baseHeight = cropHeight.takeIf { it > 0 } ?: cameraHeight
        return if (rotationDegrees == 90 || rotationDegrees == 270) baseHeight else baseWidth
    }

    private fun getOutputHeight(): Int {
        val baseWidth = cropWidth.takeIf { it > 0 } ?: cameraWidth
        val baseHeight = cropHeight.takeIf { it > 0 } ?: cameraHeight
        return if (rotationDegrees == 90 || rotationDegrees == 270) baseWidth else baseHeight
    }
}
