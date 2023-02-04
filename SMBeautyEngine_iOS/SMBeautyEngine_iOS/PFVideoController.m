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
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithTitle:@"绿幕分割开关" style:UIBarButtonItemStyleBordered target:self action:@selector(aclick:)];
     
    self.navigationItem.rightBarButtonItem = btnItem;
}

-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixbuffer, 0);
    
    if(pixbuffer){
        [self.mPixelFree processWithBuffer:pixbuffer rotationMode:PFRotationMode0];
    }
    [_openGlView displayPixelBuffer:pixbuffer];
    CVPixelBufferUnlockBaseAddress(pixbuffer, 0);
}

-(void)aclick:(UIButton *)btn{
    btn.selected = !btn.selected;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image.jpeg" ofType:nil];
    PFFiterLvmuSetting setting;
    setting.bgSrcPath = [path UTF8String];
    setting.isOpenLvmu = btn.selected;
    
    [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterLvmu value:(void *)&setting];
}



@end
