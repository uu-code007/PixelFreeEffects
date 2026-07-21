//
//  PFImageController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFImageController.h"
#import <Vision/Vision.h>
#import "UIColor+PFBeautyEditView.h"
#import "PFBeautyEditView.h"

#import "ToolUI.h"
#import "AdjustmentItem.h"
#import "AdjustmentItem.h"
#import "PFHLSToolView.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import "PFFilterView.h"
#import "PFBeautyParam.h"
#import "PFOpenGLView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/EAGL.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <math.h>

@interface PFImageController ()<PFMuViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PFFilterViewDelegate,UIGestureRecognizerDelegate> {
    PFImageColorGrading mColorGrading ;
    PFHLSFilterParams  mHLSFilterParams;
    int handle;
}

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)PFOpenGLView *openGlView;
@property(nonatomic,assign)CVPixelBufferRef sourcePixelBuffer;
@property(nonatomic,assign)CVPixelBufferRef renderPixelBuffer;
@property(nonatomic,strong)UIView *videoControlView;
@property(nonatomic,strong)UIButton *videoPlayButton;
@property(nonatomic,strong)UISlider *videoProgressSlider;
@property(nonatomic,strong)AVAsset *videoAsset;
@property(nonatomic,strong)AVPlayer *videoPlayer;
@property(nonatomic,strong)AVPlayerItemVideoOutput *videoOutput;
@property(nonatomic,strong)CADisplayLink *videoDisplayLink;
@property(nonatomic,strong)AVAssetImageGenerator *videoImageGenerator;
@property(nonatomic,strong)CIContext *videoCIContext;
@property(nonatomic,assign)NSTimeInterval videoDuration;
@property(nonatomic,assign)NSTimeInterval videoCurrentTime;
@property(nonatomic,assign)CGAffineTransform videoPreferredTransform;
@property(nonatomic,assign)CGAffineTransform videoPlaybackTransform;
@property(nonatomic,assign)CGSize videoNaturalSize;
@property(nonatomic,assign)CGSize videoGeneratorFrameSize;
@property(nonatomic,assign)CGSize videoCompositionRenderSize;
@property(nonatomic,assign)NSUInteger videoOrientationLogCount;
@property(nonatomic,assign)BOOL isVideoMode;
@property(nonatomic,assign)BOOL isVideoPlaying;
@property(nonatomic,assign)BOOL isVideoSliderTracking;
@property(nonatomic,assign)BOOL wasVideoPlayingBeforeScrubbing;
@property(nonatomic,assign)NSUInteger videoFrameRequestID;

/** NSTimer */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSRunLoop *mRunLoop;


@property (nonatomic, strong) ToolUI *toolUI;
@property (nonatomic, strong) ToolUI *bodyToolUI;
@property (nonatomic, strong) ToolUI *skinDetailToolUI;

@property (nonatomic, strong) PFHLSToolView *hlsToolView;

@property (nonatomic, assign) CGRect lvRect;
@property (nonatomic, strong) UIGestureRecognizer *panGesture;
@property (nonatomic, strong) UIGestureRecognizer *pinchGesture;
@property (nonatomic, assign) PFBeautyEditViewModuleType currentModuleType;
@property (nonatomic, weak) id<UIGestureRecognizerDelegate> previousInteractivePopGestureDelegate;
@property (nonatomic, assign) BOOL previousInteractivePopGestureEnabled;
@property (nonatomic, assign) BOOL hasDisabledInteractivePopGesture;
@property (nonatomic, strong) UIImage *debugHumanMaskImage;



@end

@implementation PFImageController

- (void)pf_disablePreviewPopGesture {
    UIGestureRecognizer *popGesture = self.navigationController.interactivePopGestureRecognizer;
    if (!popGesture) {
        return;
    }
    if (!self.hasDisabledInteractivePopGesture) {
        self.previousInteractivePopGestureDelegate = popGesture.delegate;
        self.previousInteractivePopGestureEnabled = popGesture.enabled;
        self.hasDisabledInteractivePopGesture = YES;
    }
    // 同时设置 enabled 和 delegate。即使系统稍后重新启用手势，delegate 也会拒绝开始。
    popGesture.enabled = NO;
    popGesture.delegate = self;
}

- (void)pf_restorePreviewPopGestureIfNeeded {
    if (!self.hasDisabledInteractivePopGesture) {
        return;
    }
    UIGestureRecognizer *popGesture = self.navigationController.interactivePopGestureRecognizer;
    popGesture.delegate = self.previousInteractivePopGestureDelegate;
    popGesture.enabled = self.previousInteractivePopGestureEnabled;
    self.hasDisabledInteractivePopGesture = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO;
    }
    return YES;
}

- (void)pf_cleanupRenderingResources {
    [self.timer invalidate];
    self.timer = nil;
    [self pf_clearVideoState];
    if (_mRunLoop) {
        CFRunLoopStop([_mRunLoop getCFRunLoop]);
        _mRunLoop = nil;
    }
    if (_openGlView) {
        [_openGlView removeFromSuperview];
        _openGlView = nil;
    }
    if (self.mPixelFree && self.mPixelFree.glContext) {
        [EAGLContext setCurrentContext:self.mPixelFree.glContext];
        glFinish();
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)pf_releasePixelBuffers {
    if (_sourcePixelBuffer) {
        CVBufferRelease(_sourcePixelBuffer);
        _sourcePixelBuffer = NULL;
    }
    if (_renderPixelBuffer) {
        CVBufferRelease(_renderPixelBuffer);
        _renderPixelBuffer = NULL;
    }
}

- (void)pf_setupVideoControls {
    self.videoControlView = [[UIView alloc] initWithFrame:CGRectZero];
    self.videoControlView.hidden = YES;
    self.videoControlView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.42];
    self.videoControlView.layer.cornerRadius = 8;
    self.videoControlView.clipsToBounds = YES;
    [self.view addSubview:self.videoControlView];

    self.videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.videoPlayButton.tintColor = [UIColor whiteColor];
    self.videoPlayButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.16];
    self.videoPlayButton.layer.cornerRadius = 18;
    [self.videoPlayButton addTarget:self action:@selector(pf_videoPlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView addSubview:self.videoPlayButton];

    self.videoProgressSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    self.videoProgressSlider.minimumValue = 0.0f;
    self.videoProgressSlider.maximumValue = 1.0f;
    self.videoProgressSlider.value = 0.0f;
    self.videoProgressSlider.minimumTrackTintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    self.videoProgressSlider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.35];
    [self.videoProgressSlider addTarget:self action:@selector(pf_videoSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.videoProgressSlider addTarget:self action:@selector(pf_videoSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoProgressSlider addTarget:self action:@selector(pf_videoSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.videoControlView addSubview:self.videoProgressSlider];

    [self pf_updateVideoPlayButton];
}

- (void)pf_layoutVideoControls {
    if (!self.videoControlView || !self.openGlView) {
        return;
    }

    CGFloat margin = 16.0;
    CGFloat controlHeight = 48.0;
    CGFloat previewTop = CGRectGetMinY(self.openGlView.frame);
    CGFloat previewBottom = CGRectGetMaxY(self.openGlView.frame);
    CGFloat y = previewBottom - controlHeight - 12.0;
    if (y < previewTop + 12.0) {
        y = previewTop + 12.0;
    }

    self.videoControlView.frame = CGRectMake(margin,
                                             y,
                                             CGRectGetWidth(self.view.bounds) - margin * 2.0,
                                             controlHeight);
    self.videoPlayButton.frame = CGRectMake(10.0, 6.0, 36.0, 36.0);
    self.videoProgressSlider.frame = CGRectMake(CGRectGetMaxX(self.videoPlayButton.frame) + 12.0,
                                                0,
                                                CGRectGetWidth(self.videoControlView.bounds) - CGRectGetMaxX(self.videoPlayButton.frame) - 24.0,
                                                controlHeight);
    [self.view bringSubviewToFront:self.videoControlView];
}

- (void)pf_updateVideoControls {
    self.videoControlView.hidden = !self.isVideoMode;
    if (!self.isVideoMode) {
        return;
    }

    if (!self.isVideoSliderTracking && self.videoDuration > 0) {
        NSTimeInterval currentTime = CMTimeGetSeconds(self.videoPlayer.currentTime);
        if (isfinite(currentTime)) {
            self.videoCurrentTime = MIN(MAX(currentTime, 0), self.videoDuration);
        }
        self.videoProgressSlider.value = (float)(self.videoCurrentTime / self.videoDuration);
    }
    [self pf_updateVideoPlayButton];
}

- (void)pf_updateVideoPlayButton {
    NSString *imageName = self.isVideoPlaying ? @"pause.fill" : @"play.fill";
    [self.videoPlayButton setImage:[UIImage systemImageNamed:imageName] forState:UIControlStateNormal];
}

- (void)pf_videoPlayButtonTapped:(UIButton *)sender {
    if (!self.isVideoMode || self.videoDuration <= 0 || !self.videoPlayer) {
        return;
    }

    if (self.isVideoPlaying) {
        [self.videoPlayer pause];
        self.isVideoPlaying = NO;
        self.videoDisplayLink.paused = YES;
        [self pf_updateVideoControls];
        return;
    }

    NSTimeInterval currentTime = CMTimeGetSeconds(self.videoPlayer.currentTime);
    if (isfinite(currentTime) && currentTime >= self.videoDuration) {
        __weak typeof(self) weakSelf = self;
        [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!finished || !weakSelf.isVideoMode) {
                    return;
                }
                weakSelf.videoCurrentTime = 0;
                [weakSelf.videoPlayer play];
                weakSelf.isVideoPlaying = YES;
                weakSelf.videoDisplayLink.paused = NO;
                [weakSelf pf_updateVideoControls];
            });
        }];
    } else {
        [self.videoPlayer play];
        self.isVideoPlaying = YES;
        self.videoDisplayLink.paused = NO;
        [self pf_updateVideoControls];
    }
}

