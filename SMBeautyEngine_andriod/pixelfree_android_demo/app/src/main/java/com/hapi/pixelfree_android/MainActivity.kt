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
                    OpenGLTools.switchContext()
                    if(!mPixelFree.isCreate()){
//                        OpenGLTools.switchContext()
                        mPixelFree.create()
                        val face_fiter = mPixelFree.readBundleFile(this@MainActivity, "face_fiter.bundle")
                        mPixelFree.createBeautyItemFormBundle(
                            face_fiter,
                            face_fiter.size,
                            PFSrcType.PFSrcTypeFilter
                        )

                        val face_detect = mPixelFree.readBundleFile(this@MainActivity, "face_detect.bundle")
                        mPixelFree.createBeautyItemFormBundle(
                            face_detect,
                            face_detect.size,
                            PFSrcType.PFSrcTypeDetect
                        )
// 滤镜依赖gl 上下文创建素材，必须放在 gl 环境
                        mPixelFree.pixelFreeSetFiterParam(
                            "heibai1",
                            1f
                        )


                    }else{
                        val iamgeInput = frame.toPFIamgeInput();
                        mPixelFree.processWithBuffer(iamgeInput)
                        GLES30.glFinish()
//                        frame.textureID = iamgeInput.textureID;
//                        val code =GLES30.glGetError()
//                        Log.d("mjl","GLES30.glGetError()" + code)
//                        val byteBuffer = ByteBuffer.wrap(ByteArray(frame.data.size))
//                        GLES30.glReadPixels(0, 0, frame.width, frame.height,
//                            GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, byteBuffer);
//                        val stitchBmp = Bitmap.createBitmap(frame.width, frame.height, Bitmap.Config.ARGB_8888)
//                        stitchBmp.copyPixelsFromBuffer(byteBuffer)
                    }

                    return super.onProcessFrame(frame)
                }
            }
        }
    }

    private fun VideoFrame.toPFIamgeInput(): PFIamgeInput {
        val vf = this
        var texture:Int = OpenGLTools.createTexture(
            this.width,
            this.height,
            ByteBuffer.wrap(this.data, 0, this.data.size)
        )

        
        vf.textureID = texture
        return PFIamgeInput().apply {
            textureID = texture
            wigth = vf.width
            height = vf.height
            p_data0 = vf.data
            p_data1 = vf.data
            p_data2 = vf.data
            stride_0 = vf.rowStride
            stride_1 = vf.rowStride
            stride_2 = vf.rowStride
            format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
            rotationMode = PFRotationMode.PFRotationMode90
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
            mPixelFree.pixelFreeSetBeautyFiterParam(
                PFBeautyFiterType.PFBeautyFiterTypeFace_thinning,
                1f
            )
        }
        findViewById<Button>(R.id.btWhite).setOnClickListener {

        }
    }

    override fun onDestroy() {
        super.onDestroy()
        OpenGLTools.release()
    }
}