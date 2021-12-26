package com.liuyue.pixelfreedemo.camera;

public class VideoFrame {
    private int textureId;
    private int width;
    private int height;
    private long timestampNs;

    public VideoFrame(int textureId, int width, int height, long timestampNs) {
        this.textureId = textureId;
        this.width = width;
        this.height = height;
        this.timestampNs = timestampNs;
    }

    public int getTextureId() {
        return textureId;
    }

    public VideoFrame setTextureId(int textureId) {
        this.textureId = textureId;
        return this;
    }

    public int getWidth() {
        return width;
    }

    public VideoFrame setWidth(int width) {
        this.width = width;
        return this;
    }

    public int getHeight() {
        return height;
    }

    public VideoFrame setHeight(int height) {
        this.height = height;
        return this;
    }

    public long getTimestampNs() {
        return timestampNs;
    }

    public VideoFrame setTimestampNs(long timestampNs) {
        this.timestampNs = timestampNs;
        return this;
    }
}
