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
    _openGlView = [[PFOpenGLView alloc] initWithFrame:CGRectZero context:nil];
    _openGlView.frame = self.view.bounds;
    [self.view insertSubview:self.openGlView atIndex:0];
    
//    UIButton *lvBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 140, 44)];
//    [lvBtn addTarget:self action:@selector(aclick:) forControlEvents:UIControlEventTouchUpInside];
//    [lvBtn setTitle:@"绿幕分割开" forState:UIControlStateNormal];
//    [lvBtn setTitle:@"绿幕分割关" forState:UIControlStateSelected];
//    [lvBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [self.view addSubview:lvBtn];
    
    UIButton *stickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 140, 44)];
    [stickerBtn addTarget:self action:@selector(watermarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [stickerBtn setTitle:@"添加水印" forState:UIControlStateNormal];
    [stickerBtn setTitle:@"移除水印" forState:UIControlStateSelected];
    [stickerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:stickerBtn];
    
}

-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixbuffer, 0);

    if(pixbuffer){
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        [self.mPixelFree processWithBuffer:pixbuffer rotationMode:PFRotationMode0];
        
        CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
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

-(void)watermarkBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if(btn.selected){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"qiniu_logo.png" ofType:nil];
        PFFiterWatermark setting;
        setting.path = [path UTF8String];
        setting.positionX = 0.8;
        setting.positionY = 0.1;
        setting.w = 110.0/720 * 2;
        setting.h = 34.0/1280 * 2;
        setting.isUse = YES;
        [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterWatermark value:(void *)&setting];
    } else{
        PFFiterWatermark setting;
        setting.isUse = NO;
        [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterWatermark value:(void *)&setting];
    }
}

-(void)dealloc{
    NSLog(@"dealloc------");
}


@end
