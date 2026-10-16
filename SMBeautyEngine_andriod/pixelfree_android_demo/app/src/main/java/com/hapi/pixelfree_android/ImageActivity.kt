package com.hapi.pixelfree_android

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import android.util.Log
import android.widget.Button
import android.widget.TextView
import android.net.Uri
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.hapi.avparam.ImgFmt
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.HapiCapturePreView
import com.hapi.pixelfree.PFDetectFormat
import com.hapi.pixelfree.PFFaceDetectMode
import com.hapi.pixelfree.PFImageInput
import com.hapi.pixelfree.PFRotationMode
import com.hapi.pixelfree.PFSrcType
import com.hapi.pixelfree.PixelFree
import com.hapi.pixelfreeuikit.PixeBeautyDialog
import com.hapi.pixelfreeuikit.ColorGradingDialog

class ImageActivity: AppCompatActivity()  {

    @Volatile var isLongPress = false
    @Volatile private var glReady = false
    @Volatile private var closing = false
    private val lifecycleLock = Any()
    lateinit var originBitmap: Bitmap;

    private val mPixelFree by lazy {
        PixelFree()
    }
    private val mPixeBeautyDialog by lazy {
        PixeBeautyDialog(mPixelFree)
    }
    private val mColorGradingDialog by lazy {
        ColorGradingDialog(this, mPixelFree) {}
    }

    private val handler = Handler(Looper.getMainLooper())
    private var frameCount = 0
    private lateinit var rgbaData:ByteArray
    private lateinit var fpstTextView: TextView

    private val pickImageLauncher = registerForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let { handleSelectedImage(it) }
    }

    val hapiCapturePreView by lazy { findViewById<HapiCapturePreView>(R.id.preview) }

    var w = 0
    var h = 0
    var rowBytes = 0
    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_image)

        val options = BitmapFactory.Options()
        options.inScaled = false // 禁止缩放
        options.inDensity = DisplayMetrics.DENSITY_DEFAULT // 设置输入密度为默认值
        options.inTargetDensity = resources.displayMetrics.densityDpi // 设置目标密度为设备屏幕密度

        originBitmap = BitmapFactory.decodeResource(resources, R.drawable.image_face, options)

        w = originBitmap.width;
        h = originBitmap.height;
        rowBytes = w * 4
        rgbaData = convertBitmapToRGBA(originBitmap);

        // 相册按钮 & 点击预览均可选择相册图片
        findViewById<Button>(R.id.btnAlbum).setOnClickListener {
            pickImageLauncher.launch("image/*")
        }
        hapiCapturePreView.setOnClickListener {
            pickImageLauncher.launch("image/*")
        }

        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            if (!closing) {
                mPixelFree.setRenderThreadDispatcher(Thread.currentThread()) { task ->
                    hapiCapturePreView.mHapiGLSurfacePreview.queueEvent(task)
                }
                mPixelFree.createOnCurrentGLThread()
                val authData = mPixelFree.readBundleFile(this@ImageActivity, "pixelfreeAuth.lic")
                if (authData != null) {
                    mPixelFree.auth(this.applicationContext, authData, authData.size)
                }
                val face_fiter =
                    mPixelFree.readBundleFile(this@ImageActivity, "filter_model.bundle")
                if (face_fiter != null) {
                    mPixelFree.createBeautyItemFormBundle(
                        face_fiter,
                        face_fiter.size,
                        PFSrcType.PFSrcTypeFilter
                    )
                }

                mPixelFree.setDetectModeOnCurrentGLThread(PFFaceDetectMode.PF_FACE_DETECT_MODE_IMAGE)
                synchronized(lifecycleLock) {
                    if (closing) {
                        mPixelFree.releaseOnCurrentGLThread()
                    } else {
                        glReady = true
                        handler.post {
                            if (!closing) {
                                handler.removeCallbacks(updateImageRunnable)
                                handler.post(updateImageRunnable)
                                showBeautyDialog()
                            }
                        }
                    }
                }
            }
        }

