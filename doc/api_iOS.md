# PixelFree iOS API 文档

[iOS 接入指南](./doc_iOS.md) · [Android API](./api_android.md) · [项目概览](../README.md)

本文描述当前 [SMPixelFree.h](../SMBeautyEngine_iOS/PixelFree.framework/Headers/SMPixelFree.h) 的公开接口。结构体和枚举见 [pixelFree_c.hpp](../SMBeautyEngine_iOS/PixelFree.framework/Headers/pixelFree_c.hpp)，专业调色字段见 [PFColorGradingParams.h](../SMBeautyEngine_iOS/PixelFree.framework/Headers/PFColorGradingParams.h)。代码块为 Objective-C++ 函数示例；使用 ARC，导入 `PixelFree/SMPixelFree.h`。除独立 CPU 检测外，示例调用前应使 `engine.glContext` 在所属串行处理队列中有效。

## 1. 实例、资源与处理入口

| 接口 | 返回／约定 |
| :--- | :--- |
| `initWithProcessContext:srcFilterPath:authFile:` | 创建 `SMPixelFree`；传入 `EAGLContext`、基础资源文件路径和授权文件路径。头文件说明允许延迟图形初始化；接入示例显式提供上下文 |
| `glContext` | 只读 `EAGLContext *`，供纹理与渲染上下文管理 |
| `createBeautyItemFormBundleKey:data:size:` | 返回 `void`；`key` 为 `PFSrcType`，`data` 为文件字节，`size` 为字节数。数据在调用返回前有效 |
| `setDetectMode:` | `PF_FACE_DETECT_MODE_IMAGE` 或 `PF_FACE_DETECT_MODE_VIDEO`，不要传角度或自造数字 |
| `resetDetectState` | 清除检测／跟踪缓存；IMAGE 模式换源图或方向后调用，保留调色参数 |
| `getLastErrorCode` | 最近一次设置／渲染错误，`0` 正常；不能替代独立 API 自身的错误返回 |
| `setConsoleLogEnabled:` | 控制控制台日志，属于全局开关 |
| `PF_Version()` | C 函数，返回运行时 SDK 版本字符串 |

资源类型：基础资源 `PFSrcTypeFilter`、授权资源 `PFSrcTypeAuthFile`、贴纸 `PFSrcTypeStickerFile`、美妆 `PFSrcTypeMakeup`、人体 `PFSrcTypeHumanProcessor`、肤色 `PFSrcTypeSkinSrc`。通常在初始化时传授权与基础模型，再按功能加载其他资源。

| 图像入口 | 输入与输出 |
| :--- | :--- |
| `processWithBuffer:rotationMode:` | BGRA／双平面 NV12 的 `CVPixelBufferRef`；同步回写像素，返回纹理 ID 或负错误值 |
| `processWithTexture:width:height:rotation:` | 在 `glContext` 中原位处理纹理；成功返回输入纹理 ID，失败为负值，无 CPU 输出读回 |
| `processWithImage:rotationMode:` | 输入 `UIImage *`，返回处理后的 `UIImage *`；检测与方向约定同对应图像流程 |

正常处理自动应用已设置的调色。`PFRotationMode0/90/180/270` 为方向枚举，不是字面角度整数。实例创建、参数更新、处理和销毁应串行化。`SMPixelFree` 无公开 Objective-C 销毁方法，停止处理后通过 ARC 释放，详见 [接入指南](./doc_iOS.md)。

## 2. 美颜、美型与皮肤修饰

`pixelFreeSetBeautyFilterParam:value:` 接收 `PFBeautyFilterType` 和参数指针。**指针类型由 key 决定**：数值强度用 `float *`，一键预设用 `int *`，滤镜名用 UTF-8 字符串；不要把所有 key 都当浮点强度。

