# PixelFree iOS 接入指南

[项目概览](../README.md) · [iOS API](./api_iOS.md) · [Android 接入](./doc_android.md)

本文以仓库当前的 [SMPixelFree.h](../SMBeautyEngine_iOS/PixelFree.framework/Headers/SMPixelFree.h)、[C 类型定义](../SMBeautyEngine_iOS/PixelFree.framework/Headers/pixelFree_c.hpp) 和 [调色参数](../SMBeautyEngine_iOS/PixelFree.framework/Headers/PFColorGradingParams.h) 为准。示例使用 Objective-C++（`.mm`）和 ARC，只调用交付包的公开接口。

## 1. 集成准备

| 项目 | 当前要求 |
| :--- | :--- |
| Framework | [PixelFree.framework](../SMBeautyEngine_iOS/PixelFree.framework)，动态 Framework，加入目标的链接与 Embed & Sign 配置 |
| 系统与架构 | 当前包为 iPhoneOS `arm64`，包声明最低 iOS 12.0；[Demo](../SMBeautyEngine_iOS) 部署目标为 iOS 15.0，不含模拟器切片 |
| 头文件 | `#import <PixelFree/SMPixelFree.h>` |
| 图形环境 | OpenGL ES；渲染、参数更新、资源加载与销毁在同一串行队列上管理 |
| 授权 | 提供与应用 Bundle ID、平台、有效期和功能匹配的 `pixelfreeAuth.lic` |

将配套资源加入应用目标的 Copy Bundle Resources，使用实际文件路径加载。不要仅替换二进制而沿用旧头文件或旧模型。本页采用仓库交付包手动接入，不将旧 Pod 版本视为当前接口的替代品。

| 资源 | 用途 | 加载入口 |
| :--- | :--- | :--- |
| `filter_model.bundle` | 基础美颜及相关资源 | 初始化的 `srcFilterPath` |
| `pixelfreeAuth.lic` | 授权 | 初始化的 `authFile` |
| `body_model.bundle` | 人体检测、美体及相关功能 | `PFSrcTypeHumanProcessor` |
| `skin_src.bundle` | 肤色调整 | `PFSrcTypeSkinSrc` |
| 美妆包 | 妆容资源 | `PFSrcTypeMakeup` |
| 贴纸／LUT | 特效素材 | 对应路径接口，见 [API](./api_iOS.md) |

采集、预览、音视频编码和图片保存由应用负责。先使用基础美颜确认图像链路，再按授权和资源启用其他功能。

## 2. 创建并复用引擎

下列函数接收应用已解析好的资源路径；例如可用 `NSBundle` 的 `pathForResource:ofType:` 查找应用内文件。初始化失败应由上层停止提交帧并提示资源或环境问题。

```objective-c++
#import <PixelFree/SMPixelFree.h>

SMPixelFree *CreateBeautyEngine(NSString *modelPath, NSString *licensePath) {
    if (modelPath.length == 0 || licensePath.length == 0) return nil;
    EAGLContext *previous = [EAGLContext currentContext];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context || ![EAGLContext setCurrentContext:context]) return nil;

    SMPixelFree *engine = [[SMPixelFree alloc] initWithProcessContext:context
                                                    srcFilterPath:modelPath
                                                         authFile:licensePath];
    if (engine) {
        [engine setDetectMode:PF_FACE_DETECT_MODE_VIDEO];
        float smoothing = 0.5f;
        [engine pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceBlurStrength
                                       value:&smoothing];
    }
    [EAGLContext setCurrentContext:previous];
    return engine;
}
```

将返回的实例保存在业务对象的强引用属性中，整个会话复用。实例创建成功不代表所有模块均已授权；配置或处理后检查 `getLastErrorCode`，独立功能还需检查其返回值。

## 3. 处理相机帧

常规 buffer 入口接受 BGRA 和双平面 NV12 `CVPixelBufferRef`。旋转参数使用 `PFRotationMode0/90/180/270`，应与输入图像方向匹配。调用会回写输入像素，返回时输出可用；需要保留原图时先创建工作副本。

```objective-c++
int ProcessVideoFrame(SMPixelFree *engine, CVPixelBufferRef pixelBuffer,
                      PFRotationMode rotation) {
    if (!engine || !pixelBuffer) return -1;
    EAGLContext *previous = [EAGLContext currentContext];
    if (![EAGLContext setCurrentContext:engine.glContext]) return -1;
    int texture = [engine processWithBuffer:pixelBuffer rotationMode:rotation];
    int error = [engine getLastErrorCode];
    if (texture < 0 || error != 0) {
        NSLog(@"PixelFree render=%d, lastError=%d", texture, error);
    }
    [EAGLContext setCurrentContext:previous];
    return texture;
}
```

