//
//  PFDateHandle.h
//  SMEngineDemo
//
//  Created by mumu on 2020/6/20.
//  Copyright © 2020 pfdetect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFBeautyParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface PFDateHandle : NSObject
+(NSArray<PFBeautyParam *>*)setupFilterData;
+(NSArray<PFBeautyParam *>*)setupSkinData;

+(NSArray<PFBeautyParam *>*)setupShapData;
+(NSArray<PFBeautyParam *>*)setupFaceType;

+(NSArray<PFBeautyParam *>*)setupStickers;

+(NSArray<PFBeautyParam *>*)setupMakeupData;

+(NSDictionary *)setFaceType:(int)face;

@end

NS_ASSUME_NONNULL_END
