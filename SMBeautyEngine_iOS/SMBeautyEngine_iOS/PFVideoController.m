//
//  PFVideoController.m
//  SMBeautyEngine_iOS
//
//  Created by pixelfree on 2022/9/29.
//

#import "PFVideoController.h"
#import "PFImageController.h"
#import "SMVideoConfiguration.h"
#import "SMAudioConfiguration.h"
#import "SMEncoder.h"
#import "SMUtilFunctions.h"


@interface PFVideoController ()<PFCameraDelegate,SMEncoderDelegate>

@property (strong, nonatomic) SMVideoConfiguration *videoConfiguration;
@property (strong, nonatomic) SMAudioConfiguration *audioConfiguration;
@property (strong, nonatomic) SMEncoder *videoRecorder;

@property (assign, nonatomic)  bool isRecodering;

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
    
    //    UIButton *stickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 140, 44)];
    //    [stickerBtn addTarget:self action:@selector(watermarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [stickerBtn setTitle:@"添加水印" forState:UIControlStateNormal];
    //    [stickerBtn setTitle:@"移除水印" forState:UIControlStateSelected];
    //    [stickerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //    [self.view addSubview:stickerBtn];
    
    
    // 录制
    //    UIButton *recorderBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 140, 44)];
    //    [recorderBtn addTarget:self action:@selector(recorderBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [recorderBtn setTitle:@"录制视频" forState:UIControlStateNormal];
    //    [recorderBtn setTitle:@"停止录制" forState:UIControlStateSelected];
    //    [recorderBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //    [self.view addSubview:recorderBtn];
    
    //    self.videoConfiguration = [SMVideoConfiguration defaultConfiguration];
    //    self.audioConfiguration = [SMAudioConfiguration defaultConfiguration];
    //    self.videoRecorder = [[SMEncoder alloc] initWithVideoConfiguration:self.videoConfiguration audioConfiguration:self.audioConfiguration];
    
}

-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixbuffer, 0);
    
    if(pixbuffer && !self.clickCompare){
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        [self.mPixelFree processWithBuffer:pixbuffer rotationMode:PFRotationMode0];
        
        CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
        
        if (_videoRecorder && _videoRecorder.isEncoding && self.isRecodering) {
            
            CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            float playbackRate = 2.0;
            CMTime adjustedTime = CMTimeMultiplyByFloat64(currentTime, playbackRate);
            
            CMSampleTimingInfo timingInfo = {0};
            timingInfo.duration = CMTimeMake(1, 30); // 假设目标帧率为15 FPS
            timingInfo.presentationTimeStamp = adjustedTime;
            
            CMSampleBufferRef sampleBuffer = SMCreateSampleBufferFromCVPixelBuffer(pixbuffer, timingInfo);
            [_videoRecorder asyncEncode:sampleBuffer isVideo:YES];
            CFRelease(sampleBuffer);
        }
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

-(void)recorderBtnBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.videoRecorder startEncodingToOutputFileURL:[self getFileURL] encodingDelegate:self];
        self.isRecodering = YES;
    } else {
        [self.videoRecorder stopEncoding];
        self.isRecodering = NO;
    }
    
}


- (NSURL *)getFileURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"TestPath"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        // 如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    NSURL *fileURL = [NSURL fileURLWithPath:fileName];
    
    return fileURL;
}

-(void)dealloc{
    NSLog(@"dealloc------");
}


@end
