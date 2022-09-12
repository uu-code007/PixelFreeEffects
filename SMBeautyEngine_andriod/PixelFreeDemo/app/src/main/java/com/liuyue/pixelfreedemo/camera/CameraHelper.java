package com.liuyue.pixelfreedemo.camera;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.util.Size;
import android.util.SizeF;
import android.view.Surface;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class CameraHelper {
    private static final String TAG = "CameraHelper";

    private HandlerThread mCameraThread;
    private Handler mCameraHandler;
    private String mCameraId;
    private Size mPreviewSize;
    private CameraDevice mCameraDevice;
    private CameraCharacteristics mCamCharacteristics;
    private CaptureRequest.Builder mCaptureRequestBuilder;
    private CaptureRequest mCaptureRequest;
    private CameraCaptureSession mCameraCaptureSession;

    private CameraRender mCameraRender;

    private Context mContext;
    private CameraSetting mCameraSetting;
    private VideoFrameListener mVideoFrameListener;

    public CameraHelper(@NonNull Context context, final CameraSetting cameraSetting) {
        mContext = context;
        mCameraSetting = cameraSetting;
        startCameraThread();
        setupCamera(mCameraSetting.getCameraWidth(), mCameraSetting.getCameraHeight(), mCameraSetting.getCameraFacing());
    }

    public void setVideoFrameLisener(VideoFrameListener videoFrameListener) {
        mVideoFrameListener = videoFrameListener;
    }

    public void startPreview(GLSurfaceView glSurfaceView) {
        mCameraRender = new CameraRender(glSurfaceView);
        mCameraRender.setVideoFrameListener(mInnerVideoFrameListener);
        openCamera();
    }

    private void startCameraThread() {
        mCameraThread = new HandlerThread("CameraThread");
        mCameraThread.start();
        mCameraHandler = new Handler(mCameraThread.getLooper());
    }

    private void setupCamera(int width, int height, CameraFacing cameraFacing) {
        CameraManager cameraManager = (CameraManager) mContext.getSystemService(Context.CAMERA_SERVICE);
        try {
            Log.e("飞", "setupCamera: " + cameraManager.getCameraIdList().length);
            for (String id : cameraManager.getCameraIdList()) {
                CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(id);
                if (characteristics.get(CameraCharacteristics.LENS_FACING) != cameraFacing.id) {
                    continue;
                }
                SizeF sizeF = characteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE);
                Size size = characteristics.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE);
                int count = characteristics.get(CameraCharacteristics.REQUEST_PARTIAL_RESULT_COUNT);
                int hardwareLevel = characteristics.get(CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL);

                Log.e("飞", "setupCamera: 前置还是后置？" + characteristics.get(CameraCharacteristics.LENS_FACING) + "  hardwareLevel " + hardwareLevel);
                Log.e("飞", "setupCamera: 像素物理尺寸 " + sizeF.toString());
                Log.e("飞", "setupCamera: 图像传感器面积 " + size.toString());
                Log.e("飞", "setupCamera: 结果由多少子结构构成 " + count);
                StreamConfigurationMap map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                mPreviewSize = getOptimalSize(map.getOutputSizes(SurfaceTexture.class), width, height);
                mCamCharacteristics = characteristics;
                mCameraId = id;
                Log.i(TAG, "preview width = " + mPreviewSize.getWidth() + ", height = " + mPreviewSize.getHeight() + ", cameraId = " + mCameraId);
                break;
            }
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private boolean openCamera() {
        CameraManager cameraManager = (CameraManager) mContext.getSystemService(Context.CAMERA_SERVICE);
        try {
            if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
            // 开启相机，第一个参数指示打开哪个摄像头，第二个参数 mStateCallback 为相机的状态回调接口
            // 第三个参数用来确定 Callback 在哪个线程执行，为 null 的话就在当前线程执行
            cameraManager.openCamera(mCameraId, mStateCallback, mCameraHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    public void startCapture(SurfaceTexture surfaceTexture) {
        // 设置SurfaceTexture的默认尺寸
        surfaceTexture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());
        // 根据mSurfaceTexture创建Surface
        Surface surface = new Surface(surfaceTexture);
        try {
            // 创建preview捕获请求
            mCaptureRequestBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
            // 将此请求输出目标设为我们创建的Surface对象，这个Surface对象也必须添加给createCaptureSession才行
            mCaptureRequestBuilder.addTarget(surface);
            // 创建捕获会话，第一个参数是捕获数据的输出 Surface 列表
            // 第二个参数是 CameraCaptureSession 的状态回调接口，当它创建好后会回调 onConfigured 方法
            // 第三个参数用来确定Callback在哪个线程执行，为null的话就在当前线程执行
            mCameraDevice.createCaptureSession(Collections.singletonList(surface), new CameraCaptureSession.StateCallback() {
                @Override
                public void onConfigured(@NonNull CameraCaptureSession session) {
                    try {
                        // 创建捕获请求
                        mCaptureRequest = mCaptureRequestBuilder.build();
                        mCameraCaptureSession = session;
                        // 设置重复捕获数据的请求，之后surface绑定的 SurfaceTexture 中就会一直有数据到达
                        // 然后就会回调 SurfaceTexture.OnFrameAvailableListener 接口
                        mCameraCaptureSession.setRepeatingRequest(mCaptureRequest, null, mCameraHandler);
                    } catch (CameraAccessException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onConfigureFailed(@NonNull CameraCaptureSession session) {

                }
            }, mCameraHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private VideoFrameListener mInnerVideoFrameListener = new VideoFrameListener() {
        @Override
        public void onSurfaceCreated() {
            int rotation = getDisplayRotation(mContext, mCameraSetting.getCameraFacing(), mCamCharacteristics);
            mCameraRender.rotate(rotation, 0, 0, 1);
            if (mCameraSetting.getCameraFacing() == CameraFacing.BACK) {
                mCameraRender.mirror();
            }
            startCapture(mCameraRender.getSurfaceTexture());
            mVideoFrameListener.onSurfaceCreated();
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

    private Size getOptimalSize(Size[] sizeMap, int width, int height) {
        List<Size> sizeList = new ArrayList<>();
        for (Size option : sizeMap) {
            if (width > height) {
                if (option.getWidth() > width && option.getHeight() > height) {
                    sizeList.add(option);
                }
            } else {
                if (option.getWidth() > height && option.getHeight() > width) {
                    sizeList.add(option);
                }
            }
        }
        if (sizeList.size() > 0) {
            return Collections.min(sizeList, new Comparator<Size>() {
                @Override
                public int compare(Size lhs, Size rhs) {
                    return Long.signum((long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
                }
            });
        }
        return sizeMap[0];
    }

    private CameraDevice.StateCallback mStateCallback = new CameraDevice.StateCallback() {
        @Override
        public void onOpened(@NonNull CameraDevice camera) {
            mCameraDevice = camera;
        }

        @Override
        public void onDisconnected(@NonNull CameraDevice camera) {
            camera.close();
            mCameraDevice = null;
        }

        @Override
        public void onError(@NonNull CameraDevice camera, int error) {
            camera.close();
            mCameraDevice = null;
        }
    };

    private int getDisplayRotation(Context context, CameraFacing cameraFacing, CameraCharacteristics characteristics) {
        int rotation = 0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            rotation = context.getDisplay().getRotation();
        } else {
            WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            rotation = windowManager.getDefaultDisplay().getRotation();
        }
        int sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
        if (cameraFacing == CameraFacing.FRONT) {
            return (360 - (sensorOrientation + rotation) % 360) % 360;
        } else {
            return (sensorOrientation - rotation + 360) % 360;
        }
    }

}
