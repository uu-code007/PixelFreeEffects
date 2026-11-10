# PixelFree Android API 文档

[Android 接入指南](./doc_android.md) · [iOS API](./api_iOS.md) · [项目概览](../README.md)

本文以仓库当前 [lib_pixelFree.aar](../SMBeautyEngine_andriod/pixelfree_android_demo/sdk-aar/lib_pixelFree.aar) 的公开接口为准。代码使用 Kotlin 和 `import com.hapi.pixelfree.*`。先按接入指南创建、授权并加载资源，再调用下列接口；Kotlin 的可空类型和默认参数应以当前 AAR 元数据为准。

## 1. 初始化、线程与生命周期

| 接口 | 返回与用途 |
| :--- | :--- |
| `create()` | `Unit`，创建实例，普通接口使用 SDK 自有或已绑定的 GL 调度 |
| `createOnCurrentGLThread()` | `Unit`，在调用方当前有效 EGL 上下文中创建 |
| `auth(context: Context, data: ByteArray, size: Int)` | `Unit`，加载应用授权，size 为实际字节数 |
| `isCreate()` | `Boolean`，只表示实例存在，不表示所有功能已授权 |
| `hasOwnedGL()` | `Boolean`，查询是否使用 SDK 自有 GL |
| `getCurrentGlContext()` | `EGLContext?`，取得当前引擎上下文；取得引用不代表调用线程已绑定它 |
| `setRenderThreadDispatcher(dispatcher: ((Runnable) -> Unit)?)` | 绑定／清除外部渲染任务调度 |
| `setRenderThreadDispatcher(ownerThread: Thread, dispatcher: (Runnable) -> Unit)` | 显式指定渲染线程和调度器；调度器必须在该线程执行 Runnable |
| `prepareForExternalGL()` | 从 SDK 自有离屏 GL 切换到外部 GL 前处理旧图形资源，保留实例与加载状态 |
| `releaseGLResources()` / `releaseGLResourcesOnCurrentGLThread()` | 只释放 GL 资源，保留实例、授权、模型和参数；下次处理重新初始化图形资源 |
| `release()` / `releaseOnCurrentGLThread()` | 结束整个会话，释放引擎；直接版本在所属上下文线程执行 |
| `setDetectMode(mode: PFFaceDetectMode)` | IMAGE 或 VIDEO 模式 |
| `resetDetectState()` | 换图／方向变化后使缓存失效，保留调色设置 |

同一引擎的输入、参数、资源与销毁必须串行管理。普通处理接口会等待相应处理完成；部分设置通过队列调度，不应假设所有设置都在当前调用线程执行。不要阻塞渲染线程同时等待它完成另一个调度任务。

当前提供的直接调用变体包括：

| 分组 | `OnCurrentGLThread` 方法 |
| :--- | :--- |
| 基础状态 | `setDetectModeOnCurrentGLThread`、`resetDetectStateOnCurrentGLThread`、`setConsoleLogEnabledOnCurrentGLThread` |
| 资源／效果 | `createBeautyItemFormBundleOnCurrentGLThread`、`pixelFreeSetBeautyFiterParamOnCurrentGLThread`（Float）、`pixelFreeSetBeautyExtendOnCurrentGLThread`、`pixelFreeSetBodyBeautyParamOnCurrentGLThread`、`pixelFreeSetFilterParamOnCurrentGLThread` |
| 滤镜／调色 | `setExternalFilterOnCurrentGLThread`、`clearExternalFilterOnCurrentGLThread`、`setColorGradingOnCurrentGLThread`、`resetColorGradingOnCurrentGLThread`、`processColorTransferOnCurrentGLThread` |
| 检测查询 | `getFaceCountOnCurrentGLThread`、`getFaceRectsOnCurrentGLThread`、`getFaceIdsOnCurrentGLThread`、`getFaceLandmarks168OnCurrentGLThread`、`hasFaceOnCurrentGLThread`、`hasHumanOnCurrentGLThread`、`getLastErrorCodeOnCurrentGLThread` |
| 人体 | `getHumanCountOnCurrentGLThread`、`getHumanInfoOnCurrentGLThread`、`getHumanRectsOnCurrentGLThread`、`setBodyBeautyTargetIndexOnCurrentGLThread`、`getBodyBeautyTargetIndexOnCurrentGLThread`、`getBodyLongLegControlOnCurrentGLThread`、`setBodyLongLegControlOnCurrentGLThread`、`setHumanSegmentationEnabledOnCurrentGLThread`、`getHumanSegmentationResultOnCurrentGLThread` |

