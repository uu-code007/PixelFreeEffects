//
//  PFVideoController.h
//  SMBeautyEngine_iOS
//
//  Created by pixelfree on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "PFCamera.h"
#import "PFOpenGLView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PFVideoController : ViewController
@property (nonatomic,strong) PFCamera *mCamera;

@property (nonatomic,strong) PFOpenGLView *openGlView;

@end

NS_ASSUME_NONNULL_END
