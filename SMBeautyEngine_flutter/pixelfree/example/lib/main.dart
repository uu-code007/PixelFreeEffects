import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pixelfree/pixelfree.dart';
import 'package:pixelfree/PixeBeautyDialog.dart';

import 'dart:ui';
import 'package:pixelfree/pixelfree_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _licenseAssetPath = 'assets/pixelfreeAuth.lic';
  static const _modelAssetPath = 'assets/filter_model.bundle';

  double _currentValue = 0.0;
  final _pixelFreePlugin = Pixelfree();
  int _currentTextureId = 0;
  late final _rgba;
  int w = 720;
  int h = 1024;
  ui.Image? _processedImage;
  bool _useTexture = false;
  bool _isInitializing = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    if (_isInitializing) return;

    setState(() => _isInitializing = true);

    try {
      final licPath = await _extractAssetToTemp(_licenseAssetPath);
      await _pixelFreePlugin.createWithLic(licPath);
      await initPlatformState();


// 创建HLS滤镜参数
// final params2 = PFHLSFilterParams(
//   keyColor: [0.5, 0.5, 0.5], // RGB值范围0-1
//   hue: 180.0, // 色相
//   saturation: 0.5, // 饱和度 0-1
//   brightness: 0.5, // 亮度 0-1
//   similarity: 0.8, // 相似度 0-1
// );
// // 添加HLS滤镜
// final handle = await _pixelFreePlugin.pixelFreeAddHLSFilter(params2);


// // 删除HLS滤镜
// await _pixelFreePlugin.pixelFreeDeleteHLSFilter(handle);

// final params = PFImageColorGrading(
//   isUse: true, // 启用颜色分级
//   brightness: 0.1, // 增加亮度 (-1.0 到 1.0)
//   contrast: 1.2, // 增加对比度 (0.0 到 4.0)
//   exposure: 0.5, // 增加曝光 (-10.0 到 10.0)
//   highlights: 0.3, // 调整高光 (0-1)
//   shadows: 0.2, // 调整阴影 (0-1)
//   saturation: 1.1, // 增加饱和度 (0.0 到 2.0)
//   temperature: 5500.0, // 调整色温 (开尔文温度)
//   tint: 0.1, // 调整色调补偿
//   hue: 180.0, // 调整色相 (0-360)
// );

// final result = await _pixelFreePlugin.pixelFreeSetColorGrading(params);

    } catch (e, stack) {
      debugPrint('Initialization failed: $e\n$stack');
      setState(() =>
          _initializationError = 'Initialization failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<String> _extractAssetToTemp(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${assetPath.split('/').last}');

      if (!await file.exists() ||
          (await file.length()) != byteData.lengthInBytes) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      return file.path;
    } catch (e) {
      throw Exception('Failed to extract asset $assetPath: $e');
    }
  }

  Future<void> readerImageAsyncTask(
      ByteData bytes, int width, int height) async {
    try {
      if (_useTexture) {
        final texid = await _pixelFreePlugin.processWithImage(
            bytes.buffer.asUint8List(0), width, height);
        setState(() => _currentTextureId = texid);
        return;
      }

      final processedBytes = await processImageToByteData(bytes, width, height);
      if (processedBytes == null) {
        print('Failed to process image: received null bytes');
        return;
      }

      final uint8List = processedBytes.buffer.asUint8List();

      // Validate data size
      final expectedSize = width * height * 4; // RGBA format
      if (uint8List.length != expectedSize) {
        print(
            'Warning: Data size mismatch. Expected: $expectedSize, Got: ${uint8List.length}');
        return;
      }

      // Properly await the image creation
      final image = await createImage(uint8List, width, height);

      if (_useTexture) return;
      setState(() {
        _processedImage = image; // No casting needed now
      });
    } catch (e, stackTrace) {
      print('Error in readerImageAsyncTask: $e\n$stackTrace');
    }
  }

  Future<ui.Image> createImage(Uint8List bytes, int width, int height) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        completer.complete(
            image); // Make sure to call complete() inside the callback
        return; // Explicit return for void callback
      },
    );

    return completer.future;
  }

  Future<ByteData?> processImageToByteData(
      ByteData inputBytes, int width, int height) async {
    ByteData? processedBytes;
    try {
        processedBytes = await _pixelFreePlugin.processWithImageToByteData(
            inputBytes.buffer.asUint8List(0),
            width,
            height,
        );
        return processedBytes;
    } catch (e) {
        print('Error processing image: $e');
        return null;
    } finally {
        // 确保在使用完后释放资源
        if (processedBytes != null) {
            // 如果 processedBytes 有 dispose 方法，调用它
            // processedBytes.dispose();
        }
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    const imageProvider = AssetImage('assets/images/image_render.png');
    var stream = imageProvider.resolve(ImageConfiguration.empty);

    // create a promise that will be resolved once the image is loaded
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    var listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    });

    // listen to the image loaded event
    stream.addListener(listener);

    // wait for the image to be loaded
    final imageInfo = await completer.future;

    _rgba = await imageInfo.image.toByteData(format: ImageByteFormat.rawRgba);

    Timer.periodic(const Duration(milliseconds: 200), (_) async {
      await readerImageAsyncTask(
          _rgba!, imageInfo.image.width, imageInfo.image.height);
    });
  }

  void _showBeautyDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: PixeBeautyDialog(
            pixelFree: _pixelFreePlugin,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('pixfree Plugin example app'),
          actions: [
            Switch(
              value: _useTexture,
              onChanged: (value) {
                setState(() {
                  _useTexture = value;
                });
              },
            ),
            Text(_useTexture ? 'Texture' : 'Image'),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: w / h,
                    child: _useTexture
                        ? Texture(
                            textureId: _currentTextureId,
                          )
                        : _processedImage != null
                            ? RawImage(
                                image: _processedImage,
                                fit: BoxFit.contain,
                              )
                            : const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
            if (!_isInitializing)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PixeBeautyDialog(
                  pixelFree: _pixelFreePlugin,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 清理资源
    _processedImage?.dispose();
    _rgba = null;
    super.dispose();
  }
}
