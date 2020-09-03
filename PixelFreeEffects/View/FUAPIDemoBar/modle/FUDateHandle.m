//
//  FUDateHandle.m
//  FULiveDemo
//
//  Created by 孙慕 on 2020/6/20.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import "FUDateHandle.h"
#import "FUBeautyParam.h"

@implementation FUDateHandle


+(NSArray<FUBeautyParam *>*)setupFilterData{
    NSArray *beautyFiltersDataSource = @[@"makeup_noitem",@"filter_lutup_ol",@"filter_lutup_pink"];
    
    NSDictionary *filtersCHName = @{@"makeup_noitem":@"原图",@"filter_lutup_ol":@"时尚",@"filter_lutup_pink":@"粉嫩"};

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *str in beautyFiltersDataSource) {
        FUBeautyParam *modle = [[FUBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [filtersCHName valueForKey:str];
        modle.mValue = 0.4;
        modle.type = FUDataTypeFilter;
        [array addObject:modle];
    }
    
    return array;
}

+(NSArray<FUBeautyParam *>*)setupSkinData{
    
    NSArray *prams = @[@"writen",@"runddy",@"blur",@"sharpen"];//
    NSDictionary *titelDic = @{@"writen":@"美白",@"runddy":@"红润",@"blur":@"磨皮",@"sharpen":@"锐化"};
    NSDictionary *defaultValueDic = @{@"runddy":@(0.6),@"writen":@(0.6),@"blur":@(0.7),@"sharpen":@(0.2)};
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (NSString *str in prams) {
        FUBeautyParam *modle = [[FUBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [titelDic valueForKey:str];
        modle.mValue = [[defaultValueDic valueForKey:str] floatValue];
        modle.defaultValue = modle.mValue;
        modle.type = FUDataTypeBeautify;
        [array addObject:modle];
    }
    
    return array;
    
}


+(NSArray<FUBeautyParam *>*)setupShapData{
   NSArray *prams = @[@"enlargeEyeStrength",@"faceLiftStrength",@"faceShaveStrength",@"chinChangeStrength"];
    NSDictionary *titelDic = @{@"faceLiftStrength":@"瘦脸",@"faceShaveStrength":@"v脸",@"enlargeEyeStrength":@"大眼",@"chinChangeStrength":@"下巴"};
   NSDictionary *defaultValueDic = @{@"faceLiftStrength":@(0),@"faceShaveStrength":@(0.0),@"enlargeEyeStrength":@(0),@"chinChangeStrength":@(0)
   };
   
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
//       BOOL isStyle101 = NO;
//       if ([str isEqualToString:@"intensity_chin"] || [str isEqualToString:@"intensity_forehead"] || [str isEqualToString:@"intensity_mouth"] || [str isEqualToString:@"intensity_eye_space"] || [str isEqualToString:@"intensity_eye_rotate"] || [str isEqualToString:@"intensity_long_nose"] || [str isEqualToString:@"intensity_philtrum"]) {
//           isStyle101 = YES;
//       }
       FUBeautyParam *modle = [[FUBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
       modle.mValue = [[defaultValueDic valueForKey:str] floatValue];
       modle.defaultValue = modle.mValue;
//       modle.iSStyle101 = isStyle101;
       modle.type = FUDataTypeBeautify;
       [array addObject:modle];
   }
    
    return array;
}

+(NSArray<FUBeautyParam *>*)setupSticker{
   NSArray *prams = @[@"makeup_noitem",@"baixiaomaohuxu",@"halo"];//,@"chri1"

  NSDictionary *titelDic = @{@"makeup_noitem":@"取消",@"baixiaomaohuxu":@"猫",@"halo":@"halo"};
    
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
       FUBeautyParam *modle = [[FUBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
      modle.type = FUDataTypeStrick;
       [array addObject:modle];
       
   }
    
    return array;
}

+(NSArray<FUBeautyParam *>*)setupMakeupData{
   NSArray *prams = @[@"makeup_noitem",@"lip"];
    NSDictionary *titelDic = @{@"makeup_noitem":@"卸妆",@"lip":@"口红"};
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
       FUBeautyParam *modle = [[FUBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
       modle.type = FUDataTypeMakeup;
       modle.mValue = 0.7;
       [array addObject:modle];
   }
    
    return array;
}



@end
