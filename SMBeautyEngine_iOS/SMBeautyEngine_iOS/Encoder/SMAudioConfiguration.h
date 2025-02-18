
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SMAudioConfiguration : NSObject

@property (assign, nonatomic) NSUInteger numberOfChannels;

@property (assign, nonatomic) int sampleRate;

@property (assign, nonatomic) int bitRate;


+ (instancetype)defaultConfiguration;

@end