```objective-c++
#import <PixelFree/SMPixelFree.h>

void ConfigureBeauty(SMPixelFree *engine) {
    int preset = PFBeautyTypeOneKeyNatural;
    [engine pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&preset];
    float smoothing = 0.5f;
    float detail = 0.25f;
    [engine pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceBlurStrength value:&smoothing];
    [engine pixelFreeSetBeautyFilterParam:PFBeautyFilterSkinDetailWaterGlow value:&detail];
}
```

一键预设与单项调节可能覆盖同类设置。若要在预设基础上微调，按上例先应用预设，再设置单项。

<a id="beauty-parameters"></a>

### 数值参数索引

以下名字均为 `PFBeautyFilterType` 的成员。常规强度通常 `0～1`、`0` 关闭；双向几何调节通常 `0.5` 中性，以对应枚举说明为准。不要使用统一全零数组复原所有美型项。

| 功能 | 枚举 |
| :--- | :--- |
| 磨皮／美白／红润 | `PFBeautyFilterTypeFaceBlurStrength`、`PFBeautyFilterTypeFaceM_newWhitenStrength`、`PFBeautyFilterTypeFaceRuddyStrength` |
| 锐化／亮眼／美牙 | `PFBeautyFilterTypeFaceSharpenStrength`、`PFBeautyFilterTypeFaceEyeBrighten`、`PFBeautyFilterWhitenTeeth` |
| 法令纹／黑眼圈／瑕疵 | `PFBeautyFilterNasolabial`、`PFBeautyFilterBlackEye`、`PFBeautyFilterFleckFlawClean` |
| 皮肤纹理／清晰柔光／高光柔光／水光／哑光 | `PFBeautyFilterSkinDetailTexture`、`PFBeautyFilterSkinDetailClarity`、`PFBeautyFilterSkinDetailHighlight`、`PFBeautyFilterSkinDetailWaterGlow`、`PFBeautyFilterSkinDetailMatte` |
| 大眼／瘦脸／窄脸／V 脸／小脸 | `PFBeautyFilterTypeFace_EyeStrength`、`PFBeautyFilterTypeFace_thinning`、`PFBeautyFilterTypeFace_narrow`、`PFBeautyFilterTypeFace_V`、`PFBeautyFilterTypeFace_small` |
| 下巴／额头／嘴部／人中 | `PFBeautyFilterTypeFace_chin`、`PFBeautyFilterTypeFace_forehead`、`PFBeautyFilterTypeFace_mouth`、`PFBeautyFilterTypeFace_philtrum` |
| 眼距／眼旋转／眼角／位置／高度 | `PFBeautyFilterTypeFace_eye_space`、`PFBeautyFilterTypeFace_eye_rotate`、`PFBeautyFilterTypeFace_canthus`、`PFBeautyFilterTypeFace_eye_y`、`PFBeautyFilterTypeFace_eye_height` |
| 瘦鼻／长鼻／大小／高度／位置／鼻尖／鼻梁 | `PFBeautyFilterTypeFace_nose`、`PFBeautyFilterTypeFace_long_nose`、`PFBeautyFilterTypeFace_nose_size`、`PFBeautyFilterTypeFace_nose_height`、`PFBeautyFilterTypeFace_nose_y`、`PFBeautyFilterTypeFace_nose_tip`、`PFBeautyFilterTypeFace_nose_bridge` |
| 眉粗细／长度／提升／间距／倾斜 | `PFBeautyFilterTypeFace_brow_thickness`、`PFBeautyFilterTypeFace_brow_length`、`PFBeautyFilterTypeFace_brow_lift`、`PFBeautyFilterTypeFace_brow_distance`、`PFBeautyFilterTypeFace_brow_tilt` |
| 上唇／下唇／丰唇／唇宽／微笑 | `PFBeautyFilterTypeFace_upper_lip_thickness`、`PFBeautyFilterTypeFace_lower_lip_thickness`、`PFBeautyFilterTypeFace_lip_fullness`、`PFBeautyFilterTypeFace_mouth_width`、`PFBeautyFilterTypeFace_smile` |
| 面部填充 | `PFBeautyFilterFaceFillForehead`、`PFBeautyFilterFaceFillTearTrough`、`PFBeautyFilterFaceFillEyeSocket`、`PFBeautyFilterFaceFillAppleCheeks`、`PFBeautyFilterFaceFillChin`、`PFBeautyFilterFaceFillCheeks`、`PFBeautyFilterFaceFillBrowArch`、`PFBeautyFilterFaceFillNasalBase`、`PFBeautyFilterFaceFillMouthCorner` |
| 面部提升 | `PFBeautyFilterFaceLiftForehead`、`PFBeautyFilterFaceLiftPeriorbital`、`PFBeautyFilterFaceLiftMalar`、`PFBeautyFilterFaceLiftPerioral`、`PFBeautyFilterFaceLiftContour` |
| 牙齿修饰／轮廓平滑 | `PFBeautyFilterTeethRetouch`、`PFBeautyFilterFaceContourSmooth`；各自 `0～1`、默认 `0`，与美牙独立 |

