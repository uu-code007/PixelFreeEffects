package com.liuyue.pixelfreedemo.activity;

import android.Manifest;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.util.DisplayMetrics;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.liuyue.pixelfreedemo.R;
import com.liuyue.pixelfreedemo.camera.CameraFacing;
import com.liuyue.pixelfreedemo.camera.CameraHelper;
import com.liuyue.pixelfreedemo.camera.CameraSetting;
import com.liuyue.pixelfreedemo.camera.VideoFrame;
import com.liuyue.pixelfreedemo.camera.VideoFrameListener;
import com.liuyue.pixelfreedemo.core.EffectProcessor;
import com.liuyue.pixelfreedemo.utils.PermissionUtils;

public class MainActivity extends AppCompatActivity {

    private GLSurfaceView mGLSurfaceView;
    private CameraHelper mCameraHelper;

    private EffectProcessor mEffectProcessor;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        PermissionUtils.request(this, Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        PermissionUtils.requestExternalStorageManager(this);

        initCamera();
        mEffectProcessor = new EffectProcessor();
    }

    private void initCamera() {
        mGLSurfaceView = findViewById(R.id.surface);
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        CameraSetting cameraSetting = new CameraSetting();
        cameraSetting.setCameraFacing(CameraFacing.BACK);
        mCameraHelper = new CameraHelper(MainActivity.this, cameraSetting);
        mCameraHelper.setVideoFrameLisener(mVideoFrameListener);
        mCameraHelper.startPreview(mGLSurfaceView);
    }

    private VideoFrameListener mVideoFrameListener = new VideoFrameListener() {
        @Override
        public void onSurfaceCreated() {

        }

        @Override
        public void onSurfaceChanged(int width, int height) {

        }

        @Override
        public void onDrawFrame(VideoFrame videoFrame) {

        }

        @Override
        public void onSurfaceDestroy() {

        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
