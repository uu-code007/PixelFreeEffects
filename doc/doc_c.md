# pixelFree C 使用文档

## 相关文档
- [C API 文档](api_c.md)
- [Windows 使用文档](doc_windows.md)
- [使用文档](../README.md)

## 适用平台

C API 适用于以下平台：
- **Windows**: 使用 `PixelFree.lib` 静态库
- **Linux**: 使用 `libPixelFree.so` 动态库
- **macOS**: 使用 `libPixelFree.a` 静态库

## 接入方式

### Windows 平台

1. **手动接入**

   将 `PixelFree.lib` 和 `pixelFree_c.hpp` 添加到项目中，参考 demo 工程接入。

2. **CMake 接入**

   在 `CMakeLists.txt` 中添加：
   ```cmake
   target_link_libraries(your_target PixelFree)
   include_directories(path/to/pixelFree_c.hpp)
   ```

### Linux 平台

1. **动态库接入**

   将 `libPixelFree.so` 和 `pixelFree_c.hpp` 添加到项目中。

2. **CMake 接入**

   在 `CMakeLists.txt` 中添加：
   ```cmake
   target_link_libraries(your_target PixelFree)
   include_directories(path/to/pixelFree_c.hpp)
   ```

### macOS 平台

1. **静态库接入**

   将 `libPixelFree.a` 和 `pixelFree_c.hpp` 添加到项目中。

2. **CMake 接入**

   在 `CMakeLists.txt` 中添加：
   ```cmake
   target_link_libraries(your_target PixelFree)
   include_directories(path/to/pixelFree_c.hpp)
   ```

## 仅需四步，完成接入使用

### 1. 初始化

```c
#include "pixelFree_c.hpp"

// 创建 PixelFree 实例
PFPixelFree* handle = PF_NewPixelFree();
if (handle == NULL) {
    // 处理错误
    return -1;
}

// 读取授权文件
FILE* authFile = fopen("pixelfreeAuth.lic", "rb");
if (authFile == NULL) {
    PF_DeletePixelFree(handle);
    return -1;
}

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
if (filterFile == NULL) {
    free(authBuffer);
    PF_DeletePixelFree(handle);
    return -1;
}

fseek(filterFile, 0, SEEK_END);
long filterSize = ftell(filterFile);
fseek(filterFile, 0, SEEK_SET);
char* filterBuffer = (char*)malloc(filterSize);
fread(filterBuffer, 1, filterSize, filterFile);
fclose(filterFile);

// 加载滤镜资源
PF_createBeautyItemFormBundle(handle, filterBuffer, (int)filterSize, PFSrcTypeFilter);

free(authBuffer);
free(filterBuffer);
```

### 2. 美颜参数设置

```c
// 设置瘦脸
float thinningValue = 0.5f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFace_thinning, &thinningValue);
// Windows平台使用: PF_pixelFreeSetBeautyFiterParam

// 设置磨皮
float blurValue = 0.7f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceBlurStrength, &blurValue);

// 设置美白
float whitenValue = 0.5f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceM_newWhitenStrength, &whitenValue);

// 设置美牙
float whitenTeethValue = 0.5f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterWhitenTeeth, &whitenTeethValue);

// 设置亮眼
float eyeBrightenValue = 0.3f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceEyeBrighten, &eyeBrightenValue);
```

### 3. 滤镜设置

```c
// 设置滤镜类型
const char* filterName = "heibai1";
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterName, (void*)filterName);

// 设置滤镜强度（0.0 ~ 1.0）
float filterStrength = 0.8f;
PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterStrength, &filterStrength);
```

### 4. 图像渲染处理

```c
// 准备图像数据
PFImageInput image;
image.textureID = 0;                    // buffer模式下为0
image.wigth = 720;                      // 图像宽度
image.height = 1280;                    // 图像高度
image.p_data0 = rgbaData;               // RGBA数据
image.p_data1 = NULL;
image.p_data2 = NULL;
image.stride_0 = 720 * 4;               // 每行字节数
image.stride_1 = 0;
image.stride_2 = 0;
image.format = PFFORMAT_IMAGE_RGBA;      // 图像格式
image.rotationMode = PFRotationMode90;  // 旋转模式

int result = PF_processWithBuffer(handle, image);

// 处理后的数据在 image.p_data0 中，源数据会被覆盖
```

### 5. 资源释放

```c
// 释放资源
PF_DeletePixelFree(handle);
```

## processWithBuffer 详细使用说明

`PF_processWithBuffer` 是美颜SDK的核心处理方法，用于对输入图像进行美颜处理。该方法需要传入一个 `PFImageInput` 结构体，包含图像的所有必要信息。

### PFImageInput 参数详解

```c
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
```

### 支持的图像格式

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

### 旋转模式（用于人脸检测方向）

```c
typedef enum PFRotationMode {
    PFRotationMode0 = 0,    // 0度旋转
    PFRotationMode90 = 1,   // 90度旋转
    PFRotationMode180 = 2,  // 180度旋转
    PFRotationMode270 = 3,  // 270度旋转
} PFRotationMode;
```

