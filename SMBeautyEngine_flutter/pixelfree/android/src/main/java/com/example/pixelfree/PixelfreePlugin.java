package com.example.pixelfree;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.SurfaceTexture;
import android.opengl.EGLContext;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import androidx.annotation.NonNull;


import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.TextureRegistry;

import com.hapi.pixelfree.PFBeautyFilterType;
import com.hapi.pixelfree.PFSrcType;
import com.hapi.pixelfree.PixelFree;
import com.hapi.pixelfree.PFImageInput;
import com.hapi.pixelfree.PFRotationMode;
import com.hapi.pixelfree.PFDetectFormat;
import com.hapi.pixelfree.PFFaceDetectMode;
import com.hapi.pixelfree.PFMakeupPart;

import android.opengl.*;
import android.util.Log;
import android.util.LongSparseArray;
import android.view.Surface;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

import android.graphics.Bitmap;

import java.nio.ByteBuffer;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;


/**
 * PixelfreePlugin
 */
public class PixelfreePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private static Context mContext = null;

    private FlutterPluginBinding flutterPluginBinding;
    private TextureRegistry textureRegistry;
    private TextureRegistry.SurfaceTextureEntry textureEntry;
    private SurfaceTexture surfaceTexture;

    private PixelFree mPixelFree;

    private byte[] pixels;

    private int openGLTextureId; // 您的 OpenGL 纹理 ID

    CustomRenderVideoFrame customRender;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding;
        mContext = flutterPluginBinding.getApplicationContext();

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pixelfree");
        channel.setMethodCallHandler(this);

    }

    public int onPreProcessFrame(byte[] image, int w, int h) {
        PFImageInput pxInput = new PFImageInput();
        if (mPixelFree != null && mPixelFree.isCreate()) {
            pxInput.setWigth(w);
            pxInput.setHeight(h);
            pxInput.setStride_0(w * 4);
            pxInput.setStride_1(0);
            pxInput.setP_data0(image);
            pxInput.setFormat(PFDetectFormat.PFFORMAT_IMAGE_RGBA);
            pxInput.setRotationMode(PFRotationMode.PFRotationMode0);
            pxInput.setTextureID(0);
            mPixelFree.processWithBuffer(pxInput);
        }
        return pxInput.getTextureID();
    }

    public int onPreProcessTexture(int textureid, int w, int h) {
        PFImageInput pxInput = new PFImageInput();
        if (mPixelFree != null && mPixelFree.isCreate()) {
            pxInput.setWigth(w);
            pxInput.setHeight(h);
            pxInput.setFormat(PFDetectFormat.PFFORMAT_IMAGE_TEXTURE);
            pxInput.setRotationMode(PFRotationMode.PFRotationMode0);
            pxInput.setTextureID(textureid);
            mPixelFree.processWithBuffer(pxInput);
        }
        return pxInput.getTextureID();
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String method = call.method;
        switch (method) {
            case "createWithLic": {
                textureRegistry = flutterPluginBinding.getTextureRegistry();
                textureEntry = flutterPluginBinding.getTextureRegistry().createSurfaceTexture();
                surfaceTexture = textureEntry.surfaceTexture();
                mPixelFree = new PixelFree();
                mPixelFree.create();
                String licPath = (String) call.argument("licPath");

                byte[] bytes = new byte[0];
                try {
                    bytes = loadBinaryFromPath(licPath);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
                byte[] bytes2 = mPixelFree.readBundleFile(mContext, "filter_model.bundle");
                mPixelFree.auth(mContext, bytes, bytes.length);
                mPixelFree.createBeautyItemFormBundle(
                        bytes2,
                        bytes2.length,
                        PFSrcType.PFSrcTypeFilter
                );

                Log.d("[PixelFree]", "bytes len: " + bytes.length + "bytesw len: " + bytes2.length);
//        result.success(textureEntry.id());
                result.success(0);
            }
            break;
            case "isCreate": {
                boolean isCreate = mPixelFree != null && mPixelFree.isCreate();
                result.success(isCreate);
            }
            break;
            case "pixelFreeSetBeautyExtend": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object typeObj = call.argument("type");
                Object valueObj = call.argument("value");
                if (!(typeObj instanceof Number) || !(valueObj instanceof String)) {
                    result.error("INVALID_ARGUMENT", "Invalid argument types", null);
                    return;
                }
                int type = ((Number) typeObj).intValue();
                String value = (String) valueObj;
                mPixelFree.pixelFreeSetBeautyExtend(PFBeautyFilterType.values()[type], value);
                result.success(null);
            }
            break;
            case "pixelFreeSetBeautyFilterParam": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object typeObj = call.argument("type");
                Object valueObj = call.argument("value");
                if (!(typeObj instanceof Number) || !(valueObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "Invalid argument types", null);
                    return;
                }
                int type = ((Number) typeObj).intValue();
                double value = ((Number) valueObj).doubleValue();
                float floatValue = (float) value;
                mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFilterType.values()[type], floatValue);
                result.success(null);
            }
            break;
            case "pixelFreeSetFilterParam": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object valueObj = call.argument("value");
                Object filterNameObj = call.argument("filterName");
                if (!(valueObj instanceof Number) || !(filterNameObj instanceof String)) {
                    result.error("INVALID_ARGUMENT", "Invalid argument types", null);
                    return;
                }
                float value = ((Number) valueObj).floatValue();
                String filterName = (String) filterNameObj;
                mPixelFree.pixelFreeSetFilterParam(filterName, value);
                result.success(null);
            }
            break;

            case "pixelFreeSetBeautyTypeParam": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object typeObj = call.argument("type");
                Object valueObj = call.argument("value");
                if (!(typeObj instanceof Number) || !(valueObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "Invalid argument types", null);
                    return;
                }
                int type = ((Number) typeObj).intValue();
                int value = ((Number) valueObj).intValue();
                // PFBeautyFilterTypeOneKey = 26
                mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFilterType.PFBeautyFilterTypeOneKey, value);
                result.success(null);
            }
            break;

            case "pixelFreeAddHLSFilter": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                @SuppressWarnings("unchecked")
                List<Double> keyColor = (List<Double>) call.argument("keyColor");
                if (keyColor == null || keyColor.size() < 3) {
                    result.error("INVALID_ARGUMENT", "keyColor must be a list of 3 numbers", null);
                    return;
                }
                Object hueObj = call.argument("hue");
                Object saturationObj = call.argument("saturation");
                Object brightnessObj = call.argument("brightness");
                Object similarityObj = call.argument("similarity");
                
                if (!(hueObj instanceof Number) || !(saturationObj instanceof Number) || 
                    !(brightnessObj instanceof Number) || !(similarityObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "Invalid argument types", null);
                    return;
                }

                float[] keyColorArr = new float[] {
                    keyColor.get(0).floatValue(),
                    keyColor.get(1).floatValue(),
                    keyColor.get(2).floatValue()
                };
                float hue = ((Number) hueObj).floatValue();
                float saturation = ((Number) saturationObj).floatValue();
                float brightness = ((Number) brightnessObj).floatValue();
                float similarity = ((Number) similarityObj).floatValue();

                int handle = mPixelFree.addHLSFilter(keyColorArr, hue, saturation, brightness, similarity);
                result.success(handle);
            }
            break;

            case "pixelFreeDeleteHLSFilter": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object handleObj = call.argument("handle");
                if (!(handleObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "handle must be a number", null);
                    return;
                }
                int handle = ((Number) handleObj).intValue();
                mPixelFree.deleteHLSFilter(handle);
                result.success(null);
            }
            break;

            case "pixelFreeChangeHLSFilter": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                @SuppressWarnings("unchecked")
                List<Double> keyColor = (List<Double>) call.argument("keyColor");
                if (keyColor == null || keyColor.size() < 3) {
                    result.error("INVALID_ARGUMENT", "keyColor must be a list of 3 numbers", null);
                    return;
                }
                Object hueObj = call.argument("hue");
                Object saturationObj = call.argument("saturation");
                Object brightnessObj = call.argument("brightness");
                Object similarityObj = call.argument("similarity");
                Object handleObj = call.argument("handle");
                
                if (!(hueObj instanceof Number) || !(saturationObj instanceof Number) || 
                    !(brightnessObj instanceof Number) || !(similarityObj instanceof Number) ||
                    !(handleObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "Invalid argument types", null);
                    return;
                }

                float[] keyColorArr = new float[] {
                    keyColor.get(0).floatValue(),
                    keyColor.get(1).floatValue(),
                    keyColor.get(2).floatValue()
                };
                float hue = ((Number) hueObj).floatValue();
                float saturation = ((Number) saturationObj).floatValue();
                float brightness = ((Number) brightnessObj).floatValue();
                float similarity = ((Number) similarityObj).floatValue();
                int handle = ((Number) handleObj).intValue();

                int ret = mPixelFree.changeHLSFilter(handle, keyColorArr, hue, saturation, brightness, similarity);
                result.success(ret);
            }
            break;

            case "pixelFreeSetColorGrading": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                @SuppressWarnings("unchecked")
                Map<String, Object> params = (Map<String, Object>) call.arguments;
                if (params == null) {
                    result.error("INVALID_ARGUMENT", "params cannot be null", null);
                    return;
                }
                
                try {
                    boolean isUse = (boolean) params.get("isUse");
                    float brightness = ((Number) params.get("brightness")).floatValue();
                    float contrast = ((Number) params.get("contrast")).floatValue();
                    float exposure = ((Number) params.get("exposure")).floatValue();
                    float highlights = ((Number) params.get("highlights")).floatValue();
                    float shadows = ((Number) params.get("shadows")).floatValue();
                    float saturation = ((Number) params.get("saturation")).floatValue();
                    float temperature = ((Number) params.get("temperature")).floatValue();
                    float tint = ((Number) params.get("tint")).floatValue();
                    float hue = ((Number) params.get("hue")).floatValue();

                    int ret = mPixelFree.setColorGrading(
                        brightness, contrast, exposure, highlights, shadows, 
                        saturation, temperature, tint, hue, isUse
                    );
                    result.success(ret);
                } catch (ClassCastException e) {
                    result.error("INVALID_ARGUMENT", "Invalid parameter types in color grading", null);
                }
            }
            break;

