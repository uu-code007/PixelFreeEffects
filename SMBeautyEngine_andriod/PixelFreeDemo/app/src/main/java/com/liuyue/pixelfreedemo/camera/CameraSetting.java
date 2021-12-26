package com.liuyue.pixelfreedemo.camera;

public class CameraSetting {

    private CameraFacing mCameraFacing = CameraFacing.BACK;
    private int mCameraWidth = 1080;
    private int mCameraHeight = 1920;

    public CameraFacing getCameraFacing() {
        return mCameraFacing;
    }

    public CameraSetting setCameraFacing(CameraFacing cameraFacing) {
        mCameraFacing = cameraFacing;
        return this;
    }

    public int getCameraWidth() {
        return mCameraWidth;
    }

    public CameraSetting setCameraWidth(int cameraWidth) {
        mCameraWidth = cameraWidth;
        return this;
    }

    public int getCameraHeight() {
        return mCameraHeight;
    }

    public CameraSetting setCameraHeight(int cameraHeight) {
        mCameraHeight = cameraHeight;
        return this;
    }
}
