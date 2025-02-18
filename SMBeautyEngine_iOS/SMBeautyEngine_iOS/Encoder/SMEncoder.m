#import "SMEncoder.h"
#import "SMUtilFunctions.h"


@interface SMEncoder ()
{
    SMVideoConfiguration *_videoConfiguration;
    SMAudioConfiguration *_audioConfiguration;
    
    NSURL *_fileURL;
    
    AVAssetWriter *_writer;
    AVAssetWriterInput *_videoWriterInput;
    AVAssetWriterInput *_audioWriterInput;
    NSString *_path;
    
    BOOL _isEncoding;
    
    BOOL _isSetStartTime;
    CMTime _startRecordingSourceTime;
    
    NSDictionary *_audioSetting;
    NSDictionary *_videoSetting;
    
    CGImagePropertyOrientation _orientation;
    CGSize _realVideoSize;
    
    // 由于在外面调用 SMEncoder startEncoding，stopEncoding, cancelEncoding, addEncodingSample 不好做到放在同一个线程线程中，外面也不好做同步处理，因此添加 _encoder_queue 在内部做好这些处理
    dispatch_queue_t _encoder_queue;
}

@end

@implementation SMEncoder

- (instancetype)initWithVideoConfiguration:(SMVideoConfiguration *)videoConfiguration audioConfiguration:(SMAudioConfiguration *)audioConfiguration {
    self = [super init];
    if (self) {
        _videoConfiguration = videoConfiguration;
        _audioConfiguration = audioConfiguration;
        
        _orientation = kCGImagePropertyOrientationUp;
        
        _isEncoding = NO;
        self.videoTransform = CGAffineTransformIdentity;
        
        _encoder_queue = dispatch_queue_create("pls.pili.queue.encoder.write", DISPATCH_QUEUE_SERIAL);
        SMDispactchSetSpecific(_encoder_queue, (__bridge const void *)(self));
    }
    return self;
}

- (CMTime)startRecordingTime {
    return _startRecordingSourceTime;
}

- (void)startEncodingToOutputFileURL:(NSURL*)outputFileURL encodingDelegate:(id<SMEncoderDelegate>)delegate {
    
    // 这里使用 SMDispatchSync 而不使用 SMDispatchAsync，因为第一次初始化 AVAssetWrite 比较耗时，使用 async 会让
    // SMhortVideoRecorder 中的 timer 已经返回给上层部分录制时长了，才回调 @selector(encoder:didStartRecordingToOutputFileAtURL:)
    // ISSUE: https://jira.qiniu.io/browse/PILCS-4770
    SMDispatchSync(_encoder_queue, (__bridge const void *)(self), ^{
        
        _fileURL = outputFileURL;
        _delegate = delegate;
        _isSetStartTime = NO;
        _startRecordingSourceTime = kCMTimeInvalid;
        
        // .mp4 type
        NSString *appleFileType = SMGetAppleFileType();
        _writer = [AVAssetWriter assetWriterWithURL:outputFileURL fileType:appleFileType error:nil];
        _writer.shouldOptimizeForNetworkUse = YES;
        
        if (_videoConfiguration) [self setupVideoEncode];
        if (_audioConfiguration) [self setupAudioEncode];
        
        _isEncoding = [_writer startWriting];
        if (_isEncoding) {
            if (_delegate && [_delegate respondsToSelector:@selector(encoder:didStartRecordingToOutputFileAtURL:)]) {
                [_delegate encoder:self didStartRecordingToOutputFileAtURL:_fileURL];
            }
        } else {
            NSLog(@"start encoding error, writer.status: %ld, error = %@, url = %@", (long)_writer.status, _writer.error, _fileURL.absoluteString);
            if (_audioSetting) {
                NSLog(@"audio configuration: %@", _audioSetting);
            }
            if (_videoSetting) {
                NSLog(@"video configuration: %@", _videoSetting);
            }
        }
    });
}

- (void)stopEncoding {
    
    SMDispatchAsync(_encoder_queue, (__bridge const void *)(self), ^{
        _isEncoding = NO;
        NSLog(@"writer.status: %ld", (long)_writer.status);
        
        if (_writer.status == AVAssetWriterStatusCompleted ||
            _writer.status == AVAssetWriterStatusCancelled ||
            _writer.status == AVAssetWriterStatusUnknown) {
            if (_delegate && [_delegate respondsToSelector:@selector(encoder:didFinishRecordingToOutputFileAtURL:)]) {
                [_delegate encoder:self didFinishRecordingToOutputFileAtURL:_fileURL];
            }
            _delegate = nil;
            return;
        }
        
        if(_writer.status == AVAssetWriterStatusWriting) {
            if (_videoConfiguration) [_videoWriterInput markAsFinished];
            if (_audioConfiguration) [_audioWriterInput markAsFinished];
        }
        [_writer finishWritingWithCompletionHandler:^{
            if (_delegate && [_delegate respondsToSelector:@selector(encoder:didFinishRecordingToOutputFileAtURL:)]) {
                [_delegate encoder:self didFinishRecordingToOutputFileAtURL:_fileURL];
            }
            _delegate = nil;
        }];
    });
}

