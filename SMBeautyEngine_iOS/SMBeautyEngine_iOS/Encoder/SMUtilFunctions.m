#import "SMUtilFunctions.h"
#import <UIKit/UIKit.h>

void SMDispactchSetSpecific(dispatch_queue_t queue, const void *key) {
    CFStringRef context = CFSTR("context");
    dispatch_queue_set_specific(queue,
                                key,
                                (void*)context,
                                (dispatch_function_t)CFRelease);
}

void SMDispatchSync(dispatch_queue_t queue, const void *key, dispatch_block_t block) {
    CFStringRef context = (CFStringRef)dispatch_get_specific(key);
    // 该函数执行时如果在指定 dispatch_queue_t 则直接执行 block，如果不在指定 dispatch_queue_t 则 dispatch_sync 到指定队列执行，用于避免 dispatch_sync 可能引起的死锁
    if (context) {
        block();
    } else {
        dispatch_sync(queue, block);
    }
}

void SMDispatchAsync(dispatch_queue_t queue, const void *key, dispatch_block_t block) {
    CFStringRef context = (CFStringRef)dispatch_get_specific(key);
    // 该函数执行时如果在指定 dispatch_queue_t 则直接执行 block，如果不在指定 dispatch_queue_t 则 dispatch_async 到指定队列执行
    if (context) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}

CMSampleBufferRef SMCreateSampleBufferFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CMSampleTimingInfo info) {
    CMSampleBufferRef newSampleBuffer = NULL;
    CMSampleTimingInfo timimgInfo = info/*kCMTimingInfoInvalid*/;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                       pixelBuffer,
                                       true,
                                       NULL,
                                       NULL,
                                       videoInfo,
                                       &timimgInfo,
                                       &newSampleBuffer);
    CFRelease(videoInfo);
    
    return newSampleBuffer;
}

CVPixelBufferRef SMCreateCVPixelBufferFromImage(UIImage *image) {
    CGFloat frameWidth = CGImageGetWidth([image CGImage]);
    CGFloat frameHeight = CGImageGetHeight([image CGImage]);

    return SMCreateCVPixelBufferFromImageWithSize(image, CGSizeMake(frameWidth, frameHeight));
}

CVPixelBufferRef SMCreateCVPixelBufferFromImageWithSize(UIImage *image, CGSize destSize) {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             @{}, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = destSize.width;
    CGFloat frameHeight = destSize.height;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       [image CGImage]);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

CGAffineTransform SMTransformWithImage(UIImage *image) {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

CVPixelBufferRef SMCreateCVPixelBufferFromImageWithFixTransform(UIImage *image) {
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             @{}, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    
    CGFloat frameWidth = image.size.width;
    CGFloat frameHeight = image.size.height;
    if (UIImageOrientationLeft == image.imageOrientation ||
        UIImageOrientationRight == image.imageOrientation ||
        UIImageOrientationLeftMirrored == image.imageOrientation ||
        UIImageOrientationRightMirrored == image.imageOrientation) {
        frameWidth = image.size.height;
        frameHeight = image.size.width;
    }
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          image.size.width,
                                          image.size.height,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 image.size.width,
                                                 image.size.height,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextConcatCTM(context, SMTransformWithImage(image));
    CGContextDrawImage(context, CGRectMake(0, 0, frameWidth, frameHeight), [image CGImage]);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}





NSString* SMGetAppleFileType() {
    NSString *appleFileType = AVFileTypeMPEG4;
    return appleFileType;
}

NSString* SMGetFileExtension() {
    NSString *fileExtension = @".mp4";
    return fileExtension;
}

uint64_t SMGetUptimeInNanosecondWithMachTime(uint64_t machTime) {
    static mach_timebase_info_data_t s_timebase_info = {0};
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    return (uint64_t)((machTime * s_timebase_info.numer) / s_timebase_info.denom);
}