这里的 `int` 返回值是纹理 ID 或负错误值，不是统一的“0 成功”状态码。示例中的 `-1` 也用于应用侧参数／上下文检查失败。若后续只使用回写后的 CPU 像素，无需使用纹理 ID。

在相机回调外异步处理时，应用必须在入队前持有 `CVPixelBufferRef`，完成后释放，并避免采集端与处理端同时改写同一帧。不要阻塞主线程执行逐帧处理。

### 直接处理已有纹理

在 `engine.glContext` 当前有效的队列上调用 `processWithTexture:width:height:rotation:`。该接口原位处理输入纹理，成功返回同一纹理 ID，不进行 CPU 输出读回。纹理必须在该上下文可访问；其他图形 API 或不共享上下文的纹理不能只传 ID 使用。

## 4. 加载可选资源

在与渲染相同的串行队列、有效 GL 上下文中加载。下例先检查资源内容和长度，再调用当前带类型参数的加载方法。

```objective-c++
#include <limits.h>

BOOL LoadEffectBundle(SMPixelFree *engine, NSString *path, PFSrcType type) {
    if (!engine || path.length == 0) return NO;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0 || data.length > INT_MAX) return NO;
    [engine createBeautyItemFormBundleKey:type
                                    data:(void *)data.bytes
                                    size:(int)data.length];
    return [engine getLastErrorCode] == 0;
}
```

例如将人体资源与 `PFSrcTypeHumanProcessor` 配对，将肤色资源与 `PFSrcTypeSkinSrc` 配对。加载 API 返回 `void`；上面的布尔值是应用对最近错误码的检查，不是 SDK 的原始返回值。

## 5. 开启调色与图片编辑

专业调色通过一个 `PFColorGradingParams` 配置，随下一次正常处理自动应用，不需要另外串联一次美颜处理。

```objective-c++
int ApplyGrading(SMPixelFree *engine) {
    PFColorGradingParams params;
    PF_initColorGradingParams(&params);
    params.contrast = 0.1f;
    params.temperature = 0.05f;
    return [engine pixelFreeSetColorGrading:&params];
}
```

该设置接口返回 `0` 成功或负错误码。复原调色调用 `pixelFreeResetColorGrading`。

图片场景有两种接法：

| 场景 | 接入方式 |
| :--- | :--- |
| 全图统一参数 | `setDetectMode:PF_FACE_DETECT_MODE_IMAGE`；每次从原图副本调用 `processWithBuffer:rotationMode:`，换图或改变方向时 `resetDetectState` |
| 逐人脸／逐人体编辑 | 先 `detectFacesWithBuffer:rotationMode:`／`detectBodiesWithBuffer:rotationMode:` 获取快照，再传入逐人配置渲染；换源图、裁剪或变形后重新检测 |

需要 `UIImage` 便捷入口时使用 `processWithImage:rotationMode:`。多人快照、独立分割和仿色的完整示例见 [API 文档](./api_iOS.md)，不要把实时检测框接口当成独立快照查询接口。

## 6. 生命周期与错误处理

- 停止采集或提交帧后，等待已入队操作完成，再在引擎所属处理队列与 GL 上下文中释放强引用。`SMPixelFree` 没有公开的 Objective-C `release()` 方法；ARC 负责对象释放。
- 不同线程不能同时把同一个 GL 上下文设为当前并执行渲染。参数、资源切换与销毁必须和帧处理串行。
- 帧缓冲、配置数组和素材路径对应的数据必须在同步调用返回前保持有效且不被修改。
- 人脸／人体快照需要在渲染结束前持有；iOS 的关键点和 Mask 指针是借用视图，不得超出所属结果对象的生命周期。
- 分割的 `NSError`、渲染返回的负值、调色／仿色状态码与 `getLastErrorCode` 属于不同错误通道，应分别检查。

| 现象 | 优先检查 |
| :--- | :--- |
| 找不到头文件或类型 | Framework 搜索路径、`PixelFree` 模块名、全部配套头文件是否同步更新 |
| 模拟器无法链接 | 当前包只含 iPhoneOS arm64，使用真机或另行获取匹配的模拟器交付包 |
| 有画面但效果不生效 | 授权功能、资源加载、参数中性值、检测结果和最近错误码 |
| 图像方向或遮罩叠加不正确 | 输入旋转、RAW 与方向校正后的坐标区别、显示层镜像 |
| 滑杆反复调节后变形累积 | 是否每次都从未处理的原图生成工作副本 |
| 分割返回错误 | 输入是否为 BGRA／全范围 NV12、请求类型是否可用、授权和资源是否满足 |

## 后续阅读

- [iOS API：参数、逐人编辑、分割、调色与仿色](./api_iOS.md)
- [Android API](./api_android.md)
- [自定义贴纸](./custom_stickers.md)
- [常见问题](./frequently_asked_questions.md)





