package com.byteflow.pixelfree

import android.content.Context
import java.io.InputStream

class PixelFree {
    companion object {
        init {
            System.loadLibrary("pixel")
        }
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

    private var nativeHandler: Long = -1
    fun isCreate(): Boolean {
        return nativeHandler != -1L
    }

    fun create() {
        nativeHandler = native_create()
    }

    fun release() {
        native_release(nativeHandler)
        nativeHandler=-1
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
            iamgeInput.p_BGRA ?: ByteArray(0),
            iamgeInput.p_Y ?: ByteArray(0),
            iamgeInput.p_CbCr ?: ByteArray(0),
            iamgeInput.stride_BGRA,
            iamgeInput.stride_Y,
            iamgeInput.stride_CbCr,
            iamgeInput.format!!.intFmt,
            iamgeInput.rotationMode!!.intModel
        )
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
        p_BGRA: ByteArray? = null,
        p_Y: ByteArray? = null,
        p_CbCr: ByteArray? = null,
        stride_BGRA: Int,
        stride_Y: Int,
        stride_CbCr: Int,
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