//
//  PFVideoController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFVideoController.h"
#import "PFImageController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/EAGL.h>
#import "UIColor+PFBeautyEditView.h"

@interface PFVideoController ()<PFCameraDelegate>

@end

@implementation PFVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置返回按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    
    _mCamera = [[PFCamera alloc] init];
    [_mCamera startCapture];
//    [_mCamera changeCameraInputDeviceisFront:NO];
    _mCamera.delegate = self;
    _openGlView = [[PFOpenGLView alloc] initWithFrame:CGRectZero context:self.mPixelFree.glContext];
    _openGlView.frame = self.view.bounds;
    _openGlView.contentMode = PFOpenGLViewContentModeScaleAspectFit;
    [self.view insertSubview:self.openGlView atIndex:0];
    
    
    
    
//    UIButton *lvBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 140, 44)];
//    [lvBtn addTarget:self action:@selector(aclick:) forControlEvents:UIControlEventTouchUpInside];
//    [lvBtn setTitle:@"绿幕分割开" forState:UIControlStateNormal];
//    [lvBtn setTitle:@"绿幕分割关" forState:UIControlStateSelected];
//    [lvBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [self.view addSubview:lvBtn];
//    
//    UIButton *stickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 140, 44)];
//    [stickerBtn addTarget:self action:@selector(watermarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [stickerBtn setTitle:@"添加水印" forState:UIControlStateNormal];
//    [stickerBtn setTitle:@"移除水印" forState:UIControlStateSelected];
//    [stickerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [self.view addSubview:stickerBtn];
    
}

-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixbuffer, 0);

    if(pixbuffer && !self.clickCompare && self.mPixelFree){
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        [self.mPixelFree processWithBuffer:pixbuffer rotationMode:PFRotationMode0];
        CFAbsoluteTime durtion = (CFAbsoluteTimeGetCurrent() - startTime);
        
//        float rect[4] = {0};
//        [self.mPixelFree pixelFreeGetFaceRect:rect];
        
//        NSLog(@"faceRect-------x1=%f,y1=%f,x1=%f,x2=%f",rect[0],rect[1],rect[2],rect[3]);
        
        
    }
    [_openGlView displayPixelBuffer:pixbuffer];
    CVPixelBufferUnlockBaseAddress(pixbuffer, 0);


}

-(void)aclick:(UIButton *)btn{
    btn.selected = !btn.selected;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image.jpeg" ofType:nil];
    PFFilterLvmuSetting setting;
    setting.bgSrcPath = [path UTF8String];
    setting.isOpenLvmu = btn.selected;
    
    [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterLvmu value:(void *)&setting];
}

-(void)watermarkBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if(btn.selected){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"qiniu_logo.png" ofType:nil];
        PFFilterWatermark setting;
        setting.path = [path UTF8String];
        setting.positionX = 0.8;
        setting.positionY = 0.1;
        setting.w = 110.0/720 * 2;
        setting.h = 34.0/1280 * 2;
        setting.isUse = YES;
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterWatermark value:(void *)&setting];
    } else{
        PFFilterWatermark setting;
        setting.isUse = NO;
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterWatermark value:(void *)&setting];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 停止相机采集，及时释放资源
    if (_mCamera) {
        [_mCamera stopCapture];
    }
    // 提前清理 OpenGL 视图，避免持有 glContext 引用
    // 注意：这里只移除，不置 nil，因为 dealloc 中会处理
    if (_openGlView) {
        [_openGlView removeFromSuperview];
    }
    // 强制清理 OpenGL 资源，释放 IOSurface 缓存
    if (self.mPixelFree && self.mPixelFree.glContext) {
        [EAGLContext setCurrentContext:self.mPixelFree.glContext];
        // 强制 OpenGL 完成所有待处理的操作
        glFinish();
        [EAGLContext setCurrentContext:nil];
    }
}

-(void)dealloc{
    // 确保停止相机采集
    if (_mCamera) {
        [_mCamera stopCapture];
        _mCamera.delegate = nil;
        _mCamera = nil;
    }
    // 清理OpenGL视图
    if (_openGlView) {
        [_openGlView removeFromSuperview];
        _openGlView = nil;
    }
    NSLog(@"PFVideoController dealloc------");
}


@end