旧画质增强枚举 `PFBeautyFilterTypeFaceH_qualityStrength` 已标记废弃，使用锐化项。`PFBeautyTypeOneKey` 提供 Normal（关闭）、Natural、Cute、Goddess、Fair、Sweet、Texture、Hard 预设，使用完整枚举名而非数字。

### Mask 与能力查询

| 接口 | 说明 |
| :--- | :--- |
| `pixelFreeSetSkinMaskEnabled:` | 皮肤 Mask 开关，默认开启 |
| `pixelFreeSetSmoothSkinMaskEnabled:` | 人脸区域 Mask 磨皮，默认关闭 |
| `pixelFreeSetMakeupFaceOccuEnabled:` | 面部遮挡控制，默认开启，妆效避开遮挡区域 |
| `pixelFreeGetRejuvenationAvailability` | 返回面部修饰能力位，用于按实际资源与授权启用 UI，不执行渲染 |

能力位为 `1` 填充、`2` 平滑、`4` 提升、`8` 轮廓、`0x10` 牙齿修饰、`0x20` 轮廓平滑。使用按位与判断所需能力是否可用。

## 3. 滤镜、肤色、美妆与贴纸

| 接口 | 参数与返回 |
| :--- | :--- |
| `pixelFreeSetBeautyFilterParam:value:` | `PFBeautyFilterName` 传 UTF-8 滤镜名，`PFBeautyFilterStrength` 传 `float *`，范围 `0～1` |
| `pixelFreeSetExternalFilterWithPath:intensity:enabled:` | `NSString *` 本地 LUT 文件路径、`float` 强度、`BOOL` 开关；返回状态。256×256、8×8 分块 LUT；nil／空路径或关闭开关可停用 |
| `pixelFreeClearExternalFilter` | 清除外部 LUT，返回状态 |
| `pixelFreeSetSkinToneFilter:` / `pixelFreeClearSkinToneFilter` | 设置 `PFSkinToneFilterParams *`／清除肤色；需要先加载肤色资源，返回状态 |
| `pixelFreeSetMakeupWithJsonPath:` / `clearMakeup` | 本地美妆配置路径／清除美妆，返回状态；资源包也可通过 `PFSrcTypeMakeup` 加载 |
| `pixelFreeSetMakeupPart:degree:` | `PFMakeupPart`、`float` 程度，返回 `void`；程度 `0～1`，与素材配置叠乘 |
| `pixelFreeSetFiterStickerWithPath:` | 本地贴纸资源路径，返回 `void`；`Fiter` 是实际方法拼写 |

`PFMakeupPart` 包含 Brow、Blusher、EyeShadow、EyeLiner、EyeLash、Lip、Highlight、Shadow、Foundation，使用 `PFMakeupPartLip` 等完整名称。路径参数指向应用可读取的实际文件，不是网络 URL。素材的加载与切换应与渲染串行。