- (void)pf_startVideoDisplayLink {
    if (self.videoDisplayLink) {
        self.videoDisplayLink.paused = !self.isVideoPlaying;
        return;
    }

    self.videoDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(pf_videoDisplayLinkTick:)];
    if (@available(iOS 15.0, *)) {
        self.videoDisplayLink.preferredFrameRateRange = CAFrameRateRangeMake(24, 30, 30);
    } else {
        self.videoDisplayLink.preferredFramesPerSecond = 30;
    }
    self.videoDisplayLink.paused = !self.isVideoPlaying;
    [self.videoDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)pf_videoDisplayLinkTick:(CADisplayLink *)displayLink {
    if (!self.isVideoMode || !self.videoOutput || !self.videoPlayer.currentItem || self.isVideoSliderTracking) {
        return;
    }

    CFTimeInterval hostTime = CACurrentMediaTime();
    CMTime itemTime = [self.videoOutput itemTimeForHostTime:hostTime];
    if (![self.videoOutput hasNewPixelBufferForItemTime:itemTime]) {
        [self pf_updateVideoControls];
        return;
    }

    CVPixelBufferRef playerPixelBuffer = [self.videoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:NULL];
    if (!playerPixelBuffer) {
        [self pf_updateVideoControls];
        return;
    }

    NSString *rawBufferSizeForLog = nil;
    if (self.videoOrientationLogCount < 8) {
        rawBufferSizeForLog = PFVideoPixelBufferSizeString(playerPixelBuffer);
    }

    CVPixelBufferRef orientedPixelBuffer = PFCreateBGRAOrientedPixelBuffer(playerPixelBuffer,
                                                                           self.videoPlaybackTransform,
                                                                           self.videoCIContext);
    CVBufferRelease(playerPixelBuffer);
    if (!orientedPixelBuffer) {
        [self pf_updateVideoControls];
        return;
    }

    if (self.videoOrientationLogCount < 8) {
        NSTimeInterval seconds = CMTimeGetSeconds(itemTime);
        NSLog(@"[PFVideoOrientation] playFrame #%lu itemTime=%.3f rawBuffer=%@ orientedBuffer=%@ natural=%@ generatorFrame=%@ compositionRender=%@ preferredTransform=%@ playbackTransform=%@",
              (unsigned long)self.videoOrientationLogCount,
              isfinite(seconds) ? seconds : -1.0,
              rawBufferSizeForLog,
              PFVideoPixelBufferSizeString(orientedPixelBuffer),
              PFVideoSizeString(self.videoNaturalSize),
              PFVideoSizeString(self.videoGeneratorFrameSize),
              PFVideoSizeString(self.videoCompositionRenderSize),
              PFVideoTransformString(self.videoPreferredTransform),
              PFVideoTransformString(self.videoPlaybackTransform));
        self.videoOrientationLogCount++;
    }

    CVPixelBufferRef renderBuffer = PFCreatePixelBufferLike(orientedPixelBuffer);
    if (!renderBuffer) {
        CVBufferRelease(orientedPixelBuffer);
        return;
    }

    @synchronized (self) {
        if (self.sourcePixelBuffer) {
            CVBufferRelease(self.sourcePixelBuffer);
        }
        self.sourcePixelBuffer = orientedPixelBuffer;
        if (self.renderPixelBuffer) {
            CVBufferRelease(self.renderPixelBuffer);
        }
        self.renderPixelBuffer = renderBuffer;
        self.image = nil;
    }

    if (self.clickCompare) {
        [self.openGlView displayPixelBuffer:orientedPixelBuffer];
    } else {
        [self.mPixelFree processWithBuffer:renderBuffer rotationMode:PFRotationMode0];
        [self pf_updateDetectHintNeedsFace:[self pf_currentModuleNeedsFaceHint] needsHuman:[self pf_currentModuleNeedsHumanHint]];
        [self.openGlView displayPixelBuffer:renderBuffer];
    }

    [self pf_updateVideoControls];
}

- (void)pf_videoSliderTouchDown:(UISlider *)slider {
    if (!self.isVideoMode) {
        return;
    }

    self.isVideoSliderTracking = YES;
    self.wasVideoPlayingBeforeScrubbing = self.isVideoPlaying;
    self.isVideoPlaying = NO;
    [self.videoPlayer pause];
    self.videoDisplayLink.paused = YES;
    [self pf_updateVideoControls];
}

- (void)pf_videoSliderValueChanged:(UISlider *)slider {
    if (!self.isVideoMode || self.videoDuration <= 0) {
        return;
    }

    NSTimeInterval targetTime = slider.value * self.videoDuration;
    @synchronized (self) {
        self.videoCurrentTime = targetTime;
    }
    [self pf_seekVideoToTime:targetTime resetDetectState:NO resumeWhenDone:NO];
}

