package com.liuyue.pixelfreedemo.gl;

import android.graphics.Bitmap;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Environment;

import com.liuyue.pixelfreedemo.R;
import com.liuyue.pixelfreedemo.utils.AppUtils;
import com.liuyue.pixelfreedemo.utils.ResourceUtils;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.FloatBuffer;

/**
 * 负责将 OES 格式纹理转换为 2D 格式纹理
 */
public class ExternalTextureConverter {

    private static final String TAG = "ExternalTextureConverter";

    protected int mWidth;
    protected int mHeight;

    protected int mFbo;
    protected int mOutTex;
    protected int mProgram;
    private int mVboVertices;
    private int mVboTexCoords;
    private int mVerticesLoc;
    private int mTexCoordsLoc;
    private int mMVPMatrixLoc;
    private int mTexTransMatrixLoc;

    private float[] mVertexPosition = GLUtils.VERTEX_POSITION;
    private float[] mTextureCoordinate = GLUtils.TEXTURE_COORDINATE;

    public void setViewportSize(int width, int height) {
        setup();
        mWidth = width;
        mHeight = height;

        releaseOutTex();
        mOutTex = GLUtils.createImageTexture(null, width, height, GLES20.GL_RGBA);
    }

    public int draw(int texId) {
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFbo);
        GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, mOutTex, 0);

        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);

        GLES20.glUseProgram(mProgram);

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, texId);

        setupVBO();

        GLES20.glUniformMatrix4fv(mMVPMatrixLoc, 1, false, GLUtils.IDENTITY_MATRIX, 0);

        GLES20.glUniformMatrix4fv(mTexTransMatrixLoc, 1, false, GLUtils.IDENTITY_MATRIX, 0);

        GLES20.glViewport(0, 0, mWidth, mHeight);

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);

//        sendImage(mWidth,mHeight);

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0);

        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
        return mOutTex;
    }

    static int i =0;
    static void sendImage(int width, int height) {
        i++;
        if (i<30||i>40){
            return;
        }
        ByteBuffer rgbaBuf = ByteBuffer.allocateDirect(width * height * 4);
        rgbaBuf.position(0);
        GLES20.glReadPixels(0, 0, width, height, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE,
                rgbaBuf);
        saveRgb2Bitmap(rgbaBuf, Environment.getExternalStorageDirectory().getAbsolutePath()
                + "/gl_dump_" + i+ ".png", width, height);
    }

    static void saveRgb2Bitmap(Buffer buf, String filename, int width, int height) {
        BufferedOutputStream bos = null;
        try {
            bos = new BufferedOutputStream(new FileOutputStream(filename));
            Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            bmp.copyPixelsFromBuffer(buf);
            bmp.compress(Bitmap.CompressFormat.PNG, 90, bos);
            bmp.recycle();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (bos != null) {
                try {
                    bos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void release() {
        deleteProgram();
        deleteVBO();
        if (mFbo > 0) {
            GLES20.glDeleteFramebuffers(1, new int[]{mFbo}, 0);
            mFbo = 0;
        }
        releaseOutTex();
    }

    private boolean setup() {
        mFbo = GLUtils.createFBO();

        if (!setupShaders()) {
            return false;
        }

        if (!setupLocations()) {
            return false;
        }

        if (!setupBuffers()) {
            return false;
        }
        return true;
    }

    private void releaseOutTex() {
        if (mOutTex > 0) {
            GLES20.glDeleteTextures(1, new int[]{mOutTex}, 0);
            mOutTex = 0;
        }
    }

    private void deleteProgram() {
        if (mProgram > 0) {
            GLES20.glDeleteProgram(mProgram);
            mProgram = 0;
        }
    }

    private void deleteVBO() {
        if (mVboVertices > 0) {
            GLES20.glDeleteBuffers(1, new int[]{mVboVertices}, 0);
            mVboVertices = 0;
        }
        if (mVboTexCoords > 0) {
            GLES20.glDeleteBuffers(1, new int[]{mVboTexCoords}, 0);
            mVboTexCoords = 0;
        }
    }

    private boolean setupBuffers() {
        FloatBuffer mVertices = GLUtils.createBuffer(mVertexPosition);
        FloatBuffer mTexCoords = GLUtils.createBuffer(mTextureCoordinate);

        int[] bufs = new int[2];
        GLES20.glGenBuffers(2, bufs, 0);
        mVboVertices = bufs[0];
        mVboTexCoords = bufs[1];

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, mVboVertices);
        GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, 8 * 4, mVertices, GLES20.GL_STATIC_DRAW);

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, mVboTexCoords);
        GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, 8 * 4, mTexCoords, GLES20.GL_STATIC_DRAW);

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);

        setupVBO();

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);

        return GLUtils.checkGlError(TAG + " setup VAO, VBOs.");
    }

    private void setupVBO() {
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, mVboVertices);
        GLES20.glEnableVertexAttribArray(mVerticesLoc);
        GLES20.glVertexAttribPointer(mVerticesLoc, 2, GLES20.GL_FLOAT, false, 0, 0);

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, mVboTexCoords);
        GLES20.glEnableVertexAttribArray(mTexCoordsLoc);
        GLES20.glVertexAttribPointer(mTexCoordsLoc, 2, GLES20.GL_FLOAT, false, 0, 0);
    }

    private boolean setupShaders() {
        String vertexShaderStr = ResourceUtils.loadStringFromResource(AppUtils.getApp(), R.raw.texture_vs);
        String fragmentShaderStr = ResourceUtils.loadStringFromResource(AppUtils.getApp(), R.raw.texture_external_fs);
        mProgram = GLUtils.linkProgram(vertexShaderStr, fragmentShaderStr);
        return mProgram != 0;
    }

    private boolean setupLocations() {
        mVerticesLoc = GLES20.glGetAttribLocation(mProgram, "a_pos");
        mTexCoordsLoc = GLES20.glGetAttribLocation(mProgram, "a_tex");
        mMVPMatrixLoc = GLES20.glGetUniformLocation(mProgram, "u_mvp");
        mTexTransMatrixLoc = GLES20.glGetUniformLocation(mProgram, "u_tex_trans");
        return GLUtils.checkGlError(TAG + " glBindAttribLocation");
    }
}
