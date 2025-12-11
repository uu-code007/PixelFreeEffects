//
//  UIImage+demobar.m
//  PFAPIDemoBar
//
//
//  Created by mumu on 2021/9/6.
//

#import "UIImage+demobar.h"
#import "PFBeautyEditView.h"

@implementation UIImage (demobar)

+ (UIImage *)imageWithName:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:PFBeautyEditView.class] compatibleWithTraitCollection:nil];
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end
