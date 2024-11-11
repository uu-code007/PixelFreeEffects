package com.hapi.pixelfree_android

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.util.DisplayMetrics
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.graphics.drawable.toBitmap
import com.hapi.avparam.ImgFmt
import com.hapi.avparam.VideoFrame
import com.hapi.avrender.HapiCapturePreView
import com.hapi.pixelfree.PFDetectFormat
import com.hapi.pixelfree.PFIamgeInput
import com.hapi.pixelfree.PFRotationMode
import com.hapi.pixelfree.PFSrcType
import com.hapi.pixelfree.PixelFree
import com.hapi.pixelfreeuikit.PixeBeautyDialog

class ImageActivity: AppCompatActivity()  {

    private val mPixelFree by lazy {
        PixelFree()
    }
    private val mPixeBeautyDialog by lazy {
        PixeBeautyDialog(mPixelFree)
    }

    private val handler = Handler(Looper.getMainLooper())
    private var frameCount = 0
    private lateinit var imageView: ImageView // 声明 ImageView 变量
    private lateinit var rgbaData:ByteArray
    private lateinit var fpstTextView: TextView

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

        val bitmap = BitmapFactory.decodeResource(resources, R.drawable.image_face, options)

        w = bitmap.width;
        h = bitmap.height;
        rowBytes = bitmap.rowBytes
        rgbaData = convertBitmapToRGBA(bitmap);

        // 启动定时任务
        handler.postDelayed(updateImageRunnable, 1)

        hapiCapturePreView.mHapiGLSurfacePreview.mOpenGLRender.glCreateCall = {
            //在绑定上下文后初始化
            mPixelFree.create()
            val authData = mPixelFree.readBundleFile(this@ImageActivity, "pixelfreeAuth.lic")
            mPixelFree.auth(this.applicationContext, authData, authData.size)
            val face_fiter =
                mPixelFree.readBundleFile(this@ImageActivity, "filter_model.bundle")
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

        fpstTextView = findViewById<TextView>(R.id.fpst)

    }

    private val updateImageRunnable = object : Runnable {
        private var frameCount = 0
        private var startTimeMillis = System.currentTimeMillis()
        override fun run() {
            val startTime = System.currentTimeMillis() // 或者使用 System.nanoTime()

            if (mPixelFree.isCreate()) {
                val pxInput = PFIamgeInput().apply {
                    wigth = w
                    height = h
                    p_data0 = rgbaData;
                    p_data1 = null
                    p_data2 = null
                    stride_0 = rowBytes
                    stride_1 = 0
                    stride_2 = 0
                    format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
                    rotationMode = PFRotationMode.PFRotationMode0
                }
                mPixelFree.processWithBuffer(pxInput)

                val frame = pxInput.p_data0?.let {
                    val out = VideoFrame(
                        w, h,
                        ImgFmt.IMAGE_FORMAT_RGBA,
                        it,
                        0,
                        rowBytes,
                        0,
                    )
                    out.textureID = pxInput.textureID
                    out
                }

                if (frame != null) {
                    hapiCapturePreView.onFrame(frame)
                    println("frame.textureID : ${frame.textureID}")
                };

                frameCount++
                val endTime = System.currentTimeMillis()
                val duration = endTime - startTime
                val elapsedTime = endTime - startTimeMillis

                if (elapsedTime >= 60000) { // 一分钟已经过去
                    val fps = (frameCount * 1000 / elapsedTime).toInt() // 计算平均 FPS
                    fpstTextView.text = "FPS: $fps one:$duration ms" // 更新 TextView 上的文字
                    frameCount = 0
                    startTimeMillis = System.currentTimeMillis()
                }
            }

            val endTime = System.currentTimeMillis() // 或者使用 System.nanoTime()

            val duration = endTime - startTime // 耗时（毫秒）
            println("[PixelFree] processWithBuffer all: $duration ms")

            var delay = 33L - duration
            if (delay < 0) {
                delay = 0L;
            }

            handler.postDelayed(this, delay) // 每分钟调用 30 次
        }
    }

    private fun convertBitmapToRGBA(bitmap: Bitmap): ByteArray {
        val width = bitmap.width
        val height = bitmap.height
        val rgbaDataa = IntArray(width * height)

        bitmap.getPixels(rgbaDataa, 0, width, 0, 0, width, height)
        return intArrayToByteArray(rgbaDataa)
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



    override fun onDestroy() {
        super.onDestroy()
        mPixelFree.release()
        handler.removeCallbacks(updateImageRunnable) // 停止更新
    }


}