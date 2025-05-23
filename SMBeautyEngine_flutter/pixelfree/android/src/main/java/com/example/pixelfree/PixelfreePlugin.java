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

import com.hapi.pixelfree.PFBeautyFiterType;
import com.hapi.pixelfree.PFSrcType;
import com.hapi.pixelfree.PixelFree;
import com.hapi.pixelfree.PFIamgeInput;
import com.hapi.pixelfree.PFRotationMode;
import com.hapi.pixelfree.PFDetectFormat;

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

    private final PixelFree mPixelFree = new PixelFree();

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
        PFIamgeInput pxInput = new PFIamgeInput();
        if (mPixelFree.isCreate()) {
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
        PFIamgeInput pxInput = new PFIamgeInput();
        if (mPixelFree.isCreate()) {
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
                if (mPixelFree.isCreate()) return;
                textureRegistry = flutterPluginBinding.getTextureRegistry();
                textureEntry = flutterPluginBinding.getTextureRegistry().createSurfaceTexture();
                surfaceTexture = textureEntry.surfaceTexture();
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
                boolean isCreate = mPixelFree.isCreate();
                result.success(isCreate);
            }
            break;
            case "pixelFreeSetBeautyExtend": {
                int type = (int) call.argument("type");
                mPixelFree.pixelFreeSetBeautyExtend(PFBeautyFiterType.values()[type], (String) call.argument("value"));
                result.success(null);
            }
            break;
            case "pixelFreeSetBeautyFilterParam": {
                int type = (int) call.argument("type");
                double value = (double) call.argument("value");
                mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.values()[type], (float) value);
                result.success(null);
            }
            break;
            case "pixelFreeSetFilterParam": {
                double value = (double) call.argument("value");
                mPixelFree.pixelFreeSetFiterParam((String) call.argument("filterName"), (float) value);
                result.success(null);
            }
            break;

            case "pixelFreeSetBeautyTypeParam": {
                int type = (int) call.argument("type");
                int value = (int) call.argument("value");
                mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.PFBeautyFiterTypeOneKey, (int) value);
                result.success(null);
            }
            break;

            case "pixelFreeAddHLSFilter": {
                List<Double> keyColor = (List<Double>) call.argument("keyColor");
                float[] keyColorArr = new float[] {
                    keyColor.get(0).floatValue(),
                    keyColor.get(1).floatValue(),
                    keyColor.get(2).floatValue()
                };
                float hue = ((Double) call.argument("hue")).floatValue();
                float saturation = ((Double) call.argument("saturation")).floatValue();
                float brightness = ((Double) call.argument("brightness")).floatValue();
                float similarity = ((Double) call.argument("similarity")).floatValue();

                int handle = mPixelFree.addHLSFilter(keyColorArr, hue, saturation, brightness, similarity);
                result.success(handle);
            }
            break;

            case "pixelFreeDeleteHLSFilter": {
                int handle = (int) call.argument("handle");
                mPixelFree.deleteHLSFilter(handle);
                result.success(null);
            }
            break;

            case "pixelFreeChangeHLSFilter": {
                List<Double> keyColor = (List<Double>) call.argument("keyColor");
                float[] keyColorArr = new float[] {
                    keyColor.get(0).floatValue(),
                    keyColor.get(1).floatValue(),
                    keyColor.get(2).floatValue()
                };
                float hue = ((Double) call.argument("hue")).floatValue();
                float saturation = ((Double) call.argument("saturation")).floatValue();
                float brightness = ((Double) call.argument("brightness")).floatValue();
                float similarity = ((Double) call.argument("similarity")).floatValue();

                int handle = (int) call.argument("handle");
                mPixelFree.changeHLSFilter(handle, keyColorArr, hue, saturation, brightness, similarity);
                result.success(null);
            }
            break;

            case "pixelFreeSetColorGrading": {
                Map<String, Object> params = (Map<String, Object>) call.arguments;
                
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
                int inputTextureid = (int) call.argument("textrueID");
                int w = (int) call.argument("width");
                int h = (int) call.argument("height");

                int textureID = onPreProcessTexture(inputTextureid, w, h);
                result.success(textureID);
            }
            break;

            

            case "release": {
                mPixelFree.release();
                result.success(null);
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

