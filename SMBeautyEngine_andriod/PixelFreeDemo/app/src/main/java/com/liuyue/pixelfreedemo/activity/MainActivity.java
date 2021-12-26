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
import com.liuyue.pixelfreedemo.utils.PermissionUtils;

public class MainActivity extends AppCompatActivity {

    private GLSurfaceView mGLSurfaceView;
    private CameraHelper mCameraHelper;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        PermissionUtils.request(this, Manifest.permission.CAMERA);
        initCamera();
    }

    private void initCamera() {
        mGLSurfaceView = findViewById(R.id.surface);
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        CameraSetting cameraSetting = new CameraSetting();
        cameraSetting.setCameraFacing(CameraFacing.FRONT);
        mCameraHelper = new CameraHelper(MainActivity.this, cameraSetting);
        mCameraHelper.startPreview(mGLSurfaceView);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
