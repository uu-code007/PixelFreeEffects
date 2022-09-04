package com.hapi.pixelfree_android

import android.opengl.*
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.byteflow.pixelfree.*
import com.hapi.avcapture.FrameCall
import com.hapi.avcapture.HapiTrackFactory
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.HapiCapturePreView
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch

class MainActivity : AppCompatActivity() {

    private val mPixelFree by lazy {
        PixelFree()
    }

    val hapiCapturePreView by lazy { findViewById<HapiCapturePreView>(R.id.preview) }
    var countDownLatch: CountDownLatch = CountDownLatch(1)

    //摄像头轨道
    private val cameTrack by lazy {
        HapiTrackFactory.createCameraXTrack(this, this, 720, 1280).apply {
            frameCall = object : FrameCall<VideoFrame> {
                //帧回调
                override fun onFrame(frame: VideoFrame) {

                    mPixelFree.glThread.runOnGLThread {
                        val texture: Int = mPixelFree.glThread.getTexture(
                            frame.width,
                            frame.height,
                            ByteBuffer.wrap(frame.data, 0, frame.data.size)
                        )
                        frame.textureID = texture
                        val pxInput = PFIamgeInput().apply {
                            textureID = texture
                            wigth = frame.width
                            height = frame.height
                            p_data0 = frame.data
                            p_data1 = frame.data
                            p_data2 = frame.data
                            stride_0 = frame.rowStride
                            stride_1 = frame.rowStride
                            stride_2 = frame.rowStride
                            format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
                            rotationMode = PFRotationMode.PFRotationMode90
                        }
                        mPixelFree.processWithBuffer(pxInput)
//                        hapiCapturePreView.post {
                        hapiCapturePreView.onFrame(frame)
//                        }
                        //  countDownLatch.countDown()
                    }
//                    countDownLatch.await()
//                    hapiCapturePreView. onFrame(frame)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        mPixelFree.glThread.start()
        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            mPixelFree.glThread.attachGLContext {
                mPixelFree.create()
                val face_fiter =
                    mPixelFree.readBundleFile(this@MainActivity, "face_fiter.bundle")
                mPixelFree.createBeautyItemFormBundle(
                    face_fiter,
                    face_fiter.size,
                    PFSrcType.PFSrcTypeFilter
                )
                val face_detect =
                    mPixelFree.readBundleFile(this@MainActivity, "face_detect.bundle")
                mPixelFree.createBeautyItemFormBundle(
                    face_detect,
                    face_detect.size,
                    PFSrcType.PFSrcTypeDetect
                )
                cameTrack.start()
            }
        }

        findViewById<Button>(R.id.btSouLian).setOnClickListener {
            mPixelFree.pixelFreeSetBeautyFiterParam(
                PFBeautyFiterType.PFBeautyFiterTypeFace_thinning,
                1f
            )
        }
        findViewById<Button>(R.id.btWhite).setOnClickListener {
            mPixelFree.glThread.runOnGLThread {
                mPixelFree.pixelFreeSetFiterParam(
                    "heibai1",
                    1f
                )
            }
        }
    }

    override fun onDestroy() {
        mPixelFree.glThread.runOnGLThread {
            mPixelFree.release()
        }
        super.onDestroy()
    }
}