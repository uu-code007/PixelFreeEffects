import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pixelfree_method_channel.dart';

abstract class PixelfreePlatform extends PlatformInterface {
  /// Constructs a PixelfreePlatform.
  PixelfreePlatform() : super(token: _token);

  static final Object _token = Object();

  static PixelfreePlatform _instance = MethodChannelPixelfree();

  /// The default instance of [PixelfreePlatform] to use.
  ///
  /// Defaults to [MethodChannelPixelfree].
  static PixelfreePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PixelfreePlatform] when
  /// they register themselves.
  static set instance(PixelfreePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> createWithLic(String licPath) {
    throw UnimplementedError('not been implemented');
  }

  Future<void> createBeautyItemFormBundle(ByteData data, PFSrcType type) {
    throw UnimplementedError('not been implemented');
  }

  Future<bool> isCreate() {
    throw UnimplementedError('not been implemented');
  }

  Future<void> pixelFreeSetBeautyExtend(PFBeautyFiterType type, String value) {
    throw UnimplementedError('not been implemented');
  }

  Future<void> pixelFreeSetBeautyFilterParam(PFBeautyFiterType type, double value) {
    throw UnimplementedError('not been implemented');
  }

  Future<void> pixelFreeSetFilterParam(String filterName, double value) {
    throw UnimplementedError('not been implemented');
  }

  Future<void> pixelFreeSetBeautyTypeParam(PFBeautyFiterType type, int value) {
    throw UnimplementedError('not been implemented');
  }

  Future<void> processWithBuffer(PFIamgeInput imageInput) {
    throw UnimplementedError('not been implemented');
  }

  Future<int> processWithImage(Uint8List imageData, int w, int h) async {
    throw UnimplementedError('not been implemented');
  }

  Future<ByteData?> processWithImageToByteData(Uint8List imageData, int width, int height) async {
    throw UnimplementedError('processWithImageToByteData() has not been implemented.');
  }

  Future<int?> processWithTextrueID(int textrueID, int w, int h) async {
    throw UnimplementedError('processWithTextrueID not been implemented');
  }

  Future<void> release() {
    throw UnimplementedError('not been implemented');
  }

  Future<int> pixelFreeAddHLSFilter(PFHLSFilterParams params) {
    throw UnimplementedError('pixelFreeAddHLSFilter() has not been implemented.');
  }

  Future<void> pixelFreeDeleteHLSFilter(int handle) {
    throw UnimplementedError('pixelFreeDeleteHLSFilter() has not been implemented.');
  }

  Future<void> pixelFreeChangeHLSFilter(int handle, PFHLSFilterParams params) {
    throw UnimplementedError('pixelFreeChangeHLSFilter() has not been implemented.');
  }

  Future<int> pixelFreeSetColorGrading(PFImageColorGrading params) {
    throw UnimplementedError('pixelFreeSetColorGrading() has not been implemented.');
  }

  Map<String, dynamic> jsonStringToMap(String jsonString) {
    throw UnimplementedError('not been implemented');
  }
}

enum PFSrcType { local, network, base64 }

enum PFBeautyFiterType {
  // 大眼
  eyeStrength,
  // 瘦脸
  faceThinning,
  // 窄脸
  faceNarrow,
  // 下巴
  faceChin,
  // V脸
  faceV,
  // 小脸
  faceSmall,
  // 鼻子
  faceNose,
  // 额头
  faceForehead,
  // 嘴巴
  faceMouth,
  // 人中
  facePhiltrum,
  // 长鼻
  faceLongNose,
  // 眼距
  faceEyeSpace,
  // 微笑嘴角
  faceSmile,
  // 旋转眼睛
  faceEyeRotate,
  // 开眼角
  faceCanthus,
  // 磨皮
  faceBlurStrength,
  // 美白
  faceWhitenStrength,
  // 红润
  faceRuddyStrength,
  // 锐化
  faceSharpenStrength,
  // 新美白算法
  faceNewWhitenStrength,
  // 画质增强
  faceQualityStrength,
  // 亮眼
  faceEyeBrighten,
  // 滤镜类型
  filterName,
  // 滤镜强度
  filterStrength,
  // 绿幕
  lvmu,
  // 2D贴纸
  sticker2DFilter,
  // 一键美颜
  typeOneKey,
  // 水印
  watermark,
  // 扩展字段
  extend,
}

class PFIamgeInput {
  final int textureID;
  final int width;
  final int height;
  final Uint8List? data0;
  final Uint8List? data1;
  final Uint8List? data2;
  final int stride0;
  final int stride1;
  final int stride2;
  final int format;
  final int rotationMode;

  PFIamgeInput({
    required this.textureID,
    required this.width,
    required this.height,
    this.data0,
    this.data1,
    this.data2,
    required this.stride0,
    required this.stride1,
    required this.stride2,
    required this.format,
    required this.rotationMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'textureID': textureID,
      'width': width,
      'height': height,
      'data0': data0?.buffer.asUint8List(),
      'data1': data1?.buffer.asUint8List(),
      'data2': data2?.buffer.asUint8List(),
      'stride0': stride0,
      'stride1': stride1,
      'stride2': stride2,
      'format': format,
      'rotationMode': rotationMode,
    };
  }
}

// HLS filter parameters class
class PFHLSFilterParams {
  final List<double> keyColor; // [0-1] RGB values
  final double hue;
  final double saturation; // 0-1.0
  final double brightness; // 0-1.0
  final double similarity; // 相似度

  PFHLSFilterParams({
    required this.keyColor,
    required this.hue,
    required this.saturation,
    required this.brightness,
    required this.similarity,
  });

  Map<String, dynamic> toMap() {
    return {
      'keyColor': keyColor,
      'hue': hue,
      'saturation': saturation,
      'brightness': brightness,
      'similarity': similarity,
    };
  }
}

// Color grading parameters class
class PFImageColorGrading {
  final bool isUse; // false
  final double brightness; // -1.0 to 1.0
  final double
      contrast; // 0.0 to 4.0 (max contrast), with 1.0 as the normal level
  final double exposure; // -10.0 to 10.0, with 0.0 as the normal level
  final double highlights; // 0-1, increase to lighten shadows
  final double shadows; // 0-1, decrease to darken highlights
  final double saturation; // 0.0 to 2.0, with 1.0 as the normal level
  final double
      temperature; // color temperature in degrees Kelvin, default 5000.0
  final double tint; // adjust tint to compensate
  final double hue; // 0-360

  PFImageColorGrading({
    this.isUse = false,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.exposure = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.saturation = 1.0,
    this.temperature = 5000.0,
    this.tint = 0.0,
    this.hue = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'isUse': isUse,
      'brightness': brightness,
      'contrast': contrast,
      'exposure': exposure,
      'highlights': highlights,
      'shadows': shadows,
      'saturation': saturation,
      'temperature': temperature,
      'tint': tint,
      'hue': hue,
    };
  }
}