```objective-c++
int ConfigureSkinTone(SMPixelFree *engine) {
    // 前提：已加载 skin_src.bundle，且对应功能已授权。
    PFSkinToneFilterParams params = {};
    params.isUse = true;
    params.skinToneType = PFSkinToneTypePinkWhite;
    params.intensity = 0.6f;
    params.coldWarmIntensity = 0.5f;
    return [engine pixelFreeSetSkinToneFilter:&params];
}
```

肤色类型为 Natural、Fair、PinkWhite、Wheat、Bronze；强度 `0～1`，冷暖 `0` 冷／`0.5` 中性／`1` 暖。所有有状态返回的设置都应检查结果，不能只检查实例是否非空。

水印和绿幕通过通用设置入口的 `PFBeautyFilterWatermark`／`PFBeautyFilterLvmu` 与公开的 `PFFilterWatermark`／`PFFilterLvmuSetting` 结构配置，字段见 C 头文件。不要给这些结构型参数传 `float *`。绿幕抠像与人像分割是不同能力。

## 4. 美体与目标选择

`pixelFreeSetBodyBeautyParam:value:` 接收 `PFBodyBeautyType` 和 `float *`；普通单项 `0～1`、`0.5` 中性，Preset 为整数值 `0～6`（仍通过浮点参数传入）。使用前加载 `body_model.bundle` 并取得人体功能授权。

<a id="body-parameters"></a>

| `PFBodyBeautyType` 成员 | 功能 |
| :--- | :--- |
| `PFBodyBeautyTypePreset` | 体型预设 |
| `PFBodyBeautyTypeSlimBody` / `PFBodyBeautyTypeSlimWaist` / `PFBodyBeautyTypeSlimBelly` | 瘦身／瘦腰／瘦肚子 |
| `PFBodyBeautyTypeBelly` / `PFBodyBeautyTypeCurve` / `PFBodyBeautyTypeFullSlim` | 沙漏腰／曲线／全身瘦 |
| `PFBodyBeautyTypeHipLift` / `PFBodyBeautyTypeHipEnlarge` / `PFBodyBeautyTypeBreastEnlarge` | 提胯／丰臀／丰胸 |
| `PFBodyBeautyTypeSlimArm` / `PFBodyBeautyTypeSwanNeck` | 整体手臂／天鹅颈 |
| `PFBodyBeautyTypeShoulderThin` / `PFBodyBeautyTypeRightAngleShoulder` | 瘦肩／直角肩 |
| `PFBodyBeautyTypeLeftUpperArm` / `PFBodyBeautyTypeLeftLowerArm` | 左大臂／左小臂 |
| `PFBodyBeautyTypeRightUpperArm` / `PFBodyBeautyTypeRightLowerArm` | 右大臂／右小臂 |
| `PFBodyBeautyTypeLeftUpperLeg` / `PFBodyBeautyTypeLeftLowerLeg` | 左大腿／左小腿 |
| `PFBodyBeautyTypeRightUpperLeg` / `PFBodyBeautyTypeRightLowerLeg` | 右大腿／右小腿 |
| `PFBodyBeautyTypeHeight` | 长腿，`>0.5` 拉长、`<0.5` 缩短 |

| 控制接口 | 约定 |
| :--- | :--- |
| `pixelFreeSetBodyBeautyTargetIndex:` | IMAGE 模式先处理一次再选择人体 index，返回 `0` 成功、`-1` 无效或无授权；传 `-1` 恢复原有处理方式 |
| `pixelFreeGetBodyBeautyTargetIndex` | 查询选择；`-2` 表示图片人体缓存失效，期间暂停美体，需要重新处理后选择 |
| `pixelFreeGetBodyLongLegControl:` | 写入 `PFBodyLongLegControl`，读取状态后再使用 |
| `pixelFreeSetBodyLongLegControl:` | 设置上下控制线；传 `NULL` 取消用户覆盖，恢复自动控制 |

目标选择只选择几何对象，参数不会自动按人保存。index 不是稳定身份，视频重新检测可能改变顺序；长腿仍使用全宽拉伸，选择人体只更新对应髋部高度。需要逐人体保存参数并联合渲染时使用快照接口。

