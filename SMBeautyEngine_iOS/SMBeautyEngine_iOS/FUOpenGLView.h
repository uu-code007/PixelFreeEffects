//
//  FUOpenGLView.h
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/15.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, FUOpenGLViewOrientation) {
    FUOpenGLViewOrientationPortrait              = 0,
    FUOpenGLViewOrientationLandscapeRight        = 1,
    FUOpenGLViewOrientationPortraitUpsideDown    = 2,
    FUOpenGLViewOrientationLandscapeLeft         = 3,
};

typedef NS_ENUM(NSInteger, FUOpenGLViewContentMode) {
    /* 等比例短边充满 */
    FUOpenGLViewContentModeScaleAspectFill       = 0,
    /* 拉伸铺满 */
    FUOpenGLViewContentModeScaleToFill           = 1,
     /* 等比例长边充满 */
    FUOpenGLViewContentModeScaleAspectFit        = 2,

};


@interface FUOpenGLView : UIView

/* 视频填充模式 */
@property (nonatomic, assign) FUOpenGLViewContentMode contentMode;
// 设置视频朝向，保证视频总是竖屏播放
@property (nonatomic, assign) FUOpenGLViewOrientation origintation;
@property (nonatomic, assign) NSInteger disapplePointIndex ;


-(instancetype)initWithFrame:(CGRect)frame context:(nonnull EAGLContext *)context;


- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer withLandmarks:(float *)landmarks count:(int)count MAX:(BOOL)max;

- (void)displayImageData:(void *)imageData Size:(CGSize)size Landmarks:(float *)landmarks count:(int)count zoomScale:(float)zoomScale;

- (void)displayImageData:(void *)imageData withSize:(CGSize)size Center:(CGPoint)center Landmarks:(float *)landmarks count:(int)count;

/* 同步渲染 */
- (void)displaySyncPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
