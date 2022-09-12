package com.liuyue.pixelfreedemo.core;

public enum ImageRotation {
    Rotation_0(0),
    Rotation_90(1),
    Rotation_180(2),
    Rotation_270(3);

    public int value;

    ImageRotation(int value) {
        this.value = value;
    }
}
