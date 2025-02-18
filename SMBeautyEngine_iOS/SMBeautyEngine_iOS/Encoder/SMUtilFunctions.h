#ifndef PLGCDUtils_h
#define PLGCDUtils_h

#import <stdio.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <mach/mach_time.h>

#define SMDegreeToRadians(x) (M_PI * x / 180.0)

#define SMRadiansTodegree(x) (180.0 * x / M_PI)



void SMDispactchSetSpecific(dispatch_queue_t queue, const void *key);

void SMDispatchSync(dispatch_queue_t queue, const void *key, dispatch_block_t block);

void SMDispatchAsync(dispatch_queue_t queue, const void *key, dispatch_block_t block);

CMSampleBufferRef SMCreateSampleBufferFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CMSampleTimingInfo info);

CVPixelBufferRef  SMCreateCVPixelBufferFromImageWithSize(UIImage *image, CGSize destSize);

CGAffineTransform SMTransformWithImage(UIImage *image);
BOOL SMNeedSupportMuseBaseProcessor(void);

NSString* SMGetFileSavePath(NSString *fileType);

NSString* SMGetFileMergePath(NSString *fileType);

NSString* SMGetUploaderPath(void);

NSString* SMGetAppleFileType();

NSString* SMGetFileExtension();

uint64_t SMGetUptimeInNanosecondWithMachTime(uint64_t machTime);



#endif /* PLGCDUtils_h */
