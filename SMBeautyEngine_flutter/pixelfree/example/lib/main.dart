import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pixelfree/pixelfree.dart';
import 'package:pixelfree/PixeBeautyDialog.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  double _currentValue = 0.0;
  final _pixelFreePlugin = Pixelfree();
  int _currentTextureId = 0;
  ByteData? _rgba;
  int w = 720;
  int h = 1024;
  ui.Image? _processedImage;
  bool _useTexture = false;
  bool _isInitializing = false;
  String? _initializationError;
  Timer? _timer;
  bool _isProcessing = false;
  bool _isTimerActive = false;

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
      
      // 设置成图片处理模式
      await _pixelFreePlugin.setDetectMode(PFFaceDetectMode.image);
      
      await initPlatformState();


// 创建HLS滤镜参数
// final params2 = PFHLSFilterParams(
//   keyColor: [0.5, 0.5, 0.5], // RGB值范围0-1
//   hue: 0.0, // 色相 0.45-0.45     0 默认值
//   saturation: 1.0, // 饱和度 0.3 -1.8       1 默认值
//   brightness: 1.0, // 亮度 0-1         1 默认值
//   similarity: 0.8, // 相似度 0-1       0.8 默认值
// );
// // 添加HLS滤镜
// final handle = await _pixelFreePlugin.pixelFreeAddHLSFilter(params2);

// // 删除HLS滤镜
// await _pixelFreePlugin.pixelFreeDeleteHLSFilter(handle);

// final params = PFImageColorGrading(
//   isUse: true, // 启用颜色分级 默认false
//   brightness: 0.1, // 增加亮度 (-1.0 到 1.0) 默认0
//   contrast: 1.2, // 增加对比度 (0.0 到 4.0)
//   exposure: 0.5, // 增加曝光 (-10.0 到 10.0)
//   highlights: 0.3, // 调整高光 (-1-1) 默认0
//   shadows: 0.2, // 调整阴影 (-1-1) 默认0
//   saturation: 1.1, // 增加饱和度 (0.0 到 2.0) 默认1
//   temperature: 5500.0, // 调整色温 (开尔文温度 0-10000) 默认5500
//   tint: 0.1, // 调整色调补偿 默认0 
//   hue: 180.0, // 调整色相 (0-360) 默认0
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
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      if (_useTexture) {
        final texid = await _pixelFreePlugin.processWithImage(
            bytes.buffer.asUint8List(0), width, height);
        if (mounted) {
          setState(() => _currentTextureId = texid);
        }
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
      if (mounted) {
        setState(() {
          _processedImage?.dispose(); // Dispose old image
          _processedImage = image;
        });
      }
    } catch (e, stackTrace) {
      print('Error in readerImageAsyncTask: $e\n$stackTrace');
    } finally {
      _isProcessing = false;
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

  void _startImageProcessing() {
    if (_isTimerActive) return;
    _isTimerActive = true;
    
    // 使用更长的间隔时间，比如500ms
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_rgba != null && !_isProcessing) {
        await readerImageAsyncTask(_rgba!, w, h);
      }
    });
  }

  void _stopImageProcessing() {
    _timer?.cancel();
    _timer = null;
    _isTimerActive = false;
  }

  Future<void> initPlatformState() async {
    const imageProvider = AssetImage('assets/images/image_render.png');
    var stream = imageProvider.resolve(ImageConfiguration.empty);

    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    var listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    });

    stream.addListener(listener);
    final imageInfo = await completer.future;
    stream.removeListener(listener);

    _rgba = await imageInfo.image.toByteData(format: ImageByteFormat.rawRgba);
    
    // 启动定时处理
    _startImageProcessing();
  }

  Future<void> _pickImage() async {
    try {
      // 暂停定时处理
      _stopImageProcessing();
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final pickedImage = frame.image;
        
        if (mounted) {
          setState(() {
            w = pickedImage.width;
            h = pickedImage.height;
          });
        }

        _rgba = await pickedImage.toByteData(format: ImageByteFormat.rawRgba);
        
        // 处理新图片
        await readerImageAsyncTask(_rgba!, pickedImage.width, pickedImage.height);
        
        // 重新启动定时处理
        _startImageProcessing();
        
        pickedImage.dispose();
      } else {
        // 如果用户取消选择，重新启动定时处理
        _startImageProcessing();
      }
    } catch (e) {
      print('Error picking image: $e');
      // 发生错误时也要重新启动定时处理
      _startImageProcessing();
    }
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
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _pickImage,
            ),
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
    _stopImageProcessing();
    _processedImage?.dispose();
    _rgba = null;
    super.dispose();
  }
}
