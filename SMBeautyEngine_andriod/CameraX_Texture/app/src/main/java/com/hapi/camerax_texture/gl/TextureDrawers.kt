package com.hapi.camerax_texture.gl

import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.Matrix

internal class OesTo2DDrawer {
    private val program = GlUtil.createProgram(VERTEX, FRAGMENT_OES)
    private val aPosition = GLES20.glGetAttribLocation(program, "aPosition")
    private val aTexCoord = GLES20.glGetAttribLocation(program, "aTexCoord")
    private val uTexMatrix = GLES20.glGetUniformLocation(program, "uTexMatrix")
    private val uTexture = GLES20.glGetUniformLocation(program, "uTexture")

    fun draw(oesTexture: Int, transformMatrix: FloatArray) {
        GLES20.glUseProgram(program)
        GLES20.glEnableVertexAttribArray(aPosition)
        GLES20.glVertexAttribPointer(aPosition, 2, GLES20.GL_FLOAT, false, 0, GlUtil.FULL_RECTANGLE_BUF)
        GLES20.glEnableVertexAttribArray(aTexCoord)
        GLES20.glVertexAttribPointer(aTexCoord, 2, GLES20.GL_FLOAT, false, 0, GlUtil.FULL_RECTANGLE_TEX_BUF)
        GLES20.glUniformMatrix4fv(uTexMatrix, 1, false, transformMatrix, 0)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, oesTexture)
        GLES20.glUniform1i(uTexture, 0)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0)
        GLES20.glDisableVertexAttribArray(aPosition)
        GLES20.glDisableVertexAttribArray(aTexCoord)
        GLES20.glUseProgram(0)
    }

    fun release() {
        GLES20.glDeleteProgram(program)
    }
}

internal class Texture2DDrawer {
    private val program = GlUtil.createProgram(VERTEX, FRAGMENT_2D)
    private val aPosition = GLES20.glGetAttribLocation(program, "aPosition")
    private val aTexCoord = GLES20.glGetAttribLocation(program, "aTexCoord")
    private val uTexMatrix = GLES20.glGetUniformLocation(program, "uTexMatrix")
    private val uTexture = GLES20.glGetUniformLocation(program, "uTexture")
    private val texMatrix = FloatArray(16)

    fun draw(textureId: Int, mirrorX: Boolean = false, flipY: Boolean = false) {
        Matrix.setIdentityM(texMatrix, 0)
        if (mirrorX || flipY) {
            Matrix.translateM(texMatrix, 0, 0.5f, 0.5f, 0f)
            Matrix.scaleM(
                texMatrix,
                0,
                if (mirrorX) -1f else 1f,
                if (flipY) -1f else 1f,
                1f
            )
            Matrix.translateM(texMatrix, 0, -0.5f, -0.5f, 0f)
        }
        GLES20.glUseProgram(program)
        GLES20.glEnableVertexAttribArray(aPosition)
        GLES20.glVertexAttribPointer(aPosition, 2, GLES20.GL_FLOAT, false, 0, GlUtil.FULL_RECTANGLE_BUF)
        GLES20.glEnableVertexAttribArray(aTexCoord)
        GLES20.glVertexAttribPointer(aTexCoord, 2, GLES20.GL_FLOAT, false, 0, GlUtil.FULL_RECTANGLE_TEX_BUF)
        GLES20.glUniformMatrix4fv(uTexMatrix, 1, false, texMatrix, 0)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId)
        GLES20.glUniform1i(uTexture, 0)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        GLES20.glDisableVertexAttribArray(aPosition)
        GLES20.glDisableVertexAttribArray(aTexCoord)
        GLES20.glUseProgram(0)
    }

    fun release() {
        GLES20.glDeleteProgram(program)
    }
}

private const val VERTEX = """
attribute vec4 aPosition;
attribute vec4 aTexCoord;
uniform mat4 uTexMatrix;
varying vec2 vTexCoord;
void main() {
    gl_Position = aPosition;
    vTexCoord = (uTexMatrix * aTexCoord).xy;
}
"""

private const val FRAGMENT_OES = """
#extension GL_OES_EGL_image_external : require
precision mediump float;
varying vec2 vTexCoord;
uniform samplerExternalOES uTexture;
void main() {
    gl_FragColor = texture2D(uTexture, vTexCoord);
}
"""

private const val FRAGMENT_2D = """
precision mediump float;
varying vec2 vTexCoord;
uniform sampler2D uTexture;
void main() {
    gl_FragColor = texture2D(uTexture, vTexCoord);
}
"""
