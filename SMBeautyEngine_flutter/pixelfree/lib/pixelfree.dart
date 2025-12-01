import 'dart:convert';
import 'dart:typed_data';

import 'pixelfree_platform_interface.dart';

export 'pixelfree_platform_interface.dart' show PFFaceDetectMode, PFMakeupPart, PFBeautyTypeOneKey;

class Pixelfree {
  Future<String?> getPlatformVersion() {
    return PixelfreePlatform.instance.getPlatformVersion();
}

  Future<void> createWithLic(String licPath) {
    return PixelfreePlatform.instance.createWithLic(licPath);
  }

  Future<void> createBeautyItemFormBundle(ByteData data, PFSrcType type) {
    return PixelfreePlatform.instance.createBeautyItemFormBundle(data, type);
  }

  // 是否初始化了
  Future<bool> isCreate() {
    return PixelfreePlatform.instance.isCreate();
  }

  // 扩展字段设置一般不需
  Future<void> pixelFreeSetBeautyExtend(PFBeautyFiterType type, String value) {
    return PixelfreePlatform.instance.pixelFreeSetBeautyExtend(type, value);
  }

  // 设置美颜类型与程度
  Future<void> pixelFreeSetBeautyFilterParam(
    PFBeautyFiterType type,
    double value,
  ) {
    return PixelfreePlatform.instance.pixelFreeSetBeautyFilterParam(
      type,
      value,
    );
  }

  // 设置滤镜类型与程度
  Future<void> pixelFreeSetFilterParam(String filterName, double value) {
    return PixelfreePlatform.instance.pixelFreeSetFilterParam(
      filterName,
      value,
    );
  }

  // 设置2D贴纸
  Future<void> pixelFreeSetSticker2DFilter(String filterName) {
    return PixelfreePlatform.instance.pixelFreeSetBeautyExtend(
      PFBeautyFiterType.sticker2DFilter,
      filterName,
    );
  }

  Future<void> pixelFreeSetBeautyTypeParam(PFBeautyFiterType type, int value) {
    return PixelfreePlatform.instance.pixelFreeSetBeautyTypeParam(type, value);
  }

  Future<void> processWithBuffer(PFIamgeInput imageInput) {
    return PixelfreePlatform.instance.processWithBuffer(imageInput);
  }

  // 渲染返回buffer 接口
  Future<int> processWithImage(Uint8List imageData, int w, int h) async {
    return PixelfreePlatform.instance.processWithImage(imageData, w, h);
  }

    // 渲染纹理接口
  Future<int?> processWithTextrueID(int textrueID, int w, int h) async {
    return PixelfreePlatform.instance.processWithTextrueID(textrueID, w, h);
  }

  Future<ByteData?> processWithImageToByteData(
    Uint8List imageData,
    int width,
    int height,
  ) async {
    try {
        return await PixelfreePlatform.instance.processWithImageToByteData(
            imageData,
            width,
            height,
        );
    } catch (e) {
        print('Error in processWithImageToByteData: $e');
        return null;
    }
  }

  // Future<Uint8List> readBundleFile(String fileName) {
  //   return PixelfreePlatform.instance.readBundleFile(fileName);
  // }

  Future<void> release() {
    return PixelfreePlatform.instance.release();
  }

  Map<String, dynamic> jsonStringToMap(String jsonString) {
    return json.decode(jsonString);
  }

  // HLS filter operations
  Future<int> pixelFreeAddHLSFilter(PFHLSFilterParams params) {
    return PixelfreePlatform.instance.pixelFreeAddHLSFilter(params);
  }

  Future<void> pixelFreeDeleteHLSFilter(int handle) {
    return PixelfreePlatform.instance.pixelFreeDeleteHLSFilter(handle);
  }

  Future<int> pixelFreeChangeHLSFilter(int handle, PFHLSFilterParams params) {
    return PixelfreePlatform.instance.pixelFreeChangeHLSFilter(handle, params);
  }

  // Color grading operation
  Future<int> pixelFreeSetColorGrading(PFImageColorGrading params) {
    return PixelfreePlatform.instance.pixelFreeSetColorGrading(params);
  }

  // Get version
  Future<String?> getVersion() {
    return PixelfreePlatform.instance.getVersion();
  }

  // Set log level
  Future<void> setVLogLevel(int level, String? path) {
    return PixelfreePlatform.instance.setVLogLevel(level, path);
  }

  // Get face rectangle
  Future<List<double>> getFaceRect() {
    return PixelfreePlatform.instance.getFaceRect();
  }

  // Get face count
  Future<int> getFaceSize() {
    return PixelfreePlatform.instance.getFaceSize();
  }

  // Set detect mode
  Future<void> setDetectMode(PFFaceDetectMode mode) {
    return PixelfreePlatform.instance.setDetectMode(mode);
  }

  // Check if has face
  Future<bool> hasFace() {
    return PixelfreePlatform.instance.hasFace();
  }

  // Set makeup path
  Future<int> setMakeupPath(String makeupJsonPath) {
    return PixelfreePlatform.instance.setMakeupPath(makeupJsonPath);
  }

  // Clear makeup
  Future<int> clearMakeup() {
    return PixelfreePlatform.instance.clearMakeup();
  }

  // Set makeup part degree
  Future<int> setMakeupPartDegree(PFMakeupPart part, double degree) {
    return PixelfreePlatform.instance.setMakeupPartDegree(part, degree);
  }
}
