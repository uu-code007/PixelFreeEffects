# pixelFree Android API 文档

## 相关文档
- [iOS API 文档](./api_ios.md)
- [Flutter API 文档](./api_flutter.md)
- [使用文档](./doc_flutter.md)

## 类定义

```kotlin
class PixelFree
```

## 初始化与授权

### create()

初始化 PixelFree 实例。

```kotlin
fun create()
```

### auth()

授权 SDK。

```kotlin
fun auth(context: Context, data: ByteArray, size: Int)
```

**参数：**
- `context`: 应用上下文
- `data`: 授权数据
- `size`: 数据大小

### isCreate()

检查是否已初始化。

```kotlin
fun isCreate(): Boolean
```

**返回值：**
- 是否已初始化

## 图像处理

### processWithBuffer()

处理图像数据。

```kotlin
fun processWithBuffer(iamgeInput: PFImageInput)
```

**参数：**
- `iamgeInput`: 图像输入数据，包含纹理ID、图像数据等信息

### textureIdToBitmap()

将纹理转换为位图。

```kotlin
fun textureIdToBitmap(
    textureId: Int, 
    width: Int, 
    height: Int, 
    callback: (Bitmap?) -> Unit
)
```

**参数：**
- `textureId`: 纹理ID
- `width`: 宽度
- `height`: 高度
- `callback`: 回调函数，返回转换后的位图

## 美颜参数设置

### pixelFreeSetBeautyFiterParam()

设置美颜参数。

```kotlin
fun pixelFreeSetBeautyFiterParam(type: PFBeautyFilterType, value: Float)
fun pixelFreeSetBeautyFiterParam(type: PFBeautyFilterType, value: Int)
```

**参数：**
- `type`: 美颜参数类型
- `value`: 参数值

### pixelFreeSetBeautyExtend()

设置扩展美颜参数。

```kotlin
fun pixelFreeSetBeautyExtend(type: PFBeautyFilterType, value: String)
```

**参数：**
- `type`: 美颜参数类型
- `value`: 参数值

## 滤镜设置

### pixelFreeSetFilterParam()

设置滤镜参数。

```kotlin
fun pixelFreeSetFilterParam(filterName: String, value: Float)
```

**参数：**
- `filterName`: 滤镜名称
- `value`: 滤镜强度

## 资源加载

### createBeautyItemFormBundle()

加载美颜资源包。

```kotlin
fun createBeautyItemFormBundle(data: ByteArray, size: Int, type: PFSrcType)
```

**参数：**
- `data`: 资源数据
- `size`: 数据大小
- `type`: 资源类型

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

## 人脸检测

### getFaceRect()

获取人脸矩形框。

```kotlin
fun getFaceRect(): FloatArray?
```

**返回值：**
- 人脸矩形框数组 [x, y, width, height]

### getFaceCount()

获取检测到的人脸数量。

```kotlin
fun getFaceCount(): Int
```

**返回值：**
- 人脸数量

## 图像调色

### setColorGrading()

设置图像颜色分级参数。

```kotlin
fun setColorGrading(
    brightness: Float,
    contrast: Float,
    exposure: Float,
    highlights: Float,
    shadows: Float,
    saturation: Float,
    temperature: Float,
    tint: Float,
    hue: Float,
    isUse: Boolean = true
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

### addHLSFilter()

添加 HLS 滤镜。

```kotlin
fun addHLSFilter(
    keyColor: FloatArray,
    hue: Float,
    saturation: Float,
    brightness: Float,
    similarity: Float
): Int
```

**参数：**
- `keyColor`: 关键色 [R, G, B] (0-1)
- `hue`: 色相
- `saturation`: 饱和度 (0-1)
- `brightness`: 亮度 (0-1)
- `similarity`: 相似度

**返回值：**
- 滤镜句柄

### deleteHLSFilter()

删除 HLS 滤镜。

```kotlin
fun deleteHLSFilter(filterHandle: Int): Int
```

**参数：**
- `filterHandle`: 滤镜句柄

**返回值：**
- 操作结果状态码

### changeHLSFilter()

修改 HLS 滤镜参数。

```kotlin
fun changeHLSFilter(
    filterHandle: Int,
    keyColor: FloatArray,
    hue: Float,
    saturation: Float,
    brightness: Float,
    similarity: Float
): Int
```

**参数：**
- `filterHandle`: 滤镜句柄
- `keyColor`: 关键色 [R, G, B] (0-1)
- `hue`: 色相
- `saturation`: 饱和度 (0-1)
- `brightness`: 亮度 (0-1)
- `similarity`: 相似度

**返回值：**
- 操作结果状态码

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

### release()

释放资源。

```kotlin
fun release()
```