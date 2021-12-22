//
//  FUCamera.m
//  FULiveDemo
//
//  Created by liuyang on 2016/12/26.
//  Copyright © 2016年 liuyang. All rights reserved.
//

#import "FUCamera.h"
#import <UIKit/UIKit.h>



typedef enum : NSUInteger {
    CommonMode,
    PhotoTakeMode,
    VideoRecordMode,
    VideoRecordEndMode,
} RunMode;

typedef void(^FUCameraRecordVidepCompleted)(NSString *videoPath);

@interface FUCamera()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    RunMode runMode;
    BOOL hasStarted;
    BOOL videoHDREnabled;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) AVCaptureDevice *camera;

@property (assign, nonatomic) AVCaptureDevicePosition cameraPosition;

@property (nonatomic, strong) AVCaptureDeviceInput      *audioMicInput;//麦克风输入
@property (nonatomic, strong) AVCaptureAudioDataOutput  *audioOutput;//音频输出
@property (copy, nonatomic) FUCameraRecordVidepCompleted recordVidepCompleted;

@property (assign, nonatomic) AVCaptureSessionPreset mSessionPreset;

@property (nonatomic) FUCameraFocusModel cameraFocusModel;
@end

@implementation FUCamera

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition captureFormat:(int)captureFormat
{
    if (self = [super init]) {
        self.cameraPosition = cameraPosition;
        self.captureFormat = captureFormat;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.cameraPosition = AVCaptureDevicePositionFront;
        self.captureFormat = kCVPixelFormatType_32BGRA;
        videoHDREnabled = YES;
    }
    return self;
}

- (void)startCapture{
    _cameraFocusModel = FUCameraModelAutoFace;
    
    if (![self.captureSession isRunning] && !hasStarted) {
        hasStarted = YES;
//        [self addAudio];
        [self.captureSession startRunning];
        /* 设置曝光中点 */
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:CGPointMake(0.5, 0.5) monitorSubjectAreaChange:YES];
    }
}

- (void)stopCapture{
    hasStarted = NO;
//    [self removeAudio];
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
    NSLog(@"视频采集关闭");
}

- (void)addAudio{
    if ([_captureSession canAddOutput:self.audioOutput]) {
        [_captureSession addOutput:self.audioOutput];
    }
}

- (void)removeAudio {
    [_captureSession removeOutput:self.audioOutput];
}

- (AVCaptureSession *)captureSession
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        
        AVCaptureDeviceInput *deviceInput = self.isFrontCamera ? self.frontCameraInput:self.backCameraInput;
        
        [_captureSession beginConfiguration]; // the session to which the receiver's AVCaptureDeviceInput is added.
        if ([_captureSession canAddInput: deviceInput]) {
            [_captureSession addInput: deviceInput];
        }
        
        if ([_captureSession canAddOutput:self.videoOutput]) {
            [_captureSession addOutput:self.videoOutput];
        }
        
        if ([_captureSession canAddInput:self.audioMicInput]) {
            [_captureSession addInput:self.audioMicInput];
        }
        
        [self addAudio];
        
        [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        if (self.videoConnection.supportsVideoMirroring && self.isFrontCamera) {
            self.videoConnection.videoMirrored = YES;
        }
        

        if ( [deviceInput.device lockForConfiguration:NULL] ) {
            [deviceInput.device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
            [deviceInput.device unlockForConfiguration];
        }
        [_captureSession commitConfiguration]; //
    }
    return _captureSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~");
        }
    }
    self.camera = _backCameraInput.device;
//    if ( [self.camera lockForConfiguration:NULL] ) {
//        self.camera.automaticallyAdjustsVideoHDREnabled = NO;
//        self.camera.videoHDREnabled = videoHDREnabled;
//        [self.camera unlockForConfiguration];
//    }
    
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    self.camera = _frontCameraInput.device;
    