## 5. 实时检测查询

在相应处理完成后读取，不会替你运行独立检测。

| 接口 | 输出 |
| :--- | :--- |
| `hasFace` / `getPixelFreeFaceNum` | 是否有人脸／人脸数量 |
| `pixelFreeGetFaceRects:maxCount:` | 每张脸四个 float：`x0,y0,x1,y1`；数组容量至少 `4 * maxCount`，返回写入人数 |
| `pixelFreeGetFaceIds:maxCount:` | 与上述框同序的检测 ID；容量至少 `maxCount` |
| `pixelFreeGetFaceLandmarks168:maxFaces:` | 每张脸 168 点、336 个交错 x/y float；容量至少 `336 * maxFaces`，需 BeautyV2 授权 |
| `pixelFreeGetFaceRect:` | 保留的单框接口；新接入优先使用显式容量的复数接口 |
| `hasHuman` / `pixelFreeGetHumanCount` | 是否有人体／人数；人体查询应在加载资源并完成相应 IMAGE 处理后使用 |
| `pixelFreeGetHumanInfo:atIndex:` | 写入 `PFHumanDetectionInfo`，返回 `1` 成功，`0` 不可用 |
| `pixelFreeGetHumanRects:maxCount:` | 每人体四个 float，同序输出，返回数量 |

复数框与实时关键点使用原始输入（RAW）的归一化坐标、左上原点。不要把 `x1,y1` 当宽高。`PFHumanDetectionInfo.trackId` 仅供诊断，不能视为持久身份。无检测结果、授权不足与调用失败应结合各返回值和错误码区分。

## 6. 图片快照与逐人渲染

| 检测接口 | 结果类型 |
| :--- | :--- |
| `detectFacesWithBuffer:rotationMode:` | `SMPixelFreeFaceDetection *`，失败 `nil`；需要 BeautyV2 授权 |
| `detectBodiesWithBuffer:rotationMode:` | `SMPixelFreeBodyDetection *`，失败 `nil`；需要人体授权与资源 |

检测同步执行、不修改输入。结果可在后续检测和 reset 后继续读取，但渲染必须匹配原引擎、源图和方向；同宽高比缩放可复用，裁剪、变形或换图需重新检测。人脸／人体快照使用方向校正后的归一化坐标，左上原点；不是上一节的 RAW 坐标。

- 人脸：`faceCount`、`getFaceInfo:atIndex:`，输出 `PFDetectedFaceInfo`；含快照内 `faceId`、框、168 点、四元数与可用的附加数据视图。168 点布局包含估计点，坐标可能超出图像边界。
- 人体：`bodyCount`、`getBodyInfo:atIndex:`，输出 `PFDetectedBodyInfo`；含 `bodyId`、框和源图元数据，不公开人体关键点数组。
- 配置：`PFFaceRenderConfig` 由 `faceId`、`PFFaceParameter` 数组、可选 `makeupJsonPath` 与 `makeupStrength` 组成。美妆字段保留历史名称，支持本地 JSON、目录或对应 bundle。`PFFaceStickerConfig` 单独指定每张脸的贴纸。
- 美体：`PFBodyRenderConfig` 由 `bodyId` 和 `PFBodyParameter` 数组组成。未指定参数使用中性值，不继承全局参数。
- 对象 ID 仅在该快照内有效。快照持有期间才能使用借用指针；渲染调用返回前，参数数组和路径内存不可修改或释放。

| 渲染入口 | 行为 |
| :--- | :--- |
| `processWithBuffer:rotationMode:faceDetection:faceConfigs:count:` | 按快照顺序处理人脸配置；`count=0` 仅全局效果 |
| 上述入口加 `stickerConfigs:stickerCount:` | 每脸独立贴纸，不继承相机全局贴纸 |
| `processWithBuffer:rotationMode:bodyDetection:bodyConfigs:bodyCount:` | 显式人体任务，不重新检测；零任务关闭美体 |
| `processWithBuffer:rotationMode:faceDetection:faceConfigs:count:stickerConfigs:stickerCount:bodyDetection:bodyConfigs:bodyCount:` | 联合处理；至少提供一种快照，缺失类别关闭，颜色／滤镜全局阶段只运行一次 |