- (void)pf_videoSliderTouchUp:(UISlider *)slider {
    if (!self.isVideoMode || self.videoDuration <= 0) {
        return;
    }

    NSTimeInterval targetTime = slider.value * self.videoDuration;
    @synchronized (self) {
        self.isVideoSliderTracking = NO;
        self.isVideoPlaying = self.wasVideoPlayingBeforeScrubbing;
        self.videoCurrentTime = targetTime;
    }
    [self pf_seekVideoToTime:targetTime resetDetectState:YES resumeWhenDone:self.wasVideoPlayingBeforeScrubbing];
    [self pf_updateVideoControls];
}

static CVPixelBufferRef PFCreatePixelBufferFromUIImage(UIImage *image) {
    if (!image || !image.CGImage) return NULL;
    const size_t width = CGImageGetWidth(image.CGImage);
    const size_t height = CGImageGetHeight(image.CGImage);
    NSDictionary *attrs = @{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES
    };
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn ret = CVPixelBufferCreate(kCFAllocatorDefault,
                                       width,
                                       height,
                                       kCVPixelFormatType_32BGRA,
                                       (__bridge CFDictionaryRef)attrs,
                                       &pixelBuffer);
    if (ret != kCVReturnSuccess || pixelBuffer == NULL) return NULL;

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(baseAddress,
                                             width,
                                             height,
                                             8,
                                             bytesPerRow,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!ctx) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVBufferRelease(pixelBuffer);
        return NULL;
    }
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image.CGImage);
    CGContextRelease(ctx);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

static void PFCopyPixelBuffer(CVPixelBufferRef src, CVPixelBufferRef dst) {
    if (!src || !dst) return;
    CVPixelBufferLockBaseAddress(src, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferLockBaseAddress(dst, 0);
    const size_t srcHeight = CVPixelBufferGetHeight(src);
    const size_t dstHeight = CVPixelBufferGetHeight(dst);
    const size_t srcBytesPerRow = CVPixelBufferGetBytesPerRow(src);
    const size_t dstBytesPerRow = CVPixelBufferGetBytesPerRow(dst);
    const size_t copyBytesPerRow = MIN(srcBytesPerRow, dstBytesPerRow);
    uint8_t *srcBase = (uint8_t *)CVPixelBufferGetBaseAddress(src);
    uint8_t *dstBase = (uint8_t *)CVPixelBufferGetBaseAddress(dst);
    for (size_t y = 0; y < MIN(srcHeight, dstHeight); ++y) {
        memcpy(dstBase + y * dstBytesPerRow, srcBase + y * srcBytesPerRow, copyBytesPerRow);
    }
    CVPixelBufferUnlockBaseAddress(dst, 0);
    CVPixelBufferUnlockBaseAddress(src, kCVPixelBufferLock_ReadOnly);
}

static CVPixelBufferRef PFCreatePixelBufferLike(CVPixelBufferRef sourcePixelBuffer) {
    if (!sourcePixelBuffer) return NULL;

    NSDictionary *attrs = @{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES
    };
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn ret = CVPixelBufferCreate(kCFAllocatorDefault,
                                       CVPixelBufferGetWidth(sourcePixelBuffer),
                                       CVPixelBufferGetHeight(sourcePixelBuffer),
                                       CVPixelBufferGetPixelFormatType(sourcePixelBuffer),
                                       (__bridge CFDictionaryRef)attrs,
                                       &pixelBuffer);
    if (ret != kCVReturnSuccess || !pixelBuffer) {
        return NULL;
    }

    PFCopyPixelBuffer(sourcePixelBuffer, pixelBuffer);
    return pixelBuffer;
}

static NSString *PFVideoSizeString(CGSize size) {
    return [NSString stringWithFormat:@"%.1fx%.1f", size.width, size.height];
}

static NSString *PFVideoPixelBufferSizeString(CVPixelBufferRef pixelBuffer) {
    if (!pixelBuffer) return @"null";
    return [NSString stringWithFormat:@"%zux%zu",
            CVPixelBufferGetWidth(pixelBuffer),
            CVPixelBufferGetHeight(pixelBuffer)];
}

static NSString *PFVideoTransformString(CGAffineTransform transform) {
    return [NSString stringWithFormat:@"[a=%.3f b=%.3f c=%.3f d=%.3f tx=%.3f ty=%.3f]",
            transform.a,
            transform.b,
            transform.c,
            transform.d,
            transform.tx,
            transform.ty];
}

static AVMutableVideoComposition *PFCreatePreferredTransformVideoComposition(AVAssetTrack *videoTrack,
                                                                            CMTime duration,
                                                                            CGSize *renderSizeOut) {
    if (!videoTrack) return nil;

    CGSize naturalSize = videoTrack.naturalSize;
    if (naturalSize.width <= 0 || naturalSize.height <= 0) {
        return nil;
    }

    CGAffineTransform preferredTransform = videoTrack.preferredTransform;
    CGRect transformedRect = CGRectApplyAffineTransform(CGRectMake(0, 0, naturalSize.width, naturalSize.height),
                                                        preferredTransform);
    CGSize renderSize = CGSizeMake(ceil(fabs(CGRectGetWidth(transformedRect))),
                                   ceil(fabs(CGRectGetHeight(transformedRect))));
    if (renderSize.width <= 0 || renderSize.height <= 0) {
        return nil;
    }

    CGAffineTransform finalTransform = preferredTransform;
    if (fabs(CGRectGetMinX(transformedRect)) > 0.001 ||
        fabs(CGRectGetMinY(transformedRect)) > 0.001) {
        finalTransform = CGAffineTransformConcat(preferredTransform,
                                                 CGAffineTransformMakeTranslation(-CGRectGetMinX(transformedRect),
                                                                                  -CGRectGetMinY(transformedRect)));
    }

    AVMutableVideoCompositionLayerInstruction *layerInstruction =
        [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInstruction setTransform:finalTransform atTime:kCMTimeZero];

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    CMTime compositionDuration = CMTIME_IS_VALID(duration) && CMTimeCompare(duration, kCMTimeZero) > 0
        ? duration
        : videoTrack.timeRange.duration;
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, compositionDuration);
    instruction.layerInstructions = @[layerInstruction];

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = @[instruction];
    videoComposition.renderSize = renderSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    if (renderSizeOut) {
        *renderSizeOut = renderSize;
    }
    return videoComposition;
}

static CVPixelBufferRef PFCreateBGRAOrientedPixelBuffer(CVPixelBufferRef sourcePixelBuffer,
                                                        CGAffineTransform preferredTransform,
                                                        CIContext *ciContext) {
    if (!sourcePixelBuffer) return NULL;
    if (CGAffineTransformEqualToTransform(preferredTransform, CGAffineTransformIdentity)) {
        return PFCreatePixelBufferLike(sourcePixelBuffer);
    }
    if (!ciContext) return NULL;

    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:sourcePixelBuffer];
    CIImage *orientedImage = [sourceImage imageByApplyingTransform:preferredTransform];
    CGRect extent = orientedImage.extent;
    if (CGRectIsEmpty(extent) ||
        !isfinite(CGRectGetWidth(extent)) ||
        !isfinite(CGRectGetHeight(extent))) {
        return NULL;
    }

    const size_t width = (size_t)MAX(1.0, ceil(CGRectGetWidth(extent)));
    const size_t height = (size_t)MAX(1.0, ceil(CGRectGetHeight(extent)));
    orientedImage = [orientedImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-CGRectGetMinX(extent),
                                                                                            -CGRectGetMinY(extent))];

    NSDictionary *attrs = @{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES
    };
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn ret = CVPixelBufferCreate(kCFAllocatorDefault,
                                       width,
                                       height,
                                       kCVPixelFormatType_32BGRA,
                                       (__bridge CFDictionaryRef)attrs,
                                       &pixelBuffer);
    if (ret != kCVReturnSuccess || !pixelBuffer) {
        return NULL;
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    [ciContext render:orientedImage
      toCVPixelBuffer:pixelBuffer
               bounds:CGRectMake(0, 0, width, height)
           colorSpace:colorSpace];
    CGColorSpaceRelease(colorSpace);
    return pixelBuffer;
}

