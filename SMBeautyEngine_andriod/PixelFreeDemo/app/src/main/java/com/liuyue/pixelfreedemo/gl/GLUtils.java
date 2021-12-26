package com.liuyue.pixelfreedemo.gl;

import static android.opengl.GLES20.glAttachShader;
import static android.opengl.GLES20.glCompileShader;
import static android.opengl.GLES20.glCreateProgram;
import static android.opengl.GLES20.glCreateShader;
import static android.opengl.GLES20.glGetError;
import static android.opengl.GLES20.glLinkProgram;
import static android.opengl.GLES20.glShaderSource;
import static android.opengl.GLES20.glUseProgram;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

import javax.microedition.khronos.opengles.GL10;

public class GLUtils {

    public static final float[] VERTEX_DATE = {
            1f, 1f, 1f, 1f,
            -1f, 1f, 0f, 1f,
            -1f, -1f, 0f, 0f,
            1f, 1f, 1f, 1f,
            -1f, -1f, 0f, 0f,
            1f, -1f, 1f, 0f
    };

    public static final String POSITION_ATTRIBUTE = "aPosition";
    public static final String TEXTURE_COORD_ATTRIBUTE = "aTextureCoordinate";
    public static final String TEXTURE_MATRIX_UNIFORM = "uTextureMatrix";
    public static final String TEXTURE_SAMPLER_UNIFORM = "uTextureSampler";

    public static int loadShader(int type, String shaderSource) {
        int shader = GLES20.glCreateShader(type);
        if (shader == 0) {
            throw new RuntimeException("Create Shader Failed!" + glGetError());
        }
        GLES20.glShaderSource(shader, shaderSource);
        GLES20.glCompileShader(shader);
        return shader;
    }

    public static int linkProgram(int verShader, int fragShader) {
        int program = GLES20.glCreateProgram();
        if (program == 0) {
            throw new RuntimeException("Create Program Failed!" + glGetError());
        }
        GLES20.glAttachShader(program, verShader);
        GLES20.glAttachShader(program, fragShader);
        GLES20.glLinkProgram(program);

        GLES20.glUseProgram(program);
        return program;
    }

    public static int createOESTextureObject() {
        int[] tex = new int[1];
        GLES20.glGenTextures(1, tex, 0);
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, tex[0]);
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GL10.GL_TEXTURE_MIN_FILTER, GL10.GL_NEAREST);
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GL10.GL_TEXTURE_MAG_FILTER, GL10.GL_LINEAR);
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GL10.GL_TEXTURE_WRAP_S, GL10.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GL10.GL_TEXTURE_WRAP_T, GL10.GL_CLAMP_TO_EDGE);
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0);
        return tex[0];
    }

    public static FloatBuffer createBuffer(float[] vertexData) {
        FloatBuffer buffer = ByteBuffer.allocateDirect(vertexData.length * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer();
        buffer.put(vertexData, 0, vertexData.length).position(0);
        return buffer;
    }


}
