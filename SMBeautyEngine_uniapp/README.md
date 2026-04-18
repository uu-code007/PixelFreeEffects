# PixelFree 美颜 SDK - UniApp 版本

基于 Flutter 版本实现的 UniApp 原生插件，提供完整的美颜功能支持。

## 🚀 快速开始

### 在 HBuilderX 中打开

1. 打开 HBuilderX
2. **文件** → **打开目录** → 选择 `SMBeautyEngine_uniapp` 目录
3. 添加资源文件（见下方）
4. **运行** → **运行到手机或模拟器** → 选择 Android/iOS

### 添加资源文件（必须）

1. **授权文件**: 将 `pixelfreeAuth.lic` 复制到 `static/` 目录
2. **模型文件**: 将 `filter_model.bundle` 复制到 `src/main/assets/` 目录（Android）
3. **SDK 库文件**: 
   - Android: 将 SDK jar/aar 放到 `nativeplugins/PixelFreeModule/android/libs/`
   - iOS: 在 Xcode 中添加 PixelFree.framework

### 创建必要目录

在 HBuilderX 中创建以下目录（如果不存在）：
- `pages/demo` - 复制 `examples/example.vue` 到 `pages/demo/example.vue`
- `static` - 放授权文件
- `nativeplugins/PixelFreeModule/android` - 复制 `native/android/*` 到此处
- `nativeplugins/PixelFreeModule/ios` - 复制 `native/ios/*` 到此处

## 使用示例

```javascript
import PixelFree, { PFBeautyFiterType } from '@/js_sdk/pixelfree.js';

// 初始化
await PixelFree.createWithLic('/static/pixelfreeAuth.lic');

// 设置美颜参数
await PixelFree.pixelFreeSetBeautyFilterParam(PFBeautyFiterType.eyeStrength, 0.5);

// 处理图片
const textureID = await PixelFree.processWithImage(imageData, width, height);
```

## 目录结构

```
SMBeautyEngine_uniapp/
├── pages/              # 页面
│   ├── index/         # 首页
│   └── demo/          # 示例页面（需创建）
├── js_sdk/            # JS SDK
├── native/            # 原生插件源码
├── examples/          # 示例代码
├── manifest.json      # 项目配置
└── pages.json         # 页面路由
```

## API 文档

通用接口说明见仓库根目录：

- [Android API 文档](../doc/api_android.md)
- [iOS API 文档](../doc/api_iOS.md)
- [Flutter API 文档](../doc/api_flutter.md)

### 美体（v2.5.06+）

与美颜美型独立，`key` 为 `PFBodyBeautyType` 整型（0～22），`value` 为 **0.0～1.0**（**0.5 中性**）。对照表见 [api_android.md 美体章节](../doc/api_android.md#美体参数v2506) / [api_iOS.md](../doc/api_iOS.md#美体参数v2506)。

当前 UniApp 原生插件需在 Android `PixelFreeModule` / iOS 插件中增加对 `pixelFreeSetBodyBeautyParam` 的封装后，再在 `js_sdk/pixelfree.js` 中暴露对应方法。