//        hapiCapturePreView.setScaleType(ScaleType.FIT_CENTER)
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
                    Log.d("TAG", "松开")
                    // 执行松开逻辑（如结束录制）
                    isLongPress = false;
                }
            }
        })

        // 添加颜色调节按钮
        findViewById<Button>(R.id.showColorGrading).setOnClickListener {
            if (glReady && !closing) mColorGradingDialog.show()
        }

        fpstTextView = findViewById<TextView>(R.id.fpst)

    }

    private val updateImageRunnable = object : Runnable {
        private var frameCount = 0
        private var startTimeMillis = System.currentTimeMillis()
        override fun run() {
            if (closing || !glReady) return
            val startTime = System.currentTimeMillis()
            val width = w
            val height = h
            val pixels = rgbaData
            val stride = rowBytes
            val compare = isLongPress
            hapiCapturePreView.mHapiGLSurfacePreview.queueEvent {
                if (closing || !glReady) return@queueEvent
                val pxInput = PFImageInput().apply {
                    wigth = width
                    this.height = height
                    p_data0 = pixels
                    p_data1 = null
                    p_data2 = null
                    stride_0 = stride
                    stride_1 = 0
                    stride_2 = 0
                    textureID = 0
                    format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
                    rotationMode = PFRotationMode.PFRotationMode0
                }
                if (!compare) {
                    mPixelFree.processWithBufferOnCurrentGLThread(pxInput)
                }

                val frame = VideoFrame(
                    width, height,
                    ImgFmt.IMAGE_FORMAT_RGBA,
                    pixels,
                    0,
                    4,
                    0,
                )
                // 长按显示原图；松开显示处理后的 texture
                frame.textureID = if (compare) -1000 else pxInput.textureID
                hapiCapturePreView.onFrame(frame)
                handler.post {
                    if (!closing) {
                        frameCount++
                        val endTime = System.currentTimeMillis()
                        val duration = endTime - startTime
                        val elapsedTime = endTime - startTimeMillis
                        if (elapsedTime >= 60000) {
                            val fps = frameCount * 1000 / elapsedTime
                            fpstTextView.text = "FPS: $fps one:$duration ms"
                            frameCount = 0
                            startTimeMillis = endTime
                        }
                        handler.postDelayed(this, (80L - duration).coerceAtLeast(0))
                    }
                }
            }
        }
    }

    private fun convertBitmapToRGBA(bitmap: Bitmap): ByteArray {
        val width = bitmap.width
        val height = bitmap.height
        val rgbaDataa = IntArray(width * height)

        bitmap.getPixels(rgbaDataa, 0, width, 0, 0, width, height)
        return intArrayToByteArray(rgbaDataa)
    }

    private fun handleSelectedImage(uri: Uri) {
        try {
            contentResolver.openInputStream(uri)?.use { input ->
                val options = BitmapFactory.Options().apply {
                    inScaled = false
                    inDensity = DisplayMetrics.DENSITY_DEFAULT
                    inTargetDensity = resources.displayMetrics.densityDpi
                }
                val bitmap = BitmapFactory.decodeStream(input, null, options) ?: return
                originBitmap = bitmap
                w = bitmap.width
                h = bitmap.height
                rowBytes = w * 4
                rgbaData = convertBitmapToRGBA(bitmap)
                hapiCapturePreView.mHapiGLSurfacePreview.queueEvent {
                    if (!closing && glReady) mPixelFree.resetDetectStateOnCurrentGLThread()
                }
            }
        } catch (e: Exception) {
            Log.e("ImageActivity", "Failed to load image from gallery", e)
        }
    }

    private fun applyWhiteningFilter(rgbaData: IntArray, width: Int, height: Int): IntArray {
        val whitenedData = IntArray(rgbaData.size)

        for (i in rgbaData.indices) {
            val color = rgbaData[i]

            val r = (color shr 16 and 0xFF)
            val g = (color shr 8 and 0xFF)
            val b = (color and 0xFF)

            // 简单的美白算法，将 RGB 值增加
            val newR = (r * 1.2).coerceAtMost(255.0).toInt()
            val newG = (g * 1.1).coerceAtMost(255.0).toInt()
            val newB = (b * 1.0).toInt() // 保持不变

            whitenedData[i] = (color and 0xFF000000.toInt()) or (newR shl 16) or (newG shl 8) or newB
        }

        return whitenedData
    }

    private fun createBitmapFromRGBA(rgbaData: IntArray, width: Int, height: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.setPixels(rgbaData, 0, width, 0, 0, width, height)
        return bitmap
    }

    private fun intArrayToByteArray(rgbaData: IntArray): ByteArray {
        // 创建一个 ByteArray，大小为 RGBA 数据的四倍（每个像素四个字节）
        val byteArray = ByteArray(rgbaData.size * 4)

        for (i in rgbaData.indices) {
            // 获取 RGBA 颜色
            val color = rgbaData[i]

            // 解析 R、G、B、A 通道
            val a = (color shr 24 and 0xFF).toByte() // Alpha
            val r = (color shr 16 and 0xFF).toByte() // Red
            val g = (color shr 8 and 0xFF).toByte()  // Green
            val b = (color and 0xFF).toByte()        // Blue

            // 将 RGBA 值存入 ByteArray
            byteArray[i * 4] = r
            byteArray[i * 4 + 1] = g
            byteArray[i * 4 + 2] = b
            byteArray[i * 4 + 3] = a
        }

        return byteArray
    }

    private fun byteArrayToIntArray(byteArray: ByteArray): IntArray {
        val intArray = IntArray(byteArray.size / 4) // 每 4 个字节对应一个 Int

        for (i in intArray.indices) {
            // 组合 R、G、B、A 值为一个 Int
            val r = byteArray[i * 4].toInt() and 0xFF
            val g = byteArray[i * 4 + 1].toInt() and 0xFF
            val b = byteArray[i * 4 + 2].toInt() and 0xFF
            val a = byteArray[i * 4 + 3].toInt() and 0xFF

            intArray[i] = (a shl 24) or (r shl 16) or (g shl 8) or b // 组合成 ARGB 格式
        }

        return intArray
    }



    private fun showBeautyDialog() {
        if (glReady && !closing && !isFinishing && !supportFragmentManager.isStateSaved &&
            !mPixeBeautyDialog.isAdded && supportFragmentManager.findFragmentByTag("beauty") == null) {
            mPixeBeautyDialog.show(supportFragmentManager, "beauty")
        }
    }

    override fun onDestroy() {
        val initialized = synchronized(lifecycleLock) {
            closing = true
            glReady
        }
        handler.removeCallbacksAndMessages(null)
        if (initialized) mPixelFree.release()
        glReady = false
        super.onDestroy()
    }
}
