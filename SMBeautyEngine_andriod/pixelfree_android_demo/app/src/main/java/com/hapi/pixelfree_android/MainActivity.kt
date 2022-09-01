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


                    mPixelFree.processWithBuffer(frame.toPFIamgeInput())
                    val code =GLES30.glGetError()
                    Log.d("mjl","GLES30.glGetError()" + code)
                    val byteBuffer = ByteBuffer.wrap(ByteArray(frame.data.size))
                    GLES30.glReadPixels(0, 0, frame.width, frame.height,
                        GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, byteBuffer);

                    val stitchBmp = Bitmap.createBitmap(frame.width, frame.height, Bitmap.Config.ARGB_8888)

                    stitchBmp.copyPixelsFromBuffer(byteBuffer)
//                    OpenGLTools.createTexture(
//                        frame.width,
//                        frame.height,
//                        ByteBuffer.wrap(frame.data, 0, frame.data.size)
//                    )
//                    frame.textureID = OpenGLTools.textures!![0]
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
//                when (vf.rotationDegrees) {
//                0 -> PFRotationMode.PFRotationMode0
//                90 -> PFRotationMode.PFRotationMode90
//                180 -> PFRotationMode.PFRotationMode180
//                270 -> PFRotationMode.PFRotationMode270
//                else -> PFRotationMode.PFRotationMode0
           // }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val hapiCapturePreView = findViewById<HapiCapturePreView>(R.id.preview)
        //如果需要预览视频轨道
        cameTrack.playerView = hapiCapturePreView
        mPixelFree.create()
//        val face_detect = mPixelFree.readBundleFile(this, "face_detect.bundle")
//        mPixelFree.createBeautyItemFormBundle(
//            face_detect,
//            face_detect.size,
//            PFSrcType.PFSrcTypeDetect
//        )
        val face_fiter = mPixelFree.readBundleFile(this, "face_fiter.bundle")
        mPixelFree.createBeautyItemFormBundle(
            face_fiter,
            face_fiter.size,
            PFSrcType.PFSrcTypeFilter
        )

        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            OpenGLTools.load()
            cameTrack.start()
        }

        findViewById<Button>(R.id.btSouLian).setOnClickListener {
            mPixelFree.pixelFreeSetFiterParam(
               "heibai1",
                1f
            )
        }
        findViewById<Button>(R.id.btWhite).setOnClickListener {
            mPixelFree.pixelFreeSetBeautyFiterParam(
                PFBeautyFiterType.PFBeautyFiterTypeFaceWhitenStrength,
                0.5f
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mPixelFree.release()
    }
}