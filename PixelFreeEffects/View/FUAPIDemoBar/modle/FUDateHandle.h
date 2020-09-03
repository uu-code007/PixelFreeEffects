//
//  FUDateHandle.h
//  FULiveDemo
//
//  Created by 孙慕 on 2020/6/20.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUBeautyParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUDateHandle : NSObject
+(NSArray<FUBeautyParam *>*)setupFilterData;
+(NSArray<FUBeautyParam *>*)setupSkinData;

+(NSArray<FUBeautyParam *>*)setupShapData;

+(NSArray<FUBeautyParam *>*)setupSticker;

+(NSArray<FUBeautyParam *>*)setupMakeupData;

@end

NS_ASSUME_NONNULL_END
