package com.liuyue.pixelfreedemo.camera;

public interface VideoFrameListener {
    void onSurfaceCreated();
    void onSurfaceChanged(int width, int height);
    void onDrawFrame(VideoFrame videoFrame);
    void onSurfaceDestroy();
}
