
#import "SMVideoConfiguration.h"

@implementation SMVideoConfiguration

+ (instancetype)defaultConfiguration {
    SMVideoConfiguration *config = [[SMVideoConfiguration alloc] init];
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoFrameRate = 15;
        self.sessionPreset = AVCaptureSessionPreset1280x720;
        self.position = AVCaptureDevicePositionBack;
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
        self.videoSize = CGSizeMake(480, 854);
        
        self.averageVideoBitRate = 1024*1000;
        self.videoMaxKeyframeInterval = 2*self.videoFrameRate;
        self.videoProfileLevel = AVVideoProfileLevelH264HighAutoLevel;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToVideoCaptureConfiguration:other];
}

- (BOOL)isEqualToVideoCaptureConfiguration:(SMVideoConfiguration *)other {
    return (self.videoFrameRate == other.videoFrameRate
            && [self.sessionPreset isEqualToString:other.sessionPreset] && self.position == other.position && self.videoOrientation == other.videoOrientation);
}

@end
