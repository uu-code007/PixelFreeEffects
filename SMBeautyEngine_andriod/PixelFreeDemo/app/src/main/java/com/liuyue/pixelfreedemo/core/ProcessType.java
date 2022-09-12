package com.liuyue.pixelfreedemo.core;

public enum ProcessType {
    /**
     * 滤镜处理
     */
    FILTER(0),
    /**
     * 检测
     */
    DETECT(1);

    int value;

    ProcessType(int value) {
        this.value = value;
    }
}