//      case "processWithBuffer":
//        try {
//          int textureID = (int) call.argument("textureID");
//          int width = (int) call.argument("width");
//          int height = (int) call.argument("height");
//
//          byte[] data0 = (byte[]) call.argument("data0");
//          byte[] data1 = (byte[]) call.argument("data1");
//          byte[] data2 = (byte[]) call.argument("data2");
//
//          int stride0 = (int) call.argument("stride0");
//          int stride1 = (int) call.argument("stride1");
//          int stride2 = (int) call.argument("stride2");
//
//          int format = (int) call.argument("format");
//          int rotationMode = (int) call.argument("rotationMode");
//
//          result.success(null);
//        } catch (Exception e) {
//          result.error("PROCESS_ERROR", e.getMessage(), null);
//        }
//
//        break;
            case "processWithImage": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                byte[] imageData = (byte[]) call.argument("imageData");
                int w = (int) call.argument("w");
                int h = (int) call.argument("h");

                if (customRender == null) {
                    EGLContext eglContext = mPixelFree.getCurrentGlContext();
                    customRender = new CustomRenderVideoFrame(eglContext);
                    surfaceTexture.setDefaultBufferSize(w, h);
                    customRender.start(surfaceTexture, w, h);
                }
                int textureID = onPreProcessFrame(imageData, w, h);
                customRender.onRenderVideoFrame(textureID);
                result.success(textureEntry.id());
            }
            break;
            case "processWithImageToByteData": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                byte[] imageData = (byte[]) call.argument("imageData");
                int w = (int) call.argument("width");
                int h = (int) call.argument("height");

                int textureID = onPreProcessFrame(imageData, w, h);

                // 创建 Kotlin 函数类型的回调
                Function1<Bitmap, Unit> callback = new Function1<Bitmap, Unit>() {
                    @Override
                    public Unit invoke(Bitmap bitmap) {
                        try {
                            if (bitmap != null) {
//                                Log.d("[PixelFree]", "bitmap width: " + bitmap.getWidth() + ", height: " + bitmap.getHeight());
//                                Log.d("[PixelFree]", "bitmap config: " + bitmap.getConfig());
//                                Log.d("[PixelFree]", "bitmap byte count: " + bitmap.getByteCount());

                                // 直接使用 bitmapToRgbaByteArray 方法
                                byte[] outImageData = bitmapToRgbaByteArray(bitmap);

                                result.success(outImageData);
                                bitmap.recycle();
                            } else {
                                result.error("RENDER_ERROR", "Bitmap is null", null);
                            }
                        } catch (Exception e) {
                            Log.e("[PixelFree]", "Error processing bitmap: " + e.getMessage());
                            result.error("CONVERSION_ERROR", e.getMessage(), null);
                        }
                        return Unit.INSTANCE;
                    }
                };

                try {
                    mPixelFree.textureIdToBitmap(textureID, w, h, callback);
                } catch (Exception e) {
                    result.error("INVALID_ARGS", e.getMessage(), null);
                }
            }
            break;

            case "processWithTextrueID": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                int inputTextureid = (int) call.argument("textrueID");
                int w = (int) call.argument("width");
                int h = (int) call.argument("height");

                int textureID = onPreProcessTexture(inputTextureid, w, h);
                result.success(textureID);
            }
            break;

            

            case "release": {
                if (mPixelFree != null) {
                    mPixelFree.release();
                    mPixelFree = null;
                }
                result.success(null);
            }
            break;

            case "getVersion": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                String version = mPixelFree.getVersion();
                result.success(version);
            }
            break;

            case "setVLogLevel": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object levelObj = call.argument("level");
                Object pathObj = call.argument("path");
                if (!(levelObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "level must be a number", null);
                    return;
                }
                int level = ((Number) levelObj).intValue();
                String path = pathObj instanceof String ? (String) pathObj : "";
                mPixelFree.setLogLevel(level, path);
                result.success(null);
            }
            break;

            case "getFaceRect": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                float[] faceRect = mPixelFree.getFaceRect();
                if (faceRect == null) {
                    result.success(new ArrayList<>());
                } else {
                    List<Double> faceRectList = new ArrayList<>();
                    for (float f : faceRect) {
                        faceRectList.add((double) f);
                    }
                    result.success(faceRectList);
                }
            }
            break;

            case "getFaceSize": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                int faceSize = mPixelFree.getFaceCount();
                result.success(faceSize);
            }
            break;

            case "setDetectMode": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object modeObj = call.argument("mode");
                if (!(modeObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "mode must be a number", null);
                    return;
                }
                int modeIndex = ((Number) modeObj).intValue();
                // mode: 0 = IMAGE, 1 = VIDEO
                PFFaceDetectMode mode = modeIndex == 0 ? PFFaceDetectMode.PF_FACE_DETECT_MODE_IMAGE : PFFaceDetectMode.PF_FACE_DETECT_MODE_VIDEO;
                mPixelFree.setDetectMode(mode);
                result.success(null);
            }
            break;

            case "hasFace": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                int hasFace = mPixelFree.hasFace();
                result.success(hasFace != 0);
            }
            break;

            case "setMakeupPath": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object pathObj = call.argument("makeupJsonPath");
                if (!(pathObj instanceof String)) {
                    result.error("INVALID_ARGUMENT", "makeupJsonPath must be a string", null);
                    return;
                }
                String makeupJsonPath = (String) pathObj;
                int ret = mPixelFree.setMakeupPath(makeupJsonPath);
                result.success(ret);
            }
            break;

            case "clearMakeup": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                int ret = mPixelFree.clearMakeup();
                result.success(ret);
            }
            break;

            case "setMakeupPartDegree": {
                if (mPixelFree == null) {
                    result.error("NOT_INITIALIZED", "PixelFree not initialized", null);
                    return;
                }
                Object partObj = call.argument("part");
                Object degreeObj = call.argument("degree");
                if (!(partObj instanceof Number) || !(degreeObj instanceof Number)) {
                    result.error("INVALID_ARGUMENT", "part and degree must be numbers", null);
                    return;
                }
                int partIndex = ((Number) partObj).intValue();
                double degree = ((Number) degreeObj).doubleValue();
                PFMakeupPart part = PFMakeupPart.values()[partIndex];
                int ret = mPixelFree.setMakeupPartDegree(part, (float) degree);
                result.success(ret);
            }
            break;

            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    // 通过绝对路径读取二进制文件
    public byte[] loadBinaryFromPath(String filePath) throws IOException {
        File file = new File(filePath);
        FileInputStream fis = new FileInputStream(file);
        byte[] data = new byte[(int) file.length()];
        fis.read(data);
        fis.close();
        return data;
    }

    private byte[] bitmapToRgbaByteArray(Bitmap bitmap) {
        try {
            int size = bitmap.getByteCount();

            ByteBuffer buffer = ByteBuffer.allocate(size);
            bitmap.copyPixelsToBuffer(buffer);
            buffer.rewind();

            byte[] data = buffer.array();
//            Log.d("[PixelFree]", "Buffer array length: " + data.length);

            // 验证数据
            if (data.length == 0) {
                Log.e("[PixelFree]", "Buffer array is empty!");
            }

            return data;
        } catch (Exception e) {
            Log.e("[PixelFree]", "Error in bitmapToRgbaByteArray: " + e.getMessage());
            throw e;
        }
    }


}