### 使用示例

####  OpenGL纹理处理（推荐）

```c
// 处理OpenGL纹理
GLuint inputTextureID = ...; // 输入纹理ID

PFImageInput image;
image.textureID = inputTextureID;
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

### 注意事项

1. **数据格式匹配**：确保 `format` 与实际的图像数据格式一致
2. **内存管理**：处理过程中SDK会修改输入数据，注意数据备份
3. **OpenGL上下文**：纹理模式需要在正确的OpenGL上下文中调用
4. **性能优化**：建议在子线程中处理，避免阻塞主线程
5. **错误处理**：检查返回值确保处理成功

### 返回值说明

`PF_processWithBuffer` 方法执行后：
- 纹理模式下：返回处理后的OpenGL纹理ID
- Buffer模式下：处理后的数据在 `image.p_data0` 中，源数据会被覆盖

## 设置美颜参数说明，参数范围（0.0~1.0）

```c
typedef enum PFBeautyFilterType {
    PFBeautyFilterTypeFace_EyeStrength = 0,  // 大眼（默认0.0，关闭）
    PFBeautyFilterTypeFace_thinning,         // 瘦脸（默认0.0，关闭）
    PFBeautyFilterTypeFace_narrow,           // 窄脸（默认0.0，关闭）
    PFBeautyFilterTypeFace_chin,             // 下巴（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_V,                // V脸（默认0.0，关闭）
    PFBeautyFilterTypeFace_small,            // 小脸（默认0.0，关闭）
    PFBeautyFilterTypeFace_nose,             // 瘦鼻（默认0.0，关闭）
    PFBeautyFilterTypeFace_forehead,         // 额头（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_mouth,            // 嘴巴（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_philtrum,          // 人中（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_long_nose = 10,   // 长鼻（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_eye_space,        // 眼距（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_smile,            // 微笑嘴角（默认0.0，关闭）
    PFBeautyFilterTypeFace_eye_rotate,       // 旋转眼睛（默认0.5，两个方向调节）
    PFBeautyFilterTypeFace_canthus,          // 开眼角（默认0.0，关闭）
    PFBeautyFilterTypeFaceBlurStrength,      // 磨皮（默认0.0，关闭）
    PFBeautyFilterTypeFaceWhitenStrength,    // 美白（默认0.0，关闭）
    PFBeautyFilterTypeFaceRuddyStrength,     // 红润（默认0.0，关闭）
    PFBeautyFilterTypeFaceSharpenStrength,   // 锐化（默认0.0，关闭）
    PFBeautyFilterTypeFaceM_newWhitenStrength, // 新美白算法（默认0.0，关闭）
    // @deprecated v2.5.01 已废弃，请使用 PFBeautyFilterTypeFaceSharpenStrength
    PFBeautyFilterTypeFaceH_qualityStrength, // 画质增强（默认0.0，关闭）
    PFBeautyFilterTypeFaceEyeBrighten,       // 亮眼（默认0.0，关闭）
    PFBeautyFilterName,                      // 滤镜类型
    PFBeautyFilterStrength,                  // 滤镜强度
    PFBeautyFilterLvmu,                      // 绿幕
    PFBeautyFilterSticker2DFilter,           // 2D 贴纸
    PFBeautyFilterTypeOneKey = 26,           // 一键美颜
    PFBeautyFilterWatermark,                 // 水印
    PFBeautyFilterExtend,                    // 扩展字段
    PFBeautyFilterNasolabial,                // 祛法令纹（默认0.0，关闭）
    PFBeautyFilterBlackEye,                  // 祛黑眼圈（默认0.0，关闭）
    PFBeautyFilterWhitenTeeth,               // 美牙（默认0.0，关闭）

    // ===== 新增：PFWarpFace 细分（默认0.5，取值建议 0.0~1.0）=====
    PFBeautyFilterTypeFace_eye_y,            // 眼睛上下（>0.5上移，<0.5下移）
    PFBeautyFilterTypeFace_eye_height,       // 眼高低（>0.5眼裂增大，<0.5眼裂减小）
    PFBeautyFilterTypeFace_nose_size,        // 鼻子大小（>0.5放大，<0.5缩小）
    PFBeautyFilterTypeFace_nose_height,      // 鼻子高低（>0.5增高，<0.5降低）
    PFBeautyFilterTypeFace_nose_y,           // 鼻子上下（>0.5上移，<0.5下移）
    PFBeautyFilterTypeFace_nose_tip,         // 鼻尖（>0.5更突出，<0.5更收敛）
    PFBeautyFilterTypeFace_nose_bridge,      // 鼻梁（>0.5更立体，<0.5更平缓）
    PFBeautyFilterTypeFace_brow_thickness,   // 眉粗细（>0.5加粗，<0.5变细）
    PFBeautyFilterTypeFace_brow_length,      // 眉长短（>0.5变长，<0.5变短）
    PFBeautyFilterTypeFace_brow_lift,        // 眉提升（>0.5上提，<0.5下压）
    PFBeautyFilterTypeFace_brow_distance,    // 眉距离（>0.5拉开，<0.5靠近）
    PFBeautyFilterTypeFace_brow_tilt,        // 眉倾斜（>0.5眉尾上扬，<0.5眉尾下压）
    PFBeautyFilterTypeFace_upper_lip_thickness, // 上唇厚度（>0.5变厚，<0.5变薄）
    PFBeautyFilterTypeFace_lower_lip_thickness, // 下唇厚度（>0.5变厚，<0.5变薄）
    PFBeautyFilterTypeFace_lip_fullness,     // 丰唇（>0.5更饱满，<0.5更收薄）
    PFBeautyFilterTypeFace_mouth_width,      // 嘴唇宽度（>0.5变宽，<0.5变窄）
} PFBeautyFilterType;
```

## 完整示例代码

```c
#include <stdio.h>
#include <stdlib.h>
#include "pixelFree_c.hpp"

