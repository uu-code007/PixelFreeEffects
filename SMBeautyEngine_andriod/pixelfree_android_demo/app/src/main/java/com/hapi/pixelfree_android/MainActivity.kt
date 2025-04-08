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
import com.hapi.pixelfreeuikit.IndicatorSeekBar
import com.hapi.pixelfreeuikit.PixeBeautyDialog
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch

class MainActivity : AppCompatActivity() {

    var isLongPress = false

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
                    if (mPixelFree.isCreate()) {
                        val pxInput = PFIamgeInput().apply {
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
                        val startTime = System.currentTimeMillis()
                        mPixelFree.processWithBuffer(pxInput)
                        val endTime = System.currentTimeMillis()
                        val timeCost = endTime - startTime
//                        println("processWithBuffer 耗时：$timeCost 毫秒")

                        frame.textureID = if (isLongPress) 0 else pxInput.textureID;
                    }
                    return super.onProcessFrame(frame)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        cameTrack.playerView = hapiCapturePreView
        cameTrack.start()

        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            //在绑定上下文后初始化
            mPixelFree.create()
            val authData = mPixelFree.readBundleFile(this@MainActivity, "pixelfreeAuth.lic")
            mPixelFree.auth(this.applicationContext, authData, authData.size)
            val face_fiter =
                mPixelFree.readBundleFile(this@MainActivity, "filter_model.bundle")
            mPixelFree.createBeautyItemFormBundle(
                face_fiter,
                face_fiter.size,
                PFSrcType.PFSrcTypeFilter
            )

            mPixeBeautyDialog.show(supportFragmentManager, "")
        }
        findViewById<Button>(R.id.showBeauty).setOnClickListener {
            mPixeBeautyDialog.show(supportFragmentManager, "")
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

    override fun onDestroy() {
        mPixelFree.release()
        super.onDestroy()
    }
}