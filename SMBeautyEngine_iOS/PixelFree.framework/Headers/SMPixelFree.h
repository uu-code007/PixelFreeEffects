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
//#import "SMFilterModel.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((visibility("default"))) @interface SMPixelFree : NSObject

/// 初始化
/// @param context sdk 运行的上线文，context != nil  所有着色器程序将在这里初始化， 否在视频第一帧处理时候初始化
- (instancetype)initWithProcessContext:(EAGLContext *)context srcFilterPath:(NSString *)filterPath srcDetectPath:(NSString *)srcDetectPath authFile:(NSString *)authFile;
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
- (void)processWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height;

/**
处理cpu数据

@param pixelBuffer 纹理数据

@param rotationMode 人脸检测方向

*/
- (void)processWithBuffer:(CVPixelBufferRef)pixelBuffer rotationMode:(PFRotationMode)rotationMode;

/**
图片处理

@param pixelBuffer 纹理数据

@param rotationMode 人脸检测方向

 @return 处理后效果图
*/
- (UIImage *)processWithImage:(UIImage *)image rotationMode:(PFRotationMode)rotationMode;


- (void)pixelFreeSetBeautyFiterParam:(int)key value:(void *)value;

// 加载美颜bundle
- (void)createBeautyItemFormBundle:(void*)data size:(int)sz;


@end

NS_ASSUME_NONNULL_END
