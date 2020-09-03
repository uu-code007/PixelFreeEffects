//
//  SMPixelFree.h
//  SMBeautyEngine
//
//  Created by 孙慕 on 2020/7/27.
//  Copyright © 2020 孙慕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "SMFilterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMPixelFree : NSObject


///   初始化 一
///  初始化s内部是否创建glcontext
/// @param isNew  YES 内部创建适用于pixbuffer输入，
///               NO SDK使用外部的glcontext, 初始化时，不知道glcontext。 programe 采用懒加载，第一帧会卡约50ms，如果知道，采用初始化接口二
- (instancetype)initWithProcessNewContext:(BOOL)isNew;


/// 初始化 二
/// @param context 外部glcontext
-(instancetype)initWithProcessContext:(EAGLContext *)context;

/* 动态贴纸 */
@property(nonatomic, strong) SMStickerModel *stickerModel;
/* 美颜 美型 滤镜*/
@property(nonatomic, strong) SMBeautyFilterModel *beautyModel;
/* 美妆相关ss设置 */
@property(nonatomic, strong) SMMakeUpFilterModel *makeupModle;

/**
 处理纹理数据
 
 @param texture 纹理数据
 @param width 宽度
 @param height 高度
 */
- (void)processWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height;

@end

NS_ASSUME_NONNULL_END
