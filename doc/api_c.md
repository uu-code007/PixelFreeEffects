# pixelFree C API 文档

## 相关文档
- [iOS API 文档](api_iOS.md)
- [Android API 文档](api_android.md)
- [Flutter API 文档](api_flutter.md)
- [使用文档](../README.md)

## 适用平台

C API 适用于以下平台：
- **Windows**: 使用 `PixelFree.lib` 静态库
- **Linux**: 使用 `libPixelFree.so` 动态库
- **macOS**: 使用 `libPixelFree.a` 静态库

## API 引用

```c
#include "pixelFree_c.hpp"
```

## 数据类型

### PFPixelFree

SDK 实例句柄，所有 API 调用都需要此句柄。

```c
typedef struct PFPixelFree PFPixelFree;
```

### PFImageInput / PFIamgeInput

图像输入数据结构。

**注意**：不同平台类型名可能略有不同：
- Linux/macOS: `PFImageInput`
- Windows: `PFIamgeInput`（注意拼写）

```c
// Linux/macOS
typedef struct {
    int textureID;              // OpenGL纹理ID，buffer模式下为0
    int wigth;                  // 图像宽度
    int height;                 // 图像高度
    void* p_data0;              // 主要数据通道（Y或RGBA）
    void* p_data1;              // 第二数据通道（UV或null）
    void* p_data2;              // 第三数据通道（通常为null）
    int stride_0;               // 第一通道行步长
    int stride_1;               // 第二通道行步长
    int stride_2;               // 第三通道行步长
    PFDetectFormat format;      // 图像格式
    PFRotationMode rotationMode; // 图像旋转（用于人脸检测方向）
} PFImageInput;

// Windows (注意拼写差异)
typedef struct {
    // ... 相同字段 ...
} PFIamgeInput;
```

### PFDetectFormat

图像格式枚举。

```c
typedef enum PFDetectFormat {
    PFFORMAT_UNKNOWN = 0,       // 未知格式
    PFFORMAT_IMAGE_RGB = 1,     // RGB格式
    PFFORMAT_IMAGE_BGR = 2,     // BGR格式
    PFFORMAT_IMAGE_RGBA = 3,    // RGBA格式（推荐）
    PFFORMAT_IMAGE_BGRA = 4,    // BGRA格式
    PFFORMAT_IMAGE_ARGB = 5,    // ARGB格式
    PFFORMAT_IMAGE_ABGR = 6,    // ABGR格式
    PFFORMAT_IMAGE_GRAY = 7,    // 灰度图
    PFFORMAT_IMAGE_YUV_NV12 = 8, // YUV NV12格式
    PFFORMAT_IMAGE_YUV_NV21 = 9, // YUV NV21格式
    PFFORMAT_IMAGE_YUV_I420 = 10, // YUV I420格式
    PFFORMAT_IMAGE_TEXTURE = 11, // OpenGL纹理格式
} PFDetectFormat;
```

### PFRotationMode

旋转模式枚举。

```c
typedef enum PFRotationMode {
    PFRotationMode0 = 0,    // 0度旋转
    PFRotationMode90 = 1,    // 90度旋转
    PFRotationMode180 = 2,   // 180度旋转
    PFRotationMode270 = 3,   // 270度旋转
} PFRotationMode;
```

### PFSrcType

资源类型枚举。

```c
typedef enum PFSrcType {
    PFSrcTypeFilter = 0,        // 滤镜资源
    PFSrcTypeAuthFile = 2,      // 授权文件
    PFSrcTypeStickerFile = 3,   // 贴纸资源
} PFSrcType;
```

## 初始化与资源管理

### PF_NewPixelFree()

创建 PixelFree 实例。

```c
PFPixelFree* PF_NewPixelFree();
```

**返回值：**
- 成功：返回 `PFPixelFree*` 实例指针
- 失败：返回 `NULL`

