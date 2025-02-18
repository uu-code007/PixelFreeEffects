
#import "SMAudioConfiguration.h"
#import <AVFoundation/AVFoundation.h>

@interface SMAudioConfiguration ()

@property (assign, nonatomic) BOOL acousticEchoCancellationEnable;

@end

@implementation SMAudioConfiguration

+ (instancetype)defaultConfiguration {
    SMAudioConfiguration *config = [[SMAudioConfiguration alloc] init];
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfChannels = 1;
        self.sampleRate = 44100;
        self.bitRate = 128;
        self.acousticEchoCancellationEnable = NO;
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
    
    return [self isEqualToAudioCaptureConfiguration:other];
}

- (BOOL)isEqualToAudioCaptureConfiguration:(SMAudioConfiguration *)other {
    return (self.numberOfChannels == other.numberOfChannels) && (self.sampleRate == other.sampleRate) && (self.bitRate == other.bitRate) && (self.acousticEchoCancellationEnable == other.acousticEchoCancellationEnable);
}

@end
