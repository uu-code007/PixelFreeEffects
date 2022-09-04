package com.liuyue.pixelfreedemo.gl;

import static android.opengl.GLES20.glGetError;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

import javax.microedition.khronos.opengles.GL10;

public class GLUtils {

    private static final String TAG = "GLUtils";

    public static final float[] VERTEX_DATE = {
            1f, 1f, 1f, 1f,
            -1f, 1f, 0f, 1f,
            -1f, -1f, 0f, 0f,
            1f, 1f, 1f, 1f,
            -1f, -1f, 0f, 0f,
            1f, -1f, 1f, 0f
    };

    public static float[] VERTEX_POSITION = {
            -1.0f, -1.0f,
            -1.0f, 1.0f,
            1.0f, -1.0f,
            1.0f, 1.0f,
    };

    public static float[] TEXTURE_COORDINATE = {
            0.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 0.0f,
            1.0f, 1.0f,
    };

    public static final float[] IDENTITY_MATRIX;

    static {
        IDENTITY_MATRIX = new float[16];
        Matrix.setIdentityM(IDENTITY_MATRIX, 0);
    }

    public static final String POSITION_ATTRIBUTE = "aPosition";
    public static final String TEXTURE_COORD_ATTRIBUTE = "aTextureCoordinate";
    public static final String TEXTURE_MATRIX_UNIFORM = "uTextureMatrix";
    public static final String TEXTURE_SAMPLER_UNIFORM = "u_tex";

    public static int loadShader(int type, String shaderSource) {
        int shader = GLES20.glCreateShader(type);
        if (shader == 0) {
            throw new RuntimeException("Create Shader Failed!" + glGetError());
        }
        GLES20.glShaderSource(shader, shaderSource);
        GLES20.glCompileShader(shader);

        final int[] compileStatus = new int[1];
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, compileStatus, 0);
        if (compileStatus[0] == 0) {
            GLES20.glDeleteShader(shader);
            Log.e(TAG, "Compile shader failed.");
            return 0;
        }
        return shader;
    }

    public static int linkProgram(int vertexShader, int fragmentShader) {
        int programObjectId = GLES20.glCreateProgram();
        if (programObjectId == 0) {
            throw new RuntimeException("Create Program Failed!" + glGetError());
        }
        GLES20.glAttachShader(programObjectId, vertexShader);
        GLES20.glAttachShader(programObjectId, fragmentShader);
        GLES20.glLinkProgram(programObjectId);

        if (!validateProgram(programObjectId)) {
            GLES20.glDeleteProgram(programObjectId);
            return -1;
        }
        return programObjectId;
    }

    public static int linkProgram(String vertexShader, String fragmentShader) {
        int vertexShaderId = loadShader(GLES20.GL_VERTEX_SHADER, vertexShader);
        int fragmentShaderId = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShader);
        if (vertexShaderId == 0 || fragmentShaderId == 0) {
            return -1;
        }
        return linkProgram(vertexShaderId, fragmentShaderId);
    }

    private static boolean validateProgram(int programObjectId) {
        final int[] linkStatus = new int[1];
        GLES20.glGetProgramiv(programObjectId, GLES20.GL_LINK_STATUS, linkStatus, 0);
        if (linkStatus[0] == 0) {
            Log.d(TAG, "Linking of program failed !");
            return false;
        }

        GLES20.glValidateProgram(programObjectId);
        final int[] validateStatus = new int[1];
        GLES20.glGetProgramiv(programObjectId, GLES20.GL_VALIDATE_STATUS, validateStatus, 0);
        Log.d(TAG, "Results of validating program: " + validateStatus[0]
                + "\nLog:" + GLES20.glGetProgramInfoLog(programObjectId));
        return validateStatus[0] != 0;
    }

    public static int createOESTextureObject() {
//        int[] tex = new int[1];
//        GLES20.glGenTextures(1, tex, 0);
//        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, tex[0]);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
//                GL10.GL_TEXTURE_MIN_FILTER, GL10.GL_NEAREST);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
//                GL10.GL_TEXTURE_MAG_FILTER, GL10.GL_LINEAR);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
//                GL10.GL_TEXTURE_WRAP_S, GL10.GL_CLAMP_TO_EDGE);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
//                GL10.GL_TEXTURE_WRAP_T, GL10.GL_CLAMP_TO_EDGE);
//        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0);
//        return tex[0];
        int[] textures = new int[1];
        GLES20.glGenTextures(1, textures, 0);
        return textures[0];
    }

    public static FloatBuffer createBuffer(float[] vertexData) {
        FloatBuffer buffer = ByteBuffer.allocateDirect(vertexData.length * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer();
        buffer.put(vertexData);
        buffer.rewind();
        return buffer;
    }

    public static int createFBO() {
        int[] fbo = new int[1];
        GLES20.glGenFramebuffers(1, fbo, 0);
        return fbo[0];
    }

    public static int createImageTexture(ByteBuffer data, int width, int height, int format) {
        int[] textureHandles = new int[1];
        int textureHandle;

        GLES20.glGenTextures(1, textureHandles, 0);
        textureHandle = textureHandles[0];
        checkGlError("glGenTextures");

        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureHandle);

        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER,
                GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER,
                GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S,
                GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T,
                GLES20.GL_CLAMP_TO_EDGE);
        checkGlError("loadImageTexture");

        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, format,
                width, height, 0, format, GLES20.GL_UNSIGNED_BYTE, data);
        checkGlError("loadImageTexture");
        return textureHandle;
    }

    public static boolean checkGlError(String op) {
        int error = GLES20.glGetError();
        if (error != GLES20.GL_NO_ERROR) {
            String msg = op + ": glError 0x" + Integer.toHexString(error);
            Log.e(TAG, msg);
            return false;
        }
        return true;
    }


}
