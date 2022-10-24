package com.hapi.pixelfree.gl

import android.opengl.*
import android.util.Log
import java.nio.ByteBuffer


internal object OpenGLTools {
    private var numIdex: Int = 0;
    private val mEGLCore = EGLCore()
    var sur: EGLSurface? = null
    var textures: IntArray? = null
    var context:EGLContext?=null
    fun createTexture(format:Int,width: Int, height: Int, buffer: ByteBuffer): Int {
        Log.d("mjl", "eglMakeCurrent")
        if (textures == null) {
            // 新建纹理ID
            textures = IntArray(2)
            GLES30.glGenTextures(2, textures, 0)

        }
        val index: Int = numIdex % 2;
        numIdex++;
        // 绑定纹理ID
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, textures!![index])
        // 根据颜色参数，宽高等信息，为上面的纹理ID，生成一个2D纹理
        GLES30.glTexImage2D(
            GLES30.GL_TEXTURE_2D, 0, format, width, height,
            0, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, buffer
        )
        // 设置纹理边缘参数
        GLES30.glTexParameterf(
            GLES30.GL_TEXTURE_2D,
            GLES30.GL_TEXTURE_MIN_FILTER,
            GLES30.GL_NEAREST.toFloat()
        )
        GLES30.glTexParameterf(
            GLES30.GL_TEXTURE_2D,
            GLES30.GL_TEXTURE_MAG_FILTER,
            GLES30.GL_LINEAR.toFloat()
        )
        GLES30.glTexParameterf(
            GLES30.GL_TEXTURE_2D,
            GLES30.GL_TEXTURE_WRAP_S,
            GLES30.GL_CLAMP_TO_EDGE.toFloat()
        )
        GLES30.glTexParameterf(
            GLES30.GL_TEXTURE_2D,
            GLES30.GL_TEXTURE_WRAP_T,
            GLES30.GL_CLAMP_TO_EDGE.toFloat()
        )
        // 解绑纹理ID
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, 0)

        Log.d("aaa", "toPFIamgeInput: texture --" + index + "textrue" + textures!![index]);
        return textures!![index];
    }

    fun switchContext() {
        mEGLCore.makeCurrent(sur!!);
    }

    fun load() {
        context = EGL14.eglGetCurrentContext();
    }

    fun bind() {
        mEGLCore.init(context!!, EGL_RECORDABLE_ANDROID)
        sur = mEGLCore.createOffscreenSurface(100, 100)
    }
    fun isBind():Boolean{
        return sur==null
    }

    fun release() {
        textures?.let {
            GLES30.glDeleteTextures(2, textures, 0)
        }
        textures = null
        mEGLCore.release()
    }

}