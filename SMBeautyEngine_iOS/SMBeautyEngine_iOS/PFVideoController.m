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
    
//    UIButton *lvBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 140, 44)];
//    [lvBtn addTarget:self action:@selector(aclick:) forControlEvents:UIControlEventTouchUpInside];
//    [lvBtn setTitle:@"绿幕分割开" forState:UIControlStateNormal];
//    [lvBtn setTitle:@"绿幕分割关" forState:UIControlStateSelected];
//    [lvBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [self.view addSubview:lvBtn];
    
//    UIButton *stickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 140, 44)];
//    [stickerBtn addTarget:self action:@selector(stickerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [stickerBtn setTitle:@"添加贴纸" forState:UIControlStateNormal];
//    [stickerBtn setTitle:@"移除贴纸" forState:UIControlStateSelected];
//    [stickerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [self.view addSubview:stickerBtn];
    
}

-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixbuffer, 0);

    if(pixbuffer){
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        [self.mPixelFree processWithBuffer:pixbuffer rotationMode:PFRotationMode0];
        
        CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
//        NSLog(@"方法耗时: %f ms", endTime * 1000.0);
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

-(void)stickerBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if(btn.selected){
        NSString *path =  [[NSBundle mainBundle] pathForResource:@"Stickers" ofType:nil];
        NSString *currentFolder = [path stringByAppendingPathComponent:@"flowers_glasses"];
        const char *aaa = [currentFolder UTF8String];
        
        NSString *paths = [[NSBundle mainBundle] pathForResource:@"flowers_glasses.boudle" ofType:nil];
         [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterSticker2DFilter value:(void *)[paths UTF8String]];
    } else{
        [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterSticker2DFilter value:NULL];
    }

}

-(void)dealloc{
    NSLog(@"dealloc------");
}


@end
