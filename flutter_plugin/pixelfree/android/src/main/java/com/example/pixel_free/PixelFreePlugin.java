package com.example.pixel_free;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.SurfaceTexture;
import android.opengl.EGLContext;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
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

/** PixelFreePlugin */
public class PixelFreePlugin implements FlutterPlugin, MethodCallHandler {
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

  private int width = 720;
  private int height = 1024;

  private byte[] pixels;

  private int openGLTextureId; // 您的 OpenGL 纹理 ID

  CustomRenderVideoFrame customRender;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding;
    mContext = flutterPluginBinding.getApplicationContext();

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pixel_free");
    channel.setMethodCallHandler(this);

  }

  public int onPreProcessFrame(byte[] image,int w, int h) {
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


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String method = call.method;
    switch (method) {
      case "create":{
        if (mPixelFree.isCreate()) return;
        textureRegistry = flutterPluginBinding.getTextureRegistry();
        textureEntry = flutterPluginBinding.getTextureRegistry().createSurfaceTexture();
        surfaceTexture = textureEntry.surfaceTexture();
        mPixelFree.create();
        Log.d("[PixelFree]", "eglGetError 1 " + EGL14.eglGetError());
        byte[] bytes = mPixelFree.readBundleFile(mContext, "pixelfreeAuth.lic");
        mPixelFree.auth(mContext, bytes, bytes.length);

        byte[] bytes2 = mPixelFree.readBundleFile(mContext, "filter_model.bundle");
        mPixelFree.createBeautyItemFormBundle(
                bytes2,
                bytes2.length,
                PFSrcType.PFSrcTypeFilter
        );

        // 默认设置一个瘦脸
        mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.PFBeautyFiterTypeFace_narrow,1);

        result.success(textureEntry.id());
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
        mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.PFBeautyFiterTypeOneKey, (int)value);
        result.success(null);
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
     case "processWithImage":{
       byte[] imageData = (byte[]) call.argument("imageData");
       int w =  (int) call.argument("w");
       int h =  (int) call.argument("h");

       if (customRender == null){
         EGLContext eglContext = mPixelFree.getCurrentGlContext();
         customRender =  new CustomRenderVideoFrame(eglContext);
         surfaceTexture.setDefaultBufferSize(width, height);
         customRender.start(surfaceTexture, width, height);
       }
       int textureID = onPreProcessFrame(imageData, w, h);
       customRender.onRenderVideoFrame(textureID);
       result.success(textureEntry.id());
     }
       break;
      case "release":{
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



}
