//
//  AdjustmentItem.m
//  testGPUImage
//
//  Created by sunmu on 2025/3/16.
//

#import "AdjustmentItem.h"

@implementation AdjustmentItem

- (instancetype)initWithName:(NSString *)name value:(float)value minValue:(float)minValue maxValue:(float)maxValue {
    self = [super init];
    if (self) {
        _name = name;
        _value = value;
        _minValue = minValue;
        _maxValue = maxValue;
    }
    return self;
}

@end
