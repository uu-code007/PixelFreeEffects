package com.hapi.pixelfree

import android.content.Context
import android.opengl.GLES30
import android.util.Log
import java.io.InputStream
import java.nio.ByteBuffer

class PixelFree {
    companion object {
        init {
            System.loadLibrary("pixel")
        }
    }

    private val glThread = GLThread()
    private var nativeHandler: Long = -1
    fun isCreate(): Boolean {
        return nativeHandler != -1L
    }

    fun create() {
        Log.d("[PixelFree]", "PixelFree create");
        glThread.attachGLContext()
        glThread.runOnGLThread(true) {
            nativeHandler = native_create()
        }
    }

    fun auth(context: Context, data: ByteArray, size: Int) {
        if (nativeHandler == -1L) {
            return
        }
        native_auth(nativeHandler, context, data, size)
    }

    fun readBundleFile(context: Context, fileName: String): ByteArray {
        var buffer: ByteArray? = null
        try {
            val mAssets: InputStream = context.assets.open(fileName)
            val lenght: Int = mAssets.available()
            buffer = ByteArray(lenght)
            mAssets.read(buffer)
            mAssets.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return buffer!!
    }

    fun release() {
        Log.d("[PixelFree]", "PixelFree release~");
        glThread.runOnGLThread {
            native_release(nativeHandler)
            nativeHandler = -1
            glThread.release()
        }

    }

//    private var rgbaCoverRender = RGBACoverRender()
    fun processWithBuffer(iamgeInput: PFIamgeInput) {
        if (nativeHandler == -1L) {
            return
        }
        glThread.runOnGLThread(true) {

            if (iamgeInput.textureID <= 0 &&
                (iamgeInput.format == PFDetectFormat.PFFORMAT_IMAGE_RGBA || iamgeInput.format == PFDetectFormat.PFFORMAT_IMAGE_RGB)
            ) {
                val format = when (iamgeInput.format) {
                    PFDetectFormat.PFFORMAT_IMAGE_RGBA -> GLES30.GL_RGBA
                    PFDetectFormat.PFFORMAT_IMAGE_RGB -> GLES30.GL_RGB
                    else -> GLES30.GL_RGBA
                }
                iamgeInput.textureID = glThread.getTexture(
                    format,
                    iamgeInput.wigth,
                    iamgeInput.height,
                    ByteBuffer.wrap(iamgeInput.p_data0!!, 0, iamgeInput.p_data0?.size ?: 0)
                )
            }

            if (iamgeInput.textureID <= 0 &&
                (iamgeInput.format == PFDetectFormat.PFFORMAT_IMAGE_YUV_NV21)
            ) {
                iamgeInput.textureID = glThread.getTexture(
                    GLES30.GL_RGBA,
                    iamgeInput.wigth,
                    iamgeInput.height,
                    null
                )
            }
           var res = native_processWithBuffer(
                nativeHandler,
                iamgeInput.textureID,
                iamgeInput.wigth,
                iamgeInput.height,
                iamgeInput.p_data0 ?: ByteArray(0),
                iamgeInput.p_data1 ?: ByteArray(0),
                iamgeInput.p_data2 ?: ByteArray(0),
                iamgeInput.stride_0,
                iamgeInput.stride_1,
                iamgeInput.stride_2,
                iamgeInput.format!!.intFmt,
                iamgeInput.rotationMode!!.intModel
            )
//            iamgeInput.textureID = res;

            GLES30.glFinish()
        }
    }

    fun pixelFreeSetBeautyFiterParam(type: PFBeautyFiterType, value: Float) {
        if (nativeHandler == -1L) {
            return
        }
        glThread.runOnGLThread {
            native_pixelFreeSetBeautyFiterParam(nativeHandler, type.intType, value)
        }
    }

    fun createBeautyItemFormBundle(data: ByteArray, size: Int, type: PFSrcType) {
        if (nativeHandler == -1L) {
            return
        }
        glThread.runOnGLThread {
            native_createBeautyItemFormBundle(nativeHandler, data, size, type.intType)
        }
    }

    fun pixelFreeSetBeautyFiterParam(type: PFBeautyFiterType, value: Int) {
        if (nativeHandler == -1L) {
            return
        }
        glThread.runOnGLThread {
            native_pixelFreeSetBeautyType(nativeHandler,type.intType,value);
        }
    }

    fun pixelFreeSetBeautyExtend(type: PFBeautyFiterType, value: String) {
        if (nativeHandler == -1L) {
            return
        }
        glThread.runOnGLThread {
            native_pixelFreeSetBeautyExtend(nativeHandler,value);
        }
    }

    /**
     * 设置滤镜
     *
     * @param filterName
     * @param value
     */
    fun pixelFreeSetFiterParam(filterName: String, value: Float) {
        if (nativeHandler == -1L) {
            return
        }
        glThread.runOnGLThread {
            native_pixelFreeSetFiterParam(nativeHandler, filterName, value)
        }
    }

    private external fun native_create(): Long
    private external fun native_auth(handler: Long, context: Context, data: ByteArray, size: Int)
    private external fun native_release(handler: Long)
    private external fun native_processWithBuffer(
        handler: Long,
        textureID: Int,
        wigth: Int,
        height: Int,
        p_data0: ByteArray? = null,
        p_data1: ByteArray? = null,
        p_data2: ByteArray? = null,
        stride_0: Int,
        stride_1: Int,
        stride_2: Int,
        format: Int,
        rotationMode: Int
    ):Int

    private external fun native_pixelFreeSetFiterParam(
        handler: Long,
        filterName: String, value: Float
    )

    private external fun native_pixelFreeSetBeautyFiterParam(
        handler: Long,
        type: Int, value: Float
    )

    private external fun native_pixelFreeSetBeautyType(
        handler: Long,
        type: Int,value: Int
    )
    private external fun native_pixelFreeSetBeautyExtend(
        handler: Long,value: String
    )

    private external fun native_createBeautyItemFormBundle(
        handler: Long,
        data: ByteArray, size: Int, type: Int
    )
}