static UIImage *PFCreateImageFromHumanSegmentationResult(const PFHumanSegmentationResult *result) {
    if (!result || !result->maskData || result->width <= 0 || result->height <= 0) {
        return nil;
    }
    
    const int width = result->width;
    const int height = result->height;
    const int pixelCount = width * height;
    if (result->count < pixelCount) {
        return nil;
    }
    
    NSMutableData *rgbaData = [NSMutableData dataWithLength:(NSUInteger)pixelCount * 4];
    uint8_t *pixels = (uint8_t *)rgbaData.mutableBytes;
    for (int i = 0; i < pixelCount; ++i) {
        float maskValue = result->maskData[i];
        if (!isfinite(maskValue)) {
            maskValue = 0.0f;
        }
        maskValue = fminf(fmaxf(maskValue, 0.0f), 1.0f);
        uint8_t gray = (uint8_t)lrintf(maskValue * 255.0f);
        pixels[i * 4 + 0] = gray;
        pixels[i * 4 + 1] = gray;
        pixels[i * 4 + 2] = gray;
        pixels[i * 4 + 3] = 255;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)rgbaData);
    CGImageRef cgImage = CGImageCreate((size_t)width,
                                       (size_t)height,
                                       8,
                                       32,
                                       (size_t)width * 4,
                                       colorSpace,
                                       kCGImageAlphaLast | kCGBitmapByteOrder32Big,
                                       provider,
                                       NULL,
                                       false,
                                       kCGRenderingIntentDefault);
    UIImage *image = cgImage ? [UIImage imageWithCGImage:cgImage] : nil;
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    // 设置返回按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(0, 0, 44, 44); // 标准导航栏按钮尺寸
    [albumBtn setImage:[UIImage imageNamed:@"tab_album_nor"] forState:UIControlStateNormal];

    // 3. 添加点击事件（更安全的内存管理写法）
    [albumBtn addTarget:self
                 action:@selector(albumBtnClick:)
       forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:albumBtn];

    // 5. 设置导航栏按钮（考虑iOS 11+的布局兼容）
    if (@available(iOS 11.0, *)) {
        albumBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        barButtonItem.imageInsets = UIEdgeInsetsMake(0, -15, 0, 0); // 调整位置
    }

    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    
//        _image = [UIImage imageNamed:@"IMG_2406"];
//    _image = [UIImage imageNamed:@"2631742911906_.pic_hd.jpg"];
//    _image = [UIImage imageNamed:@"image_src"];
    
//    _image = [UIImage imageNamed:@"diamge"];
    _image = [UIImage imageNamed:@"IMG_1580"];
//    _image = [UIImage imageNamed:@"IMG_1580_fleck_flaw_clean_tf_compare"];
    
    
    float x = 0;
    float y = 0;
    
    // 计算图片显示区域（考虑导航栏和安全区域）
    // 注意：在 viewDidLoad 时导航栏可能还没有布局完成，所以使用固定值
    // 实际布局会在 viewDidLayoutSubviews 中更新
    CGFloat topMargin = 80;
    CGFloat bottomReserve = 300;
    CGFloat spacing = 10;
    CGFloat imageHeight = self.view.bounds.size.height - topMargin - bottomReserve - spacing * 2;
    if (imageHeight < 200) {
        imageHeight = 200; // 最小高度
    }
    
    _openGlView = [[PFOpenGLView alloc] initWithFrame:CGRectMake(x, topMargin, self.view.frame.size.width, imageHeight)
                                               context:self.mPixelFree.glContext];
    _openGlView.contentMode = PFOpenGLViewContentModeScaleAspectFit;
    [self.view insertSubview:_openGlView atIndex:0];
    [self pf_setupVideoControls];
    
    
    // 初始化调节项
    NSArray<AdjustmentItem *> *adjustmentItems = @[
        [[AdjustmentItem alloc] initWithName:@"亮度" value:0.0 minValue:-1.0 maxValue:1.0], // brightness
        [[AdjustmentItem alloc] initWithName:@"对比度" value:1.0 minValue:0.0 maxValue:4.0], // contrast
        [[AdjustmentItem alloc] initWithName:@"曝光" value:0.0 minValue:-10.0 maxValue:10.0], // exposure
        [[AdjustmentItem alloc] initWithName:@"高光" value:0.0 minValue:-1.0 maxValue:1.0], // highlights
        [[AdjustmentItem alloc] initWithName:@"阴影" value:0.0 minValue:-1.0 maxValue:1.0], // shadows
        [[AdjustmentItem alloc] initWithName:@"饱和度" value:1.0 minValue:0.0 maxValue:2.0], // saturation
        [[AdjustmentItem alloc] initWithName:@"色温" value:5000.0 minValue:0.0 maxValue:10000.0], // temperature
        [[AdjustmentItem alloc] initWithName:@"色相" value:0.0 minValue:0.0 maxValue:360.0] // hue
    ];
    
    // 初始化调节项
    NSArray<AdjustmentItem *> *adjustmentItems2 = @[
        [[AdjustmentItem alloc] initWithName:@"色相" value:0.0 minValue:-0.45 maxValue:0.45], // brightness
        [[AdjustmentItem alloc] initWithName:@"饱和度" value:1.0 minValue:0.3 maxValue:1.8], // contrast
        [[AdjustmentItem alloc] initWithName:@"明亮度" value:0.0 minValue:-3.0 maxValue:3.0], // exposure
        [[AdjustmentItem alloc] initWithName:@"相似度" value:0.8 minValue:0.0 maxValue:1.0], // exposure
    ];
    
    CGFloat compactAuxToolH = 400.0 * 0.5;

    // 创建 ToolUI（调色）
    self.toolUI = [[ToolUI alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - compactAuxToolH, self.view.bounds.size.width, compactAuxToolH) adjustmentItems:adjustmentItems];
    self.toolUI.hidden = YES;
    [self.view addSubview:self.toolUI];
    
    // 设置滑动事件回调
    __weak typeof(self) weakSelf = self;
    self.toolUI.sliderValueChangedBlock = ^(AdjustmentItem *item) {
        [weakSelf handleSliderValueChanged:item];
    };

    // 创建美体 ToolUI：使用 AdjustmentItem 包装 body 参数
    // 美体调节项（瘦身栏 + 其它）
    NSArray<AdjustmentItem *> *bodyItems = @[
        // 瘦身栏：瘦身 / 瘦肚子 / 瘦腰 / 沙漏腰 / 曲线 / 全身瘦
        [[AdjustmentItem alloc] initWithName:@"瘦身"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"瘦肚子" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"瘦腰"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"沙漏腰" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"曲线"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"全身瘦" value:0.5 minValue:0.0 maxValue:1.0],
        // 其它美体项
        [[AdjustmentItem alloc] initWithName:@"提跨"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"丰臀"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"丰胸"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"长腿"   value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"天鹅颈" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"瘦肩膀" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"直角肩" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"左大臂" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"左小臂" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"右大臂" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"右小臂" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"左大腿" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"左小腿" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"右大腿" value:0.5 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"右小腿" value:0.5 minValue:0.0 maxValue:1.0],
    ];
    self.bodyToolUI = [[ToolUI alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - compactAuxToolH, self.view.bounds.size.width, compactAuxToolH) adjustmentItems:bodyItems];
    self.bodyToolUI.hidden = YES;
    [self.view addSubview:self.bodyToolUI];

    self.bodyToolUI.sliderValueChangedBlock = ^(AdjustmentItem *item) {
        [weakSelf handleBodySliderValueChanged:item];
    };

    NSArray<AdjustmentItem *> *skinDetailItems = @[
        [[AdjustmentItem alloc] initWithName:@"纹理" value:0.0 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"清晰" value:0.0 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"高光" value:0.0 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"水光" value:0.0 minValue:0.0 maxValue:1.0],
        [[AdjustmentItem alloc] initWithName:@"哑光" value:0.0 minValue:0.0 maxValue:1.0],
    ];
    self.skinDetailToolUI = [[ToolUI alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - compactAuxToolH, self.view.bounds.size.width, compactAuxToolH) adjustmentItems:skinDetailItems];
    self.skinDetailToolUI.hidden = YES;
    [self.view addSubview:self.skinDetailToolUI];

    self.skinDetailToolUI.sliderValueChangedBlock = ^(AdjustmentItem *item) {
        [weakSelf handleSkinDetailSliderValueChanged:item];
    };

    _hlsToolView = [[PFHLSToolView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - compactAuxToolH, self.view.bounds.size.width, compactAuxToolH) Colors:nil adjustmentItems:adjustmentItems2];
    _hlsToolView.hidden = YES;
    _hlsToolView.mDelegate = self;
    [self.view addSubview:_hlsToolView];
    
    // 创建美妆列表视图
    
    PFImageColorGrading ColorGrading = {
        .isUse = false,
        .brightness = 0.0f,
        .contrast = 1.0f,
        .exposure = 0.0f,
        .highlights = 0.0f,
        .shadows = 0.0f,
        .saturation = 1.0f,
        .temperature = 5000.0f,
        .tint = 0.0f,
        .hue = 0.0f
    };
    mColorGrading = ColorGrading;
    
    PFHLSFilterParams HLSFilterParams = {
        .brightness = 0.0f,
        .saturation = 1.0f,
        .hue = 0.0f,
        .similarity = 0.8
    };
    HLSFilterParams.key_color[0] = 0.75;
    HLSFilterParams.key_color[1] = 0.24;
    HLSFilterParams.key_color[2] = 0.31;
    
    mHLSFilterParams = HLSFilterParams;
    
    handle = [self.mPixelFree pixelFreeAddHLSFilter:&mHLSFilterParams];

    
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"body_model.bundle" ofType:nil];
    
    NSData *date1 = [NSData dataWithContentsOfFile:face_FiltePath];

    [self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeHumanProcessor data:(void *)date1.bytes size:(int)date1.length];
    
    // 设置图片检测模式
