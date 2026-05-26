# pixelFree iOS API 文档

## 相关文档
- [Android API 文档](api_android.md)
- [Flutter API 文档](api_flutter.md)
- [C API 文档](api_c.md)
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
- `key`: 美颜参数类型，常用类型包括：
  - `PFBeautyFilterTypeFaceBlurStrength`: 磨皮
  - `PFBeautyFilterTypeFaceM_newWhitenStrength`: 美白
  - `PFBeautyFilterTypeFaceRuddyStrength`: 红润
  - `PFBeautyFilterTypeFaceEyeBrighten`: 亮眼
  - `PFBeautyFilterNasolabial`: 祛法令纹
  - `PFBeautyFilterBlackEye`: 祛黑眼圈
  - `PFBeautyFilterWhitenTeeth`: 美牙
  - `PFBeautyFilterFleckFlawClean`: AI 祛瑕疵
- `value`: 参数值，通常为 `float` 类型指针，范围 0.0 ~ 1.0

**使用示例：**
```objective-c
// 设置磨皮强度
float blurValue = 0.7f;
[_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceBlurStrength value:&blurValue];

// 设置美牙强度
float whitenTeethValue = 0.5f;
[_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterWhitenTeeth value:&whitenTeethValue];

// 设置亮眼强度
float eyeBrightenValue = 0.3f;
[_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceEyeBrighten value:&eyeBrightenValue];

// 设置 AI 祛瑕疵强度
float fleckFlawCleanValue = 0.6f;
[_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterFleckFlawClean value:&fleckFlawCleanValue];
```

### AI 祛瑕疵（v2.5.07+）

`PFBeautyFilterFleckFlawClean` 用于弱化面部痘印、斑点等瑕疵，强度范围 **0.0 ~ 1.0**，默认 **0.0** 关闭。开启后 SDK 内部会按需启用 skin segmentation 与 delspot 输出。

## 美体参数（v2.5.06+）

基于人体 25 关键点对身体区域塑形，与美型（脸部）独立。`key` 为 `PFBodyBeautyType` 枚举整型，`value` 为 `float *`，一般取值 **0.0 ~ 1.0**，**默认 0.5 表示中性**（无调节效果）。部分项目以 0.5 为分界向两侧增强/反向，含义见下表及 `pixelFree_c.hpp` 内注释。

### pixelFreeSetBodyBeautyParam:value:

```objective-c
- (void)pixelFreeSetBodyBeautyParam:(int)key value:(void *)value;
```

**参数：**
- `key`: `PFBodyBeautyType` 枚举值（与 C 头文件一致）
- `value`: 指向 `float` 的指针

**示例：**
```objective-c
float slim = 0.65f;
[_mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeSlimBody value:&slim];

float waist = 0.5f; // 中性
[_mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeSlimWaist value:&waist];
```

### PFBodyBeautyType 与中文名称对照