**使用示例：**
```c
PFPixelFree* handle = PF_NewPixelFree();
if (handle == NULL) {
    // 处理错误
    return -1;
}
```

### PF_DeletePixelFree()

释放 PixelFree 实例。

```c
void PF_DeletePixelFree(PFPixelFree* pixelFree);
```

**参数：**
- `pixelFree`: PixelFree 实例指针

**使用示例：**
```c
PF_DeletePixelFree(handle);
```

### PF_Version()

获取 SDK 版本号。

```c
const char* PF_Version();
```

**返回值：**
- 版本号字符串

### PF_VLogSetLevel()

设置日志级别。

```c
void PF_VLogSetLevel(PFPixelFree* pixelFree, int level, char *path);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `level`: 日志级别
- `path`: 日志文件路径

## 资源加载

### PF_createBeautyItemFormBundle()

加载美颜资源包。支持加载美颜、滤镜、贴纸等资源。

```c
void PF_createBeautyItemFormBundle(PFPixelFree* pixelFree, void *data, int size, PFSrcType type);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `data`: 资源数据，通常从文件读取
- `size`: 数据大小（字节数）
- `type`: 资源类型，可选值：
  - `PFSrcTypeFilter`: 滤镜资源
  - `PFSrcTypeAuthFile`: 授权文件
  - `PFSrcTypeStickerFile`: 贴纸资源

**使用示例：**
```c
// 读取授权文件
FILE* authFile = fopen("pixelfreeAuth.lic", "rb");
fseek(authFile, 0, SEEK_END);
long authSize = ftell(authFile);
fseek(authFile, 0, SEEK_SET);
char* authBuffer = (char*)malloc(authSize);
fread(authBuffer, 1, authSize, authFile);
fclose(authFile);

// 加载授权
PF_createBeautyItemFormBundle(handle, authBuffer, (int)authSize, PFSrcTypeAuthFile);

// 读取滤镜文件
FILE* filterFile = fopen("filter_model.bundle", "rb");
fseek(filterFile, 0, SEEK_END);
long filterSize = ftell(filterFile);
fseek(filterFile, 0, SEEK_SET);
char* filterBuffer = (char*)malloc(filterSize);
fread(filterBuffer, 1, filterSize, filterFile);
fclose(filterFile);

// 加载滤镜
PF_createBeautyItemFormBundle(handle, filterBuffer, (int)filterSize, PFSrcTypeFilter);

free(authBuffer);
free(filterBuffer);
```

## 美颜参数设置

### PF_pixelFreeSetBeautyFilterParam() / PF_pixelFreeSetBeautyFiterParam()

设置美颜参数，如磨皮、美白、红润等。

**注意**：不同平台函数名可能略有不同：
- Linux/macOS: `PF_pixelFreeSetBeautyFilterParam`
- Windows: `PF_pixelFreeSetBeautyFiterParam`

```c
// Linux/macOS
void PF_pixelFreeSetBeautyFilterParam(PFPixelFree* pixelFree, int key, void *value);

// Windows
void PF_pixelFreeSetBeautyFiterParam(PFPixelFree* pixelFree, int key, void *value);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `key`: 美颜参数类型，常用类型包括：
  - `PFBeautyFilterTypeFace_EyeStrength`: 大眼
  - `PFBeautyFilterTypeFace_thinning`: 瘦脸
  - `PFBeautyFilterTypeFaceBlurStrength`: 磨皮
  - `PFBeautyFilterTypeFaceWhitenStrength`: 美白
  - `PFBeautyFilterTypeFaceRuddyStrength`: 红润
  - `PFBeautyFilterTypeFaceEyeBrighten`: 亮眼
  - `PFBeautyFilterNasolabial`: 祛法令纹
  - `PFBeautyFilterBlackEye`: 祛黑眼圈
  - `PFBeautyFilterWhitenTeeth`: 美牙
  - `PFBeautyFilterFleckFlawClean`: AI 祛瑕疵
  - 更多类型请参考 SDK 文档
- `value`: 参数值，通常为 `float` 类型指针，范围 0.0 ~ 1.0

**使用示例：**
```c
// 设置磨皮强度
float blurValue = 0.7f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceBlurStrength, &blurValue);
// Windows平台使用: PF_pixelFreeSetBeautyFiterParam

