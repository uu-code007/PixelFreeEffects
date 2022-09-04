package com.liuyue.pixelfreedemo.camera;

import android.graphics.Bitmap;
import android.graphics.SurfaceTexture;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.os.Environment;
import android.util.Log;

import com.liuyue.pixelfreedemo.gl.ExternalTextureConverter;
import com.liuyue.pixelfreedemo.gl.GLUtils;
import com.liuyue.pixelfreedemo.gl.PreviewRenderer;
import com.liuyue.pixelfreedemo.gl.TextureProcessor;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.Buffer;
import java.nio.ByteBuffer;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class CameraRender implements GLSurfaceView.Renderer {

    private static final String TAG = "CameraRender";

    private final GLSurfaceView mGLSurfaceView;
    private SurfaceTexture mSurfaceTexture;
    private int mSurfaceTextureWidth;
    private int mSurfaceTextureHeight;

    private ExternalTextureConverter mTextureConverter;
    private TextureProcessor mTextureProcessor;
    private PreviewRenderer mPreviewRenderer;

    private int mOESTextureId;
    private final float[] transformMatrix = new float[16];

    private VideoFrameListener mVideoFrameListener;

    public CameraRender(final GLSurfaceView glSurfaceView) {
        mGLSurfaceView = glSurfaceView;
        mGLSurfaceView.setEGLContextClientVersion(2);
        mGLSurfaceView.setRenderer(this);
        mGLSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        mTextureConverter = new ExternalTextureConverter();
        mTextureProcessor = new TextureProcessor();
        mPreviewRenderer = new PreviewRenderer();
    }

    public void setVideoFrameListener(VideoFrameListener videoFrameListener) {
        mVideoFrameListener = videoFrameListener;
    }

    public SurfaceTexture getSurfaceTexture() {
        return mSurfaceTexture;
    }

    public void rotate(float degree, float x, float y, float z) {
        mTextureProcessor.rotate(degree, x, y, z);
    }

    public void mirror() {
        mTextureProcessor.mirror();
    }

    public void scale(float scaleX, float scaleY) {
        mTextureProcessor.scale(scaleX, scaleY);
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        mOESTextureId = GLUtils.createOESTextureObject();

        initSurfaceTexture();
        if (mVideoFrameListener != null) {
            mVideoFrameListener.onSurfaceCreated();
        }
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        mSurfaceTextureWidth = width;
        mSurfaceTextureHeight = height;

        mTextureConverter.setViewportSize(width, height);
        mTextureProcessor.setViewportSize(width, height);
        mPreviewRenderer.setViewportSize(width, height);

        Log.e("飞", width + " " + height);

        if (mVideoFrameListener != null) {
            mVideoFrameListener.onSurfaceChanged(width, height);
        }
    }

    @Override
    public void onDrawFrame(GL10 gl) {
//        Log.e("飞", ": "+System.currentTimeMillis());
        if (mSurfaceTexture != null) {
            mSurfaceTexture.updateTexImage();
            mSurfaceTexture.getTransformMatrix(transformMatrix);
        }
        int texId = mTextureConverter.draw(mOESTextureId);

        texId = mTextureProcessor.draw(texId);

        if (mVideoFrameListener != null) {
            VideoFrame videoFrame = new VideoFrame(texId, mSurfaceTextureWidth, mSurfaceTextureHeight, mSurfaceTexture.getTimestamp());
            mVideoFrameListener.onDrawFrame(videoFrame);
            texId = videoFrame.getTextureId();
        }

        mPreviewRenderer.draw(texId);
    }

    static int i = 0;

    static void sendImage(int width, int height) {
        i++;
        if (i < 30 || i > 40) {
            return;
        }
        ByteBuffer rgbaBuf = ByteBuffer.allocateDirect(width * height * 4);
        rgbaBuf.position(0);
        GLES20.glReadPixels(0, 0, width, height, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE,
                rgbaBuf);
        saveRgb2Bitmap(rgbaBuf, Environment.getExternalStorageDirectory().getAbsolutePath()
                + "/gl_dump_" + i + ".png", width, height);
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

    public void release(){
        mTextureConverter.release();
        mTextureProcessor.release();
        mPreviewRenderer.release();
    }


    private void initSurfaceTexture() {
        mSurfaceTexture = new SurfaceTexture(mOESTextureId);
        mSurfaceTexture.setOnFrameAvailableListener(surfaceTexture -> mGLSurfaceView.requestRender());
    }
}
