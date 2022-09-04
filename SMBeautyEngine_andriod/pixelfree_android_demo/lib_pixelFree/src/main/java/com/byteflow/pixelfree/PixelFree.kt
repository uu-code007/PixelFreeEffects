package com.byteflow.pixelfree

import android.content.Context
import android.opengl.GLES30
import java.io.InputStream

class PixelFree {
    companion object {
        init {
            System.loadLibrary("pixel")
        }
    }
    val glThread = GLThread()
    private var nativeHandler: Long = -1
    fun isCreate(): Boolean {
        return nativeHandler != -1L
    }
    fun create() {
        nativeHandler = native_create()
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
        native_release(nativeHandler)
        nativeHandler=-1
        glThread.release()
    }

    fun processWithBuffer(iamgeInput: PFIamgeInput) {
        if(nativeHandler==-1L){
            return
        }
        native_processWithBuffer(
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
        GLES30.glFinish()
    }

    fun pixelFreeSetBeautyFiterParam(type: PFBeautyFiterType, value: Float) {
        if(nativeHandler==-1L){
            return
        }
        native_pixelFreeSetBeautyFiterParam(nativeHandler, type.intType, value)
    }

    fun createBeautyItemFormBundle(data: ByteArray, size: Int, type: PFSrcType) {
        if(nativeHandler==-1L){
            return
        }
        native_createBeautyItemFormBundle(nativeHandler, data, size, type.intType)
    }

    /**
     * 设置滤镜
     *
     * @param filterName
     * @param value
     */
    fun pixelFreeSetFiterParam(filterName: String, value: Float) {
        if(nativeHandler==-1L){
            return
        }
        native_pixelFreeSetFiterParam(nativeHandler, filterName, value)
    }

    private external fun native_create(): Long
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
    )

    private external fun native_pixelFreeSetFiterParam(
        handler: Long,
        filterName: String, value: Float
    )

    private external fun native_pixelFreeSetBeautyFiterParam(
        handler: Long,
        type: Int, value: Float
    )

    private external fun native_createBeautyItemFormBundle(
        handler: Long,
        data: ByteArray, size: Int, type: Int
    )
}