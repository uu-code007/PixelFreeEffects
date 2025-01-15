import 'dart:convert';
import 'dart:ffi';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pixel_free_method_channel.dart';
import 'dart:typed_data';

abstract class PixelFreePlatform extends PlatformInterface {
  /// Constructs a PixelFreePlatform.
  PixelFreePlatform() : super(token: _token);

  static final Object _token = Object();

  static PixelFreePlatform _instance = MethodChannelPixelFree();

  /// The default instance of [PixelFreePlatform] to use.
  ///
  /// Defaults to [MethodChannelPixelFree].
  static PixelFreePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PixelFreePlatform] when
  /// they register themselves.
  static set instance(PixelFreePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

//   Future<String?> getPlatformVersion() {
//     throw UnimplementedError('platformVersion() has not been implemented.');
//   }

//  Future<void> auth(String licPath) {
//     throw UnimplementedError('not been implemented');
//   }


Future<void> create() {
    throw UnimplementedError('not been implemented');;
}

// Future<void> createBeautyItemFormBundle(
//       ByteData data, PFSrcType type) {
//     throw UnimplementedError('not been implemented');
//   }

Future<bool> isCreate() {
    throw UnimplementedError('not been implemented');
  }

Future<void> pixelFreeSetBeautyExtend(
      PFBeautyFiterType type, String value) {
    throw UnimplementedError('not been implemented');
  }

Future<void> pixelFreeSetBeautyFilterParam(
      PFBeautyFiterType type, double value) {
    throw UnimplementedError('not been implemented');
  }

Future<void> pixelFreeSetFilterParam(
      String filterName, double value) {
    throw UnimplementedError('not been implemented');
}

  Future<void> pixelFreeSetBeautyTypeParam(PFBeautyFiterType type, int value) {
    throw UnimplementedError('not been implemented');
  }


Future<void> processWithBuffer(PFIamgeInput imageInput) {
    throw UnimplementedError('not been implemented');
}

Future<int> processWithImage(Uint8List imageData,int w,int h) async {
    throw UnimplementedError('not been implemented');
}


//  Future<Uint8List> readBundleFile(String fileName) {
//     throw UnimplementedError('not been implemented');
// }

Future<void> release() {
    throw UnimplementedError('not been implemented');
  }
}


Map<String, dynamic> jsonStringToMap(String jsonString) {
    throw UnimplementedError('not been implemented');
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
