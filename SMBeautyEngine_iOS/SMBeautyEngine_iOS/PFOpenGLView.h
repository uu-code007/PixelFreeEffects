//
//  PFOpenGLView.h
//
//  Created by mumu on 2021/9/6.
//

#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, PFOpenGLViewOrientation) {
    PFOpenGLViewOrientationPortrait              = 0,
    PFOpenGLViewOrientationLandscapeRight        = 1,
    PFOpenGLViewOrientationPortraitUpsideDown    = 2,
    PFOpenGLViewOrientationLandscapeLeft         = 3,
};

typedef NS_ENUM(NSInteger, PFOpenGLViewContentMode) {
    /* 等比例短边充满 */
    PFOpenGLViewContentModeScaleAspectFill       = 0,
    /* 拉伸铺满 */
    PFOpenGLViewContentModeScaleToFill           = 1,
     /* 等比例长边充满 */
    PFOpenGLViewContentModeScaleAspectFit        = 2,

};


@interface PFOpenGLView : UIView

/* 视频填充模式 */
@property (nonatomic, assign) PFOpenGLViewContentMode contentMode;
// 设置视频朝向，保证视频总是竖屏播放
@property (nonatomic, assign) PFOpenGLViewOrientation origintation;
@property (nonatomic, assign) NSInteger disapplePointIndex ;


-(instancetype)initWithFrame:(CGRect)frame context:(nonnull EAGLContext *)context;


- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer withLandmarks:(float *)landmarks count:(int)count MAX:(BOOL)max;

- (void)displayImageData:(void *)imageData Size:(CGSize)size Landmarks:(float *)landmarks count:(int)count zoomScale:(float)zoomScale;

- (void)displayImageData:(void *)imageData withSize:(CGSize)size Center:(CGPoint)center Landmarks:(float *)landmarks count:(int)count;

/* 同步渲染 */
- (void)displaySyncPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