| 枚举值 | 枚举名 | 中文（与 Demo 调节项一致） |
| -----: | ------ | ------------------------- |
| 0 | `PFBodyBeautyTypePreset` | 体型预设（0~6 子风格，见头文件） |
| 1 | `PFBodyBeautyTypeSlimBody` | 瘦身 |
| 2 | `PFBodyBeautyTypeSlimWaist` | 瘦腰 |
| 3 | `PFBodyBeautyTypeBelly` | 沙漏腰 |
| 4 | `PFBodyBeautyTypeCurve` | 曲线 |
| 5 | `PFBodyBeautyTypeFullSlim` | 全身瘦 |
| 6 | `PFBodyBeautyTypeHipLift` | 提跨（0.5 中性；>0.5 上提，<0.5 下压） |
| 7 | `PFBodyBeautyTypeHipEnlarge` | 丰臀（0.5 中性；>0.5 丰臀，<0.5 缩臀） |
| 8 | `PFBodyBeautyTypeBreastEnlarge` | 丰胸 |
| 9 | `PFBodyBeautyTypeSlimArm` | 手臂（整体） |
| 10 | `PFBodyBeautyTypeSwanNeck` | 天鹅颈 |
| 11 | `PFBodyBeautyTypeShoulderThin` | 瘦肩膀 |
| 12 | `PFBodyBeautyTypeRightAngleShoulder` | 直角肩 |
| 13 | `PFBodyBeautyTypeLeftUpperArm` | 左大臂 |
| 14 | `PFBodyBeautyTypeLeftLowerArm` | 左小臂 |
| 15 | `PFBodyBeautyTypeRightUpperArm` | 右大臂 |
| 16 | `PFBodyBeautyTypeRightLowerArm` | 右小臂 |
| 17 | `PFBodyBeautyTypeLeftUpperLeg` | 左大腿 |
| 18 | `PFBodyBeautyTypeLeftLowerLeg` | 左小腿 |
| 19 | `PFBodyBeautyTypeRightUpperLeg` | 右大腿 |
| 20 | `PFBodyBeautyTypeRightLowerLeg` | 右小腿 |
| 21 | `PFBodyBeautyTypeHeight` | 长腿（0.5 中性；>0.5 拉长，<0.5 缩短） |
| 22 | `PFBodyBeautyTypeSlimBelly` | 瘦肚子（0.5 中性；径向液化，作用范围小于瘦身） |

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

## 美妆功能

### createBeautyItemFormBundleKey:data:size:

加载美妆资源包。

```objective-c
- (void)createBeautyItemFormBundleKey:(int)key data:(void*)data size:(int)sz;
```

**参数：**
- `key`: 资源类型，美妆使用 `PFSrcTypeMakeup` (值为 4)
- `data`: 美妆 bundle 文件的字节数据
- `sz`: 数据大小（字节数）

**使用示例：**
```objective-c
// 读取美妆 bundle 文件
NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"makeup_name" ofType:@"bundle"];
NSData *bundleData = [NSData dataWithContentsOfFile:bundlePath];

// 加载美妆
[self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeMakeup 
                                           data:(void *)bundleData.bytes 
                                           size:(int)bundleData.length];
```

### pixelFreeSetMakeupWithJsonPath:

通过 JSON 配置文件设置美妆。

```objective-c
- (int)pixelFreeSetMakeupWithJsonPath:(NSString *)jsonPath;
```

**参数：**
- `jsonPath`: 美妆配置 JSON 文件路径

**返回值：**
- 操作结果状态码

### clearMakeup

清除当前美妆效果。

```objective-c
- (int)clearMakeup;
```

**返回值：**
- 操作结果状态码

**使用示例：**
```objective-c
// 清除美妆
[self.mPixelFree clearMakeup];
```

### pixelFreeSetMakeupPart:degree:

设置美妆部位程度（与配置叠乘）。

```objective-c
- (void)pixelFreeSetMakeupPart:(int)part degree:(float)degree;
```

**参数：**
- `part`: 美妆部位类型，使用 `PFMakeupPart` 枚举值：
  - `PFMakeupPartBrow` (0): 眉毛
  - `PFMakeupPartBlusher` (1): 腮红
  - `PFMakeupPartEyeShadow` (2): 眼影
  - `PFMakeupPartEyeLiner` (3): 眼线
  - `PFMakeupPartEyeLash` (4): 睫毛
  - `PFMakeupPartLip` (5): 唇彩
  - `PFMakeupPartHighlight` (6): 高光
  - `PFMakeupPartShadow` (7): 阴影
  - `PFMakeupPartFoundation` (8): 粉底
- `degree`: 程度值，范围 0.0 ~ 1.0，与配置中的程度值叠乘

**使用示例：**
```objective-c
// 设置唇彩程度为 0.8
[self.mPixelFree pixelFreeSetMakeupPart:PFMakeupPartLip degree:0.8f];

// 设置眼影程度为 0.5
[self.mPixelFree pixelFreeSetMakeupPart:PFMakeupPartEyeShadow degree:0.5f];
```
