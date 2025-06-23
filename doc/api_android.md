# pixelFree Android API 文档

## 相关文档
- [iOS API 文档](api_ios.md)
- [Flutter API 文档](api_flutter.md)
- [使用文档](../README.md)

## 安装

### Maven 导入

在 `build.gradle` 中添加依赖：

```gradle
dependencies {
    implementation 'io.github.uu-code007:lib_pixelFree:2.4.9'
}
```

### 手动导入

将 SDK AAR 文件添加到项目中，并在 `build.gradle` 中引用：

```gradle
dependencies {
    implementation files('libs/lib_pixelFree.aar')
}
```

## 导入

```kotlin
import com.hapi.pixelfree.*
```

## 类定义

```kotlin
class PixelFree
```

## 初始化与授权

### create()

初始化 SDK。在使用其他功能前必须先调用此方法。

```kotlin
fun create()
```

**示例：**
```kotlin
val pixelFree = PixelFree()
pixelFree.create()
```

### auth()

使用授权文件进行授权。

```kotlin
fun auth(context: Context, authData: ByteArray, size: Int)
```

**参数：**
- `context`: 应用上下文
- `authData`: 授权文件数据
- `size`: 数据大小

**示例：**
```kotlin
val authData = pixelFree.readBundleFile(context, "pixelfreeAuth.lic")
pixelFree.auth(context, authData, authData.size)
```

### isCreate()

检查 SDK 是否已初始化。

```kotlin
fun isCreate(): Boolean
```

**返回值：**
- `true`: SDK 已初始化
- `false`: SDK 未初始化

## 资源加载

### createBeautyItemFormBundle()

加载美颜资源包。支持加载美颜、滤镜、贴纸等资源。

```kotlin
fun createBeautyItemFormBundle(data: ByteArray, size: Int, type: PFSrcType)
```

**参数：**
- `data`: 资源数据，通常从 assets 读取
- `size`: 数据大小
- `type`: 资源类型，可选值：
  - `PFSrcType.PFSrcTypeFilter`: 滤镜资源
  - `PFSrcType.PFSrcTypeAuthFile`: 授权文件
  - `PFSrcType.PFSrcTypeStickerFile`: 贴纸资源

**示例：**
```kotlin
val filterData = pixelFree.readBundleFile(context, "filter_model.bundle")
pixelFree.createBeautyItemFormBundle(filterData, filterData.size, PFSrcType.PFSrcTypeFilter)
```

### readBundleFile()

读取资源文件。

```kotlin
fun readBundleFile(context: Context, fileName: String): ByteArray
```

**参数：**
- `context`: 应用上下文
- `fileName`: 文件名

**返回值：**
- 文件数据

## 美颜参数设置

### pixelFreeSetBeautyFiterParam()

设置美颜参数，如磨皮、美白、红润等。

```kotlin
fun pixelFreeSetBeautyFiterParam(key: Int, value: Float)
```

**参数：**
- `key`: 美颜参数类型，可选值：
  - `PFBeautyFiterTypeFace_EyeStrength`: 大眼
  - `PFBeautyFiterTypeFace_thinning`: 瘦脸
  - `PFBeautyFiterTypeFaceBlurStrength`: 磨皮
  - `PFBeautyFiterTypeFaceWhitenStrength`: 美白
  - `PFBeautyFiterTypeFaceRuddyStrength`: 红润
  - 更多类型请参考 SDK 文档
- `value`: 参数值，范围 0.0-1.0

**示例：**
```kotlin
// 设置磨皮强度为 0.5
pixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterTypeFaceBlurStrength, 0.5f)
```

### pixelFreeSetBeautyFiterParam()

设置滤镜参数，调整滤镜强度。

```kotlin
fun pixelFreeSetBeautyFiterParam(filterName: String, value: Float)
```

**参数：**
- `filterName`: 滤镜名称，如 "heibai1"、"nature" 等
- `value`: 滤镜强度，范围 0.0-1.0

**示例：**
```kotlin
// 设置黑白滤镜，强度为 0.7
pixelFree.pixelFreeSetBeautyFiterParam("heibai1", 0.7f)
```

## 图像处理

### processWithBuffer()

处理图像数据，支持实时预览。这是美颜SDK的核心处理方法，用于对输入图像进行美颜处理。

```kotlin
fun processWithBuffer(imageInput: PFImageInput)
```

**参数：**
- `imageInput`: 图像输入数据，包含图像的所有必要信息

#### PFImageInput 参数详解