int main() {
    // 1. 创建实例
    PFPixelFree* handle = PF_NewPixelFree();
    if (handle == NULL) {
        printf("Failed to create PixelFree handle\n");
        return -1;
    }

    // 2. 加载授权文件
    FILE* authFile = fopen("pixelfreeAuth.lic", "rb");
    if (authFile == NULL) {
        printf("Failed to open auth file\n");
        PF_DeletePixelFree(handle);
        return -1;
    }

    fseek(authFile, 0, SEEK_END);
    long authSize = ftell(authFile);
    fseek(authFile, 0, SEEK_SET);
    char* authBuffer = (char*)malloc(authSize);
    fread(authBuffer, 1, authSize, authFile);
    fclose(authFile);

    PF_createBeautyItemFormBundle(handle, authBuffer, (int)authSize, PFSrcTypeAuthFile);

    // 3. 加载滤镜资源
    FILE* filterFile = fopen("filter_model.bundle", "rb");
    if (filterFile == NULL) {
        printf("Failed to open filter file\n");
        free(authBuffer);
        PF_DeletePixelFree(handle);
        return -1;
    }

    fseek(filterFile, 0, SEEK_END);
    long filterSize = ftell(filterFile);
    fseek(filterFile, 0, SEEK_SET);
    char* filterBuffer = (char*)malloc(filterSize);
    fread(filterBuffer, 1, filterSize, filterFile);
    fclose(filterFile);

    PF_createBeautyItemFormBundle(handle, filterBuffer, (int)filterSize, PFSrcTypeFilter);

    // 4. 设置美颜参数
    float blurValue = 0.7f;
    PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceBlurStrength, &blurValue);

    float whitenValue = 0.5f;
    PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFaceM_newWhitenStrength, &whitenValue);

    float whitenTeethValue = 0.5f;
    PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterWhitenTeeth, &whitenTeethValue);

    // 5. 设置滤镜
    const char* filterName = "heibai1";
    PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterName, (void*)filterName);
    float filterStrength = 0.8f;
    PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterStrength, &filterStrength);

    // 6. 处理图像
    PFImageInput image;
    image.textureID = 0;
    image.wigth = 720;
    image.height = 1280;
    image.p_data0 = rgbaData;  // 假设已有RGBA数据
    image.p_data1 = NULL;
    image.p_data2 = NULL;
    image.stride_0 = 720 * 4;
    image.stride_1 = 0;
    image.stride_2 = 0;
    image.format = PFFORMAT_IMAGE_RGBA;
    image.rotationMode = PFRotationMode90;

    int result = PF_processWithBuffer(handle, image);
    printf("Process result: %d\n", result);

    // 7. 清理资源
    free(authBuffer);
    free(filterBuffer);
    PF_DeletePixelFree(handle);

    return 0;
}
```

## 注意事项

1. **内存管理**：确保在使用完数据后释放内存
2. **文件路径**：确保授权文件和资源文件的路径正确
3. **错误处理**：检查所有函数调用的返回值
4. **线程安全**：SDK不是线程安全的，请在单线程中使用或自行加锁
5. **资源释放**：使用完毕后务必调用 `PF_DeletePixelFree` 释放资源

## 常见问题

1. **Q: 如何处理多线程场景？**
   A: SDK不是线程安全的，建议在单线程中使用，或使用互斥锁保护SDK调用。

2. **Q: 纹理模式下如何处理？**
   A: 确保在正确的OpenGL上下文中调用，并正确设置 `textureID` 和 `format`。

3. **Q: 如何获取处理后的数据？**
   A: iOS || android  Buffer模式下，处理后的数据会覆盖 `image.p_data0`；纹理模式下，返回处理后的纹理ID。

4. **Q: 美型功能没有效果？**
   A: 美型功能依赖人脸检测，确保 `rotationMode` 设置正确，且图像中包含清晰的人脸。

