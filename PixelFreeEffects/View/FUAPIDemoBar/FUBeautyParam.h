//
//  FUBeautyParam.h
//  FULiveDemo
//
//  Created by 孙慕 on 2020/1/7.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FUDataType) {
    FUDataTypeBeautify            = 0,
    FUDataTypeFilter,
    FUDataTypeStrick,
    FUDataTypeMakeup,
    FUDataTypebody
};

@interface FUBeautyParam : NSObject
@property (nonatomic,copy)NSString *mTitle;

@property (nonatomic,copy)NSString *mParam;

@property (nonatomic,assign)float mValue;

/* 双向的参数  0.5是原始值*/
@property (nonatomic,assign) BOOL iSStyle101;

/* 默认值用于，设置默认和恢复 */
@property (nonatomic,assign)float defaultValue;


@property (nonatomic,assign)FUDataType type;
@end

NS_ASSUME_NONNULL_END
