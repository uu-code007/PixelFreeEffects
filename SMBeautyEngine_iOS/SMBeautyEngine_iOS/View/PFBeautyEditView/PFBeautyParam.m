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
        self.iconURL = [coder decodeObjectForKey:@"iconURL"];
        self.bundleURL = [coder decodeObjectForKey:@"bundleURL"];
        self.localBundlePath = [coder decodeObjectForKey:@"localBundlePath"];
        self.isRemoteResource = [coder decodeBoolForKey:@"isRemoteResource"];
        self.isDownloaded = [coder decodeBoolForKey:@"isDownloaded"];
        self.isDownloading = [coder decodeBoolForKey:@"isDownloading"];
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
    [coder encodeObject:self.iconURL forKey:@"iconURL"];
    [coder encodeObject:self.bundleURL forKey:@"bundleURL"];
    [coder encodeObject:self.localBundlePath forKey:@"localBundlePath"];
    [coder encodeBool:self.isRemoteResource forKey:@"isRemoteResource"];
    [coder encodeBool:self.isDownloaded forKey:@"isDownloaded"];
    [coder encodeBool:self.isDownloading forKey:@"isDownloading"];
}
@end