- (void)cancelEncoding {
    
    SMDispatchAsync(_encoder_queue, (__bridge const void *)(self), ^{
        
        if (!_isEncoding) return;
        
        _isEncoding = NO;
        
        if (_writer.status == AVAssetWriterStatusCompleted) {
            return;
        }
        
        if(_writer.status == AVAssetWriterStatusWriting) {
            if (_videoConfiguration) [_videoWriterInput markAsFinished];
            if (_audioConfiguration) [_audioWriterInput markAsFinished];
        }
        
        [_writer cancelWriting];
        
        if (_fileURL) {
            NSString *filePath = [_fileURL absoluteString];
            filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            unlink([filePath UTF8String]); // because cancelWriting may not delete the file, so we delete the file manually.
        }
        
        _delegate = nil;
    });
}

#pragma mark -- Private methods
- (void)setupVideoEncode {
#define ISEQUAL(a, b) (fabs(a-b)<0.0001)
    CGFloat width = _videoConfiguration.videoSize.width;
    CGFloat height = _videoConfiguration.videoSize.height;
    if (ISEQUAL(self.videoTransform.a, 1) && ISEQUAL(self.videoTransform.b, 0)) {
        _orientation = kCGImagePropertyOrientationUp;
    } else if (ISEQUAL(self.videoTransform.a, 0) && ISEQUAL(self.videoTransform.b, 1)) {
        _orientation = kCGImagePropertyOrientationRight;
        width = _videoConfiguration.videoSize.height;
        height = _videoConfiguration.videoSize.width;
    } else if (ISEQUAL(self.videoTransform.a, -1) && ISEQUAL(self.videoTransform.b, 0)) {
        _orientation = kCGImagePropertyOrientationDown;
    } else if (ISEQUAL(self.videoTransform.a, 0) && ISEQUAL(self.videoTransform.b, -1)) {
        _orientation = kCGImagePropertyOrientationLeft;
        width = _videoConfiguration.videoSize.height;
        height = _videoConfiguration.videoSize.width;
    } else {
        _orientation = kCGImagePropertyOrientationUp;
        self.videoTransform = CGAffineTransformIdentity;
        NSAssert(false, @"should not be here");
    }
#undef ISEQUAL
    _realVideoSize = CGSizeMake(width, height);
    
    NSDictionary* settings = @{AVVideoCodecKey: AVVideoCodecH264,
                               AVVideoCompressionPropertiesKey: @{ AVVideoAverageBitRateKey: @([_videoConfiguration averageVideoBitRate]),
                                                                   AVVideoMaxKeyFrameIntervalKey: @([_videoConfiguration videoMaxKeyframeInterval]),
                                                                   AVVideoExpectedSourceFrameRateKey: @([_videoConfiguration videoFrameRate]),
                                                                   AVVideoProfileLevelKey: [_videoConfiguration videoProfileLevel],
                                                                   AVVideoAllowFrameReorderingKey: @(NO)},
                               AVVideoWidthKey: @(width),
                               AVVideoHeightKey: @(height),
                               AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
    };
    
    
    _videoSetting = settings;
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    _videoWriterInput.transform = CGAffineTransformIdentity;
    [_writer addInput:_videoWriterInput];
}

- (void)setupAudioEncode {
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithInteger:_audioConfiguration.numberOfChannels], AVNumberOfChannelsKey,
                              [NSNumber numberWithFloat:_audioConfiguration.sampleRate], AVSampleRateKey,
                              [NSNumber numberWithInteger:_audioConfiguration.bitRate], AVEncoderBitRateKey,
                              nil];
    
    _audioSetting = settings;
    _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
    _audioWriterInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_audioWriterInput];
}

