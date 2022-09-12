package com.liuyue.pixelfreedemo.core;

public class ImageInput {

    private int textureID;
    private int width;
    private int height;
    private byte[] BGRA;
    private byte[] Y;
    private byte[] CbCr;
    private int BGRAStride;
    private int YStride;
    private int CbCrStride;

    private ImageFormat format;
    private ImageRotation rotation;

    public ImageInput(int textureID, int width, int height) {
        this.textureID = textureID;
        this.width = width;
        this.height = height;
    }

    public ImageInput(int width, int height, byte[] BGRA, int BGRAStride) {
        this.width = width;
        this.height = height;
        this.BGRA = BGRA;
        this.BGRAStride = BGRAStride;
    }

    public ImageInput(int width, int height, byte[] y, byte[] cbCr, int YStride, int cbCrStride) {
        this.width = width;
        this.height = height;
        Y = y;
        CbCr = cbCr;
        this.YStride = YStride;
        CbCrStride = cbCrStride;
    }

    public int getTextureID() {
        return textureID;
    }

    public ImageInput setTextureID(int textureID) {
        this.textureID = textureID;
        return this;
    }

    public int getWidth() {
        return width;
    }

    public ImageInput setWidth(int width) {
        this.width = width;
        return this;
    }

    public int getHeight() {
        return height;
    }

    public ImageInput setHeight(int height) {
        this.height = height;
        return this;
    }

    public byte[] getBGRA() {
        return BGRA;
    }

    public ImageInput setBGRA(byte[] BGRA) {
        this.BGRA = BGRA;
        return this;
    }

    public byte[] getY() {
        return Y;
    }

    public ImageInput setY(byte[] y) {
        Y = y;
        return this;
    }

    public byte[] getCbCr() {
        return CbCr;
    }

    public ImageInput setCbCr(byte[] cbCr) {
        CbCr = cbCr;
        return this;
    }

    public int getBGRAStride() {
        return BGRAStride;
    }

    public ImageInput setBGRAStride(int BGRAStride) {
        this.BGRAStride = BGRAStride;
        return this;
    }

    public int getYStride() {
        return YStride;
    }

    public ImageInput setYStride(int YStride) {
        this.YStride = YStride;
        return this;
    }

    public int getCbCrStride() {
        return CbCrStride;
    }

    public ImageInput setCbCrStride(int cbCrStride) {
        CbCrStride = cbCrStride;
        return this;
    }

    public ImageFormat getFormat() {
        return format;
    }

    public ImageInput setFormat(ImageFormat format) {
        this.format = format;
        return this;
    }

    public ImageRotation getRotation() {
        return rotation;
    }

    public ImageInput setRotation(ImageRotation rotation) {
        this.rotation = rotation;
        return this;
    }
}
