# pixelFree 商业级美颜SDK

#### 项目介绍

**pixelFree** 是基于个人几年对图形学习，总结开发的SDK, 轻量级高性能，主要用于直播，短视频，证件照.....

主要功能包含：美白，红润，磨皮，锐化，大眼，瘦脸…….

集成接入参考  *pixelFreeEffects* 演示**DEMO**

注：演示所有素材均来源于网络，如有侵权邮件告知（微信号：17376595626）,将第一时间删除

#### 美颜效果 

磨皮的同时，保留更多细节，美化与真实并存

**演示1**  参数：美白（0.6），红润（0.6），磨皮（0.7），锐化（0.2），大眼（1.0），瘦脸（1.0），v脸（1.0），下巴（1.0）

![aaa](./res/comp_effectBeatu.png)

**演示2**：动态贴纸

![dynamic_stickers](./res/dynamic_stickers.png)

#### 美颜全开性能

![aaa](./res/option.png)   

#### 支持的平台系统

|  平台   |  系统  |
| :-----: | :----: |
|   iOS   | > 9.0  |
| Andriod | >  5.0 |
| flutter |   -    |

#### 已经支持适配的音视频厂商

七牛云，声网，腾讯，即构

#### iOS 接入方式

1.  手动接入

    Demo 工程中有接入 PixelFree.framework，参考 demo 接入

2. pod 导入

   ```objective-c
     pod 'PixelFree'
   ```


#### 接入使用

1. 初始化

   ```
   // 素材路径
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"filter_model.bundle" ofType:nil];
    
    // 授权文件
    NSString *authFile = [[NSBundle mainBundle] pathForResource:@"pixelfreeAuth.lic" ofType:nil];
    
    // 初始化实例
    self.mPixelFree = [[SMPixelFree alloc] initWithProcessContext:nil srcFilterPath:face_FiltePath authFile:authFile];
    
   ```

2. 美颜参数设置

    ```
   // 大眼
   [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_EyeStrength value:&value]; 
   ```

3. 滤镜设置 (内置 30 款滤镜 )

   ```
   // 滤镜类型，类型字段查看，滤镜表格
   const char *aaa = [param.mParam UTF8String];
   [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterName value:(void *)aaa];
   // 滤镜程度
   [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterStrength value:&value];
   ```

4. 图像渲染处理，内部会内存回写

   ```
   // pixbuffer 视频数据
   [_mPixelFree processWithBuffer:pixbuffer];
   ```

   
#### 更新日志

**2024-8-2 日更新** SDK v2.4.6

- 支持 flutter 使用
- 提交 flutter PixelFree 插件，以及flutter demo

**2024-5-12 日更新** v2.4.6

- iOS android  demo 优化
- 鉴权优化

**2024-3-25 日更新** v2.4.6

- 新增添加水印接口

**2024-2-28 日更新** v2.4.5

- 更新 android 添加一键美颜

**2024-1-16 日更新** v2.4.5

- 添加动态贴纸
- 适配七牛云音视频 SDK

**2023-12-16 日更新** v2.4.4

- android 低端设备优化
- 支持单纹理处理

**2023-11-11 日更新** v2.4.3
- 支持返回内部纹理返回
- android 改用 aar 包接入

**2023-10-09 日更新** v2.4.1
- 新增眼睛旋转
- 新增微笑嘴角

**2023-09-09 日更新** v2.4.0
- 新增一键美颜
- 包体与 CPU 优化

**2023-08-12 日更新** v2.3.3
伟大优化，性能提升 30%
- 磨皮优化
- GPU 指令优化

**2023-07-20 日更新** v2.3.2

- 优化美型效果，美型形变显得更加真实

**2023-07-4 日更新** v2.3.1

- 新增道具贴纸
- 优化内存

**2023-02-4 日更新** v2.3.0

- 新增绿幕背景替换实现，一件替换背景图片
- 背景视频替换，完成 FFmpege 解码，接口未开放，待续

**2022-09-30 日更新** v2.2.0

- iOS 添加 UIImage 图片处理接口，

**2022-09-3 日更新** v2.0.1

1. add andriod JNI and Demo
2. 调优美型算法

**2021-11-20 日更新** v2.0.0

1. c++ 重构sdk
2. 提供 SO 库
3. 移除动态贴纸，3D贴纸功能

**2020-12-31 日更新** v1.1.2

1. 修复异常crash

2. 美型切换到cpu上执行，通过网格减少运算，降低gpu负荷

**2020-12-05 日更新** v1.1.0

1. 添加3D贴纸（使用配置json，仅测试了.obj格式模型）

2. 添加新美白（阴影保护的更好，减少噪点引入）

3. 新增画质增强功能

4. 修复滤镜造成画面异常bug

**2020-10-11 日更新**

- 架构 日志系统，code_type，具备远程分析能力 ；默认LogLevelDebug。

**2020-9-20 日更新**  v1.0.3

1. 效果优化:

- **目前只有texture接口，算法需要数据，需要glFinish() 阻塞，render耗时 +3ms,但是大大提升了贴纸跟随**

2. 修复bug

- 人脸快速消失，crash问题
- 第一次进入会鉴权失败问题 

iphone 8 **测试**
*CPU:68%*   **cpu 百分比有提升，但是只跑了4个核**
*渲染耗时：*

|            | 打开项（美白,红润,磨皮,锐化,滤镜,大眼,瘦脸,V脸,下巴） |
| ---------- | :---------------------------------------------------: |
| 耗时（ms） |          8.2ms （+3ms来自cpu获取数据的阻塞）          |



**2020-9-12 日更新**

优化：

- 去除drawCall, 去除多余gl指令，

iphone 8 **测试**
*CPU:54%*
*渲染耗时：*

|            | 打开项（美白,红润,磨皮,锐化,滤镜,大眼,瘦脸,V脸,下巴） |
| ---------- | :---------------------------------------------------: |
| 耗时（ms） |                         4.6ms                         |



**2020-9-5 日更新**

优化：

- 异步人脸检测

- 缓存高代价对象

iphone 8 **测试**
*CPU:56%*
*渲染耗时：*

|            | 打开项（美白,红润,磨皮,锐化,滤镜,大眼,瘦脸,V脸,下巴） |
| ---------- | :---------------------------------------------------: |
| 耗时（ms） |                         5.2ms                         |

不开人脸变形耗时6.4ms,原因：功能少的时候，CPU 只开了 4核



**2020-9-3 日更新**

基于对美颜，美型，滤镜，贴纸，美妆原理理解。实现高质量美颜SDK **pixelFree.framework ** ,版本 v1.0.1

*iphone 8* **测试**

*CPU:54%*

*渲染耗时：*

|            | 打开项（美白,红润,磨皮,锐化,滤镜,大眼,瘦脸,V脸,下巴） |
| ---------- | :---------------------------------------------------: |
| 耗时（ms） |                        18.6ms                         |


####  Android 体验 demo
![android 体验](./res/qrcode_www.pgyer.com.png)

####  iOS 体验 demo



![iOS 体验](./res/testflight_apple.png)







