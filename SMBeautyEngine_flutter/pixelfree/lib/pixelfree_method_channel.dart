import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pixelfree_platform_interface.dart';

/// An implementation of [PixelfreePlatform] that uses method channels.
class MethodChannelPixelfree extends PixelfreePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pixelfree');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
@override
Future<void> createWithLic(String licPath) async {
    await methodChannel.invokeMethod('createWithLic',{'licPath': licPath});
  }

@override
Future<void> createBeautyItemFormBundle(
      ByteData data, PFSrcType type) async {
    await methodChannel.invokeMethod('createBeautyItemFormBundle',
        [data.buffer.asUint8List(), type.index]);
  }

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

// @override
// Future<int> processWithImage(Uint8List imageData,int w,int h) async {
//     return await methodChannel.invokeMethod('processWithImage',{'imageData': imageData,'w': w,'h': h} );
// }

@override
Future<ByteData?> processWithImageToByteData(Uint8List imageData, int width, int height) async {
    try {
        final result = await methodChannel.invokeMethod('processWithImageToByteData', {
            'imageData': imageData,
            'width': width,
            'height': height,
        });
        
        if (result == null) {
            return null;
        }

        final List<int> resultList = result as List<int>;
        
        if (resultList.isEmpty) {
            return null;
        }

        final expectedSize = width * height * 4; // RGBA format
        if (resultList.length != expectedSize) {
            return null;
        }

        // 直接使用 resultList 创建 ByteData，避免创建额外的 Uint8List
        return ByteData.view(Uint8List.fromList(resultList).buffer);
    } catch (e) {
        print('Error in processWithImageToByteData: $e');
        return null;
    }
}


Future<int?> processWithTextrueID(int textrueID, int w, int h) async {
      final textureid = await methodChannel.invokeMethod<int>('processWithTextrueID', {
            'textrueID': textrueID,
            'width': w,
            'height': h,
        });
     return textureid;
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

@override
Future<int> pixelFreeAddHLSFilter(PFHLSFilterParams params) async {
  final result = await methodChannel.invokeMethod('pixelFreeAddHLSFilter', params.toMap());
  return result as int;
}

@override
Future<void> pixelFreeDeleteHLSFilter(int handle) async {
  await methodChannel.invokeMethod('pixelFreeDeleteHLSFilter', {'handle': handle});
}

@override
Future<int> pixelFreeChangeHLSFilter(int handle, PFHLSFilterParams params) async {
  final result = await methodChannel.invokeMethod('pixelFreeChangeHLSFilter', {
    'handle': handle,
    ...params.toMap(),
  });
  if (result == null) {
    throw Exception('Failed to change HLS filter: null result received');
  }
  return result as int;
}

@override
Future<int> pixelFreeSetColorGrading(PFImageColorGrading params) async {
  final result = await methodChannel.invokeMethod('pixelFreeSetColorGrading', params.toMap());
  return result as int;
}

}