//    [self.mPixelFree setDetectMode:0]; // 0 = PF_FACE_DETECT_MODE_IMAGE
//    [self.mPixelFree pixelFreeSetSkinMaskEnabled:YES];
    self.sourcePixelBuffer = PFCreatePixelBufferFromUIImage(_image);
    self.renderPixelBuffer = PFCreatePixelBufferFromUIImage(_image);

    // 图片 Demo：底部 Tab 含调色 / 全局 HLS / 美体（与 ToolUI 联动）
    self.beautyEditView.moduleTypes = @[
        @(PFBeautyEditViewModuleTypeOneKey),
        @(PFBeautyEditViewModuleTypeSkin),
        @(PFBeautyEditViewModuleTypeShape),
        @(PFBeautyEditViewModuleTypeFilter),
        @(PFBeautyEditViewModuleTypeMakeup),
        @(PFBeautyEditViewModuleTypeSkinTone),
        @(PFBeautyEditViewModuleTypeStickers),
        @(PFBeautyEditViewModuleTypeBody),
        @(PFBeautyEditViewModuleTypeSkinDetail),
        @(PFBeautyEditViewModuleTypeColorGrading),
        @(PFBeautyEditViewModuleTypeGlobalHLS),
    ];
    self.currentModuleType = PFBeautyEditViewModuleTypeOneKey;
}

- (void)bottomDidChange:(int)index {
    [super bottomDidChange:index];
    self.currentModuleType = (PFBeautyEditViewModuleType)index;
    self.toolUI.hidden = YES;
    self.hlsToolView.hidden = YES;
    self.bodyToolUI.hidden = YES;
    self.skinDetailToolUI.hidden = YES;
    switch ((PFBeautyEditViewModuleType)index) {
        case PFBeautyEditViewModuleTypeColorGrading:
            self.toolUI.hidden = NO;
            break;
        case PFBeautyEditViewModuleTypeGlobalHLS:
            self.hlsToolView.hidden = NO;
            break;
        case PFBeautyEditViewModuleTypeBody:
            self.bodyToolUI.hidden = NO;
            break;
        case PFBeautyEditViewModuleTypeSkinDetail:
            self.skinDetailToolUI.hidden = NO;
            break;
        default:
            break;
    }
    [self pf_syncAuxiliaryPanelLayout];
}

- (void)pf_syncAuxiliaryPanelLayout {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    CGFloat toolH = 400;
    CGFloat compactAuxToolH = toolH * 0.5;
    /// 须与 PFBeautyEditView 内 bottomContainer 最小高度（56）一致，否则外置工具条会与 Tab 区域重叠并被盖住
    CGFloat tabStripH = 56;
    CGFloat fullBeautyH = 280;
    CGFloat panelBottomInset = [self pf_effectivePanelBottomInset];
    BOOL ext = !self.toolUI.hidden || !self.hlsToolView.hidden || !self.bodyToolUI.hidden || !self.skinDetailToolUI.hidden;
    if (ext) {
        self.beautyEditView.frame = CGRectMake(0, h - tabStripH - panelBottomInset, w, tabStripH);
        CGFloat compactY = h - tabStripH - compactAuxToolH - panelBottomInset;
        self.toolUI.frame = CGRectMake(0, self.toolUI.hidden ? h : compactY, w, compactAuxToolH);
        self.hlsToolView.frame = CGRectMake(0, self.hlsToolView.hidden ? h : compactY, w, compactAuxToolH);
        self.bodyToolUI.frame = CGRectMake(0, self.bodyToolUI.hidden ? h : compactY, w, compactAuxToolH);
        self.skinDetailToolUI.frame = CGRectMake(0, self.skinDetailToolUI.hidden ? h : compactY, w, compactAuxToolH);
        // toolUI / HLS / 美体 在 viewDidLoad 中晚于 beautyEditView 添加，会压在 Tab 上；辅助面板打开时把菜单栏提到最前
        [self.view bringSubviewToFront:self.beautyEditView];
    } else {
        self.beautyEditView.frame = CGRectMake(0, h - fullBeautyH - panelBottomInset, w, fullBeautyH);
        self.toolUI.frame = CGRectMake(0, h - compactAuxToolH - panelBottomInset, w, compactAuxToolH);
        self.hlsToolView.frame = CGRectMake(0, h - compactAuxToolH - panelBottomInset, w, compactAuxToolH);
        self.bodyToolUI.frame = CGRectMake(0, h - compactAuxToolH - panelBottomInset, w, compactAuxToolH);
        self.skinDetailToolUI.frame = CGRectMake(0, h - compactAuxToolH - panelBottomInset, w, compactAuxToolH);
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self pf_disablePreviewPopGesture];

    if (self.timer) {
        return;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFun) userInfo:@"参数" repeats:YES];
        
        _mRunLoop = [NSRunLoop currentRunLoop];
        [_mRunLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
        //        //如果是子线程还需要启动runloop
        [_mRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
    });
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pf_disablePreviewPopGesture];
}

