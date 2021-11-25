//
//  FUDateHandle.h
//  FULiveDemo
//
//  Created by 孙慕 on 2020/6/20.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFBeautyParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUDateHandle : NSObject
+(NSArray<PFBeautyParam *>*)setupFilterData;
+(NSArray<PFBeautyParam *>*)setupSkinData;

+(NSArray<PFBeautyParam *>*)setupShapData;

+(NSArray<PFBeautyParam *>*)setupSticker;

+(NSArray<PFBeautyParam *>*)setupMakeupData;

@end

NS_ASSUME_NONNULL_END