//    if ([self.camera lockForConfiguration:NULL] ) {
//        self.camera.automaticallyAdjustsVideoHDREnabled = NO;
//        self.camera.videoHDREnabled = videoHDREnabled;
//        [self.camera unlockForConfiguration];
//    }


    return _frontCameraInput;
}

- (AVCaptureDeviceInput *)audioMicInput
{
    if (!_audioMicInput) {
        //添加后置麦克风的输出
        
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~");
        }
    }
    return _audioMicInput;
}

- (AVCaptureAudioDataOutput *)audioOutput
{
    if (!_audioOutput) {
        //添加音频输出
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.audioCaptureQueue];
    }
    
    return _audioOutput;
}


//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

-(BOOL)supportsAVCaptureSessionPreset:(BOOL)isFront {
    if (isFront) {
        return [self.frontCameraInput.device supportsAVCaptureSessionPreset:_mSessionPreset];
    }else {
        return [self.backCameraInput.device supportsAVCaptureSessionPreset:_mSessionPreset];
    }
}

//切换前后置摄像头
-(void)changeCameraInputDeviceisFront:(BOOL)isFront {
    [self.captureSession stopRunning];
    if (isFront) {
        [self.captureSession removeInput:self.backCameraInput];
        if ([self.captureSession canAddInput:self.frontCameraInput]) {
            [self.captureSession addInput:self.frontCameraInput];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.camera];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_camera];
            
            NSLog(@"前置添加监听----");
        }
        self.cameraPosition = AVCaptureDevicePositionFront;
    }else {
        [self.captureSession removeInput:self.frontCameraInput];
        if ([self.captureSession canAddInput:self.backCameraInput]) {
            [self.captureSession addInput:self.backCameraInput];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.camera];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_camera];
            NSLog(@"后置添加监听----");
        }
        self.cameraPosition = AVCaptureDevicePositionBack;
    }
    
  
    
    AVCaptureDeviceInput *deviceInput = isFront ? self.frontCameraInput:self.backCameraInput;
    
    [self.captureSession beginConfiguration]; // the session to which the receiver's AVCaptureDeviceInput is added.
    if ( [deviceInput.device lockForConfiguration:NULL] ) {
        [deviceInput.device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
        [deviceInput.device unlockForConfiguration];
    }
    [self.captureSession commitConfiguration];
    
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if (self.videoConnection.supportsVideoMirroring) {
        self.videoConnection.videoMirrored = isFront;
    }
    
    /* 与标准视频稳定相比，这种稳定方法减少了摄像机的视野，在视频捕获管道中引入了更多的延迟，并消耗了更多的系统内存 */
    if(self.videoConnection.supportsVideoStabilization && !isFront) {//前置保持大视野，关闭防抖
        self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
        NSLog(@"activeVideoStabilizationMode = %ld",(long)self.videoConnection.activeVideoStabilizationMode);
    }else {
        NSLog(@"connection don't support video stabilization");
        self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeOff;
    }
    
    [self.captureSession startRunning];
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {

    //    //返回和视频录制相关的所有默认设备
    //    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //    //遍历这些设备返回跟position相关的设备
    //    for (AVCaptureDevice *device in devices) {
    //        if ([device position] == position) {
    //            return device;
    //        }
    //    }
    //    return nil;
    
    if (@available(iOS 10.2, *)) {

        AVCaptureDevice* newDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:position];
        if(!newDevice){
            newDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
        }
        return newDevice;
    }else{
        //返回和视频录制相关的所有默认设备
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        //遍历这些设备返回跟position相关的设备
        for (AVCaptureDevice *device in devices) {
            if ([device position] == position) {
                    return device;
            }
        }
        return nil;
    }
}

- (AVCaptureDevice *)camera
{
    if (!_camera) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if ([device position] == self.cameraPosition)
            {
                _camera = device;
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_camera];
            }
        }
    }
    return _camera;
}

- (AVCaptureVideoDataOutput *)videoOutput
{
    if (!_videoOutput) {
        //输出
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_captureFormat] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [_videoOutput setSampleBufferDelegate:self queue:self.videoCaptureQueue];
    }
    return _videoOutput;
}

