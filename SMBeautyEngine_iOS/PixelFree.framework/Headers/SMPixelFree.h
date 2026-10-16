//
//  SMPixelFree.h
//  SMBeautyEngine
//
//  Created by mumu on 2020/7/27.
//  Copyright © 2020 孙慕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "pixelFree_c.hpp"
NS_ASSUME_NONNULL_BEGIN

/// Immutable snapshot. Borrowed face views remain valid for this object's lifetime.
/// Public face views always contain 168 points (336 interleaved x,y floats),
/// in the same layout as pixelFreeGetFaceLandmarks168, including estimated points.
__attribute__((visibility("default"))) @interface SMPixelFreeFaceDetection : NSObject
@property(nonatomic, readonly) NSInteger faceCount;
- (BOOL)getFaceInfo:(PFDetectedFaceInfo *)info atIndex:(NSInteger)index;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/// Immutable owned snapshot, including across subsequent detection/reset calls.
/// Body info contains IDs and a normalized upright [0,1] rect, top-left origin.
/// Keypoints remain internal; IDs are local to this snapshot.
__attribute__((visibility("default"))) @interface SMPixelFreeBodyDetection : NSObject
@property(nonatomic, readonly) NSInteger bodyCount;
- (BOOL)getBodyInfo:(PFDetectedBodyInfo *)info atIndex:(NSInteger)index;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

__attribute__((visibility("default"))) @interface SMPixelFree : NSObject

/// 初始化
/// @param context sdk 运行的上线文，context != nil  所有着色器程序将在这里初始化， 否在视频第一帧处理时候初始化
- (instancetype)initWithProcessContext:(EAGLContext *)context srcFilterPath:(NSString *)filterPath authFile:(NSString *)authFile;
/*!
 @property glContext
 @brief OpenGL context
 
 @since v1.0.0
 */
@property(nonatomic, strong, readonly) EAGLContext* glContext;

/**
 处理纹理数据
 
 @param texture 纹理数据
 @param width 宽度
 @param height 高度
 */
- (int)processWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height rotation:(PFRotationMode)rotation;

/**
处理cpu数据

@param pixelBuffer 纹理数据

@param rotationMode 人脸检测方向

*/
- (int)processWithBuffer:(CVPixelBufferRef)pixelBuffer rotationMode:(PFRotationMode)rotationMode;

/// Synchronous detection only; supports BGRA and bi-planar NV12 pixel buffers.
/// Requires valid advanced beauty (BeautyV2) authorization; basic beauty and
/// style-only certificates cannot create snapshots or access their landmarks.
/// Returns nil on invalid input, authorization or detector failure.
- (nullable SMPixelFreeFaceDetection *)detectFacesWithBuffer:(CVPixelBufferRef)pixelBuffer
                                               rotationMode:(PFRotationMode)rotationMode;
/// Renders all supplied face tasks in snapshot order; zero tasks is global-only.
/// Keep buffers/config arrays immutable until this synchronous call returns.
- (int)processWithBuffer:(CVPixelBufferRef)pixelBuffer
           rotationMode:(PFRotationMode)rotationMode
          faceDetection:(SMPixelFreeFaceDetection *)faceDetection
            faceConfigs:(nullable const PFFaceRenderConfig *)faceConfigs
                  count:(int)count;
/// Image-only per-face stickers; does not inherit the camera's global sticker.
- (int)processWithBuffer:(CVPixelBufferRef)pixelBuffer
           rotationMode:(PFRotationMode)rotationMode
          faceDetection:(SMPixelFreeFaceDetection *)faceDetection
            faceConfigs:(nullable const PFFaceRenderConfig *)faceConfigs
                  count:(int)count
         stickerConfigs:(nullable const PFFaceStickerConfig *)stickerConfigs
           stickerCount:(int)stickerCount;

/// Synchronous CPU-only detection; supports BGRA and bi-planar NV12 buffers.
/// Requires body authorization and a loaded body_model.bundle; no GL work.
/// Never modifies input pixels. Returns nil on invalid input or detection failure.
- (nullable SMPixelFreeBodyDetection *)detectBodiesWithBuffer:(CVPixelBufferRef)pixelBuffer
                                               rotationMode:(PFRotationMode)rotationMode;
/// Renders supplied body tasks in snapshot order without new body inference.
/// Zero tasks disables body effects; unspecified body parameters are neutral.
/// Rerender from the original source with the same rotation and engine instance.
/// Keep buffers/config arrays immutable until this synchronous call returns.
- (int)processWithBuffer:(CVPixelBufferRef)pixelBuffer
           rotationMode:(PFRotationMode)rotationMode
          bodyDetection:(SMPixelFreeBodyDetection *)bodyDetection
            bodyConfigs:(nullable const PFBodyRenderConfig *)bodyConfigs
              bodyCount:(int)bodyCount;
/// Unified image render; at least one snapshot is required. A nil face snapshot
/// requires count=stickerCount=0; a nil body snapshot requires bodyCount=0.
/// Missing categories are disabled, with no legacy face/body, makeup or sticker
/// fallback. Global color/filter stages run once. Source/lifetime rules above apply.
- (int)processWithBuffer:(CVPixelBufferRef)pixelBuffer
           rotationMode:(PFRotationMode)rotationMode
          faceDetection:(nullable SMPixelFreeFaceDetection *)faceDetection
            faceConfigs:(nullable const PFFaceRenderConfig *)faceConfigs
                  count:(int)count
         stickerConfigs:(nullable const PFFaceStickerConfig *)stickerConfigs
           stickerCount:(int)stickerCount
          bodyDetection:(nullable SMPixelFreeBodyDetection *)bodyDetection
            bodyConfigs:(nullable const PFBodyRenderConfig *)bodyConfigs
              bodyCount:(int)bodyCount;

