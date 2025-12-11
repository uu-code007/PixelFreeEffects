//
//  PFBeautyParam.m
//  SMEngineDemo
//
//  Created by mumu on 2020/1/7.
//  Copyright © 2020 pfdetect. All rights reserved.
//

#import "PFBeautyParam.h"

@implementation PFBeautyParam


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.mTitle = [coder decodeObjectForKey:@"mTitle"];
        self.mParam = [coder decodeObjectForKey:@"mParam"];
        self.mValue = [coder decodeFloatForKey:@"mValue"];
        self.defaultValue = [coder decodeFloatForKey:@"defaultValue"];
        self.type = [coder decodeIntForKey:@"type"];
        self.iSStyle101 = [coder decodeBoolForKey:@"iSStyle101"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mTitle forKey:@"mTitle"];
    [coder encodeObject:self.mParam forKey:@"mParam"];
    [coder encodeFloat:self.mValue forKey:@"mValue"];
    [coder encodeFloat:self.defaultValue forKey:@"defaultValue"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeBool:self.iSStyle101 forKey:@"iSStyle101"];
}
@end
