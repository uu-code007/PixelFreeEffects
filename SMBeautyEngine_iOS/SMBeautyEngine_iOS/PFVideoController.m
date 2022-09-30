//
//  PFVideoController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFVideoController.h"
#import "PFImageController.h"

@interface PFVideoController ()<PFCameraDelegate>

@end

@implementation PFVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mCamera = [[PFCamera alloc] init];
    [_mCamera startCapture];
//    [_mCamera changeCameraInputDeviceisFront:NO];
    _mCamera.delegate = self;
    _openGlView = [[PFOpenGLView alloc] initWithFrame:CGRectZero context:self.mPixelFree.glContext];
    _openGlView.frame = self.view.bounds;
    [self.view insertSubview:self.openGlView atIndex:0];
}

-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixbuffer, 0);
    
    if(pixbuffer){
        [self.mPixelFree processWithBuffer:pixbuffer rotationMode:PFRotationMode0];
//        NSLog(@"render 耗时: %f ms", endTime * 1000.0);
    }
    [_openGlView displayPixelBuffer:pixbuffer];
    CVPixelBufferUnlockBaseAddress(pixbuffer, 0);
}

@end
