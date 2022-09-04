package com.hapi.pixelfree_android

import android.graphics.Bitmap
import android.opengl.*
import android.os.Bundle
import android.util.Log
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.byteflow.pixelfree.*
import com.hapi.avcapture.FrameCall
import com.hapi.avcapture.HapiTrackFactory
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.HapiCapturePreView
import java.nio.ByteBuffer

class MainActivity : AppCompatActivity() {

    private val mPixelFree by lazy {
        PixelFree()
    }

    //摄像头轨道
    private val cameTrack by lazy {
        HapiTrackFactory.createCameraXTrack(this, this, 720, 1280).apply {
            frameCall = object : FrameCall<VideoFrame> {
                //帧回调
                override fun onFrame(frame: VideoFrame) {}

                //数据处理回调
                override fun onProcessFrame(frame: VideoFrame): VideoFrame {
                    if(!mPixelFree.isCreate()){
                        OpenGLTools.switchContext()
                        mPixelFree.create()
                        val face_fiter = mPixelFree.readBundleFile(this@MainActivity, "face_fiter.bundle")
                        mPixelFree.createBeautyItemFormBundle(
                            face_fiter,
                            face_fiter.size,
                            PFSrcType.PFSrcTypeFilter
                        )
                    }else{
                        mPixelFree.processWithBuffer(frame.toPFIamgeInput())
                    }
                    return super.onProcessFrame(frame)
                }
            }
        }
    }

    private fun VideoFrame.toPFIamgeInput(): PFIamgeInput {
        val vf = this
        OpenGLTools.createTexture(
            this.width,
            this.height,
            ByteBuffer.wrap(this.data, 0, this.data.size)
        )
        vf.textureID = OpenGLTools.textures!![0]
        return PFIamgeInput().apply {
            textureID = OpenGLTools.textures!![0]
            wigth = vf.width
            height = vf.height
            p_BGRA = vf.data
            p_Y
            p_CbCr
            stride_BGRA = vf.rowStride
            stride_Y
            stride_CbCr
            format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
            rotationMode = PFRotationMode.PFRotationMode0
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val hapiCapturePreView = findViewById<HapiCapturePreView>(R.id.preview)
        //如果需要预览视频轨道
        cameTrack.playerView = hapiCapturePreView

        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            OpenGLTools.load()
            cameTrack.start()
        }

        findViewById<Button>(R.id.btSouLian).setOnClickListener {
            mPixelFree.pixelFreeSetFiterParam(
               "heibai",
                1f
            )
        }
        findViewById<Button>(R.id.btWhite).setOnClickListener {
            mPixelFree.pixelFreeSetBeautyFiterParam(
                PFBeautyFiterType.PFBeautyFiterTypeFaceBlurStrength,
                1f
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        OpenGLTools.release()
    }
}