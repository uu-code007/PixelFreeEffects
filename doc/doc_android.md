# PixelFree Android 接入指南

[项目概览](../README.md) · [Android API](./api_android.md) · [iOS 接入](./doc_iOS.md)

本文对照仓库当前 [lib_pixelFree.aar](../SMBeautyEngine_andriod/pixelfree_android_demo/sdk-aar/lib_pixelFree.aar) 的公开 Kotlin/Java 接口编写。示例使用 Kotlin；方法名和枚举均以当前 AAR 为准。

## 1. 集成交付包

| 项目 | 当前交付说明 |
| :--- | :--- |
| 系统要求 | AAR 清单声明最低 API 19；[Demo](../SMBeautyEngine_andriod/pixelfree_android_demo) 为 API 21 / Android 5.0 起，应用依赖可能要求更高版本 |
| ABI | `arm64-v8a`、`armeabi-v7a`，当前包不含 x86/x86_64 |
| 包名 | `com.hapi.pixelfree` |
| 图像输入 | `PFImageInput`，字段 `wigth` 为公开接口的实际拼写 |
| 授权 | 使用匹配应用包名、平台、有效期和模块的 `pixelfreeAuth.lic` |

将当前 AAR 放入应用模块的 `libs` 目录，并在模块级 `build.gradle` 中声明：

```groovy
dependencies {
    implementation files('libs/lib_pixelFree.aar')
}
```

也可复用 Demo 的 `sdk-aar` 模块。只选择一种依赖方式，避免同时引用旧 Maven 包和本地 AAR。不要将旧文档中的固定 Maven 版本当作本文新版接口的交付版本。

当前 AAR 内含 `filter_model.bundle`、`body_model.bundle`、`skin_src.bundle` 和原生库。应用仍需按功能调用资源加载接口，并把自己的授权文件放入 `src/main/assets`。不要在应用 assets 中保留与 AAR 同名但版本不匹配的模型。

| 资源 | 对应类型／接口 |
| :--- | :--- |
| `pixelfreeAuth.lic` | `auth(context, data, size)` |
| `filter_model.bundle` | `PFSrcType.PFSrcTypeFilter` |
| `body_model.bundle` | `PFSrcType.PFSrcTypeHumanProcessor` |
| `skin_src.bundle` | `PFSrcType.PFSrcTypeSkinSrc` |
| 美妆 bundle | `PFSrcType.PFSrcTypeMakeup` |

相机采集、权限申请、预览和编码由应用负责。发布前检查合并后的 manifest、ABI 打包结果及 AAR 自带的混淆配置是否正确应用。

## 2. 最小 RGBA 处理会话

下面的会话使用 SDK 管理的 GL 调度。应用在整个处理会话内复用一个对象，将帧处理放入工作队列，并将参数更新和关闭与处理操作串行化。`processRgba` 会修改传入数组；图片编辑时传入原图副本。

```kotlin
import android.content.Context
import com.hapi.pixelfree.*
import java.io.Closeable

class BeautySession(context: Context) : Closeable {
    private val engine = PixelFree()
    private var closed = false

    init {
        engine.create()
        try {
            check(engine.isCreate()) { "PixelFree instance was not created" }
            val license = requireNotNull(engine.readBundleFile(context, "pixelfreeAuth.lic"))
            engine.auth(context, license, license.size)
            val model = requireNotNull(engine.readBundleFile(context, "filter_model.bundle"))
            engine.createBeautyItemFormBundle(model, model.size, PFSrcType.PFSrcTypeFilter)
            engine.setDetectMode(PFFaceDetectMode.PF_FACE_DETECT_MODE_VIDEO)
            engine.pixelFreeSetBeautyFiterParam(
                PFBeautyFilterType.PFBeautyFilterTypeFaceBlurStrength, 0.5f
            )
        } catch (failure: Throwable) {
            engine.release()
            throw failure
        }
    }

    fun processRgba(
        pixels: ByteArray, width: Int, height: Int,
        rotation: PFRotationMode = PFRotationMode.PFRotationMode0
    ) {
        check(!closed)
        require(width > 0 && height > 0)
        require(pixels.size.toLong() == width.toLong() * height * 4)
        val input = PFImageInput().also {
            it.wigth = width
            it.height = height
            it.p_data0 = pixels
            it.stride_0 = width * 4
            it.format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
            it.rotationMode = rotation
        }
        engine.processWithBuffer(input)
        val error = engine.getLastErrorCode()
        check(error == 0 && input.textureID > 0) { "PixelFree error: $error" }
    }

    override fun close() {
        if (!closed) {
            engine.release()
            closed = true
        }
    }
}
```

`processWithBuffer` 返回 `Unit`，不能把它赋给纹理 ID 或状态码变量。输出写入输入平面，同时更新 `input.textureID`；该纹理只能在正确的 GL 上下文中使用。`isCreate()` 只表示实例存在，不表示授权验证或所有模块开通成功。

示例用 `check` 展示失败检测。业务中应根据错误码决定提示、降级、重试或停止处理，而不是让异常直接终止相机页面。

## 3. YUV 输入与行步长

以紧凑 NV21 为例，构造独立的 Y、VU 平面：

```kotlin
fun makeNv21Input(
    bytes: ByteArray, width: Int, height: Int, rotation: PFRotationMode
): PFImageInput {
    require(width > 0 && height > 0 && width % 2 == 0 && height % 2 == 0)
    val ySize = width.toLong() * height
    require(bytes.size.toLong() == ySize + ySize / 2)
    val yEnd = ySize.toInt()
    return PFImageInput().also {
        it.wigth = width
        it.height = height
        it.p_data0 = bytes.copyOfRange(0, yEnd)
        it.p_data1 = bytes.copyOfRange(yEnd, bytes.size)
        it.stride_0 = width
        it.stride_1 = width
        it.format = PFDetectFormat.PFFORMAT_IMAGE_YUV_NV21
        it.rotationMode = rotation
    }
}
```

