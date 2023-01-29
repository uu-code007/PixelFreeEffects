package com.hapi.avcapture.video

import android.graphics.PixelFormat.RGBA_8888
import android.media.Image
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.camera.core.ImageProxy

// mImageReader 生产Image 对象 -> rgba
class RGBAProducer {

    var rgbaByteArray: ByteArray? = null
        private set
    var rowPadding = 0
        private set
    var pixelStride = 0
        private set
    var mWidth = 0
    var mHeight = 0
    var rowStride=0

    // 用同一个byte[] 来解析Image -> rgba
    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun parseImg(image: ImageProxy) {
        //获取基本参数
        val f =image.format
        val isrgba =f==RGBA_8888
        mWidth = image.width                            //image中图像数据得到的宽
        mHeight = image.height                          //image中图像数据得到的高
        val planes = image.planes                                //image图像数据对象
        val buffer = planes[0].getBuffer()
        pixelStride = planes[0].getPixelStride()            //像素步幅
         rowStride = planes[0].getRowStride()                    //行距
        rowPadding =
            rowStride - pixelStride * mWidth         //行填充数据（得到的数据宽度大于指定的width,多出来的数据就是填充数据）
        val len: Int = buffer.limit() - buffer.position()

        if ((rgbaByteArray?.size?:0) !=len) {
            rgbaByteArray = ByteArray(len)
        }
        buffer.get(rgbaByteArray!!)
    }

    // 用同一个byte[] 来解析Image -> rgba
    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun parseImg(image: Image) {
        //获取基本参数
        mWidth = image.width                            //image中图像数据得到的宽
        mHeight = image.height                          //image中图像数据得到的高
        val planes = image.planes                                //image图像数据对象
        val buffer = planes[0].getBuffer()
        pixelStride = planes[0].getPixelStride()            //像素步幅
        val rowStride = planes[0].getRowStride()                    //行距
        rowPadding =
            rowStride - pixelStride * mWidth         //行填充数据（得到的数据宽度大于指定的width,多出来的数据就是填充数据）
        val len: Int = buffer.limit() - buffer.position()
        if (rgbaByteArray == null) {
            rgbaByteArray = ByteArray(len)
        }
        buffer.get(rgbaByteArray!!)
    }
}