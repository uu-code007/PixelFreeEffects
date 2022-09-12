package com.liuyue.pixelfreedemo.core;

public class EffectProcessor {

    static {
        System.load("pixel_free_jni");
    }

    public EffectProcessor() {
        create();
    }

    public void release() {
        destroy();
    }

    private native boolean create();

    private native boolean destroy();

    private native void process(ImageInput imageInput);

    private native void setBeauty(int type, Object value);

    private native void createBeautyItem(Object data, int size, int processType);
}
