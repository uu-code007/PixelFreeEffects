//
//  PixelFree.h
//  PixelFree
//
//  Created by 孙慕 on 2020/10/15.
//  Copyright © 2020 孙慕. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface PixelFree : NSObject

/**
 初始化SDK
 */
+ (void)setupPixelFree;


/**
 获取版本号

 @return 版本号
 */
+ (NSString *)getSDKVersion;




@end

NS_ASSUME_NONNULL_END
