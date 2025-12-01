import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixelfree/pixelfree.dart';
import 'package:pixelfree/pixelfree_platform_interface.dart';
import 'package:pixelfree/pixelfree_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPixelfreePlatform
    with MockPlatformInterfaceMixin
    implements PixelfreePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> createWithLic(String licPath) => Future.value();

  @override
  Future<void> createBeautyItemFormBundle(ByteData data, PFSrcType type) => Future.value();

  @override
  Future<bool> isCreate() => Future.value(false);

  @override
  Future<void> pixelFreeSetBeautyExtend(PFBeautyFiterType type, String value) => Future.value();

  @override
  Future<void> pixelFreeSetBeautyFilterParam(PFBeautyFiterType type, double value) => Future.value();

  @override
  Future<void> pixelFreeSetFilterParam(String filterName, double value) => Future.value();

  @override
  Future<void> pixelFreeSetBeautyTypeParam(PFBeautyFiterType type, int value) => Future.value();

  @override
  Future<void> processWithBuffer(PFIamgeInput imageInput) => Future.value();

  @override
  Future<int> processWithImage(Uint8List imageData, int w, int h) => Future.value(0);

  @override
  Future<ByteData?> processWithImageToByteData(Uint8List imageData, int width, int height) => Future.value(null);

  @override
  Future<int?> processWithTextrueID(int textrueID, int w, int h) => Future.value(null);

  @override
  Future<void> release() => Future.value();

  @override
  Future<int> pixelFreeAddHLSFilter(PFHLSFilterParams params) => Future.value(0);

  @override
  Future<void> pixelFreeDeleteHLSFilter(int handle) => Future.value();

  @override
  Future<int> pixelFreeChangeHLSFilter(int handle, PFHLSFilterParams params) => Future.value(0);

  @override
  Future<int> pixelFreeSetColorGrading(PFImageColorGrading params) => Future.value(0);

  @override
  Future<String?> getVersion() => Future.value('1.0.0');

  @override
  Future<void> setVLogLevel(int level, String? path) => Future.value();

  @override
  Future<List<double>> getFaceRect() => Future.value([]);

  @override
  Future<int> getFaceSize() => Future.value(0);

  @override
  Future<void> setDetectMode(PFFaceDetectMode mode) => Future.value();

  @override
  Future<bool> hasFace() => Future.value(false);

  @override
  Future<int> setMakeupPath(String makeupJsonPath) => Future.value(0);

  @override
  Future<int> clearMakeup() => Future.value(0);

  @override
  Future<int> setMakeupPartDegree(PFMakeupPart part, double degree) => Future.value(0);

  @override
  Map<String, dynamic> jsonStringToMap(String jsonString) => {};
}

void main() {
  final PixelfreePlatform initialPlatform = PixelfreePlatform.instance;

  test('$MethodChannelPixelfree is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPixelfree>());
  });

  test('getPlatformVersion', () async {
    Pixelfree pixelfreePlugin = Pixelfree();
    MockPixelfreePlatform fakePlatform = MockPixelfreePlatform();
    PixelfreePlatform.instance = fakePlatform;

    expect(await pixelfreePlugin.getPlatformVersion(), '42');
  });
}
