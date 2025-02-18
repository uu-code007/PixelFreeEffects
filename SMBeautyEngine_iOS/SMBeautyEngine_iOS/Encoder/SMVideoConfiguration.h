
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SMVideoConfiguration : NSObject


@property (assign, nonatomic) NSUInteger videoFrameRate;

@property (strong, nonatomic) NSString *sessionPreset;

@property (assign, nonatomic) AVCaptureDevicePosition position;

@property (assign, nonatomic) AVCaptureVideoOrientation videoOrientation;

@property (assign, nonatomic) CGSize videoSize;

@property (nonatomic, assign) NSUInteger averageVideoBitRate;

@property (nonatomic, assign) NSUInteger videoMaxKeyframeInterval;

@property (nonatomic, copy) NSString *videoProfileLevel;


+ (instancetype)defaultConfiguration;

@end