/**
图片处理

@param image 纹理数据

@param rotationMode 人脸检测方向

 @return 处理后效果图
*/
- (UIImage *)processWithImage:(UIImage *)image rotationMode:(PFRotationMode)rotationMode;


- (void)pixelFreeSetBeautyFilterParam:(int)key value:(void *)value;

// 获取最近一次功能设置/渲染后的错误码，0 表示正常。
- (int)getLastErrorCode;

// 设置外部 256x256 LUT 滤镜。path 传 nil/空字符串或 enabled=NO 可关闭。
- (int)pixelFreeSetExternalFilterWithPath:(nullable NSString *)path intensity:(float)intensity enabled:(BOOL)enabled;
- (int)pixelFreeClearExternalFilter;
- (int)pixelFreeSetSkinToneFilter:(PFSkinToneFilterParams *)params;
- (int)pixelFreeClearSkinToneFilter;

// 美体参数
- (void)pixelFreeSetBodyBeautyParam:(int)key value:(void *)value;
- (int)pixelFreeGetBodyLongLegControl:(PFBodyLongLegControl *)control;
- (int)pixelFreeSetBodyLongLegControl:(const PFBodyLongLegControl *_Nullable)control;

// 切换图片/视频源时调用，清空人脸与人体检测/跟踪缓存。
// IMAGE 模式会复用人脸、人体及相关 AI 结果；换图或图像方向变化后调用此接口失效缓存。
- (void)resetDetectState;

// 加载美颜bundle
- (void)createBeautyItemFormBundleKey:(int)key data:(void*)data size:(int)sz;

- (void)pixelFreeGetFaceRect:(float *)faceRect;
// 每张脸写入 x, y, x1, y1（相对输入图归一化，原点左上）。maxCount 是 faceRects 能容纳的人脸数。
- (int)pixelFreeGetFaceRects:(float *)faceRects maxCount:(int)maxCount;
// 与 GetFaceRects 同序，写入检测器人脸 id。
- (int)pixelFreeGetFaceIds:(int *)faceIds maxCount:(int)maxCount;
// 每张脸 168 点，x,y 交错。points 至少 maxFaces * 336 个 float。需要高级证书中的美型授权，否则返回 0。
- (int)pixelFreeGetFaceLandmarks168:(float *)points maxFaces:(int)maxFaces;

- (int)getPixelFreeFaceNum;

// 设置图片检测模式
- (void)setDetectMode:(int)mode;

// 获取是否检测到人脸
- (int)hasFace;
// 获取最近一次处理是否检测到人体
- (int)hasHuman;
// index 对应最近一次检测顺序；rect 为原始输入图左上原点、0~1 归一化坐标。
- (int)pixelFreeGetHumanCount;
- (int)pixelFreeGetHumanInfo:(PFHumanDetectionInfo *)info atIndex:(int)index;
- (int)pixelFreeGetHumanRects:(float *)rects maxCount:(int)maxCount;
// -1 恢复原有美体处理。先 IMAGE 模式处理一次再选择；reset 后清除选择。
// 长腿保持原全宽拉伸，切换人体只更新锁定的髋部高度。
- (int)pixelFreeSetBodyBeautyTargetIndex:(int)index;
// -2 表示图片人体缓存已失效；处理完成后重新选择，期间暂停美体。
- (int)pixelFreeGetBodyBeautyTargetIndex;
// 设置是否开启人体/人像分割，默认关闭；需先加载 body_model.bundle。
- (void)pixelFreeSetHumanSegmentationEnabled:(BOOL)enabled;
// 获取最近一次处理的人像分割结果；返回 1 表示 result 中有可用 mask。
- (int)pixelFreeGetHumanSegmentationResult:(PFHumanSegmentationResult *)result;
// 按人体 index 获取最近一次处理的人像分割结果；index 从 0 开始。
- (int)pixelFreeGetHumanSegmentationResultAtIndex:(int)index result:(PFHumanSegmentationResult *)result;

// 图片调色设置
- (int)pixelFreeSetColorGrading:(PFImageColorGrading *)imageColorGrading;

// HLS 功能
- (int)pixelFreeAddHLSFilter:(PFHLSFilterParams*)HLSFilterParams;
- (int)pixelFreeDeleteHLSFilter:(int)handle;
- (int)pixelFreeChangeHLSFilter:(int)handle params:(PFHLSFilterParams*)HLSFilterParams;

// 自定义贴纸专属
- (void)pixelFreeSetFiterStickerWithPath:(NSString *)path;

- (int)pixelFreeSetMakeupWithJsonPath:(NSString *)jsonPath;
- (int)clearMakeup;

// 设置美妆部位程度（与配置叠乘）
- (void)pixelFreeSetMakeupPart:(int)part degree:(float)degree;
// 设置美妆是否使用面部遮挡分割；开启后妆只作用在非遮挡区域，默认开启
- (void)pixelFreeSetMakeupFaceOccuEnabled:(BOOL)enabled;

// 设置是否开启皮肤分割（Skin Mask），默认开启
- (void)pixelFreeSetSkinMaskEnabled:(BOOL)enabled;
// 设置是否开启 mask 磨皮，默认关闭
- (void)pixelFreeSetSmoothSkinMaskEnabled:(BOOL)enabled;

// 设置是否输出日志到控制台（全局开关）
- (void)setConsoleLogEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