```kotlin
class PFImageInput {
    var textureID: Int = 0           // OpenGL纹理ID，buffer模式下为0
    var wigth: Int = 0               // 图像宽度
    var height: Int = 0              // 图像高度
    var p_data0: ByteArray? = null   // 主要数据通道（Y或RGBA）
    var p_data1: ByteArray? = null   // 第二数据通道（UV或null）
    var p_data2: ByteArray? = null   // 第三数据通道（通常为null）
    var stride_0: Int = 0            // 第一通道行步长
    var stride_1: Int = 0            // 第二通道行步长
    var stride_2: Int = 0            // 第三通道行步长
    var format: PFDetectFormat       // 图像格式
    var rotationMode: PFRotationMode // 图像旋转（用于人脸检测方向）
}
```

#### 支持的图像格式

```kotlin
enum class PFDetectFormat(val intType: Int) {
    PFFORMAT_UNKNOWN(0),           // 未知格式
    PFFORMAT_IMAGE_RGB(1),         // RGB格式
    PFFORMAT_IMAGE_BGR(2),         // BGR格式
    PFFORMAT_IMAGE_RGBA(3),        // RGBA格式（推荐）
    PFFORMAT_IMAGE_BGRA(4),        // BGRA格式
    PFFORMAT_IMAGE_ARGB(5),        // ARGB格式
    PFFORMAT_IMAGE_ABGR(6),        // ABGR格式
    PFFORMAT_IMAGE_GRAY(7),        // 灰度图
    PFFORMAT_IMAGE_YUV_NV12(8),    // YUV NV12格式
    PFFORMAT_IMAGE_YUV_NV21(9),    // YUV NV21格式
    PFFORMAT_IMAGE_YUV_I420(10),   // YUV I420格式
    PFFORMAT_IMAGE_TEXTURE(11),    // OpenGL纹理格式
}
```

#### 旋转模式

```kotlin
enum class PFRotationMode(val intType: Int) {
    PFRotationMode0(0),    // 0度旋转
    PFRotationMode90(1),   // 90度旋转
    PFRotationMode180(2),  // 180度旋转
    PFRotationMode270(3),  // 270度旋转
}
```

#### 使用示例

**1. RGBA格式图像处理（推荐）**

```kotlin
// 摄像头实时处理示例
override fun onProcessFrame(frame: VideoFrame): VideoFrame {
    if (pixelFree.isCreate()) {
        val pxInput = PFImageInput().apply {
            wigth = frame.width
            height = frame.height
            p_data0 = frame.data
            p_data1 = frame.data
            p_data2 = frame.data
            stride_0 = frame.rowStride
            stride_1 = frame.rowStride
            stride_2 = frame.rowStride
            format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
            rotationMode = PFRotationMode.PFRotationMode90
        }
        
        // 执行美颜处理
        pixelFree.processWithBuffer(pxInput)
        
        // 获取处理后的data，源数据会被覆盖
        val processedData = pxInput.p_data0
    }
    return super.onProcessFrame(frame)
}
```

**2. 静态图像处理**

```kotlin
// 处理Bitmap图像
val pxInput = PFImageInput().apply {
    wigth = bitmap.width
    height = bitmap.height
    p_data0 = rgbaData        // RGBA字节数组
    p_data1 = null
    p_data2 = null
    stride_0 = rowBytes       // 每行字节数 = width * 4
    stride_1 = 0
    stride_2 = 0
    textureID = 0
    format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
    rotationMode = PFRotationMode.PFRotationMode0
}

pixelFree.processWithBuffer(pxInput)

// 获取处理后的data，源数据会被覆盖
val processedData = pxInput.p_data0
```

**3. YUV格式处理**

```kotlin
// YUV NV21格式处理
val pxInput = PFImageInput().apply {
    wigth = width
    height = height
    
    // YUV数据分离
    val ySize = width * height
    val uvSize = width * height / 2
    val yData = ByteArray(ySize)
    val uvData = ByteArray(uvSize)
    
    System.arraycopy(yuvData, 0, yData, 0, ySize)
    System.arraycopy(yuvData, ySize, uvData, 0, uvSize)
    
    p_data0 = yData
    p_data1 = uvData
    p_data2 = null
    stride_0 = width
    stride_1 = width
    stride_2 = 0
    format = PFDetectFormat.PFFORMAT_IMAGE_YUV_NV21
    rotationMode = PFRotationMode.PFRotationMode90
}

pixelFree.processWithBuffer(pxInput)

// 获取处理后的data，源数据会被覆盖
val processedYData = pxInput.p_data0
val processedUvData = pxInput.p_data1
```

**4. OpenGL纹理处理**

