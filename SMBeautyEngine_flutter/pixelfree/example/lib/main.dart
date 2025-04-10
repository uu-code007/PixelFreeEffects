import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:pixel_free/pixel_free.dart';

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pixel_free/pixel_free_platform_interface.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _currentValue = 0.0;
  final _pixelFreePlugin = PixelFree();
  int _currentTextureId = 0;
  late final _rgba ;
  int w = 720;
  int h = 1024;

  @override
  void initState() {
    super.initState();
    _pixelFreePlugin.create();

    initPlatformState();
  }



Future<void> readerImageAsyncTask(ByteData bytes, int width, int height) async {
    final texid = await _pixelFreePlugin.processWithImage(bytes.buffer.asUint8List(0),width,height);
      setState(()  {
        _currentTextureId = texid;
      });
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

    Timer.periodic(Duration(milliseconds: 200), (_) async {
      // _pixelFreePlugin.pixelFreeSetFilterParam("heibai1", 1.0);
        _pixelFreePlugin.pixelFreeSetBeautyTypeParam(PFBeautyFiterType.typeOneKey, 1);
       await readerImageAsyncTask(_rgba!,imageInfo.image.width, imageInfo.image.height);
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('pixfree Plugin example app'),
        ),
        body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

                            AspectRatio(
                            aspectRatio: w/ h,
                            child: Texture(
                                   textureId: _currentTextureId,
                                   ),
                             ),

            const Text(
              'v瘦脸参数设置',
            ),
            Slider(
              value: _currentValue,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                _pixelFreePlugin.pixelFreeSetBeautyFilterParam(PFBeautyFiterType.faceV, value);
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  


}