// 设置美牙强度
float whitenTeethValue = 0.5f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterWhitenTeeth, &whitenTeethValue);

// 设置亮眼强度
float eyeBrightenValue = 0.3f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceEyeBrighten, &eyeBrightenValue);

// 设置 AI 祛瑕疵强度
float fleckFlawCleanValue = 0.6f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterFleckFlawClean, &fleckFlawCleanValue);

// 设置滤镜
const char* filterName = "heibai1";
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterName, (void*)filterName);
float filterStrength = 0.8f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterStrength, &filterStrength);
```

### PF_pixelFreeSetFleckFlawClean()（v2.5.07+）

独立设置 AI 祛瑕疵强度。强度范围 **0.0 ~ 1.0**，默认 **0.0** 关闭。开启后 SDK 内部会按需启用 skin segmentation 与 delspot 输出。

```c
int PF_pixelFreeSetFleckFlawClean(PFPixelFree* pixelFree, float strength);
```

**示例：**
```c
PF_pixelFreeSetFleckFlawClean(handle, 0.6f);
```

## 美体参数（v2.5.06+）

基于人体 25 关键点，与脸部美型参数独立。使用 `PF_pixelFreeSetBodyBeautyParam` 设置；`key` 为 `PFBodyBeautyType`，`value` 为指向 `float` 的指针，一般 **0.0 ~ 1.0**，**0.5 为中性**。

### PF_pixelFreeSetBodyBeautyParam()

```c
void PF_pixelFreeSetBodyBeautyParam(PFPixelFree* pixelFree, int key, void *value);
```

**参数：**
- `pixelFree`: 实例指针
- `key`: `PFBodyBeautyType` 枚举值
- `value`: `float *` 强度

**示例：**
```c
float v = 0.65f;
PF_pixelFreeSetBodyBeautyParam(handle, PFBodyBeautyTypeSlimBody, &v);

float neutral = 0.5f;
PF_pixelFreeSetBodyBeautyParam(handle, PFBodyBeautyTypeSlimBelly, &neutral);
```

### PFBodyBeautyType 与中文名称对照

| 值 | 枚举名 | 中文 |
| --: | ------ | ---- |
| 0 | `PFBodyBeautyTypePreset` | 体型预设 |
| 1 | `PFBodyBeautyTypeSlimBody` | 瘦身 |
| 2 | `PFBodyBeautyTypeSlimWaist` | 瘦腰 |
| 3 | `PFBodyBeautyTypeBelly` | 沙漏腰 |
| 4 | `PFBodyBeautyTypeCurve` | 曲线 |
| 5 | `PFBodyBeautyTypeFullSlim` | 全身瘦 |
| 6 | `PFBodyBeautyTypeHipLift` | 提跨 |
| 7 | `PFBodyBeautyTypeHipEnlarge` | 丰臀 |
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
| 21 | `PFBodyBeautyTypeHeight` | 长腿 |
| 22 | `PFBodyBeautyTypeSlimBelly` | 瘦肚子 |

方向性说明（提跨、丰臀、长腿、瘦肚子等）以 `pixelFree_c.hpp` 中 `PFBodyBeautyType` 注释为准。

## 图像处理

### PF_processWithBuffer()

处理图像数据，支持实时预览。这是美颜SDK的核心处理方法，用于对输入图像进行美颜处理。

```c
// Linux/macOS
int PF_processWithBuffer(PFPixelFree* pixelFree, PFImageInput inputImage);

// Windows
int PF_processWithBuffer(PFPixelFree* pixelFree, PFIamgeInput inputImage);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `inputImage`: 图像输入数据，包含图像的所有必要信息