图像处理与快照的直接调用变体见后文。不是所有普通方法都有同名直接版本；不要自行拼接不存在的 API 名称。人体独立检测虽提供带该后缀的方法，但本身是 CPU 操作，不要求 GL。

## 2. 资源与诊断

| 接口 | 约定 |
| :--- | :--- |
| `readBundleFile(context: Context, fileName: String): ByteArray?` | 读取 assets，失败返回 null，使用前检查 |
| `createBeautyItemFormBundle(data: ByteArray, size: Int, type: PFSrcType)` | `Unit`；配套类型加载资源，调用前验证非空和长度 |
| `getLastErrorCode(): Int` | 最近一次设置／渲染错误，`0` 正常；不是所有独立接口的错误通道 |
| `getVersion(): String` | SDK 运行时版本 |
| `setLogLevel(level: Int, logPath: String)` | 设置日志等级与应用可写的日志路径 |
| `setConsoleLogEnabled(enabled: Boolean)` | 控制台日志全局开关 |

资源类型为 `PFSrcTypeFilter`、`PFSrcTypeAuthFile`、`PFSrcTypeStickerFile`、`PFSrcTypeMakeup`、`PFSrcTypeHumanProcessor`、`PFSrcTypeSkinSrc`，均使用 `PFSrcType.` 前缀。通常通过 `auth` 加载授权，其他资源按功能显式加载。

```kotlin
import android.content.Context
import com.hapi.pixelfree.*

fun loadBodyResources(engine: PixelFree, context: Context) {
    val data = requireNotNull(engine.readBundleFile(context, "body_model.bundle"))
    require(data.isNotEmpty())
    engine.createBeautyItemFormBundle(data, data.size, PFSrcType.PFSrcTypeHumanProcessor)
    val error = engine.getLastErrorCode()
    check(error == 0) { "PixelFree resource error: $error" }
}
```

当前 AAR 自带基础、人体、肤色资源，但仍需加载。路径型素材接口需要实际文件路径；打包在 APK assets 内的路径不能直接当作文件系统路径，应按需要复制到应用可读目录，或用字节加载入口。

## 3. 图像输入与输出

`PFImageInput` 为可变输入对象。不同帧不能并发复用同一对象；在调用结束前保持数组不变。

| 字段 | 类型／含义 |
| :--- | :--- |
| `wigth`, `height` | `Int`，图像宽高；`wigth` 为实际拼写 |
| `textureID` | `Int`，纹理路径的输入或处理后的输出纹理 |
| `p_data0`, `p_data1`, `p_data2` | `ByteArray?`，根据格式提供像素平面，未使用平面为 null |
| `stride_0`, `stride_1`, `stride_2` | `Int`，对应平面的每行字节数 |
| `format` | `PFDetectFormat`，明确指定与数据一致的格式 |
| `rotationMode` | `PFRotationMode`，0／90／180／270 方向枚举 |

RGBA 示例和双平面 NV21 打包方式见 [接入指南](./doc_android.md)。相机 YUV 的 rowStride 与 pixelStride 必须正确转换；不能把所有平面指向同一数组来代替布局描述。

| 方法 | 返回／副作用 |
| :--- | :--- |
| `processWithBuffer(imageInput: PFImageInput)` | `Unit`；常规处理回写输入像素并更新 `textureID`，包括已配置的调色 |
| `processWithBufferOnCurrentGLThread(imageInput: PFImageInput)` | 同上，要求当前有效 EGL 上下文 |
| `processWithBufferToTexture(imageInput: PFImageInput)` | `Unit`；更新 SDK 输出纹理，不进行最终 CPU／输入纹理回写和最终 GPU 等待，CPU 平面只读 |
| `processWithBufferToTextureOnCurrentGLThread(imageInput: PFImageInput)` | 同上，直接在当前 GL 上下文执行 |

