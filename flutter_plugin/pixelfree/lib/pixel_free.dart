
import 'dart:ui';

import 'pixel_free_platform_interface.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

class PixelFree {

  // Future<void> auth(String licPath) {
  // return PixelFreePlatform.instance.auth(licPath);
  // }


  Future<void> create() {
    return PixelFreePlatform.instance.create();
  }


  // Future<void> createBeautyItemFormBundle(
  //     ByteData data, PFSrcType type) {
  //   return PixelFreePlatform.instance.createBeautyItemFormBundle(data, type);
  // }

 // 是否初始化了
  Future<bool> isCreate() {
    return PixelFreePlatform.instance.isCreate();
  }

 // 扩展字段设置一般不需
  Future<void> pixelFreeSetBeautyExtend(
      PFBeautyFiterType type, String value) {
    return PixelFreePlatform.instance.pixelFreeSetBeautyExtend(type, value);
  }

// 设置美颜类型与程度
  Future<void> pixelFreeSetBeautyFilterParam(
      PFBeautyFiterType type, double value) {
    return PixelFreePlatform.instance.pixelFreeSetBeautyFilterParam(type, value);
  }


 // 设置滤镜类型与程度
  Future<void> pixelFreeSetFilterParam(
      String filterName, double value) {
    return PixelFreePlatform.instance.pixelFreeSetFilterParam(filterName, value);
  }

  Future<void> pixelFreeSetBeautyTypeParam(
      PFBeautyFiterType type, int value) {
    return PixelFreePlatform.instance.pixelFreeSetBeautyTypeParam(type, value);
  }


  Future<void> processWithBuffer(PFIamgeInput imageInput) {
    return PixelFreePlatform.instance.processWithBuffer(imageInput);
  }

// 图片渲染
  Future<int> processWithImage(Uint8List imageData,int w,int h) async {
    return PixelFreePlatform.instance.processWithImage(imageData,w,h);
}


  // Future<Uint8List> readBundleFile(String fileName) {
  //   return PixelFreePlatform.instance.readBundleFile(fileName);
  // }

  Future<void> release() {
    return PixelFreePlatform.instance.release();
  }

  Map<String, dynamic> jsonStringToMap(String jsonString) {
    return json.decode(jsonString);
  }

}

