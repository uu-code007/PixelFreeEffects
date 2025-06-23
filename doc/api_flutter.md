# pixelFree Flutter API 文档

## 相关文档
- [iOS API 文档](api_ios.md)
- [Android API 文档](api_android.md)
- [使用文档](../README.md)

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  pixelfree: ^2.4.15
```

## 导入

```dart
import 'package:pixelfree/pixelfree.dart';
```

## 类定义

```dart
class Pixelfree
```

## 初始化与授权

### createWithLic()

使用授权文件初始化 SDK。在使用其他功能前必须先调用此方法。

```dart
Future<void> createWithLic(String licPath)
```

**参数：**
- `licPath`: 授权文件路径，通常放在 assets 目录下

**示例：**
```dart
final pixelfree = Pixelfree();
await pixelfree.createWithLic('assets/license.lic');
```

### isCreate()

检查 SDK 是否已初始化。

```dart
Future<bool> isCreate()
```

**返回值：**
- `true`: SDK 已初始化
- `false`: SDK 未初始化

## 资源加载

### createBeautyItemFormBundle()

加载美颜资源包。支持加载美颜、滤镜、贴纸等资源。

```dart
Future<void> createBeautyItemFormBundle(ByteData data, PFSrcType type)
```

**参数：**
- `data`: 资源数据，通常从 assets 读取
- `type`: 资源类型，可选值：
  - `PFSrcType.beauty`: 美颜资源
  - `PFSrcType.filter`: 滤镜资源
  - `PFSrcType.sticker`: 贴纸资源

**示例：**
```dart
final ByteData data = await rootBundle.load('assets/beauty.bundle');
await pixelfree.createBeautyItemFormBundle(data, PFSrcType.beauty);
```

## 美颜参数设置

### pixelFreeSetBeautyFilterParam()

设置美颜参数，如磨皮、美白、红润等。

```dart
Future<void> pixelFreeSetBeautyFilterParam(PFBeautyFiterType type, double value)
```

**参数：**
- `type`: 美颜参数类型，可选值：
  - `PFBeautyFiterType.smooth`: 磨皮
  - `PFBeautyFiterType.whiten`: 美白
  - `PFBeautyFiterType.ruddy`: 红润
  - 更多类型请参考 SDK 文档
- `value`: 参数值，范围 0.0-1.0

**示例：**
```dart
// 设置磨皮强度为 0.5
await pixelfree.pixelFreeSetBeautyFilterParam(PFBeautyFiterType.smooth, 0.5);
```

### pixelFreeSetBeautyExtend()

设置扩展美颜参数，用于特殊场景。

```dart
Future<void> pixelFreeSetBeautyExtend(PFBeautyFiterType type, String value)
```

**参数：**
- `type`: 美颜参数类型
- `value`: 参数值，JSON 格式字符串

### pixelFreeSetBeautyTypeParam()

设置美颜类型参数，用于切换不同的美颜风格。

```dart
Future<void> pixelFreeSetBeautyTypeParam(PFBeautyFiterType type, int value)
```

**参数：**
- `type`: 美颜参数类型
- `value`: 风格索引值

## 滤镜设置

### pixelFreeSetFilterParam()

设置滤镜参数，调整滤镜强度。

```dart
Future<void> pixelFreeSetFilterParam(String filterName, double value)
```

**参数：**
- `filterName`: 滤镜名称，如 "nature"、"fresh" 等
- `value`: 滤镜强度，范围 0.0-1.0

**示例：**
```dart
// 设置自然滤镜，强度为 0.7
await pixelfree.pixelFreeSetFilterParam('nature', 0.7);
```

### pixelFreeSetSticker2DFilter()

设置 2D 贴纸，如装饰物、特效等。

```dart
Future<void> pixelFreeSetSticker2DFilter(String filterName)
```

**参数：**
- `filterName`: 贴纸名称，如 "crown"、"glasses" 等

## 图像处理

### processWithBuffer()

处理图像数据，支持实时预览。这是美颜SDK的核心处理方法，用于对输入图像进行美颜处理。

```dart
Future<void> processWithBuffer(PFIamgeInput imageInput)
```

**参数：**
- `imageInput`: 图像输入数据，包含图像的所有必要信息

#### PFIamgeInput 参数详解

```dart
class PFIamgeInput {
  int textureID;        // OpenGL纹理ID，buffer模式下为0
  int width;            // 图像宽度
  int height;           // 图像高度
  Uint8List? pData0;    // 主要数据通道（Y或RGBA）
  Uint8List? pData1;    // 第二数据通道（UV或null）
  Uint8List? pData2;    // 第三数据通道（通常为null）
  int stride0;          // 第一通道行步长
  int stride1;          // 第二通道行步长
  int stride2;          // 第三通道行步长
  PFDetectFormat format;        // 图像格式
  PFRotationMode rotationMode;  // 图像旋转（用于人脸检测方向）
}
```

#### 支持的图像格式

```dart
enum PFDetectFormat {
  unknown,      // 未知格式
  rgb,          // RGB格式
  bgr,          // BGR格式
  rgba,         // RGBA格式（推荐）
  bgra,         // BGRA格式
  argb,         // ARGB格式
  abgr,         // ABGR格式
  gray,         // 灰度图
  yuvNv12,      // YUV NV12格式
  yuvNv21,      // YUV NV21格式
  yuvI420,      // YUV I420格式
  texture,      // OpenGL纹理格式
}
```

#### 旋转模式

```dart
enum PFRotationMode {
  rotation0,    // 0度旋转
  rotation90,   // 90度旋转
  rotation180,  // 180度旋转
  rotation270,  // 270度旋转
}
```

#### 使用示例

**1. RGBA格式图像处理（推荐）**

```dart
// 处理RGBA图像数据
final imageInput = PFIamgeInput(
  width: 720,
  height: 1280,
  pData0: rgbaData,        // RGBA字节数组
  pData1: null,
  pData2: null,
  stride0: 720 * 4,        // 每行字节数 = width * 4
  stride1: 0,
  stride2: 0,
  format: PFDetectFormat.rgba,
  rotationMode: PFRotationMode.rotation90,
  textureID: 0,
);