**返回值：**
- 处理后的纹理 ID（纹理模式下）
- 处理结果状态码

#### PFImageInput 参数详解

```c
PFImageInput image;
image.textureID = 0;           // OpenGL纹理ID，buffer模式下为0
image.wigth = 720;             // 图像宽度
image.height = 1280;            // 图像高度
image.p_data0 = rgbaData;       // 主要数据通道（Y或RGBA）
image.p_data1 = NULL;          // 第二数据通道（UV或null）
image.p_data2 = NULL;          // 第三数据通道（通常为null）
image.stride_0 = 720 * 4;      // 第一通道行步长
image.stride_1 = 0;            // 第二通道行步长
image.stride_2 = 0;            // 第三通道行步长
image.format = PFFORMAT_IMAGE_RGBA;  // 图像格式
image.rotationMode = PFRotationMode90; // 图像旋转
```

#### 使用示例

**1. RGBA格式图像处理（推荐）**

```c
// 处理RGBA图像数据
PFImageInput image;
image.textureID = 0;
image.wigth = 720;
image.height = 1280;
image.p_data0 = rgbaData;        // RGBA字节数组
image.p_data1 = NULL;
image.p_data2 = NULL;
image.stride_0 = 720 * 4;        // 每行字节数 = width * 4
image.stride_1 = 0;
image.stride_2 = 0;
image.format = PFFORMAT_IMAGE_RGBA;
image.rotationMode = PFRotationMode90;

int result = PF_processWithBuffer(handle, image);
// 处理后的数据在 image.p_data0 中，源数据会被覆盖
```

**2. OpenGL纹理处理**

```c
// 处理OpenGL纹理
PFImageInput image;
image.textureID = inputTextureID;  // 输入纹理ID
image.wigth = 720;
image.height = 1280;
image.p_data0 = NULL;
image.p_data1 = NULL;
image.p_data2 = NULL;
image.stride_0 = 0;
image.stride_1 = 0;
image.stride_2 = 0;
image.format = PFFORMAT_IMAGE_TEXTURE;
image.rotationMode = PFRotationMode0;

int outputTextureID = PF_processWithBuffer(handle, image);
// 返回处理后的纹理ID
```

**3. YUV格式处理**

```c
// YUV NV21格式处理
int ySize = width * height;
int uvSize = width * height / 2;
unsigned char* yData = (unsigned char*)malloc(ySize);
unsigned char* uvData = (unsigned char*)malloc(uvSize);

// 分离YUV数据
memcpy(yData, yuvData, ySize);
memcpy(uvData, yuvData + ySize, uvSize);

PFImageInput image;
image.textureID = 0;
image.wigth = width;
image.height = height;
image.p_data0 = yData;
image.p_data1 = uvData;
image.p_data2 = NULL;
image.stride_0 = width;
image.stride_1 = width;
image.stride_2 = 0;
image.format = PFFORMAT_IMAGE_YUV_NV21;
image.rotationMode = PFRotationMode90;

int result = PF_processWithBuffer(handle, image);
// 处理后的数据在 image.p_data0 和 image.p_data1 中

free(yData);
free(uvData);
```

#### 注意事项

1. **数据格式匹配**：确保 `format` 与实际的图像数据格式一致
2. **内存管理**：处理过程中SDK会修改输入数据，注意数据备份
3. **OpenGL上下文**：纹理模式需要在正确的OpenGL上下文中调用
4. **性能优化**：建议在子线程中处理，避免阻塞主线程
5. **错误处理**：检查返回值确保处理成功

## 人脸检测

### PF_pixelFreeGetFaceRect()

获取人脸矩形框。