将结果传给 `processWithBuffer`。由于此函数复制了平面，输出在返回对象的 `p_data0`／`p_data1` 中，不会自动写回原始 `bytes`；若编码器需要连续 NV21，请按输出平面重新拼接。

相机提供的 `YUV_420_888` 可能含非紧凑行步长与像素步长，不能直接当作上例的 NV21。应先按采集 API 的实际布局转换，或使用经过验证的纹理路径。`PFDetectFormat` 中有某个枚举值不代表所有处理入口都支持它；独立分割的格式限制见 [API](./api_android.md)。

## 4. 接入应用已有的 GL 渲染线程

对已有 EGL 上下文的预览／RTC 管线，选择一套一致的线程模式：

| 模式 | 适用方式 |
| :--- | :--- |
| SDK 调度 | `create()` 与普通处理接口；SDK 负责将相关操作调度到其 GL 队列 |
| 绑定应用渲染队列 | 用 `setRenderThreadDispatcher(ownerThread, dispatcher)` 绑定真实渲染线程；普通接口通过该队列运行 |
| 调用方直接执行 | 当前线程已有有效 EGL 上下文，使用 `createOnCurrentGLThread()`、`processWithBufferOnCurrentGLThread(...)` 及对应直接调用方法 |

下面函数只用于已经创建、授权、加载资源的“调用方直接执行”模式，输入必须是在当前 GL 上下文可访问的二维纹理。

```kotlin
fun processCurrentTexture(engine: PixelFree, texture: Int, width: Int, height: Int): Int {
    require(texture > 0 && width > 0 && height > 0)
    val input = PFImageInput().also {
        it.wigth = width
        it.height = height
        it.textureID = texture
        it.format = PFDetectFormat.PFFORMAT_IMAGE_TEXTURE
        it.rotationMode = PFRotationMode.PFRotationMode0
    }
    engine.processWithBufferToTextureOnCurrentGLThread(input)
    val error = engine.getLastErrorCodeOnCurrentGLThread()
    check(error == 0 && input.textureID > 0) { "PixelFree error: $error" }
    return input.textureID
}
```

`ToTexture` 路径输出 SDK 纹理，不执行最终 CPU／输入纹理回写或最终 GPU 等待。调用方必须在同一上下文中、下一次处理或 GL 资源释放前消费该纹理，跨上下文使用还需正确共享和同步。它不承诺检测阶段完全没有读回开销。需要常规回写时使用不带 `ToTexture` 的入口。

不要把相机 OES 纹理、Vulkan 句柄或其他上下文的纹理 ID 当作普通二维纹理直接使用。切换自有离屏 GL 与应用 GL 时，结合 `prepareForExternalGL()`、`releaseGLResources()` 管理旧资源；详见 [线程与生命周期 API](./api_android.md)。

## 5. 扩展功能与图片工作流

| 需求 | 当前入口 |
| :--- | :--- |
| 内置滤镜 | `pixelFreeSetFilterParam(name, intensity)` |
| 外部 LUT | `setExternalFilter(path, intensity, enabled)` |
| 专业调色 | `setColorGrading(PFColorGradingParams(...))`；随下一次正常处理自动应用 |
| 肤色 | 加载 `skin_src.bundle` 后 `setSkinToneFilter(...)` |
| 美体 | 加载 `body_model.bundle` 后 `pixelFreeSetBodyBeautyParam(...)` |
| 独立检测和逐人编辑 | `detectFacesWithBuffer(...)`、`detectBodiesWithBuffer(...)`、`processWithBufferAndEffects(...)` |
| 智能分割 | 查询 `getSegmentationAvailability()` 后调用 `segmentWithBuffer(...)` |
| 参考图仿色 | `processColorTransfer(...)`；独立于普通美颜／调色 |

图片统一调节使用 `PF_FACE_DETECT_MODE_IMAGE`，每次从原图副本渲染；换图或方向变化后 `resetDetectState()`。逐人编辑先检测并保留快照，在同一引擎中从原图工作副本重渲染。人脸／人体快照用完调用 `close()`，再释放引擎；不要为每次滑杆更新重新创建整个引擎。

## 6. 结束会话与排查

先停止提交新帧，排空业务队列，再关闭快照和引擎。直接 GL 模式使用 `releaseOnCurrentGLThread()`；仅重建图形资源时使用 `releaseGLResourcesOnCurrentGLThread()`，保留实例、授权、资源和参数。需要等待 SDK 调度返回的调用，不应与正在等待它的渲染线程相互阻塞。

| 现象 | 优先检查 |
| :--- | :--- |
| 找不到方法或枚举 | 是否实际引用当前 AAR，是否残留旧 Maven 依赖，是否误写 `Filter`／`Fiter` |
| 原生库无法加载 | 应用 ABI 是否与 AAR 中的 arm64-v8a／armeabi-v7a 匹配 |
| 无效果或被停止渲染 | 授权、资源、检测结果和 `getLastErrorCode()` |
| 花屏／颜色偏差 | RGBA/BGRA 顺序、YUV 平面顺序、stride、旋转和纹理类型 |
| 黑屏或偶发纹理错误 | GL 上下文、线程归属、输出纹理生命周期和跨上下文同步 |
| 图片越调越变形 | 是否把已经处理的结果再次作为输入 |
| 分割失败 | 可用类型位、对应授权、CPU 平面和支持格式，读取异常的 `errorCode` |

更多参数、快照、分割与仿色示例见 [Android API](./api_android.md)。