await pixelfree.processWithBuffer(imageInput);

// 获取处理后的data，源数据会被覆盖
final processedData = imageInput.pData0;
```

**2. 纹理模式处理**

```dart
// 处理OpenGL纹理
final imageInput = PFIamgeInput(
  width: 720,
  height: 1280,
  pData0: null,
  pData1: null,
  pData2: null,
  stride0: 0,
  stride1: 0,
  stride2: 0,
  format: PFDetectFormat.texture,
  rotationMode: PFRotationMode.rotation0,
  textureID: inputTextureID,  // 输入纹理ID
);

await pixelfree.processWithBuffer(imageInput);

// 获取处理后的纹理ID
final outputTextureID = imageInput.textureID;
```

**3. YUV格式处理**

```dart
// YUV NV21格式处理
final ySize = width * height;
final uvSize = width * height ~/ 2;

final yData = Uint8List.fromList(yuvData.take(ySize).toList());
final uvData = Uint8List.fromList(yuvData.skip(ySize).take(uvSize).toList());

final imageInput = PFIamgeInput(
  width: width,
  height: height,
  pData0: yData,
  pData1: uvData,
  pData2: null,
  stride0: width,
  stride1: width,
  stride2: 0,
  format: PFDetectFormat.yuvNv21,
  rotationMode: PFRotationMode.rotation90,
  textureID: 0,
);

await pixelfree.processWithBuffer(imageInput);