```c
void PF_pixelFreeGetFaceRect(PFPixelFree* pixelFree, float *faceRect);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `faceRect`: 输出人脸矩形框数组 [x, y, width, height]

**使用示例：**
```c
float faceRect[4];
PF_pixelFreeGetFaceRect(handle, faceRect);
// faceRect[0]: x坐标
// faceRect[1]: y坐标
// faceRect[2]: 宽度
// faceRect[3]: 高度
```

### PF_pixelFreeHaveFaceSize()

获取检测到的人脸数量。

```c
int PF_pixelFreeHaveFaceSize(PFPixelFree* pixelFree);
```

**参数：**
- `pixelFree`: PixelFree 实例指针

**返回值：**
- 人脸数量

## 图像调色

### PF_pixelFreeColorGrading()

设置图像颜色分级参数。

```c
int PF_pixelFreeColorGrading(PFPixelFree* pixelFree, PFImageColorGrading* ImageColorGrading);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `ImageColorGrading`: 颜色分级参数结构体

**PFImageColorGrading 结构：**
```c
typedef struct {
    bool isUse;              // 是否启用
    float brightness;        // 亮度 (-1.0 到 1.0)
    float contrast;          // 对比度 (0.0 到 4.0)
    float exposure;          // 曝光度 (-10.0 到 10.0)
    float highlights;        // 高光 (0 到 1)
    float shadows;           // 阴影 (0 到 1)
    float saturation;        // 饱和度 (0.0 到 2.0)
    float temperature;       // 色温
    float tint;              // 色调
    float hue;               // 色相 (0-360)
} PFImageColorGrading;
```

**返回值：**
- 操作结果状态码

**使用示例：**
```c
PFImageColorGrading colorGrading;
colorGrading.isUse = true;
colorGrading.brightness = 0.1f;
colorGrading.contrast = 1.2f;
colorGrading.exposure = 0.0f;
colorGrading.highlights = 0.5f;
colorGrading.shadows = 0.5f;
colorGrading.saturation = 1.0f;
colorGrading.temperature = 5000.0f;
colorGrading.tint = 0.0f;
colorGrading.hue = 0.0f;

int result = PF_pixelFreeColorGrading(handle, &colorGrading);
```

## HLS 滤镜操作

### PF_pixelFreeAddHLSFilter()

添加 HLS 滤镜。

```c
int PF_pixelFreeAddHLSFilter(PFPixelFree* pixelFree, PFHLSFilterParams* HLSFilterParams);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `HLSFilterParams`: HLS 滤镜参数

**PFHLSFilterParams 结构：**
```c
typedef struct {
    float key_color[3];      // 关键色 [R, G, B] (0-1)
    float hue;               // 色相
    float saturation;        // 饱和度 (0-1.0)
    float brightness;        // 亮度 (0-1.0)
    float similarity;        // 相似度
} PFHLSFilterParams;
```

**返回值：**
- 滤镜句柄，用于后续修改或删除

**使用示例：**
```c
PFHLSFilterParams hlsParams;
hlsParams.key_color[0] = 1.0f;  // R
hlsParams.key_color[1] = 0.0f;  // G
hlsParams.key_color[2] = 0.0f;  // B
hlsParams.hue = 0.0f;
hlsParams.saturation = 1.0f;
hlsParams.brightness = 1.0f;
hlsParams.similarity = 0.5f;

int handle = PF_pixelFreeAddHLSFilter(handle, &hlsParams);
```

### PF_pixelFreeDeleteHLSFilter()

删除 HLS 滤镜。

```c
int PF_pixelFreeDeleteHLSFilter(PFPixelFree* pixelFree, int handle);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `handle`: 滤镜句柄，由 `PF_pixelFreeAddHLSFilter` 返回

**返回值：**
- 操作结果状态码

### PF_pixelFreeChangeHLSFilter()

修改 HLS 滤镜参数。

```c
int PF_pixelFreeChangeHLSFilter(PFPixelFree* pixelFree, int handle, PFHLSFilterParams* HLSFilterParams);
```

**参数：**
- `pixelFree`: PixelFree 实例指针
- `handle`: 滤镜句柄
- `HLSFilterParams`: 新的滤镜参数

**返回值：**
- 操作结果状态码