以下函数接收业务已持有的快照，演示为第一张脸和第一个人体分别配置参数。`workingBuffer` 必须是原图的工作副本，不能是上一次处理结果；调用前设置引擎上下文。

```objective-c++
int RenderSelectedPeople(SMPixelFree *engine, CVPixelBufferRef workingBuffer,
                         PFRotationMode rotation,
                         SMPixelFreeFaceDetection *faces,
                         SMPixelFreeBodyDetection *bodies) {
    if (!faces && !bodies) return -1; // 应用侧：没有可用快照。
    PFDetectedFaceInfo face = {};
    PFDetectedBodyInfo body = {};
    int faceCount = (faces.faceCount > 0 && [faces getFaceInfo:&face atIndex:0]) ? 1 : 0;
    int bodyCount = (bodies.bodyCount > 0 && [bodies getBodyInfo:&body atIndex:0]) ? 1 : 0;
    PFFaceParameter faceParams[] = {{PFBeautyFilterTypeFaceBlurStrength, 0.5f}};
    PFBodyParameter bodyParams[] = {{PFBodyBeautyTypeSlimWaist, 0.6f}};
    PFFaceRenderConfig faceConfig = {face.faceId, faceParams, 1, NULL, 0.0f};
    PFBodyRenderConfig bodyConfig = {body.bodyId, bodyParams, 1};
    return [engine processWithBuffer:workingBuffer
                       rotationMode:rotation
                      faceDetection:faces
                        faceConfigs:faceCount ? &faceConfig : NULL
                              count:faceCount
                     stickerConfigs:NULL
                       stickerCount:0
                      bodyDetection:bodies
                        bodyConfigs:bodyCount ? &bodyConfig : NULL
                          bodyCount:bodyCount];
}
```

快照通过 `[engine detectFacesWithBuffer:originalBuffer rotationMode:rotation]` 和对应人体方法取得，保留至图片编辑会话结束。每次更新只重建参数和原图工作副本。联合入口中 `faces=nil` 时人脸及贴纸数量必须均为 `0`；`bodies=nil` 时人体数量必须为 `0`。失败返回相应人脸／人体负错误码。

## 7. 独立语义分割

`getSegmentationAvailability` 返回当前可用 `PFSegmentationType` 位。`segmentWithBuffer:rotationMode:types:error:` 为基础入口；增加 `options:` 可选择 `PFSegmentationOptionHairFaceContext`，但请求类型必须包含 Hair。

| 类型 | 位值 | 前提 |
| :--- | ---: | :--- |
| `PFSegmentationHair` | 1 | 对应资源与 BeautyV2 |
| `PFSegmentationHead` | 2 | 对应资源与 BeautyV2 |
| `PFSegmentationSkin` | 4 | 对应资源与 BeautyV2 |
| `PFSegmentationHuman` | 8 | 人体资源与授权 |
| `PFSegmentationSky` | 16 | 保留，当前不可用 |

输入仅接受 BGRA 或全范围双平面 NV12（BT.601），视频范围 NV12 被拒绝。独立分割是同步 CPU 操作，不改像素、不执行 GL 或美颜；每次显式调用分析当前输入。失败返回 `nil`，并通过 `PixelFreeSegmentation` 域的 `NSError` 返回错误，不返回部分成功结果。

```objective-c++
void InspectHairMask(SMPixelFree *engine, CVPixelBufferRef originalBuffer) {
    unsigned int requested = PFSegmentationHair;
    if (([engine getSegmentationAvailability] & requested) != requested) return;
    NSError *error = nil;
    SMPixelFreeSegmentation *result = [engine segmentWithBuffer:originalBuffer
                                                 rotationMode:PFRotationMode0
                                                        types:requested
                                                      options:PFSegmentationOptionHairFaceContext
                                                        error:&error];
    if (!result) {
        NSLog(@"Segmentation failed: %@", error);
        return;
    }
    PFSegmentationMask mask = {};
    if ([result getMask:&mask type:PFSegmentationHair]) {
        NSLog(@"Mask %d x %d, stride=%d", mask.width, mask.height, mask.stride);
        // 在 result 存活期间读取 mask.maskData，或复制后交给其他队列。
    }
}
```

