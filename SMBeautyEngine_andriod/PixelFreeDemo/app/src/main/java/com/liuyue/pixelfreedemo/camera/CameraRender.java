package com.liuyue.pixelfreedemo.camera;

import android.graphics.SurfaceTexture;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.util.Log;

import com.liuyue.pixelfreedemo.R;
import com.liuyue.pixelfreedemo.gl.GLUtils;
import com.liuyue.pixelfreedemo.utils.AppUtils;
import com.liuyue.pixelfreedemo.utils.ResourceUtils;

import java.nio.FloatBuffer;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class CameraRender implements GLSurfaceView.Renderer {

    private static final String TAG = "CameraRender";

    private final GLSurfaceView mGLSurfaceView;
    private SurfaceTexture mSurfaceTexture;

    private int mOESTextureId;
    private int mShaderProgram = -1;
    private FloatBuffer mDataBuffer;
    private int[] mFBOIds = new int[1];
    private float[] transformMatrix = new float[16];

    private VideoFrameListener mVideoFrameListener;

    public CameraRender(final GLSurfaceView glSurfaceView) {
        mGLSurfaceView = glSurfaceView;
        mGLSurfaceView.setEGLContextClientVersion(2);
        mGLSurfaceView.setRenderer(this);
    }

    public void setVideoFrameListener(VideoFrameListener videoFrameListener) {
        mVideoFrameListener = videoFrameListener;
    }

    public SurfaceTexture getSurfaceTexture() {
        return mSurfaceTexture;
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        mOESTextureId = GLUtils.createOESTextureObject();
        mDataBuffer = GLUtils.createBuffer(GLUtils.VERTEX_DATE);
        int vertexShader = GLUtils.loadShader(GLES20.GL_VERTEX_SHADER, ResourceUtils.loadStringFromResource(AppUtils.getApp(), R.raw.base_vertex_shader));
        int fragmentShader = GLUtils.loadShader(GLES20.GL_FRAGMENT_SHADER, ResourceUtils.loadStringFromResource(AppUtils.getApp(), R.raw.base_fragment_shader));
        mShaderProgram = GLUtils.linkProgram(vertexShader, fragmentShader);
        GLES20.glGenFramebuffers(1, mFBOIds, 0);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFBOIds[0]);

        initSurfaceTexture();
        if (mVideoFrameListener != null) {
            mVideoFrameListener.onSurfaceCreated();
        }
        Log.i(TAG, "onSurfaceCreated: mFBOId: " + mFBOIds[0]);
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        GLES20.glViewport(0, 0, width, height);
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        if (mSurfaceTexture != null) {
            mSurfaceTexture.updateTexImage();
            mSurfaceTexture.getTransformMatrix(transformMatrix);
        }

        GLES20.glClearColor(1.0f, 0.0f, 0.0f, 0.0f);

        int aPositionLocation = GLES20.glGetAttribLocation(mShaderProgram, GLUtils.POSITION_ATTRIBUTE);
        int aTextureCoordLocation = GLES20.glGetAttribLocation(mShaderProgram, GLUtils.TEXTURE_COORD_ATTRIBUTE);
        int uTextureMatrixLocation = GLES20.glGetUniformLocation(mShaderProgram, GLUtils.TEXTURE_MATRIX_UNIFORM);
        int uTextureSamplerLocation = GLES20.glGetUniformLocation(mShaderProgram, GLUtils.TEXTURE_SAMPLER_UNIFORM);

        GLES20.glActiveTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, mOESTextureId);
        GLES20.glUniform1i(uTextureSamplerLocation, 0);
        GLES20.glUniformMatrix4fv(uTextureMatrixLocation, 1, false, transformMatrix, 0);

        if (mDataBuffer != null) {
            mDataBuffer.position(0);
            GLES20.glEnableVertexAttribArray(aPositionLocation);
            GLES20.glVertexAttribPointer(aPositionLocation, 2, GLES20.GL_FLOAT, false, 16, mDataBuffer);

            mDataBuffer.position(2);
            GLES20.glEnableVertexAttribArray(aTextureCoordLocation);
            GLES20.glVertexAttribPointer(aTextureCoordLocation, 2, GLES20.GL_FLOAT, false, 16, mDataBuffer);
        }

        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 6);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
    }

    private void initSurfaceTexture() {
        mSurfaceTexture = new SurfaceTexture(mOESTextureId);
        mSurfaceTexture.setOnFrameAvailableListener(surfaceTexture -> mGLSurfaceView.requestRender());
    }
}