- (void)timerFun{
    if (self.isVideoMode) {
        if (!self.isVideoPlaying || self.isVideoSliderTracking) {
            [self pf_renderCurrentPixelBuffers];
        }
        return;
    }

    [self pf_renderCurrentPixelBuffers];
}

- (void)pf_renderCurrentPixelBuffers {
    @synchronized (self) {
        if (!_image || !self.sourcePixelBuffer || !self.renderPixelBuffer) {
            if (!self.isVideoMode || !self.sourcePixelBuffer || !self.renderPixelBuffer) {
                return;
            }
        }
        if (!self.openGlView) {
            return;
        }
        if (self.clickCompare) {
            [self.openGlView displayPixelBuffer:self.sourcePixelBuffer];
            return;
        }
        // 每帧从原图拷贝，避免 processWithBuffer 对同一 buffer 累积变形。
        PFCopyPixelBuffer(self.sourcePixelBuffer, self.renderPixelBuffer);
        [self.mPixelFree processWithBuffer:self.renderPixelBuffer rotationMode:PFRotationMode0];
        [self pf_updateDetectHintNeedsFace:[self pf_currentModuleNeedsFaceHint] needsHuman:[self pf_currentModuleNeedsHumanHint]];
        [self.openGlView displayPixelBuffer:self.renderPixelBuffer];
    }
}

- (BOOL)pf_currentModuleNeedsFaceHint {
    switch (self.currentModuleType) {
        case PFBeautyEditViewModuleTypeOneKey:
        case PFBeautyEditViewModuleTypeSkin:
        case PFBeautyEditViewModuleTypeShape:
        case PFBeautyEditViewModuleTypeSkinTone:
        case PFBeautyEditViewModuleTypeMakeup:
        case PFBeautyEditViewModuleTypeStickers:
        case PFBeautyEditViewModuleTypeSkinDetail:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)pf_currentModuleNeedsHumanHint {
    return self.currentModuleType == PFBeautyEditViewModuleTypeBody;
}

- (void)albumBtnClick:(UIButton *)sender {
    // 检查相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        // 请求权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [self presentImagePicker];
            } else {
                [self showPermissionAlert];
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
        // 已授权，打开相册
        [self presentImagePicker];
    } else {
        // 未授权，提示用户
        [self showPermissionAlert];
    }
}

- (void)presentImagePicker{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[
            UTTypeImage.identifier,
            UTTypeMovie.identifier
        ];
        [self presentViewController:picker animated:YES completion:nil];
    });
    
}

- (void)showPermissionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"权限请求"
                                                                   message:@"请在设置中允许访问相册。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:settingsAction];
    [alert addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 更新布局以适应屏幕尺寸变化
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat topMargin = navBarHeight > 0 ? navBarHeight : 80;
    CGFloat bottomReserve = 300;
    CGFloat spacing = 10;
    
    // 计算图片高度
    CGFloat imageHeight = self.view.bounds.size.height - topMargin - bottomReserve - spacing * 2;
    if (imageHeight < 200) {
        imageHeight = 200; // 最小高度
    }
    
    // 更新 OpenGL 预览 frame
    _openGlView.frame = CGRectMake(0, topMargin, self.view.frame.size.width, imageHeight);
    [self pf_layoutVideoControls];

    [self pf_syncAuxiliaryPanelLayout];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController ||
        ![self.navigationController.viewControllers containsObject:self]) {
        [self pf_restorePreviewPopGestureIfNeeded];
        [self pf_cleanupRenderingResources];
    }
    NSLog(@"viewWillDisappear ---");
}



-(void)dealloc{
    [self pf_cleanupRenderingResources];
    [self pf_releasePixelBuffers];
    NSLog(@"dealloc ---");
}


#pragma mark - 滑动事件回调处理

- (void)handleSliderValueChanged:(AdjustmentItem *)item {
    // 根据调节项更新滤镜参数
    
    mColorGrading.isUse = true;
    
    if ([item.name isEqualToString:@"亮度"]) {
        mColorGrading.brightness = item.value;
    } else if ([item.name isEqualToString:@"对比度"]) {
        mColorGrading.contrast = item.value;
    } else if ([item.name isEqualToString:@"曝光"]) {
        mColorGrading.exposure = item.value;
    } else if ([item.name isEqualToString:@"高光"]) {
        mColorGrading.highlights = item.value;
    } else if ([item.name isEqualToString:@"阴影"]) {
        mColorGrading.shadows = item.value;
    } else if ([item.name isEqualToString:@"饱和度"]) {
        mColorGrading.saturation = item.value;
    } else if ([item.name isEqualToString:@"色温"]) {
        mColorGrading.temperature = item.value;
    } else if ([item.name isEqualToString:@"色相"]) {
        mColorGrading.hue = item.value;
    }
    
    [self.mPixelFree pixelFreeSetColorGrading:&mColorGrading];
    
}

// 美体滑动事件回调：根据名称映射到 PFWarpBody 参数
- (void)handleBodySliderValueChanged:(AdjustmentItem *)item {
    float value = item.value;
    // 保证 0~1
    if (value < 0.0f) value = 0.0f;
    if (value > 1.0f) value = 1.0f;

    if ([item.name isEqualToString:@"瘦身"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeSlimBody value:&value];
    } else if ([item.name isEqualToString:@"瘦肚子"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeSlimBelly value:&value];
    } else if ([item.name isEqualToString:@"瘦腰"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeSlimWaist value:&value];
    } else if ([item.name isEqualToString:@"沙漏腰"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeBelly value:&value];
    } else if ([item.name isEqualToString:@"曲线"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeCurve value:&value];
    } else if ([item.name isEqualToString:@"全身瘦"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeFullSlim value:&value];
    } else if ([item.name isEqualToString:@"提跨"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeHipLift value:&value];
    } else if ([item.name isEqualToString:@"丰臀"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeHipEnlarge value:&value];
    } else if ([item.name isEqualToString:@"丰胸"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeBreastEnlarge value:&value];
    } else if ([item.name isEqualToString:@"长腿"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeHeight value:&value];
    } else if ([item.name isEqualToString:@"天鹅颈"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeSwanNeck value:&value];
    } else if ([item.name isEqualToString:@"瘦肩膀"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeShoulderThin value:&value];
    } else if ([item.name isEqualToString:@"直角肩"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeRightAngleShoulder value:&value];
    } else if ([item.name isEqualToString:@"左大臂"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeLeftUpperArm value:&value];
    } else if ([item.name isEqualToString:@"左小臂"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeLeftLowerArm value:&value];
    } else if ([item.name isEqualToString:@"右大臂"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeRightUpperArm value:&value];
    } else if ([item.name isEqualToString:@"右小臂"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeRightLowerArm value:&value];
    } else if ([item.name isEqualToString:@"左大腿"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeLeftUpperLeg value:&value];
    } else if ([item.name isEqualToString:@"左小腿"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeLeftLowerLeg value:&value];
    } else if ([item.name isEqualToString:@"右大腿"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeRightUpperLeg value:&value];
    } else if ([item.name isEqualToString:@"右小腿"]) {
        [self.mPixelFree pixelFreeSetBodyBeautyParam:PFBodyBeautyTypeRightLowerLeg value:&value];
    }
}

