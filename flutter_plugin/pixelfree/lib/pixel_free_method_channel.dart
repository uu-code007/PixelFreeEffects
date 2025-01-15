import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pixel_free_platform_interface.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

/// An implementation of [PixelFreePlatform] that uses method channels.
class MethodChannelPixelFree extends PixelFreePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pixel_free');

//   @override
//   Future<String?> getPlatformVersion() async {
//     final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
//     return version;
//   }

//  @override
//  Future<void> auth(String licPath) async {
//     await methodChannel.invokeMethod('auth', licPath);
//   }

@override
Future<void> create() async {
    await methodChannel.invokeMethod('create');
  }

// @override
// Future<void> createBeautyItemFormBundle(
//       ByteData data, PFSrcType type) async {
//     await methodChannel.invokeMethod('createBeautyItemFormBundle',
//         [data.buffer.asUint8List(), type.index]);
//   }

@override
Future<bool> isCreate() async {
    return await methodChannel.invokeMethod('isCreate');
  }


@override
Future<void> pixelFreeSetBeautyExtend(
      PFBeautyFiterType type, String value) async {
    await methodChannel.invokeMethod('pixelFreeSetBeautyExtend', {'type': type.index,'value': value,});
  }

@override
Future<void> pixelFreeSetBeautyFilterParam(
      PFBeautyFiterType type, double value) async {
    await methodChannel.invokeMethod('pixelFreeSetBeautyFilterParam',{'type': type.index,'value': value,});
  }


@override
Future<void> pixelFreeSetFilterParam(
      String filterName, double value) async {
    await methodChannel.invokeMethod(
        'pixelFreeSetFilterParam', {'filterName': filterName,'value': value,});
}

@override
Future<void> pixelFreeSetBeautyTypeParam(PFBeautyFiterType type, int value)  async {
      await methodChannel.invokeMethod(
        'pixelFreeSetBeautyTypeParam', {'type': type.index,'value': value,});
}

@override
Future<void> processWithBuffer(PFIamgeInput imageInput) async {
    await methodChannel.invokeMethod('processWithBuffer', imageInput.toMap());
}

@override
Future<int> processWithImage(Uint8List imageData,int w,int h) async {
    return await methodChannel.invokeMethod('processWithImage',{'imageData': imageData,'w': w,'h': h} );
}




// @override
//  Future<Uint8List> readBundleFile(String fileName) async {
//     final result = await methodChannel.invokeMethod('readBundleFile', fileName);
//     return Uint8List.fromList(result as List<int>);
//   }

@override
Future<void> release() async {
    await methodChannel.invokeMethod('release');
  }

@override
Map<String, dynamic> jsonStringToMap(String jsonString) {
    return json.decode(jsonString);
}

}

