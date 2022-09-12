package com.liuyue.pixelfreedemo.core;

public enum ImageFormat {
    UNKNOWN(0),
    RGB(1),
    BGR(2),
    RGBA(3),
    BGRA(4),
    ARGB(5),
    ABGR(6),
    GRAY(7),
    YUV_NV12(8),
    YUV_NV21(9),
    YUV_I420(10);

    public int value;

    ImageFormat(int value) {
        this.value = value;
    }
}
