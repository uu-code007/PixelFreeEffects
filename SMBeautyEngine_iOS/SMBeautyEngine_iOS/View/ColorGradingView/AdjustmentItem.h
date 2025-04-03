//
//  AdjustmentItem.h
//  testGPUImage
//
//  Created by sunmu on 2025/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustmentItem : NSObject

@property (nonatomic, copy) NSString *name; // 调节项名称
@property (nonatomic, assign) float value;   // 当前值
@property (nonatomic, assign) float minValue; // 最小值
@property (nonatomic, assign) float maxValue; // 最大值

- (instancetype)initWithName:(NSString *)name value:(float)value minValue:(float)minValue maxValue:(float)maxValue;

@end

NS_ASSUME_NONNULL_END
