package com.hapi.camerax_texture.gl

import android.opengl.GLES20

internal class TextureFrameBuffer {
    var width = 0
        private set
    var height = 0
        private set
    var textureId = 0
        private set
    private var framebufferId = 0

    fun ensureSize(width: Int, height: Int) {
        if (this.width == width && this.height == height && textureId > 0) {
            return
        }
        release()
        this.width = width
        this.height = height
        textureId = GlUtil.createTexture2D(width, height)
        val framebuffers = IntArray(1)
        GLES20.glGenFramebuffers(1, framebuffers, 0)
        framebufferId = framebuffers[0]
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, framebufferId)
        GLES20.glFramebufferTexture2D(
            GLES20.GL_FRAMEBUFFER,
            GLES20.GL_COLOR_ATTACHMENT0,
            GLES20.GL_TEXTURE_2D,
            textureId,
            0
        )
        val status = GLES20.glCheckFramebufferStatus(GLES20.GL_FRAMEBUFFER)
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)
        if (status != GLES20.GL_FRAMEBUFFER_COMPLETE) {
            throw RuntimeException("Framebuffer is incomplete: $status")
        }
    }

    fun bind() {
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, framebufferId)
    }

    fun release() {
        GlUtil.deleteFramebuffer(framebufferId)
        GlUtil.deleteTexture(textureId)
        framebufferId = 0
        textureId = 0
        width = 0
        height = 0
    }
}