```kotlin
// 纹理模式处理
val pxInput = PFImageInput().apply {
    wigth = width
    height = height
    p_data0 = null
    p_data1 = null
    p_data2 = null
    stride_0 = 0
    stride_1 = 0
    stride_2 = 0
    format = PFDetectFormat.PFFORMAT_IMAGE_TEXTURE
    rotationMode = PFRotationMode.PFRotationMode0
    textureID = inputTextureID  // 输入纹理ID
}

pixelFree.processWithBuffer(pxInput)
val outputTextureID = pxInput.textureID  // 输出纹理ID
```

#### 注意事项

1. **数据格式匹配**：确保 `format` 与实际的图像数据格式一致
2. **内存管理**：处理过程中SDK会修改输入数据，注意数据备份
3. **OpenGL上下文**：纹理模式需要在正确的OpenGL上下文中调用
4. **性能优化**：建议在子线程中处理，避免阻塞UI线程
5. **错误处理**：检查 `pixelFree.isCreate()` 确保SDK已正确初始化

#### 返回值说明

`processWithBuffer` 方法执行后，输入数据会被处理后的数据覆盖：
- `pxInput.p_data0`：处理后的主要数据通道
- `pxInput.p_data1`：处理后的第二数据通道（如果有）
- `pxInput.textureID`：处理后的OpenGL纹理ID（纹理模式下）

## 人脸检测

### pixelFreeGetFaceRect()

获取人脸矩形框。

```kotlin
fun pixelFreeGetFaceRect(faceRect: FloatArray)
```

**参数：**
- `faceRect`: 输出人脸矩形框数组 [x, y, width, height]

### getPixelFreeFaceNum()

获取检测到的人脸数量。

```kotlin
fun getPixelFreeFaceNum(): Int
```

**返回值：**
- 人脸数量

## 图像调色

### pixelFreeSetColorGrading()

设置图像颜色分级参数。

```kotlin
fun pixelFreeSetColorGrading(
    brightness: Float,
    contrast: Float,
    exposure: Float,
    highlights: Float,
    shadows: Float,
    saturation: Float,
    temperature: Float,
    tint: Float,
    hue: Float,
    isUse: Boolean
): Int
```

**参数：**
- `brightness`: 亮度 (-1.0 到 1.0)
- `contrast`: 对比度 (0.0 到 4.0)
- `exposure`: 曝光度 (-10.0 到 10.0)
- `highlights`: 高光 (0 到 1)
- `shadows`: 阴影 (0 到 1)
- `saturation`: 饱和度 (0.0 到 2.0)
- `temperature`: 色温
- `tint`: 色调
- `hue`: 色相 (0-360)
- `isUse`: 是否启用

**返回值：**
- 操作结果状态码

## HLS 滤镜操作

### pixelFreeAddHLSFilter()

添加 HLS 滤镜。

```kotlin
fun pixelFreeAddHLSFilter(params: PFHLSFilterParams): Int
```

**参数：**
- `params`: HLS 滤镜参数

**返回值：**
- 滤镜句柄

### pixelFreeDeleteHLSFilter()

删除 HLS 滤镜。

```kotlin
fun pixelFreeDeleteHLSFilter(handle: Int): Int
```

**参数：**
- `handle`: 滤镜句柄

**返回值：**
- 操作结果状态码

### pixelFreeChangeHLSFilter()

修改 HLS 滤镜参数。

```kotlin
fun pixelFreeChangeHLSFilter(handle: Int, params: PFHLSFilterParams): Int
```

**参数：**
- `handle`: 滤镜句柄
- `params`: 新的滤镜参数

**返回值：**
- 操作结果状态码

## 工具方法

### textureIdToBitmap()

将纹理ID转换为Bitmap。

```kotlin
fun textureIdToBitmap(textureId: Int, width: Int, height: Int, callback: (Bitmap?) -> Unit)
```

**参数：**
- `textureId`: 纹理ID
- `width`: 宽度
- `height`: 高度
- `callback`: 回调函数，返回转换后的Bitmap

## 资源释放

### release()

释放 SDK 资源，在不需要使用 SDK 时调用。

```kotlin
fun release()
```

**示例：**
```kotlin
// 在 onDestroy 中调用
override fun onDestroy() {
    pixelFree.release()
    super.onDestroy()
}
```

## 其他功能

### getVersion()

获取 SDK 版本号。

```kotlin
fun getVersion(): String
```

**返回值：**
- 版本号字符串

### setLogLevel()

设置日志级别。

```kotlin
fun setLogLevel(level: Int, logPath: String)
```

**参数：**
- `level`: 日志级别
- `logPath`: 日志文件路径