`PFSegmentationMask` 是整帧语义概率图，值域 `0～1`、`1` 表示前景，不含逐人 ID。`width/height` 是实际输出尺寸（最长边不超过 512），`stride` 以 float 元素计，不是字节。Mask 已映射回 RAW 输入坐标，显示时才结合旋转／镜像；不要重复旋转数据。Mask 指针随 `SMPixelFreeSegmentation` 对象存活，即使引擎 reset、重载资源或销毁也不失效。

### 兼容的人像分割帧查询

`pixelFreeSetHumanSegmentationEnabled:` 默认关闭，需人体资源。处理后通过 `pixelFreeGetHumanSegmentationResult:` 或 `pixelFreeGetHumanSegmentationResultAtIndex:result:` 获取 `PFHumanSegmentationResult`，返回 `1` 表示有 Mask。此处指针来自帧缓存，在下一次处理、reset 或销毁后失效；其生命周期与独立语义分割对象不同。

## 8. 专业调色

`pixelFreeSetColorGrading:` 接收 `const PFColorGradingParams *` 并复制设置；`pixelFreeResetColorGrading` 恢复中性。正常 buffer、image、texture 处理会在美颜／美体／贴纸后自动应用调色。只改调色无需追加一次手动渲染；IMAGE 模式调色修改不会主动清空已缓存的美颜结果。

| 字段 | 范围／说明 |
| :--- | :--- |
| `brightness, contrast, saturation, vibrance, ambiance, clarity, structure` | `-1～1`，中性 `0` |
| `exposure, lightSensation, highlights, shadows, blacks, whites` | `-1～1`，中性 `0` |
| `vignette, temperature, tint, hue` | `-1～1`，中性 `0` |
| `sharpen, denoise, fade, glow` | `0～1` |
| `splitShadow, splitHighlight` | RGBA 四个值，各 `0～1`；对应 intensity 为 `0～1` |
| `grainIntensity, grainRough` | `0～1` |
| `hslHue, hslSat, hslLight` | 各八个 `-1～1` 值，顺序红、橙、黄、绿、青、蓝、紫、洋红 |
| `customHSLCount, customHSL` | 最多 16 组；关键 RGB 为 `0～1`，range 为色相圈数 `0～0.5`，feather 为 `0～0.5-range`，调整值 `-1～1` |
| `curveRGB, curveRed, curveGreen, curveBlue` | 空曲线为恒等；否则 2～32 点、坐标 `0～1` 且 x 严格递增 |

```objective-c++
int SetPhotoGrading(SMPixelFree *engine) {
    PFColorGradingParams params;
    PF_initColorGradingParams(&params);
    params.contrast = 0.1f;
    params.vibrance = 0.15f;
    params.hslSat[0] = -0.1f;
    params.curveRGB.count = 3;
    params.curveRGB.points[0] = {0.0f, 0.0f};
    params.curveRGB.points[1] = {0.5f, 0.55f};
    params.curveRGB.points[2] = {1.0f, 1.0f};
    return [engine pixelFreeSetColorGrading:&params];
}
```

必须先初始化结构，不使用旧版 `PFImageColorGrading`、HLS 句柄增删接口或旧的绝对曝光／色温量纲。新版 `customHSL` 替代自定义关键色句柄配置。参数需为有限数值，不能包含 NaN 或无穷大。

## 9. 参考图仿色

`processColorTransferWithSource:reference:params:output:` 是独立入口，源图被着色、参考图提供色彩，不执行其他美颜、美体、美妆、贴纸或常规调色。当前需要美体授权与配套资源。使用当前引擎的 GL 上下文，输入提供有效 CPU 图像数据。