`ToTexture` 输出必须在同一上下文、下一次处理或释放 GL 资源前使用。不要把其 `p_data0` 当作已处理输出；需要像素回写时使用普通入口。检查 `textureID` 与 `getLastErrorCode()`，尤其不能把 `Unit` 返回值当作成功码。纹理输入不等于任意 OES／跨 API 句柄；输入须符合当前包装接口要求。

`PFDetectFormat` 定义 RGB、BGR、RGBA、BGRA、ARGB、ABGR、GRAY、NV12、NV21、I420、TEXTURE 等类型；各处理入口的支持范围并不相同，独立分割的明确限制见第 8 节。

## 4. 美颜、美型、美妆与滤镜

| 接口 | 参数与语义 |
| :--- | :--- |
| `pixelFreeSetBeautyFiterParam(type: PFBeautyFilterType, value: Float)` | 数值效果，通常 `0～1`；双向几何项常以 `0.5` 中性 |
| `pixelFreeSetBeautyFiterParam(type: PFBeautyFilterType, value: Int)` | 整数配置，例如 `PFBeautyFilterTypeOneKey`；不是滤镜名重载 |
| `pixelFreeSetFilterParam(filterName: String, value: Float)` | 内置滤镜名称和强度，名称以交付素材为准 |
| `pixelFreeSetBeautyExtend(type: PFBeautyFilterType, value: String)` | 扩展字符串配置，仅使用与交付版本匹配的公开扩展约定，不自行猜测字段 |
| `setExternalFilter(imagePath: String, intensity: Float, enabled: Boolean = true): Int` | 本地外部 LUT，256×256、8×8 分块，强度 `0～1` |
| `clearExternalFilter(): Int` | 清除外部 LUT |
| `setSkinToneFilter(type: Int, intensity: Float, coldWarmIntensity: Float, enabled: Boolean = true): Int` | 需先加载肤色资源；type：0 自然、1 白皙、2 粉白、3 小麦色、4 美黑 |
| `clearSkinToneFilter(): Int` | 关闭肤色调整 |
| `setMakeupPath(makeupJsonPath: String): Int` | 加载实际本地美妆配置路径；资源包可通过 `PFSrcTypeMakeup` 加载 |
| `clearMakeup(): Int` | 清除美妆 |
| `setMakeupPartDegree(part: PFMakeupPart, degree: Float): Int` | 程度 `0～1`，与素材程度叠乘 |
| `setStickerWithPath(stickerPath: String)` | `Unit`，贴纸 bundle／资源本地路径 |
| `setMakeupFaceOccuEnabled(enabled: Boolean)` | 遮挡控制，默认开启 |
| `setSkinMaskEnabled(enabled: Boolean)` | 皮肤 Mask，默认开启 |
| `setSmoothSkinMaskEnabled(enabled: Boolean)` | 人脸区域 Mask 磨皮，默认关闭 |

设置中有状态返回的接口应逐次检查。皮肤冷暖为 `0` 冷、`0.5` 中性、`1` 暖。当前 AAR 仍导出 `setMakeupPath`，不应因旧文档的“废弃”字样而认为该方法已删除。

```kotlin
fun configureBeauty(engine: PixelFree) {
    // 先设预设，再覆盖需要单独调整的项。
    engine.pixelFreeSetBeautyFiterParam(
        PFBeautyFilterType.PFBeautyFilterTypeOneKey,
        PFBeautyTypeOneKey.PFBeautyTypeOneKeyNatural.intModel
    )
    engine.pixelFreeSetBeautyFiterParam(
        PFBeautyFilterType.PFBeautyFilterTypeFaceBlurStrength, 0.5f
    )
    engine.pixelFreeSetBeautyFiterParam(
        PFBeautyFilterType.PFBeautyFilterFleckFlawClean, 0.3f
    )
    engine.pixelFreeSetBeautyFiterParam(
        PFBeautyFilterType.PFBeautyFilterSkinDetailWaterGlow, 0.2f
    )
}

fun configureMakeupAndTone(engine: PixelFree): Int {
    // 前提：已加载美妆、肤色资源，并取得相应授权。
    val makeupStatus = engine.setMakeupPartDegree(PFMakeupPart.PFMakeupPartLip, 0.8f)
    if (makeupStatus != 0) return makeupStatus
    return engine.setSkinToneFilter(2, 0.6f, 0.5f, true)
}
```