- (void)handleSkinDetailSliderValueChanged:(AdjustmentItem *)item {
    float value = item.value;
    if (value < 0.0f) value = 0.0f;
    if (value > 1.0f) value = 1.0f;

    if ([item.name isEqualToString:@"纹理"]) {
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSkinDetailTexture value:&value];
    } else if ([item.name isEqualToString:@"清晰"]) {
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSkinDetailClarity value:&value];
    } else if ([item.name isEqualToString:@"高光"]) {
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSkinDetailHighlight value:&value];
    } else if ([item.name isEqualToString:@"水光"]) {
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSkinDetailWaterGlow value:&value];
    } else if ([item.name isEqualToString:@"哑光"]) {
        [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSkinDetailMatte value:&value];
    }
}


-(void)sliderValueChanged:(AdjustmentItem *)item{
        if ([item.name isEqualToString:@"明亮度"]) {
            mHLSFilterParams.brightness = item.value;
        } else if ([item.name isEqualToString:@"色相"]) {
            mHLSFilterParams.hue = item.value;
        } else if ([item.name isEqualToString:@"饱和度"]) {
            mHLSFilterParams.saturation = item.value;
        } else if ([item.name isEqualToString:@"相似度"]) {
            mHLSFilterParams.similarity = item.value;
        }
    [self.mPixelFree pixelFreeChangeHLSFilter:handle params:&mHLSFilterParams];
}
- (void)colorDidSelectedR:(float)r G:(float)g B:(float)b A:(float)a {
    //    [_mHLSFilter setColorDidSelectedR:r G:g B:b A:a];
    //    [self.sourcePicture processImage];
    mHLSFilterParams.key_color[0] = r;
    mHLSFilterParams.key_color[1] = g;
    mHLSFilterParams.key_color[2] = b;
    [self.mPixelFree pixelFreeChangeHLSFilter:handle params:&mHLSFilterParams];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];

    [picker dismissViewControllerAnimated:NO completion:^{
        if ([mediaType isEqualToString:UTTypeMovie.identifier] && mediaURL) {
            [self pf_applyPickedVideoURL:mediaURL];
            return;
        }
        [self pf_applyPickedImage:pickedImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)pf_applyPickedVideoURL:(NSURL *)videoURL {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
        AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        CGAffineTransform preferredTransform = videoTrack ? videoTrack.preferredTransform : CGAffineTransformIdentity;
        CGSize naturalSize = videoTrack ? videoTrack.naturalSize : CGSizeZero;
        CGSize compositionRenderSize = CGSizeZero;
        AVMutableVideoComposition *videoComposition =
            PFCreatePreferredTransformVideoComposition(videoTrack, asset.duration, &compositionRenderSize);
        CGAffineTransform playbackTransform = videoComposition ? CGAffineTransformIdentity : preferredTransform;
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        UIImage *frameImage = [self pf_videoFrameImageWithGenerator:generator atTime:0 duration:duration];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (!frameImage || !isfinite(duration) || duration <= 0) {
                [self pf_showMediaLoadFailAlertWithMessage:@"视频解码失败，无法读取首帧。"];
                return;
            }
            [self pf_clearVideoState];

            NSDictionary *pixelBufferAttrs = @{
                (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
            };
            AVPlayerItemVideoOutput *videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBufferAttrs];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            if (videoComposition) {
                playerItem.videoComposition = videoComposition;
            }
            [playerItem addOutput:videoOutput];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
            player.muted = YES;
            player.actionAtItemEnd = AVPlayerActionAtItemEndPause;

            @synchronized (self) {
                self.videoAsset = asset;
                self.videoPlayer = player;
                self.videoOutput = videoOutput;
                self.videoImageGenerator = generator;
                self.videoPreferredTransform = preferredTransform;
                self.videoPlaybackTransform = playbackTransform;
                self.videoNaturalSize = naturalSize;
                self.videoGeneratorFrameSize = frameImage.size;
                self.videoCompositionRenderSize = compositionRenderSize;
                self.videoOrientationLogCount = 0;
                if (!self.videoCIContext) {
                    self.videoCIContext = [CIContext contextWithOptions:@{ kCIContextUseSoftwareRenderer : @NO }];
                }
                self.videoDuration = duration;
                self.videoCurrentTime = 0;
                self.isVideoMode = YES;
                self.isVideoPlaying = NO;
                self.isVideoSliderTracking = NO;
                self.wasVideoPlayingBeforeScrubbing = NO;
                self.videoFrameRequestID++;
            }
            NSLog(@"[PFVideoOrientation] selected duration=%.3f natural=%@ generatorFrame=%@ imageScale=%.2f preferredTransform=%@ videoComposition=%@ compositionRender=%@ playbackTransform=%@ url=%@",
                  duration,
                  PFVideoSizeString(naturalSize),
                  PFVideoSizeString(frameImage.size),
                  frameImage.scale,
                  PFVideoTransformString(preferredTransform),
                  videoComposition ? @"YES" : @"NO",
                  PFVideoSizeString(compositionRenderSize),
                  PFVideoTransformString(playbackTransform),
                  videoURL.lastPathComponent);
            if (![self pf_replaceSourceImage:frameImage resetDetectState:YES failMessage:@"视频首帧转 PixelBuffer 失败。"]) {
                [self pf_clearVideoState];
                return;
            }
            [self pf_layoutVideoControls];
            [self pf_updateVideoControls];
            [self pf_renderCurrentPixelBuffers];
            [self pf_startVideoDisplayLink];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(pf_videoPlayerDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:playerItem];
        });
    });
}

- (UIImage *)pf_videoFrameImageAtTime:(NSTimeInterval)time {
    AVAssetImageGenerator *generator = self.videoImageGenerator;
    if (!generator) {
        return nil;
    }
    return [self pf_videoFrameImageWithGenerator:generator atTime:time duration:self.videoDuration];
}

