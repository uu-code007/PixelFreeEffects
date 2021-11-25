//
//  FUDateHandle.m
//  FULiveDemo
//
//  Created by 孙慕 on 2020/6/20.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import "FUDateHandle.h"
#import "PFBeautyParam.h"

@implementation FUDateHandle


+(NSArray<PFBeautyParam *>*)setupFilterData{
    NSArray *beautyFiltersDataSource = @[@"origin",@"filter1",@"filter3",@"filter9",@"filter18",@"filter29",@"filter40",@"filter45"];
    
    NSDictionary *filtersCHName = @{@"makeup_noitem":@"原图",@"filter_lutup_ol":@"时尚",@"filter_lutup_pink":@"粉嫩"};

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *str in beautyFiltersDataSource) {
        PFBeautyParam *modle = [[PFBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = str;
        modle.mValue = 1.0;
        modle.type = FUDataTypeFilter;
        [array addObject:modle];
    }
    
    return array;
}

+(NSArray<PFBeautyParam *>*)setupSkinData{
    NSArray *prams = @[@"writen",@"newWhitenStrength",@"runddy",@"blur",@"sharpen",@"qualityStrength"];//
    NSDictionary *titelDic = @{@"writen":@"美白",@"runddy":@"红润",@"blur":@"磨皮",@"sharpen":@"锐化",@"newWhitenStrength":@"新美白",@"qualityStrength":@"增强画质"};
    NSDictionary *defaultValueDic = @{@"runddy":@(0.6),@"writen":@(0.6),@"blur":@(0.7),@"sharpen":@(0.2),@"newWhitenStrength":@(0.2),@"qualityStrength":@(0.2)};
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (NSString *str in prams) {
        PFBeautyParam *modle = [[PFBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [titelDic valueForKey:str];
        modle.mValue = [[defaultValueDic valueForKey:str] floatValue];
        modle.defaultValue = modle.mValue;
        modle.type = FUDataTypeBeautify;
        [array addObject:modle];
    }
    
    return array;
    
}


+(NSArray<PFBeautyParam *>*)setupShapData{
//   NSArray *prams = @[@"enlargeEyeStrength",@"faceLiftStrength",@"faceShaveStrength",@"chinChangeStrength"];
//    NSDictionary *titelDic = @{@"faceLiftStrength":@"瘦脸",@"faceShaveStrength":@"v脸",@"enlargeEyeStrength":@"大眼",@"chinChangeStrength":@"下巴"};
//   NSDictionary *defaultValueDic = @{@"faceLiftStrength":@(0.2),@"faceShaveStrength":@(0.2),@"enlargeEyeStrength":@(0.2),@"chinChangeStrength":@(0.2)
//   };
   
    NSArray *prams = @[@"face_EyeStrength",@"face_thinning",@"face_narrow",@"face_chin",
                                      @"face_V",@"face_small",@"face_nose",@"face_forehead",
                       @"face_mouth",@"face_philtrum",@"face_long_nose",@"face_eye_space"];
     NSDictionary *titelDic = @{@"face_EyeStrength":@"大眼",@"face_thinning":@"瘦脸",@"face_narrow":@"窄脸",@"face_chin":@"下巴",
                                @"face_V":@"v脸",@"face_small":@"小脸",@"face_nose":@"瘦鼻",@"face_forehead":@"额头",
                                @"face_mouth":@"嘴巴",@"face_philtrum":@"人中",@"face_long_nose":@"长鼻",@"face_eye_space":@"眼距"
     };
    NSDictionary *defaultValueDic = @{@"face_EyeStrength":@(0.2),@"face_thinning":@(0.2),@"face_narrow":@(0.2),@"face_chin":@(0.5),
                                      @"face_V":@(0.2),@"face_small":@(0.2),@"face_nose":@(0.2),@"face_forehead":@(0.5),
                                      @"face_mouth":@(0.5),@"face_philtrum":@(0.5),@"face_long_nose":@(0.5),@"face_eye_space":@(0.5)
    };
    
    
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
    BOOL isStyle101 = NO;
    if ([str isEqualToString:@"face_chin"] || [str isEqualToString:@"face_forehead"] || [str isEqualToString:@"face_mouth"] || [str isEqualToString:@"face_eye_space"] || [str isEqualToString:@"face_long_nose"] || [str isEqualToString:@"face_philtrum"]) {
           isStyle101 = YES;
    }
       PFBeautyParam *modle = [[PFBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
       modle.mValue = [[defaultValueDic valueForKey:str] floatValue];
       modle.defaultValue = modle.mValue;
       modle.iSStyle101 = isStyle101;
       modle.type = FUDataTypeBeautify;
       [array addObject:modle];
   }
    
    return array;
}

+(NSArray<PFBeautyParam *>*)setupSticker{
   NSArray *prams = @[@"makeup_noitem",@"baixiaomaohuxu",@"ballCap"];//,@"chri1"

  NSDictionary *titelDic = @{@"makeup_noitem":@"取消",@"baixiaomaohuxu":@"猫",@"ballCap":@"ballCap"};
    
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
       PFBeautyParam *modle = [[PFBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
      modle.type = FUDataTypeStrick;
       [array addObject:modle];
       
   }
    
    return array;
}

+(NSArray<PFBeautyParam *>*)setupMakeupData{
   NSArray *prams = @[@"makeup_noitem",@"lip"];
    NSDictionary *titelDic = @{@"makeup_noitem":@"卸妆",@"lip":@"口红"};
    
    NSDictionary *defaultValueDic = @{@"makeup_noitem":@(0),@"lip":@(0.5)};

   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
       PFBeautyParam *modle = [[PFBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
       modle.type = FUDataTypeMakeup;
       modle.mValue = [[defaultValueDic valueForKey:str] floatValue];;
       [array addObject:modle];
   }
    
    return array;
}



@end