- (void)asyncEncode:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo {
    // 1. 在采集视频的情形下，要保证写入的首个数据为视频帧，防止视频文件首帧黑屏。
    // 2. 在相机访问权限被拒只能录制音频的情形下，需要获知相机权限状态，避免 [_writer startWriting] 不执行，导致不能生成录像文件。
    
    //    CMSampleBufferRef copySample = NULL;
    //    OSStatus status = CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &copySample);
    //    if (!copySample || noErr != status ) {
    //        SMLogE(@"copy sample buffer error,OSStatus %d", status);
    //        return;
    //    }
    /*
     modify by lizhengyong
     retain rather than copy for better performance
     */
    CFRetain(sampleBuffer);
    
    SMDispatchAsync(_encoder_queue, (__bridge const void *)(self), ^{
        
        do {
            
            if (!_isEncoding) {
                NSLog(@"encoder no start or stop，isVideo = %d", isVideo);
                break;
            }
            
            if (!CMSampleBufferDataIsReady(sampleBuffer)) {
                NSLog(@"write copy sample buffer nor ready");
                break;
            }
            
            if (!_isSetStartTime) {
                if (_videoConfiguration && self.isAccessCamera) {
                    if (isVideo) {
                        CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                        if (_writer.status == AVAssetWriterStatusWriting) {
                            [_writer startSessionAtSourceTime:startTime];
                            _startRecordingSourceTime = startTime;
                            _isSetStartTime = YES;
                        } else {
                            NSLog(@"writer startSessionAtSourceTime error: %@, status: %ld",  _writer.error.localizedDescription, (long)_writer.status);
                        }
                    }
                } else {
                    if (_writer.status == AVAssetWriterStatusWriting) {
                        CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                        if (_writer.status == AVAssetWriterStatusWriting) {
                            [_writer startSessionAtSourceTime:startTime];
                            _startRecordingSourceTime = startTime;
                            _isSetStartTime = YES;
                        } else {
                            NSLog(@"writer startSessionAtSourceTime error: %@, status: %ld",  _writer.error.localizedDescription, (long)_writer.status);
                        }
                    }
                }
            }
            
            if (!_isSetStartTime) {
                NSLog(@"start time not set, will abandon %@ sample", isVideo ? @"video" : @"audio");
                break;
            }
            
            if (_writer.status == AVAssetWriterStatusFailed) {
                NSLog(@"writer error: %@, status: %ld", _writer.error.localizedDescription, (long)_writer.status);
                break;
            }
            
            if (_writer.status == AVAssetWriterStatusWriting) {
                if (isVideo) {
                    if (_isEncoding && _videoWriterInput.readyForMoreMediaData) {
                        // 写入第一帧数据耗时 0.5s 左右
                        if (_orientation != kCGImagePropertyOrientationUp) {
                            CVPixelBufferRef oribuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:oribuffer];
                            CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
                            CIImage *outputImage = [ciImage imageByApplyingOrientation:_orientation];
                            
                            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @{}, kCVPixelBufferIOSurfacePropertiesKey,
                                                     nil];
                            CVImageBufferRef pxbuffer;
                            CVPixelBufferCreate(kCFAllocatorDefault, _realVideoSize.width, _realVideoSize.height, CVPixelBufferGetPixelFormatType(oribuffer), (__bridge CFDictionaryRef)options, &pxbuffer);
                            
                            CVPixelBufferLockBaseAddress(pxbuffer, 0);
                            [context render:outputImage toCVPixelBuffer:pxbuffer];
                            CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
                            
                            CMSampleTimingInfo info;
                            CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &info);
                            CMSampleBufferRef tmpbuffer = SMCreateSampleBufferFromCVPixelBuffer(pxbuffer, info);
                            [_videoWriterInput appendSampleBuffer:tmpbuffer];
                            CFRelease(tmpbuffer);
                            CFRelease(pxbuffer);
                        } else {
                            [_videoWriterInput appendSampleBuffer:sampleBuffer];
                        }
                    }
                } else {
                    if (_isEncoding && _audioWriterInput.readyForMoreMediaData) {
                        [_audioWriterInput appendSampleBuffer:sampleBuffer];
                    }
                }
            }
            
        } while (0);
        
        CFRelease(sampleBuffer);
    });
}

- (void)reloadvideoConfiguration:(SMVideoConfiguration *__nonnull)videoConfiguration {
    _videoConfiguration = videoConfiguration;
}

- (void)reloadAudioConfiguration:(SMAudioConfiguration *)audioConfiguration {
    _audioConfiguration = audioConfiguration;
}

#pragma mark -- dealloc
- (void)dealloc {
    _writer = nil;
    _videoWriterInput = nil;
    _audioWriterInput = nil;
    NSLog(@"dealloc: %@", [[self class] description]);
}

@end