- (UIImage *)pf_videoFrameImageWithGenerator:(AVAssetImageGenerator *)generator
                                      atTime:(NSTimeInterval)time
                                    duration:(NSTimeInterval)duration {
    if (!generator || !isfinite(time)) {
        return nil;
    }
    NSTimeInterval decodeTime = MAX(time, 0);
    if (isfinite(duration) && duration > 0) {
        decodeTime = MIN(decodeTime, MAX(duration - 0.001, 0));
    }
    NSError *error = nil;
    CMTime cmTime = CMTimeMakeWithSeconds(decodeTime, 600);
    CGImageRef cgImage = NULL;
    @synchronized (generator) {
        cgImage = [generator copyCGImageAtTime:cmTime actualTime:NULL error:&error];
    }
    if (!cgImage) {
        NSLog(@"[ImagePicker] video frame decode failed: %@", error);
        return nil;
    }

    UIImage *image = [UIImage imageWithCGImage:cgImage scale:UIScreen.mainScreen.scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return image;
}

- (void)pf_applyPickedImage:(UIImage *)image {
    [self pf_clearVideoState];
    [self pf_replaceSourceImage:image resetDetectState:YES failMessage:@"图片读取失败。"];
}

- (void)pf_clearVideoState {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.videoPlayer pause];
    [self.videoDisplayLink invalidate];
    @synchronized (self) {
        self.videoAsset = nil;
        self.videoPlayer = nil;
        self.videoOutput = nil;
        self.videoDisplayLink = nil;
        self.videoImageGenerator = nil;
        self.videoPreferredTransform = CGAffineTransformIdentity;
        self.videoPlaybackTransform = CGAffineTransformIdentity;
        self.videoNaturalSize = CGSizeZero;
        self.videoGeneratorFrameSize = CGSizeZero;
        self.videoCompositionRenderSize = CGSizeZero;
        self.videoOrientationLogCount = 0;
        self.videoDuration = 0;
        self.videoCurrentTime = 0;
        self.isVideoMode = NO;
        self.isVideoPlaying = NO;
        self.isVideoSliderTracking = NO;
        self.wasVideoPlayingBeforeScrubbing = NO;
        self.videoFrameRequestID++;
    }
    self.videoProgressSlider.value = 0.0f;
    [self pf_updateVideoControls];
}

- (void)pf_videoPlayerDidReachEnd:(NSNotification *)notification {
    if (notification.object != self.videoPlayer.currentItem) {
        return;
    }
    self.isVideoPlaying = NO;
    self.videoCurrentTime = self.videoDuration;
    self.videoDisplayLink.paused = YES;
    [self pf_updateVideoControls];
}

- (void)pf_seekVideoToTime:(NSTimeInterval)time resetDetectState:(BOOL)resetDetectState resumeWhenDone:(BOOL)resumeWhenDone {
    NSUInteger requestID = 0;
    @synchronized (self) {
        self.videoFrameRequestID++;
        requestID = self.videoFrameRequestID;
    }

    CMTime cmTime = CMTimeMakeWithSeconds(MAX(time, 0), 600);
    [self.videoPlayer seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        UIImage *frameImage = [self pf_videoFrameImageAtTime:time];
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized (self) {
                if (!self.isVideoMode || requestID != self.videoFrameRequestID) {
                    return;
                }
            }
            if (frameImage) {
                NSLog(@"[PFVideoOrientation] seekFrame time=%.3f imageSize=%@ imageScale=%.2f natural=%@ generatorFrame=%@ compositionRender=%@ preferredTransform=%@ playbackTransform=%@",
                      time,
                      PFVideoSizeString(frameImage.size),
                      frameImage.scale,
                      PFVideoSizeString(self.videoNaturalSize),
                      PFVideoSizeString(self.videoGeneratorFrameSize),
                      PFVideoSizeString(self.videoCompositionRenderSize),
                      PFVideoTransformString(self.videoPreferredTransform),
                      PFVideoTransformString(self.videoPlaybackTransform));
                [self pf_replaceSourceImage:frameImage resetDetectState:resetDetectState failMessage:nil];
                [self pf_renderCurrentPixelBuffers];
            }
            if (resumeWhenDone && self.isVideoMode) {
                [self.videoPlayer play];
                self.isVideoPlaying = YES;
                self.videoDisplayLink.paused = NO;
            }
        });
    });
}

- (BOOL)pf_replaceSourceImage:(UIImage *)image resetDetectState:(BOOL)resetDetectState failMessage:(NSString *)failMessage {
    if (!image) {
        if (failMessage) {
            [self pf_showMediaLoadFailAlertWithMessage:failMessage];
        }
        return NO;
    }

    UIImage *normalizedImage = [self pf_normalizedImage:image];
    CVPixelBufferRef sourceBuffer = PFCreatePixelBufferFromUIImage(normalizedImage);
    CVPixelBufferRef renderBuffer = PFCreatePixelBufferFromUIImage(normalizedImage);
    if (!sourceBuffer || !renderBuffer) {
        if (sourceBuffer) {
            CVBufferRelease(sourceBuffer);
        }
        if (renderBuffer) {
            CVBufferRelease(renderBuffer);
        }
        if (failMessage) {
            [self pf_showMediaLoadFailAlertWithMessage:failMessage];
        }
        return NO;
    }

    @synchronized (self) {
        self.image = normalizedImage;
        if (resetDetectState) {
            [self.mPixelFree resetDetectState];
            [self pf_hideDetectHint];
        }
        if (self.sourcePixelBuffer) {
            CVBufferRelease(self.sourcePixelBuffer);
        }
        self.sourcePixelBuffer = sourceBuffer;
        if (self.renderPixelBuffer) {
            CVBufferRelease(self.renderPixelBuffer);
        }
        self.renderPixelBuffer = renderBuffer;
    }
    return YES;
}

- (UIImage *)pf_normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationUpMirrored) {
        return image;
    }
    
    CGSize targetSize = CGSizeMake(image.size.width * 0.5, image.size.height * 0.5);
    UIGraphicsBeginImageContext(targetSize);
    [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage ?: image;
}

- (void)pf_showMediaLoadFailAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"读取失败"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - PFFilterViewDelegate

- (void)filterViewDidSelectedFilter:(PFBeautyParam *)param {
    
    if ([param.mParam isEqualToString:@""] || param.mParam.length == 0) {
        // 关闭美妆
        NSLog(@"[Makeup] 关闭美妆");
        [self.mPixelFree clearMakeup];
    } else {
        // 设置美妆
        NSString *path = [[NSBundle mainBundle] pathForResource:@"makeup" ofType:nil];
        if (!path) {
            NSLog(@"[Makeup] 错误: 找不到 makeup 资源文件夹");
            return;
        }
        
        NSString *currentFolder = [path stringByAppendingPathComponent:param.mParam];
        NSLog(@"[Makeup] 美妆路径: %@", currentFolder);
        
        // 检查文件夹是否存在
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL exists = [fileManager fileExistsAtPath:currentFolder isDirectory:&isDirectory];
        
        if (exists && isDirectory) {
            NSLog(@"[Makeup] 文件夹存在，应用美妆");
//            int ret = [self.mPixelFree pixelFreeSetMakeupWithJsonPath:currentFolder];
            
            NSString *name = [NSString stringWithFormat:@"%@.bundle",param.mParam];
            NSString *currentBundle = [path stringByAppendingPathComponent:name];
            NSData *date = [NSData dataWithContentsOfFile:currentBundle];
            
            [self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeMakeup data:(void *)date.bytes size:date.length];
//            NSLog(@"[Makeup] 应用美妆返回值: %d", ret);
        } else {
            NSLog(@"[Makeup] 错误: 美妆文件夹不存在: %@", currentFolder);
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    PFHumanSegmentationResult maskResult = {};
    int hasMask = [self.mPixelFree pixelFreeGetHumanSegmentationResultAtIndex:0 result:&maskResult];
    UIImage *debugMaskImage = hasMask ? PFCreateImageFromHumanSegmentationResult(&maskResult) : nil;
    self.debugHumanMaskImage = debugMaskImage;
    
    NSLog(@"[HumanSeg] first mask hasMask=%d humanCount=%d index=%d size=%dx%d count=%d image=%@",
          hasMask,
          maskResult.humanCount,
          maskResult.index,
          maskResult.width,
          maskResult.height,
          maskResult.count,
          debugMaskImage);
}

@end