数值参数包括基础美肤、精细眼／鼻／眉／唇调整、五类皮肤细节、九项面部填充、五项提升、牙齿修饰和轮廓平滑。两端当前成员命名一致，完整名称可查 [美颜参数索引](./api_iOS.md#beauty-parameters)，在 Kotlin 中加 `PFBeautyFilterType.` 前缀。不要跨版本硬编码成员序号。

`PFBeautyTypeOneKey` 提供 Normal、Natural、Cute、Goddess、Fair、Sweet、Texture、Hard。旧画质增强项使用锐化项替代；`PFBeautyFilterTeethRetouch` 与 `PFBeautyFilterWhitenTeeth` 分别控制牙齿修饰和美牙。

`PFMakeupPart` 为 Brow、Blusher、EyeShadow、EyeLiner、EyeLash、Lip、Highlight、Shadow、Foundation，例如 `PFMakeupPart.PFMakeupPartLip`。水印／绿幕等扩展配置应使用对应交付版本的接入约定，不把 iOS 结构体指针调用照搬到 Kotlin Float setter。

### 面部修饰能力查询

`getRejuvenationAvailability(): Int` 返回能力位；`getRejuvenationAvailabilityAsync(callback: (Int) -> Unit)` 为异步版本，回调在引擎／渲染队列执行，更新 UI 前切回主线程。

| `PFRejuvenationAvailability` 常量 | 功能 |
| :--- | :--- |
| `FILL` | 填充 |
| `SMOOTH` | 平滑 |
| `FIELDS` | 提升 |
| `CONTOUR` | 轮廓 |
| `TEETH` | 牙齿修饰 |
| `CONTOUR_SMOOTH` | 轮廓平滑 |

能力取决于资源、授权和运行环境，首帧处理后可再次查询。使用按位与判断所需能力是否可用。

## 5. 美体与实时人体选择

`pixelFreeSetBodyBeautyParam(type: PFBodyBeautyType, value: Float)` 设置美体。普通单项 `0～1`、`0.5` 中性；`PFBodyBeautyTypePreset` 接受表示整数 `0～6` 的浮点值。成员涵盖瘦身、腰腹、曲线、臀胸、长腿、颈肩和左右四肢；完整对应关系见 [美体参数索引](./api_iOS.md#body-parameters)，Kotlin 加 `PFBodyBeautyType.` 前缀。

| 接口 | 约定 |
| :--- | :--- |
| `setBodyBeautyTargetIndex(index: Int): Int` | IMAGE 模式先处理后选择，`0` 成功、`-1` 无效／未授权；index `-1` 恢复原有处理 |
| `getBodyBeautyTargetIndex(): Int` | `-2` 表示图片人体缓存失效；期间暂停美体，重新处理后再选择 |
| `getBodyLongLegControl(): PFBodyLongLegControl?` | 读取上下控制线及状态标记，null 表示不可用 |
| `setBodyLongLegControl(control: PFBodyLongLegControl?): Int` | 设置控制线；null 取消用户覆盖 |

`PFBodyLongLegControl` 使用 `PFBodyStretchLine(x0, y0, x1, y1)` 的 upper／lower 以及 `hasAutoPoints`、`hasUserOverride`。目标 index 只选择对象，单人参数需由编辑器保存；reset 或换图后重新选择。视频检测顺序可能改变。长腿仍采用全宽拉伸，目标选择只更新对应髋部高度。

## 6. 最近一帧的检测信息

| 接口 | 输出 |
| :--- | :--- |
| `hasFace(): Int` / `getFaceCount(): Int` | 是否检测到人脸／人数 |
| `getFaceRect(): FloatArray?` | 保留的单框入口，新接入优先使用复数框接口 |
| `getFaceRects(maxCount: Int = 64): FloatArray` | 每张脸 `x0,y0,x1,y1`，不要当作宽高 |
| `getFaceIds(maxCount: Int = 64): IntArray` | 与人脸框同序的 ID |
| `getFaceLandmarks168(maxFaces: Int = 64): FloatArray` | 每张脸 336 个交错 x/y 值；需 BeautyV2 授权 |
| `hasHuman(): Int` / `getHumanCount(): Int` | 是否有人体／人数，先加载人体资源并完成对应 IMAGE 处理 |
| `getHumanInfo(index: Int): PFHumanDetectionInfo?` | index、诊断用 trackId、rect、hasRect |
| `getHumanRects(maxCount: Int = 64): FloatArray` | 每人体四个归一化边界坐标 |

这些接口查询处理后的当前检测状态，不执行独立检测。坐标对应 RAW 输入、原点左上；显示时处理旋转和镜像。ID／index 不是跨照片身份，trackId 仅供诊断。人脸关键点公开布局包含估计点。

## 7. 图片快照与逐人渲染

| 检测入口 | 结果与失败 |
| :--- | :--- |
| `detectFacesWithBuffer(imageInput: PFImageInput): PFFaceDetectionResult` | 需要 CPU 平面与 BeautyV2；失败抛 `PFFaceException` |
| `detectBodiesWithBuffer(imageInput: PFImageInput): PFBodyDetectionResult` | 需要人体资源／授权，CPU 检测；失败抛 `PFBodyException` |

两者均有对应 `detectFacesWithBufferOnCurrentGLThread`／`detectBodiesWithBufferOnCurrentGLThread` 方法。检测不改输入，不进行美颜渲染。人脸／人体结果实现 `Closeable`，通过 `count` 与 `getFaceInfo(index)`／`getBodyInfo(index)` 查询；渲染时保持结果未关闭。

`PFDetectedFaceInfo` 包含 faceId、rect、168 点 landmarks、quaternion、可用的附加数据和源图元数据；`PFDetectedBodyInfo` 含 bodyId、rect、诊断 trackId 和源图元数据，不提供人体关键点数组。信息中的数组是返回给应用的数据副本，但关闭结果后不能再用该快照渲染。

快照坐标为方向校正后的归一化坐标，左上原点；同宽高比缩放可复用，但换图、裁剪或变形需重新检测。渲染必须匹配创建快照的引擎、来源与旋转，ID 只在该快照内有意义。

| 配置类型 | 构造字段 |
| :--- | :--- |
| `PFFaceParameter` | `key: PFBeautyFilterType`、`value: Float`，只接受数值型人脸参数 |
| `PFFaceRenderConfig` | `faceId`、`parameters`、可空 `makeupJsonPath`、`makeupStrength`；妆容字段可指本地 JSON、目录或匹配 bundle |
| `PFFaceStickerConfig` | `faceId`、可空 `stickerPath` |
| `PFBodyParameter` | `key: PFBodyBeautyType`、`value: Float` |
| `PFBodyRenderConfig` | `bodyId`、`parameters` |

| 渲染方法（均返回 Int） | 参数 |
| :--- | :--- |
| `processWithBufferAndFace` | `imageInput, detection, config` |
| `processWithBufferAndFaces` | `imageInput, detection, configs: List<PFFaceRenderConfig>` |
| `processWithBufferAndFaceEffects` | `imageInput, detection, configs, stickers: List<PFFaceStickerConfig>` |
| `processWithBufferAndBodies` | `imageInput, detection, configs: List<PFBodyRenderConfig>` |
| `processWithBufferAndEffects` | `imageInput, faceDetection, faceConfigs, stickers, bodyDetection, bodyConfigs`；快照可空，列表默认空 |

上述五个方法均有相应 `OnCurrentGLThread` 版本。返回纹理 ID 或负错误码，同时更新输入输出；不要只检查返回是否为 `0`。参数按快照顺序应用，未指定数值参数使用中性值。联合入口至少提供一个快照；类别快照为 null 时对应配置必须为空，该类别关闭，不继承全局美妆／贴纸或旧逐帧配置。

以下为一次完整的人脸检测与多人配置示例。`original` 为原图输入，`working` 必须是同一图的独立可写副本、具有相同方向，不能与原图数组共享可写数据。

```kotlin
fun renderFacesOnce(engine: PixelFree, original: PFImageInput, working: PFImageInput): Int {
    engine.detectFacesWithBuffer(original).use { faces ->
        val configs = (0 until faces.count).map { index ->
            val face = faces.getFaceInfo(index)
            PFFaceRenderConfig(
                faceId = face.faceId,
                parameters = listOf(PFFaceParameter(
                    PFBeautyFilterType.PFBeautyFilterTypeFaceBlurStrength,
                    if (index == 0) 0.5f else 0.3f
                ))
            )
        }
        val texture = engine.processWithBufferAndFaces(working, faces, configs)
        check(texture >= 0) { "Face render error: $texture" }
        return texture
    }
}
```

实际滑杆编辑会话应把检测和 `use` 生命周期提升到整个编辑会话，保留快照，每次从原图副本渲染。不要每次滑杆变化都重新检测，也不要保存上一次渲染后的像素作为原图。

联合处理示例接收业务已持有的快照，为每个人体设置独立配置：

```kotlin
fun renderPeople(
    engine: PixelFree, working: PFImageInput,
    faces: PFFaceDetectionResult, bodies: PFBodyDetectionResult
): Int {
    val faceConfigs = (0 until faces.count).map { index ->
        PFFaceRenderConfig(faces.getFaceInfo(index).faceId, listOf(
            PFFaceParameter(PFBeautyFilterType.PFBeautyFilterTypeFaceBlurStrength, 0.4f)
        ))
    }
    val bodyConfigs = (0 until bodies.count).map { index ->
        PFBodyRenderConfig(bodies.getBodyInfo(index).bodyId, listOf(
            PFBodyParameter(PFBodyBeautyType.PFBodyBeautyTypeSlimWaist, 0.6f)
        ))
    }
    return engine.processWithBufferAndEffects(
        working, faces, faceConfigs, emptyList(), bodies, bodyConfigs
    )
}
```

该函数返回的负错误值应由调用方处理。需要逐脸贴纸时构建 `PFFaceStickerConfig(faceId, absolutePath)` 列表传给联合入口或专用 FaceEffects 入口；不传的脸没有贴纸。快照和所有配置在同步调用返回前不可关闭或修改。

## 8. 独立分割与人像帧查询

| 接口 | 说明 |
| :--- | :--- |
| `getSegmentationAvailability(): Int` | 可用的 `PFSegmentationType.bit` 位集合 |
| `segmentWithBuffer(imageInput: PFImageInput, types: Int): PFSegmentationResult` | 无额外选项的同步 CPU 分割 |
| `segmentWithBuffer(imageInput: PFImageInput, types: Int, options: Int): PFSegmentationResult` | 可选 `PFSegmentationOption.HairFaceContext.bit`，必须同时请求 Hair |

类型为 `PFSegmentationType.Hair`、`Head`、`Skin`、`Human`，位分别为 1、2、4、8；`Sky`（16）是保留项，当前不可用。Hair／Head／Skin 需对应资源与 BeautyV2，Human 需人体资源和授权。

独立分割接受 RGB/BGR、RGBA/BGRA/ARGB/ABGR、GRAY、双平面 NV12/NV21 的 ByteArray；YUV 使用全范围 BT.601。当前 Android 包装接口不接受 I420 或纯纹理输入。调用不修改输入、不上传纹理，不执行美颜。每次显式调用分析当前输入；失败抛出 `PFSegmentationException`，不返回部分结果。

```kotlin
fun getHairMask(engine: PixelFree, original: PFImageInput): PFSegmentationMask? {
    val types = PFSegmentationType.Hair.bit
    if ((engine.getSegmentationAvailability() and types) != types) return null
    val result = engine.segmentWithBuffer(
        original, types, PFSegmentationOption.HairFaceContext.bit
    )
    return result.getMask(PFSegmentationType.Hair)
}
```

调用方捕获 `PFSegmentationException` 并读取 `errorCode`；这里的 null 仅表示不可用／没有该 Mask，异常不应被静默当作空前景。

`PFSegmentationResult` 提供 `types`、`masks`、`getMask(type)`，持有独立副本，无需 `close()`，后续 reset、资源重载或引擎释放不影响它。`PFSegmentationMask` 字段包括 type、maskData、width、height、stride、sourceWidth／sourceHeight、rotationMode、rect。

Mask 为整帧语义概率（`0～1`，1 表示前景），没有逐人 ID；已映射回 RAW 坐标，左上原点。实际宽高以结果为准，最长边不超过 512；stride 以 float 元素计。数组 getter 返回副本，连续读取像素时先保存一次 `maskData`，不要在循环中重复获取。

### 兼容的人像帧结果

`setHumanSegmentationEnabled(enabled: Boolean)` 默认关闭，需人体资源。处理后通过 `getHumanSegmentationResult(): PFHumanSegmentationResult?` 或 `getHumanSegmentationResultAtIndex(index: Int)` 获取最近一帧的副本；直接版本为 `getHumanSegmentationResultOnCurrentGLThread(index: Int = 0)`。字段为 maskData、width、height、count、humanCount、index。它是当前帧查询流程，不等同于上面的独立多类型分割。

## 9. 专业调色

`setColorGrading(params: PFColorGradingParams): Int` 复制参数，`resetColorGrading(): Int` 恢复中性；两者都有 `OnCurrentGLThread` 版本。设置成功为 `0`，在下一次正常处理的最终输出前应用，不需要手动再跑一次调色或美颜。IMAGE 模式只修改调色不会主动清空美颜缓存。

| 字段组 | 范围 |
| :--- | :--- |
| brightness、contrast、saturation、vibrance、ambiance、clarity、structure | `-1～1`，中性 `0` |
| exposure、lightSensation、highlights、shadows、blacks、whites | `-1～1`，中性 `0` |
| vignette、temperature、tint、hue | `-1～1`，中性 `0` |
| sharpen、denoise、fade、glow、grainIntensity、grainRough | `0～1` |
| splitShadow／splitHighlight | `PFColorGradingParams.RGBA`；各通道 `0～1`，对应 Intensity 也为 `0～1` |
| hslHue／hslSat／hslLight | 各 8 个 `-1～1` 值：红、橙、黄、绿、青、蓝、紫、洋红 |
| customHSL | 最多 16 个 `CustomHSL`；关键 RGB 各 `0～1`，range 为色相圈数 `0～0.5`，feather 为 `0～0.5-range`，三个调整量 `-1～1` |
| curveRGB／curveRed／curveGreen／curveBlue | 空列表保持原样；否则 2～32 个 `CurvePoint`，坐标 `0～1`、x 严格递增 |

```kotlin
fun setPhotoGrading(engine: PixelFree): Int {
    val params = PFColorGradingParams(
        contrast = 0.1f,
        vibrance = 0.15f,
        hslSat = listOf(-0.1f, 0f, 0f, 0f, 0f, 0f, 0f, 0f),
        curveRGB = listOf(
            PFColorGradingParams.CurvePoint(0f, 0f),
            PFColorGradingParams.CurvePoint(0.5f, 0.55f),
            PFColorGradingParams.CurvePoint(1f, 1f)
        )
    )
    return engine.setColorGrading(params)
}
```

使用默认构造参数保证未设置项为中性。列表长度和曲线顺序必须合法，所有数值需有限；包装层参数检查也可能抛出 `IllegalArgumentException`。新版不使用旧的多参数 `pixelFreeSetColorGrading` 或 HLS 句柄增删方法。

## 10. 参考图仿色

当前签名为 `processColorTransfer(source, reference, params, output, outputFormat, outputStride): Int`，其中前两项为 `PFImageInput`，params 为 `PFColorTransferParams`，output 为 `ByteArray`。outputFormat 默认跟随源格式，outputStride 默认 `0`（紧凑）。同名 `OnCurrentGLThread` 版本要求当前有效 GL 上下文。

此接口独立于常规美颜、人体、美妆、贴纸和调色，需要美体授权与配套资源。源图被着色、参考图提供色彩；输入提供有效 CPU 平面。输出尺寸与源图相同，缓冲区由调用方持有，支持 RGB/BGR/RGBA/BGRA/ARGB/ABGR 输出。

```kotlin
fun transferToRgba(engine: PixelFree, source: PFImageInput, reference: PFImageInput): ByteArray {
    require(source.wigth > 0 && source.height > 0)
    val size = source.wigth.toLong() * source.height * 4
    require(size <= Int.MAX_VALUE)
    val output = ByteArray(size.toInt())
    val params = PFColorTransferParams(features = PFColorTransferFeature.COLOR, degree = 0.7f)
    val status = engine.processColorTransfer(
        source, reference, params, output,
        PFDetectFormat.PFFORMAT_IMAGE_RGBA, source.wigth * 4
    )
    check(status == 0) { "Color transfer error: $status" }
    return output
}
```

默认 `features=0` 仅复制原图，必须显式开启 `COLOR`。`degree` 为 `0～1`、默认 `1`，`strength` 是同值只读属性；同一源图与参考图仅改变程度可复用相关缓存。输出返回的是应用自己的字节数组，不是 SDK 纹理。

## 11. 工具与错误处理

`textureIdToBitmap(textureId: Int, width: Int, height: Int, callback: (Bitmap?) -> Unit)` 提供纹理读回辅助，可能失败返回 null；应在纹理有效且上下文匹配时使用，回调更新 UI 前切回主线程。仅预览时优先在原 GL 链路消费纹理，避免无必要的像素复制。

| 调用类别 | 成功与错误 |
| :--- | :--- |
| 普通帧处理 | 返回 Unit；检查更新后的 textureID 和最近错误，不把 Unit 当状态 |
| 快照检测 | 返回结果，人数可为 0；失败抛 `PFFaceException`／`PFBodyException` |
| 快照渲染 | 返回纹理 ID 或负错误；无效或已关闭快照也可能抛异常 |
| 独立分割 | 返回结果或抛 `PFSegmentationException(errorCode)` |
| 调色／仿色等状态接口 | `0` 成功，负值错误；参数检查也可能抛异常 |

| 类别 | 错误码 |
| :--- | :--- |
| 通用 `getLastErrorCode` | `1001` 参数；`1101/1102/1103` 人脸／人体／GL 初始化；`2001～2005` 应用、平台、过期、模块授权、渲染停止；`3001/3002` 无人脸／人体 |
| 调色 | `-200` 参数、`-201` 未授权、`-202` GL、`-203` 缺少资源；未初始化时包装接口还可能返回 `-1` |
| 分割 | `-1` 参数、`-2` 未授权、`-3` 不可用、`-4` 推理、`-5` 无效结果、`-6` 内部错误 |
| 人脸 | `-4101` 参数、`-4102` 快照、`-4103` 重复 ID、`-4104` 未知 ID、`-4105` 源不匹配、`-4106` 未授权、`-4107` 检测不可用、`-4108` 美妆资源、`-4109` 内部错误、`-4110` 贴纸资源 |
| 人体 | `-4201/-4202/-4203/-4204/-4205/-4206/-4207/-4209`：参数／快照／重复 ID／未知 ID／源不匹配／未授权／检测不可用／内部错误 |
| 仿色 | `-4301` 参数、`-4302` 未授权、`-4303` 模型、`-4304` 内部错误 |

不要用单个成功条件覆盖所有 API，也不要将授权／资源失败当作“照片无人”。产品应根据接口返回和异常明确处理降级。

## 12. 从旧文档迁移

| 旧用法／错误假设 | 当前做法 |
| :--- | :--- |
| 用美颜 setter 的字符串重载设置滤镜 | `pixelFreeSetFilterParam(name, value)` |
| 沿用旧拼写的美颜枚举 | 使用 `PFBeautyFilterType` 当前成员；方法名仍是 `pixelFreeSetBeautyFiterParam` |
| 使用 iOS 风格的人脸计数／输出参数方法 | `getFaceCount()`、`getFaceRects(...)` 等 Kotlin 返回值接口 |
| 多参数调色或 HLS 句柄 | `setColorGrading(PFColorGradingParams(...))`，自定义颜色使用 customHSL |
| 资源读取必定成功 | `readBundleFile` 可返回 null，先检查再读取 size |
| 每个方法都有当前 GL 线程版本 | 仅使用 AAR 实际导出的对应方法 |
| 普通输入数组等同于原图存档 | 处理会回写，图片编辑需单独保存原始像素 |

安装、ABI、资源打包和最小可用会话见 [Android 接入指南](./doc_android.md)。
