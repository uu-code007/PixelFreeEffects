//
//  UIColor+FUDemoBar.h
//  PFAPIDemoBar
//
//
//  Created by mumu on 2021/9/6.
//
#import <UIKit/UIKit.h>

@interface UIColor (PFBeautyEditView)

/**
 *  十六进制颜色
 */
+ (UIColor *)colorWithHexColorString:(NSString *)hexColorString;

/**
 *  十六进制颜色:含alpha
 */
+ (UIColor *)colorWithHexColorString:(NSString *)hexColorString alpha:(float)alpha;
@end
