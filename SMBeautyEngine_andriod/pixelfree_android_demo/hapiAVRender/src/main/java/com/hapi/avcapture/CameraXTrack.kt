package com.hapi.avcapture

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.util.Size
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.hapi.avcapture.video.RGBAProducer
import com.hapi.avparam.ImgFmt
import com.hapi.avparam.VideoFrame
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraXTrack internal constructor(
    val width: Int,
    val height: Int,
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner
) : VideoTrack() {
    private val rgbaProducer = RGBAProducer()
    private val cameraExecutor: ExecutorService by lazy {
        Executors.newSingleThreadExecutor()
    }
    private val mLuminosityAnalyzer = ImageAnalysis.Analyzer { image ->
        rgbaProducer.parseImg(image)
        val outFrame = VideoFrame(
            rgbaProducer.mWidth, rgbaProducer.mHeight, ImgFmt.IMAGE_FORMAT_RGBA,
            rgbaProducer.rgbaByteArray!!,
            image.imageInfo.rotationDegrees,
            rgbaProducer.pixelStride,
            rgbaProducer.rowPadding
        )
        outFrame.rowStride = rgbaProducer.rowStride
        innerPushFrame(outFrame)
        image.close()
    }

    private val imageAnalyzer by lazy {
        ImageAnalysis.Builder()
            .setTargetResolution(Size(width, height))
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
            .build()
            .also {
                it.setAnalyzer(cameraExecutor, mLuminosityAnalyzer)
            }
    }

    override fun start() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener(Runnable {
            val cameraProvider: ProcessCameraProvider = cameraProviderFuture.get()
            val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    lifecycleOwner, cameraSelector, imageAnalyzer
                )
            } catch (exc: Exception) {
                exc.printStackTrace()
            }
        }, ContextCompat.getMainExecutor(context))
    }

    @SuppressLint("RestrictedApi")
    override fun stop() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.get().shutdown()
    }
}