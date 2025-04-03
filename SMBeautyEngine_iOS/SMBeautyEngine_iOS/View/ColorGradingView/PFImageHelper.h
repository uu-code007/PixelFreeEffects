//
//  PFImageHelper.h
//  FULiveDemo
//
//  Created by L on 2018/8/3.
//  Copyright © 2018年 L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PFImageHelper : NSObject

+ (void) convertUIImageToBitmapRGBA8:(UIImage *) image completionHandler:(void (^)(int32_t size, unsigned char * bits))completionHandler ;
+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
                                withWidth:(int) width
                               withHeight:(int) height ;

+(CVPixelBufferRef) pixelBufferFromImage:(UIImage *)image;

+(UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef;

+ (UIImage *)imageFromPixelBuffer2:(CVPixelBufferRef)pixelBufferRef;
+ (unsigned char *)getRGBAWithImage:(UIImage *)image;

+ (unsigned char *)getRGBAWithImageName:(NSString *)imageName width:(int *)width height:(int *)height;

+ (UIColor*)getPixelColorScreenWindowAtLocation:(CGPoint)point;
@end
