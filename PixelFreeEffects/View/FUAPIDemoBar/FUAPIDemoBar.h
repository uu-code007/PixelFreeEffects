//
//  FUDemoBar.h
//  FUAPIDemoBar
//
//  Created by L on 2018/6/26.
//  Copyright © 2018年 L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUBeautyParam.h"

@protocol FUAPIDemoBarDelegate <NSObject>

// 滤镜程度改变
- (void)filterValueChange:(FUBeautyParam *)param;

-(void)bottomDidChange:(int)index;
// 显示上半部分View
-(void)showTopView:(BOOL)shown;

// 开启关闭按钮
- (void)switchRenderState:(BOOL)state;

@end

@interface FUAPIDemoBar : UIView

@property (nonatomic, assign) id<FUAPIDemoBarDelegate>mDelegate ;


// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation;

// 上半部是否显示
@property (nonatomic, assign) BOOL isTopViewShow ;

-(void)setDefaultFilter:(FUBeautyParam *)filter;


@end