`PFColorTransferParams` 通过 `PF_initColorTransferParams` 初始化：默认 `features=0`，只复制源图；开启 `PFColorTransferFeatureColor` 才启用仿色。`strength` 范围 `0～1`，同一源图与参考图仅改变程度可复用处理结果中的相关缓存。

```objective-c++
int TransferColors(SMPixelFree *engine, PFImageInput source, PFImageInput reference,
                   void *outputPixels, int outputStride) {
    // 本例输出 RGBA；调用方至少分配 outputStride * source.height 字节。
    PFColorTransferParams params;
    PF_initColorTransferParams(&params);
    params.features = PFColorTransferFeatureColor;
    params.strength = 0.7f;
    PFColorTransferOutput output = {};
    output.data = outputPixels;
    output.width = source.wigth;
    output.height = source.height;
    output.stride = outputStride;
    output.format = PFFORMAT_IMAGE_RGBA;
    return [engine processColorTransferWithSource:source reference:reference
                                          params:&params output:&output];
}
```

`PFImageInput` 的宽度字段实际拼写为 `wigth`；设置真实格式、平面和字节 stride。输出尺寸必须与源图一致，缓冲区由应用分配和持有；RGBA 的 `outputStride` 至少为宽度乘 4。输出格式支持 RGB/BGR/RGBA/BGRA/ARGB/ABGR，`PFFORMAT_UNKNOWN` 表示跟随源格式。`stride=0` 表示紧凑输出，仍需预先分配足够空间。

## 10. 返回值与错误

| 错误通道 | 成功／失败规则 |
| :--- | :--- |
| 普通 buffer／texture 与快照渲染 | 返回纹理 ID；负值为失败，不能只判断是否等于 0 |
| 独立人脸／人体检测 | 非 nil 结果（人数可以为 0）；nil 表示失败 |
| 独立分割 | 非 nil 结果；nil 与 `NSError` 表示失败 |
| 调色、仿色等状态接口 | `0` 成功，负错误值失败 |
| `getLastErrorCode` | `PFSDKErrorCode`，`0` 正常；独立 API 错误应读取其自身返回 |

| 类别 | 公开错误码 |
| :--- | :--- |
| 通用 | `1001` 参数；`1101/1102/1103` 人脸／人体／GL 初始化；`2001～2005` 应用、平台、过期、模块授权、渲染停止；`3001/3002` 未检测到人脸／人体 |
| 调色 | `-200` 参数，`-201` 未授权，`-202` GL，`-203` 缺少资源 |
| 分割 | `-1` 参数，`-2` 未授权，`-3` 不可用，`-4` 推理失败，`-5` 结果无效，`-6` 内部错误 |
| 人脸快照 | `-4101` 参数，`-4102` 快照，`-4103` 重复 ID，`-4104` 未知 ID，`-4105` 源不匹配，`-4106` 未授权，`-4107` 检测不可用，`-4108` 美妆资源，`-4109` 内部错误，`-4110` 贴纸资源 |
| 人体快照 | `-4201/-4202/-4203/-4204/-4205/-4206/-4207/-4209`，分别对应参数／快照／重复 ID／未知 ID／源不匹配／未授权／检测不可用／内部错误 |
| 仿色 | `-4301` 参数，`-4302` 未授权，`-4303` 模型，`-4304` 内部错误 |

## 11. 从旧示例迁移

- 导入当前 `PixelFree` Framework，不再引用旧模块下分散的调色或 HLS 头文件。
- 加载资源使用 `createBeautyItemFormBundleKey:data:size:`；buffer 处理必须提供 `rotationMode:`。
- 调色改用 `PFColorGradingParams`，重新映射 UI 范围，不复用旧量纲。
- 使用真实枚举名称和指针类型；不要硬编码旧美颜枚举序号。
- 将“当前帧查询”“图片快照”“独立分割结果”分别管理，避免混用坐标与生命周期。
