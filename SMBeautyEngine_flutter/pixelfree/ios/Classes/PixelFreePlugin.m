#import "PixelFreePlugin.h"
#import <PixelFree/SMPixelFree.h>

/*
 插件主要图处理场景，RTC,推流，需要结合产商插件开发，优化性能
 */

@interface GLTexture : NSObject <FlutterTexture>
@property(nonatomic) CVPixelBufferRef target;
@end

@implementation GLTexture

- (CVPixelBufferRef)copyPixelBuffer {
  // 实现FlutterTexture协议的接口，每次flutter是直接读取我们映射了纹理的pixelBuffer对象
  // TODO: [self.textures textureFrameAvailable:_textureId]; 更新 CVPixelBufferRef 快会导致未知问题
  return _target;
}

@end

@interface PixelfreePlugin () <FlutterPlugin> {
  int64_t _textureId;
  GLTexture *_glTexture;

  int frameWidth;
  int frameHeight;
}
@property(nonatomic, strong) NSObject<FlutterTextureRegistry> *textures;  // 其实是FlutterEngine

@property(nonatomic, strong) SMPixelFree *mPixelFree;

@property(nonatomic, assign) CVPixelBufferRef renderTarget;

@end

@implementation PixelfreePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"pixelfree"
                                  binaryMessenger:[registrar messenger]];
  PixelfreePlugin *instance = [[PixelfreePlugin alloc] initWithTextures:registrar.textures];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithTextures:(NSObject<FlutterTextureRegistry> *)textures {
  if (self = [super init]) {
    _textures = textures;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  //    NSLog(@"flutter call.method = %@",call.method);
  NSDictionary *dicArguments = (NSDictionary *)call.arguments;
  if ([@"createWithLic" isEqualToString:call.method]) {
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"filter_model.bundle"
                                                               ofType:nil];
    //         NSString *authFile = [[NSBundle mainBundle] pathForResource:@"pixelfreeAuth.lic"
    //         ofType:nil];
    NSString *authFile = dicArguments[@"licPath"];
    // NSString *face_FiltePath = dicArguments[@"modlePath"];

    self.mPixelFree = [[SMPixelFree alloc] initWithProcessContext:nil
                                                    srcFilterPath:face_FiltePath
                                                         authFile:authFile];
    _glTexture = [[GLTexture alloc] init];
    _textureId = [_textures registerTexture:_glTexture];
    result(@(_textureId));
  } else if ([@"isCreate" isEqualToString:call.method]) {
    bool isCreate = _mPixelFree ? true : false;
    result(@(isCreate));
  } else if ([@"processWithImage" isEqualToString:call.method]) {
    FlutterStandardTypedData *imageData = (FlutterStandardTypedData *)dicArguments[@"imageData"];
    int w = [dicArguments[@"w"] intValue];
    int h = [dicArguments[@"h"] intValue];
    [self getRenderTargetWithWidth:w height:h rgbaBuffer:(char *)imageData.data.bytes];
    _glTexture.target = _renderTarget;
    if (_renderTarget) {  // 如果是视频帧，自行替换，
      [_mPixelFree processWithBuffer:_renderTarget rotationMode:PFRotationMode0];
      [self.textures textureFrameAvailable:_textureId];
    }
    result(@(_textureId));
  } else if ([@"processWithImageToByteData" isEqualToString:call.method]) {
    FlutterStandardTypedData *imageData = (FlutterStandardTypedData *)dicArguments[@"imageData"];
    int w = [dicArguments[@"width"] intValue];
    int h = [dicArguments[@"height"] intValue];

    [self getRenderTargetWithWidth:w height:h rgbaBuffer:(char *)imageData.data.bytes];

    if (_renderTarget) {
      [_mPixelFree processWithBuffer:_renderTarget rotationMode:PFRotationMode0];
      [self.textures textureFrameAvailable:_textureId];
    }

    CVPixelBufferLockBaseAddress(_renderTarget, kCVPixelBufferLock_ReadOnly);

    // 1. 获取 BGRA 数据的指针和大小
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(_renderTarget);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(_renderTarget);
    size_t height = CVPixelBufferGetHeight(_renderTarget);
    size_t width = CVPixelBufferGetWidth(_renderTarget);

    // 2. 分配新的缓冲区用于 RGBA 数据
    size_t rgbaBufferSize = width * height * 4;  // RGBA 占 4 字节
    uint8_t *rgbaBuffer = malloc(rgbaBufferSize);

    // 3. 遍历像素，将 BGRA 转换为 RGBA
    for (size_t y = 0; y < height; y++) {
      uint8_t *srcRow = baseAddress + y * bytesPerRow;
      uint8_t *dstRow = rgbaBuffer + y * width * 4;

      for (size_t x = 0; x < width; x++) {
        // BGRA -> RGBA
        dstRow[x * 4 + 0] = srcRow[x * 4 + 2];  // R
        dstRow[x * 4 + 1] = srcRow[x * 4 + 1];  // G
        dstRow[x * 4 + 2] = srcRow[x * 4 + 0];  // B
        dstRow[x * 4 + 3] = srcRow[x * 4 + 3];  // A
      }
    }

    // 4. 封装成 FlutterStandardTypedData
    NSData *rgbaData = [NSData dataWithBytesNoCopy:rgbaBuffer
                                            length:rgbaBufferSize
                                      freeWhenDone:YES];
    FlutterStandardTypedData *flutterData = [FlutterStandardTypedData typedDataWithBytes:rgbaData];

    CVPixelBufferUnlockBaseAddress(_renderTarget, kCVPixelBufferLock_ReadOnly);

    CVPixelBufferRelease(_renderTarget);
    result(flutterData);
      
  } else if ([@"processWithTextrueID" isEqualToString:call.method]) {
      int textrueID = (int)dicArguments[@"textrueID"];
      int w = [dicArguments[@"width"] intValue];
      int h = [dicArguments[@"height"] intValue];
      [_mPixelFree processWithTexture:textrueID width:w height:h];
      result(@(textrueID));
  } else if ([@"pixelFreeSetBeautyExtend" isEqualToString:call.method]) {  // 更新 2.4.5 后
    //        [_mPixelFree pixelFreeSetBeautyFiterParam:<#(int)#> value:<#(nonnull void *)#>]
    //        _textureId = [_textures unregisterTexture:_glTexture];
    result(NULL);
  } else if ([@"pixelFreeSetBeautyFilterParam" isEqualToString:call.method]) {
    int type = [dicArguments[@"type"] intValue];  //
    float value = [dicArguments[@"value"] floatValue];

    [_mPixelFree pixelFreeSetBeautyFiterParam:type value:&value];
    result(NULL);
  } else if ([@"pixelFreeSetFilterParam" isEqualToString:call.method]) {
    float value = [dicArguments[@"value"] floatValue];
    const char *filterName = [dicArguments[@"filterName"] UTF8String];
    [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterName value:(void *)filterName];
    [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterStrength value:&value];
    result(NULL);
  } else if ([@"pixelFreeSetBeautyTypeParam" isEqualToString:call.method]) {
      int value = [dicArguments[@"value"] intValue];
      [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
      result(NULL);
    } else if ([@"release" isEqualToString:call.method]) {
    [_textures unregisterTexture:_glTexture];
    result(NULL);
  } else if ([@"pixelFreeAddHLSFilter" isEqualToString:call.method]) {
    NSDictionary *params = dicArguments;
    PFHLSFilterParams hlsParams = {
        .brightness = 0.0f,
        .saturation = 1.0f,
        .hue = 0.0f,
        .similarity = 0.0f,
    };
    
    NSArray *keyColor = params[@"keyColor"];
    hlsParams.key_color[0] = [keyColor[0] floatValue];
    hlsParams.key_color[1] = [keyColor[1] floatValue];
    hlsParams.key_color[2] = [keyColor[2] floatValue];
    
    hlsParams.hue = [params[@"hue"] floatValue];
    hlsParams.saturation = [params[@"saturation"] floatValue];
    hlsParams.brightness = [params[@"brightness"] floatValue];
    hlsParams.similarity = [params[@"similarity"] floatValue];
    
    int handle = [_mPixelFree pixelFreeAddHLSFilter:&hlsParams];
    result(@(handle));
  } else if ([@"pixelFreeDeleteHLSFilter" isEqualToString:call.method]) {
    int handle = [dicArguments[@"handle"] intValue];
    [_mPixelFree pixelFreeDeleteHLSFilter:handle];
    result(NULL);
  } else if ([@"pixelFreeChangeHLSFilter" isEqualToString:call.method]) {
    int handle = [dicArguments[@"handle"] intValue];
    NSDictionary *params = dicArguments;
    
    PFHLSFilterParams hlsParams = {
        .brightness = 0.0f,
        .saturation = 1.0f,
        .hue = 0.0f,
        .similarity = 0.0f,
    };
    NSArray *keyColor = params[@"keyColor"];
    hlsParams.key_color[0] = [keyColor[0] floatValue];
    hlsParams.key_color[1] = [keyColor[1] floatValue];
    hlsParams.key_color[2] = [keyColor[2] floatValue];
    
    hlsParams.hue = [params[@"hue"] floatValue];
    hlsParams.saturation = [params[@"saturation"] floatValue];
    hlsParams.brightness = [params[@"brightness"] floatValue];
    hlsParams.similarity = [params[@"similarity"] floatValue];
    
    [_mPixelFree pixelFreeChangeHLSFilter:handle params:&hlsParams];
    result(NULL);
  } else if ([@"pixelFreeSetColorGrading" isEqualToString:call.method]) {
    NSDictionary *params = dicArguments;
    PFImageColorGrading colorGrading = {
        .isUse = false,
        .brightness = 0.0f,
        .contrast = 1.0f,
        .exposure = 0.0f,
        .highlights = 0.0f,
        .shadows = 0.0f,
        .saturation = 1.0f,
        .temperature = 5000.0f,
        .tint = 0.0f,
        .hue = 0.0f
    };
    
    colorGrading.isUse = [params[@"isUse"] boolValue];
    colorGrading.brightness = [params[@"brightness"] floatValue];
    colorGrading.contrast = [params[@"contrast"] floatValue];
    colorGrading.exposure = [params[@"exposure"] floatValue];
    colorGrading.highlights = [params[@"highlights"] floatValue];
    colorGrading.shadows = [params[@"shadows"] floatValue];
    colorGrading.saturation = [params[@"saturation"] floatValue];
    colorGrading.temperature = [params[@"temperature"] floatValue];
    colorGrading.tint = [params[@"tint"] floatValue];
    colorGrading.hue = [params[@"hue"] floatValue];
    
    [_mPixelFree pixelFreeSetColorGrading:&colorGrading];
    result(NULL);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (CVPixelBufferRef)getRenderTargetWithWidth:(int)w height:(int)h rgbaBuffer:(char *)rgbaData {
  @autoreleasepool {
    // 如果之前已经创建了 _renderTarget，你可能需要在这里释放之前的 _renderTarget

    //        if (!_renderTarget || frameWidth != w || frameHeight != h) {
    frameWidth = w;
    frameHeight = h;

    CFDictionaryRef empty;  // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault,
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(
        kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);

    CVPixelBufferRef renderTarget;
    CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault,
                                            frameWidth,
                                            frameHeight,
                                            kCVPixelFormatType_32BGRA,
                                            attrs,
                                            &renderTarget);

    if (theError) {
      // 处理创建失败的情况
    }

    CVPixelBufferLockBaseAddress(renderTarget, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(renderTarget);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(renderTarget);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int pixelStart = (y * w + x) * 4;
        unsigned char *pixel = baseAddress + y * bytesPerRow + x * 4;
        pixel[0] = rgbaData[pixelStart + 2];  // B
        pixel[1] = rgbaData[pixelStart + 1];  // G
        pixel[2] = rgbaData[pixelStart];      // R
        pixel[3] = rgbaData[pixelStart + 3];  // A
      }
    }
    CVPixelBufferUnlockBaseAddress(renderTarget, 0);

    _renderTarget = renderTarget;
    //        }
    return _renderTarget;
  }
}

@end
