package com.hapi.pixelfree_android

import android.os.Bundle
import android.util.Log
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.hapi.pixelfree.*
import com.hapi.avcapture.FrameCall
import com.hapi.avcapture.HapiTrackFactory
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.HapiCapturePreView
import com.hapi.pixelfreeuikit.PixeBeautyDialog
import java.util.concurrent.CountDownLatch

class MainActivity : AppCompatActivity() {

    @Volatile var isLongPress = false
    @Volatile private var glReady = false
    @Volatile private var closing = false
    private val frameLock = Any()

    private val mPixelFree by lazy {
        PixelFree()
    }
    private val mPixeBeautyDialog by lazy {
        PixeBeautyDialog(mPixelFree)
    }
    val hapiCapturePreView by lazy { findViewById<HapiCapturePreView>(R.id.preview) }

    //摄像头轨道
    private val cameTrack by lazy {
        HapiTrackFactory.createCameraXTrack(this, this, 720, 1280).apply {
            frameCall = object : FrameCall<VideoFrame> {
                //帧回调
                override fun onFrame(frame: VideoFrame) {
                }

                override fun onProcessFrame(frame: VideoFrame): VideoFrame {
                    val done = CountDownLatch(1)
                    synchronized(frameLock) {
                        if (!glReady || closing) return frame
                        hapiCapturePreView.mHapiGLSurfacePreview.queueEvent {
                            try {
                                if (!glReady || closing) return@queueEvent
                                val compare = isLongPress
                                val pxInput = PFImageInput().apply {
                                    wigth = frame.width
                                    height = frame.height
                                    p_data0 = frame.data
                                    p_data1 = null
                                    p_data2 = null
                                    stride_0 = frame.rowStride
                                    stride_1 = 0
                                    stride_2 = 0
                                    format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
                                    // CameraX uses clockwise correction; PixelFree uses counterclockwise rotation.
                                    rotationMode = when (frame.rotationDegrees) {
                                        90 -> PFRotationMode.PFRotationMode270
                                        180 -> PFRotationMode.PFRotationMode180
                                        270 -> PFRotationMode.PFRotationMode90
                                        else -> PFRotationMode.PFRotationMode0
                                    }
                                }
                                if (!compare) mPixelFree.processWithBufferOnCurrentGLThread(pxInput)
                                frame.textureID = if (compare) 0 else pxInput.textureID
                                hapiCapturePreView.onFrame(frame)
                            } finally {
                                done.countDown()
                            }
                        }
                    }
                    // CameraX reuses the RGBA buffer after this callback returns.
                    done.await()
                    return frame
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            if (!closing) {
                mPixelFree.setRenderThreadDispatcher(Thread.currentThread()) { task ->
                    hapiCapturePreView.mHapiGLSurfacePreview.queueEvent(task)
                }
                mPixelFree.createOnCurrentGLThread()
                val authData = mPixelFree.readBundleFile(this@MainActivity, "pixelfreeAuth.lic")
                if (authData != null) {
                    mPixelFree.auth(this.applicationContext, authData, authData.size)
                }
                val face_fiter =
                    mPixelFree.readBundleFile(this@MainActivity, "filter_model.bundle")
                if (face_fiter != null) {
                    mPixelFree.createBeautyItemFormBundle(
                        face_fiter,
                        face_fiter.size,
                        PFSrcType.PFSrcTypeFilter
                    )
                }

                synchronized(frameLock) {
                    if (closing) {
                        mPixelFree.releaseOnCurrentGLThread()
                    } else {
                        glReady = true
                        runOnUiThread { showBeautyDialog() }
                    }
                }
            }
        }
        cameTrack.start()
        findViewById<Button>(R.id.showBeauty).setOnClickListener {
            showBeautyDialog()
        }

        mPixeBeautyDialog.setOnCompButtonStateListener(object : PixeBeautyDialog.OnCompButtonStateListener {
            override fun onCompButtonPressed(isPressed: Boolean) {
                if (isPressed) {
                    Log.d("TAG", "长按按下")
                    // 执行长按逻辑（如显示提示、开始录制等）
                    isLongPress = true;
                } else {
                    Log.d("TAG", "长按松开")
                    isLongPress = false;
                }
            }
        })
    }

    private fun showBeautyDialog() {
        if (glReady && !closing && !isFinishing && !supportFragmentManager.isStateSaved &&
            !mPixeBeautyDialog.isAdded && supportFragmentManager.findFragmentByTag("beauty") == null) {
            mPixeBeautyDialog.show(supportFragmentManager, "beauty")
        }
    }

    override fun onDestroy() {
        val initialized = synchronized(frameLock) {
            closing = true
            glReady
        }
        cameTrack.frameCall = null
        if (initialized) mPixelFree.release()
        glReady = false
        super.onDestroy()
    }
}
