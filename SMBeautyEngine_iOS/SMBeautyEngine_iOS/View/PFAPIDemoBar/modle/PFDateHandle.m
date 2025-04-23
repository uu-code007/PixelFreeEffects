//
//  PFDateHandle.m
//  SMEngineDemo
//
//  Created by mumu on 2020/6/20.
//  Copyright © 2020 pfdetect. All rights reserved.
//

#import "PFDateHandle.h"
#import "PFBeautyParam.h"

@implementation PFDateHandle

+(NSArray<PFBeautyParam *>*)setupFilterData{
    NSArray *beautyFiltersDataSource = @[@"origin",@"meibai1",
                            
                                         @"liangbai1",
                                         @"fennen1",
                                         @"nuansediao1",
                                         @"gexing1",
                                         @"xiaoqingxin1",
                                         @"heibai1"];
    
    NSDictionary *filtersCHName = @{@"origin":@"原图",@"filter_lutup_ol":@"时尚",@"filter_lutup_pink":@"粉嫩"};
    NSDictionary *titelDic = @{@"origin":@"原图",@"meibai1":@"美白",@"liangbai1":@"白亮", @"fennen1":@"粉嫩",@"nuansediao1":@"暖色调",@"gexing1":@"个性1",@"xiaoqingxin1":@"小清新",@"heibai1":@"黑白"};

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *str in beautyFiltersDataSource) {
        PFBeautyParam *modle = [[PFBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [titelDic valueForKey:str];
        modle.mValue = 0.5;
        modle.type = FUDataTypeFilter;
        [array addObject:modle];
    }
    
    return array;
}

+(NSArray<PFBeautyParam *>*)setupSkinData{
    NSArray *prams = @[@"writen",@"runddy",@"blur",@"sharpen",@"eye_b",@"qualityStrength"];//
    NSDictionary *titelDic = @{@"writen":@"美白",@"runddy":@"红润",@"blur":@"磨皮",@"sharpen":@"锐化",@"newWhitenStrength":@"新美白",@"eye_b":@"亮眼",@"qualityStrength":@"增强画质"};
    NSDictionary *defaultValueDic = @{@"runddy":@(0.6),@"writen":@(0.6),@"blur":@(0.7),@"sharpen":@(0.2),@"eye_b":@(0.0),@"newWhitenStrength":@(0.2),@"qualityStrength":@(0.2)};
    
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
                       @"face_mouth",@"face_philtrum",@"face_long_nose",@"face_eye_space",@"face_smile",@"face_eye_rotate",@"face_canthus"];

     NSDictionary *titelDic = @{@"face_EyeStrength":@"大眼",@"face_thinning":@"瘦脸",@"face_narrow":@"瘦颧骨",@"face_chin":@"下巴",
                                @"face_V":@"瘦下颔",@"face_small":@"小脸",@"face_nose":@"瘦鼻",@"face_forehead":@"额头",
                                @"face_mouth":@"嘴巴",@"face_philtrum":@"人中",@"face_long_nose":@"长鼻",@"face_eye_space":@"眼距",@"face_smile":@"微笑嘴角",@"face_eye_rotate":@"眼睛角度",@"face_canthus":@"开眼角"
     };
    NSDictionary *defaultValueDic = @{@"face_EyeStrength":@(0.2),@"face_thinning":@(0.2),@"face_narrow":@(0.2),@"face_chin":@(0.5),
                                      @"face_V":@(0.2),@"face_small":@(0.2),@"face_nose":@(0.2),@"face_forehead":@(0.5),
                                      @"face_mouth":@(0.5),@"face_philtrum":@(0.5),@"face_long_nose":@(0.5),@"face_eye_space":@(0.5),@"face_smile":@(0),@"face_eye_rotate":@(0.5),@"face_canthus":@(0)
    };
    
    
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
    BOOL isStyle101 = NO;
    if ([str isEqualToString:@"face_chin"] || [str isEqualToString:@"face_forehead"] || [str isEqualToString:@"face_mouth"] || [str isEqualToString:@"face_eye_space"] || [str isEqualToString:@"face_long_nose"] || [str isEqualToString:@"face_philtrum"] || [str isEqualToString:@"face_eye_rotate"]) {
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

+(NSArray<PFBeautyParam *>*)setupFaceType{
   NSArray *prams = @[@"makeup_noitem",@"ziran",@"keai",@"nvshen",@"baijing"];//,@"chri1"

  NSDictionary *titelDic = @{@"makeup_noitem":@"origin",@"ziran":@"自然",@"keai":@"可爱",@"nvshen":@"女神",@"baijing":@"白净"};
    
   NSMutableArray *array = [[NSMutableArray alloc] init];
   for (NSString *str in prams) {
       PFBeautyParam *modle = [[PFBeautyParam alloc] init];
       modle.mParam = str;
       modle.mTitle = [titelDic valueForKey:str];
       modle.type = FUDataTypeOneKey;
       [array addObject:modle];
   }
    
    return array;
}

//+(NSArray<PFBeautyParam *>*)setupMakeupData{
//   NSArray *prams = @[@"makeup_noitem",@"lip"];
//    NSDictionary *titelDic = @{@"makeup_noitem":@"卸妆",@"lip":@"口红"};
//    
//    NSDictionary *defaultValueDic = @{@"makeup_noitem":@(0),@"lip":@(0.5)};
//
//   NSMutableArray *array = [[NSMutableArray alloc] init];
//   for (NSString *str in prams) {
//       PFBeautyParam *modle = [[PFBeautyParam alloc] init];
//       modle.mParam = str;
//       modle.mTitle = [titelDic valueForKey:str];
//       modle.type = FUDataTypeMakeup;
//       modle.mValue = [[defaultValueDic valueForKey:str] floatValue];;
//       [array addObject:modle];
//   }
//    
//    return array;
//}



+(NSDictionary *)setFaceType:(int)face{
    NSDictionary *defaultValueDic = nil;
    switch (face) {
        case 1://自然
            defaultValueDic = @{@"runddy":@(0.6),@"writen":@(0.6),@"blur":@(0.7),@"sharpen":@(0.2),@"newWhitenStrength":@(0.2),@"qualityStrength":@(0.2),@"face_EyeStrength":@(0.2),@"face_thinning":@(0.2),@"face_narrow":@(0.2),@"face_chin":@(0.5),
                                              @"face_V":@(0.2),@"face_small":@(0.2),@"face_nose":@(0.2),@"face_forehead":@(0.5),
                                              @"face_mouth":@(0.5),@"face_philtrum":@(0.5),@"face_long_nose":@(0.5),@"face_eye_space":@(0.5)
            };
            break;
        case 2://可爱
            defaultValueDic = @{@"runddy":@(0.6),@"writen":@(0.6),@"blur":@(0.7),@"sharpen":@(0.3),@"newWhitenStrength":@(0.2),@"qualityStrength":@(0.3),@"face_EyeStrength":@(0.6),@"face_thinning":@(0.3),@"face_narrow":@(0.0),@"face_chin":@(0.2),
                                              @"face_V":@(0.0),@"face_small":@(0.2),@"face_nose":@(0.2),@"face_forehead":@(0.2),
                                              @"face_mouth":@(0.5),@"face_philtrum":@(0.5),@"face_long_nose":@(0.5),@"face_eye_space":@(0.5)
            };
            break;
        case 3://女神
            defaultValueDic = @{@"runddy":@(0.5),@"writen":@(0.5),@"blur":@(0.6),@"sharpen":@(0.2),@"newWhitenStrength":@(0.2),@"qualityStrength":@(0.2),@"face_EyeStrength":@(0.4),@"face_thinning":@(0.3),@"face_narrow":@(0.4),@"face_chin":@(0.5),
                                              @"face_V":@(0.2),@"face_small":@(0.2),@"face_nose":@(0.2),@"face_forehead":@(0.5),
                                              @"face_mouth":@(0.5),@"face_philtrum":@(0.5),@"face_long_nose":@(0.5),@"face_eye_space":@(0.5)
            };
            break;
        case 4://净白
            defaultValueDic = @{@"runddy":@(0.5),@"writen":@(0.8),@"blur":@(0.7),@"sharpen":@(0.2),@"newWhitenStrength":@(0.2),@"qualityStrength":@(0.2),@"face_EyeStrength":@(0.2),@"face_thinning":@(0.2),@"face_narrow":@(0.0),@"face_chin":@(0.5),
                                              @"face_V":@(0.0),@"face_small":@(0.0),@"face_nose":@(0.5),@"face_forehead":@(0.5),
                                              @"face_mouth":@(0.5),@"face_philtrum":@(0.5),@"face_long_nose":@(0.5),@"face_eye_space":@(0.5)
            };
            break;
            
        default:
            break;
    }
    return defaultValueDic;
}


+(NSArray<PFBeautyParam *>*)setupStickers{
    NSMutableArray *beautyFiltersDataSource = [@[@"origin",@"flowers",@"candy",@"maorong",@"xiongerduo",@"xiantiaoxiongmao",@"sunflower_glasses"] mutableCopy];

    NSDictionary *titelDic = @{@"origin":@"origin",@"flowers":@"flowers",@"baixiaomao":@"baixiaomao",@"candy":@"candy",@"maorong":@"maorong",@"xiongerduo":@"xiongerduo",@"xiantiaoxiongmao":@"xiantiaoxiongmao"};
    

//    NSArray<NSString *> * aar = [self getAllSubdirectoryNames];
//    [beautyFiltersDataSource addObjectsFromArray:aar];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *str in beautyFiltersDataSource) {
        PFBeautyParam *modle = [[PFBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = str;
        modle.type = FUDataTypeStickers;
        [array addObject:modle];
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"allStickers" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return array;
    }

    for (NSDictionary *dict in jsonArray) {
        PFBeautyParam *param = [[PFBeautyParam alloc] init];
        param.mParam = dict[@"mParam"];
        param.mTitle = dict[@"mTitle"];
        param.type = FUDataTypeStickers;
        [array addObject:param];
    }
    
    return array;
}

+ (NSArray<NSString *> *)getAllSubdirectoryNames{
    NSString *s2dPath = [[NSBundle mainBundle] pathForResource:@"pixelfree2D" ofType:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:s2dPath isDirectory:&isDirectory];

    if (exists && isDirectory) {
        NSLog(@"kiwi2D 文件夹路径: %@", s2dPath);
    } else {
        NSLog(@"kiwi2D 文件夹不存在");
    }
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:s2dPath error:nil];
    NSMutableArray *subdirectories = [NSMutableArray array];

    for (NSString *item in contents) {
        NSString *fullPath = [s2dPath stringByAppendingPathComponent:item];
        BOOL isSubDirectory = NO;
        [fileManager fileExistsAtPath:fullPath isDirectory:&isSubDirectory];
        
        if (isSubDirectory) {
            [subdirectories addObject:item];
        }
    }
    return subdirectories;
}

@end
