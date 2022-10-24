package com.hapi.avcapture.screen;
public interface ImageListener {
    public void onImageAvailable(byte[] rgbaBuffer, int width, int height, int pixelStride, int rowPadding);
}