//视频采集队列
- (dispatch_queue_t)videoCaptureQueue {
    if (_videoCaptureQueue == nil) {
//        _videoCaptureQueue = dispatch_queue_create("com.faceunity.videoCaptureQueue", NULL);
        _videoCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    return _videoCaptureQueue;
}

//音频采集队列
- (dispatch_queue_t)audioCaptureQueue {
    if (_audioCaptureQueue == nil) {
        _audioCaptureQueue = dispatch_queue_create("com.faceunity.audioCaptureQueue", NULL);
    }
    return _audioCaptureQueue;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.automaticallyAdjustsVideoMirroring =  NO;
    
    return _videoConnection;
}

//设置采集格式
- (void)setCaptureFormat:(int)captureFormat
{
    
    if (_captureFormat == captureFormat) {
        return;
    }

    _captureFormat = captureFormat;
    
    if (((NSNumber *)[[_videoOutput videoSettings] objectForKey:(id)kCVPixelBufferPixelFormatTypeKey]).intValue != captureFormat) {
        
        [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_captureFormat] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        if ([self.camera lockForConfiguration:nil]){
            [self.camera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [self.camera unlockForConfiguration];
        }
    }
    
}

/**
 * 切换回连续对焦和曝光模式
 * 中心店对焦和曝光(centerPoint)
 */
- (void)resetFocusAndExposureModes {
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [self.camera isFocusPointOfInterestSupported] && [self.camera isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [self.camera isExposurePointOfInterestSupported] && [self.camera isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ([self.camera lockForConfiguration:&error]) {
        if (canResetFocus) {
            self.camera.focusMode = focusMode;
            self.camera.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            self.camera.exposureMode = exposureMode;
            self.camera.exposurePointOfInterest = centerPoint;
        }
        [self.camera unlockForConfiguration];
    } else {
        NSLog(@"%@",error);
    }
    
}


- (void)subjectAreaDidChange:(NSNotification *)notification
{
    dispatch_async(self.videoCaptureQueue, ^{
        CGPoint devicePoint = CGPointMake(0.5, 0.5);
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];

        [self cameraChangeModle:FUCameraModelAutoFace];
    });

}


#pragma  mark -  曝光补偿
- (void)setExposureValue:(float)value {
//    NSLog(@"camera----曝光值----%lf",value);
    NSError *error;
    if ([self.camera lockForConfiguration:&error]){
        [self.camera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [self.camera setExposureTargetBias:value completionHandler:nil];
        [self.camera unlockForConfiguration];
    }else{
    }
}


#pragma  mark -  分辨率
-(BOOL)changeSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    
    if ([self.captureSession canSetSessionPreset:sessionPreset]) {
        
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
        _captureSession.sessionPreset = sessionPreset;
        _mSessionPreset = sessionPreset;
        [self.captureSession startRunning];

        return YES;
    }
    return NO;
}

#pragma  mark -  镜像
-(void)changeVideoMirrored:(BOOL)videoMirrored{
    if (self.videoConnection.supportsVideoMirroring) {
        self.videoConnection.videoMirrored = videoMirrored;
    }
}

#pragma  mark -  帧率
-(void)changeVideoFrameRate:(int)frameRate{
    if (frameRate <= 30) {//此方法可以设置相机帧率,仅支持帧率小于等于30帧.
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [videoDevice lockForConfiguration:NULL];
        [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
        [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
        [videoDevice unlockForConfiguration];
        return;
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDeviceFormat *vFormat in [videoDevice formats] ) {
        CMFormatDescriptionRef description= vFormat.formatDescription;
        float maxRate = ((AVFrameRateRange*) [vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
        if (maxRate > frameRate - 1 &&
            CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            if ([videoDevice lockForConfiguration:nil]) {
                /* 设置分辨率的方法activeFormat与sessionPreset是互斥的 */
                videoDevice.activeFormat = vFormat;
                [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
                [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
                [videoDevice unlockForConfiguration];
                break;
            }
        }
    }
}




- (BOOL)focusPointSupported
{
    return self.camera.focusPointOfInterestSupported;
}


- (BOOL)exposurePointSupported
{
    return self.camera.exposurePointOfInterestSupported;
}


- (BOOL)isFrontCamera
{
    return self.cameraPosition == AVCaptureDevicePositionFront;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if([self.delegate respondsToSelector:@selector(didOutputVideoSampleBuffer:)])
    {
        [self.delegate didOutputVideoSampleBuffer:sampleBuffer];
    }
    /* 人脸对焦判断 */
    [self cameraFocusAndExpose];
}

#pragma  mark -  人脸曝光逻辑
-(void)cameraFocusAndExpose{
    if (_cameraFocusModel == FUCameraModelAutoFace) {
        
         if ([self.dataSource respondsToSelector:@selector(faceCenterInImage:)]) {
           CGPoint center =  [self.dataSource faceCenterInImage:self];
            if (center.y >= 0) {
                [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:center monitorSubjectAreaChange:YES];
            }else{
                [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:CGPointMake(0.5, 0.5) monitorSubjectAreaChange:YES];
            }
        }
    }
}



-(void)videpCompleted{
}


- (void)takePhotoAndSave
{
    runMode = PhotoTakeMode;
}

//开始录像
- (void)startRecord
{
    runMode = VideoRecordMode;
}

//停止录像
- (void)stopRecordWithCompletionHandler:(void (^)(NSString *videoPath))handler
{
    self.recordVidepCompleted =  handler;
    runMode = VideoRecordEndMode;

}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    
    CVPixelBufferLockBaseAddress(pixelBufferRef, 0);
    
    CGFloat SW = [UIScreen mainScreen].bounds.size.width;
    CGFloat SH = [UIScreen mainScreen].bounds.size.height;
    
    float width = CVPixelBufferGetWidth(pixelBufferRef);
    float height = CVPixelBufferGetHeight(pixelBufferRef);
    
    float dw = width / SW;
    float dh = height / SH;

    float cropW = width;
    float cropH = height;

    if (dw > dh) {
        cropW = SW * dh;
    }else
    {
        cropH = SH * dw;
    }

    CGFloat cropX = (width - cropW) * 0.5;
    CGFloat cropY = (height - cropH) * 0.5;

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(cropX, cropY,
                                                 cropW,
                                                 cropH)];
    
    UIImage *image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    CVPixelBufferUnlockBaseAddress(pixelBufferRef, 0);
    
    return image;
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

}

- (void)setCaptureVideoOrientation:(AVCaptureVideoOrientation) orientation {
    
    [self.videoConnection setVideoOrientation:orientation];
}

- (void)getCurrentExposureValue:(float *)current max:(float *)max min:(float *)min{
    *min = self.camera.minExposureTargetBias;
    *max = self.camera.maxExposureTargetBias;
    *current = self.camera.exposureTargetBias;

}



- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async(self.videoCaptureQueue, ^{
        AVCaptureDevice *device = self.camera;

        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode] ) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }

            if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode] ) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
        
//            NSLog(@"---point --%@",NSStringFromCGPoint(point));  
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    });
}


-(void)cameraChangeModle:(FUCameraFocusModel)modle
{
    _cameraFocusModel = modle;
}


//缩放
- (CGFloat)maxZoomFactor
{
    return MIN(self.camera.activeFormat.videoMaxZoomFactor, 4.0f);
}

- (void)setZoomValue:(CGFloat)zoomValue
{
    if (!self.camera.isRampingVideoZoom) {
        NSError *error;
        if ([self.camera lockForConfiguration:&error]) {
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
            self.camera.videoZoomFactor = zoomFactor;
            [self.camera unlockForConfiguration];
        }
    }
    
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"camera dealloc");
}
@end