// 获取处理后的data，源数据会被覆盖
final processedYData = imageInput.pData0;
final processedUvData = imageInput.pData1;
```

#### 注意事项

1. **数据格式匹配**：确保 `format` 与实际的图像数据格式一致
2. **内存管理**：处理过程中SDK会修改输入数据，注意数据备份
3. **OpenGL上下文**：纹理模式需要在正确的OpenGL上下文中调用
4. **性能优化**：建议在子线程中处理，避免阻塞UI线程
5. **错误处理**：检查 `pixelfree.isCreate()` 确保SDK已正确初始化

#### 返回值说明

`processWithBuffer` 方法执行后，输入数据会被处理后的数据覆盖：
- `imageInput.pData0`：处理后的主要数据通道
- `imageInput.pData1`：处理后的第二数据通道（如果有）
- `imageInput.textureID`：处理后的OpenGL纹理ID（纹理模式下）

### processWithImage()

处理图像数据并返回处理后的纹理 ID。

```dart
Future<int> processWithImage(Uint8List imageData, int w, int h)
```

**参数：**
- `imageData`: 图像数据，RGBA 格式
- `w`: 图像宽度
- `h`: 图像高度

**返回值：**
- 处理后的纹理 ID，可用于 OpenGL 渲染

### processWithTextrueID()

处理纹理数据，适用于 OpenGL 渲染场景。

```dart
Future<int?> processWithTextrueID(int textrueID, int w, int h)
```

**参数：**
- `textrueID`: 输入纹理 ID
- `w`: 纹理宽度
- `h`: 纹理高度

**返回值：**
- 处理后的纹理 ID

### processWithImageToByteData()

处理图像数据并返回处理后的字节数据。

```dart
Future<ByteData?> processWithImageToByteData(Uint8List imageData, int width, int height)
```

**参数：**
- `imageData`: 图像数据
- `width`: 图像宽度
- `height`: 图像高度

**返回值：**
- 处理后的字节数据，可用于保存图片或显示

## HLS 滤镜操作

### pixelFreeAddHLSFilter()

添加 HLS 滤镜，用于调整特定颜色的色相、亮度和饱和度。

```dart
Future<int> pixelFreeAddHLSFilter(PFHLSFilterParams params)
```

**参数：**
- `params`: HLS 滤镜参数，包含：
  - `keyColor`: 关键色 [R, G, B] (0-1)
  - `hue`: 色相
  - `saturation`: 饱和度 (0-1)
  - `brightness`: 亮度 (0-1)
  - `similarity`: 相似度

**返回值：**
- 滤镜句柄，用于后续修改或删除

### pixelFreeDeleteHLSFilter()

删除 HLS 滤镜。

```dart
Future<void> pixelFreeDeleteHLSFilter(int handle)
```

**参数：**
- `handle`: 滤镜句柄，由 `pixelFreeAddHLSFilter` 返回

### pixelFreeChangeHLSFilter()

修改 HLS 滤镜参数。

```dart
Future<int> pixelFreeChangeHLSFilter(int handle, PFHLSFilterParams params)
```

**参数：**
- `handle`: 滤镜句柄
- `params`: 新的滤镜参数

**返回值：**
- 操作结果状态码

## 图像调色

### pixelFreeSetColorGrading()

设置图像颜色分级参数，用于整体调色。

```dart
Future<int> pixelFreeSetColorGrading(PFImageColorGrading params)
```

**参数：**
- `params`: 颜色分级参数，包含：
  - `brightness`: 亮度 (-1.0 到 1.0)
  - `contrast`: 对比度 (0.0 到 4.0)
  - `exposure`: 曝光度 (-10.0 到 10.0)
  - `highlights`: 高光 (0 到 1)
  - `shadows`: 阴影 (0 到 1)
  - `saturation`: 饱和度 (0.0 到 2.0)
  - `temperature`: 色温
  - `tint`: 色调
  - `hue`: 色相 (0-360)

**返回值：**
- 操作结果状态码

## 工具方法

### jsonStringToMap()

将 JSON 字符串转换为 Map，用于解析配置数据。

```dart
Map<String, dynamic> jsonStringToMap(String jsonString)
```

**参数：**
- `jsonString`: JSON 字符串

**返回值：**
- 转换后的 Map

## 资源释放

### release()

释放 SDK 资源，在不需要使用 SDK 时调用。

```dart
Future<void> release()
```

**示例：**
```dart
// 在 dispose 中调用
@override
void dispose() {
  pixelfree.release();
  super.dispose();
}
```