# pixelFree iOS API 文档

## 相关文档
- [Android API 文档](api_android.md)
- [Flutter API 文档](api_flutter.md)
- [使用文档](../README.md)

## API 引用

```objective-c
#import <SMBeautyEngine/SMPixelFree.h>
#import <SMBeautyEngine/PFBeautyFilterType.h>
#import <SMBeautyEngine/PFImageColorGrading.h>
#import <SMBeautyEngine/PFHLSFilterParams.h>
```


初始化 SMPixelFree 实例。

```objective-c
- (instancetype)initWithProcessContext:(EAGLContext *)context 
                         srcFilterPath:(NSString *)filterPath 
                             authFile:(NSString *)authFile;
```

**参数：**
- `context`: OpenGL ES 上下文，如果为 nil，将在第一帧处理时初始化
- `filterPath`: 滤镜资源文件路径
- `authFile`: 授权文件路径

## 属性

### glContext

OpenGL ES 上下文。

```objective-c
@property(nonatomic, strong, readonly) EAGLContext* glContext;
```

## 图像处理方法

### processWithTexture:width:height:rotation:

处理纹理数据。

```objective-c
- (int)processWithTexture:(GLuint)texture 
                    width:(GLint)width 
                   height:(GLint)height 
                 rotation:(PFRotationMode)rotation;
```

**参数：**
- `texture`: 输入纹理 ID
- `width`: 纹理宽度
- `height`: 纹理高度
- `rotation`: 旋转模式

**返回值：**
- 处理后的纹理 ID

### processWithBuffer:rotationMode:

处理 CPU 数据。

```objective-c
- (int)processWithBuffer:(CVPixelBufferRef)pixelBuffer 
             rotationMode:(PFRotationMode)rotationMode;
```

**参数：**
- `pixelBuffer`: 输入像素缓冲区
- `rotationMode`: 人脸检测方向

**返回值：**
- 处理结果状态码

### processWithImage:rotationMode:

处理图片数据。

```objective-c
- (UIImage *)processWithImage:(UIImage *)image 
                 rotationMode:(PFRotationMode)rotationMode;
```

**参数：**
- `image`: 输入图片
- `rotationMode`: 人脸检测方向

**返回值：**
- 处理后的图片

## 美颜参数设置

### pixelFreeSetBeautyFilterParam:value:

设置美颜参数。

```objective-c
- (void)pixelFreeSetBeautyFilterParam:(int)key value:(void *)value;
```

**参数：**
- `key`: 美颜参数类型
- `value`: 参数值

## 资源加载

### createBeautyItemFormBundle:size:

加载美颜资源包。

```objective-c
- (void)createBeautyItemFormBundle:(void*)data size:(int)sz;
```

**参数：**
- `data`: 资源数据
- `sz`: 数据大小

## 人脸检测

### pixelFreeGetFaceRect:

获取人脸矩形框。

```objective-c
- (void)pixelFreeGetFaceRect:(float *)faceRect;
```

**参数：**
- `faceRect`: 输出人脸矩形框数组 [x, y, width, height]

### getPixelFreeFaceNum

获取检测到的人脸数量。

```objective-c
- (int)getPixelFreeFaceNum;
```

**返回值：**
- 人脸数量

## 图像调色

### pixelFreeSetColorGrading:

设置图像颜色分级参数。

```objective-c
- (int)pixelFreeSetColorGrading:(PFImageColorGrading *)imageColorGrading;
```

**参数：**
- `imageColorGrading`: 颜色分级参数结构体

**返回值：**
- 操作结果状态码

## HLS 滤镜操作

### pixelFreeAddHLSFilter:

添加 HLS 滤镜。

```objective-c
- (int)pixelFreeAddHLSFilter:(PFHLSFilterParams*)HLSFilterParams;
```

**参数：**
- `HLSFilterParams`: HLS 滤镜参数

**返回值：**
- 滤镜句柄

### pixelFreeDeleteHLSFilter:

删除 HLS 滤镜。

```objective-c
- (int)pixelFreeDeleteHLSFilter:(int)handle;
```

**参数：**
- `handle`: 滤镜句柄

**返回值：**
- 操作结果状态码

### pixelFreeChangeHLSFilter:params:

修改 HLS 滤镜参数。

```objective-c
- (int)pixelFreeChangeHLSFilter:(int)handle params:(PFHLSFilterParams*)HLSFilterParams;
```

**参数：**
- `handle`: 滤镜句柄
- `HLSFilterParams`: 新的滤镜参数

**返回值：**
- 操作结果状态码

## 贴纸功能

### pixelFreeSetFiterStickerWithPath:

设置自定义贴纸。

```objective-c
- (void)pixelFreeSetFiterStickerWithPath:(NSString *)path;
```

**参数：**
- `path`: 贴纸资源路径 